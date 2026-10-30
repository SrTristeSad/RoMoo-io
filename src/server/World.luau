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

-- Três silhuetas de árvore, com escala compatível com o avatar R15.
-- Peças e materiais nativos do Studio; não há meshes externos obrigatórios.
local function createTree(model, pos)
    local scale = rng:NextNumber(.85, 1.25)
    local pine = rng:NextInteger(1, 5) == 1
    local height = (if pine then 7.2 else 5.7) * scale
    local tone = rng:NextInteger(-9, 9)
    local bark = Color3.fromRGB(114 + tone, 83 + tone, 55 + tone)
    local trunk = makePart(model, "Core",
        Vector3.new(height, 1.6 * scale, 1.6 * scale),
        CFrame.new(pos + Vector3.new(0, height / 2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
        bark, Enum.Material.Wood, {shape = Enum.PartType.Cylinder, collide = true})
    local palette
    if pos.Z < -Config.MapSize / 2 + 110 then
        palette = {Color3.fromRGB(61, 117, 95), Color3.fromRGB(55, 105, 88)}
    elseif pos.Z > Config.MapSize / 2 - 110 then
        palette = {Color3.fromRGB(121, 144, 83), Color3.fromRGB(144, 156, 91)}
    else
        palette = {Color3.fromRGB(54, 139, 65), Color3.fromRGB(74, 162, 72)}
    end
    if pine then
        for layer = 1, 3 do
            local radius = (5.6 - layer * 1.05) * scale
            makePart(model, "RamoPinheiro", Vector3.new(radius, 3.6 * scale, radius),
                CFrame.new(pos + Vector3.new(0, height * (.64 + layer * .18), 0)),
                palette[layer % 2 + 1], Enum.Material.Grass, {shape = Enum.PartType.Ball})
        end
    else
        for i, offset in ipairs({
            Vector3.new(0, 2.1, 0), Vector3.new(-2.05, .9, 0),
            Vector3.new(2.0, 1.0, -.4), Vector3.new(0, .8, 2.0),
        }) do
            makePart(model, "Copa", Vector3.new(5.25, 4.0, 5.0) * scale,
                CFrame.new(pos + Vector3.new(0, height, 0) + offset * scale),
                palette[(i % 2) + 1], Enum.Material.Grass, {shape = Enum.PartType.Ball})
        end
    end
    return trunk
end

local function createRock(model, pos, gold)
    local scale = rng:NextNumber(.80, 1.2)
    local stone = if gold then Color3.fromRGB(108, 103, 99) else Color3.fromRGB(120, 130, 139)
    local core = makePart(model, "Core", Vector3.new(5.2, 3.5, 5) * scale,
        CFrame.new(pos + Vector3.new(0, 1.75 * scale, 0)) *
        CFrame.Angles(0, rng:NextNumber(-.5, .5), 0),
        stone, Enum.Material.Slate, {collide = true})
    local shapes = {
        {Vector3.new(-1.9, 1.5, 1.9), Vector3.new(2.6, 2.7, 3.2)},
        {Vector3.new(1.7, 1.4, -1.7), Vector3.new(2.8, 2.4, 2.8)},
    }
    for i, item in ipairs(shapes) do
        makePart(model, "FaceRochosa", item[2] * scale,
            CFrame.new(pos + item[1] * scale) *
            CFrame.Angles(0, math.rad(i * 48), math.rad(9)),
            if gold then Color3.fromRGB(139, 131, 118)
                else Color3.fromRGB(142, 149, 151), Enum.Material.Rock,
            {wedge = true})
    end
    if gold then
        for i, offset in ipairs({
            Vector3.new(-1.6, 3.1, -.5), Vector3.new(1.5, 2.7, 1.5),
            Vector3.new(0, 3.6, -1.0),
        }) do
            makePart(model, "VeioDeOuro", Vector3.new(.95, 1.7, 1.3) * scale,
                CFrame.new(pos + offset * scale) *
                CFrame.Angles(0, math.rad(i * 37), math.rad(15)),
                Color3.fromRGB(235, 182, 46), Enum.Material.Metal, {wedge = true})
        end
    end
    return core
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

    -- 170 árvores, 66 rochas e 22 minérios espalhados em grupos.
    -- Separação menor que a versão anterior, mas com espaço para caminhar.
    local spots = {}
    local function add(kind, x, z)
        if math.abs(x) > Config.MapSize / 2 - 17 or math.abs(z) > Config.MapSize / 2 - 17 then
            return false
        end
        local pos = Vector3.new(x, 0, z)
        if not clearFromRiver(x, z) then return false end
        if Vector2.new(x, z + 64).Magnitude < 10 then return false end
        for _, other in ipairs(spots) do
            if (other - pos).Magnitude < 10.5 then return false end
        end
        table.insert(spots, pos)
        World.spawnNode(kind, pos, resources)
        return true
    end

    -- Próximo ao spawn: todos os recursos em vista, mais árvores ao redor.
    for _, item in ipairs({
        {"Tree",-17,-64}, {"Tree",-31,-68}, {"Tree",-27,-91},
        {"Tree",20,-57}, {"Tree",33,-71}, {"Tree",38,-88},
        {"Tree",-47,-79}, {"Tree",-46,-104}, {"Tree",50,-106},
        {"Rock",12,-83}, {"Rock",-11,-88}, {"Rock",27,-100},
        {"Gold",5,-109}, {"Gold",-24,-115},
    }) do
        add(item[1], item[2], item[3])
    end

    local groves = {
        Vector2.new(-80,-85), Vector2.new(88,-98),
        Vector2.new(-149,-158), Vector2.new(-44,-163),
        Vector2.new(64,-190), Vector2.new(166,-174),
        Vector2.new(-160,-48), Vector2.new(153,-38),
        Vector2.new(-165,77), Vector2.new(-70,98),
        Vector2.new(46,97), Vector2.new(145,143),
        Vector2.new(-132,181), Vector2.new(0,187),
        Vector2.new(163,195), Vector2.new(-29,-211),
    }
    for _, center in ipairs(groves) do
        local created = 0
        for _try = 1, 120 do
            if created >= 10 then break end
            local angle = rng:NextNumber(-math.pi, math.pi)
            local radius = math.sqrt(rng:NextNumber()) * 38
            if add("Tree", center.X + math.cos(angle)*radius,
                center.Y + math.sin(angle)*radius) then
                created += 1
            end
        end
    end
    local function scatter(kind, goal)
        local made = 0
        for _try = 1, goal * 60 do
            if made >= goal then break end
            local x = rng:NextNumber(-Config.MapSize/2 + 20, Config.MapSize/2 - 20)
            local z = rng:NextNumber(-Config.MapSize/2 + 20, Config.MapSize/2 - 20)
            if add(kind,x,z) then made += 1 end
        end
    end
    scatter("Tree", 35)
    scatter("Rock", 63)
    scatter("Gold", 20)

    local count = {Tree = 0, Rock = 0, Gold = 0}
    for _, model in ipairs(resources:GetChildren()) do
        local kind = model:GetAttribute("Kind")
        if count[kind] then count[kind] += 1 end
    end
    print(string.format("[RoMoo] Floresta 3D: %d arvores, %d pedras e %d ouros permanentes.",
        count.Tree, count.Rock, count.Gold))

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
