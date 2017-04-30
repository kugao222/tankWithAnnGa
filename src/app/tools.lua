local t = class("tools")

-- 
local math = _G.math
local cc = _G.cc

function t.delayExcute(node, time, func)
    
end

function t.loopExcute(node, time, callback)
    local delay = cc.DelayTime:create(time)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    local action = cc.RepeatForever:create(sequence)
    node:runAction(action)
    return action
end

return t