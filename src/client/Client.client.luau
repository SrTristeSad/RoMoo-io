--!nonstrict
-- Controle de coleta e HUD enxuta; câmera e avatar são os nativos do Roblox.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local remotes = ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Remotes")
local strike = remotes:WaitForChild("Strike")
local feedback = remotes:WaitForChild("Feedback")
local world = workspace:WaitForChild("RoMooWorld")
local resources = world:WaitForChild("Resources")
local wolves = world:WaitForChild("Wolves")
local holding = false
local previous = -1e8
local cooldown = .43
local clientRayParams = RaycastParams.new()
clientRayParams.FilterType = Enum.RaycastFilterType.Include
clientRayParams.FilterDescendantsInstances = {resources,wolves}
local toolAnimationExpiry = .23

-- Camara elevada ATRAS do avatar, mas ainda terceira pessoa.
-- Mouse livre: o avatar gira para o cursor; botao direito orbita a camera.
player.CameraMode = Enum.CameraMode.Classic
local yaw = 0
local orbitDistance = 21
local rightMouseHeld = false
local cameraWasInitialized = false
local lastTouchPosition = nil
task.defer(function()
    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    end)
end)

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
top.Size = UDim2.new(.96, 0, 0, 43)
local topSizeLimit = Instance.new("UISizeConstraint")
topSizeLimit.MaxSize = Vector2.new(520, 43)
topSizeLimit.Parent = top
top.BackgroundColor3 = Color3.fromRGB(31, 45, 40)
top.BackgroundTransparency = .12
top.BorderSizePixel = 0
top.Parent = ui
rounded(top, 10)
local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 4)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Parent = top

for index, entry in ipairs({
    {key = "Wood", title = "MADEIRA", color = Color3.fromRGB(149, 104, 65)},
    {key = "Stone", title = "PEDRA", color = Color3.fromRGB(111, 124, 137)},
    {key = "Gold", title = "OURO", color = Color3.fromRGB(196, 152, 48)},
    {key = "Food", title = "COMIDA", color = Color3.fromRGB(168, 93, 72)},
}) do
    local cell = Instance.new("TextLabel")
    cell.Name = entry.key
    cell.LayoutOrder = index
    cell.Size = UDim2.new(.242, 0, 0, 34)
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
hint.Text = "WASD: andar  |  Mouse: mirar  |  Direito: camera  |  Clique: coletar"
hint.Parent = ui
rounded(hint, 8)

local hover = Instance.new("Highlight")
hover.Name = "RecursoSelecionado"
hover.FillTransparency = 1
hover.OutlineColor = Color3.fromRGB(255, 216, 95)
hover.OutlineTransparency = .1
hover.DepthMode = Enum.HighlightDepthMode.Occluded
hover.Enabled = false
hover.Parent = workspace

local labels = {Tree = "ÁRVORE", Rock = "PEDRA", Gold = "OURO", Bush = "ARBUSTO", Wolf = "LOBO"}
local function getRoot()
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function equipped()
    local char = player.Character
    return char and char:FindFirstChild("Marreta") ~= nil
end

-- Hit-test direto nos recursos 3D. Mouse.Target pode selecionar Terrain,
-- acessórios e peças decorativas, mas o raio filtrado prioriza o recurso.
local function pointerRay()
    local camera = workspace.CurrentCamera
    if not camera then return nil end
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        local viewport = camera.ViewportSize
        return camera:ViewportPointToRay(viewport.X * .5, viewport.Y * .5)
    end
    -- GetMouseLocation usa pixels da tela, compatíveis com ViewportPointToRay.
    local mousePoint = UserInputService:GetMouseLocation()
    return camera:ViewportPointToRay(mousePoint.X, mousePoint.Y)
end

local function targetFromPointer()
    local ray = pointerRay()
    if not ray then return nil end
    local hit = workspace:Raycast(ray.Origin, ray.Direction * 240, clientRayParams)
    local model = hit and hit.Instance:FindFirstAncestorOfClass("Model")
    while model and model.Parent ~= resources and model.Parent ~= wolves do
        local parent = model.Parent
        if not parent then break end
        model = if parent:IsA("Model") then parent else parent:FindFirstAncestorOfClass("Model")
    end
    return if model and (model.Parent == resources or model.Parent == wolves) then model else nil
end

-- Mirar no solo, na copa das árvores ou nas rochas. O personagem se vira
-- no plano XZ; é a correção da versão em que só andava de frente.
local aimParams = RaycastParams.new()
aimParams.FilterType = Enum.RaycastFilterType.Exclude
local function cursorDirection(root)
    local camera = workspace.CurrentCamera
    local ray = pointerRay()
    if not camera or not ray then return nil end
    local character = player.Character
    aimParams.FilterDescendantsInstances = if character then {character} else {}
    local hit = workspace:Raycast(ray.Origin, ray.Direction * 700, aimParams)
    local point = hit and hit.Position
    if not point and math.abs(ray.Direction.Y) > .005 then
        local t = (root.Position.Y - ray.Origin.Y) / ray.Direction.Y
        if t > 0 then point = ray.Origin + ray.Direction*t end
    end
    local flat = point and Vector3.new(point.X-root.Position.X,0,point.Z-root.Position.Z)
    if flat and flat.Magnitude > .8 then return flat.Unit end
    local forward = camera.CFrame.LookVector
    flat = Vector3.new(forward.X,0,forward.Z)
    return if flat.Magnitude > .02 then flat.Unit else nil
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
    local character = player.Character
    local tool = character and character:FindFirstChild("Marreta")
    if not tool then return end
    local now = os.clock()
    if now - previous < cooldown then return end
    local target = targetFromPointer()
    if target then
        previous = now
        -- Animar cada golpe, inclusive quando o botão fica pressionado.
        local anim = Instance.new("StringValue")
        anim.Name = "toolanim"
        anim.Value = "Slash"
        anim.Parent = tool
        Debris:AddItem(anim, toolAnimationExpiry)
        strike:FireServer(target)
    end
end

local connectedTools = setmetatable({}, {__mode = "k"})
local function toolAdded(inst)
    if not inst:IsA("Tool") or inst.Name ~= "Marreta" or connectedTools[inst] then return end
    connectedTools[inst] = true
    inst.Activated:Connect(attack)
end
local function characterAdded(char)
    holding = false
    local humanoid = char:WaitForChild("Humanoid", 10)
    if humanoid then
        humanoid.AutoRotate = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
        cameraWasInitialized = false
        local camera = workspace.CurrentCamera
        if camera then
            camera.CameraType = Enum.CameraType.Scriptable
            camera.FieldOfView = 68
        end
    end
    char.ChildAdded:Connect(toolAdded)
    for _, inst in ipairs(char:GetChildren()) do toolAdded(inst) end
end
player.CharacterAdded:Connect(characterAdded)
if player.Character then task.spawn(characterAdded, player.Character) end

UserInputService.InputBegan:Connect(function(input, consumed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightMouseHeld = true
        return
    end
    if consumed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        holding = true
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if rightMouseHeld and input.UserInputType == Enum.UserInputType.MouseMovement then
        yaw -= input.Delta.X * .006
    elseif input.UserInputType == Enum.UserInputType.MouseWheel then
        orbitDistance = math.clamp(orbitDistance - input.Position.Z * 2, 12, 32)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then holding = false end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then rightMouseHeld = false end
end)

-- Arrastar na metade direita da tela orbita a câmera em dispositivos móveis.
local touchOrbitInput = nil
local touchLastPosition = nil
UserInputService.TouchStarted:Connect(function(input, processed)
    local camera = workspace.CurrentCamera
    if processed or not camera or touchOrbitInput then return end
    if input.Position.X > camera.ViewportSize.X * .58 then
        touchOrbitInput = input
        touchLastPosition = input.Position
    end
end)
UserInputService.TouchMoved:Connect(function(input)
    if touchOrbitInput ~= input or not touchLastPosition then return end
    local delta = input.Position - touchLastPosition
    yaw -= delta.X * .006
    touchLastPosition = input.Position
end)
UserInputService.TouchEnded:Connect(function(input)
    if touchOrbitInput == input then
        touchOrbitInput = nil
        touchLastPosition = nil
    end
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


-- Mouse e avatar não estão presos à mesma orientação da câmera.
-- O plano do jogo fica mais visível com ângulo alto, mantendo profundidade 3D.
RunService:BindToRenderStep("RoMooCameraAndAim", Enum.RenderPriority.Camera.Value + 1, function(dt)
    local root = getRoot()
    local camera = workspace.CurrentCamera
    if not root or not camera then return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    camera.CameraType = Enum.CameraType.Scriptable
    local forward = Vector3.new(math.sin(yaw),0,-math.cos(yaw))
    local position = root.Position - forward * orbitDistance +
        Vector3.new(0, orbitDistance * .72, 0)
    local target = root.Position + forward * 5 + Vector3.new(0, 1.8, 0)
    local desired = CFrame.lookAt(position, target)
    if not cameraWasInitialized then
        camera.CFrame = desired
        cameraWasInitialized = true
    else
        camera.CFrame = camera.CFrame:Lerp(desired, math.clamp(dt*11, 0, 1))
    end
    camera.Focus = CFrame.new(root.Position)
    if not (UserInputService.TouchEnabled and not UserInputService.MouseEnabled) then
        local aim = cursorDirection(root)
        if aim then
            local facing = CFrame.lookAt(root.Position, root.Position + aim)
            root.CFrame = root.CFrame:Lerp(facing, math.clamp(dt*15, 0, 1))
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if holding then attack() end
end)
RunService.RenderStepped:Connect(function()
    local target = targetFromPointer()
    if target and closeEnough(target) then
        hover.Adornee = target
        hover.Enabled = true
        hint.Text = if target.Parent == wolves then "LOBO • SEGURE PARA ATACAR"
            else (labels[target.Name] or "RECURSO") .. " • SEGURE PARA COLETAR"
        hover.OutlineColor = if target.Parent == wolves
            then Color3.fromRGB(249,95,78) else Color3.fromRGB(255,216,95)
    elseif target then
        hover.Enabled = false
        hover.Adornee = nil
        hint.Text = "Aproxime-se para coletar " .. (labels[target.Name] or "recurso")
    else
        hover.Enabled = false
        hover.Adornee = nil
        hint.Text = "WASD: andar  |  Mouse: mirar  |  Direito: camera  |  Clique: coletar"
    end
end)

-- Indicador flutuante da recompensa, em tela (sem criar Parts persistentes).
local function popupGather(position, kind, amount)
    if typeof(position) ~= "Vector3" or typeof(amount) ~= "number" then return end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local point, onScreen = camera:WorldToScreenPoint(position + Vector3.new(0, 5, 0))
    if not onScreen then return end
    local counter = Instance.new("TextLabel")
    counter.Name = "Coleta"
    counter.AnchorPoint = Vector2.new(.5, .5)
    counter.Size = UDim2.fromOffset(135, 32)
    counter.Position = UDim2.fromOffset(point.X, point.Y)
    counter.BackgroundTransparency = 1
    counter.TextStrokeTransparency = .2
    counter.TextColor3 = if kind == "Gold" then Color3.fromRGB(255, 219, 91)
        else if kind == "Tree" then Color3.fromRGB(189, 244, 158)
        else Color3.fromRGB(230, 237, 243)
    counter.TextSize = 23
    counter.Font = Enum.Font.GothamBold
    counter.Text = "+" .. tostring(amount) .. " " ..
        (if kind == "Tree" then "MADEIRA" else if kind == "Rock" then "PEDRA"
            else if kind == "Gold" then "OURO" else "COMIDA")
    counter.Parent = ui
    TweenService:Create(counter, TweenInfo.new(.64, Enum.EasingStyle.Quad), {
        Position = UDim2.fromOffset(point.X, point.Y - 39),
        TextTransparency = 1,
        TextStrokeTransparency = 1,
    }):Play()
    Debris:AddItem(counter, .7)
end

feedback.OnClientEvent:Connect(function(kind, position, resourceKind, _broken)
    if kind == "Gather" then
        popupGather(position, resourceKind, _broken)
        return
    end
    if kind ~= "Impact" then
        if kind == "Muito longe! Aproxime-se do recurso." then hint.Text = kind end
        return
    end
    if typeof(position) ~= "Vector3" then return end
    local baseColor = if resourceKind == "Tree" then Color3.fromRGB(142, 102, 67)
        else if resourceKind == "Gold" then Color3.fromRGB(244, 196, 68)
        else if resourceKind == "Wolf" then Color3.fromRGB(229, 96, 75)
        else if resourceKind == "Bush" then Color3.fromRGB(98, 185, 99)
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
