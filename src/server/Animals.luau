--!nonstrict
-- Fauna simplificada para o RoMoo io: animais herbívoros fogem, predadores perseguem.
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Animals = {}
local rng = Random.new(721)
local defs = {
    Cow = {color = Color3.fromRGB(213, 185, 145), health = 80, speed = 11, food = 30, xp = 30, count = 9, hostile = false},
    Sheep = {color = Color3.fromRGB(242, 240, 222), health = 60, speed = 13, food = 20, xp = 25, count = 6, hostile = false},
    Bull = {color = Color3.fromRGB(113, 80, 65), health = 140, speed = 19, food = 45, xp = 70, count = 4, hostile = true, damage = 18},
    Wolf = {color = Color3.fromRGB(102, 108, 117), health = 95, speed = 21, food = 25, xp = 55, count = 5, hostile = true, damage = 13},
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

local function spawn(kind)
    if not folder or not folder.Parent then return nil end
    local def = defs[kind]
    if not def then return nil end
    local pos
    repeat
        pos = Vector3.new(rng:NextInteger(-mapHalf + 40, mapHalf - 40),
            3, rng:NextInteger(-mapHalf + 40, mapHalf - 40))
    until Vector3.new(pos.X, 0, pos.Z).Magnitude > 35

    local model = Instance.new("Model")
    model.Name = kind
    model:SetAttribute("Kind", kind)
    model:SetAttribute("Health", def.health)
    model.Parent = folder
    local cf = CFrame.new(pos)
    local core = part("Core", Vector3.new(6, 5, 8), Vector3.zero, def.color, Enum.PartType.Ball, model, cf)
    model.PrimaryPart = core
    part("Head", Vector3.new(4, 4, 4), Vector3.new(0, 0, -4.3), def.color, Enum.PartType.Ball, model, cf)
    part("Nose", Vector3.new(2.3, 1.7, 1.5), Vector3.new(0, -.9, -6),
        if kind == "Wolf" then Color3.fromRGB(55, 55, 65) else Color3.fromRGB(198, 139, 144),
        Enum.PartType.Ball, model, cf)
    for _, side in ipairs({-1, 1}) do
        part("Orelha", Vector3.new(1.7, 2.2, 1.8),
            Vector3.new(side * 2.3, 1.1, -4.1), def.color, Enum.PartType.Ball, model, cf)
        part("Olho", Vector3.new(0.9, 1, 0.75),
            Vector3.new(side * 1.45, 1, -6),
            Color3.fromRGB(34, 37, 39), Enum.PartType.Ball, model, cf)
        if kind == "Bull" then
            part("Chifre", Vector3.new(1.8, 2, 1.2), Vector3.new(side * 2.6, 2.8, -4.4),
                Color3.fromRGB(236, 225, 177), Enum.PartType.Ball, model, cf)
        end
    end

    attachImportedVisual(model, core, kind)

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
                    local playerDelta, distance, hum = directionToAnimal(pos, if def.hostile then 42 else 26)
                    local dir = state.moveDirection
                    if playerDelta and playerDelta.Magnitude > 0.1 then
                        dir = if def.hostile then playerDelta.Unit else -playerDelta.Unit
                    elseif now > state.nextWander then
                        local angle = rng:NextNumber() * math.pi * 2
                        dir = Vector3.new(math.cos(angle), 0, math.sin(angle))
                        state.moveDirection = dir
                        state.nextWander = now + rng:NextNumber(1.5, 4)
                    end
                    local moveSpeed = if playerDelta then def.speed else def.speed * 0.35
                    local nextPos = Vector3.new(
                        math.clamp(pos.X + dir.X * moveSpeed * dt, -mapHalf + 20, mapHalf - 20),
                        3, math.clamp(pos.Z + dir.Z * moveSpeed * dt, -mapHalf + 20, mapHalf - 20))
                    if dir.Magnitude > 0.1 then
                        model:PivotTo(CFrame.lookAt(nextPos, nextPos + dir))
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
