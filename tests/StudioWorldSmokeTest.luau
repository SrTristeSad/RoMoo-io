--!nonstrict
-- Command Bar do SERVIDOR durante Play: Mundo original sem pontes, corrente,
-- biomas, limites, lobos 3D e recurso infinito.
local Replicated=game:GetService("ReplicatedStorage")
local scripts=game:GetService("ServerScriptService"):WaitForChild("RoMoo")
local Config=require(Replicated:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local Rules=require(scripts:WaitForChild("MapRules"))
local World=require(scripts:WaitForChild("World"))
local Flow=require(scripts:WaitForChild("RiverFlow"))
local world=workspace:WaitForChild("RoMooWorld",15)
assert(world,"Mundo ausente")
local resources=world:WaitForChild("Resources")
local wolfFolder=world:WaitForChild("Wolves")
local currents=world:FindFirstChild("CorrentezaLeste")
local bounds=world:FindFirstChild("LimitesInvisiveis")
assert(currents and currents:GetAttribute("DirectionX")==1,"Corrente nao vai para +X")
assert(Flow.isInCurrent(Config,Vector3.new(1,-3,0)),"Agua sem corrente")
assert(not Flow.isInCurrent(Config,Vector3.new(1,3,35)),"Corrente fora da agua")
assert(world:FindFirstChild("Pontes")==nil,"Pontes antigas nao removidas")
assert(bounds and #bounds:GetChildren()==4,"Faltam 4 limites invisiveis")
for _,part in ipairs(bounds:GetChildren()) do
    assert(part.CanCollide and part.Transparency==1 and not part.CanQuery,
        "Limite nao impede sair do mundo")
end
assert(Rules.isSnow(Config,Vector3.new(0,0,-240)),"Neve nao gerada")
assert(Rules.isDesert(Config,Vector3.new(0,0,240)),"Deserto nao gerado")
assert(Rules.isRiver(Config,Vector3.zero),"Rio nao centralizado")
local counts={Tree=0,Bush=0,Rock=0,Gold=0}
for _,node in ipairs(resources:GetChildren()) do
    local kind=node:GetAttribute("Kind")
    assert(counts[kind]~=nil,"Recurso inesperado")
    assert(node.PrimaryPart and not node:FindFirstChild("Durability"))
    assert(node:GetAttribute("Health")==nil,"Recurso natural ganhou HP")
    if kind=="Tree" then
        assert(Rules.canPlaceTree(Config,node.PrimaryPart.Position),
            "Arvore dentro do rio/deserto")
    end
    if kind=="Bush" then
        assert(Rules.canPlaceBush(Config,node.PrimaryPart.Position))
    end
    counts[kind]+=1
end
assert(counts.Tree>=170,"Floresta pouco densa: "..counts.Tree)
assert(counts.Bush>=45,"Faltam arbustos: "..counts.Bush)
assert(counts.Rock>=Config.TotalRocks,"Rochas insuficientes")
assert(counts.Gold>=Config.GoldOres,"Ouro insuficiente")

local temp=Instance.new("Folder")
temp.Name="TesteSemDestruir"
temp.Parent=workspace
for _,kind in ipairs({"Tree","Rock","Gold","Bush"}) do
    local node=World.spawnNode(kind,Vector3.new(850,0,850),temp)
    for hit=1,100 do
        local stats=World.hitNode(node)
        assert(stats and stats.inventory and stats.yield>0)
        assert(node.Parent==temp and node.PrimaryPart and not node:GetAttribute("Health"),
            kind.." destruido apos "..hit.." golpes")
    end
end
temp:Destroy()

assert(#wolfFolder:GetChildren()>=3,"Poucos lobos: "..#wolfFolder:GetChildren())
for _,wolf in ipairs(wolfFolder:GetChildren()) do
    assert(wolf:GetAttribute("SourceTypeId")==4,"Lobo nao e do tipo Moo-IO")
    assert(wolf.PrimaryPart and wolf:FindFirstChild("WolfHealth"),"Lobo sem hitbox")
    assert(wolf:FindFirstChild("Visual3D") or wolf:FindFirstChild("Corpo"),
        "Lobo sem corpo 3D")
end
print(("[RoMoo] PASS - %d arvores, %d arbustos, %d rochas, %d ouros, %d lobos, rio sem pontes.")
    :format(counts.Tree,counts.Bush,counts.Rock,counts.Gold,#wolfFolder:GetChildren()))
