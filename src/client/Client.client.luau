--!nonstrict
-- Controles de estilo .io: mouse mira, clique/Space usa item, E auto-ataque, Q comida.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local remotes = ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Remotes")
local actionRemote = remotes:WaitForChild("Action")
local noticeRemote = remotes:WaitForChild("Notice")
local isTouch = UserInputService.TouchEnabled
local selected = "Hammer"
local held = false
local automatic = false
local lastFire = 0
local rotationLocked = false
local lockedDirection = Vector3.new(0, 0, -1)
local touchDirection = nil
local viewCamera = workspace.CurrentCamera

local screen = Instance.new("ScreenGui")
screen.Name = "RoMooClassicHUD"
screen.IgnoreGuiInset = true
screen.ResetOnSpawn = false
screen.DisplayOrder = 10
screen.Parent = player:WaitForChild("PlayerGui")

local function round(parent, pixels)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, pixels)
    corner.Parent = parent
end

local function label(parent, name, text, color, font)
    local value = Instance.new("TextLabel")
    value.Name = name
    value.BackgroundTransparency = 1
    value.Text = text
    value.TextColor3 = color or Color3.new(1, 1, 1)
    value.Font = font or Enum.Font.GothamBold
    value.TextScaled = true
    value.Parent = parent
    return value
end

local function frame(parent, name, size, position, color, anchor)
    local object = Instance.new("Frame")
    object.Name = name
    object.Size = size
    object.Position = position
    object.AnchorPoint = anchor or Vector2.zero
    object.BorderSizePixel = 0
    object.BackgroundColor3 = color
    object.Parent = parent
    return object
end



-- Minimap 2D: escala do terreno 3D, marcadores de jogadores atualizados localmente.
local minimap = frame(screen, "Minimap", UDim2.fromOffset(if isTouch then 108 else 142, if isTouch then 108 else 142),
    UDim2.new(1, -14, 0, if isTouch then 110 else 14),
    Color3.fromRGB(48, 110, 62), Vector2.new(1, 0))
minimap.BorderSizePixel = 2
minimap.BorderColor3 = Color3.fromRGB(34, 61, 45)
round(minimap, 5)
-- Mostrar os três biomas no minimapa, não um quadrado verde uniforme.
local miniSnow = frame(minimap, "Snow", UDim2.fromScale(1, 88 / Config.MapSize),
    UDim2.fromScale(0, 0), Color3.fromRGB(204, 228, 234))
local miniDesert = frame(minimap, "Desert", UDim2.fromScale(1, 88 / Config.MapSize),
    UDim2.fromScale(0, 1 - 88 / Config.MapSize), Color3.fromRGB(219, 193, 136))
local mapLabel = label(minimap, "Title", "MAPA", Color3.fromRGB(238, 247, 226))
mapLabel.Position = UDim2.new(.05, 0, 0, 4)
mapLabel.Size = UDim2.new(.9, 0, 0, 15)
local centerDot = frame(minimap, "Spawn", UDim2.fromOffset(5, 5), UDim2.fromScale(.5, .5),
    Color3.fromRGB(104, 219, 255), Vector2.new(.5, .5))
round(centerDot, 3)
local markers = {}
local function updateMinimap()
    local present = {}
    for _, other in ipairs(Players:GetPlayers()) do
        local character = other.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root then
            present[other] = true
            local dot = markers[other]
            if not dot then
                dot = frame(minimap, other.Name .. "Marker", UDim2.fromOffset(7, 7), UDim2.new(),
                    if other == player then Color3.fromRGB(76, 181, 255) else Color3.fromRGB(245, 105, 91),
                    Vector2.new(.5, .5))
                round(dot, 5)
                markers[other] = dot
            end
            dot.Position = UDim2.fromScale(
                math.clamp(.5 + root.Position.X / Config.MapSize, .03, .97),
                math.clamp(.5 + root.Position.Z / Config.MapSize, .03, .97))
        end
    end
    for user, dot in pairs(markers) do
        if not present[user] then dot:Destroy() markers[user] = nil end
    end
end
task.spawn(function()
    while screen.Parent do
        updateMinimap()
        task.wait(.4)
    end
end)

local inventory = frame(screen, "Resources", UDim2.new(0.91, 0, 0, 50),
    UDim2.new(0.5, 0, 0, 12), Color3.fromRGB(34, 42, 36), Vector2.new(0.5, 0))
round(inventory, 8)
local invMax = Instance.new("UISizeConstraint")
invMax.MaxSize = Vector2.new(490, 50)
invMax.Parent = inventory

local resourceOrder = {
    {key = "Food", text = "COMIDA", color = Color3.fromRGB(203, 94, 72)},
    {key = "Wood", text = "MADEIRA", color = Color3.fromRGB(167, 129, 79)},
    {key = "Stone", text = "PEDRA", color = Color3.fromRGB(130, 138, 147)},
    {key = "Gold", text = "OURO", color = Color3.fromRGB(213, 180, 67)},
}
for i, resource in ipairs(resourceOrder) do
    local box = frame(inventory, resource.key, UDim2.new(.25, -5, 1, -8),
        UDim2.new((i - 1) / 4, 4, 0, 4), resource.color)
    round(box, 5)
    local counter = label(box, "Count", "", Color3.new(1, 1, 1))
    counter.Size = UDim2.fromScale(1, 1)
    local function refresh()
        counter.Text = resource.text .. "\n" .. tostring(player:GetAttribute(resource.key) or 0)
    end
    player:GetAttributeChangedSignal(resource.key):Connect(refresh)
    refresh()
end

local ageRoot = frame(screen, "Age", UDim2.new(0.65, 0, 0, 24),
    UDim2.new(0.5, 0, 0, 67), Color3.fromRGB(31, 36, 40), Vector2.new(0.5, 0))
round(ageRoot, 5)
local ageMax = Instance.new("UISizeConstraint")
ageMax.MaxSize = Vector2.new(340, 24)
ageMax.Parent = ageRoot
local ageFill = frame(ageRoot, "Progress", UDim2.new(0, 0, 1, 0),
    UDim2.new(), Color3.fromRGB(104, 197, 111))
round(ageFill, 5)
local ageText = label(ageRoot, "AgeText", "IDADE 1", Color3.fromRGB(255, 255, 255))
ageText.Size = UDim2.fromScale(1, 1)

local notification = label(screen, "Notice", "", Color3.fromRGB(255, 253, 215))
notification.AnchorPoint = Vector2.new(.5, 0)
notification.Size = UDim2.new(.8, 0, 0, 32)
notification.Position = UDim2.new(.5, 0, 0, 105)
notification.TextStrokeTransparency = .3
local noticeNumber = 0
noticeRemote.OnClientEvent:Connect(function(msg)
    if typeof(msg) ~= "string" then return end
    noticeNumber += 1
    local current = noticeNumber
    notification.Text = msg
    task.delay(2.3, function()
        if current == noticeNumber then notification.Text = "" end
    end)
end)

local hotbar = frame(screen, "Hotbar", UDim2.new(.96, 0, 0, 60),
    UDim2.new(.5, 0, 1, if isTouch then -150 else -12),
    Color3.fromRGB(31, 40, 36), Vector2.new(.5, 1))
round(hotbar, 8)
local maxBar = Instance.new("UISizeConstraint")
maxBar.MaxSize = Vector2.new(740, 64)
maxBar.Parent = hotbar
local itemButtons = {}

local function itemUnlocked(itemName)
    local data = Config.Items[itemName]
    return data and (not data.upgrade or player:GetAttribute("Unlock" .. itemName) == true)
end

local function selectItem(name)
    if not itemUnlocked(name) then return end
    selected = name
    actionRemote:FireServer("Select", name)
    for itemName, button in pairs(itemButtons) do
        button.BackgroundColor3 = if itemName == name then Color3.fromRGB(64, 166, 87) else Color3.fromRGB(83, 98, 83)
    end
end

local function refreshHotbar()
    for itemName, button in pairs(itemButtons) do
        local data = Config.Items[itemName]
        local available = itemUnlocked(itemName)
        button.Text = data.label .. (available and "" or "\n🔒")
        button.TextTransparency = available and 0 or .45
        button.BackgroundColor3 = if not available then Color3.fromRGB(55, 61, 60)
            elseif itemName == selected then Color3.fromRGB(64, 166, 87)
            else Color3.fromRGB(83, 98, 83)
    end
    if not itemUnlocked(selected) then selectItem("Hammer") end
end

for i, itemName in ipairs(Config.ItemOrder) do
    local button = Instance.new("TextButton")
    button.Name = itemName
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.fromRGB(245, 248, 241)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.TextWrapped = true
    button.Parent = hotbar
    round(button, 5)
    itemButtons[itemName] = button
    local hotbarNumber = label(button, "Number", tostring(i), Color3.fromRGB(238, 218, 118))
    hotbarNumber.Size = UDim2.fromOffset(12, 13)
    hotbarNumber.Position = UDim2.fromOffset(2, 1)
    button.Activated:Connect(function() selectItem(itemName) end)
    player:GetAttributeChangedSignal("Unlock" .. itemName):Connect(refreshHotbar)
end

local function adjustHotbar()
    local width = hotbar.AbsoluteSize.X
    local slotWidth = math.floor((width - 12 - 8 * 4) / 9)
    for i, itemName in ipairs(Config.ItemOrder) do
        local button = itemButtons[itemName]
        button.Size = UDim2.new(0, slotWidth, 1, -12)
        button.Position = UDim2.new(0, 6 + (i - 1) * (slotWidth + 4), 0, 6)
    end
end
hotbar:GetPropertyChangedSignal("AbsoluteSize"):Connect(adjustHotbar)
task.defer(adjustHotbar)
refreshHotbar()

local upgradePanel = frame(screen, "UpgradeChoice", UDim2.new(.88, 0, 0, 130),
    UDim2.new(.5, 0, .37, 0), Color3.fromRGB(35, 49, 39), Vector2.new(.5, .5))
round(upgradePanel, 10)
local upgradeMax = Instance.new("UISizeConstraint")
upgradeMax.MaxSize = Vector2.new(390, 130)
upgradeMax.Parent = upgradePanel
local prompt = label(upgradePanel, "Title", "ESCOLHA SUA EVOLUÇÃO", Color3.fromRGB(246, 224, 121))
prompt.Size = UDim2.new(.95, 0, 0, 30)
prompt.Position = UDim2.new(.025, 0, 0, 7)
local choices = {}
for i = 1, 2 do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(.46, 0, 0, 66)
    button.Position = UDim2.new(if i == 1 then .025 else .515, 0, 0, 49)
    button.BorderSizePixel = 0
    button.BackgroundColor3 = Color3.fromRGB(112, 136, 84)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = upgradePanel
    round(button, 8)
    choices[i] = button
    button.Activated:Connect(function()
        local name = button:GetAttribute("ItemName")
        if typeof(name) == "string" then actionRemote:FireServer("Upgrade", name) end
    end)
end

local function refreshAge()
    local age = player:GetAttribute("Age") or 1
    local xp = player:GetAttribute("XP") or 0
    local startXP = Config.AgeThresholds[age] or 0
    local endXP = Config.AgeThresholds[age + 1]
    if endXP then
        ageFill.Size = UDim2.fromScale(math.clamp((xp - startXP) / (endXP - startXP), 0, 1), 1)
        ageText.Text = "IDADE " .. age .. "   " .. (xp - startXP) .. "/" .. (endXP - startXP)
    else
        ageFill.Size = UDim2.fromScale(1, 1)
        ageText.Text = "IDADE " .. age
    end

    local pending = player:GetAttribute("PendingUpgrade") or 0
    local set = Config.UpgradeChoices[pending]
    upgradePanel.Visible = set ~= nil
    if set then
        prompt.Text = "IDADE " .. pending .. " — ESCOLHA UM ITEM"
        for i, name in ipairs(set) do
            local button = choices[i]
            button:SetAttribute("ItemName", name)
            button.Text = Config.Items[name].label
        end
    end
end
for _, attr in ipairs({"Age", "XP", "PendingUpgrade"}) do
    player:GetAttributeChangedSignal(attr):Connect(refreshAge)
end
refreshAge()

local hp = label(screen, "Health", "VIDA 100/100", Color3.fromRGB(255, 244, 244))
hp.AnchorPoint = Vector2.new(0, 1)
hp.Position = UDim2.new(0, 14, 1, if isTouch then -150 else -17)
hp.Size = UDim2.new(.3, 0, 0, 25)
hp.TextXAlignment = Enum.TextXAlignment.Left
local function onCharacter(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end
    humanoid.AutoRotate = false
    local function updateHealth()
        hp.Text = "VIDA " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
    end
    humanoid.HealthChanged:Connect(updateHealth)
    updateHealth()
end
player.CharacterAdded:Connect(onCharacter)
if player.Character then task.spawn(onCharacter, player.Character) end

local function getRoot()
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function aimFromScreen(screenPoint)
    local root = getRoot()
    if not root or not viewCamera then return Vector3.new(0, 0, -1) end
    local ray = viewCamera:ViewportPointToRay(screenPoint.X, screenPoint.Y)
    if math.abs(ray.Direction.Y) < .001 then return root.CFrame.LookVector end
    local t = -ray.Origin.Y / ray.Direction.Y
    if t <= 0 then return root.CFrame.LookVector end
    local worldPoint = ray.Origin + ray.Direction * t
    local delta = Vector3.new(worldPoint.X - root.Position.X, 0, worldPoint.Z - root.Position.Z)
    if delta.Magnitude < .1 then return root.CFrame.LookVector end
    return delta.Unit
end

local function currentDirection()
    if rotationLocked then return lockedDirection end
    if isTouch and touchDirection then return touchDirection end
    return aimFromScreen(UserInputService:GetMouseLocation())
end

local function fireUse(item)
    if not itemUnlocked(item) then return end
    local now = os.clock()
    if now - lastFire < Config.UseCooldown then return end
    lastFire = now
    actionRemote:FireServer("Use", item, currentDirection())
end

local function quickFood()
    fireUse(if itemUnlocked("Cookie") then "Cookie" else "Food")
end

local function release()
    held = false
end

local mobileUse
if isTouch then
    mobileUse = Instance.new("TextButton")
    mobileUse.Name = "ActionTouch"
    mobileUse.Size = UDim2.fromOffset(115, 86)
    mobileUse.Position = UDim2.new(1, -126, 1, -106)
    mobileUse.BackgroundColor3 = Color3.fromRGB(164, 98, 66)
    mobileUse.BorderSizePixel = 0
    mobileUse.Text = "USAR"
    mobileUse.TextColor3 = Color3.new(1, 1, 1)
    mobileUse.Font = Enum.Font.GothamBold
    mobileUse.TextScaled = true
    mobileUse.Parent = screen
    round(mobileUse, 12)
    mobileUse.MouseButton1Down:Connect(function()
        held = true
        fireUse(selected)
    end)
    mobileUse.MouseButton1Up:Connect(release)
    mobileUse.MouseLeave:Connect(release)

    local foodButton = Instance.new("TextButton")
    foodButton.Name = "EatTouch"
    foodButton.Size = UDim2.fromOffset(90, 46)
    foodButton.Position = UDim2.new(1, -225, 1, -70)
    foodButton.Text = "COMER"
    foodButton.Font = Enum.Font.GothamBold
    foodButton.TextScaled = true
    foodButton.TextColor3 = Color3.new(1, 1, 1)
    foodButton.BackgroundColor3 = Color3.fromRGB(113, 157, 79)
    foodButton.Parent = screen
    round(foodButton, 9)
    foodButton.Activated:Connect(quickFood)
else
    local hotkeyHelp = label(screen, "Help", "MOUSE: mirar/usar  |  E: automático  |  Q: comer  |  X: travar mira",
        Color3.fromRGB(30, 53, 35))
    hotkeyHelp.AnchorPoint = Vector2.new(.5, 0)
    hotkeyHelp.Position = UDim2.new(.5, 0, 0, 145)
    hotkeyHelp.Size = UDim2.new(.9, 0, 0, 20)
end

local keyItems = {
    [Enum.KeyCode.One] = 1, [Enum.KeyCode.Two] = 2, [Enum.KeyCode.Three] = 3,
    [Enum.KeyCode.Four] = 4, [Enum.KeyCode.Five] = 5, [Enum.KeyCode.Six] = 6,
    [Enum.KeyCode.Seven] = 7, [Enum.KeyCode.Eight] = 8, [Enum.KeyCode.Nine] = 9,
}
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        quickFood()
    elseif input.KeyCode == Enum.KeyCode.E then
        automatic = not automatic
        notification.Text = if automatic then "ATAQUE AUTOMÁTICO LIGADO" else "ATAQUE AUTOMÁTICO DESLIGADO"
    elseif input.KeyCode == Enum.KeyCode.X then
        if not rotationLocked then lockedDirection = currentDirection() end
        rotationLocked = not rotationLocked
    elseif keyItems[input.KeyCode] then
        selectItem(Config.ItemOrder[keyItems[input.KeyCode]])
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.Space then
        held = true
        fireUse(selected)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.Space then
        held = false
    end
end)

-- O movimento móvel continua a utilizar o joystick nativo; arrastar na direita aponta a arma.
if isTouch then
    UserInputService.TouchStarted:Connect(function(input, processed)
        if processed then return end
        local width = if viewCamera then viewCamera.ViewportSize.X else 800
        if input.Position.X > width * .54 then
            touchDirection = aimFromScreen(input.Position)
        end
    end)
    UserInputService.TouchMoved:Connect(function(input, processed)
        if processed then return end
        local width = if viewCamera then viewCamera.ViewportSize.X else 800
        if input.Position.X > width * .54 then
            touchDirection = aimFromScreen(input.Position)
        end
    end)
end

-- Projeção de posicionamento visual; o servidor sempre revalida distância e colisão.
local preview = Instance.new("Part")
preview.Name = "RoMooPlacementPreview"
preview.Anchored = true
preview.Transparency = .48
preview.Material = Enum.Material.ForceField
preview.CanCollide = false
preview.CanTouch = false
preview.CanQuery = false
preview.Color = Color3.fromRGB(90, 230, 114)
preview.Parent = workspace

RunService:BindToRenderStep("RoMooClassicCamera", Enum.RenderPriority.Camera.Value + 1, function()
    local root = getRoot()
    viewCamera = workspace.CurrentCamera
    if not root or not viewCamera then preview.Transparency = 1 return end
    local focus = root.Position + Vector3.new(0, 1, 0)
    viewCamera.CameraType = Enum.CameraType.Scriptable
    viewCamera.FieldOfView = 45
    viewCamera.CFrame = CFrame.lookAt(focus + Vector3.new(0, 105, 14), focus)
    local direction = currentDirection()
    local horizontal = Vector3.new(direction.X, 0, direction.Z)
    if horizontal.Magnitude >= .1 then
        root.CFrame = CFrame.lookAt(root.Position, root.Position + horizontal.Unit)
    end

    if Config.Items[selected].category == "Building" then
        local pos = root.Position + horizontal.Unit * Config.BuildDistance
        preview.Transparency = .5
        if selected == "WoodWall" or selected == "StoneWall" then
            preview.Size = Vector3.new(12, 8, 3)
            local facing = if math.abs(horizontal.X) > math.abs(horizontal.Z) then math.rad(90) else 0
            preview.CFrame = CFrame.new(math.round(pos.X / 3) * 3, 4,
                math.round(pos.Z / 3) * 3) * CFrame.Angles(0, facing, 0)
        else
            preview.Size = Vector3.new(9, 1, 9)
            preview.Position = Vector3.new(math.round(pos.X / 3) * 3, .5,
                math.round(pos.Z / 3) * 3)
        end
    else
        preview.Transparency = 1
    end
    if held or automatic and Config.Items[selected].category == "Weapon" then
        fireUse(selected)
    end
end)

print("[RoMoo io] Barra de 9 itens, câmera elevada, clique/Space, E automático e Q comida.")
