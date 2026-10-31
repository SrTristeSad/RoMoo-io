--!nonstrict
-- Texturas de superficie para o tema cubico. A fonte PNG fica em
-- assets/voxel/kenney/. Roblox precisa de IDs de imagem enviados pelo
-- Creator Hub: este modulo NAO tenta executar/baixar arquivo de terceiros.
local VoxelMaterials = {}
local SIDE = {
    Enum.NormalId.Front, Enum.NormalId.Back,
    Enum.NormalId.Left, Enum.NormalId.Right,
}
local ALL = {
    Enum.NormalId.Front, Enum.NormalId.Back,
    Enum.NormalId.Left, Enum.NormalId.Right,
    Enum.NormalId.Top, Enum.NormalId.Bottom,
}
local FRONT = {Enum.NormalId.Front}
local function apply(part,id,faces)
    if not part or not part:IsA("BasePart") or typeof(id)~="number"
        or id<=0 or id==math.huge or id~=math.floor(id) then return false end
    for _,face in ipairs(faces) do
        local decal=Instance.new("Decal")
        decal.Name="RoMooVoxelSkin"
        decal.Face=face
        -- IDs pertencem a imagens importadas pelo dono do jogo.
        decal.Texture="rbxassetid://"..tostring(id)
        decal.Parent=part
    end
    return true
end
local function topAndSides(part,top,side)
    apply(part,side,SIDE)
    apply(part,top,{Enum.NormalId.Top,Enum.NormalId.Bottom})
end

-- O budget visual limita o numero de Parts decorativas com texturas numa
-- mesma arvore. Cada Part usa no maximo seis Decals e nao afeta colisao.
function VoxelMaterials.resource(model,kind,config)
    local ids=config and config.VoxelTextureIds
    if not ids or not model or not model:IsA("Model") then return 0 end
    local count=0
    local foliage=0
    local z=model.PrimaryPart and model.PrimaryPart.Position.Z or 0
    local snow=z<=-config.MapSize*.5+config.SnowDepth
    for _,part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency<.95 then
            local name=part.Name
            if kind=="Tree" then
                if name=="Core" then
                    topAndSides(part,ids.TrunkTop,ids.TrunkSide)
                    count+=1
                elseif (name=="Copa" or name=="RamoPinheiro")
                    and foliage<(config.VoxelFoliageBudget or 2) then
                    apply(part,if snow then ids.SnowLeaves else ids.Leaves,ALL)
                    foliage+=1
                    count+=1
                end
            elseif kind=="Rock" then
                if name=="Core" then
                    apply(part,ids.Stone,ALL)
                    count+=1
                end
            elseif kind=="Gold" then
                if name=="Core" then
                    apply(part,ids.GoldOre,ALL)
                    count+=1
                end
            elseif kind=="Bush" and name=="Core" then
                apply(part,ids.Leaves,ALL)
                count+=1
            end
        end
    end
    return count
end

local faces={
    Cow="CowFace",
    Pig="PigFace",
    Bull="BullFace",
    Bully="BullFace",
    Wolf="WolfFace",
    Yeti="YetiFace",
}
function VoxelMaterials.animal(model,kind,config)
    local ids=config and config.VoxelTextureIds
    if not ids or not model or not model:IsA("Model") then return 0 end
    local count=0
    for _,part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency<.95 then
            if part.Name=="Cabeca" then
                if kind=="Boar" then
                    if apply(part,ids.BoarHead,ALL) then count+=1 end
                elseif kind=="Wolf" then
                    if apply(part,ids.FoxBody,ALL) then count+=1 end
                else
                    local face=faces[kind]
                    if face and apply(part,ids[face],FRONT) then count+=1 end
                end
            elseif part.Name=="Tronco" or part.Name=="Corpo" then
                local id=if kind=="Boar" then ids.BoarBody
                    else if kind=="Wolf" then ids.FoxBody else nil
                if apply(part,id,ALL) then count+=1 end
            elseif part.Name=="Perna" and kind=="Boar" then
                if apply(part,ids.BoarLeg,ALL) then count+=1 end
            elseif part.Name=="Cauda" then
                local id=if kind=="Boar" then ids.BoarTail
                    else if kind=="Wolf" then ids.FoxTail else nil
                if apply(part,id,ALL) then count+=1 end
            end
        end
    end
    return count
end
return VoxelMaterials
