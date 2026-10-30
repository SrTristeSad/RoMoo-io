--!nonstrict
-- Cole no Server Command Bar durante Play (sem alterar contas reais).
-- Confere morte/renascimento em objeto isolado e proteção contra spawn kill.
local Replicated = game:GetService("ReplicatedStorage")
local Server = game:GetService("ServerScriptService"):WaitForChild("RoMoo")
local Config = require(Replicated:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local SessionState = require(Server:WaitForChild("SessionState"))
local Progression = require(Server:WaitForChild("Progression"))
local Structures = require(Server:WaitForChild("Structures"))

local fake = Instance.new("Folder")
fake.Name = "RoMooSessionSmoke"
fake.Parent = workspace
local profile = SessionState.create(fake, Config)
assert(profile.age == 1 and profile.xp == 0 and profile.weapon == "Hammer")
for _, kind in ipairs({"Wood","Stone","Gold","Food"}) do
    assert(profile.stock[kind] == fake:GetAttribute(kind), "Inventario inicial divergiu: "..kind)
end

profile.stock.Wood = 200
profile.stock.Stone = 99
profile.stock.Gold = 77
profile.stock.Food = 38
profile.weapon = "Sword"
profile.lastStrike = os.clock()
profile.lastWeaponSelect = os.clock()
profile.lastEat = os.clock()
profile.lastBuild = os.clock()
profile.kills = 4
profile.deaths = 3
Progression.award(fake, profile, Progression.threshold(1,Config), Config)
assert(profile.age == 2)
assert(SessionState.resetForNewLife(fake, profile, Config))
assert(profile.age == 1 and profile.xp == 0 and profile.weapon == "Hammer")
assert(fake:GetAttribute("Age") == 1 and fake:GetAttribute("WeaponId") == "Hammer")
assert(fake:GetAttribute("XP") == 0)
assert(fake:GetAttribute("XPToNext") == Progression.threshold(1,Config))
for _, row in ipairs({
    {"Wood",Config.StartingWood}, {"Stone",Config.StartingStone},
    {"Gold",Config.StartingGold}, {"Food",Config.StartingFood},
}) do
    assert(profile.stock[row[1]] == row[2], "Inventario nao reiniciou")
    assert(fake:GetAttribute(row[1]) == row[2], "HUD nao reiniciou")
end
assert(profile.kills == 4 and profile.deaths == 3, "Placar deveria sobreviver")
assert(profile.lastStrike < -1000 and profile.lastBuild < -1000)

local char = Instance.new("Model")
char.Parent = fake
assert(SessionState.canStrike(char), "Personagem livre bloqueado")
local shield = Instance.new("ForceField")
shield.Parent = char
assert(not SessionState.canStrike(char), "Golpe permitido durante protecao")
shield:Destroy()
assert(SessionState.canStrike(char), "Golpe continuou bloqueado apos escudo")
assert(Config.SpawnProtectionSeconds >= 2)
assert(typeof(Structures.clearOwner) == "function", "Falta limpeza de bases")
fake:Destroy()
print("[RoMoo SESSAO] PASS: reset de idade, arsenal, materiais, placar e invulnerabilidade.")
