--!nonstrict
-- Fauna simplificada para o RoMoo io: animais herbívoros fogem, predadores perseguem.
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local AnimalModels = require(script.Parent:WaitForChild("AnimalModels"))
local Animals = {}
local rng = Random.new(721)
-- A seleção de espécies, o comportamento e as categorias têm como referência
-- SrTristeSad/ToonRoyale-Assets/android/server-lua/world/animal_types.lua (AGPL-3.0).
-- Valores adaptados à escala em studs, câmera 3D e balanço do Roblox.
local defs = {
    Cow = {sourceId = 0, color = Color3.fromRGB(219, 201, 175), health = 100, speed = 11,
        food = 30, xp = 35, count = 6, hostile = false},
    Pig = {sourceId = 1, color = Color3.fromRGB(232, 157, 155), health = 130, speed = 12,
        food = 45, xp = 40, count = 4, hostile = false},
    Sheep = {sourceId = 12, color = Color3.fromRGB(239, 236, 217), health = 110, speed = 13,
        food = 35, xp = 35, count = 5, hostile = false},
    Bull = {sourceId = 2, color = Color3.fromRGB(124, 83, 61), health = 220, speed = 18,
        food = 60, xp = 90, count = 3, hostile = true, damage = 18},
    Bully = {sourceId = 3, color = Color3.fromRGB(87, 60, 52), health = 360, speed = 19,
        food = 90, xp = 120, count = 1, hostile = true, damage = 22},
    Wolf = {sourceId = 4, color = Color3.fromRGB(126, 130, 139), health = 105, speed = 22,
        food = 48, xp = 65, count = 4, hostile = true, damage = 13, biome = "Snow"},
    Boar = {sourceId = 9, color = Color3.fromRGB(127, 85, 68), health = 155, speed = 18,
        food = 45, xp = 60, count = 3, hostile = true, damage = 16},
    Yeti = {sourceId = 10, color = Color3.fromRGB(233, 241, 243), health = 470, speed = 13,
        food = 130, xp = 160, count = 1, hostile = true, damage = 27, biome = "Snow"},
}
local folder
local states = {}
local mapHalf = 260

-- Substitui os protótipos pelas malhas do Roblox Studio se o usuário importar
-- os arquivos CC0 para ServerStorage/RoMooAnimalModels/<Cow|Bull|Wolf|Sheep>.
local function attachImportedVisual(model, core, kind)
    local library = ServerStorage:FindFirstChild("RoMooAnimalModels")
    local template = library and library:FindFirstChild(kind)
    if not template or not template:IsA("Model") then return false end
    local clone = template:Clone()
    clone.Name = "ImportedVisual"
    -- Nunca executar scripts que estejam acidentalmente dentro de um modelo.
    for _, child in ipairs(clone:GetDescendants()) do
        if child:IsA("LuaSourceContainer") then child:Destroy() end
    end
    clone.Parent = model
    local foundPart = false
    for _, desc in ipairs(clone:GetDescendants()) do
        if desc:IsA("BasePart") then
            foundPart = true
            desc.Anchored = true
            desc.CanCollide = false
            desc.CanTouch = false
            desc.CanQuery = false
            desc.CastShadow = true
        end
    end
    if not foundPart then
        clone:Destroy()
        return false
    end
    local ok, err = pcall(function()
        local bounds = clone:GetExtentsSize()
        local maximum = math.max(bounds.X, bounds.Y, bounds.Z)
        if maximum <= 0 then error("Imported animal has zero-sized geometry") end
        local target = if kind == "Bull" then 10 else if kind == "Wolf" then 9 else 8
        clone:ScaleTo(math.clamp(target / maximum, .01, 100))
        -- Model:PivotTo usa o centro da malha importada se não existir PrimaryPart.
        clone:PivotTo(core.CFrame)
    end)
    if not ok then
        warn("[RoMoo Animals] Falha no modelo " .. kind .. ": " .. tostring(err))
        clone:Destroy()
        return false
    end
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("BasePart") then
            child.Transparency = 1 -- Colisão/posição continua no Core, visual vem da malha.
            child.CastShadow = false
        end
    end
    return true
end

local function part(name, size, relative, color, shape, model, anchor)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = anchor * CFrame.new(relative)
    p.Color = color
    p.Shape = shape or Enum.PartType.Block
    p.Material = Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = model
    return p
end

local function freeSpawnPoint(point)
    local world = folder and folder.Parent
    local resources = world and world:FindFirstChild("Resources")
    if resources then
        for _, node in ipairs(resources:GetChildren()) do
            if node:IsA("Model") and node.PrimaryPart then
                local offset = node.PrimaryPart.Position - point
                if Vector2.new(offset.X, offset.Z).Magnitude < 12 then return false end
            end
        end
    end
    for _, animal in ipairs(folder:GetChildren()) do
        if animal:IsA("Model") and animal.PrimaryPart then
            local offset = animal.PrimaryPart.Position - point
            if Vector2.new(offset.X, offset.Z).Magnitude < 10 then return false end
        end
    end
    return true
end

local function spawn(kind)
    if not folder or not folder.Parent then return nil end
    local def = defs[kind]
    if not def then return nil end
    local pos = nil
    for _ = 1, 45 do
        local x = rng:NextInteger(-mapHalf + 40, mapHalf - 40)
        local z = if def.biome == "Snow" then rng:NextInteger(-mapHalf + 18, -mapHalf + 82)
            else rng:NextInteger(-mapHalf + 40, mapHalf - 40)
        local candidate = Vector3.new(x, 3.6, z)
        if Vector3.new(candidate.X, 0, candidate.Z).Magnitude > 40 and freeSpawnPoint(candidate) then
            pos = candidate
            break
        end
    end
    if not pos then return nil end

    local model = Instance.new("Model")
    model.Name = kind
    model:SetAttribute("Kind", kind)
    model:SetAttribute("SourceTypeId", def.sourceId)
    model:SetAttribute("Health", def.health)
    model.Parent = folder
    local cf = CFrame.new(pos)
    local core = part("Core", Vector3.new(5.8, 4.5, 7.8), Vector3.zero,
        def.color, Enum.PartType.Block, model, cf)
    core.Transparency = 1
    model.PrimaryPart = core
    if not attachImportedVisual(model, core, kind) then
        AnimalModels.create(model, cf, kind, core)
    end

    local hpGui = Instance.new("BillboardGui")
    hpGui.Name = "AnimalHealth"
    hpGui.Adornee = core
    hpGui.StudsOffsetWorldSpace = Vector3.new(0, 4.2, 0)
    hpGui.Size = UDim2.fromOffset(62, 9)
    hpGui.AlwaysOnTop = true
    hpGui.Parent = model
    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.fromScale(1, 1)
    bg.BorderSizePixel = 0
    bg.BackgroundColor3 = Color3.fromRGB(57, 48, 48)
    bg.Parent = hpGui
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.fromScale(1, 1)
    fill.BorderSizePixel = 0
    fill.BackgroundColor3 = Color3.fromRGB(81, 198, 91)
    fill.Parent = bg

    states[model] = {
        kind = kind, health = def.health, lastAttack = 0,
        moveDirection = Vector3.new(1, 0, 0), nextWander = 0,
        phase = rng:NextNumber(0, math.pi * 2), panicUntil = 0,
    }
    return model
end

local function directionToAnimal(animalPosition, maxDist)
    local chosen, distance, hum = nil, maxDist, nil
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        local human = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if human and root and human.Health > 0 then
            local delta = Vector3.new(root.Position.X - animalPosition.X, 0, root.Position.Z - animalPosition.Z)
            if delta.Magnitude < distance then
                chosen, distance, hum = delta, delta.Magnitude, human
            end
        end
    end
    return chosen, distance, hum
end

function Animals.create(world, mapSize)
    local existing = world:FindFirstChild("Animals")
    if existing then existing:Destroy() end
    folder = Instance.new("Folder")
    folder.Name = "Animals"
    folder.Parent = world
    states = {}
    mapHalf = math.floor(mapSize / 2)
    for kind, def in pairs(defs) do
        for _ = 1, def.count do spawn(kind) end
    end

    task.spawn(function()
        while folder and folder.Parent do
            local dt = task.wait(0.15)
            dt = math.min(dt, 0.3)
            local now = os.clock()
            for model, state in pairs(states) do
                if not model.Parent or not model.PrimaryPart then
                    states[model] = nil
                else
                    local def = defs[state.kind]
                    local pos = model.PrimaryPart.Position
                    local detection = if def.hostile then 42 else if now < state.panicUntil then 58 else 26
                    local playerDelta, distance, hum = directionToAnimal(pos, detection)
                    local dir = state.moveDirection
                    if playerDelta and playerDelta.Magnitude > 0.1 then
                        dir = if def.hostile then playerDelta.Unit else -playerDelta.Unit
                    elseif now > state.nextWander then
                        local angle = rng:NextNumber() * math.pi * 2
                        dir = Vector3.new(math.cos(angle), 0, math.sin(angle))
                        state.moveDirection = dir
                        state.nextWander = now + rng:NextNumber(1.5, 4)
                    end
                    local panicking = not def.hostile and now < state.panicUntil
                    local moveSpeed = def.speed * 0.35
                    if playerDelta then
                        moveSpeed = def.speed
                        if panicking then moveSpeed *= 1.18 end
                    end
                    local nextPos = Vector3.new(
                        math.clamp(pos.X + dir.X * moveSpeed * dt, -mapHalf + 20, mapHalf - 20),
                        3.6, math.clamp(pos.Z + dir.Z * moveSpeed * dt, -mapHalf + 20, mapHalf - 20))
                    if dir.Magnitude > 0.1 then
                        -- Pequena animação de caminhada, compatível com Parts e MeshParts,
                        -- sem publicar AnimationIds ou criar joints por animal.
                        local bob = math.abs(math.sin(now * moveSpeed * .72 + state.phase)) * .17
                        local lean = math.sin(now * moveSpeed * .72 + state.phase) * math.rad(2.0)
                        local raised = nextPos + Vector3.new(0, bob, 0)
                        model:PivotTo(CFrame.lookAt(raised, raised + dir) * CFrame.Angles(lean, 0, 0))
                    end
                    if def.hostile and playerDelta and hum and distance < 7 and now - state.lastAttack > 1.5 then
                        local char = hum.Parent
                        if not char or not char:FindFirstChildOfClass("ForceField") then
                            state.lastAttack = now
                            hum:TakeDamage(def.damage)
                        end
                    end
                end
            end
        end
    end)
    return folder
end

function Animals.hit(model, damage)
    local state = states[model]
    if not state or not model.Parent then return 0, 0, false end
    state.health -= damage
    if not defs[state.kind].hostile then
        state.panicUntil = os.clock() + 3.3
    end
    local def = defs[state.kind]
    if state.health > 0 then
        model:SetAttribute("Health", state.health)
        local gui = model:FindFirstChild("AnimalHealth")
        local bg = gui and gui:FindFirstChild("Background")
        local fill = bg and bg:FindFirstChild("Fill")
        if fill then fill.Size = UDim2.fromScale(state.health / def.health, 1) end
        return 0, 0, false
    end
    states[model] = nil
    local kind = state.kind
    model:Destroy()
    task.delay(24, function()
        if folder and folder.Parent then spawn(kind) end
    end)
    return def.food, def.xp, true
end

return Animals
