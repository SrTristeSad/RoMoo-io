--!nonstrict
-- Controle de coleta e HUD enxuta; câmera e avatar são os nativos do Roblox.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local remotes = ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Remotes")
local strike = remotes:WaitForChild("Strike")
local feedback = remotes:WaitForChild("Feedback")
local world = workspace:WaitForChild("RoMooWorld")
local resources = world:WaitForChild("Resources")
local holding = false
local previous = -1e8
local cooldown = .43

player.CameraMode = Enum.CameraMode.Classic
player.CameraMinZoomDistance = 7
player.CameraMaxZoomDistance = 20

local ui = Instance.new("ScreenGui")
ui.Name = "RoMooPrototypeHUD"
ui.IgnoreGuiInset = false
ui.ResetOnSpawn = false
ui.DisplayOrder = 10
ui.Parent = player:WaitForChild("PlayerGui")

local function rounded(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local top = Instance.new("Frame")
top.Name = "Inventario"
top.AnchorPoint = Vector2.new(.5, 0)
top.Position = UDim2.new(.5, 0, 0, 8)
top.Size = UDim2.new(.94, 0, 0, 43)
local topSizeLimit = Instance.new("UISizeConstraint")
topSizeLimit.MaxSize = Vector2.new(390, 43)
topSizeLimit.Parent = top
top.BackgroundColor3 = Color3.fromRGB(31, 45, 40)
top.BackgroundTransparency = .12
top.BorderSizePixel = 0
top.Parent = ui
rounded(top, 10)
local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.Padding = UDim.new(0, 4)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Parent = top

for _, entry in ipairs({
    {key = "Wood", title = "MADEIRA", color = Color3.fromRGB(149, 104, 65)},
    {key = "Stone", title = "PEDRA", color = Color3.fromRGB(111, 124, 137)},
    {key = "Gold", title = "OURO", color = Color3.fromRGB(196, 152, 48)},
}) do
    local cell = Instance.new("TextLabel")
    cell.Name = entry.key
    cell.Size = UDim2.new(.315, 0, 0, 34)
    cell.BackgroundColor3 = entry.color
    cell.BorderSizePixel = 0
    cell.TextColor3 = Color3.fromRGB(255, 255, 255)
    cell.TextSize = 14
    cell.Font = Enum.Font.GothamBold
    cell.Parent = top
    rounded(cell, 7)
    local function refresh()
        cell.Text = entry.title .. "  " .. tostring(player:GetAttribute(entry.key) or 0)
    end
    player:GetAttributeChangedSignal(entry.key):Connect(refresh)
    refresh()
end

local hint = Instance.new("TextLabel")
hint.Name = "Dica"
hint.AnchorPoint = Vector2.new(.5, 1)
hint.Position = UDim2.new(.5, 0, 1, -56)
hint.Size = UDim2.new(.94, 0, 0, 30)
local hintMax = Instance.new("UISizeConstraint")
hintMax.MaxSize = Vector2.new(470, 30)
hintMax.Parent = hint
hint.BackgroundColor3 = Color3.fromRGB(28, 41, 38)
hint.BackgroundTransparency = .2
hint.BorderSizePixel = 0
hint.TextColor3 = Color3.fromRGB(247, 248, 239)
hint.Font = Enum.Font.GothamMedium
hint.TextSize = 14
hint.Text = "WASD: andar  •  Mouse: mirar  •  Clique: marreta"
hint.Parent = ui
rounded(hint, 8)

local hover = Instance.new("Highlight")
hover.Name = "RecursoSelecionado"
hover.FillTransparency = 1
hover.OutlineColor = Color3.fromRGB(255, 216, 95)
hover.OutlineTransparency = .1
hover.DepthMode = Enum.HighlightDepthMode.Occluded
hover.Parent = workspace

local labels = {Tree = "ÁRVORE", Rock = "PEDRA", Gold = "OURO"}
local function getRoot()
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function equipped()
    local char = player.Character
    return char and char:FindFirstChild("Marreta") ~= nil
end

local function targetFromPointer()
    local hitPart
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        local camera = workspace.CurrentCamera
        if not camera then return nil end
        local viewport = camera.ViewportSize
        local ray = camera:ViewportPointToRay(viewport.X*.5, viewport.Y*.5)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Include
        params.FilterDescendantsInstances = {resources}
        local result = workspace:Raycast(ray.Origin, ray.Direction * 140, params)
        hitPart = result and result.Instance
    else
        hitPart = mouse.Target
    end
    local model = hitPart and hitPart:FindFirstAncestorOfClass("Model")
    while model and model.Parent ~= resources do
        local ancestor = model.Parent
        if not ancestor then break end
        model = if ancestor:IsA("Model") then ancestor
            else ancestor:FindFirstAncestorOfClass("Model")
    end
    return if model and model.Parent == resources then model else nil
end

local function closeEnough(model)
    local root = getRoot()
    local core = model and model.PrimaryPart
    if not root or not core then return false end
    local dx = root.Position.X - core.Position.X
    local dz = root.Position.Z - core.Position.Z
    return dx*dx + dz*dz <= 17*17
end

local function attack()
    if not equipped() then return end
    local now = os.clock()
    if now - previous < cooldown then return end
    local target = targetFromPointer()
    if target then
        previous = now
        strike:FireServer(target)
    end
end

local connectedTools = setmetatable({}, {__mode = "k"})
local function toolAdded(inst)
    if not inst:IsA("Tool") or inst.Name ~= "Marreta" or connectedTools[inst] then return end
    connectedTools[inst] = true
    inst.Activated:Connect(function()
        -- O Tool nativo informa ao Animate do Roblox a ação de golpear.
        local action = Instance.new("StringValue")
        action.Name = "toolanim"
        action.Value = "Slash"
        action.Parent = inst
        Debris:AddItem(action, .25)
        attack()
    end)
end
local function characterAdded(char)
    holding = false
    local humanoid = char:WaitForChild("Humanoid", 10)
    if humanoid and workspace.CurrentCamera then
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        workspace.CurrentCamera.CameraSubject = humanoid
        workspace.CurrentCamera.FieldOfView = 73
    end
    char.ChildAdded:Connect(toolAdded)
    for _, inst in ipairs(char:GetChildren()) do toolAdded(inst) end
end
player.CharacterAdded:Connect(characterAdded)
if player.Character then task.spawn(characterAdded, player.Character) end

UserInputService.InputBegan:Connect(function(input, consumed)
    if consumed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        holding = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then holding = false end
end)

if UserInputService.TouchEnabled then
    local button = Instance.new("TextButton")
    button.Name = "Golpear"
    button.AnchorPoint = Vector2.new(1, 1)
    button.Position = UDim2.new(1, -20, 1, -95)
    button.Size = UDim2.fromOffset(96, 64)
    button.Text = "GOLPEAR"
    button.Font = Enum.Font.GothamBold
    button.TextSize = 17
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(142, 88, 52)
    button.Parent = ui
    rounded(button, 13)
    button.Activated:Connect(attack)
end

RunService.Heartbeat:Connect(function()
    if holding then attack() end
end)
RunService.RenderStepped:Connect(function()
    local target = targetFromPointer()
    if target and closeEnough(target) then
        hover.Adornee = target
        hint.Text = labels[target.Name] .. "  •  CLIQUE PARA COLETAR"
    elseif target then
        hover.Adornee = nil
        hint.Text = "Aproxime-se para coletar " .. (labels[target.Name] or "recurso")
    else
        hover.Adornee = nil
        hint.Text = "WASD: andar  •  Mouse: mirar  •  Clique: marreta"
    end
end)

feedback.OnClientEvent:Connect(function(kind, position, resourceKind, _broken)
    if kind ~= "Impact" then
        if kind == "Muito longe! Aproxime-se do recurso." then hint.Text = kind end
        return
    end
    if typeof(position) ~= "Vector3" then return end
    local baseColor = if resourceKind == "Tree" then Color3.fromRGB(142, 102, 67)
        else if resourceKind == "Gold" then Color3.fromRGB(244, 196, 68)
        else Color3.fromRGB(156, 166, 170)
    local particles = 4
    for i = 1, particles do
        local frag = Instance.new("Part")
        frag.Name = "RoMooImpactFX"
        frag.Size = Vector3.new(.35, .35, .35)
        frag.Shape = Enum.PartType.Ball
        frag.Material = Enum.Material.Neon
        frag.Color = baseColor
        frag.Anchored = true
        frag.CanCollide = false
        frag.CanTouch = false
        frag.CanQuery = false
        frag.CFrame = CFrame.new(position)
        frag.Parent = workspace
        local angle = i * math.pi * 2 / particles
        TweenService:Create(frag, TweenInfo.new(.34, Enum.EasingStyle.Quad), {
            CFrame = CFrame.new(position + Vector3.new(math.cos(angle)*2, 1.3 + i%3, math.sin(angle)*2)),
            Transparency = 1,
        }):Play()
        Debris:AddItem(frag, .44)
    end
end)

print("[RoMoo 3D] Roblox R15, marreta e coleta por clique inicializados.")
