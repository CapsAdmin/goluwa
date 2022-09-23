local nl = require("nattlua")
local code = [[
    BlueTeam = game.Teams["BlueTeam"]:Clone()
    local RedTeam = game.Teams["RedTeam"]:Clone()
    local NumPlayers = 2

    repeat wait(0)until game:FindFirstChild("Teams")
    local GameTime = 250
    local A = game:service('Players')
    local A1 = "This service is unavailable, please wait until 1 more player joins..."
    local A2 = "Welcome to the official meadows sfing game"
    local A4 = "5"
    local A3 = "The amount of players is successful, and the game will be starting in" .. A4 .. "Seconds.."
    local A5 = "Teaming players..."
    local A6 = "Blue team has won"
    local A7 = "Red team has won"
    local redplayers = 0
    local blueplayers = 0
    local M = Instance.new("Message",game.Workspace)
    local H = Instance.new("Hint",game.Workspace)
    local TimeForLoop = .5
    local players = 0
    local GameRun = false
    local GameOver = false
    local RegenTeams = false

    function teams()
    function balanceTeams(players, teams, randomize, callback)
    for key = 1, #players do
    local value = table.remove(players, randomize and math.random(#players) or 1);
    if (not callback) or callback(key, value) then
    value.TeamColor = teams[(key % (#teams + 1)) + 1];
    end
    end
    end
    end;

    balanceTeams(
    players:GetPlayers(),
    {BrickColor.new("Bright red"), BrickColor.new("Bright blue")},
    true
    );

    function checkSpectators()
    spectators = 0
    for _, player in pairs(game:service('Players'):GetChildren()) do
    if player.TeamColor == game.Teams.Spectators.TeamColor then
    spectators = spectators + 1 end
    if(spectators >= NumPlayers) then
    game.Teams.BlueTeam:remove()
    game.Teams.RedTeam:remove()
    end

    wait(3)
    end
    end

    function findwinner()
    if GameOver then
    for _, player in pairs(game.Players:GetPlayers()) do
    if player.TeamColor == BlueTeam.TeamColor then
    players = blueplayers + 1
    wait(5)
    if blueplayers == 0 then
    print("Blue team has lost")
    M.Text = A7
    elseif player.TeamColor == RedTeam.TeamColor then
    players = redplayers + 1
    if redplayers == 0 then
    print("Red team has lost")
    M.Text = A6
    end
    end
    end
    end
    end
    end

    function RegenPlrs()
    for i,v in pairs(game.Players:GetPlayers())do
    if v and v.Character then
    v.Character:BreakJoints()
    end
    end
    end

    function StartGame()
    if GameRun then
    teams()
    RegenPlrs()
    checkspectators()
    findwinner()
    end
    end

    coroutine.resume(coroutine.create(function()
    while wait(TimeForLoop)do
    if not ( #A:GetPlayers() >= NumPlayers ) then
    M.Text = A1
    else
    StartGame()
    M.Text = ""
    wait(1)
    M.Text = A2
    wait(5)
    M.Text = A3
    for z = 5, 0, -1 do
    M.Text = ""..z
    wait(1)
    end
    for i = GameTime, 0, -1 do
    H.Text = "Time left: "..i
    wait(1)
    end
    wait(2)
    M.Text = "Times up!"
    wait(2)
    M.Text = "Starting new round..."
    wait(2.5)
    end
    end
    end))
]]
print(assert(nl.Compiler(code, nil, {preserve_whitespace = false}):Emit()))
