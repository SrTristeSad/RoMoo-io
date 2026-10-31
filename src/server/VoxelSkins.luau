--!nonstrict
-- RoMoo: skin cubica compativel com atlas PNG 64x64 de autoria/autorizacao do criador.
-- Nenhuma textura, marca ou personagem de Minecraft vem incluido.
local Skin={}
local UV={
 Head={0,0,8,8,8,32,0}, Torso={16,16,8,12,4,16,32},
 RightArm={40,16,4,12,4,40,32}, LeftArm={32,48,4,12,4,48,48},
 RightLeg={0,16,4,12,4,0,32}, LeftLeg={16,48,4,12,4,0,48},
}
local FACES={
 right=Enum.NormalId.Right, front=Enum.NormalId.Front,
 left=Enum.NormalId.Left, back=Enum.NormalId.Back,
 top=Enum.NormalId.Top, bottom=Enum.NormalId.Bottom,
}
local colors={
 Explorer={Head=Color3.fromRGB(218,172,124),Torso=Color3.fromRGB(69,143,95),
 RightArm=Color3.fromRGB(69,143,95),LeftArm=Color3.fromRGB(69,143,95),
 RightLeg=Color3.fromRGB(72,92,155),LeftLeg=Color3.fromRGB(72,92,155)},
 Builder={Head=Color3.fromRGB(180,128,88),Torso=Color3.fromRGB(224,133,56),
 RightArm=Color3.fromRGB(224,133,56),LeftArm=Color3.fromRGB(224,133,56),
 RightLeg=Color3.fromRGB(77,90,102),LeftLeg=Color3.fromRGB(77,90,102)},
}
function Skin.faceRect(part,face,slim,outer)
 local uv=UV[part]
 if not uv then return nil end
 local u,v,w,h,d=uv[1],uv[2],uv[3],uv[4],uv[5]
 if slim and (part=="RightArm" or part=="LeftArm") then w=3 end
 if outer then u,v=uv[6],uv[7] end
 local r={
  right={u,v+d,d,h},front={u+d,v+d,w,h},left={u+d+w,v+d,d,h},
  back={u+d+w+d,v+d,w,h},top={u+d,v,w,d},bottom={u+d+w,v,w,d}
 }
 local selected=r[face]
 if not selected then return nil end
 return Vector2.new(selected[1],selected[2]),Vector2.new(selected[3],selected[4])
end
local function textureFaces(block,limb,id,slim,outer)
 for face,normal in pairs(FACES) do
  local offset,size=Skin.faceRect(limb,face,slim,outer)
  local gui=Instance.new("SurfaceGui")
  gui.Name="Skin_"..face
  gui.Face=normal
  gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize
  gui.CanvasSize=size
  gui.LightInfluence=.9
  gui.MaxDistance=145
  gui.Parent=block
  local image=Instance.new("ImageLabel")
  image.Name="PixelAtlas"
  image.Size=UDim2.fromScale(1,1)
  image.BackgroundTransparency=1
  image.Image="rbxassetid://"..tostring(id)
  image.ImageRectOffset=offset
  image.ImageRectSize=size
  image.ResampleMode=Enum.ResamplerMode.Pixelated
  image.Parent=gui
 end
end
local function originalEyes(head)
 local gui=Instance.new("SurfaceGui")
 gui.Name="OriginalFace"
 gui.Face=Enum.NormalId.Front
 gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize
 gui.CanvasSize=Vector2.new(8,8)
 gui.Parent=head
 for _,x in ipairs({2,5}) do
  local eye=Instance.new("Frame")
  eye.Size=UDim2.fromOffset(1,1)
  eye.Position=UDim2.fromOffset(x,3)
  eye.BackgroundColor3=Color3.fromRGB(35,39,40)
  eye.BorderSizePixel=0
  eye.Parent=gui
 end
end
local PARTS={
 {"Head","Head",Vector3.new(1.6,1.6,1.6),Vector3.zero},
 {"Torso","UpperTorso",Vector3.new(1.6,2.4,.8),Vector3.new(0,-.4,0)},
 {"RightArm","RightUpperArm",Vector3.new(.8,2.4,.8),Vector3.new(0,-.48,0)},
 {"LeftArm","LeftUpperArm",Vector3.new(.8,2.4,.8),Vector3.new(0,-.48,0)},
 {"RightLeg","RightUpperLeg",Vector3.new(.8,2.4,.8),Vector3.new(0,-.48,0)},
 {"LeftLeg","LeftUpperLeg",Vector3.new(.8,2.4,.8),Vector3.new(0,-.48,0)},
}
local function block(parent,anchor,name,size,offset,color)
 local part=Instance.new("Part")
 part.Name="Voxel_"..name
 part.Size=size
 part.CFrame=anchor.CFrame*CFrame.new(offset)
 part.Color=color
 part.Material=Enum.Material.SmoothPlastic
 part.Anchored=false
 part.Massless=true
 part.CanCollide=false
 part.CanTouch=false
 part.CanQuery=false
 part.TopSurface=Enum.SurfaceType.Smooth
 part.BottomSurface=Enum.SurfaceType.Smooth
 part.Parent=parent
 local weld=Instance.new("WeldConstraint")
 weld.Part0=anchor
 weld.Part1=part
 weld.Parent=part
 return part
end
function Skin.apply(character,preset)
 if not character or not character:IsA("Model") then return false end
 preset=preset or {}
 local anchors={}
 for _,spec in ipairs(PARTS) do
  local anchor=character:FindFirstChild(spec[2])
  if not anchor or not anchor:IsA("BasePart") then return false end
  anchors[spec[2]]=anchor
 end
 local previous=character:FindFirstChild("RoMooVoxelVisual")
 if previous then previous:Destroy() end
 local visual=Instance.new("Model")
 visual.Name="RoMooVoxelVisual"
 visual.Parent=character
 local slim=preset.slim==true
 local id=if typeof(preset.imageId)=="number" and preset.imageId>0
  and preset.imageId<1e16 and preset.imageId==math.floor(preset.imageId)
  then preset.imageId else nil
 local palette=colors[preset.palette] or colors.Explorer
 for _,spec in ipairs(PARTS) do
  local limb,anchor,size,offset=spec[1],anchors[spec[2]],spec[3],spec[4]
  if slim and (limb=="RightArm" or limb=="LeftArm") then
   size=Vector3.new(.6,size.Y,size.Z)
  end
  local cube=block(visual,anchor,limb,size,offset,if id then Color3.new(1,1,1) else palette[limb])
  if id then
   textureFaces(cube,limb,id,slim,false)
   if preset.outer~=false then
    local shell=block(visual,anchor,limb.."_Outer",
     size+Vector3.new(.08,.08,.08),offset,Color3.new(1,1,1))
    shell.Transparency=1
    textureFaces(shell,limb,id,slim,true)
   end
  elseif limb=="Head" then originalEyes(cube) end
 end
 -- Os membros R15 permanecem como hitboxes; escondemos so a aparencia.
 for _,child in ipairs(character:GetChildren()) do
  if child:IsA("BasePart") and child.Name~="HumanoidRootPart" then
   child.Transparency=1
   for _,d in ipairs(child:GetDescendants()) do
    if d:IsA("Decal") or d:IsA("Texture") then d.Transparency=1 end
   end
  elseif child:IsA("Accessory") then
   for _,d in ipairs(child:GetDescendants()) do
    if d:IsA("BasePart") then d.Transparency=1 end
   end
  end
 end
 return true
end
return Skin
