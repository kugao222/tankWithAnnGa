local t = class("util")

-- 
local math = _G.math

-- 随机数
function t.rand(l,r) -- 整数
	return math.random(l,r)
end

-- 0-1 float 
local p = 10000-- p小数点后面几位
local tp = p*2
local dp = 1/p
function t.randWeight()  
	return (math.random(0,tp)-p) * dp
end

function t.exp(v)  
	return math.exp(v)
end

return t