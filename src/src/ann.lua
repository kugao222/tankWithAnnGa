local t = class("ann")
-- ff ann

local gb = _G.gb
local util = gb.util
local _randWeight = util.randWeight
local _exp = util.exp
local define = gb.define

-- neuron
local function _neuronCreateHelper(numOfInputs)
	local num = numOfInputs+1 -- shift output
	local neuronT = {num=numOfInputs}
	for i=1,num do
		neuronT[i] = _randWeight()
	end
	neuronT.activation = 0 -- 激励值
	neuronT.error = 0 -- 误差
	--neuronT[num] = -1 -- shift
	return neuronT
end

-- layer
local function _layerCreateHelper(numOfNeuron, numOfNeuronInputs)
	local layerT = {}
	for i=1,numOfNeuron do
		layerT[i] = _neuronCreateHelper(numOfNeuronInputs)
	end
	return layerT
end

--
function t:ctor(hln,hlnn, inputNum,outputNum)
	-- layers
	self.layers = {}
	-- hidden layer number
	self.hiddenLayerNum = hln
	-- hidden layer neuron number
	self.hiddenLayerNeuronNum = hlnn

	-- input&ouput
	self.inputNum = inputNum
	self.outputNum = outputNum

	-- 
	self.learningRate = 0.5

	--
	self.errorSum = 9999999

	--
	self.isTrained = false

	--
	self.numEpochs = 0

	-- create
	self:constructLayers()
end

-- 构造层
function t:constructLayers()
	local layers = self.layers
	local inputNum = self.inputNum
	local outputNum = self.outputNum

	-- 
	local hiddenLayerNum = self.hiddenLayerNum
	if hiddenLayerNum > 0 then
		local hiddenLayerNeuronNum = self.hiddenLayerNeuronNum
		layers[1] = _layerCreateHelper(hiddenLayerNeuronNum, inputNum)
		for i=2,hiddenLayerNum do
			layers[i] = _layerCreateHelper(hiddenLayerNeuronNum, hiddenLayerNeuronNum)
		end
		layers[hiddenLayerNum+1] = _layerCreateHelper(outputNum, hiddenLayerNeuronNum)
	else
		layers[1] = _layerCreateHelper(outputNum, inputNum)
	end
end

-- 一次刺激
local outputsReusedEmpty = {}
function t:stimulate(inputs)
	--
	local inputsNumber = #inputs
	local inputNum = self.inputNum
	if inputNum ~= inputsNumber then return outputsReusedEmpty end

	-- loop layer
	local layers = self.layers
	local count = #layers
	local curOutputs = nil
	local curInputs = inputs
	for i=1,count do
		curOutputs = self:stimulateLayer(layers[i], curInputs) -- curInputs重用
		curInputs = curOutputs
		--dump(curOutputs, "----------Outputs")
	end

	--dump(curOutputs, "----------Outputs")
	return curOutputs
end

---- 训练 ------------------------------------------
function t:training(inputsList,outputsList)
	local errorSum
	while 1 do
		self:trainingEpoch(inputsList,outputsList)
		self.numEpochs = self.numEpochs + 1
		if self.errorSum <= 0.003 then
			break
		end
	end
	--self:trainingEpoch(inputsList,outputsList)
end

function t:trainingEpoch(inputsList,outputsList) -- 这里只放入一个
	local errorSum = 0
	local learningRate = self.learningRate

	--
	local layers = self.layers
	local hiddenLayerNum = self.hiddenLayerNum
	local hiddenLayerNeuronNum = self.hiddenLayerNeuronNum
	local outputLayer = layers[hiddenLayerNum+1]
	local fisrtNeuron = outputLayer[1]
	local weightNum = fisrtNeuron.num -- 输出层neuron 的weight数

	local hiddenLayer = layers[hiddenLayerNum]

	-- 输出层
	local outputNum = self.outputNum
	local inputNum = self.inputNum
	local err, outputs, outputsT
	local opsV,opsVT,posVD, curNeuron, curWeight, curHiddenNeuron
	for i,v in ipairs(inputsList) do -- 每一个训练集
		outputs = self:stimulate(v)
		outputsT = outputsList[i]

		--
		for op=1,outputNum do -- 每一个输出单位
			opsV = outputs[op]
			opsVT = outputsT[op]
			posVD = opsVT-opsV
			curNeuron = outputLayer[op]
			--
			err = posVD*opsV*(1-opsV)
			curNeuron.error = err
			errorSum = errorSum + posVD*posVD
			--
			for j=1,weightNum do
				curHiddenNeuron = hiddenLayer[j]
				curNeuron[j] = curNeuron[j]+err*learningRate*curHiddenNeuron.activation
				--print("--curNeuron[j] == "..curNeuron[j])
			end
			curNeuron[weightNum+1] = curNeuron[weightNum+1]+err*learningRate*-1;
		end

		-- 针对每一个hidden layer的单元
		local curNrnHid
		for op=1,hiddenLayerNeuronNum do -- 每一个hidden单位
			err = 0
			for j=1,outputNum do
				curNeuron = outputLayer[j]
				err=err+curNeuron.error*curNeuron[op]
			end
			curNrnHid = hiddenLayer[op]
			err = err*curNrnHid.activation*(1-curNrnHid.activation)

			for w=1,inputNum do
				curNrnHid[w] = curNrnHid[w] + err*learningRate*v[w]
			end

			curNrnHid[inputNum+1] = curNrnHid[inputNum+1]+err*learningRate*-1;
		end

		outputs = nil
	end

	self.errorSum = errorSum

	return true
end

---- 辅助 ------------------------------------------
local curOutputsReuse = {}
function t:stimulateLayer(layer, inputs)
	local curOutputs = {}
	local num = #layer
	for i=1,num do
		curOutputs[i] = self:stimulateNeuron(layer[i], inputs)
	end

	-- 重用
	-- for i=1,num do
	-- 	inputs[i] = curOutputs[i]
	-- end
	return curOutputs
end
function t:stimulateNeuron(neuron, inputs)
	local num = neuron.num
	local accum = 0
	--
	for i=1,num do
		accum = accum + neuron[i]*inputs[i]
	end

	-- 偏移
	accum = self:impel(accum + neuron[num+1]*(-1))
	neuron.activation = accum

	return accum
end
-- 激励函数
local _dActivationResponse = define.dActivationResponse
function t:impel(netinput)
	return  1 / ( 1 + _exp(-netinput / _dActivationResponse))
end

-- 
function t:setWeights(ws)
	local count = 1

	local t = {}
	local num
	local function handleNeuron(neuron)
		num = neuron.num+1
		for i=1,num do
			neuron[i] = ws[count]
			count = count + 1
		end
	end
	self:loopEverNeuron(handleNeuron)
end
function t:getWeights()
	local t = {}
	local num
	local function handleNeuron(neuron)
		num = neuron.num+1
		for i=1,num do
			t[#t+1] = neuron[i]
		end
	end
	self:loopEverNeuron(handleNeuron)
	return t
end
function t:loopEverNeuron(handle)
	local layers = self.layers
	local count = #layers
	local curLayer
	for i=1,count do
		curLayer = layers[i]
		for j=1,#curLayer do
			handle(curLayer[j])
		end
	end
end
function t:getNumOfWeights()
	local list = self:getWeights()
	return #list, list
end

return t