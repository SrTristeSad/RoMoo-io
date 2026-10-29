--!nonstrict
-- Silhueta 3D minimalista: corpo circular, braços e ferramenta, sem copiar assets.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local Avatar = {}
local palettes = {
    Color3.fromRGB(168, 112, 73),
    Color3.fromRGB(187, 139, 90),
    Color3.fromRGB(143, 99, 72),
    Color3.fromRGB(174, 119, 94),
    Color3.fromRGB(193, 148, 112),
}

local function attachPart(name, size, position, material, color, root, parent, shape)
    local obj = Instance.new("Part")
    obj.Name = name
    obj.Size = size
    obj.CFrame = root.CFrame * CFrame.new(position)
    obj.Anchored = false
    obj.Massless = true
    obj.CanCollide = false
    obj.CanTouch = false
    obj.CanQuery = false
    obj.Material = material
    obj.Color = color
    if shape then obj.Shape = shape end
    obj.Parent = parent
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = obj
    weld.Parent = obj
    return obj
end

local function changeWeapon(character, root, selected)
    local visuals = character:FindFirstChild("RoMooAvatar")
    if not visuals then return end
    local existing = visuals:FindFirstChild("Weapon")
    if existing then existing:Destroy() end
    local tool = Instance.new("Folder")
    tool.Name = "Weapon"
    tool.Parent = visuals
    if selected == "Food" or selected == "Cookie" then
        local cookie = selected == "Cookie"
        attachPart(if cookie then "Biscoito" else "Maca",
            if cookie then Vector3.new(2.6, .85, 2.6) else Vector3.new(2.4, 2.4, 2.4),
            Vector3.new(3.3, .15, -2.6), Enum.Material.SmoothPlastic,
            if cookie then Color3.fromRGB(198, 139, 72) else Color3.fromRGB(213, 68, 64),
            root, tool, Enum.PartType.Ball)
        return
    end
    if Config.Items[selected] and Config.Items[selected].category == "Building" then
        local isStone = selected == "StoneWall" or selected == "CastleWall" or selected == "StoneSpikes"
        attachPart("PlantaDeConstrucao", Vector3.new(3.5, .4, 3.5),
            Vector3.new(3.4, 0, -2.8), Enum.Material.SmoothPlastic,
            if isStone then Color3.fromRGB(126, 144, 152) else Color3.fromRGB(176, 135, 88),
            root, tool)
        return
    end
    attachPart("Cabo", Vector3.new(1.1, 1, 5),
        Vector3.new(3.2, .1, -3.3), Enum.Material.Wood, Color3.fromRGB(111, 74, 46), root, tool)
    local blade = selected == "Sword" or selected == "LongSword"
        or selected == "Spear" or selected == "GreatSpear"
    local axe = selected == "Axe" or selected == "HeavyAxe"
    local long = selected == "LongSword" or selected == "Spear" or selected == "GreatSpear"
    if blade or axe then
        attachPart(if axe then "Machado" else "Lamina",
            Vector3.new(if axe then 3.9 else 1.2, 1,
                if long then 7 else if axe then 2.4 else 5),
            Vector3.new(3.2, .1, if long then -7.3 else -6.8),
            Enum.Material.Metal, Color3.fromRGB(163, 176, 180), root, tool)
    else
        local heavy = selected == "WarHammer" or selected == "Crusher"
        attachPart("Cabeca",
            if heavy then Vector3.new(4.1, 2, 2.5) else Vector3.new(3.1, 1.6, 1.8),
            Vector3.new(3.2, .1, -6.1),
            Enum.Material.Slate, Color3.fromRGB(109, 115, 124), root, tool)
    end
end

function Avatar.attach(player, character, humanoid)
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not root then return end

    local visuals = Instance.new("Folder")
    visuals.Name = "RoMooAvatar"
    visuals.Parent = character

    local function conceal(item)
        if item:IsDescendantOf(visuals) then return end
        if item:IsA("BasePart") then
            item.Transparency = 1
            item.CastShadow = false
        elseif item:IsA("Decal") or item:IsA("Texture") then
            item.Transparency = 1
        end
    end
    for _, item in ipairs(character:GetDescendants()) do conceal(item) end
    character.DescendantAdded:Connect(conceal)
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    humanoid.WalkSpeed = 19

    local bodyColor = palettes[player.UserId % #palettes + 1]
    local body = attachPart("Corpo", Vector3.new(6, 5.4, 6), Vector3.new(0, .35, 0),
        Enum.Material.SmoothPlastic, bodyColor, root, visuals, Enum.PartType.Ball)
    attachPart("BracoE", Vector3.new(2.1, 2, 2.1), Vector3.new(-3.3, 0, -1.1),
        Enum.Material.SmoothPlastic, bodyColor, root, visuals, Enum.PartType.Ball)
    attachPart("BracoD", Vector3.new(2.1, 2, 2.1), Vector3.new(3.3, 0, -1.1),
        Enum.Material.SmoothPlastic, bodyColor, root, visuals, Enum.PartType.Ball)

    local overhead = Instance.new("BillboardGui")
    overhead.Name = "Overhead"
    overhead.Size = UDim2.fromOffset(128, 36)
    overhead.StudsOffsetWorldSpace = Vector3.new(0, 4.9, 0)
    overhead.AlwaysOnTop = true
    overhead.Adornee = body
    overhead.Parent = visuals
    local name = Instance.new("TextLabel")
    name.Size = UDim2.fromOffset(128, 19)
    name.BackgroundTransparency = 1
    name.Text = player.DisplayName
    name.TextScaled = true
    name.TextStrokeTransparency = .25
    name.Font = Enum.Font.GothamBold
    name.TextColor3 = Color3.new(1, 1, 1)
    name.Parent = overhead
    local hpTrack = Instance.new("Frame")
    hpTrack.BorderSizePixel = 0
    hpTrack.BackgroundColor3 = Color3.fromRGB(73, 60, 61)
    hpTrack.Position = UDim2.fromOffset(14, 22)
    hpTrack.Size = UDim2.fromOffset(100, 8)
    hpTrack.Parent = overhead
    local fill = Instance.new("Frame")
    fill.BorderSizePixel = 0
    fill.BackgroundColor3 = Color3.fromRGB(81, 216, 94)
    fill.Size = UDim2.fromScale(1, 1)
    fill.Parent = hpTrack
    local function updateHealth()
        fill.Size = UDim2.fromScale(math.clamp(humanoid.Health / math.max(1, humanoid.MaxHealth), 0, 1), 1)
    end
    humanoid.HealthChanged:Connect(updateHealth)
    updateHealth()

    local function updateWeapon()
        changeWeapon(character, root, player:GetAttribute("SelectedItem") or "Hammer")
    end
    local selectionConnection = player:GetAttributeChangedSignal("SelectedItem"):Connect(updateWeapon)
    character.Destroying:Connect(function()
        selectionConnection:Disconnect()
    end)
    updateWeapon()
end

return Avatar
