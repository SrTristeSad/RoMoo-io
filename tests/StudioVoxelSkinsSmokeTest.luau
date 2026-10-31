--!nonstrict
-- Play > Command Bar do SERVIDOR. Verifica a malha de skin 64x64
-- sem precisar importar qualquer imagem real nem modificar o jogador.
local modules=game:GetService("ServerScriptService"):WaitForChild("RoMoo")
local Skins=require(modules:WaitForChild("VoxelSkins"))
local Config=require(game:GetService("ReplicatedStorage"):WaitForChild("RoMoo")
    :WaitForChild("Shared"):WaitForChild("Config"))
assert(Config.VoxelThemeEnabled and Config.VoxelSkins.Enabled,"Tema voxel desabilitado")
local offset,size=Skins.faceRect("Head","front",false,false)
assert(offset==Vector2.new(8,8) and size==Vector2.new(8,8),"UV da cabeca incorreta")
offset,size=Skins.faceRect("Torso","front",false,false)
assert(offset==Vector2.new(20,20) and size==Vector2.new(8,12),"UV torso incorreta")
offset,size=Skins.faceRect("RightArm","front",false,false)
assert(offset==Vector2.new(44,20) and size==Vector2.new(4,12),"Braco classico incorreto")
offset,size=Skins.faceRect("RightArm","front",true,false)
assert(offset==Vector2.new(44,20) and size==Vector2.new(3,12),"Braco slim incorreto")
offset,size=Skins.faceRect("LeftArm","front",false,false)
assert(offset==Vector2.new(36,52) and size==Vector2.new(4,12),"Braco esquerdo incorreto")
assert(Skins.faceRect("Invalid","front")==nil,"Membro invalido aceito")
local fake=Instance.new("Model")
fake.Name="TesteAvatarVoxel"
fake.Parent=workspace
for _,name in ipairs({"Head","UpperTorso","RightUpperArm","LeftUpperArm",
    "RightUpperLeg","LeftUpperLeg"}) do
    local p=Instance.new("Part")
    p.Name=name
    p.Anchored=true
    p.Position=Vector3.new(900,6,900)
    p.Parent=fake
end
assert(Skins.apply(fake,Config.VoxelSkins.Presets[1]),"Paleta nao aplicada")
local visual=fake:FindFirstChild("RoMooVoxelVisual")
assert(visual,"Modelo cubico ausente")
local count=0
for _,part in ipairs(visual:GetChildren()) do
    if part:IsA("BasePart") then
        count+=1
        assert(not part.CanQuery and not part.CanCollide,
            "Skin alterou hitbox ou colisao")
    end
end
assert(count==6,"Avatar deve ter seis membros cubicos")
assert(fake.Head.Transparency==1,"Cabeca original nao foi escondida")
local custom={imageId=123456,slim=true,outer=true}
assert(Skins.apply(fake,custom),"Atlas moderno nao aplicado")
visual=fake:FindFirstChild("RoMooVoxelVisual")
assert(#visual:GetChildren()>6,"Segunda camada nao foi adicionada")
local arm=visual:FindFirstChild("Voxel_RightArm")
assert(arm and math.abs(arm.Size.X-.6)<.01,"Bracos slim nao foram aplicados")
local gui=arm:FindFirstChild("Skin_front")
local image=gui and gui:FindFirstChild("PixelAtlas")
assert(image and image.ImageRectOffset==Vector2.new(44,20)
    and image.ImageRectSize==Vector2.new(3,12),"Atlas recortado errado")
fake:Destroy()
print("[RoMoo VOXEL] PASS: paleta, 64x64, braco slim, 2a camada e colisao.")
