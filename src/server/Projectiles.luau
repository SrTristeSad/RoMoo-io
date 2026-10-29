--!nonstrict
-- Projéteis autoritativos em studs/segundo, inspirados no ciclo
-- world/projectiles.lua do servidor Moo-IO. Não reusa WebSockets nem física 2D.
-- Estado transitório e consumo de munição permanecem sob controle do servidor.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Projectiles = {}
local active = {}
local started = false
local container
local MAX_PROJECTILES = 90
local MAX_PER_PLAYER = 9
local maxDistanceFromMap = 400

local function colorPart(name, color)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = Vector3.new(.42, .42, 3.2)
    part.Material = Enum.Material.Wood
    part.Color = color
    part.CastShadow = false
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    return part
end

local function discard(record)
    if record.part then record.part:Destroy() end
    active[record] = nil
end

local function resolveCollision(record, hit, at)
    local hitModel = hit:FindFirstAncestorOfClass("Model")
    if not hitModel then return false end
    if hitModel.Parent == record.context.creatures then
        local food, xp, killed = record.context.animals.hit(hitModel, record.damage)
        record.context.emitFX("Hit", at, record.damage, "Animal")
        if killed then record.context.onAnimalKilled(record.owner, food, xp) end
        return true
    elseif hitModel.Parent == record.context.buildings then
        local builderId = hitModel:GetAttribute("OwnerUserId")
        local builder = if typeof(builderId) == "number" then Players:GetPlayerByUserId(builderId) else nil
        if builder and record.context.clans.allies(record.owner, builder) then return false end
        local hp = (hitModel:GetAttribute("Health") or 0) - record.damage
        record.context.emitFX("Hit", at, record.damage, "Structure")
        if hp <= 0 then hitModel:Destroy() else hitModel:SetAttribute("Health", hp) end
        return true
    end
    local human = hitModel:FindFirstChildOfClass("Humanoid")
    if human and human.Health > 0 then
        local target = Players:GetPlayerFromCharacter(hitModel)
        if target and target ~= record.owner and
            not record.context.clans.allies(record.owner, target) and
            not hitModel:FindFirstChildOfClass("ForceField") then
            record.context.onPlayerHit(record.owner, human, record.damage)
            record.context.emitFX("Hit", at, record.damage, "Player")
            return true
        end
    end
    return false
end

local function tickProjectile(record, dt)
    local step = math.min(0.09, dt)
    local distance = math.min(record.speed * step, record.remaining)
    if distance <= 0 then discard(record) return end
    local movement = record.direction * distance
    local hit = workspace:Raycast(record.position, movement, record.params)
    if hit then
        local consumed = resolveCollision(record, hit.Instance, hit.Position)
        if consumed then
            discard(record)
            return
        end
        -- Hit sem dano: parede, árvore, rocha ou alvo aliado. Pare a flecha.
        discard(record)
        return
    end
    record.position += movement
    record.remaining -= distance
    if record.remaining <= 0 or math.abs(record.position.X) > maxDistanceFromMap
        or math.abs(record.position.Z) > maxDistanceFromMap then
        discard(record)
        return
    end
    record.part.CFrame = CFrame.lookAt(record.position, record.position + record.direction)
end

function Projectiles.start(world)
    if started then return end
    started = true
    container = Instance.new("Folder")
    container.Name = "Projectiles"
    container.Parent = world

    RunService.Heartbeat:Connect(function(dt)
        for record in pairs(active) do
            if not record.owner.Parent or not record.part.Parent then
                discard(record)
            else
                tickProjectile(record, dt)
            end
        end
    end)
end

function Projectiles.fire(owner, root, direction, weapon, context)
    if not container or not container.Parent then return false end
    local count = 0
    local ownedCount = 0
    for record in pairs(active) do
        count += 1
        if record.owner == owner then ownedCount += 1 end
    end
    if count >= MAX_PROJECTILES or ownedCount >= MAX_PER_PLAYER then return false end
    local direction2D = Vector3.new(direction.X, 0, direction.Z)
    if direction2D.Magnitude < .1 then return false end
    direction2D = direction2D.Unit
    local spawn = root.Position + Vector3.new(0, .4, 0) + direction2D * 4
    local part = colorPart("Flecha", Color3.fromRGB(204, 159, 96))
    part.CFrame = CFrame.lookAt(spawn, spawn + direction2D)
    part.Parent = container

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local decoration = container.Parent:FindFirstChild("Decorations")
    local excluded = {root.Parent, container}
    if decoration then table.insert(excluded, decoration) end
    params.FilterDescendantsInstances = excluded

    active[{
        owner = owner, part = part, position = spawn, direction = direction2D,
        remaining = math.clamp(weapon.range or 100, 2, 160),
        speed = math.clamp(weapon.projectileSpeed or 110, 10, 250),
        damage = weapon.damage or 10,
        params = params, context = context,
    }] = true
    return true
end

return Projectiles
