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

function math.clamp(number, min, max)
	return math.max(math.min(number,max),min)
end

function math.lerp(m, a, b)
	return (b - a) * m + a
end

local inf, ninf = math.huge, -math.huge

function math.isvalid(num) 
	return
	not (
		not num or 
		num == inf or 
		num == ninf or 
		not (num >= 0 or num <= 0) 
	)
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
	
    return math.floor((x % 10) + '0')
end

function math.tostring(num, base)
	local t={}
	local len = math.len(num)
	
	for i = 0, len - 1 do
		t[len - i] = math.digit10(num, i)
	end
	
	return table.concat(t)
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