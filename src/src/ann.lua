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