--!nonstrict
-- Cenário de teste 3D: Terrain nativo, água real, árvores, pedras e minério de ouro.
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Config = require(ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))

local World = {}
local rng = Random.new(20261029)

local function makePart(parent, name, size, cf, color, material, opts)
    opts = opts or {}
    local p = Instance.new(opts.wedge and "WedgePart" or "Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material
    if opts.shape then p.Shape = opts.shape end
    p.Anchored = true
    p.CanCollide = opts.collide == true
    p.CanTouch = false
    p.CanQuery = opts.query ~= false
    p.CastShadow = opts.shadow ~= false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function riverZ(x)
    return math.sin(x / 85) * 6 + math.sin(x / 37) * 2
end

local function clearFromRiver(x, z)
    local width = Config.River.Width
    return math.abs(z - riverZ(x)) > width / 2 + 14
end

local function createRiver(terrain, folder)
    local size = Config.MapSize
    local width = Config.River.Width
    terrain.WaterColor = Color3.fromRGB(47, 139, 180)
    terrain.WaterTransparency = .24
    terrain.WaterReflectance = .1
    terrain.WaterWaveSize = .23
    terrain.WaterWaveSpeed = 7
    for x = -size/2 + 8, size/2 - 8, 14 do
        local middleZ = riverZ(x)
        -- Esculpir o canal no solo e preencher com água real do Terrain.
        terrain:FillBlock(CFrame.new(x, -1, middleZ),
            Vector3.new(18, 14, width + 5), Enum.Material.Air)
        terrain:FillBlock(CFrame.new(x, -8, middleZ),
            Vector3.new(18, 4, width + 5), Enum.Material.Sand)
        terrain:FillBlock(CFrame.new(x, -3, middleZ),
            Vector3.new(18, 6, width), Enum.Material.Water)
        for _, side in ipairs({-1, 1}) do
            terrain:FillBlock(CFrame.new(x, -.8, middleZ + side * (width/2 + 5)),
                Vector3.new(18, 1.5, 6), Enum.Material.Sand)
        end
    end
    local bridges = Instance.new("Folder")
    bridges.Name = "Pontes"
    bridges.Parent = folder
    local bWidth = Config.River.BridgeWidth
    local length = width + 22
    for _, bridgeX in ipairs(Config.River.BridgeXs or {0}) do
        local bridge = Instance.new("Model")
        bridge.Name = "PonteDeMadeira"
        bridge:SetAttribute("BridgeX", bridgeX)
        bridge.Parent = bridges
        local centerZ = riverZ(bridgeX)
        local plankIndex = 0
        for z = -length / 2, length / 2, 2.6 do
            plankIndex += 1
            local plank = makePart(bridge, "Tabua", Vector3.new(bWidth, .8, 2.45),
                CFrame.new(bridgeX, 1.12, centerZ + z),
                if plankIndex % 2 == 0 then Color3.fromRGB(151, 104, 64)
                    else Color3.fromRGB(178, 126, 77),
                Enum.Material.WoodPlanks, {collide = true})
            if not bridge.PrimaryPart then bridge.PrimaryPart = plank end
        end
        for _, side in ipairs({-1, 1}) do
            local railX = bridgeX + side * (bWidth/2 - .5)
            makePart(bridge, "Corrimao", Vector3.new(.6, .7, length),
                CFrame.new(railX, 3.05, centerZ),
                Color3.fromRGB(108, 73, 46), Enum.Material.Wood, {collide = true})
            makePart(bridge, "CorrimaoBaixo", Vector3.new(.5, .55, length),
                CFrame.new(railX, 2.15, centerZ),
                Color3.fromRGB(139, 98, 61), Enum.Material.Wood, {collide = true})
            for z = -length / 2 + 2, length / 2 - 2, 9 do
                makePart(bridge, "Poste", Vector3.new(.7, 2.8, .7),
                    CFrame.new(railX, 2, centerZ + z),
                    Color3.fromRGB(111, 78, 48), Enum.Material.Wood, {collide = true})
            end
        end
        for _, side in ipairs({-1, 1}) do
            local landZ = centerZ + side * (length / 2 + 2)
            makePart(bridge, "Acesso", Vector3.new(bWidth, .7, 5),
                CFrame.new(bridgeX, .8, landZ),
                Color3.fromRGB(163, 114, 70), Enum.Material.WoodPlanks, {collide = true})
        end
    end
    return bridges
end

local function createTree(model, pos)
    local variation = rng:NextNumber(.85, 1.15)
    local trunkH = 8 * variation
    local trunk = makePart(model, "Core", Vector3.new(trunkH, 2.6, 2.6),
        CFrame.new(pos + Vector3.new(0, trunkH/2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
        Color3.fromRGB(116, 82, 54), Enum.Material.Wood, {shape = Enum.PartType.Cylinder, collide = true})
    -- Copa com volumes separados, não uma esfera substituindo a árvore.
    for i, offset in ipairs({
        Vector3.new(0, 9.0, 0), Vector3.new(-3.5, 8.5, .8),
        Vector3.new(3.2, 8.7, -1), Vector3.new(0, 11.8, 1.1),
    }) do
        makePart(model, "Folhas", Vector3.new(7.5, 5.4, 7.4) * variation,
            CFrame.new(pos + offset * variation),
            if i % 2 == 0 then Color3.fromRGB(59, 129, 66) else Color3.fromRGB(73, 150, 80),
            Enum.Material.Grass, {shape = Enum.PartType.Ball})
    end
    for _, side in ipairs({-1, 1}) do
        local branch = makePart(model, "Galho", Vector3.new(1.25, 4.1, 1.25),
            CFrame.new(pos + Vector3.new(side * 1.4, 6.7, 0)) *
            CFrame.Angles(0, 0, math.rad(side * 37)),
            Color3.fromRGB(116, 82, 54), Enum.Material.Wood)
        branch.CanQuery = false
    end
    return trunk
end

local function createRock(model, pos, gold)
    local body = makePart(model, "Core", Vector3.new(7.5, 5, 6.8),
        CFrame.new(pos + Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, math.rad(18), 0),
        Color3.fromRGB(110, 121, 130), Enum.Material.Slate, {collide = true})
    for index, offset in ipairs({
        Vector3.new(-2.7, 1.4, 2.2), Vector3.new(2.8, 1.5, -1.9),
        Vector3.new(0, 2.5, -3.2)
    }) do
        makePart(model, "Rochoso", Vector3.new(3.6, 3.8, 4.5),
            CFrame.new(pos + offset) * CFrame.Angles(0, math.rad(index * 53), math.rad(8)),
            if index == 1 then Color3.fromRGB(138, 147, 150) else Color3.fromRGB(117, 126, 131),
            Enum.Material.Rock, {wedge = true})
    end
    if gold then
        for index, offset in ipairs({
            Vector3.new(-2.2, 4.4, .4),
            Vector3.new(1.6, 3.8, -2.2),
            Vector3.new(1.7, 2.1, 2.1),
        }) do
            makePart(model, "VeioDeOuro", Vector3.new(1.25, 2.2, 1.4),
                CFrame.new(pos + offset) * CFrame.Angles(0, math.rad(index * 35), math.rad(18)),
                Color3.fromRGB(236, 183, 39), Enum.Material.Metal, {wedge = true})
        end
    end
    return body
end

local function importedResource(kind, model, pos)
    local library = ServerStorage:FindFirstChild("RoMooResourceModels")
    local template = library and library:FindFirstChild(kind)
    if not template or not template:IsA("Model") then return nil end
    local visual = template:Clone()
    visual.Name = "Visual3D"
    for _, item in ipairs(visual:GetDescendants()) do
        if item:IsA("LuaSourceContainer") then item:Destroy() end
        if item:IsA("BasePart") then
            item.Anchored = true
            item.CanCollide = false
            item.CanTouch = false
            item.CanQuery = true
        end
    end
    visual.Parent = model
    local ok = pcall(function() visual:PivotTo(CFrame.new(pos)) end)
    if not ok then visual:Destroy() return nil end
    local center = makePart(model, "Core", Vector3.new(6, 6, 6),
        CFrame.new(pos + Vector3.new(0, 3, 0)), Color3.fromRGB(112, 115, 116),
        Enum.Material.SmoothPlastic, {collide = true})
    center.Transparency = 1
    return center
end

function World.spawnNode(kind, pos, parent)
    local stats = Config.ResourceTypes[kind]
    assert(stats, "Tipo de recurso desconhecido: " .. tostring(kind))
    local model = Instance.new("Model")
    model.Name = kind
    model:SetAttribute("Kind", kind)
    model.Parent = parent

    local core = importedResource(kind, model, pos)
    if not core then
        core = if kind == "Tree" then createTree(model, pos)
            else createRock(model, pos, kind == "Gold")
    end
    model.PrimaryPart = core

    return model
end

-- O servidor original coleta materiais de objetos naturais sem esgotar sua vida.
-- São permanentes; dano, durabilidade e destruição só se aplicam a construções.
function World.hitNode(node)
    if not node or not node.Parent or not node.PrimaryPart then return nil end
    local kind = node:GetAttribute("Kind")
    return Config.ResourceTypes[kind]
end

function World.create()
    local prior = workspace:FindFirstChild("RoMooWorld")
    if prior then prior:Destroy() end
    local old = workspace:FindFirstChild("Baseplate")
    if old and old:IsA("BasePart") and old.Anchored then old:Destroy() end

    local terrain = workspace.Terrain
    terrain:Clear()
    -- Materiais 3D nativos: nada de uma placa plana feita com Part.
    pcall(function() terrain.Decoration = true end)
    pcall(function() terrain.GrassLength = .75 end)
    terrain:FillBlock(CFrame.new(0, -6, 0),
        Vector3.new(Config.MapSize, 12, Config.MapSize), Enum.Material.Grass)
    local folder = Instance.new("Folder")
    folder.Name = "RoMooWorld"
    folder.Parent = workspace
    createRiver(terrain, folder)

    -- Nas margens: pedras reais, espalhadas, sem colisão com o jogador.
    for i = 1, 34 do
        local x = rng:NextNumber(-Config.MapSize/2 + 12, Config.MapSize/2 - 12)
        local side = if i % 2 == 0 then -1 else 1
        local z = riverZ(x) + side * (Config.River.Width / 2 + rng:NextNumber(5, 12))
        if math.abs(x) > Config.River.BridgeWidth + 9
            and math.abs(x - 150) > Config.River.BridgeWidth + 9
            and math.abs(x + 150) > Config.River.BridgeWidth + 9 then
            makePart(folder, "PedraMargem", Vector3.new(1.3, .8, 1.7),
                CFrame.new(x, .1, z) * CFrame.Angles(0, rng:NextNumber(-3, 3), 0),
                Color3.fromRGB(145, 150, 142), Enum.Material.Slate,
                {shape = Enum.PartType.Ball, query = false, shadow = false})
        end
    end

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "Nascimento"
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Duration = 2
    spawn.Size = Vector3.new(10, 1, 10)
    spawn.Position = Vector3.new(0, .6, -64)
    spawn.Transparency = 1
    spawn.CanCollide = false
    spawn.Parent = folder

    local resources = Instance.new("Folder")
    resources.Name = "Resources"
    resources.Parent = folder

    local spots = {}
    local function add(kind, x, z)
        local pos = Vector3.new(x, 0, z)
        if not clearFromRiver(x, z) then return false end
        if Vector2.new(x, z + 64).Magnitude < 11 then return false end
        for _, other in ipairs(spots) do
            if (other - pos).Magnitude < 16 then return false end
        end
        table.insert(spots, pos)
        World.spawnNode(kind, pos, resources)
        return true
    end

    -- Recursos garantidos a curta distância do ponto inicial: teste imediato.
    add("Tree", -19, -67)
    add("Rock", 18, -72)
    add("Gold", 5, -91)
    add("Tree", -33, -94)
    add("Rock", 30, -104)

    local desired = {Tree = 25, Rock = 18, Gold = 8}
    for kind, count in pairs(desired) do
        for _ = 1, count do
            for _try = 1, 90 do
                local x = rng:NextInteger(-Config.MapSize/2 + 24, Config.MapSize/2 - 24)
                local z = rng:NextInteger(-Config.MapSize/2 + 24, Config.MapSize/2 - 24)
                if add(kind, x, z) then break end
            end
        end
    end

    Lighting.ClockTime = 14
    Lighting.Brightness = 2.4
    Lighting.Ambient = Color3.fromRGB(158, 167, 167)
    Lighting.OutdoorAmbient = Color3.fromRGB(179, 190, 177)
    Lighting.GlobalShadows = true
    local atmo = Lighting:FindFirstChild("RoMooAtmosphere") or Instance.new("Atmosphere")
    atmo.Name = "RoMooAtmosphere"
    atmo.Density = .2
    atmo.Haze = .8
    atmo.Color = Color3.fromRGB(208, 230, 239)
    atmo.Parent = Lighting

    print("[RoMoo] Terrain nativo, rio com agua real, marreta e "
        .. #resources:GetChildren() .. " recursos 3D.")
    return resources
end

return World
