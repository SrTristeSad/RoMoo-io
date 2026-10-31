--!nonstrict
-- Roblox Studio: Play > Server Command Bar.
-- Verifica quatro membros articulados, postura de descanso e query barato.
local modules=game:GetService("ServerScriptService"):WaitForChild("RoMoo")
local Gait=require(modules:WaitForChild("CreatureGait"))
local AnimalModels=require(modules:WaitForChild("AnimalModels"))
local World=require(modules:WaitForChild("World"))
local temp=Instance.new("Folder")
temp.Name="CreatureGaitSmokeTest"
temp.Parent=workspace
local root=Instance.new("Model")
root.Name="Cow"
root.Parent=temp
local core=Instance.new("Part")
core.Name="Core"
core.Size=Vector3.new(5,4,7)
core.CFrame=CFrame.new(900,3.6,900)
core.Anchored=true
core.CanQuery=true
core.Transparency=1
core.Parent=root
root.PrimaryPart=core
AnimalModels.create(root,core.CFrame,"Cow",core)
local legs={}
local hooves={}
for _,part in ipairs(root:GetChildren()) do
    if part.Name=="Perna" then table.insert(legs,part) end
    if part.Name=="Casco" then table.insert(hooves,part) end
end
assert(#legs==4 and #hooves==4,"Quatro patas/cascos ausentes")
local initial={}
for i,leg in ipairs(legs) do initial[i]=leg.CFrame end
assert(Gait.animate(root,1.2,11,1),"Animal nao registrado na animacao")
local moved=false
for i,leg in ipairs(legs) do
    if (leg.Position-initial[i].Position).Magnitude>.01 then moved=true end
end
assert(moved,"Pernas nao se movimentaram")
root:PivotTo(core.CFrame*CFrame.new(4,0,0))
assert(Gait.animate(root,1.3,11,0),"Retorno a pose de repouso falhou")
for i,leg in ipairs(legs) do
    local old=initial[i].Position
    assert((leg.Position-(old+Vector3.new(4,0,0))).Magnitude<.05,
        "Casco/perna nao retornou a pose de repouso apos teleportar")
end
local resources=Instance.new("Folder")
resources.Parent=temp
for _,kind in ipairs({"Tree","Rock","Gold","Bush"}) do
    local node=World.spawnNode(kind,Vector3.new(930,0,930),resources)
    assert(node.PrimaryPart.CanQuery,"Core sem query: "..kind)
    assert(node.PrimaryPart:GetAttribute("Health")==nil,"Core deve ser permanente")
    for _,item in ipairs(node:GetDescendants()) do
        if item:IsA("BasePart") and item~=node.PrimaryPart then
            assert(not item.CanQuery,"Decoracao atrapalhando os golpes: "..kind)
        end
    end
end
temp:Destroy()
print("[RoMoo GAIT] PASS: pernas, retorno, reposicionamento e query de recursos.")
