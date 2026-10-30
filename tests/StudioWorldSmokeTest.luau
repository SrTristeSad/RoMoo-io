--!nonstrict
-- Command Bar do servidor durante Play: verifica o protótipo focado em 3D.
local World = require(game:GetService("ServerScriptService"):WaitForChild("RoMoo"):WaitForChild("World"))
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("RoMoo")
    :WaitForChild("Shared"):WaitForChild("Config"))
local world = workspace:WaitForChild("RoMooWorld", 15)
assert(world, "Mundo não foi criado")
local nodes = world:WaitForChild("Resources")
assert(#nodes:GetChildren() >= 20, "Muito poucos recursos gerados")
local count = {Tree = 0, Rock = 0, Gold = 0}
for _, node in ipairs(nodes:GetChildren()) do
    assert(node:IsA("Model") and node.PrimaryPart, "Recurso sem Model/PrimaryPart")
    local kind = node:GetAttribute("Kind")
    assert(count[kind] ~= nil, "Tipo desconhecido " .. tostring(kind))
    count[kind] += 1
    assert(node:GetAttribute("Health") == nil, "Recurso natural não deve ter HP")
    assert(node:FindFirstChild("Durability") == nil, "Recurso com barra de durabilidade")
end
assert(count.Tree >= 120, "Floresta escassa: esperadas 120 ou mais arvores, obtidas " .. count.Tree)
assert(count.Rock >= 35, "Esperadas 35 ou mais pedras, obtidas " .. count.Rock)
assert(count.Gold >= 12, "Esperados 12 ou mais minérios de ouro, obtidos " .. count.Gold)

local testFolder = Instance.new("Folder")
testFolder.Name = "TesteTemporario"
testFolder.Parent = workspace
for _, kind in ipairs({"Tree", "Rock", "Gold"}) do
    local node = World.spawnNode(kind, Vector3.new(900, 0, 900), testFolder)
    local originalParent = node.Parent
    for i = 1, 100 do
        local stats = World.hitNode(node)
        assert(stats and stats.inventory and stats.yield > 0, "Golpe não concedeu recurso")
        assert(node.Parent == originalParent and node.PrimaryPart ~= nil,
            "Recurso desapareceu depois de " .. i .. " golpes: " .. kind)
        assert(node:GetAttribute("Health") == nil, "Recurso recebeu vida: " .. kind)
    end
end
testFolder:Destroy()
assert(workspace.Terrain.WaterWaveSize > 0, "Água sem ondas")
local bridges = world:FindFirstChild("Pontes")
assert(bridges and #bridges:GetChildren() == 3, "Devem existir tres pontes")
for _, bridge in ipairs(bridges:GetChildren()) do
    assert(bridge.Name == "PonteDeMadeira" and bridge.PrimaryPart
        and #bridge:GetChildren() > 5, "Ponte incompleta")
end
local player = game:GetService("Players"):GetPlayers()[1]
if player and player.Character then
    local hammer = player.Character:FindFirstChild("Marreta")
    assert(hammer and hammer:IsA("Tool") and hammer:FindFirstChild("Handle"),
        "Marreta não está equipada no personagem")
end
print(string.format("[RoMoo 3D] PASS: Terrain, pontes, %d arvores, %d pedras, %d ouros e marreta.", count.Tree, count.Rock, count.Gold))
