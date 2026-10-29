-- Studio Server Command Bar em Play: teste isolado de recursos e geometria 3D.
local Replicated = game:GetService("ReplicatedStorage")
local World = require(game:GetService("ServerScriptService"):WaitForChild("RoMoo"):WaitForChild("World"))
local Config = require(Replicated:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local world = workspace:WaitForChild("RoMooWorld", 15)
assert(world, "Mundo ausente")
local fauna = world:FindFirstChild("Animals")
assert(fauna and #fauna:GetChildren() > 15, "Fauna insuficiente")
local counts = {}
for _, animal in ipairs(fauna:GetChildren()) do
    assert(animal:GetAttribute("SourceTypeId") ~= nil, "Tipo da fonte Moo-IO ausente")
    assert(animal.PrimaryPart ~= nil, "Animal sem PrimaryPart")
    local kind = animal:GetAttribute("Kind")
    counts[kind] = (counts[kind] or 0) + 1
    assert(animal:FindFirstChild("Tronco") or animal:FindFirstChild("ImportedVisual"),
        "Animal sem modelo 3D: " .. tostring(kind))
end
assert(counts.Cow and counts.Wolf and counts.Pig and counts.Sheep, "Espécies comuns ausentes")

local testFolder = Instance.new("Folder")
testFolder.Name = "ResourceSmokeTemp"
testFolder.Parent = workspace
for _, kind in ipairs({"Tree","Rock","Gold","Bush"}) do
    local node = World.spawnNode(kind, Vector3.new(800,0,800), testFolder)
    assert(node:GetAttribute("Health") == Config.ResourceTypes[kind].health)
    local hits = 0
    local broken = false
    while not broken and hits < 20 do
        broken = World.hitNode(node, Config.Items.Hammer)
        hits += 1
    end
    assert(broken, "Recurso nao quebrou: " .. kind)
    assert(node:GetAttribute("Health") == 0, "Durabilidade final incorreta")
end
testFolder:Destroy()
print("[RoMoo 0.7] PASS: fauna 3D e recursos quebraveis.")
