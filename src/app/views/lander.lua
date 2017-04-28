local t = class("lander")
-- lander:描述结构，重量等

local math = _G.math
local dump = _G.dump
local cc = _G.cc

--
local THRUST_PER_SECOND = 350
local ROTATION_PER_SECOND = 3

--
function t:ctor(mass,width, pos,angel,v)
	--
	self.mass = mass
	self.width = width --  ====0====

	--
	self.pos = pos
	self.angel = angel -- 弧
	self.v = v

	-- 
	self.g = 0

	--
	self.isThrusting = false
	self.isSpinning = false
	self.spinNP = 1

	-- 
	self.isEnd = false

	-- 
	self.timeAccum = 0
end

function t:setLunar(lunar)
	self.lunar = lunar
	self.g = lunar.g

	-------------
   local sp = cc.Sprite:create("spaceship.png")--, cc.rect(posx, posy, 85, 121)
   sp:setPhysicsBody(cc.PhysicsBody:createBox(cc.size(90.0, 62.0)))
   lunar:addChild(sp)
   sp:setPosition(self.pos)
   self.box = sp:getPhysicsBody()
   self.node = sp
end

function t:update(dt)
	if self.isEnd then return end

	--dump(dt, "------dt")
	self:operationInfluence(dt)
	--self:gravityInfluence(dt)

	--
	--self:movement(dt)

	--
	local timeAccum = self.timeAccum
	timeAccum = timeAccum + dt
	self.timeAccum = timeAccum
end

--
function t:gravityInfluence(dt)
	local a = self.g
	local v = self.v
	v.y = -a*dt + v.y
end

-- 
local _pi = math.pi
local _AtoR = _pi/180
function t:operationInfluence(dt)
	local angelR = self.angel
	--local angelR = _AtoR*angelA
	--
	if self.isThrusting then
		print("isThrusting")
		local a = (THRUST_PER_SECOND * dt) / self.mass;
		local v = self.v
		--print("a == "..a)
	    v.x = v.x + a * math.cos(angelR)
	    v.y = v.y + a * math.sin(angelR)

	    -- self.box
	    self.box:applyImpulse({x=500,y=200}); 
	end

    --
    if self.isSpinning then
    	print("isSpinning")
    	local spinNP = self.spinNP
    	angelR = angelR + ROTATION_PER_SECOND * dt * spinNP;
    	self.angel = angelR
    	--self.box:applyTorque(100)
    	self.node:setRotation(30)
	end
end

--
local vnReuse = {x=0,y=0}
local _scale = 60
function t:movement(dt)
	local v = self.v
	local lenT = v.x*v.x + v.y*v.y
	local len = math.sqrt(lenT)

	-- local vn = vnReuse
	-- vn.x = v.x/len
	-- vn.y = v.x/len

	local dx = v.x*dt*_scale
	local dy = v.y*dt*_scale

	local pos = self.pos
	pos.x = pos.x + dx
	dy = pos.y + dy

	if dy < 0 then
		dy = 0
		pos.y = dy
		--
		self.isEnd = true
		dump(pos, "-- pos")
		print("timeAccum == "..self.timeAccum)
	end
	pos.y = dy
	--print("pos.y == "..pos.y)
	--dump(pos, "----------pos")
end

--
function t:thrust(on)
	self.isThrusting = on
end
function t:spin(on,np)
	self.isSpinning = on
	self.spinNP = np
end

return t
