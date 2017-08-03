-- used like <tag=[pi * rand()]>

local expression = _G.expression or {}

local lib =
{
	PI = math.pi,
	pi = math.pi,
	rand = math.random,
	random = math.random,
	randomf = math.randomf,
	abs = math.abs,
	sgn = function (x)
		if x < 0 then return -1 end
		if x > 0 then return  1 end
		return 0
	end,

	acos = math.acos,
	asin = math.asin,
	atan = math.atan,
	atan2 = math.atan2,
	ceil = math.ceil,
	cos = math.cos,
	cosh = math.cosh,
	deg = math.deg,
	exp = math.exp,
	floor = math.floor,
	frexp = math.frexp,
	ldexp = math.ldexp,
	log = math.log,
	log10 = math.log10,
	max = math.max,
	min = math.min,
	rad = math.rad,
	sin = math.sin,
	sinc = function (x)
		if x == 0 then return 1 end
		return math.sin(x) / x
	end,
	sinh = math.sinh,
	sqrt = math.sqrt,
	tanh = math.tanh,
	tan = math.tan,

	clamp = math.Clamp,
	pow = math.pow
}

local blacklist = {"repeat", "until", "function", "end"}

local expressions = {}

function expression.Compile(str, extra_lib)
	local source = str

	for _, word in pairs(blacklist) do
		if str:find("[%p%s]" .. word) or str:find(word .. "[%p%s]") then
			return false, string.format("illegal characters used %q", word)
		end
	end

	local env = {}

	for k,v in pairs(lib) do env[k] = v end

	if extra_lib then
		for k,v in pairs(extra_lib) do env[k] = v end
	end

	local t0 = system.GetElapsedTime()
	env.t    = function () return system.GetElapsedTime() - t0 end
	env.time = function () return system.GetElapsedTime() - t0 end
	env.select = select

	str = "local input = select(1, ...) return " .. str

	local func, err = loadstring(str)

	if func then
		setfenv(func, env)
		expressions[func] = source
		return true, func
	else
		return false, err
	end
end

return expression