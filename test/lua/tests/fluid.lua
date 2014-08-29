local N = 64
local dt = 0.001
local diff = 0.5
local visc = 0.2
local force = 5.0
local source = 100.0

local size = (N+2)*(N+2)

local function IX(i, j) return ((i)+(N+2)*(j)) end
local function SWAP(x0, x) local temp = {} for i = 0, size - 1 do temp[i] = x0[i] x0[i] = x[i] x[i] = temp[i] end end

--#define for i = 1, N do for j = 1, N do for i = 1, N do { for ( j=1 ; j<=N ; j++ ) {
--#define end end }}

local function add_source( N, x, s, dt )
	local size = (N+2)*(N+2);
	for i=0, size - 1 do x[i] = x[i] + dt*s[i]; end
end

local function set_bnd ( N, b, x )
	for i = 1, N do 
		x[IX(0  ,i)] = b==1 and -x[IX(1,i)] or x[IX(1,i)];
		x[IX(N+1,i)] = b==1 and -x[IX(N,i)] or x[IX(N,i)];
		x[IX(i,0  )] = b==2 and -x[IX(i,1)] or x[IX(i,1)];
		x[IX(i,N+1)] = b==2 and -x[IX(i,N)] or x[IX(i,N)];
	end
	x[IX(0  ,0  )] = 0.5*(x[IX(1,0  )]+x[IX(0  ,1)]);
	x[IX(0  ,N+1)] = 0.5*(x[IX(1,N+1)]+x[IX(0  ,N)]);
	x[IX(N+1,0  )] = 0.5*(x[IX(N,0  )]+x[IX(N+1,1)]);
	x[IX(N+1,N+1)] = 0.5*(x[IX(N,N+1)]+x[IX(N+1,N)]);
end

local function lin_solve ( N, b, x, x0, a, c )
	for k = 0, 19 do 
		for i = 1, N do for j = 1, N do
			x[IX(i,j)] = (x0[IX(i,j)] + a*(x[IX(i-1,j)]+x[IX(i+1,j)]+x[IX(i,j-1)]+x[IX(i,j+1)]))/c;
		end end
		set_bnd ( N, b, x );
	end
end

local function diffuse ( N, b, x, x0, diff, dt )
	local a=dt*diff*N*N;
	lin_solve ( N, b, x, x0, a, 1+4*a );
end

local function advect ( N, b, d, d0, u, v, dt )
	local dt0 = dt*N;
	local j0 = 0
	local j1 = 0
	local i0 = 0
	local i1 = 0
	for i = 1, N do for j = 1, N do
		local x = i-dt0*u[IX(i,j)]; local y = j-dt0*v[IX(i,j)];
		if (x<0.5) then x=0.5; end if (x>N+0.5) then x=N+0.5; i0=x; i1=i0+1; end
		if (y<0.5) then y=0.5; end if (y>N+0.5) then y=N+0.5; j0=y; j1=j0+1; end
		local s1 = x-i0; s0 = 1-s1; t1 = y-j0; t0 = 1-t1;
		d[IX(i,j)] = s0*(t0*d0[IX(i0,j0)]+t1*d0[IX(i0,j1)])+
					 s1*(t0*d0[IX(i1,j0)]+t1*d0[IX(i1,j1)]);
	end end
	set_bnd ( N, b, d );
end

local function project ( N, u, v, p, div )
	for i = 1, N do for j = 1, N do
		div[IX(i,j)] = -0.5*(u[IX(i+1,j)]-u[IX(i-1,j)]+v[IX(i,j+1)]-v[IX(i,j-1)])/N;
		p[IX(i,j)] = 0;
	end end	
	set_bnd ( N, 0, div ); set_bnd ( N, 0, p );

	lin_solve ( N, 0, p, div, 1, 4 );

	for i = 1, N do for j = 1, N do
		u[IX(i,j)] = u[IX(i,j)] - 0.5*N*(p[IX(i+1,j)]-p[IX(i-1,j)]);
		v[IX(i,j)] = v[IX(i,j)] - 0.5*N*(p[IX(i,j+1)]-p[IX(i,j-1)]);
	end end
	set_bnd ( N, 1, u ); set_bnd ( N, 2, v );
end

local function dens_step ( N, x, x0, u, v, diff, dt )
	add_source ( N, x, x0, dt );
	SWAP ( x0, x ); diffuse ( N, 0, x, x0, diff, dt );
	SWAP ( x0, x ); advect ( N, 0, x, x0, u, v, dt );
end

local function vel_step ( N, u, v, u0, v0, visc, dt )
	add_source ( N, u, u0, dt ); add_source ( N, v, v0, dt );
	SWAP ( u0, u ); diffuse ( N, 1, u, u0, visc, dt );
	SWAP ( v0, v ); diffuse ( N, 2, v, v0, visc, dt );
	project ( N, u, v, u0, v0 );
	SWAP ( u0, u ); SWAP ( v0, v );
	advect ( N, 1, u, u0, u0, v0, dt ); advect ( N, 2, v, v0, u0, v0, dt );
	project ( N, u, v, u0, v0 );
end

local u = {}
local v = {}
local u_prev = {} 
local v_prev = {}
local dens = {}
local dens_prev = {}

for i = 0, size - 1 do
	u[i] = math.random()
	v[i] = math.random()
	dens[i] = math.random()
	
	u_prev[i] = 0
	v_prev[i] = 0
	dens_prev[i] = 0
end
 
event.AddListener("Draw2D", "fluid", function()
	
	local size = (N+2)*(N+2)
	for i = 0, size - 1 do
		u_prev[i] = 0
		v_prev[i] = 0
		dens_prev[i] = 0
	end
	
	local w, h = surface.GetScreenSize()
	
	local i, j = surface.GetMousePos()
	i = (i / w) * N + 1
	j = (j / h) * N + 1
	
	local vmx, vmy = surface.GetMouseVel()
		
	if input.IsMouseDown("button_1") then
		u_prev[IX(i, j)] = force * vmx
		v_prev[IX(i, j)] = force * vmy
	end
	
	if input.IsMouseDown("button_2") then
		dens_prev[IX(i, j)] = source
	end
	
	vel_step ( N, u, v, u_prev, v_prev, visc, dt );
	dens_step ( N, dens, dens_prev, u, v, diff, dt );
	
	surface.SetWhiteTexture()
	
	for i = 0, N do
		for j = 0, N do
			
			d00 = dens[IX(i, j)]
			d01 = dens[IX(i, j + 1)]
			d10 = dens[IX(i + 1, j)]
			d11 = dens[IX(i + 1, j + 1)]		
									
			surface.SetColor(d00, d01, d10, 1)
			surface.DrawRect(i*4, j*4, 4, 4)
		end
	end
end, {priority = -math.huge})