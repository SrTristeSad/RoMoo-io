--!strict
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))

local World = {}
local random = Random.new(20261029)

local function part(name, size, position, color, material, parent, shape, collidable)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.Color = color
    p.Material = material
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.CanCollide = collidable ~= false
    if shape then
        p.Shape = shape
    end
    p.Parent = parent
    return p
end

function World.spawnNode(kind, position, parent)
    local entry = Config.ResourceTypes[kind]
    assert(entry, "Tipo de recurso desconhecido: " .. tostring(kind))
    local model = Instance.new("Model")
    model.Name = kind
    model:SetAttribute("Kind", kind)
    model:SetAttribute("Health", entry.health)
    model.Parent = parent

    local center
    if kind == "Tree" then
        center = part("Core", Vector3.new(3.8, 10, 3.8), position + Vector3.new(0, 5, 0), Color3.fromRGB(115, 79, 49), Enum.Material.Wood, model, Enum.PartType.Cylinder, true)
        part("Folhas", Vector3.new(13, 13, 13), position + Vector3.new(0, 12, 0), Color3.fromRGB(55, 147, 65), Enum.Material.Grass, model, Enum.PartType.Ball, false)
    elseif kind == "Rock" then
        center = part("Core", Vector3.new(8, 6, 8), position + Vector3.new(0, 3, 0), Color3.fromRGB(128, 136, 141), Enum.Material.Slate, model, Enum.PartType.Ball, true)
    elseif kind == "Gold" then
        center = part("Core", Vector3.new(7, 6, 7), position + Vector3.new(0, 3, 0), Color3.fromRGB(114, 118, 123), Enum.Material.Slate, model, Enum.PartType.Ball, true)
        part("VeioDeOuro", Vector3.new(4, 3, 4), position + Vector3.new(1, 5, 1), Color3.fromRGB(255, 194, 46), Enum.Material.Metal, model, Enum.PartType.Ball, false)
    else
        center = part("Core", Vector3.new(7, 4, 7), position + Vector3.new(0, 2, 0), Color3.fromRGB(62, 155, 68), Enum.Material.Grass, model, Enum.PartType.Ball, false)
        for _, offset in ipairs({Vector3.new(2, 3, 0), Vector3.new(-2, 3, 1), Vector3.new(0, 4, -2)}) do
            part("Fruta", Vector3.new(1.6, 1.6, 1.6), position + offset, Color3.fromRGB(230, 67, 73), Enum.Material.SmoothPlastic, model, Enum.PartType.Ball, false)
        end
    end
    model.PrimaryPart = center
    return model
end

function World.create()
    local old = workspace:FindFirstChild("RoMooWorld")
    if old then old:Destroy() end

    local folder = Instance.new("Folder")
    folder.Name = "RoMooWorld"
    folder.Parent = workspace
    local half = Config.MapSize / 2

    part("Gramado", Vector3.new(Config.MapSize, 2, Config.MapSize), Vector3.new(0, -1, 0), Color3.fromRGB(111, 183, 89), Enum.Material.Grass, folder, nil, true)
    -- Zonas visuais clássicas: norte frio, centro verde, sul desértico.
    local snow = part("Neve", Vector3.new(Config.MapSize - 18, 0.08, 88),
        Vector3.new(0, 0.05, -half + 50), Color3.fromRGB(211, 235, 237), Enum.Material.Snow, folder, nil, false)
    local desert = part("Deserto", Vector3.new(Config.MapSize - 18, 0.08, 88),
        Vector3.new(0, 0.05, half - 50), Color3.fromRGB(216, 189, 129), Enum.Material.Sand, folder, nil, false)
    snow.CastShadow = false
    desert.CastShadow = false
    -- Grade discreta que preserva a leitura do mapa visto de cima.
    for x = -240, 240, 24 do
        local line = part("GradeX", Vector3.new(0.09, 0.02, Config.MapSize),
            Vector3.new(x, 0.12, 0), Color3.fromRGB(102, 133, 104), Enum.Material.SmoothPlastic, folder, nil, false)
        line.Transparency = 0.55
        line.CastShadow = false
    end
    for z = -240, 240, 24 do
        local line = part("GradeZ", Vector3.new(Config.MapSize, 0.02, 0.09),
            Vector3.new(0, 0.12, z), Color3.fromRGB(102, 133, 104), Enum.Material.SmoothPlastic, folder, nil, false)
        line.Transparency = 0.55
        line.CastShadow = false
    end

    for _, wallData in ipairs({
        {pos = Vector3.new(0, 10, -half), size = Vector3.new(Config.MapSize + 20, 20, 8)},
        {pos = Vector3.new(0, 10, half), size = Vector3.new(Config.MapSize + 20, 20, 8)},
        {pos = Vector3.new(-half, 10, 0), size = Vector3.new(8, 20, Config.MapSize + 20)},
        {pos = Vector3.new(half, 10, 0), size = Vector3.new(8, 20, Config.MapSize + 20)},
    }) do
        part("LimiteDoMapa", wallData.size, wallData.pos, Color3.fromRGB(91, 122, 90), Enum.Material.Rock, folder, nil, true)
    end

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "SpawnCentral"
    spawn.Size = Vector3.new(20, 1, 20)
    spawn.Position = Vector3.new(0, 0.5, 0)
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Duration = 5
    spawn.Color = Color3.fromRGB(67, 151, 185)
    spawn.Material = Enum.Material.SmoothPlastic
    spawn.Parent = folder

    local nodes = Instance.new("Folder")
    nodes.Name = "Resources"
    nodes.Parent = folder
    local buildings = Instance.new("Folder")
    buildings.Name = "Buildings"
    buildings.Parent = folder

    local positions = {}
    local kinds = { "Tree", "Tree", "Tree", "Rock", "Rock", "Gold", "Bush", "Bush" }
    for _ = 1, Config.ResourceCount do
        local chosen
        for _try = 1, 40 do
            local candidate = Vector3.new(random:NextInteger(-half + 24, half - 24), 0, random:NextInteger(-half + 24, half - 24))
            local valid = candidate.Magnitude > 32
            for _, existing in ipairs(positions) do
                if (candidate - existing).Magnitude < 16 then
                    valid = false
                    break
                end
            end
            if valid then
                chosen = candidate
                break
            end
        end
        if chosen then
            table.insert(positions, chosen)
            World.spawnNode(kinds[random:NextInteger(1, #kinds)], chosen, nodes)
        end
    end

    Lighting.ClockTime = 14
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(150, 156, 155)
    return nodes, buildings
end

return World
