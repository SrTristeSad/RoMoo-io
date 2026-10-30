--!nonstrict
-- No Command Bar do servidor em Play: valida experiencia, idades
-- e desbloqueios usando um jogador ficticio (sem alterar perfis reais).
local Replicated=game:GetService("ReplicatedStorage")
local scripts=game:GetService("ServerScriptService"):WaitForChild("RoMoo")
local Config=require(Replicated:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local Progression=require(scripts:WaitForChild("Progression"))

assert(Progression.threshold(1,Config)==100,"XP inicial divergente")
assert(Progression.threshold(2,Config)==120,"XP idade 2 divergente")
assert(Progression.threshold(3,Config)==144,"XP idade 3 divergente")

local dummy=Instance.new("Folder")
dummy.Name="RoMooProgressionTest"
dummy.Parent=workspace
local p={}
Progression.initialize(dummy,p,Config)
assert(p.age==1 and p.xp==0 and dummy:GetAttribute("Age")==1)
assert(dummy:GetAttribute("XPToNext")==100)
assert(Progression.canUse(p,Config.Buildings.Wall))
assert(not Progression.canUse(p,Config.Buildings.Spikes))
assert(not Progression.canUse(p,Config.Buildings.Windmill))
assert(not Progression.canUse(p,Config.Buildings.StoneWall))

-- A cada golpe de madeira/pedra/ouro, +5 XP: 20 golpes = idade 2.
for i=1,19 do
    assert(Progression.award(dummy,p,5,Config)==nil)
end
assert(p.xp==95 and dummy:GetAttribute("XP")==95)
assert(Progression.award(dummy,p,5,Config)==2)
assert(p.age==2 and p.xp==0 and dummy:GetAttribute("XPToNext")==120)
assert(Progression.canUse(p,Config.Buildings.Spikes))
assert(not Progression.canUse(p,Config.Buildings.Windmill))
assert(Progression.award(dummy,p,120,Config)==3)
assert(Progression.canUse(p,Config.Buildings.Windmill))
assert(not Progression.canUse(p,Config.Buildings.StoneWall))
assert(Progression.award(dummy,p,144,Config)==4)
assert(Progression.canUse(p,Config.Buildings.StoneWall))
assert(Config.Buildings.StoneWall.health>Config.Buildings.Wall.health)
local before=p.xp
assert(Progression.award(dummy,p,-1,Config)==nil and p.xp==before)
assert(Progression.award(dummy,p,math.huge,Config)==nil and p.xp==before)
assert(Progression.award(dummy,p,0/0,Config)==nil and p.xp==before)
assert(Progression.award(dummy,p,"cheat",Config)==nil and p.xp==before)
dummy:Destroy()

print("[RoMoo] PASS: 100/120/144 XP, desbloqueios idades 2/3/4 e antiabuso.")
