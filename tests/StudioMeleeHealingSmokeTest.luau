--!nonstrict
-- Play > Server Command Bar: teste de cone de marreta e cura.
local ServerScripts = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ServerScripts:WaitForChild("RoMoo")
local Melee = require(modules:WaitForChild("Melee"))
local World = require(modules:WaitForChild("World"))
local Config = require(ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
assert(Melee.validDirection(Vector3.new(1,0,0)) ~= nil, "Direcao unitária rejeitada")
assert(Melee.validDirection(Vector3.new(0,0,0)) == nil, "Direcao nula aceita")
assert(Melee.validDirection(Vector3.new(9,0,0)) == nil, "Direcao abusiva aceita")
assert(Melee.validDirection("Wolf") == nil, "Cliente pode enviar Model/nome")
local invalid = Vector3.new(0/0,0,1)
assert(Melee.validDirection(invalid) == nil, "NaN aceito")
assert(Config.EatCost > 0 and Config.EatHeal > 0 and Config.EatCooldown > 0,
    "Cura desconfigurada")
local remotes = ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Remotes")
assert(remotes:FindFirstChild("Strike") and remotes:FindFirstChild("Eat"),
    "Faltam RemoteEvents de ataque ou cura")

local temp = Instance.new("Folder")
temp.Name = "RoMooMeleeSmokeResources"
temp.Parent = workspace
local empty = Instance.new("Folder")
empty.Name = "RoMooMeleeSmokeCreatures"
empty.Parent = workspace
local spot = Vector3.new(900,0,900)
local node = World.spawnNode("Tree",spot,temp)
local fakeRoot = Instance.new("Part")
fakeRoot.Name = "RoMooMeleeFakeRoot"
fakeRoot.Anchored = true
fakeRoot.CanCollide = false
fakeRoot.CanQuery = false
fakeRoot.Size = Vector3.one
fakeRoot.Position = spot + Vector3.new(0,3,13)
fakeRoot.Parent = workspace

assert(Melee.choose(fakeRoot,Vector3.new(0,0,-1),temp,empty,Config) == node,
    "Golpe à frente não encontrou árvore")
assert(Melee.choose(fakeRoot,Vector3.new(0,0,1),temp,empty,Config) == nil,
    "Golpe acertou alvo atrás")
assert(Melee.choose(fakeRoot,Vector3.new(1,0,0),temp,empty,Config) == nil,
    "Golpe acertou alvo fora do cone")
fakeRoot.Position = spot + Vector3.new(0,3,40)
assert(Melee.choose(fakeRoot,Vector3.new(0,0,-1),temp,empty,Config) == nil,
    "Golpe alcançou árvore distante")
for hit=1,100 do
    local stats=World.hitNode(node)
    assert(stats and stats.yield>0 and node.Parent==temp and node:GetAttribute("Health")==nil,
        "Árvore desapareceu ou perdeu durabilidade após golpe")
end
fakeRoot:Destroy()
empty:Destroy()
temp:Destroy()

print("[RoMoo] PASS: cone direcional, antiabuso, alcance, recursos permanentes e eventos de cura.")
