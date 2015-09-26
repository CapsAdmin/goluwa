local META = prototype.CreateTemplate("neural_network")

prototype.GetSet(META, "Neurons", {})
prototype.GetSet(META, "LearningRate", 0.5)

local ACTIVATION_RESPONSE = 1

local function sigmoid_transfer(x)
	return 1 / (1 + exp(-x / ACTIVATION_RESPONSE))
end

function NeuralNetwork(inputs, outputs, hidden_layers, neurons_per_layer)
	local self = prototype.CreateObject(META)

	self.inputs = inputs or 1
	self.outputs = outputs or 1
	self.hidden_layers = hidden_layers or math.ceil(self.inputs / 2)
	self.neurons_per_layer = neurons_per_layer or math.ceil(self.outputs * 0.66666 + self.outputs)

	self.Neurons[1] = {}   --Input Layer

	for i = 1, self.inputs do
		self.Neurons[1][i] = {}
	end

	for i = 2, self.hidden_layers + 2 do --plus 2 represents the output layer (also need to skip input layer)
		self.Neurons[i] = {}

		local in_layer = self.neurons_per_layer

		if i == self.hidden_layers + 2 then
			in_layer = self.outputs
		end

		for j = 1, in_layer do
			self.Neurons[i][j] = {bias = math.randomf(-1, 1)}
			for k = 1, #self.Neurons[i-1] do
				self.Neurons[i][j][k] = math.randomf(-1, 1)
			end
		end
	end

	return self
end

function META:Ask(input)
	check(input, "table")

	local neurons = self.Neurons

	local output = {}

	for i = 1,#neurons do
		for j = 1,#neurons[i] do
			if i == 1 then
				neurons[i][j].result = input[j]
			else
				neurons[i][j].result = neurons[i][j].bias

				for k = 1, #neurons[i][j] do
					neurons[i][j].result = neurons[i][j].result + (neurons[i][j][k] * neurons[i-1][k].result)
				end

				neurons[i][j].result = sigmoid_transfer(neurons[i][j].result)

				if i == #neurons then
					table.insert(output, neurons[i][j].result)
				end
			end
		end
	end

	return output
end

function META:Learn(desired_outputs)
	check(desired_outputs, "table")

	local neurons = self.Neurons

	for i = #neurons, 2, -1 do
		for j = 1,#neurons[i] do
			if i == #neurons then
				neurons[i][j].delta = (desired_outputs[j] - neurons[i][j].result) * neurons[i][j].result * (1 - neurons[i][j].result)
			else
				local weight = 0

				for k = 1,#neurons[i+1] do
					weight = weight + neurons[i+1][k][j]*neurons[i+1][k].delta
				end

				neurons[i][j].delta = neurons[i][j].result * (1 - neurons[i][j].result) * weight
			end
		end
	end

	for i = 2,#neurons do
		for j = 1,#neurons[i] do
			neurons[i][j].bias = neurons[i][j].delta * self.learning_rate

			for k = 1,#neurons[i][j] do
				neurons[i][j][k] = neurons[i][j][k] + neurons[i][j].delta * self.learning_rate * neurons[i-1][k].result
			end
		end
	end
end

prototype.Register(META)