--!nonstrict
-- Fauna simplificada para o RoMoo io: animais herbívoros fogem, predadores perseguem.
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local AnimalModels = require(script.Parent:WaitForChild("AnimalModels"))
local CreatureGait = require(script.Parent:WaitForChild("CreatureGait"))
local Rules = require(script.Parent:WaitForChild("MapRules"))
local CombatVisibility = require(script.Parent:WaitForChild("CombatVisibility"))
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
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
    Boar = {sourceId = 9, color = Color3.fromRGB(127, 85, 68), health = 155, speed = 18,
        food = 45, xp = 60, count = 3, hostile = true, damage = 16},
    Yeti = {sourceId = 10, color = Color3.fromRGB(233, 241, 243), health = 470, speed = 13,
        food = 130, xp = 160, count = 1, hostile = true, damage = 27, biome = "Snow"},
}
local folder
local states = {}
local mapHalf = 260
-- Lobos usam Wolves.start e seu proprio sistema de IA. Nao duplicar lobos.
local speciesOrder = {"Cow","Pig","Sheep","Bull","Bully","Boar","Yeti"}
-- Spatial hash estatico: os recursos do RoMoo nao desaparecem e nao
-- precisam ser lidos 300 vezes por animal em cada tick de IA.
local resourceGrid = {}
local TILE = 18
local function cell(x,z)
    return tostring(math.floor(x/TILE))..":"..tostring(math.floor(z/TILE))
end
local function indexResources(world)
    resourceGrid = {}
    local resources = world:FindFirstChild("Resources")
    if not resources then return end
    for _,resource in ipairs(resources:GetChildren()) do
        local core = resource.PrimaryPart
        if core then
            local point = core.Position
            local key = cell(point.X,point.Z)
            if not resourceGrid[key] then resourceGrid[key] = {} end
            table.insert(resourceGrid[key],{
                x=point.X, z=point.Z, blocks=core.CanCollide
            })
        end
    end
end
local function nearResource(point,squaredDistance,blockingOnly)
    local ix,iz = math.floor(point.X/TILE),math.floor(point.Z/TILE)
    for dx=-1,1 do
        for dz=-1,1 do
            local entries=resourceGrid[tostring(ix+dx)..":"..tostring(iz+dz)]
            if entries then
                for _,item in ipairs(entries) do
                    if not blockingOnly or item.blocks then
                        local x,z=point.X-item.x,point.Z-item.z
                        if x*x+z*z < squaredDistance then return true end
                    end
                end
            end
        end
    end
    return false
end

-- Substitui os protótipos pelas malhas do Roblox Studio se o usuário importar
-- os arquivos CC0 para ServerStorage/RoMooAnimalModels/<Cow|Bull|Wolf|Sheep>.
local function attachImportedVisual(model, core, kind)
    if Config.VoxelThemeEnabled then return false end
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

-- Movimento por steering 2D: permite contornar árvores, rochas e
-- construções sem PhysicConstraints em dezenas de criaturas.
local function openSpace(point, ownModel)
    if not Rules.insideMap(Config,point,20)
        or Rules.isRiver(Config,point,10) then return false end
    if nearResource(point,58,true) then return false end
    local world = folder and folder.Parent
    local buildings = world and world:FindFirstChild("Buildings")
    if buildings then
        for _,structure in ipairs(buildings:GetChildren()) do
            local core=structure.PrimaryPart
            if core and core.CanCollide then
                local dx,dz=core.Position.X-point.X,core.Position.Z-point.Z
                if dx*dx+dz*dz < 66 then return false end
            end
        end
    end
    return true
end

local function freeSpawnPoint(point, kind)
    if not Rules.insideMap(Config,point,22)
        or Rules.isRiver(Config,point,14) then return false end
    if kind == "Yeti" then
        if not Rules.isSnow(Config,point) then return false end
    elseif Rules.isSnow(Config,point) then
        return false
    end
    if nearResource(point,12*12,false) then return false end
    for _,animal in ipairs(folder:GetChildren()) do
        if animal.PrimaryPart then
            local p=animal.PrimaryPart.Position
            local x,z=p.X-point.X,p.Z-point.Z
            if x*x+z*z < 10*10 then return false end
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
        if Vector3.new(candidate.X, 0, candidate.Z).Magnitude > 70
            and freeSpawnPoint(candidate,kind) then
            pos = candidate
            break
        end
    end
    if not pos then return nil end

    local model = Instance.new("Model")
    model.Name = kind
    model:SetAttribute("Kind", kind)
    model:SetAttribute("SourceTypeId", def.sourceId)
    model:SetAttribute("Hostile", def.hostile)
    model:SetAttribute("Health", def.health)
    model:SetAttribute("MaxHealth", def.health)
    model.Parent = folder
    local cf = CFrame.new(pos)
    local core = part("Core", Vector3.new(5.8, 4.5, 7.8), Vector3.zero,
        def.color, Enum.PartType.Block, model, cf)
    core.Transparency = 1
    model.PrimaryPart = core
    -- Hitbox invisível para flechas e detecção por raycast, sem colisão física.
    core.CanQuery = true
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
        facing = Vector3.new(0,0,-1), lastFarUpdate = -1e8,
    }
    return model
end

-- Uma unica leitura de jogadores para toda a rodada de IA.
local function snapshotTargets()
    local targets = {}
    for _,player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root and hum and hum.Health > 0
            and not char:FindFirstChildOfClass("ForceField") then
            table.insert(targets,{position=root.Position,humanoid=hum})
        end
    end
    return targets
end

local function directionToAnimal(animalPosition, maxDist, targets)
    local chosen, hum, best = nil, nil, maxDist*maxDist
    local closest = math.huge
    for _,entry in ipairs(targets) do
        local dx = entry.position.X-animalPosition.X
        local dz = entry.position.Z-animalPosition.Z
        local distance2 = dx*dx + dz*dz
        if distance2 < closest then closest=distance2 end
        if distance2 < best then
            best=distance2
            chosen=Vector3.new(dx,0,dz)
            hum=entry.humanoid
        end
    end
    return chosen, if chosen then math.sqrt(best) else math.huge, hum, closest
end

function Animals.create(world, mapSize)
    local existing = world:FindFirstChild("Animals")
    if existing then existing:Destroy() end
    folder = Instance.new("Folder")
    folder.Name = "Animals"
    folder.Parent = world
    states = {}
    mapHalf = math.floor(mapSize / 2)
    indexResources(world)
    for _,kind in ipairs(speciesOrder) do
        local def=defs[kind]
        for _ = 1, def.count do spawn(kind) end
    end
    print("[RoMoo FAUNA] Espécies ativas: vaca, porco, ovelha, touro, touro alfa, javali e yeti.")

    task.spawn(function()
        while folder and folder.Parent do
            local dt = task.wait(0.15)
            dt = math.min(dt, 0.3)
            local now = os.clock()
            local targets = snapshotTargets()
            for model, state in pairs(states) do
                if not model.Parent or not model.PrimaryPart then
                    states[model] = nil
                else
                    local def = defs[state.kind]
                    local pos = model.PrimaryPart.Position
                    local detection = if def.hostile then 42 else if now < state.panicUntil then 58 else 26
                    local playerDelta, distance, hum, nearest2 =
                        directionToAnimal(pos, detection, targets)
                    -- Animais fora do alcance de qualquer jogador precisam de
                    -- menos atualizacoes. Isso reduz trafego e PivotTo no servidor.
                    if nearest2 > Config.WildlifeFarDistance*Config.WildlifeFarDistance
                        and now-state.lastFarUpdate < Config.WildlifeFarStep then
                        continue
                    end
                    state.lastFarUpdate = now
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
                    local function at(direction)
                        return Vector3.new(
                            math.clamp(pos.X + direction.X * moveSpeed * dt, -mapHalf + 20, mapHalf - 20),
                            3.6,
                            math.clamp(pos.Z + direction.Z * moveSpeed * dt, -mapHalf + 20, mapHalf - 20))
                    end
                    local nextPos = at(dir)
                    if not openSpace(nextPos, model) then
                        -- Se a linha direta está bloqueada, seguir uma tangente
                        -- e guardar esta direção por um instante para evitar tremor.
                        local turn = state.pathSign or 1
                        local sideways = Vector3.new(-dir.Z * turn, 0, dir.X * turn)
                        local candidate = at(sideways)
                        if openSpace(candidate, model) then
                            dir = sideways
                            nextPos = candidate
                        else
                            state.pathSign = -turn
                            sideways = -sideways
                            candidate = at(sideways)
                            if openSpace(candidate, model) then
                                dir = sideways
                                nextPos = candidate
                            else
                                nextPos = pos
                                state.nextWander = now
                            end
                        end
                    end
                    local moving=dir.Magnitude > 0.1 and (nextPos-pos).Magnitude > .01
                    if moving then
                        -- Pequena animação de caminhada, compatível com Parts e MeshParts,
                        -- sem publicar AnimationIds ou criar joints por animal.
                        local bob = math.abs(math.sin(now * moveSpeed * .72 + state.phase)) * .17
                        local lean = math.sin(now * moveSpeed * .72 + state.phase) * math.rad(2.0)
                        local raised = nextPos + Vector3.new(0, bob, 0)
                        local smooth=state.facing:Lerp(dir,math.clamp(dt*7,0,1))
                        if smooth.Magnitude > .05 then
                            state.facing=smooth.Unit
                        end
                        model:PivotTo(CFrame.lookAt(raised, raised + state.facing) *
                            CFrame.Angles(lean, 0, 0))
                    end
                    CreatureGait.animate(model,now,moveSpeed,if moving then 1 else 0)
                    if def.hostile and playerDelta and hum and hum.Health > 0
                        and distance < 7 and now - state.lastAttack > 1.5 then
                        local char = hum.Parent
                        local humanRoot=char and char:FindFirstChild("HumanoidRootPart")
                        local map=folder.Parent
                        local resources=map and map:FindFirstChild("Resources")
                        local buildings=map and map:FindFirstChild("Buildings")
                        if char and humanRoot and not char:FindFirstChildOfClass("ForceField")
                            and CombatVisibility.clear(pos,humanRoot.Position,resources,buildings) then
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
    if typeof(damage) ~= "number" or damage ~= damage
        or damage <= 0 or damage > 1000 then return 0, 0, false end
    local state = states[model]
    if not state or model.Parent ~= folder then return 0, 0, false end
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
