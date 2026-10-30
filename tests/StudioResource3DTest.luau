--!nonstrict
-- Cole na Command Bar do SERVIDOR em Play.
-- Confirma fauna real da partida e que recursos naturais sao permanentes.
local Replicated = game:GetService("ReplicatedStorage")
local ServerModules = game:GetService("ServerScriptService"):WaitForChild("RoMoo")
local World = require(ServerModules:WaitForChild("World"))
local Melee = require(ServerModules:WaitForChild("Melee"))
local Animals = require(ServerModules:WaitForChild("Animals"))
local Config = require(Replicated:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local world = workspace:WaitForChild("RoMooWorld",15)
assert(world,"Mundo ausente")
local wildlife = world:WaitForChild("Animals",15)
local wolves = world:WaitForChild("Wolves",15)
assert(#wildlife:GetChildren() >= 15, "Fauna insuficiente")
assert(#wolves:GetChildren() >= 1, "Lobos desapareceram")
local counts = {}
for _,animal in ipairs(wildlife:GetChildren()) do
    assert(animal:GetAttribute("SourceTypeId") ~= nil,"ID da especie ausente")
    assert(animal:GetAttribute("Hostile") ~= nil,"Comportamento ausente")
    assert(animal.PrimaryPart ~= nil and animal.PrimaryPart.CanQuery,"Hitbox ausente")
    assert(animal:FindFirstChild("Tronco") or animal:FindFirstChild("ImportedVisual"),
        "Animal sem modelo 3D: "..animal.Name)
    assert(math.abs(animal.PrimaryPart.Position.Z) >
        Config.River.Width*.5+8,"Animal nasceu no rio")
    counts[animal.Name]=(counts[animal.Name] or 0)+1
end
assert(counts.Cow and counts.Pig and counts.Sheep and counts.Bull,
    "Especies de fazenda ausentes")
assert(not counts.Wolf,"Lobos duplicados na pasta Animals")

local temp = Instance.new("Folder")
temp.Name="RoMooFaunaSmokeTest"
temp.Parent=workspace
local emptyResources=Instance.new("Folder")
emptyResources.Name="Resources"
emptyResources.Parent=temp
local emptyWolves=Instance.new("Folder")
emptyWolves.Name="Wolves"
emptyWolves.Parent=temp
local fakeAnimals=Instance.new("Folder")
fakeAnimals.Name="Animals"
fakeAnimals.Parent=temp
local dummy=Instance.new("Model")
dummy.Name="Cow"
dummy.Parent=fakeAnimals
local core=Instance.new("Part")
core.Name="Core"
core.Size=Vector3.new(5,5,6)
core.CFrame=CFrame.new(1000,3,988)
core.Anchored=true
core.CanQuery=true
core.Parent=dummy
dummy.PrimaryPart=core
local root=Instance.new("Part")
root.Name="AttackerRoot"
root.CFrame=CFrame.new(1000,3,1000)
root.Anchored=true
root.CanQuery=false
root.Parent=temp
assert(Melee.choose(root,Vector3.new(0,0,-1),emptyResources,emptyWolves,
    Config,nil,Config.Weapons.Hammer,nil,fakeAnimals)==dummy,
    "Golpe frontal nao encontrou vaca")
assert(Melee.choose(root,Vector3.new(0,0,1),emptyResources,emptyWolves,
    Config,nil,Config.Weapons.Hammer,nil,fakeAnimals)==nil,
    "Golpe alcancou animal atras do jogador")
assert(Animals.hit(dummy,10)==0,"Animal inventado recebeu recompensa")
for _,kind in ipairs({"Tree","Rock","Gold","Bush"}) do
    local node=World.spawnNode(kind,Vector3.new(1030,0,1030),emptyResources)
    for _=1,40 do
        assert(World.hitNode(node)==Config.ResourceTypes[kind],"Recurso perdeu a coleta")
        assert(node.Parent==emptyResources and node:GetAttribute("Health")==nil,
            "Recurso foi destruido")
    end
end
temp:Destroy()
print("[RoMoo FAUNA] PASS: especies 3D, lobos separados, rio, combate e recursos infinitos.")
