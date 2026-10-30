--!nonstrict
-- Avatar R15 padrao do Roblox; uma Tool real muda sua geometria
-- ao desbloquear Marreta, Machado ou Espada, sem substituir o avatar.
local Avatar = {}
local function decoration(tool,handle,name,size,offset,color,material,shape)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=handle.CFrame*CFrame.new(offset)
    p.Color=color
    p.Material=material
    p.Shape=shape or Enum.PartType.Block
    p.Anchored=false
    p.Massless=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p:SetAttribute("WeaponDecoration",true)
    p.Parent=tool
    local weld=Instance.new("WeldConstraint")
    weld.Part0=handle
    weld.Part1=p
    weld.Parent=p
    return p
end

local function clearDecorations(tool)
    for _,p in ipairs(tool:GetChildren()) do
        if p:IsA("BasePart") and p:GetAttribute("WeaponDecoration") then
            p:Destroy()
        end
    end
end

function Avatar.applyWeaponVisual(tool,id)
    if not tool or not tool:IsA("Tool") then return false end
    local handle=tool:FindFirstChild("Handle")
    if not handle or not handle:IsA("BasePart") then return false end
    if id~="Hammer" and id~="Axe" and id~="Sword" then return false end
    clearDecorations(tool)
    if id=="Hammer" then
        tool.Name="Marreta"
        tool.ToolTip="Marreta: colhe madeira, pedra, ouro e comida infinitamente"
        tool.Grip=CFrame.new(0,-1.05,0)*CFrame.Angles(0,0,math.rad(-10))
        handle.Size=Vector3.new(.5,3.5,.5)
        handle.Color=Color3.fromRGB(128,85,51)
        handle.Material=Enum.Material.Wood
        decoration(tool,handle,"CabecaMetal",Vector3.new(2.85,1.05,1.13),
            Vector3.new(0,1.32,0),Color3.fromRGB(112,127,134),Enum.Material.Metal)
        decoration(tool,handle,"FaceEsquerda",Vector3.new(.24,1.26,1.26),
            Vector3.new(-1.46,1.32,0),Color3.fromRGB(165,176,183),Enum.Material.Metal)
        decoration(tool,handle,"FaceDireita",Vector3.new(.24,1.26,1.26),
            Vector3.new(1.46,1.32,0),Color3.fromRGB(165,176,183),Enum.Material.Metal)
        decoration(tool,handle,"Empunhadura",Vector3.new(.59,1.22,.59),
            Vector3.new(0,-1.04,0),Color3.fromRGB(66,63,57),Enum.Material.Fabric)
    elseif id=="Axe" then
        tool.Name="Marreta" -- Mantem o identificador da Tool e as conexoes do cliente.
        tool.ToolTip="Machado: rende mais madeira, pedra, ouro e comida por golpe"
        tool.Grip=CFrame.new(0,-1.0,0)*CFrame.Angles(0,0,math.rad(-10))
        handle.Size=Vector3.new(.42,3.7,.45)
        handle.Color=Color3.fromRGB(141,96,62)
        handle.Material=Enum.Material.Wood
        decoration(tool,handle,"CabecaMachado",Vector3.new(2.75,1.45,.66),
            Vector3.new(1.05,1.35,0),Color3.fromRGB(145,157,166),Enum.Material.Metal)
        decoration(tool,handle,"FioCortante",Vector3.new(.34,2.13,.84),
            Vector3.new(2.33,1.35,0),Color3.fromRGB(201,208,207),Enum.Material.Metal)
        decoration(tool,handle,"CintaDeFerro",Vector3.new(.62,.8,.72),
            Vector3.new(0,1.25,0),Color3.fromRGB(81,85,87),Enum.Material.Metal)
        decoration(tool,handle,"Punho",Vector3.new(.5,1.1,.58),
            Vector3.new(0,-1.15,0),Color3.fromRGB(68,67,60),Enum.Material.Fabric)
    else
        tool.Name="Marreta"
        tool.ToolTip="Espada: ataque rapido e forte, coleta menos material"
        tool.Grip=CFrame.new(0,-.4,0)
        handle.Size=Vector3.new(.47,1.3,.44)
        handle.Color=Color3.fromRGB(71,65,58)
        handle.Material=Enum.Material.Fabric
        decoration(tool,handle,"Guarda",Vector3.new(2.15,.28,.54),
            Vector3.new(0,.8,0),Color3.fromRGB(173,141,73),Enum.Material.Metal)
        decoration(tool,handle,"Lamina",Vector3.new(.64,3.5,.27),
            Vector3.new(0,2.68,0),Color3.fromRGB(175,190,197),Enum.Material.Metal)
        decoration(tool,handle,"Ponta",Vector3.new(.33,.65,.27),
            Vector3.new(0,4.58,0),Color3.fromRGB(204,212,218),Enum.Material.Metal)
        decoration(tool,handle,"Pomo",Vector3.new(.71,.7,.71),
            Vector3.new(0,-.8,0),Color3.fromRGB(174,146,82),Enum.Material.Metal,
            Enum.PartType.Ball)
    end
    tool:SetAttribute("WeaponId",id)
    return true
end

function Avatar.createHammer()
    local tool=Instance.new("Tool")
    tool.Name="Marreta"
    tool.RequiresHandle=true
    tool.CanBeDropped=false
    local handle=Instance.new("Part")
    handle.Name="Handle"
    handle.Anchored=false
    handle.CanCollide=false
    handle.CanTouch=false
    handle.CanQuery=false
    handle.Massless=true
    handle.TopSurface=Enum.SurfaceType.Smooth
    handle.BottomSurface=Enum.SurfaceType.Smooth
    handle.Parent=tool
    Avatar.applyWeaponVisual(tool,"Hammer")
    return tool
end

function Avatar.equip(player,character,humanoid,weaponId)
    humanoid.WalkSpeed=16
    humanoid.AutoRotate=false
    local existing=character:FindFirstChild("Marreta")
    if existing then
        Avatar.applyWeaponVisual(existing,weaponId or "Hammer")
        return
    end
    local backpack=player:WaitForChild("Backpack",10)
    if not backpack then return end
    for _,child in ipairs(backpack:GetChildren()) do
        if child:IsA("Tool") and child.Name=="Marreta" then child:Destroy() end
    end
    local tool=Avatar.createHammer()
    Avatar.applyWeaponVisual(tool,weaponId or "Hammer")
    tool.Parent=backpack
    task.defer(function()
        if humanoid.Parent==character and humanoid.Health>0 and tool.Parent then
            humanoid:EquipTool(tool)
        end
    end)
end

return Avatar
