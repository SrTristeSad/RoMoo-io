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
    assert(node:GetAttribute("Health") == Config.ResourceTypes[kind].hp)
end
assert(count.Tree > 0 and count.Rock > 0 and count.Gold > 0, "Falta recurso essencial")

local testFolder = Instance.new("Folder")
testFolder.Name = "TesteTemporario"
testFolder.Parent = workspace
for _, kind in ipairs({"Tree", "Rock", "Gold"}) do
    local node = World.spawnNode(kind, Vector3.new(900, 0, 900), testFolder)
    local ticks = math.ceil(Config.ResourceTypes[kind].hp / Config.ResourceTypes[kind].damage)
    local broken = false
    for i = 1, ticks do
        local stats
        stats, broken = World.hitNode(node)
        assert(stats and stats.inventory, "Recurso não deu recompensa")
        if i < ticks then assert(not broken, "Quebrou antes da hora") end
    end
    assert(broken and node:GetAttribute("Health") == 0, "Recurso não quebrou: " .. kind)
end
testFolder:Destroy()
assert(workspace.Terrain.WaterWaveSize > 0, "Água sem ondas")
local bridge = world:FindFirstChild("PonteDeMadeira")
assert(bridge and #bridge:GetChildren() > 5, "Ponte não criada")
local player = game:GetService("Players"):GetPlayers()[1]
if player and player.Character then
    local hammer = player.Character:FindFirstChild("Marreta")
    assert(hammer and hammer:IsA("Tool") and hammer:FindFirstChild("Handle"),
        "Marreta não está equipada no personagem")
end
print("[RoMoo 3D] PASS: Terrain, ponte, árvore, pedra, ouro e marreta.")
