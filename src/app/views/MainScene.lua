local MainScene = class("MainScene", cc.load("mvc").ViewBase)
--

local gameMainClass = require("src/app/gameMain")
local tools = require("src/app/tools")

--
local cc = _G.cc
local director = cc.Director:getInstance()
local scheduler = director:getScheduler()
local s = director:getWinSize() -- 960*640
gb.winSize = s

---- 
local gb = _G.gb
local populationClass = gb.populationClass
local util = gb.util


--
function MainScene:onCreate()
	--scheduler:setTimeScale(5)
	self:start()
end

--
function MainScene:start()
	---- 
	local countTank = 60 -- 人口数
	local timeLoop = 50 -- 时间

	---- 主逻辑
	local t = {
		countTank = countTank,
		size = {width=s.width, height=s.height},
		tankSize = {width=30,height=30},
		mineSize = {width=10,height=10},
	}
	local gameMain = gameMainClass:create(t)
	self:addChild(gameMain)
	self.gameMain = gameMain

	---- 基因
	local ann = gameMain.tankList[1].ann
	self:setupPopulation(countTank, ann:getNumOfWeights())

	---- 带入基因
	self:setupGeneIntoTank()

	---- 一代的时间
	local population = self.population
	local tankList = gameMain.tankList
	local function cb()
		--print("==============================================")
		local geneList = population.list
		for i,v in ipairs(geneList) do
			v.fitness = tankList[i].fitness
			--print("----- i == "..v.fitness)
		end

		population:epoch()

		--
		self:setupGeneIntoTank()

		--
		self.tick = timeLoop
		self:updateUi()
		--print("--cb")
	end
	tools.loopExcute(self, timeLoop, cb)

	----
	self:setupUpdate()

	--
	local lb = cc.Label:create()
	self:addChild(lb)
	lb:setPosition(s.width*0.1, s.height*0.05)
    local ttfConfig  = {}
    ttfConfig.fontFilePath="arial.ttf"
    ttfConfig.fontSize = 30		
    lb:setTTFConfig(ttfConfig)
	self.tick = timeLoop
	local function cb1()
		local tick = self.tick - 1; self.tick = tick
		lb:setString("time : "..tick)
	end
	tools.loopExcute(self, 1, cb1)

	--
	local _cc_KeyCode = cc.KeyCode
    local function onKeyEventP(keyCode, event)
        if keyCode == _cc_KeyCode.KEY_F then
        	scheduler:setTimeScale(20)
        elseif keyCode == _cc_KeyCode.KEY_B then
        --elseif keyCode == _cc_KeyCode.KEY_RIGHT_ARROW then
        	scheduler:setTimeScale(1)
        end
    end
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyEventP, cc.Handler.EVENT_KEYBOARD_PRESSED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	-- 
	self:updateUi()
end

function MainScene:updateUi()
	local lb = self.lb
	if not lb then
		lb = cc.Label:create()
		self:addChild(lb)
		lb:setPosition(s.width*0.5, s.height*0.95)
		self.lb = lb

	    local ttfConfig  = {}
	    ttfConfig.fontFilePath="arial.ttf"
	    ttfConfig.fontSize = 50		
	    lb:setTTFConfig(ttfConfig)
	end
	local population = self.population
	lb:setString("generation : "..(population.generation+1))
end

-- 带入基因
function MainScene:setupGeneIntoTank()
	local population = self.population
	local geneList = population.list
	local tankList = self.gameMain.tankList
	local function getGeneEx(geneBitList)
		local geneDecode = {}
		for i,v in ipairs(geneBitList) do
			geneDecode[i] = v[1]
		end
		return geneDecode
	end
	for i,v in ipairs(tankList) do
		v:resetFitness()
		v.ann:setWeights(getGeneEx(geneList[i].geneBitList))
	end
end

-- 创建population
function MainScene:setupPopulation(size,geneBitCount)
	local population = self.population
	if population then -- 已经有了

		return
	end
	local _randWeight = util.randWeight
	-- 1. 基因结构(数值范围)
	local function generateGeneBitFunc() -- 基因bit内部是数组
		local t = {_randWeight()}
		return t
	end
	-- 2. 基因变异
	local function mutateGeneBitFunc(t)
		t[1] = _randWeight()
	end
	-- 3. 适应性度量
	local function fitnessMeasurementFunc(geneBitList) -- 
		return nil -- 外部度量
	end

	local t = {
		-- 人口
		population = size,
		-- 基因
		geneBitCount = geneBitCount,-- 长度
		generateGeneBitFunc = generateGeneBitFunc,
		mutateGeneBitFunc = mutateGeneBitFunc,
		fitnessMeasurementFunc = fitnessMeasurementFunc,
	}
	local population = populationClass:create(t)
	self.population = population
end

---- 更新
local _frameTime = 10 -- ms 定义一帧的时间
function MainScene:setupUpdate()
	local timeAccum  = 0
	local countFrame = 0
	local gameMain = self.gameMain
	local math = _G.math
	local function update(dt)
		timeAccum = timeAccum + dt*1000 -- 累计时间

		-- 
		if timeAccum < _frameTime then return end

		countFrame = math.floor(timeAccum/_frameTime) -- 计算几个帧
		timeAccum = timeAccum - countFrame*_frameTime -- 消耗

		-- 更新
		for i=1,countFrame do
			gameMain:update(_frameTime)
		end
	end
	self:scheduleUpdateWithPriorityLua(update, -1)
end

-- function MainScene:setupUpdate()
-- end

return MainScene
