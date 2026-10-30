--!nonstrict
-- Personagem padrão do Roblox com uma Tool de marreta equipada de verdade.
local Avatar = {}

local function piece(parent, name, size, offset, color, material, shape, handle)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = handle.CFrame * CFrame.new(offset)
    part.Color = color
    part.Material = material
    part.Shape = shape or Enum.PartType.Block
    part.Anchored = false
    part.Massless = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = handle
    weld.Part1 = part
    weld.Parent = part
    return part
end

function Avatar.createHammer()
    local tool = Instance.new("Tool")
    tool.Name = "Marreta"
    tool.ToolTip = "Clique numa árvore, pedra ou minério de ouro para coletar"
    tool.RequiresHandle = true
    tool.CanBeDropped = false
    tool.Grip = CFrame.new(0, -1.05, 0) * CFrame.Angles(0, 0, math.rad(-10))

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(.5, 3.5, .5)
    handle.Color = Color3.fromRGB(128, 85, 51)
    handle.Material = Enum.Material.Wood
    handle.CanCollide = false
    handle.Massless = true
    handle.TopSurface = Enum.SurfaceType.Smooth
    handle.BottomSurface = Enum.SurfaceType.Smooth
    handle.Parent = tool

    piece(tool, "CabeçaMetal", Vector3.new(2.85, 1.05, 1.13),
        Vector3.new(0, 1.32, 0), Color3.fromRGB(112, 127, 134),
        Enum.Material.Metal, nil, handle)
    piece(tool, "FaceEsquerda", Vector3.new(.24, 1.26, 1.26),
        Vector3.new(-1.46, 1.32, 0), Color3.fromRGB(165, 176, 183),
        Enum.Material.Metal, nil, handle)
    piece(tool, "FaceDireita", Vector3.new(.24, 1.26, 1.26),
        Vector3.new(1.46, 1.32, 0), Color3.fromRGB(165, 176, 183),
        Enum.Material.Metal, nil, handle)
    piece(tool, "Empunhadura", Vector3.new(.59, 1.22, .59),
        Vector3.new(0, -1.04, 0), Color3.fromRGB(66, 63, 57),
        Enum.Material.Leather, nil, handle)
    return tool
end

function Avatar.equip(player, character, humanoid)
    -- Manter corpo, roupas, rosto e animações originais do Roblox.
    humanoid.WalkSpeed = 16
    humanoid.AutoRotate = true
    if character:FindFirstChild("Marreta") then return end
    local backpack = player:WaitForChild("Backpack", 10)
    if not backpack then return end
    for _, child in ipairs(backpack:GetChildren()) do
        if child:IsA("Tool") and child.Name == "Marreta" then child:Destroy() end
    end
    local tool = Avatar.createHammer()
    tool.Parent = backpack
    task.defer(function()
        if humanoid.Parent == character and humanoid.Health > 0 and tool.Parent then
            humanoid:EquipTool(tool)
        end
    end)
end

return Avatar
