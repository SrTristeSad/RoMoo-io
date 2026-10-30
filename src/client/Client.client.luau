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
local build = remotes:WaitForChild("Build")
local selectWeapon = remotes:WaitForChild("SelectWeapon")
local Config = require(ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local eat = remotes:WaitForChild("Eat")
local world = workspace:WaitForChild("RoMooWorld")
local resources = world:WaitForChild("Resources")
local wolves = world:WaitForChild("Wolves")
local buildings = world:WaitForChild("Buildings")
local holding = false
local previous = -1e8
local cooldown = .43
local lastWeaponSelection = "Hammer"
local selectedMode = "Hammer"
local clientRayParams = RaycastParams.new()
clientRayParams.FilterType = Enum.RaycastFilterType.Include
local function updateRayTargets()
    local targets={resources,wolves,buildings}
    for _,other in ipairs(Players:GetPlayers()) do
        if other~=player and other.Character then table.insert(targets,other.Character) end
    end
    clientRayParams.FilterDescendantsInstances=targets
end
local function watchPlayer(other)
    if other==player then return end
    other.CharacterAdded:Connect(updateRayTargets)
    other.CharacterRemoving:Connect(updateRayTargets)
end
Players.PlayerAdded:Connect(function(other)
    watchPlayer(other)
    updateRayTargets()
end)
Players.PlayerRemoving:Connect(updateRayTargets)
for _,other in ipairs(Players:GetPlayers()) do watchPlayer(other) end
updateRayTargets()
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
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
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

-- Progresso de idade: dados replicados pelo servidor, nunca calculados no cliente.
local xpPanel=Instance.new("Frame")
xpPanel.Name="ProgressoIdade"
xpPanel.AnchorPoint=Vector2.new(.5,0)
xpPanel.Position=UDim2.new(.5,0,0,55)
xpPanel.Size=UDim2.new(.9,0,0,25)
xpPanel.BackgroundColor3=Color3.fromRGB(34,44,39)
xpPanel.BackgroundTransparency=.08
xpPanel.BorderSizePixel=0
xpPanel.Parent=ui
rounded(xpPanel,7)
local xpLimit=Instance.new("UISizeConstraint")
xpLimit.MaxSize=Vector2.new(500,25)
xpLimit.Parent=xpPanel
local xpFill=Instance.new("Frame")
xpFill.Name="XPFill"
xpFill.Size=UDim2.fromScale(0,1)
xpFill.BackgroundColor3=Color3.fromRGB(90,191,112)
xpFill.BorderSizePixel=0
xpFill.Parent=xpPanel
rounded(xpFill,7)
local xpText=Instance.new("TextLabel")
xpText.Name="XPTexto"
xpText.Size=UDim2.fromScale(1,1)
xpText.BackgroundTransparency=1
xpText.TextColor3=Color3.new(1,1,1)
xpText.TextStrokeTransparency=.55
xpText.TextSize=13
xpText.Font=Enum.Font.GothamBold
xpText.Text="IDADE 1   0/100 XP"
xpText.Parent=xpPanel
-- Placar da partida para o jogador local.
local matchStats=Instance.new("TextLabel")
matchStats.Name="AbatesMortes"
matchStats.AnchorPoint=Vector2.new(1,0)
matchStats.Position=UDim2.new(1,-12,0,88)
matchStats.Size=UDim2.fromOffset(155,25)
matchStats.BackgroundColor3=Color3.fromRGB(32,45,42)
matchStats.BackgroundTransparency=.12
matchStats.BorderSizePixel=0
matchStats.TextColor3=Color3.fromRGB(244,245,234)
matchStats.TextSize=12
matchStats.Font=Enum.Font.GothamBold
matchStats.Parent=ui
rounded(matchStats,7)
local function refreshMatchStats()
    matchStats.Text=("ABATES %d  |  MORTES %d"):format(
        player:GetAttribute("Kills") or 0, player:GetAttribute("Deaths") or 0)
end
player:GetAttributeChangedSignal("Kills"):Connect(refreshMatchStats)
player:GetAttributeChangedSignal("Deaths"):Connect(refreshMatchStats)
refreshMatchStats()

local function refreshXP()
    local age=player:GetAttribute("Age") or 1
    local experience=player:GetAttribute("XP") or 0
    local required=player:GetAttribute("XPToNext") or 100
    xpText.Text=if required<=0 then ("IDADE "..age.."  MAX")
        else ("IDADE "..age.."  "..experience.."/"..required.." XP")
    xpFill.Size=UDim2.fromScale(if required<=0 then 1
        else math.clamp(experience/math.max(1,required),0,1),1)
end
for _,attribute in ipairs({"Age","XP","XPToNext"}) do
    player:GetAttributeChangedSignal(attribute):Connect(refreshXP)
end
refreshXP()

-- Hotbar de construções: a marreta segue equipada; trocar de slot muda
-- apenas o comando enviado. O servidor valida custos e local da construção.
local buildBar = Instance.new("ScrollingFrame")
buildBar.Name = "BarraConstrucoes"
buildBar.AnchorPoint = Vector2.new(.5,1)
buildBar.Position = UDim2.new(.5,0,1,-113)
buildBar.Size = UDim2.new(.96,0,0,54)
buildBar.CanvasSize = UDim2.fromOffset(0,0)
buildBar.AutomaticCanvasSize = Enum.AutomaticSize.X
buildBar.ScrollingDirection = Enum.ScrollingDirection.X
buildBar.ScrollBarThickness = 3
buildBar.BorderSizePixel = 0
buildBar.BackgroundColor3 = Color3.fromRGB(29,42,37)
buildBar.BackgroundTransparency = .08
buildBar.BorderSizePixel = 0
buildBar.Parent = ui
rounded(buildBar,9)
local widthLimit = Instance.new("UISizeConstraint")
widthLimit.MaxSize = Vector2.new(790,54)
widthLimit.Parent = buildBar
local barLayout = Instance.new("UIListLayout")
barLayout.FillDirection = Enum.FillDirection.Horizontal
barLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
barLayout.VerticalAlignment = Enum.VerticalAlignment.Center
barLayout.Padding = UDim.new(0,4)
barLayout.SortOrder = Enum.SortOrder.LayoutOrder
barLayout.Parent = buildBar
local choices = {
    {mode="Hammer",label="1 MARRETA"},
    {mode="Wall",label="2 PAREDE 10M"},
    {mode="Spikes",label="3 ESPINHOS 20M/5P"},
    {mode="Windmill",label="4 MOINHO 50M/10P"},
    {mode="StoneWall",label="5 MURO PEDRA 30P/10M"},
    {mode="Axe",label="6 MACHADO"},
    {mode="Sword",label="7 ESPADA"},
}
local buttons = {}
local function setMode(mode,skipRemote)
    local blueprint=Config.Buildings[mode] or Config.Weapons[mode]
    if not blueprint then return end
    local age=player:GetAttribute("Age") or 1
    if age<(blueprint.minAge or 1) then return end
    selectedMode=mode
    if Config.Weapons[mode] then
        lastWeaponSelection=mode
        if not skipRemote then selectWeapon:FireServer(mode) end
    end
    for _,choice in ipairs(choices) do
        local button=buttons[choice.mode]
        local data=Config.Buildings[choice.mode] or Config.Weapons[choice.mode]
        local unlocked=not data or age >= (data.minAge or 1)
        if button then
            button.Text=if unlocked then choice.label
                else ("IDADE "..tostring(data.minAge).." - "..choice.label)
            button.BackgroundColor3=if not unlocked then Color3.fromRGB(62,64,65)
                else if choice.mode==mode then Color3.fromRGB(60,158,92)
                else Color3.fromRGB(77,87,81)
            button.TextColor3=if unlocked then Color3.new(1,1,1)
                else Color3.fromRGB(178,181,179)
        end
    end
end
for i,item in ipairs(choices) do
    local button=Instance.new("TextButton")
    button.Name=item.mode
    button.LayoutOrder=i
    button.Size=UDim2.fromOffset(107,44)
    button.BackgroundColor3=Color3.fromRGB(77,87,81)
    button.BorderSizePixel=0
    button.TextColor3=Color3.new(1,1,1)
    button.TextSize=11
    button.TextWrapped=true
    button.Font=Enum.Font.GothamBold
    button.Text=item.label
    button.Parent=buildBar
    rounded(button,6)
    buttons[item.mode]=button
    button.Activated:Connect(function()
        setMode(item.mode)
    end)
end
setMode("Hammer",true)
player:GetAttributeChangedSignal("Age"):Connect(function()
    local blueprint = Config.Weapons[selectedMode] or Config.Buildings[selectedMode]
    local age = player:GetAttribute("Age") or 1
    if blueprint and age < (blueprint.minAge or 1) then
        -- Quando a idade reinicia, voltar para arma realmente disponivel.
        setMode("Hammer",true)
    else
        setMode(selectedMode,true)
    end
end)
player:GetAttributeChangedSignal("WeaponId"):Connect(function()
    local serverWeapon=player:GetAttribute("WeaponId")
    if Config.Weapons[serverWeapon] then
        lastWeaponSelection=serverWeapon
        if Config.Weapons[selectedMode] then setMode(serverWeapon,true) end
    end
end)
local preview = Instance.new("Part")
preview.Name = "RoMooBuildPreview"
preview.Anchored = true
preview.CanCollide = false
preview.CanTouch = false
preview.CanQuery = false
preview.Material = Enum.Material.ForceField
preview.Transparency = 1
preview.Parent = workspace
local previewElapsed = 0

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
hint.Text = "WASD: andar | Mouse: mirar | Clique: golpear | Q: curar"
hint.Parent = ui
rounded(hint, 8)

-- Barra de vida essencial ao enfrentar lobos.
local healthPanel = Instance.new("Frame")
healthPanel.Name = "Vida"
healthPanel.AnchorPoint = Vector2.new(0,1)
healthPanel.Position = UDim2.new(0,14,1,-171)
healthPanel.Size = UDim2.fromOffset(190,32)
healthPanel.BackgroundColor3 = Color3.fromRGB(32,44,41)
healthPanel.BackgroundTransparency = .13
healthPanel.BorderSizePixel = 0
healthPanel.Parent = ui
rounded(healthPanel,7)
local hpBarBack = Instance.new("Frame")
hpBarBack.Name = "HealthTrack"
hpBarBack.Position = UDim2.fromOffset(7,21)
hpBarBack.Size = UDim2.new(1,-14,0,6)
hpBarBack.BackgroundColor3 = Color3.fromRGB(78,74,74)
hpBarBack.BorderSizePixel = 0
hpBarBack.Parent = healthPanel
rounded(hpBarBack,4)
local hpBar = Instance.new("Frame")
hpBar.Name = "HealthFill"
hpBar.Size = UDim2.fromScale(1,1)
hpBar.BackgroundColor3 = Color3.fromRGB(82,196,98)
hpBar.BorderSizePixel = 0
hpBar.Parent = hpBarBack
rounded(hpBar,4)
local hpText = Instance.new("TextLabel")
hpText.Name = "HealthText"
hpText.Size = UDim2.new(1,-14,0,18)
hpText.Position = UDim2.fromOffset(7,2)
hpText.BackgroundTransparency = 1
hpText.TextColor3 = Color3.fromRGB(245,247,237)
hpText.TextSize = 13
hpText.Font = Enum.Font.GothamBold
hpText.TextXAlignment = Enum.TextXAlignment.Left
hpText.Text = "VIDA 100/100"
hpText.Parent = healthPanel

local hover = Instance.new("Highlight")
hover.Name = "RecursoSelecionado"
hover.FillTransparency = 1
hover.OutlineColor = Color3.fromRGB(255, 216, 95)
hover.OutlineTransparency = .1
hover.DepthMode = Enum.HighlightDepthMode.Occluded
hover.Enabled = false
hover.Parent = workspace

local labels = {
    Tree="ÁRVORE",Rock="PEDRA",Gold="OURO",Bush="ARBUSTO",Wolf="LOBO",
    Wall="PAREDE",Spikes="ESPINHOS",Windmill="MOINHO",StoneWall="MURO DE PEDRA",
}
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
    while model and model.Parent ~= resources and model.Parent ~= wolves
        and model.Parent ~= buildings and not Players:GetPlayerFromCharacter(model) do
        local parent = model.Parent
        if not parent then break end
        model = if parent:IsA("Model") then parent else parent:FindFirstAncestorOfClass("Model")
    end
    return if model and (model.Parent == resources or model.Parent == wolves
        or model.Parent == buildings or (
            Players:GetPlayerFromCharacter(model) and model ~= player.Character))
        then model else nil
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
    local weapon=Config.Weapons[selectedMode] or Config.Weapons.Hammer
    return dx*dx + dz*dz <= weapon.range*weapon.range
end

local function attack()
    local character = player.Character
    local tool = character and character:FindFirstChild("Marreta")
    local root = getRoot()
    if not tool or not root then return end
    local now = os.clock()
    local weapon=Config.Weapons[selectedMode]
    local delayTime=if weapon then weapon.cooldown else Config.BuildCooldown
    if now - previous < delayTime then return end
    -- Mira envia apenas DIRECAO, nunca Model, HP ou recompensa.
    -- O servidor procura recursos/lobos no cone frontal.
    local direction = cursorDirection(root)
    if not direction or direction.Magnitude < .7 then return end
    previous = now
    if not weapon then
        build:FireServer(selectedMode,direction.Unit)
        return
    end
    local anim = Instance.new("StringValue")
    anim.Name = "toolanim"
    anim.Value = "Slash"
    anim.Parent = tool
    Debris:AddItem(anim, toolAnimationExpiry)
    strike:FireServer(direction.Unit)
end

local function consumeFood()
    eat:FireServer()
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
        local function refreshHP()
            local maxHP=math.max(1,humanoid.MaxHealth)
            local ratio=math.clamp(humanoid.Health/maxHP,0,1)
            hpText.Text=("VIDA %d/%d"):format(math.ceil(humanoid.Health),math.ceil(maxHP))
            hpBar.Size=UDim2.fromScale(ratio,1)
            hpBar.BackgroundColor3=if ratio<.33 then Color3.fromRGB(215,75,66)
                else if ratio<.65 then Color3.fromRGB(228,169,68)
                else Color3.fromRGB(82,196,98)
        end
        humanoid.HealthChanged:Connect(refreshHP)
        humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(refreshHP)
        refreshHP()
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
    if input.KeyCode == Enum.KeyCode.Q then consumeFood() end
    local hotkeys={
        [Enum.KeyCode.One]="Hammer",
        [Enum.KeyCode.Two]="Wall",
        [Enum.KeyCode.Three]="Spikes",
        [Enum.KeyCode.Four]="Windmill",
        [Enum.KeyCode.Five]="StoneWall",
        [Enum.KeyCode.Six]="Axe",
        [Enum.KeyCode.Seven]="Sword",
    }
    local choice=hotkeys[input.KeyCode]
    if choice then setMode(choice) return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if Config.Weapons[selectedMode] then
            holding=true
        else
            attack()
        end
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
    button.Name = "Acao"
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
    RunService.RenderStepped:Connect(function()
        button.Text=if Config.Weapons[selectedMode] then "GOLPEAR" else "CONSTRUIR"
    end)
    local healButton=Instance.new("TextButton")
    healButton.Name="Curar"
    healButton.AnchorPoint=Vector2.new(1,1)
    healButton.Position=UDim2.new(1,-20,1,-166)
    healButton.Size=UDim2.fromOffset(96,55)
    healButton.Text="CURAR"
    healButton.TextColor3=Color3.new(1,1,1)
    healButton.Font=Enum.Font.GothamBold
    healButton.TextSize=15
    healButton.BackgroundColor3=Color3.fromRGB(84,152,90)
    healButton.Parent=ui
    rounded(healButton,12)
    healButton.Activated:Connect(consumeFood)
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

-- Fantasma visual para construções. É apenas uma previsão do cliente:
-- o servidor verifica colisões, alcance, recursos e limites de verdade.
local function previewBuild(dt)
    if Config.Weapons[selectedMode] then
        preview.Transparency=1
        return
    end
    previewElapsed+=dt
    if previewElapsed<.07 then return end
    previewElapsed=0
    local root=getRoot()
    if not root then preview.Transparency=1 return end
    local direction=cursorDirection(root)
    if not direction then preview.Transparency=1 return end
    local pos=root.Position+direction*Config.BuildDistance
    pos=Vector3.new(math.floor(pos.X/2+.5)*2,0,math.floor(pos.Z/2+.5)*2)
    local size=if selectedMode=="Wall" then Vector3.new(10,6,2)
        else if selectedMode=="StoneWall" then Vector3.new(11.5,7,2.8)
        else if selectedMode=="Spikes" then Vector3.new(8,.7,8)
        else Vector3.new(3.8,9,3.8)
    local half=Config.MapSize*.5-14
    local canPlace=math.abs(pos.X)<=half and math.abs(pos.Z)<=half
        and math.abs(pos.Z)>Config.River.Width*.5+7
        and (pos-Vector3.new(0,0,-64)).Magnitude>=17
    if canPlace then
        for _,node in ipairs(resources:GetChildren()) do
            local core=node.PrimaryPart
            if core then
                local dx=pos.X-core.Position.X
                local dz=pos.Z-core.Position.Z
                local radius=if node:GetAttribute("Kind")=="Tree" then 7.5 else 7
                if dx*dx+dz*dz<radius*radius then canPlace=false break end
            end
        end
    end
    local buildingsFolder=world:FindFirstChild("Buildings")
    if canPlace and buildingsFolder then
        for _,node in ipairs(buildingsFolder:GetChildren()) do
            local core=node.PrimaryPart
            if core and (Vector2.new(pos.X-core.Position.X,pos.Z-core.Position.Z)).Magnitude<9 then
                canPlace=false break
            end
        end
    end
    preview.Size=size
    preview.CFrame=CFrame.lookAt(pos,pos+direction)*CFrame.new(0,size.Y*.5,0)
    preview.Color=if canPlace then Color3.fromRGB(76,216,129)
        else Color3.fromRGB(237,92,82)
    preview.Transparency=.55
end
RunService.RenderStepped:Connect(previewBuild)

RunService.Heartbeat:Connect(function()
    if holding then attack() end
end)
RunService.RenderStepped:Connect(function()
    if not Config.Weapons[selectedMode] then
        hover.Enabled = false
        hover.Adornee = nil
        hint.Text="Clique para colocar "..selectedMode.." | 1: voltar à marreta"
        return
    end
    local target = targetFromPointer()
    if target and closeEnough(target) then
        hover.Adornee = target
        hover.Enabled = true
        if Players:GetPlayerFromCharacter(target) then
            hint.Text="ADVERSARIO • GOLPEAR PARA ATACAR"
            hover.OutlineColor=Color3.fromRGB(238,74,68)
        elseif target.Parent==buildings then
            local owned=target:GetAttribute("OwnerUserId")==player.UserId
            hint.Text=if owned then "SUA CONSTRUCAO"
                else (labels[target.Name] or "ESTRUTURA").." • GOLPEAR"
            hover.OutlineColor=if owned then Color3.fromRGB(95,211,122)
                else Color3.fromRGB(249,95,78)
        elseif target.Parent==wolves then
            hint.Text="LOBO • SEGURE PARA ATACAR"
            hover.OutlineColor=Color3.fromRGB(249,95,78)
        else
            hint.Text=(labels[target.Name] or "RECURSO").." • SEGURE PARA GOLPEAR"
            hover.OutlineColor=Color3.fromRGB(255,216,95)
        end
    elseif target then
        hover.Enabled = false
        hover.Adornee = nil
        hint.Text = "Aproxime-se para golpear " .. (labels[target.Name] or "recurso")
    else
        hover.Enabled = false
        hover.Adornee = nil
        hint.Text = "WASD: andar | Mouse: mirar | Clique: golpear | Q: curar"
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
    elseif kind == "Healed" then
        hint.Text="+" .. tostring(position) .. " vida recuperada"
        return
    elseif kind == "Notice" then
        hint.Text=tostring(position)
        return
    elseif kind=="Built" then
        hint.Text=tostring(position).." construído!"
        return
    elseif kind=="Income" then
        hint.Text="Moinho: +"..tostring(position).." ouro"
        return
    elseif kind=="RespawnReset" then
        setMode("Hammer",true)
        hint.Text="Nova vida: recursos, idade e armas reiniciados"
        return
    elseif kind=="WeaponEquipped" then
        hint.Text="Arma equipada: "..tostring(position)
        return
    elseif kind=="PlayerHit" then
        hint.Text="Golpe em adversario: "..tostring(position).." de dano"
        return
    elseif kind=="LevelUp" then
        local age=tonumber(position) or 1
        local announce=Instance.new("TextLabel")
        announce.Name="NovaIdade"
        announce.AnchorPoint=Vector2.new(.5,.5)
        announce.Position=UDim2.new(.5,0,.24,0)
        announce.Size=UDim2.new(.85,0,0,53)
        announce.BackgroundColor3=Color3.fromRGB(40,102,64)
        announce.BackgroundTransparency=.08
        announce.BorderSizePixel=0
        local unlocked=if age==2 then "ESPINHOS"
            else if age==3 then "MOINHO E MACHADO"
            else if age==4 then "MURO DE PEDRA"
            else if age==5 then "ESPADA"
            else "NOVO NIVEL"
        announce.Text="IDADE "..age.."!  "..unlocked
        announce.TextScaled=true
        announce.Font=Enum.Font.GothamBlack
        announce.TextColor3=Color3.new(1,1,1)
        announce.Parent=ui
        rounded(announce,9)
        TweenService:Create(announce,TweenInfo.new(1.6),{
            BackgroundTransparency=1,TextTransparency=1,
            Position=UDim2.new(.5,0,.18,0),
        }):Play()
        Debris:AddItem(announce,1.7)
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
