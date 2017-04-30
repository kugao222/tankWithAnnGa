local t = class("mine", cc.Node)
local cc = _G.cc

local util = gb.util

--
function t:ctor(gameMain)
	----
	local size = gameMain.size; self.size = size
	local mineSize = gameMain.mineSize; self.mineSize = mineSize

	----
	local pos = {x=util.rand(0,size.width), y=util.rand(0,size.height)}
	self.pos = pos--

	---- 
	local spr = cc.Sprite:create("mine.png")
	self:addChild(spr)
	gameMain:addChild(self)
	self:setPosition(pos)

	local cs = spr:getContentSize()
	local scaleSpr = mineSize.width / cs.width
	spr:setScale(scaleSpr)
end

--
function t:resetPos()
	local pos = self.pos
	local size = self.size
	pos.x=util.rand(0,size.width)
	pos.y=util.rand(0,size.height)
	self:setPosition(pos)
end
return t
