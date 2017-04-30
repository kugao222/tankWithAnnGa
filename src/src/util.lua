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

-- 截断
function t.clampf(value, min_inclusive, max_inclusive)
    -- body
    local temp = 0
    if min_inclusive > max_inclusive then
        temp = min_inclusive
        min_inclusive =  max_inclusive
        max_inclusive = temp
    end

    if value < min_inclusive then
        return min_inclusive
    elseif value < max_inclusive then
        return value
    else
        return max_inclusive
    end
end

-- 弧度到向量
function t.angleR2V(aR, v)
	v.x = math.cos(aR)
	v.y = math.sin(aR)
end

-- 角度到向量
local _pi = math.pi
local _a2rFactor = _pi/180
local _r2aFactor = 180/_pi
function t.angleA2V(a, v)
	a = _a2rFactor*a
	v.x = math.cos(a)
	v.x = math.sin(a)
end

t._r2aFactor = _r2aFactor
t._a2rFactor = _a2rFactor
t._pi = _pi
return t