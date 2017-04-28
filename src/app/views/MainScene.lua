local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local lunarClass = require("src/app/views/lunar")
local landerClass = require("src/app/views/lander")

local cc = _G.cc
local director = cc.Director:getInstance()
local s = director:getWinSize() -- 960*640
--
function MainScene:onEnter()
	-- 重力
	local g = 98
	-- 世界边界
	local size = {width=860, height=640}

	--
	local curScene = director:getRunningScene()
	local pw = curScene:getPhysicsWorld()
	pw:setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
	local tt = pw:getGravity()
	dump(tt, "")
	pw:setGravity({x=0,y=-g})

	--
	local mass = 100
	local width = 10
	local pos = {x=s.width*0.5,y=size.height*0.8}
	local angel = 0
	local v = {x=0, y=0}
	local lander = landerClass:create(mass,width, pos, angel, v)
	--
	local padPos = {x=0,y=0}
	local padWidth = 20 -- 0====
	local lunar = lunarClass:create(size, g, padPos,padWidth)
	lunar:setObject(lander)
	self:addChild(lunar)

	-- 
	local function update(dt)
		lunar:update(dt)
	end
	self:scheduleUpdateWithPriorityLua(update, -1)

	--
	local _cc_KeyCode = cc.KeyCode
    local function onKeyEventP(keyCode, event)
        if keyCode == _cc_KeyCode.KEY_SPACE then
        	--print("space+")
        	lander:thrust(true)
        elseif keyCode == _cc_KeyCode.KEY_LEFT_ARROW then
        	lander:spin(true, -1)
        elseif keyCode == _cc_KeyCode.KEY_RIGHT_ARROW then
        	lander:spin(true, 1)        	
        end
    end
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyEventP, cc.Handler.EVENT_KEYBOARD_PRESSED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    local function onKeyEventR(keyCode, event)
        if keyCode == _cc_KeyCode.KEY_SPACE then
        	lander:thrust(false)
        elseif keyCode == _cc_KeyCode.KEY_LEFT_ARROW then
        	lander:spin(false, -1)
        elseif keyCode == _cc_KeyCode.KEY_RIGHT_ARROW then
        	lander:spin(false, 1)  
        end
    end
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyEventR, cc.Handler.EVENT_KEYBOARD_RELEASED)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

return MainScene
