--!strict
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local WorldDecor = require(script.Parent:WaitForChild("WorldDecor"))

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
    p.CanTouch = collidable ~= false
    p.CanQuery = true
    if collidable == false then p.CastShadow = false end
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
    model:SetAttribute("MaxHealth", entry.health)
    model.Parent = parent

    local center
    if kind == "Tree" then
        local half = Config.MapSize / 2
        local leafA = Color3.fromRGB(59, 147, 71)
        local leafB = Color3.fromRGB(75, 165, 74)
        if position.Z < -half + 96 then
            leafA = Color3.fromRGB(61, 118, 106)
            leafB = Color3.fromRGB(84, 146, 126)
        elseif position.Z > half - 96 then
            leafA = Color3.fromRGB(110, 138, 83)
            leafB = Color3.fromRGB(139, 155, 88)
        end
        center = part("Core", Vector3.new(3.8, 10, 3.8), position + Vector3.new(0, 5, 0),
            Color3.fromRGB(115, 79, 49), Enum.Material.Wood, model, Enum.PartType.Cylinder, true)
        part("CopaBaixa", Vector3.new(12, 9, 12), position + Vector3.new(0, 10.5, 0),
            leafA, Enum.Material.Grass, model, Enum.PartType.Ball, false)
        part("CopaAlta", Vector3.new(9, 7, 9), position + Vector3.new(0, 15.2, 0),
            leafB, Enum.Material.Grass, model, Enum.PartType.Ball, false)
    elseif kind == "Rock" then
        center = part("Core", Vector3.new(8, 6, 8), position + Vector3.new(0, 3, 0),
            Color3.fromRGB(128, 136, 141), Enum.Material.Slate, model, Enum.PartType.Ball, true)
        part("Fragmento", Vector3.new(4, 3, 5), position + Vector3.new(3, 1.5, 1),
            Color3.fromRGB(153, 158, 156), Enum.Material.Slate, model, Enum.PartType.Ball, false)
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
    -- A vida só aparece depois do primeiro golpe; o recurso quebra ao esgotar.
    local gui = Instance.new("BillboardGui")
    gui.Name = "ResourceDurability"
    gui.Size = UDim2.fromOffset(66, 8)
    gui.StudsOffsetWorldSpace = Vector3.new(0, if kind == "Tree" then 12 else 5, 0)
    gui.AlwaysOnTop = false
    gui.Adornee = center
    gui.Enabled = false
    gui.Parent = model
    local bg = Instance.new("Frame")
    bg.Name = "Track"
    bg.BackgroundColor3 = Color3.fromRGB(53, 57, 53)
    bg.BorderSizePixel = 0
    bg.Size = UDim2.fromScale(1,1)
    bg.Parent = gui
    local bar = Instance.new("Frame")
    bar.Name = "Remaining"
    bar.BackgroundColor3 = Color3.fromRGB(244, 181, 73)
    bar.BorderSizePixel = 0
    bar.Size = UDim2.fromScale(1,1)
    bar.Parent = bg
    return model
end

function World.hitNode(model, weapon)
    if not model or not model.Parent or not model.PrimaryPart then return false, 0 end
    local hp = model:GetAttribute("Health")
    if typeof(hp) ~= "number" or hp <= 0 then return false, 0 end
    -- Golpes base: redução de durabilidade por golpe (sem ferramentas inúteis).
    local durabilityDamage = math.max(1, (weapon.gather or 1) - 1)
    local remaining = math.max(0, hp - durabilityDamage)
    model:SetAttribute("Health", remaining)
    local ui = model:FindFirstChild("ResourceDurability")
    if ui then
        ui.Enabled = remaining > 0
        local bg = ui:FindFirstChild("Track")
        local fill = bg and bg:FindFirstChild("Remaining")
        if fill then
            fill.Size = UDim2.fromScale(remaining / math.max(1, model:GetAttribute("MaxHealth") or hp), 1)
        end
    end
    return remaining <= 0, remaining
end

function World.create()
    local old = workspace:FindFirstChild("RoMooWorld")
    if old then old:Destroy() end

    -- Remove apenas a Baseplate grande do template, evitando z-fighting.
    local defaultBaseplate = workspace:FindFirstChild("Baseplate")
    if defaultBaseplate and defaultBaseplate:IsA("BasePart")
        and defaultBaseplate.Anchored and defaultBaseplate.Size.X >= 500
        and defaultBaseplate.Size.Z >= 500 then
        defaultBaseplate:Destroy()
    end

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
    -- Faixas suaves entre campo, gelo e areia, sem barreiras físicas.
    for i = 1, 5 do
        local opacity = i / 6
        local dist = (i - .5) * 6
        local snowFade = part("TransicaoNeve", Vector3.new(Config.MapSize - 18, 0.04, 6),
            Vector3.new(0, .12, -half + 94 + dist),
            Color3.fromRGB(217, 232, 229), Enum.Material.Snow, folder, nil, false)
        snowFade.Transparency = opacity
        local sandFade = part("TransicaoAreia", Vector3.new(Config.MapSize - 18, 0.04, 6),
            Vector3.new(0, .12, half - 94 - dist),
            Color3.fromRGB(223, 193, 135), Enum.Material.Sand, folder, nil, false)
        sandFade.Transparency = opacity
    end
    -- Grade antiga opcional; visual padrão usa vegetação 3D autoral.
    if Config.Decoration.ShowGrid then
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

    -- Plantas e detalhes ficam separados dos recursos (não dão materiais).
    WorldDecor.generate(folder, Config.MapSize, positions, Config.Decoration)

    Lighting.ClockTime = 13.8
    Lighting.Brightness = 2.4
    Lighting.Ambient = Color3.fromRGB(165, 174, 161)
    Lighting.OutdoorAmbient = Color3.fromRGB(162, 171, 163)
    Lighting.GlobalShadows = true
    local atmosphere = Lighting:FindFirstChild("RoMooAtmosphere")
    if not atmosphere then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Name = "RoMooAtmosphere"
        atmosphere.Parent = Lighting
    end
    atmosphere.Density = 0.14
    atmosphere.Offset = 0.2
    atmosphere.Haze = 0.65
    atmosphere.Glare = 0
    atmosphere.Color = Color3.fromRGB(213, 231, 225)

    return nodes, buildings
end

return World
