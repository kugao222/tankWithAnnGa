local t = class("tank", cc.Node)
local cc = _G.cc
local util = gb.util
local _r2aFactor = util._r2aFactor
local _a2rFactor = util._a2rFactor
local _pi = util._pi

--
local gb = _G.gb
local annClass = gb.annClass

function t:ctor(gameMain)
	----
	local ann = annClass:create(1,10, 4,2) -- 输入:4 输出:2
	self.ann = ann

	----
	local size = gameMain.size; self.size = size
	local tankSize = gameMain.tankSize; self.tankSize = tankSize
	local r = tankSize.width
	self.rT = r*r

	----
	local pos = {x=util.rand(0,size.width), y=util.rand(0,size.height)}
	self.pos = pos--

	local angelR = 0*_a2rFactor; self.angelR = angelR
	local lookAt = {x=0,y=0}; self.lookAt = lookAt
	util.angleR2V(angelR, lookAt)

	self.speed = 0
	self.lTrack = 0.16
	self.rTrack = 0.16

	---- 
	self.fitness = 0

	----
	self.closetMineIdx = 0

	---- 
	local spr = cc.Sprite:create("tank.png")
	self:addChild(spr)
	gameMain:addChild(self)
	self:setPosition(pos)

	local cs = spr:getContentSize()
	local scaleSpr = tankSize.width / cs.width
	spr:setScaleX(-scaleSpr)
	spr:setScaleY(scaleSpr)
	self.spr = spr

	self:setRotation(angelR*_r2aFactor)
end

-- 
function t:update(dt, mineList)
	---- closetMineIdx
	local closet_so_farT = 10000000
	local posSelf = self.pos
	local posMine,lengthT
	local nearestIdx = -1
	local dx,dy
	for i,v in ipairs(mineList) do
		posMine = v.pos
		dx = posMine.x-posSelf.x
		dy = posMine.y-posSelf.y
		lengthT = dx*dx+dy*dy
		if lengthT < closet_so_farT then
			closet_so_farT = lengthT
			nearestIdx = i
		end
	end

	self.closetMineIdx = nearestIdx
	--
	if nearestIdx == -1 then return end

	local closestMine = mineList[nearestIdx]
	local posMine = closestMine.pos

	local vMineToClosedObject = {x=posSelf.x-posMine.x,y=posSelf.y-posMine.y}
	local t = vMineToClosedObject
	local len = math.sqrt(t.x*t.x+t.y*t.y)
	local vMineToClosedObjectNormed = {x=t.x/len,y=t.y/len}
	local lookAt = self.lookAt
	---- ann
	local tAnn = {
		vMineToClosedObjectNormed.x,
		vMineToClosedObjectNormed.y,
		lookAt.x,
		lookAt.y,
	}
	local output = self.ann:stimulate(tAnn)

	----
	local lTrack = output[1]
	local rTrack = output[2]

	local rotForce = lTrack - rTrack
	local range = 0.01
	rotForce = util.clampf(rotForce, -_pi*range, _pi*range)

	local angelR = self.angelR + rotForce
	self.angelR = angelR
	
	util.angleR2V(angelR, lookAt)
--dump(angelR, "--angelR")
--dump(lookAt, "--lookAt")
	--
	local speed = lTrack+rTrack
	self.speed = speed

	-- 移动
	local pos = self.pos
	local x = pos.x + lookAt.x*speed--*dt
	local y = pos.y + lookAt.y*speed--*dt

	local size = self.size
	local width = size.width
	local height = size.height
	if x < 0 then x = width end
	if y < 0 then y = height end
	if x > width then x = 0 end
	if y > height then y = 0 end

	pos.x = x
	pos.y = y
	--dump(pos, "---pos")
	self:setPosition(x,y)

	self:setRotation(-angelR*_r2aFactor)

	---- 吃掉mine -- posMine
	x = x - posMine.x
	y = y - posMine.y

	local lenT = x*x+y*y
	if lenT > self.rT then
		return false
	end

	--print("---eat")
	--closestMine:setVisible(false)

	----
	self.fitness = self.fitness + 1
	self:updateColor()

	--
	closestMine:resetPos()

	return true
end

--
function t:updateColor()
	local fit = self.fitness / 30 * 255
	if fit > 255 then fit = 255 end
	self.spr:setColor(cc.c3b(fit,0,0))
end

function t:resetFitness()
	self.fitness = 0
	self:updateColor()
end

return t
