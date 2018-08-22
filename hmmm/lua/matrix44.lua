local result = Matrix44()
result:Rotate(math.pi / 4, 0.0, 1.0, 0.0)

P""
for i = 1, 1000000 do
	result.GetInverse(result, result)
end
P""