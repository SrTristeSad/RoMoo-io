--!nonstrict
-- Rodar no Command Bar do servidor em Play: sem upload de imagens.
-- Verifica nomes de faces, texturas, limites e ausencia de colisao alterada.
local scripts=game:GetService("ServerScriptService"):WaitForChild("RoMoo")
local Mats=require(scripts:WaitForChild("VoxelMaterials"))
local cfg=require(game:GetService("ReplicatedStorage"):WaitForChild("RoMoo")
    :WaitForChild("Shared"):WaitForChild("Config"))
local fake={
    MapSize=cfg.MapSize,SnowDepth=cfg.SnowDepth,VoxelFoliageBudget=2,
    VoxelTextureIds={
        TrunkTop=123456,TrunkSide=234567,Leaves=345678,
        SnowLeaves=456789,Stone=567890,GoldOre=678901,
        BoarBody=111111,BoarHead=222222,BoarLeg=333333,BoarTail=444444,
    },
}
local folder=Instance.new("Folder")
folder.Name="VoxelMaterialsSmoke"
folder.Parent=workspace
local function node(kind,names,z)
    local m=Instance.new("Model")
    m.Name=kind
    m.Parent=folder
    for _,name in ipairs(names) do
        local part=Instance.new("Part")
        part.Name=name
        part.Anchored=true
        part.Position=Vector3.new(1000,5,z or 1000)
        part.Parent=m
        if not m.PrimaryPart then m.PrimaryPart=part end
    end
    return m
end
local tree=node("Tree",{"Core","Copa","Copa","Copa"})
assert(Mats.resource(tree,"Tree",fake)==3,"Orcamento de folhagem violado")
local total=0
for _,part in ipairs(tree:GetDescendants()) do
    if part:IsA("Decal") then total+=1 end
end
assert(total==18,"Tronco e copas precisam de 18 faces com imagens")
assert(tree.PrimaryPart.CanCollide,"Renderizacao alterou colisao do recurso")
local gold=node("Gold",{"Core","VeioDeOuro"})
assert(Mats.resource(gold,"Gold",fake)==1,"Minerio nao recebeu superficie")
local boar=node("Boar",{"Tronco","Cabeca","Perna","Cauda"})
assert(Mats.animal(boar,"Boar",fake)==4,"Javali nao recebeu texturas")
local foo=node("Cow",{"Tronco","Cabeca"})
assert(Mats.animal(foo,"Cow",cfg)==0,"ID zero deve manter paleta")
folder:Destroy()
print("[RoMoo SKINS] PASS: arvore, ouro, javali, faces e limite de decoracao.")
