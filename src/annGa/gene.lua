local t = class("gene")
-- 基因的定义(基因链中存有问题的解，
-- 这个解得好坏用updateFitness()和fitness来衡量和存储)

local gb = _G.gb
local util = gb.util

--
function t:ctor(population) -- length:geneBitCount
	-- 群组
	self.population = population
	local geneBitCount = population.geneBitCount
	local generateGeneBitFunc = population.generateGeneBitFunc

	-- 适应性值
	self.fitness = 0

	-- 基因bit链
	local geneBitList = {}; self.geneBitList = geneBitList
	for i=1,geneBitCount do
		geneBitList[i] = generateGeneBitFunc() -- 初始化都是随机的.
	end
end

-- 更新适应性值
function t:updateFitness() -- func:打分函数
	local func = self.population.fitnessMeasurementFunc
	self.fitness = func(self.geneBitList)
end

-- 变异
function t:mutate() -- func:打分函数
	local population = self.population
	local mutateGeneBitFunc = population.mutateGeneBitFunc
	local fold = 1000
	local mutationRate = math.floor(population.mutationRate*fold+0.00001) 

	local rn
	local geneBitList = self.geneBitList
	local count = #geneBitList
	local v
	for i=1,count do
		v = geneBitList[i]
		rn = util.rand(1,fold)
		if rn <= mutationRate then
			-- print("----------------- rn == "..rn)
			-- print("----------------- mutationRate == "..mutationRate)
			mutateGeneBitFunc(geneBitList[i])
		end
	end
end

return t