--!nonstrict
-- Controles de estilo .io: mouse mira, clique/Space usa item, E auto-ataque, Q comida.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local remotes = ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Remotes")
local actionRemote = remotes:WaitForChild("Action")
local noticeRemote = remotes:WaitForChild("Notice")
local FX = require(script.Parent:WaitForChild("Effects"))
FX.start(remotes:WaitForChild("FX"))
local isTouch = UserInputService.TouchEnabled
local selected = "Hammer"
local held = false
local automatic = false
local lastFire = {Primary = -1e8, Food = -1e8}
local rotationLocked = false
local lockedDirection = Vector3.new(0, 0, -1)
local touchDirection = nil
local viewCamera = workspace.CurrentCamera
player.CameraMode = Enum.CameraMode.Classic
player.CameraMinZoomDistance = 12
player.CameraMaxZoomDistance = 24
task.defer(function()
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false) end)
end)

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
local minimap = frame(screen, "Minimap", UDim2.fromOffset(if isTouch then 88 else 104, if isTouch then 88 else 104),
    UDim2.new(1, -8, 0, if isTouch then 72 else 9),
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
            local allyCode = player:GetAttribute("ClanCode")
            dot.BackgroundColor3 = if other == player then Color3.fromRGB(76, 181, 255)
                else if allyCode and allyCode ~= "" and other:GetAttribute("ClanCode") == allyCode
                    then Color3.fromRGB(100, 236, 128) else Color3.fromRGB(245, 105, 91)
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

local inventory = frame(screen, "Resources", UDim2.new(.68, 0, 0, 36),
    UDim2.new(0.5, 0, 0, 8), Color3.fromRGB(34, 42, 36), Vector2.new(0.5, 0))
round(inventory, 8)
local invMax = Instance.new("UISizeConstraint")
invMax.MaxSize = Vector2.new(460, 36)
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
    counter.TextScaled = false
    counter.TextSize = if isTouch then 11 else 13
    local function refresh()
        counter.Text = resource.text .. " " .. tostring(player:GetAttribute(resource.key) or 0)
    end
    player:GetAttributeChangedSignal(resource.key):Connect(refresh)
    refresh()
end

local ageRoot = frame(screen, "Age", UDim2.new(.62, 0, 0, 19),
    UDim2.new(0.5, 0, 0, 51), Color3.fromRGB(31, 36, 40), Vector2.new(0.5, 0))
round(ageRoot, 5)
local ageMax = Instance.new("UISizeConstraint")
ageMax.MaxSize = Vector2.new(350, 19)
ageMax.Parent = ageRoot
local ageFill = frame(ageRoot, "Progress", UDim2.new(0, 0, 1, 0),
    UDim2.new(), Color3.fromRGB(104, 197, 111))
round(ageFill, 5)
local ageText = label(ageRoot, "AgeText", "IDADE 1", Color3.fromRGB(255, 255, 255))
ageText.Size = UDim2.fromScale(1, 1)
ageText.TextScaled = false
ageText.TextSize = 12

local notification = label(screen, "Notice", "", Color3.fromRGB(255, 253, 215))
notification.AnchorPoint = Vector2.new(.5, 0)
notification.Size = UDim2.new(.7, 0, 0, 23)
notification.Position = UDim2.new(.5, 0, 0, 79)
notification.TextScaled = false
notification.TextSize = 14
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

-- Painel recolhível de clãs (não ocupa espaço durante o combate).
local clanToggle = Instance.new("TextButton")
clanToggle.Name = "ClanToggle"
clanToggle.Position = UDim2.fromOffset(12, 93)
clanToggle.Size = UDim2.fromOffset(110, 28)
clanToggle.TextScaled = false
clanToggle.TextSize = 13
clanToggle.Text = "CLÃ: SOLO"
clanToggle.TextColor3 = Color3.fromRGB(252, 252, 243)
clanToggle.TextScaled = true
clanToggle.Font = Enum.Font.GothamBold
clanToggle.BorderSizePixel = 0
clanToggle.BackgroundColor3 = Color3.fromRGB(46, 84, 59)
clanToggle.Parent = screen
round(clanToggle, 8)

local clanPanel = frame(screen, "ClanPanel", UDim2.fromOffset(248, 160),
    UDim2.fromOffset(12, 128), Color3.fromRGB(29, 44, 36))
clanPanel.Visible = false
round(clanPanel, 8)
local clanStatus = label(clanPanel, "Status", "Você está sozinho", Color3.fromRGB(231, 239, 226))
clanStatus.Size = UDim2.new(1, -14, 0, 33)
clanStatus.Position = UDim2.fromOffset(7, 6)

local clanInput = Instance.new("TextBox")
clanInput.Name = "ClanCodeInput"
clanInput.Position = UDim2.fromOffset(10, 42)
clanInput.Size = UDim2.new(1, -20, 0, 35)
clanInput.PlaceholderText = "CÓDIGO NUMÉRICO (6 DÍGITOS)"
clanInput.Text = ""
clanInput.ClearTextOnFocus = false
clanInput.TextColor3 = Color3.fromRGB(255, 255, 255)
clanInput.PlaceholderColor3 = Color3.fromRGB(181, 201, 186)
clanInput.BackgroundColor3 = Color3.fromRGB(57, 76, 62)
clanInput.TextScaled = true
clanInput.Font = Enum.Font.Gotham
clanInput.Parent = clanPanel
round(clanInput, 6)

local clanActions = {
    {text = "CRIAR", action = "ClanCreate"},
    {text = "ENTRAR", action = "ClanJoin"},
    {text = "SAIR", action = "ClanLeave"},
}
for i, spec in ipairs(clanActions) do
    local button = Instance.new("TextButton")
    button.Name = spec.action
    button.Size = UDim2.fromOffset(72, 40)
    button.Position = UDim2.fromOffset(9 + (i - 1) * 79, 92)
    button.BorderSizePixel = 0
    button.BackgroundColor3 = if i == 3 then Color3.fromRGB(130, 73, 71)
        else Color3.fromRGB(76, 133, 86)
    button.Text = spec.text
    button.Font = Enum.Font.GothamBold
    button.TextScaled = true
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Parent = clanPanel
    round(button, 5)
    button.Activated:Connect(function()
        actionRemote:FireServer(spec.action, clanInput.Text)
    end)
end
local clanHint = label(clanPanel, "Hint", "Compartilhe o código com os amigos",
    Color3.fromRGB(172, 193, 168))
clanHint.Size = UDim2.new(1, -14, 0, 20)
clanHint.Position = UDim2.fromOffset(7, 137)

clanToggle.Activated:Connect(function()
    clanPanel.Visible = not clanPanel.Visible
end)
local function refreshClan()
    local code = player:GetAttribute("ClanCode")
    local count = player:GetAttribute("ClanMembers") or 0
    if typeof(code) == "string" and code ~= "" then
        clanToggle.Text = "CLÃ: " .. code
        clanStatus.Text = code .. " | " .. count .. "/8 jogadores" ..
            (if player:GetAttribute("ClanLeader") then " | LÍDER" else "")
    else
        clanToggle.Text = "CLÃ: SOLO"
        clanStatus.Text = "Sem clã nesta partida"
    end
end
for _, attribute in ipairs({"ClanCode", "ClanMembers", "ClanLeader"}) do
    player:GetAttributeChangedSignal(attribute):Connect(refreshClan)
end
refreshClan()

-- Itens obtidos permanecem visíveis; a barra ganha linhas, não cria um menu oculto.
local hotbar = frame(screen, "Hotbar", UDim2.new(.91, 0, 0, 49),
    UDim2.new(.5, 0, 1, if isTouch then -138 else -9),
    Color3.fromRGB(31, 40, 36), Vector2.new(.5, 1))
round(hotbar, 8)
local maxBar = Instance.new("UISizeConstraint")
maxBar.MaxSize = Vector2.new(730, 165)
maxBar.Parent = hotbar

local itemButtons = {}
local visibleItems = {}
local adjustHotbar

local keyLabels = {"1","2","3","4","5","6","7","8","9","0","-","=","R","T"}
local function itemUnlocked(itemName)
    local data = Config.Items[itemName]
    if not data then return false end
    if data.minAge then return (player:GetAttribute("Age") or 1) >= data.minAge end
    return not data.upgrade or player:GetAttribute("Unlock" .. itemName) == true
end

local function selectItem(name)
    if not itemUnlocked(name) then return end
    selected = name
    actionRemote:FireServer("Select", name)
    for itemName, button in pairs(itemButtons) do
        button.BackgroundColor3 = if itemName == name
            then Color3.fromRGB(64, 166, 87) else Color3.fromRGB(83, 98, 83)
    end
end

local function refreshHotbar()
    table.clear(visibleItems)
    for _, itemName in ipairs(Config.ItemOrder) do
        local button = itemButtons[itemName]
        local active = itemUnlocked(itemName)
        button.Visible = active
        if active then
            table.insert(visibleItems, itemName)
            local labelText = Config.Items[itemName].label
            button.Text = if isTouch then string.sub(labelText, 1, 10) else labelText
        end
        button.BackgroundColor3 = if itemName == selected
            then Color3.fromRGB(64, 166, 87) else Color3.fromRGB(83, 98, 83)
    end
    if not itemUnlocked(selected) then selectItem("Hammer") end
    if adjustHotbar then adjustHotbar() end
end
player:GetAttributeChangedSignal("Age"):Connect(refreshHotbar)

for _, itemName in ipairs(Config.ItemOrder) do
    local button = Instance.new("TextButton")
    button.Name = itemName
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.fromRGB(245, 248, 241)
    button.TextScaled = false
    button.TextSize = if isTouch then 10 else 12
    button.Font = Enum.Font.GothamBold
    button.TextWrapped = true
    button.Parent = hotbar
    round(button, 5)
    itemButtons[itemName] = button
    local hint = label(button, "Number", "", Color3.fromRGB(238, 218, 118))
    hint.Size = UDim2.fromOffset(13, 13)
    hint.Position = UDim2.fromOffset(2, 1)
    button.Activated:Connect(function() selectItem(itemName) end)
    if Config.Items[itemName].upgrade then
        player:GetAttributeChangedSignal("Unlock" .. itemName):Connect(refreshHotbar)
    end
end

adjustHotbar = function()
    local width = hotbar.AbsoluteSize.X
    if width < 1 then return end
    local columns = if width < 480 then 5 else if width < 660 then 7 else 9
    local rows = math.max(1, math.ceil(#visibleItems / columns))
    local cellH = if isTouch then 36 else 41
    local height = rows * (cellH + 4) + 8
    hotbar.Size = UDim2.new(.96, 0, 0, height)
    local cellW = math.floor((width - 12 - (columns - 1) * 4) / columns)
    for i, itemName in ipairs(visibleItems) do
        local button = itemButtons[itemName]
        local row = math.floor((i - 1) / columns)
        local col = (i - 1) % columns
        button.Size = UDim2.fromOffset(cellW, cellH)
        button.Position = UDim2.fromOffset(6 + col * (cellW + 4), 4 + row * (cellH + 4))
        local hint = button:FindFirstChild("Number")
        if hint then hint.Text = keyLabels[i] or "" end
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
hp.Position = UDim2.new(0, 14, 1, if isTouch then -235 else -87)
hp.Size = UDim2.new(.25, 0, 0, 21)
hp.TextScaled = false
hp.TextSize = 15
hp.TextXAlignment = Enum.TextXAlignment.Left
local function onCharacter(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end
    humanoid.AutoRotate = false
    humanoid.CameraOffset = Vector3.new(0, 1.7, 0)
    viewCamera = workspace.CurrentCamera
    if viewCamera then
        viewCamera.CameraType = Enum.CameraType.Custom
        viewCamera.CameraSubject = humanoid
        viewCamera.FieldOfView = 70
    end
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

-- Seleção de alvo pelo cursor da câmera 3D, sem a projeção 2D antiga.
local function aimFromScreen(screenPoint)
    local root = getRoot()
    viewCamera = workspace.CurrentCamera
    if not root or not viewCamera then return Vector3.new(0, 0, -1) end
    local ray = viewCamera:ViewportPointToRay(screenPoint.X, screenPoint.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    if player.Character then params.FilterDescendantsInstances = {player.Character} end
    local result = workspace:Raycast(ray.Origin, ray.Direction * 700, params)
    local target = result and result.Position
    if not target and ray.Direction.Y < -.01 then
        local t = (root.Position.Y - ray.Origin.Y) / ray.Direction.Y
        if t > 0 then target = ray.Origin + ray.Direction * t end
    end
    if target then
        local delta = Vector3.new(target.X - root.Position.X, 0, target.Z - root.Position.Z)
        if delta.Magnitude > .2 then return delta.Unit end
    end
    local forward = Vector3.new(viewCamera.CFrame.LookVector.X, 0, viewCamera.CFrame.LookVector.Z)
    return if forward.Magnitude > .01 then forward.Unit else root.CFrame.LookVector
end

local function currentDirection()
    if rotationLocked then return lockedDirection end
    if isTouch and touchDirection then return touchDirection end
    return aimFromScreen(UserInputService:GetMouseLocation())
end

local function fireUse(item)
    if not itemUnlocked(item) then return end
    local now = os.clock()
    local slot = if Config.Items[item].category == "Food" then "Food" else "Primary"
    local interval = if slot == "Food" then Config.EatCooldown
        else Config.Items[item].cooldown or Config.UseCooldown
    if now - lastFire[slot] < interval then return end
    lastFire[slot] = now
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
    local hotkeyHelp = label(screen, "Help", "Clique: coletar | Segure: golpear | Q: comer | E: automático | H: ajuda",
        Color3.fromRGB(246, 247, 240))
    hotkeyHelp.AnchorPoint = Vector2.new(.5, 0)
    hotkeyHelp.Position = UDim2.new(.5, 0, 0, 108)
    hotkeyHelp.Size = UDim2.new(.85, 0, 0, 19)
    hotkeyHelp.TextScaled = false
    hotkeyHelp.TextSize = 12
    task.delay(7, function()
        if hotkeyHelp.Parent then hotkeyHelp.Visible = false end
    end)
    UserInputService.InputBegan:Connect(function(key, processed)
        if not processed and key.KeyCode == Enum.KeyCode.H then
            hotkeyHelp.Visible = not hotkeyHelp.Visible
        end
    end)
end

local keyItems = {
    [Enum.KeyCode.One] = 1, [Enum.KeyCode.Two] = 2, [Enum.KeyCode.Three] = 3,
    [Enum.KeyCode.Four] = 4, [Enum.KeyCode.Five] = 5, [Enum.KeyCode.Six] = 6,
    [Enum.KeyCode.Seven] = 7, [Enum.KeyCode.Eight] = 8, [Enum.KeyCode.Nine] = 9,
    [Enum.KeyCode.Zero] = 10, [Enum.KeyCode.Minus] = 11, [Enum.KeyCode.Equals] = 12,
    [Enum.KeyCode.R] = 13, [Enum.KeyCode.T] = 14,
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
        local chosen = visibleItems[keyItems[input.KeyCode]]
        if chosen then selectItem(chosen) end
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

RunService:BindToRenderStep("RoMooThirdPerson", Enum.RenderPriority.Camera.Value + 1, function()
    local root = getRoot()
    viewCamera = workspace.CurrentCamera
    if not root or not viewCamera then preview.Transparency = 1 return end
    local direction = currentDirection()
    local horizontal = Vector3.new(direction.X, 0, direction.Z)
    if horizontal.Magnitude >= .1 then
        root.CFrame = root.CFrame:Lerp(CFrame.lookAt(root.Position, root.Position + horizontal.Unit), .25)
    end

    if Config.Items[selected].category == "Building" then
        local pos = root.Position + horizontal.Unit * Config.BuildDistance
        preview.Transparency = .5
        if selected == "WoodWall" or selected == "StoneWall" or selected == "CastleWall" then
            local fortress = selected == "CastleWall"
            preview.Size = if fortress then Vector3.new(13, 11, 4) else Vector3.new(12, 8, 3)
            local facing = if math.abs(horizontal.X) > math.abs(horizontal.Z) then math.rad(90) else 0
            preview.CFrame = CFrame.new(math.round(pos.X / 3) * 3, if fortress then 5.5 else 4,
                math.round(pos.Z / 3) * 3) * CFrame.Angles(0, facing, 0)
        elseif Config.Items[selected].goldPerTick then
            local isGold = selected == "GoldMill"
            preview.Size = Vector3.new(5, if isGold then 15 else 12, 5)
            preview.Position = Vector3.new(math.round(pos.X / 3) * 3,
                if isGold then 7.5 else 6, math.round(pos.Z / 3) * 3)
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

print("[RoMoo io] Camera terceira pessoa, mira 3D, HUD compacta e hotbar dinamica.")
