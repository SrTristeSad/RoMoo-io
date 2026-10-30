--!nonstrict
-- Cenário de teste 3D: Terrain nativo, água real, árvores, pedras e minério de ouro.
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Config = require(ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local Rules = require(script.Parent:WaitForChild("MapRules"))

local World = {}
local rng = Random.new(Config.Seed)

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

-- O Moo-IO usa um rio horizontal e correnteza no sentido +X.
-- A geometria aquatica e formada de agua Terrain; sem pontes.
local function createRiver(terrain, folder)
    local size = Config.MapSize
    local width = Config.River.Width
    local bank = Config.River.BankWidth
    terrain.WaterColor = Color3.fromRGB(57, 151, 189)
    terrain.WaterTransparency = .25
    terrain.WaterReflectance = .08
    terrain.WaterWaveSize = .25
    terrain.WaterWaveSpeed = 13

    terrain:FillBlock(CFrame.new(0,-2.8,0),
        Vector3.new(size-2,14,width+7),Enum.Material.Air)
    terrain:FillBlock(CFrame.new(0,-9,0),
        Vector3.new(size-2,6,width+8),Enum.Material.Sand)
    terrain:FillBlock(CFrame.new(0,-3,0),
        Vector3.new(size-2,6,width),Enum.Material.Water)
    for _,side in ipairs({-1,1}) do
        terrain:FillBlock(CFrame.new(0,-1,side*(width/2+bank/2)),
            Vector3.new(size-3,2,bank),Enum.Material.Sand)
    end

    local current = Instance.new("Folder")
    current.Name = "CorrentezaLeste"
    current:SetAttribute("DirectionX",Config.River.CurrentDirection)
    current:SetAttribute("Speed",Config.River.CurrentSpeed)
    current.Parent = folder
    for x = -size/2+25,size/2-25,42 do
        local marker=makePart(current,"Espuma",Vector3.new(.3,.3,.3),
            CFrame.new(x,0.18,0),Color3.fromRGB(192,240,245),
            Enum.Material.SmoothPlastic,{query=false,shadow=false})
        marker.Transparency=1
        local emitter=Instance.new("ParticleEmitter")
        emitter.Name="AguaCorrendo"
        emitter.EmissionDirection=Enum.NormalId.Right
        emitter.Rate=2
        emitter.Lifetime=NumberRange.new(1.8,2.7)
        emitter.Speed=NumberRange.new(3,5)
        emitter.Acceleration=Vector3.new(Config.River.CurrentSpeed,0,0)
        emitter.SpreadAngle=Vector2.new(4,9)
        emitter.Size=NumberSequence.new(.27)
        emitter.Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,.3),
            NumberSequenceKeypoint.new(1,1),
        })
        emitter.Color=ColorSequence.new(Color3.fromRGB(204,244,247))
        emitter.LightEmission=.2
        emitter.Parent=marker
    end
    return current
end

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
    local ok = pcall(function()
        local size=visual:GetExtentsSize()
        local longest=math.max(size.X,size.Y,size.Z)
        assert(longest>.02 and longest<5000,"Geometria invalida")
        local wanted=if kind=="Tree" then 13 else if kind=="Bush" then 5.5 else 7.5
        visual:ScaleTo(math.clamp(wanted/longest,.02,12))
        local boundsCF,bounds=visual:GetBoundingBox()
        -- Alinhar a base visivel ao chao; MeshParts importados variam de origem.
        visual:PivotTo(CFrame.new(pos))
        boundsCF,bounds=visual:GetBoundingBox()
        local baseY=boundsCF.Position.Y-bounds.Y*.5
        visual:PivotTo(visual:GetPivot()*CFrame.new(0,-baseY,0))
    end)
    if not ok then visual:Destroy() return nil end
    local center = makePart(model, "Core", Vector3.new(6, 6, 6),
        CFrame.new(pos + Vector3.new(0, 3, 0)), Color3.fromRGB(112, 115, 116),
        Enum.Material.SmoothPlastic, {collide = true})
    center.Transparency = 1
    return center
end

local function createBush(model,pos)
    local core=makePart(model,"Core",Vector3.new(4.6,2.8,4.6),
        CFrame.new(pos+Vector3.new(0,1.4,0)),
        Color3.fromRGB(52,132,69),Enum.Material.Grass,
        {shape=Enum.PartType.Ball,collide=false})
    for _,offset in ipairs({
        Vector3.new(-1.55,1.1,1.2),Vector3.new(1.8,1.7,-.4),
        Vector3.new(.3,2.6,1.0)
    }) do
        makePart(model,"Fruta",Vector3.new(.77,.77,.77),
            CFrame.new(pos+offset),Color3.fromRGB(225,70,69),
            Enum.Material.SmoothPlastic,{shape=Enum.PartType.Ball,collide=false})
    end
    return core
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
            else if kind == "Bush" then createBush(model,pos)
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
    terrain:FillBlock(CFrame.new(0,-6,0),
        Vector3.new(Config.MapSize,12,Config.MapSize),Enum.Material.Grass)
    local half=Config.MapSize*.5
    terrain:FillBlock(CFrame.new(0,-2,-half+Config.SnowDepth*.5),
        Vector3.new(Config.MapSize-8,4,Config.SnowDepth),Enum.Material.Snow)
    terrain:FillBlock(CFrame.new(0,-2,half-Config.DesertDepth*.5),
        Vector3.new(Config.MapSize-8,4,Config.DesertDepth),Enum.Material.Sand)
    local folder = Instance.new("Folder")
    folder.Name = "RoMooWorld"
    folder.Parent = workspace
    createRiver(terrain, folder)

    -- Pedrinhas de margem apenas decorativas.
    for i=1,42 do
        local x=rng:NextNumber(-half+12,half-12)
        local z=(if i%2==0 then -1 else 1) *
            (Config.River.Width*.5+Config.River.BankWidth+rng:NextNumber(.8,6))
        makePart(folder,"SeixoDeMargem",Vector3.new(1.6,.8,1.5),
            CFrame.new(x,.2,z)*CFrame.Angles(0,rng:NextNumber(0,6.28),0),
            Color3.fromRGB(151,154,143),Enum.Material.Slate,
            {shape=Enum.PartType.Ball,query=false,shadow=false})
    end
    -- Como no original, a borda e limite de movimento, nao precipicio.
    local walls=Instance.new("Folder")
    walls.Name="LimitesInvisiveis"
    walls.Parent=folder
    local thickness=12
    local tall=115
    for _,wall in ipairs({
        {Vector3.new(0,tall*.5-35,-half-3),Vector3.new(Config.MapSize+24,tall,thickness)},
        {Vector3.new(0,tall*.5-35,half+3),Vector3.new(Config.MapSize+24,tall,thickness)},
        {Vector3.new(-half-3,tall*.5-35,0),Vector3.new(thickness,tall,Config.MapSize+24)},
        {Vector3.new(half+3,tall*.5-35,0),Vector3.new(thickness,tall,Config.MapSize+24)},
    }) do
        local part=makePart(walls,"Limite",wall[2],CFrame.new(wall[1]),
            Color3.new(1,1,1),Enum.Material.SmoothPlastic,
            {collide=true,query=false,shadow=false})
        part.Transparency=1
    end

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "Nascimento"
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Duration = Config.SpawnProtectionSeconds
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
    -- Distribuicao por setores: adaptacao do world/objects.lua original.
    local spots={}
    local localGrid={}
    local tile=Config.MinimumSeparation
    local function key(x,z)
        return math.floor(x/tile)..":"..math.floor(z/tile)
    end
    local function free(x,z)
        local cx,cz=math.floor(x/tile),math.floor(z/tile)
        for gx=cx-1,cx+1 do
            for gz=cz-1,cz+1 do
                local group=localGrid[gx..":"..gz]
                if group then
                    for _,pos in ipairs(group) do
                        local dx,dz=x-pos.X,z-pos.Z
                        if dx*dx+dz*dz < tile*tile then return false end
                    end
                end
            end
        end
        return true
    end
    local function add(kind,x,z,ignoreWater)
        local position=Vector3.new(x,0,z)
        if not Rules.insideMap(Config,position,17) then return false end
        if kind=="Tree" and not Rules.canPlaceTree(Config,position) then return false end
        if kind=="Bush" and not Rules.canPlaceBush(Config,position) then return false end
        if not ignoreWater and Rules.isRiver(Config,position,5) then return false end
        if (position-Vector3.new(0,0,-64)).Magnitude < 19 then return false end
        if not free(x,z) then return false end
        local name=key(x,z)
        if not localGrid[name] then localGrid[name]={} end
        table.insert(localGrid[name],position)
        table.insert(spots,position)
        World.spawnNode(kind,position,resources)
        return true
    end
    local area=Config.MapSize/Config.AreaCount
    local function sector(kind,count)
        for gx=0,Config.AreaCount-1 do
            for gz=0,Config.AreaCount-1 do
                local inserted=0
                for _=1,140 do
                    if inserted>=count then break end
                    local x=-half+gx*area+rng:NextNumber(5,area-5)
                    local z=-half+gz*area+rng:NextNumber(5,area-5)
                    if add(kind,x,z,false) then inserted+=1 end
                end
            end
        end
    end
    sector("Tree",Config.TreesPerArea)
    sector("Bush",Config.BushesPerArea)

    -- Rochas e ouro podem surgir no rio, como no original.
    local function scatter(kind,count)
        local created=0
        for _=1,count*350 do
            if created>=count then break end
            local x=rng:NextNumber(-half+19,half-19)
            local z=rng:NextNumber(-half+19,half-19)
            if add(kind,x,z,true) then created+=1 end
        end
    end
    scatter("Rock",Config.TotalRocks)
    scatter("Gold",Config.GoldOres)
    local count={Tree=0,Bush=0,Rock=0,Gold=0}
    for _,node in ipairs(resources:GetChildren()) do
        local kind=node:GetAttribute("Kind")
        count[kind]=(count[kind] or 0)+1
    end
    print(("[RoMoo Mapa] %d arvores, %d arbustos, %d rochas, %d minerios; grade %dx%d.")
        :format(count.Tree,count.Bush,count.Rock,count.Gold,Config.AreaCount,Config.AreaCount))

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

    print("[RoMoo] Terreno nativo, rio com correnteza, sem pontes, e "
        .. #resources:GetChildren() .. " recursos 3D.")
    return resources
end

return World
