local t = class("population")
-- 基因的集群(管理基因群)

-- 
local geneClass = require("src/gene")
local gb = _G.gb
local define = gb.define
local util = gb.util
local math = _G.math
local table = _G.table

---------------
function t:ctor(t)
	--
	--dump(os.time(), "------os.time()")
	math.randomseed(os.time())
	--math.randomseed(2)

	-- 基因定义
	self.geneBitCount = t.geneBitCount
	self.generateGeneBitFunc = t.generateGeneBitFunc
	self.mutateGeneBitFunc = t.mutateGeneBitFunc
	self.fitnessMeasurementFunc = t.fitnessMeasurementFunc
	self.mutationRate = define.mutationRate; -- 变异率

	-- 群体管理
	self.list = {}
	-- 每一代
	self.generation = 0; -- 从1开始.
	-- 交配率
	self.crossoverRate = define.crossoverRate; -- 70%
	-- 适应性值总和
	self.fittnessTotal = 0; -- 最高适应性
	self.fittnessEver = 0; -- 表示群组的总和适应性
	-- 每一代最优
	self.maxFitnessIdx = 0 -- 最优单位
	self.maxFitness = 0 -- 最优适应性

	--
	local count = t.population
	self.count = count
	print(" ==>> set population count : "..count)

	-- 创建基因群
	local list = self.list
	for i=1,count do
		list[i] = geneClass:create(self)
	end

	-- 负值适配
	self.fitnessNagtiveAdjust = {on=false}

	-- 
	self:updateAllFitness()
	print(" ==>> all genes inited !")
end

-- 生产下一代
function t:epoch(jumpOutFitnessLevel) -- func:打分函数
	-- 1. crossover & 变异
	local list = self.list
	local count = #list
	count = math.floor(count/2+0.000001)
	local listNewGeneration = {}
	local c1, c2, curCount
	for i=1,count do
		c1, c2 = self:crossoverWithMutate()
		curCount = #listNewGeneration
		listNewGeneration[curCount+1] = c1
		listNewGeneration[curCount+2] = c2
	end
	self.list = listNewGeneration
	
	-- 2. 更新每条基因的适应性值
	self:updateAllFitness()

	--
	--print("------------------------------------------------------------")
	local function cut(vv)
		return math.floor(vv*100)*0.01
	end
	print("epoch finished! generation:"..(self.generation-1).." maxFitness:"..cut(self.maxFitness).." fittnessEver:"..cut(self.fittnessEver))

	if jumpOutFitnessLevel == nil then return false end

	local maxFitness = self.maxFitness
	--print("maxFitness == "..maxFitness)
	if maxFitness >= jumpOutFitnessLevel then
		--print("jumpOutFitnessLevel == "..jumpOutFitnessLevel)
		return true
	end
	
	return false
	-- local curOne = listNewGeneration[self.maxFitnessIdx]
	-- local geneBitList = curOne.geneBitList
	-- dump(curOne.geneBitList, "-----geneBitList")
end

-- 更新每条基因的适应性值
function t:updateAllFitness()
	local list = self.list
	local count = #list -- 总数
	local accum = 0 -- 累计
	local curFitness = 0 -- 当前适应值
	--local func = self.fitnessMeasurementFunc

	-------------------------
	local isHasN = false
	local maxAbs = 0 -- 最大的值(绝对的)
	local max = nil -- 最大的值
	local maxIdx = nil -- 最大值对应的idx
	local min = 1 -- 主要是为了获得最小负值
	local v
	for i=1,count do
		v = list[i]
		v:updateFitness()
		curFitness = v.fitness
		accum = accum + curFitness

		-- 记录最小值
		if curFitness < min then
			min = curFitness
		end

		--print("curFitness == "..curFitness)
		if max == nil or curFitness > max then
			max = curFitness
			--print("max == "..max)
			maxIdx = i
		end

		-- 负值判断
		if not isHasN and curFitness < 0 then
			isHasN = true
		end

		-- 最大范围
		curFitness = math.abs(curFitness)
		if curFitness > maxAbs then
			maxAbs = curFitness
		end
	end

	-- 适配(因为有负值)
	local fitnessNagtiveAdjust = self.fitnessNagtiveAdjust
	fitnessNagtiveAdjust.on = isHasN
	fitnessNagtiveAdjust.maxAbs = maxAbs -- 最大的范围
	fitnessNagtiveAdjust.min = min

	self.fittnessTotal = accum
	self.fittnessEver = accum/count
	--print("-------accum == "..accum)
	self.maxFitnessIdx = maxIdx
	self.maxFitness = max
	--print("max == "..max)
	----------------------------

	self.generation = self.generation + 1
end

-- 交叉和变异
function t:crossoverWithMutate()
	-- 获取 mam adn dad
	local mam = self:selectOne()
	local dad = self:selectOne()

	-- crossover
	local c1,c2 = self:crossover(mam,dad)
	c1:mutate()
	c2:mutate()
	return c1,c2
end

-- 自然选择(按适应性值排列，就是轮盘赌)
function t:selectOne()
	local fittnessTotal = self.fittnessTotal
		
	-- 尺度适配, 扩大最大值的效益, 大的值比例会变大
	local scale = 1

	-- 负值适配
	local adjustN = function (v)
		return v*scale
	end
	local fitnessNagtiveAdjust = self.fitnessNagtiveAdjust
	if fitnessNagtiveAdjust.on then
		local maxAbs = fitnessNagtiveAdjust.maxAbs
		adjustN = function (v)
			return (v+maxAbs)*scale
		end
	end

	-- 尺度适配调整, 使小数也有机会被随到
	local min = adjustN(fitnessNagtiveAdjust.min)
	if min == 0 then
		--scale = scale
	elseif min < 1 then
		local scale1 = math.ceil(1/min)
		if scale1 > scale then
			scale = scale1*scale
		end
	end

	-- 适配总和
	fittnessTotal = adjustN(fittnessTotal)
	local fittnessTotalUint = math.ceil(fittnessTotal*10000)

	-- 随机数
	local rn = util.rand(0,fittnessTotalUint)*0.0001

	-- 轮盘
	local list = self.list
	local count = #list
	local v, fitNessAdjust, theOneIdx
	local maxFitnessIdx = 0
	local maxFitnessValue = -1
	local accum = 0

	-- 打印
	-- for i=1,count do
	-- 	v = list[i]
	-- 	fitNessAdjust = adjustN(v.fitness)
	-- 	--print("fitNessAdjust == "..fitNessAdjust)
	-- end

	for i=1,count do
		v = list[i]
		fitNessAdjust = adjustN(v.fitness)

		-- 取最大值
		if fitNessAdjust > maxFitnessValue then
			maxFitnessValue = fitNessAdjust
			maxFitnessIdx = i
		end

		-- 查找范围
		accum = accum + fitNessAdjust
		if rn < accum then
			theOneIdx = i
			break
		end
	end

	-- 
	if not theOneIdx then
		theOneIdx = maxFitnessIdx -- 保底
	end
	local theSelectOne = list[theOneIdx] or list[1]

	-- 移除?(TODO::效率低)
	--table.remove(list, theOneIdx)

	return theSelectOne
end

-- 交换部分基因链
function t:crossover(a,b)
	local crossoverRate = self.crossoverRate*100
	local rn = util.rand(1,100)
	if rn > crossoverRate then
		return a,b
	end

	-- 
	return self:exchangeGeneBits(a,b)
end

-- 交换实现gene bits
local function cloneGeneBit(a,b) --  a --> b
	for i,v in ipairs(a) do
		b[i] = v
	end
end
--
function t:exchangeGeneBits(a,b)
	local geneBitListA = a.geneBitList
	local geneBitListB = b.geneBitList

	local count = self.geneBitCount
	if count < 2 then return a,b end

	-- 创建后来
	local aa = geneClass:create(self)
	local bb = geneClass:create(self)
	local geneBitListAA = aa.geneBitList
	local geneBitListBB = bb.geneBitList

	local rn = util.rand(2, count) -- 从哪里开始交换

	for i=1,rn-1 do
		cloneGeneBit(geneBitListA[i], geneBitListAA[i])
		cloneGeneBit(geneBitListB[i], geneBitListBB[i])
	end
	for i=rn,count do 
		cloneGeneBit(geneBitListB[i], geneBitListAA[i])
		cloneGeneBit(geneBitListA[i], geneBitListBB[i])
	end

	return aa,bb
end

return t