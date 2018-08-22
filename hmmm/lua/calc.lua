function characterPresent(stringParam, character)
    for i=1, #stringParam do
        if stringParam:sub(i, i) == character then return true end
    end
    return false
end

local validCharacters = "0123456789.-"

function getNumber(stringParam)
    local foundDigit = false
    local i = 1
    local currentCharacter = stringParam:sub(i, i)
    while characterPresent(validCharacters, currentCharacter) do
        if i == 1 then
			validCharacters = "0123456789."
		end
        if currentCharacter == "." then validCharacters = "0123456789" end
        if characterPresent("0123456789", currentCharacter) then foundDigit = true end
        i = i+1
        if i > #stringParam then break end
        currentCharacter = stringParam:sub(i, i)
    end
    if not foundDigit then i = 1 end
    local number = tonumber(stringParam:sub(1, i-1))
    return number, stringParam:sub(i, #stringParam)
end

function parseExpression(expression, expectEndParentheses)
	local expectingExpression = true
	local lastExpressionWasParenthetical = false

	local operators = "+-/*^"
	local parts = {}
	local foundEndParentheses = false
	expectEndParentheses = expectEndParentheses or false
	while expression ~= "" do
        local nextNumber, expressionAfterNumber = getNumber(expression)
		print(nextNumber, expressionAfterNumber)
        local nextCharacter = expression:sub(1, 1)
        local nextPiece = expression:sub(1, 5)
        if #expression <= 5 then nextPiece = nextPiece.." [end]" end
        if expectingExpression then
            if nextCharacter == "(" then
                local nestedExpressionValue, expressionAfterParentheses = parseExpression(expression:sub(2, #expression), true)
                if nestedExpressionValue == nil then return nestedExpressionValue, expressionAfterParentheses end
                table.insert(parts, nestedExpressionValue)
                expression = expressionAfterParentheses
                lastExpressionWasParenthetical = true
            else
                if nextNumber == nil then return nil, "Expected number or '(', but found '"..nextPiece.."'" end
                table.insert(parts, nextNumber)
                expression = expressionAfterNumber
                lastExpressionWasParenthetical = false
            end
        elseif characterPresent(operators, nextCharacter) then
            table.insert(parts, nextCharacter)
            expression = expression:sub(2, #expression)
        elseif nextCharacter == "(" or (lastExpressionWasParenthetical and nextNumber ~= nil) then
			table.insert(parts, "*")
        elseif nextCharacter == ")" then
            if expectEndParentheses then
                expression = expression:sub(2, #expression)
                foundEndParentheses = true
                break
            else return nil, "')' present without matching '(' at '"..nextPiece.."'" end
        else return nil, "Expected expression, but found '"..nextPiece.."'" end
        expectingExpression = not expectingExpression
    end
    if expectEndParentheses and not foundEndParentheses then return nil, "Expression unexpectedly ended ('(' present without matching ')')" end
    if expectingExpression then return nil, "Expression unexpectedly ended" end
    local i = #parts
    while i >= 1 do
        if parts[i] == "^" then
            parts[i-1] = parts[i-1]^parts[i+1]
            table.remove(parts, i+1)
            table.remove(parts, i)
        end
		i = i-1
    end
    i = 1
    while i <= #parts do
        if parts[i] == "*" then
            parts[i-1] = parts[i-1]*parts[i+1]
            table.remove(parts, i+1)
            table.remove(parts, i)
        elseif parts[i] == "/" then
            parts[i-1] = parts[i-1]/parts[i+1]
            table.remove(parts, i+1)
            table.remove(parts, i)
        else
			i = i+1
		end
    end
    i = 1
    while i <= #parts do
        if parts[i] == "+" then
            parts[i-1] = parts[i-1]+parts[i+1]
            table.remove(parts, i+1)
            table.remove(parts, i)
        elseif parts[i] == "-" then
            parts[i-1] = parts[i-1]-parts[i+1]
            table.remove(parts, i+1)
            table.remove(parts, i)
        else i = i+1 end
    end
    return parts[1], expression
end

local result, errorMessage = parseExpression("1+2+3")
if result == nil then
	print(errorMessage)
else
	print(result)
end
