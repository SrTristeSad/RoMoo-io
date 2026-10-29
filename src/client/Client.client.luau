--!strict
-- Interface simples; o cliente apenas envia intenções, sem controlar inventário ou dano.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("RoMoo")
local remotes = shared:WaitForChild("Remotes")
local actionRemote = remotes:WaitForChild("Action")
local noticeRemote = remotes:WaitForChild("Notice")

local screen = Instance.new("ScreenGui")
screen.Name = "RoMooHUD"
screen.IgnoreGuiInset = true
screen.ResetOnSpawn = false
screen.DisplayOrder = 10
screen.Parent = player:WaitForChild("PlayerGui")

local function rounded(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = frame
end

local function textLabel(name, text, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Name = name
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(249, 249, 249)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextScaled = true
    lbl.Parent = parent
    return lbl
end

local panel = Instance.new("Frame")
panel.Name = "Inventario"
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.Position = UDim2.new(0.5, 0, 0, 14)
panel.Size = UDim2.new(0.94, 0, 0, 55)
panel.BackgroundColor3 = Color3.fromRGB(31, 38, 39)
panel.BackgroundTransparency = 0.12
panel.BorderSizePixel = 0
panel.Parent = screen
rounded(panel, 12)
local sizeLimit = Instance.new("UISizeConstraint")
sizeLimit.MaxSize = Vector2.new(540, 60)
sizeLimit.Parent = panel

local resourceOrder = {
    {key = "Wood", title = "MADEIRA", color = Color3.fromRGB(158, 108, 64)},
    {key = "Stone", title = "PEDRA", color = Color3.fromRGB(126, 136, 140)},
    {key = "Gold", title = "OURO", color = Color3.fromRGB(231, 184, 46)},
    {key = "Food", title = "COMIDA", color = Color3.fromRGB(99, 170, 96)},
}
for i, resource in ipairs(resourceOrder) do
    local tile = Instance.new("Frame")
    tile.Name = resource.key
    tile.Position = UDim2.new((i - 1) / 4, 5, 0, 6)
    tile.Size = UDim2.new(0.25, -10, 1, -12)
    tile.BackgroundColor3 = resource.color
    tile.BorderSizePixel = 0
    tile.Parent = panel
    rounded(tile, 7)

    local value = textLabel("Valor", resource.title .. "\n0", tile)
    value.Size = UDim2.fromScale(1, 1)
    value.TextSize = 18
    local function update()
        value.Text = resource.title .. "\n" .. tostring(player:GetAttribute(resource.key) or 0)
    end
    player:GetAttributeChangedSignal(resource.key):Connect(update)
    update()
end

local help = textLabel("Ajuda", "E: coletar   F: atacar   H: comer   1: parede   2: armadilha", screen)
help.AnchorPoint = Vector2.new(0.5, 0)
help.Position = UDim2.new(0.5, 0, 0, 75)
help.Size = UDim2.new(0.9, 0, 0, 22)
help.TextColor3 = Color3.fromRGB(37, 56, 47)
help.TextStrokeColor3 = Color3.fromRGB(237, 248, 224)
help.TextStrokeTransparency = 0.4
local helpLimit = Instance.new("UISizeConstraint")
helpLimit.MaxSize = Vector2.new(600, 30)
helpLimit.Parent = help
if UserInputService.TouchEnabled then
    help.Text = "Use os botões para coletar, atacar e construir!"
end

local notice = textLabel("Aviso", "", screen)
notice.AnchorPoint = Vector2.new(0.5, 0.5)
notice.Position = UDim2.new(0.5, 0, 0.20, 0)
notice.Size = UDim2.new(0.88, 0, 0, 42)
notice.TextColor3 = Color3.fromRGB(252, 247, 215)
notice.TextStrokeTransparency = 0.1
local noticeSeq = 0
noticeRemote.OnClientEvent:Connect(function(message)
    if typeof(message) ~= "string" then return end
    noticeSeq += 1
    local thisNotice = noticeSeq
    notice.Text = message
    task.delay(2.5, function()
        if thisNotice == noticeSeq then notice.Text = "" end
    end)
end)

local controls = Instance.new("Frame")
controls.Name = "Acoes"
controls.AnchorPoint = Vector2.new(1, 1)
controls.Position = UDim2.new(1, -16, 1, -18)
controls.Size = UDim2.new(0, 266, 0, 108)
controls.BackgroundColor3 = Color3.fromRGB(25, 33, 35)
controls.BackgroundTransparency = 0.2
controls.BorderSizePixel = 0
controls.Parent = screen
rounded(controls, 11)

local actions = {
    { name = "COLETAR", action = "Gather", col = 0, row = 0, color = Color3.fromRGB(62, 136, 81) },
    { name = "ATACAR", action = "Attack", col = 1, row = 0, color = Color3.fromRGB(185, 71, 68) },
    { name = "COMER", action = "Eat", col = 2, row = 0, color = Color3.fromRGB(77, 138, 163) },
    { name = "PAREDE", action = "Wall", col = 0, row = 1, color = Color3.fromRGB(125, 92, 61) },
    { name = "ARMADILHA", action = "Trap", col = 1, row = 1, color = Color3.fromRGB(138, 97, 58) },
}
for _, option in ipairs(actions) do
    local button = Instance.new("TextButton")
    button.Name = option.action
    button.Position = UDim2.new(0, 6 + option.col * 87, 0, 6 + option.row * 50)
    button.Size = UDim2.new(0, 81, 0, 45)
    button.BackgroundColor3 = option.color
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = option.name
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = controls
    rounded(button, 8)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 4)
    pad.Parent = button
    button.Activated:Connect(function()
        actionRemote:FireServer(option.action)
    end)
end

local hotkeys = {
    [Enum.KeyCode.E] = "Gather",
    [Enum.KeyCode.F] = "Attack",
    [Enum.KeyCode.H] = "Eat",
    [Enum.KeyCode.One] = "Wall",
    [Enum.KeyCode.Two] = "Trap",
}
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    local action = hotkeys[input.KeyCode]
    if action then actionRemote:FireServer(action) end
end)

local camera = workspace.CurrentCamera
RunService:BindToRenderStep("RoMooCamera", Enum.RenderPriority.Camera.Value + 1, function()
    if workspace.CurrentCamera ~= camera then camera = workspace.CurrentCamera end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not camera or not root then return end
    local focus = root.Position + Vector3.new(0, 2, 0)
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = CFrame.lookAt(focus + Vector3.new(0, 68, 54), focus)
end)

print("[RoMoo io] HUD e câmera iniciados.")
