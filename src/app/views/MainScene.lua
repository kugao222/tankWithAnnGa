local MainScene = class("MainScene", cc.load("mvc").ViewBase)

local cc = _G.cc
local director = cc.Director:getInstance()
local s = director:getWinSize() -- 960*640


function MainScene:onCreate()
	local function update(dt)
		
	end
	self:scheduleUpdateWithPriorityLua(update, -1)
end
--
function MainScene:onEnter()
	
end

return MainScene
