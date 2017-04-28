local t = class("lunar", cc.Layer)
-- lunar:描述重力空间等参数
local cc = _G.cc

--
function t:ctor(size, g, padPos)
	-- 物体列表
	self.objectList = {}

	-- 
	self.size = size

	--
	self.g = g

	--
	self.padPos = padPos

	-------------------
    local function onNodeEvent(event) if "enter" == event then self:onEnter() end end
    self:registerScriptHandler(onNodeEvent)
end

--
local director = cc.Director:getInstance()
local s = director:getWinSize()
function t:onEnter()
	-- 框
	local size = self.size
	local eb = cc.PhysicsBody:createEdgeBox(size)
	local node = cc.Node:create()
	node:setPhysicsBody(eb)
	node:setPosition(s.width*0.5,s.height*0.5)
	self:addChild(node)

	-- 平台
	node = cc.Node:create()
	local box = cc.PhysicsBody:createBox(cc.size(100, 20))
	box:setDynamic(false)
	node:setPhysicsBody(box)
	node:setPosition(s.width*0.5,0)
	self:addChild(node)
end

--
function t:setObject(obj)
	local objectList = self.objectList
	objectList[#objectList+1] = obj

	--
	obj:setLunar(self)
end

--
function t:update(dt)
	local objectList = self.objectList
	for i,v in ipairs(objectList) do
		v:update(dt)
	end
end

return t
