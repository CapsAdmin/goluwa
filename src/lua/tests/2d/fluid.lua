--require"jit.dump".on("+a", R"%DATA%/logs/" .. "jit_dump.txt")

local function new_array(val, size)
	local arr = ffi.new("float[?]", size)
	ffi.fill(arr, val)
	return arr
end

local META = {}
META.__index = META

function META:tick()
	self:update();
	self:draw();
end

function META:update()
	self.u_prev = new_array(0, self.bufferSize);
	self.v_prev = new_array(0, self.bufferSize);
	self.dens_prev = new_array(0, self.bufferSize);

	self:handleInput();
	self:velocityStep();
	self:densityStep();
end

function META:handleInput()
	local x, y = surface.ScreenToWorld(surface.GetMousePosition())

	-- Lower boundary
	x = math.max(0, x);
	y = math.max(0, y);

	-- Upper boundary
	x = math.min(self.canvas.w, x);
	y = math.min(self.canvas.h, y);

	if not self.mouse then
		self.mouse = {}
		self.mouse.x = x
		self.mouse.y = y;
	end

	local gridX = math.floor((self.mouse.x / self.cwidth) * self.gridResPlus1);
	local gridY = math.floor((self.mouse.y / self.cheight) * self.gridResPlus1); -- TODO Fixme on non-square surfices

	if (not (gridX < 1 or gridX > self.gridResolution or gridY < 1 or gridY > self.gridResolution)) then
		if input.IsMouseDown("button_1") then
			self.u[self:IX(gridX, gridY)] = self.force * (x - self.mouse.x);
			self.v[self:IX(gridX, gridY)] = self.force * (self.mouse.y - y);
		end

		if input.IsMouseDown("button_2") then
			for x = 6, 0, -1 do
				for y = 6, 0, -1 do
					self.dens_prev[self:IX(gridX - x, gridY - y + 4)] = self.source;
				end
			end
		end
	end

	self.mouse.x = x;
	self.mouse.y = y;
end

function META:draw()
	--do return end
	local bufferData = self.canvas:CreateBuffer()
	local h = self.cwidth / self.gridResolution;

	for y = 0, self.cheight -1 do
		for x = 0, self.cwidth - 1 do
			local d00 = self.dens[self:IX(x, -y + self.cheight)];
			d00 = math.min(0xff, d00);

			local index = (y * self.cwidth + x) * 4
			bufferData[index].r = d00; -- RED
			bufferData[index].g = d00; -- GREEN
			bufferData[index].b = d00; -- BLUE
			bufferData[index].a = 255; -- ALPHA
		end
	end

	self.canvas:Upload({buffer = bufferData})

	surface.SetTexture(self.canvas)
	surface.SetColor(1,1,1,1)
	surface.DrawRect(0, 0, self.cwidth, self.cheight)
end

function META:setBnd(b, x)
	for i = 1, self.gridResolution do
		local z = x[self:IX(1, i)];
		local y = x[self:IX(self.gridResolution, i)];
		x[self:IX(0, i)] = b == 1 and -z or z;
		x[self:IX(self.gridResPlus1, i)] = b == 1 and -y or y;

		z = x[self:IX(i, 1)];
		y = x[self:IX(i, self.gridResolution)];
		x[self:IX(i, 0)] = b == 2 and -z or z;
		x[self:IX(i, self.gridResPlus1)] = b == 2 and -y or y;
	end

	x[self:IX(0, 0)] = 0.5 * (x[self:IX(1, 0)] + x[self:IX(0, 1)]);
	x[self:IX(0, self.gridResPlus1)] = 0.5 * (x[self:IX(1, self.gridResPlus1)] + x[self:IX(0, self.gridResolution)]);
	x[self:IX(self.gridResPlus1, 0)] = 0.5 * (x[self:IX(self.gridResolution, 0)] + x[self:IX(self.gridResPlus1, 1)]);
	x[self:IX(self.gridResPlus1, self.gridResPlus1)] = 0.5 * (x[self:IX(self.gridResolution, self.gridResPlus1)] + x[self:IX(self.gridResPlus1, self.gridResolution)]);

	return x;
end

function META:IX(x, y)
	return self.gridResPlus2 * y + x;
end

function META:linearSolve(b, current, previous, a, div)
	local inverseC = 1/div;
	local locA = a;
	local locB = b;
	local pCur = current;

	local iterations = locA == 0 and 1 or 20;
	for k = 0, iterations - 1 do
		for x = self.gridResolution, 1, -1 do
			for y = self.gridResolution, 1, -1 do
				local i = self:IX(x, y);
				local v = previous[i];

				if (locA ~= 0) then
					local s = pCur[i - 1] +
						pCur[i + 1] +
						pCur[i - self.gridResPlus2] +
						pCur[i + self.gridResPlus2];

					v = v + locA * s;
				end

				pCur[i] = v * inverseC;
			end
		end
	end

	self:setBnd(locB, current);
end

function META:advect(b, current, prev, u, v)
	local dt0 = self.dt * self.gridResolution;

	for i = 1, self.gridResolution do
		for j = 1, self.gridResolution do
			local ix1 = self:IX(i,j);

			local x = i - dt0 * u[ix1];
			local y = j - dt0 * v[ix1];

			x = math.max(x, 0.5)
			x = math.min(x, self.gridResolution + 0.5)

			local i0 = math.floor(x);
			local i1 = i0 + 1;

			y = math.max(y, 0.5)
			y = math.min(y, self.gridResolution + 0.5)

			local j0 = math.floor(y);
			local j1 = j0 + 1;
			local s1 = x - i0;
			local s0 = 1 - s1;
			local t1 = y - j0;
			local t0 = 1 - t1;

			current[ix1] = s0 * (t0 * prev[self:IX(i0, j0)] + t1 * prev[self:IX(i0, j1)]) +
				s1 * (t0 * prev[self:IX(i1, j0)] + t1 * prev[self:IX(i1, j1)]);
		end
	end
	self:setBnd(b, current);
end

function META:diffuse(b, current, prev, rate)
	local a = self.dt * rate * self.gridResolution * self.gridResolution;
	self:linearSolve(b, current, prev, a, 1 + 4 * a);
end

function META:project()
	local i, j;

	for i = 1, self.gridResolution do
		for j = 1, self.gridResolution do
			self.v_prev[self:IX(i, j)] = -0.5 * (self.u[self:IX(i + 1, j)] - self.u[self:IX(i - 1, j)] + self.v[self:IX(i, j + 1)] - self.v[self:IX(i, j - 1)]) / self.gridResolution;
			self.u_prev[self:IX(i, j)] = 0;
		end
	end

	self:setBnd(0, self.v_prev);
	self:setBnd(0, self.u_prev);

	self:linearSolve(0, self.u_prev, self.v_prev, 1, 4);

	for i = 1, self.gridResolution do
		for j = 1, self.gridResolution do
			self.u[self:IX(i, j)] = self.u[self:IX(i, j)] - 0.5 * self.gridResolution * (self.u_prev[self:IX(i + 1, j)] - self.u_prev[self:IX(i - 1, j)]);
			self.v[self:IX(i, j)] = self.v[self:IX(i, j)] - 0.5 * self.gridResolution * (self.u_prev[self:IX(i, j + 1)] - self.u_prev[self:IX(i, j - 1)]);
		end
	end

	self:setBnd(1, self.u);
	self:setBnd(2, self.v);
end

function META:densityStep()
	self:addSource(self.dens, self.dens_prev);

	--swapBuffers(ref dens_prev, ref dens);
	local z = self.dens_prev; self.dens_prev = self.dens; self.dens = z;
	self:diffuse(0, self.dens, self.dens_prev, self.diffusionRate);

	z = self.dens_prev; self.dens_prev = self.dens; self.dens = z;
	self:advect(0, self.dens, self.dens_prev, self.u, self.v);
end

function META:velocityStep()
	-- N, u, v, u_prev, v_prev, visc, dt
	self:addSource(self.u, self.u_prev);
	self:addSource(self.v, self.v_prev);

	local z = self.u_prev; self.u_prev = self.u; self.u = z;
	self:diffuse(1, self.u, self.u_prev, self.viscocity);

	z = self.v_prev; self.v_prev = self.v; self.v = z;
	self:diffuse(2, self.v, self.v_prev, self.viscocity);

	self:project();

	z = self.u_prev; self.u_prev = self.u; self.u = z;
	z = self.v_prev; self.v_prev = self.v; self.v = z;

	self:advect(1, self.u, self.u_prev, self.u_prev, self.v_prev);
	self:advect(2, self.v, self.v_prev, self.u_prev, self.v_prev);

	self:project();
end

function META:addSource(current, prev)
	for i = 0, self.bufferSize - 1 do
		current[i] = current[i] + self.dt * prev[i];
	end
end

function FField(resolution, debug)
	local self = setmetatable({}, META)

    self.debug = debug or false;

    self.gridResolution = resolution or 128;
    self.diffusionRate = 0.0;
    self.viscocity = 0.0;
    self.force = 5.0; -- scales the mouse movement that generate a force
    self.source = 300.0; -- amount of density that will be deposited

    self.gridResPlus1 =  self.gridResolution + 1;
    self.gridResPlus2 = self.gridResolution + 2;
    self.bufferSize = self.gridResPlus2 * self.gridResPlus2;

    self.u = new_array(0, self.bufferSize);
    self.v = new_array(0, self.bufferSize);
    self.dens = new_array(0, self.bufferSize);

    self.u_prev = new_array(0, self.bufferSize);
    self.v_prev = new_array(0, self.bufferSize);
    self.dens_prev = new_array(0, self.bufferSize);

    self.dt = 0.1;

	self.canvas = Texture(self.gridResolution, self.gridResolution)
	self.cwidth = self.canvas.w
	self.cheight = self.canvas.h

	return self
end

local fluid = FField(256)

event.AddListener("Draw2D", "lol", function(dt)
	--fluid.dt = dt
	surface.PushMatrix(0,0, 2, 2)
	fluid:tick()
	surface.PopMatrix()
end)
