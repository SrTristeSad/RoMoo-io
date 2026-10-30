--!nonstrict
-- Rodar na Command Bar do SERVIDOR durante Play.
-- Testa bloqueio do alcance sem exigir dois jogadores ou destruir o mapa.
local Replicated = game:GetService("ReplicatedStorage")
local modules = game:GetService("ServerScriptService"):WaitForChild("RoMoo")
local Visibility = require(modules:WaitForChild("CombatVisibility"))
local Melee = require(modules:WaitForChild("Melee"))
local Config = require(Replicated:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local root = Instance.new("Folder")
root.Name = "RoMooVisibilityTest"
root.Parent = workspace
local resources=Instance.new("Folder")
resources.Name="Resources"
resources.Parent=root
local buildings=Instance.new("Folder")
buildings.Name="Buildings"
buildings.Parent=root
local animals=Instance.new("Folder")
animals.Name="Animals"
animals.Parent=root
local attacker=Instance.new("Part")
attacker.Anchored=true
attacker.CanQuery=false
attacker.CanCollide=false
attacker.Position=Vector3.new(900,4,900)
attacker.Parent=root
local victim=Instance.new("Model")
victim.Name="Cow"
victim.Parent=animals
local core=Instance.new("Part")
core.Name="Core"
core.Size=Vector3.new(4,4,4)
core.Position=Vector3.new(900,4,888)
core.Anchored=true
core.CanCollide=false
core.CanQuery=true
core.Parent=victim
victim.PrimaryPart=core
local wall=Instance.new("Part")
wall.Name="SolidWall"
wall.Size=Vector3.new(12,8,2)
wall.Position=Vector3.new(900,4,894)
wall.Anchored=true
wall.CanCollide=true
wall.CanQuery=true
wall.Parent=buildings

local from,to=attacker.Position,core.Position
assert(not Visibility.clear(from,to,resources,buildings),
    "Parede solida nao bloqueou a linha de visao")
assert(Melee.choose(attacker,Vector3.new(0,0,-1),resources,animals,Config,nil,
    Config.Weapons.Hammer,nil)==victim,
    "Teste base de mira falhou sem consultar a pasta de paredes")
assert(Melee.choose(attacker,Vector3.new(0,0,-1),resources,animals,Config,buildings,
    Config.Weapons.Hammer,nil)==nil,
    "Golpe atravessou a parede")
wall.CanCollide=false
assert(Visibility.clear(from,to,resources,buildings),
    "Espinhos sem colisao foram tratados como muro")
wall:Destroy()
local tree=Instance.new("Part")
tree.Name="TreeCore"
tree.Anchored=true
tree.Size=Vector3.new(6,8,6)
tree.Position=Vector3.new(900,4,894)
tree.CanCollide=true
tree.CanQuery=true
tree.Parent=resources
assert(not Visibility.clear(from,to,resources,buildings),
    "Tronco solido nao impediu golpe animal")
tree:Destroy()
assert(Visibility.clear(from,to,resources,buildings),"Espaco vazio bloqueado")
local ownResource=Instance.new("Model")
ownResource.Name="Tree"
ownResource.Parent=resources
local solidCore=Instance.new("Part")
solidCore.Name="Core"
solidCore.Anchored=true
solidCore.Size=Vector3.new(5,5,5)
solidCore.Position=Vector3.new(900,4,888)
solidCore.Parent=ownResource
ownResource.PrimaryPart=solidCore
assert(not Visibility.clear(from,to,resources,buildings),
    "Recursos solidos precisam bloquear outros alvos")
assert(Visibility.clear(from,to,resources,buildings,ownResource),
    "O recurso atingido nao pode bloquear o proprio golpe")
ownResource:Destroy()
assert(not Visibility.clear("invalid",to,resources,buildings),"Entrada invalida aceita")
root:Destroy()
print("[RoMoo VISIBILIDADE] PASS: muralhas, espinhos, troncos e golpe direcional.")
