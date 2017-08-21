math.tau = math.pi*2

function math.linear2gamma(n)
	if n <= 0.04045 then
		return n / 12.92
	end

	return ((n + 0.055) / 1.055) ^ 2.4
end

function math.gamma2linear(n)
	if n < 0.0031308 then
		return n * 12.92
	else
		return 1.055 * (n ^ (1.0 / 2.4)) - 0.055
	end
end

function math.normalizeangle(a)
	return (a + math.pi) % math.tau - math.pi
end

function math.map(num, in_min, in_max, out_min, out_max)
	return (num - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function math.normalize(num, min, max)
	return (num - min) / (max - min)
end

function math.pow2ceil(n)
	return 2 ^ math.ceil(math.log(n) / math.log(2))
end

function math.pow2floor(n)
	return 2 ^ math.floor(math.log(n) / math.log(2))
end

function math.pow2round(n)
	return 2 ^ math.round(math.log(n) / math.log(2))
end

function math.round(num, idp)
	if idp and idp > 0 then
		local mult = 10 ^ idp
		return math.floor(num * mult + 0.5) / mult
	end

	return math.floor(num + 0.5)
end

function math.randomf(min, max)
	min = min or -1
	max = max or 1
	return min + (math.random() * (max-min))
end

function math.clamp(self, min, max)
	return
		self <= min and min or
		self >= max and max or
		self
end

function math.lerp(m, a, b)
	return (b - a) * m + a
end

function math.len(x)
	local len = 1

	while x > 9999 do
		x = x / 10000
		len = len + 4
	end

	while x > 99 do
		x = x / 100
		len = len + 2
	end

	if x > 9 then
		len = len + 1
	end

	return len
end


function math.digit10(x, n)
    while n > 0 do
        x = x / 10
		n = n - 1
    end

    return math.floor(x % 10)
end

function math.approach(cur, target, inc)
    inc = math.abs(inc)

    if cur < target then
        return math.clamp(cur + inc, cur, target)
    elseif cur > target then
        return math.clamp(cur - inc, target, cur)
    end

    return target
end

local inf, ninf = math.huge, -math.huge

function math.isvalid(num)
	return
		num and
		num ~= inf and
		num ~= ninf and
		(num >= 0 or num <= 0)
end

function math.tostring(num)
	local t = {}
	local len = math.len(num)

	for i = 0, len - 1 do
		t[len - i] = math.digit10(num, i)
	end

	return table.concat(t)
end