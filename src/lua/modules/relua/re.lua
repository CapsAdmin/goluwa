data = require("reData")
parser = require("reParse")

local DefaultTable = data.DefaultTable
local ListTable = data.ListTable

-- object Tree A tree! what more description do you want??
-- 	var Tree.val = String
-- 	var Tree.children = {Tree} | {}

local re = {}
local function warn(...) print(...) end

--data NFA
--data NFA.states = [State]
--data NFA.edges = [{Input:[State]}]
--data State = Table Holds some arbitrary state information
--data Input = Char
local stateIdx = 0
local State = {}
State.__index = State
-- function State.new() return State A new state
function State.new()
	stateIdx = stateIdx + 1
	return setmetatable({id=tostring(stateIdx)}, State)
end
function State.__tostring(self)
	return "State: " .. self.id
end




-- actually more like a NFA, but with caching
local NDFA = {}
NDFA.__index = NDFA
-- function NDFA.new() return NDFA A new machine with only a single state and no final states.
function NDFA.new()
	local m = {}
	local initState = State.new()
	m.start = initState

	m.states = {}
	m.states[initState]=true

	m.edges = DefaultTable( function() return ListTable() end )
	m = setmetatable(m, NDFA)
	return m
end

--function NDFA.final(self) return [State] The final states of the machine
function NDFA:final()
	local states = {}
	for s,_ in pairs(self.states) do
		if s.isFinal then
			table.insert(states, s)
		end
	end
	return states
end

--function NDFA:addEdge(State source, Input input, State dest) create an edge leading from source to dest given the input.
function NDFA:addEdge(source, input, dest)
	if type(input) == "table" and input.isCharacterClass then
		self.edges[source]["CLASS"][input] = dest
	else
		table.insert(self.edges[source][input], dest )
	end
end

--function NDFA:insert(NDFA m) return NDFA A machine with the states and edges of m added to self with no link between them.
function NDFA:insert(m)
	-- add all states in m to self and copy edges
	for s,_ in pairs(m.states) do
		self.states[s] = true
		self.edges[s] = m.edges[s]
	end
	return self
end

--function NDFA:concat(NDFA m1, NDFA m2) return NDFA A new NDFA resulting from concatenating m2 to m1
function NDFA.concat(m1, m2)
	-- link all end states of m1 to the start of m2
	local m2Start = m2.start
	for i,s in pairs(m1:final()) do
		s.isFinal = false
		m1:addEdge( s, "EPSILON", m2Start )
	end
	m1:insert(m2)
	return m1
end

-- function NDFA:addState(State source, Input input, Bool final) Add a new State to this machine, adding edges from the given state ID to it.
function NDFA:addState(source, input, final)
	local state = State.new()
	if final then
		state.isFinal = true
	end
	--table.insert(self.states, state)
	self.states[state] = true
	if source and input then
		self:addEdge(source, input, state)
	end
	return state
end

function NDFA:execute(input)
	self:init(input)
	for c in input:gmatch(".") do
		if not self:step(c) then
			break
		end
	end
	local match = false
	for _,s in pairs( self:final() ) do
		if self.curState[s] then
			match=true
			break
		end
	end

	local match = self:match()
	if not match then return match end
	return self:match():extract(input)
end

function NDFA:match()
	local finals = self:final()
	local path
	for _,s in pairs(finals) do
		local path1 = self.curState[s]
		path = compare(path1, path)
	end
	return path
end
function NDFA:printMatches()
	local path = self:match()
	for n = 1,path.nGroups*3,3 do
		if path[n+1] and path[n+2] then
			print("match: ", (n-1)/3+1, "["..path[n+1]..":"..path[n+2].."]", self.input:sub(path[n+1], path[n+2]))
		end
	end
end

local Path = {}
Path.__index = Path

function Path.new(...)
	return setmetatable({nGroups=0}, Path)
end
function Path.__tostring(path)
	local str = {}
	table.insert( str, "Path:")
	for n = 1,path.nGroups*3,3 do
		table.insert(str, "  group:")
		table.insert(str, (n-1)/3+1)
		if path[n+1] then
			table.insert(str, " [")
			table.insert(str, path[n+1])
			table.insert(str, ":")
			if path[n+2] then table.insert(str, path[n+2])
			else table.insert(str, "...") end
			table.insert(str, "]")
		else
			table.insert(str, " None")
		end
	end
	return table.concat(str)
end
function Path:extract(input)
	local matches = {}
	for n = 1,self.nGroups*3,3 do
		local start, stop, match = self[n+1], self[n+2]
		if stop and start and stop >=start then
			 match = string.sub(input, start+1, stop)
		else
			match = ""
		end
		table.insert(matches, match)
	end
	local mt = {}
	function mt.__tostring(match)
		local t = {}
		for k,v in ipairs(match) do table.insert(t,v);table.insert(t,", ") end
		table.remove(t)
		return table.concat(t)
	end
	return setmetatable(matches, mt)
end

function NDFA:init(input)
	self.steps = 0
	self.input = input
	self.curState = {}
	for s,fs in pairs( eClosure(self, self.start) ) do
		local path = Path.new()
		for _,f in ipairs(fs) do
			f(self, s, "", path)
		end
		self.curState[s] = path
	end
	self.subMatches = {} -- completed matches
	self.partialMatches = {} -- partial, incomplete, matches

	for s,path in pairs(self.curState) do
		--if s.hit then s.hit(self,s,"",path) end
	end
end

function compare( path1, path2)
	if not path2 then return path1 end
	-- compare path1 to path2 and return the optimal one.
	local nGroups = math.max( path1.nGroups, path2.nGroups)
	--print("compare:")
	--print(" ", path1)
	--print(" ", path2)

	for n = 1,nGroups*3,3 do
		assert( path1[n] == path2[n], "Mismatched maximality for group" )
		local maxify = path1[n +0]
		--print("group:", n, maxify)

		local len1, len2 = 0,0
		--print(path1[n+2], path1[n+1], path2[n+2], path2[n+1])
		if path1[n+2] then len1 = path1[n+2] - path1[n+1] end
		if path2[n+2] then len2 = path2[n+2] - path2[n+1] end

		if len1>len2 then
			--if maxify then print("","",path1) else print("","",path2) end
			if maxify then return path1 else return path2 end
		elseif len2>len1 then
			--if maxify then print("","",path2) else print("","",path1) end
			if maxify then return path2 else return path1 end
		end

		-- so far they are equivilent if we have not returned by now.
	end
	-- all groupings are equivilent
	return path1
end

function copy(path)
	local newpath = Path.new()
	for k,v in pairs(path) do
		newpath[k] = v
	end
	return newpath
end

function NDFA:step(input)
	local nextState = {}
	local isAlive = false
	self.steps = self.steps + 1
	function addState(s, path)
		isAlive = true
		newstates = eClosure(self, s)
		for state,fs in pairs(newstates) do
			local newpath = copy( path )
			for _,f in ipairs(fs) do
				f(self, state, input, newpath)
			end
			nextState[state] = compare( newpath, nextState[state] )
		end
	end

	for state,path in pairs(self.curState) do
		-- check against character classes
		for table,s in pairs(self.edges[state]["CLASS"])do
			if table[input] then
				addState(s, path)
			end
		end
		-- check against literal edges (i.e. not character classes)
		for _,s in pairs(self.edges[state][input]) do
			addState(s, path)
		end
	end
	self.curState = nextState
	return isAlive
end

function NDFA.__tostring(self)
	return "NDFA: " .. self
end

--function eClosure(NDFA, Int) return {State:[Function]} List of all states accessible via epsilon transitions from the given state, and a list of functions to execute for that state. This function is cached, and the returned table should NOT be modified.
function eClosure(m, start, mutable)
	if not m.cache then m.cache = DefaultTable( function() return ListTable() end ) end
	local cache = m.cache.eClosure[start]
	if cache.clean then
		return cache.val --return the actual cache, assuming caller will not attempt to modify it
	else

		val = eClosure2(m, start, {}, {}, 1)
		-- cache it
		cache.val = val; cache.clean = true
		return val
	end
end
function eClosure2(m, start, prevStates, depthTable, depth)

	local cache = m.cache.eClosure[start]
	-- no more intermediate caching
		local states = {}

		-- add the initial state and compile the function list
		states[start] = {}
		depthTable[start] = depth

		-- find all states with Epsilon transitions from here
		for _,s in pairs( m.edges[start]["EPSILON"]) do
			if not depthTable[s] or depthTable[s] > depth then
				eClosure2(m,s, states, depthTable, depth+1)
			end
		end
		-- copy start.hit function into the cache
		if start.hit then
			for k,v in pairs(states) do
				table.insert( v, 1, start.hit)
			end
		end
		-- copy this value into the prevStates table.
		for k,v in pairs(states) do
			prevStates[k]=v
		end
	return prevStates
end

-- function compile(String) return Regex
-- compiles the regex string into an NFA.
function re.compile(regex)
	local ast = parser.parse(regex)
	local names = {"One", "Two", "Three", "Four?"}
	stateIdx = 0
	local nfa = buildNDFA(ast, {captureNames=names, groupN=0})
	nfa.regex = regex
	return nfa
end

-- helper functions for building NDFA's with submatching enabled.
function startGroup(i, maxify)
	return function(self, state, c, path)
		local ii = (i-1)*3 +1
		-- use as an array to avoid unnessesary table creation when we clone paths.
		path[ii] = maxify
		path[ii +1] = self.steps
		path[ii +2] = nil
		if path.nGroups<i then path.nGroups=i end
	end
end
function stopGroup(i)
	return function (self, state, c, path)
		local ii = (i-1)*3 +1
		if path[ii +1] then
			if path.nGroups<i then path.nGroups=i end
			path[ii +2] = self.steps
		end
	end
end
-- function buildNFA(Tree, NDFA) return NDFA builds an NFA from the given regex AST
function buildNDFA(ast, state)
	local mt = {}
	mt.__index = function(table, key)
		if not key then warn("nil literal?") end
		return function(machines)
			local m = NDFA.new()
			m:addState(m.start,key,true)
			return m
		end
	end
	local fragments = setmetatable({}, mt)
	function fragments.CONCAT(machines)
		local m0 = nil
		for _,m1 in ipairs(machines) do
			if m0 then
				m0:concat(m1)
			else
				m0 = m1
			end
		end
		return m0
	end
	function fragments.DOT(machines)
		local m = NDFA.new()
		m:addState(m.start,"DOT",true)
		return m
	end
	function fragments.QUESTION(machines, buildState)
		local m = NDFA.new()
		local m1 = machines[1]
		local m2 = NDFA.new()
		m.start.isFinal = true
		m2.start.isFinal = true
		m:concat(m1):concat(m2)

		buildState.groupN = buildState.groupN + 1
		local i= buildState.groupN
		m.start.hit = startGroup(i, true)
		m2.start.hit = stopGroup(i)
		m:addEdge(m.start, "EPSILON", m2.start)
		return m
	end
	function fragments.PLUS(machines, buildState)
		local m = NDFA.new()
		local m1 = machines[1]
		local m2 = NDFA.new()
		m.start.isFinal = true
		m2.start.isFinal = true
		local finalStates = m1:final()
		m:concat(m1):concat(m2)

		buildState.groupN = buildState.groupN + 1
		local i= buildState.groupN

		local start = m1.start
		for _,stop in pairs(finalStates) do
			m:addEdge(stop,"EPSILON", start)
		end
		m.start.hit = startGroup(i, true)
		m2.start.hit = stopGroup(i)

		return m
	end
	function fragments.MINUS(machines, buildState)
		local m = fragments.STAR(machines, buildState)
		local i= buildState.groupN
		m.start.hit = startGroup(i, false)
		return m
	end
	function fragments.STAR(machines, buildState)
		local m = NDFA.new()
		local m1 = machines[1]
		local m2 = NDFA.new()
		m.start.isFinal = true
		m2.start.isFinal = true
		local finalStates = m1:final()
		m:concat(m1):concat(m2)


		buildState.groupN = buildState.groupN + 1
		local i= buildState.groupN

		local start = m1.start
		for _,stop in pairs(finalStates) do
			m:addEdge(stop,"EPSILON", start)
			m:addEdge(start,"EPSILON", stop)
		end
		m.start.hit = startGroup(i, true)
		m2.start.hit = stopGroup(i)

		return m
	end
	fragments["|"] = function(machines)
		local m = NDFA.new()
		local m1 = machines[1]
		local m2 = machines[2]
		m:insert(m1)
		m:insert(m2)
		m:addEdge(m.start, "EPSILON", m1.start)
		m:addEdge(m.start, "EPSILON", m2.start)
		return m
	end
	function fragments.ROOT(...)
		return fragments.EMPTY(...)
	end
	function fragments.EMPTY(machines)
		if machines[1] then
			return machines[1]
		else
			return NDFA.new()
		end
	end
	function fragments.CAPTURE(machines, buildState)
		local m1 = NDFA.new()
		local name = table.remove( buildState.captureNames, 1)
		buildState.groupN = buildState.groupN + 1
		local i= buildState.groupN
		m1.start.isFinal = true
		m1.start.captureName = name

		m1.start.hit = startGroup(i, true)

		local m2 = machines[1]
		local m3 = NDFA.new()
		m3.start.isFinal =  true
		m3.start.captureName = name

		m3.start.hit = stopGroup(i)

		m1:concat(m2):concat(m3)
		return m1
	end

	local children = {}
	for i,c in pairs( ast.children ) do
		local m = buildNDFA(c,state)
		children[i] = m
	end
	if not children then warn("no children?") end
	local val = ast.val or "Empty"
	local m = fragments[val](children, state)
	return m
end
return re
