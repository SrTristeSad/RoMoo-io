--!nonstrict
-- Cole na Command Bar do SERVIDOR em Play. Teste de integração do arco.
-- Não comprova colisão com jogadores: use os cenários de dois clientes do checklist.
local Players = game:GetService("Players")
local Replicated = game:GetService("ReplicatedStorage")
local ServerScripts = game:GetService("ServerScriptService")
local shared = Replicated:WaitForChild("RoMoo"):WaitForChild("Shared")
local Config = require(shared:WaitForChild("Config"))
local gameServer = ServerScripts:WaitForChild("RoMoo")
local Projectiles = require(gameServer:WaitForChild("Projectiles"))
local Animals = require(gameServer:WaitForChild("Animals"))
local Clans = require(gameServer:WaitForChild("Clans"))
local world = workspace:WaitForChild("RoMooWorld")
local projectiles = world:WaitForChild("Projectiles")
assert(Config.Items.Bow.projectile, "Arco desabilitado")
assert(Config.Items.Bow.minAge == 6 and Config.Items.Bow.ammo.Wood == 2)
local owner = Players:GetPlayers()[1]
assert(owner, "Entre como jogador no Play antes do teste")
local char = owner.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
assert(root, "Personagem sem HumanoidRootPart")
local before = #projectiles:GetChildren()
local ok = Projectiles.fire(owner, root, Vector3.new(1, 0, 0), Config.Items.Bow, {
    buildings = world:WaitForChild("Buildings"), creatures = world:WaitForChild("Animals"),
    animals = Animals, clans = Clans,
    emitFX = function() end, onAnimalKilled = function() end, onPlayerHit = function() end,
})
assert(ok, "Falha ao criar projétil")
assert(#projectiles:GetChildren() == before + 1, "Projétil não apareceu")
task.wait(2)
assert(#projectiles:GetChildren() <= before, "Projétil não desapareceu após o alcance")
print("[RoMoo 0.8] PASS: arco, projétil, alcance e limpeza de instâncias.")
