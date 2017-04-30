local t = class("gameMain", cc.Node)

local tankClass = require("src/app/tank")
local mineClass = require("src/app/mine")

function t:ctor(t)
	local countTank = t.countTank
	local countMine = countTank
	self.size = t.size
	self.tankSize = t.tankSize
	self.mineSize = t.mineSize

	----
	local tankList = {}; self.tankList = tankList
	local v
	for i=1,countTank do
		v = tankClass:create(self)
		tankList[i] = v
	end

	----
	local mineList = {}; self.mineList = mineList
	for i=1,countMine do
		v = mineClass:create(self)
		mineList[i] = v
	end
end

-- 固定10ms
function t:update(dt)
	--print("---tick")
	local tankList = self.tankList
	local mineList = self.mineList
	for i,v in ipairs(tankList) do
		v:update(dt, mineList)
	end
end

return t
