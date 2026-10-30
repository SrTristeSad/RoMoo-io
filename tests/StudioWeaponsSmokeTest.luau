--!nonstrict
-- Execute na Command Bar do servidor, durante Play. Teste nao destrutivo.
-- Confere geometria das armas, atributos de dano, acesso por idade e morte.
local Replicated=game:GetService("ReplicatedStorage")
local Server=game:GetService("ServerScriptService"):WaitForChild("RoMoo")
local Config=require(Replicated:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local Avatar=require(Server:WaitForChild("Avatar"))
local Melee=require(Server:WaitForChild("Melee"))
local Progression=require(Server:WaitForChild("Progression"))
local remotes=Replicated:WaitForChild("RoMoo"):WaitForChild("Remotes")

assert(remotes:FindFirstChild("SelectWeapon"),"Remote de selecao ausente")
assert(remotes:FindFirstChild("Strike"),"Remote de golpe ausente")
assert(Config.Weapons.Hammer.minAge==1,"Marreta nao e inicial")
assert(Config.Weapons.Axe.minAge==3,"Machado fora da idade 3")
assert(Config.Weapons.Sword.minAge==5,"Espada fora da idade 5")
assert(Config.Weapons.Axe.gatherMultiplier>Config.Weapons.Hammer.gatherMultiplier,
    "Machado nao aumenta coleta")
assert(Config.Weapons.Sword.pvpDamage>Config.Weapons.Axe.pvpDamage,
    "Espada nao aumenta dano PvP")
assert(Config.Weapons.Sword.cooldown<Config.Weapons.Axe.cooldown,
    "Espada nao ataca mais rapido que machado")

local tool=Avatar.createHammer()
assert(tool:IsA("Tool") and tool.Name=="Marreta" and tool:FindFirstChild("Handle"))
for _,entry in ipairs({
    {"Hammer","CabecaMetal"}, {"Axe","CabecaMachado"}, {"Sword","Lamina"},
}) do
    local kind,geometry=entry[1],entry[2]
    assert(Avatar.applyWeaponVisual(tool,kind),kind.." nao equipou")
    assert(tool.Name=="Marreta","Mudou nome da Tool, o cliente nao reconhecera")
    assert(tool:GetAttribute("WeaponId")==kind,"Atributo incorreto: "..kind)
    assert(tool:FindFirstChild(geometry),"Falta geometria 3D: "..geometry)
end
assert(not Avatar.applyWeaponVisual(tool,"AdminGun"),"Arma inventada aceita")
tool:Destroy()

local dummy=Instance.new("Folder")
dummy.Name="RoMooWeaponAgeTest"
dummy.Parent=workspace
local p={}
Progression.initialize(dummy,p,Config)
assert(p.age==1)
assert(not Progression.canUse(p,Config.Weapons.Axe))
assert(not Progression.canUse(p,Config.Weapons.Sword))
for age=2,5 do
    local threshold=Progression.threshold(p.age,Config)
    assert(Progression.award(dummy,p,threshold,Config)==age,
        "Nao foi possivel evoluir idade "..age)
end
assert(Progression.canUse(p,Config.Weapons.Axe))
assert(Progression.canUse(p,Config.Weapons.Sword))
dummy:Destroy()

local direction=Melee.validDirection(Vector3.new(1,0,0))
assert(direction and direction.Magnitude>.9)
assert(Melee.validDirection(Vector3.new(math.huge,0,0))==nil,
    "Aceitou mira infinita")
print("[RoMoo ARMAS] PASS: marreta, machado, espada, idade, visual 3D e seguranca.")
