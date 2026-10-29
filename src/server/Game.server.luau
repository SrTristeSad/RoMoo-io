--!nonstrict
-- Regras autoritativas: o cliente informa item e direção, mas nunca concede dano/recursos.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local World = require(script.Parent:WaitForChild("World"))
local Avatar = require(script.Parent:WaitForChild("Avatar"))
local nodes, buildings = World.create()
local rootFolder = ReplicatedStorage:WaitForChild("RoMoo")
local oldRemotes = rootFolder:FindFirstChild("Remotes")
if oldRemotes then oldRemotes:Destroy() end
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = rootFolder
local actionRemote = Instance.new("RemoteEvent")
actionRemote.Name = "Action"
actionRemote.Parent = remotes
local noticeRemote = Instance.new("RemoteEvent")
noticeRemote.Name = "Notice"
noticeRemote.Parent = remotes

local profiles = {}
local recentDamage = {}
local spikeCooldown = {}

local function notice(player, msg)
    noticeRemote:FireClient(player, msg)
end

local function alive(player)
    local char = player.Character
    if not char then return nil, nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return nil, nil, nil end
    return char, hum, root
end

local function horizontalDistance(a, b)
    return (Vector2.new(a.X, a.Z) - Vector2.new(b.X, b.Z)).Magnitude
end

local function directionFor(root, supplied)
    if typeof(supplied) ~= "Vector3" then return root.CFrame.LookVector end
    if supplied.X ~= supplied.X or supplied.Z ~= supplied.Z then return root.CFrame.LookVector end
    if math.abs(supplied.X) > 100000 or math.abs(supplied.Z) > 100000 then
        return root.CFrame.LookVector
    end
    local v = Vector3.new(supplied.X, 0, supplied.Z)
    if v.Magnitude < 0.05 then return root.CFrame.LookVector end
    return v.Unit
end

local function isAimed(from, at, dir, maxDistance)
    local delta = Vector3.new(at.X - from.X, 0, at.Z - from.Z)
    if delta.Magnitude > maxDistance then return false end
    if delta.Magnitude < 0.1 then return true end
    return delta.Unit:Dot(dir) >= 0.55
end

local function changeResource(player, key, amount)
    local p = profiles[player]
    if not p then return end
    p.stock[key] = math.max(0, (p.stock[key] or 0) + amount)
    player:SetAttribute(key, p.stock[key])
    if key == "Gold" then
        local stats = player:FindFirstChild("leaderstats")
        local entry = stats and stats:FindFirstChild("Ouro")
        if entry then entry.Value = p.stock.Gold end
    end
end

local function refreshUpgrade(player)
    local p = profiles[player]
    if not p then return end
    local pending = 0
    for _, level in ipairs({2, 3}) do
        if p.age >= level and not p.chosen[level] then
            pending = level
            break
        end
    end
    player:SetAttribute("PendingUpgrade", pending)
end

local function awardXP(player, amount)
    local p = profiles[player]
    if not p then return end
    p.xp += amount
    local previousAge = p.age
    for age, threshold in ipairs(Config.AgeThresholds) do
        if p.xp >= threshold then p.age = age end
    end
    player:SetAttribute("XP", p.xp)
    if previousAge ~= p.age then
        player:SetAttribute("Age", p.age)
        refreshUpgrade(player)
        notice(player, "IDADE " .. p.age .. " alcançada!")
    end
end

local function unlocked(player, itemName)
    local item = Config.Items[itemName]
    local p = profiles[player]
    if not item or not p then return false end
    if not item.upgrade then return true end
    return p.chosen[item.upgrade] == itemName
end

local function chooseUpgrade(player, itemName)
    if typeof(itemName) ~= "string" then return end
    local p = profiles[player]
    local item = Config.Items[itemName]
    if not p or not item or not item.upgrade then return end
    local age = item.upgrade
    if p.age < age or p.chosen[age] then return end
    p.chosen[age] = itemName
    player:SetAttribute("Unlock" .. itemName, true)
    refreshUpgrade(player)
    notice(player, item.label .. " desbloqueado!")
end

local function nearestTarget(player, root, direction, range)
    local target = nil
    local best = range
    local pos = root.Position
    for _, model in ipairs(nodes:GetChildren()) do
        if model:IsA("Model") and model.PrimaryPart then
            local dist = horizontalDistance(pos, model.PrimaryPart.Position)
            if dist < best and isAimed(pos, model.PrimaryPart.Position, direction, range) then
                target = {kind = "Resource", instance = model}
                best = dist
            end
        end
    end
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            local char, hum, otherRoot = alive(other)
            if char and hum and otherRoot and not char:FindFirstChildOfClass("ForceField") then
                local dist = horizontalDistance(pos, otherRoot.Position)
                if dist < best and isAimed(pos, otherRoot.Position, direction, range) then
                    target = {kind = "Player", instance = hum}
                    best = dist
                end
            end
        end
    end
    for _, model in ipairs(buildings:GetChildren()) do
        if model:IsA("Model") and model.PrimaryPart and model:GetAttribute("OwnerUserId") ~= player.UserId then
            local dist = horizontalDistance(pos, model.PrimaryPart.Position)
            if dist < best and isAimed(pos, model.PrimaryPart.Position, direction, range) then
                target = {kind = "Building", instance = model}
                best = dist
            end
        end
    end
    return target
end

local function swing(player, root, itemName, direction)
    local weapon = Config.Items[itemName]
    local target = nearestTarget(player, root, direction, weapon.range or Config.AttackRange)
    if not target then return end
    if target.kind == "Resource" then
        local model = target.instance
        local entry = Config.ResourceTypes[model:GetAttribute("Kind")]
        if not entry or not model.PrimaryPart then return end
        local origin = Vector3.new(model.PrimaryPart.Position.X, 0, model.PrimaryPart.Position.Z)
        local gather = weapon.gather or 1
        changeResource(player, entry.inventory, entry.reward * gather)
        awardXP(player, 4 * gather)
        local hp = (model:GetAttribute("Health") or 1) - 1
        if hp > 0 then
            model:SetAttribute("Health", hp)
        else
            local kind = model:GetAttribute("Kind")
            model:Destroy()
            task.delay(Config.ResourceRespawnSeconds, function()
                if nodes.Parent then World.spawnNode(kind, origin, nodes) end
            end)
        end
    elseif target.kind == "Player" then
        local hum = target.instance
        recentDamage[hum] = {attacker = player, at = os.clock()}
        hum:TakeDamage(weapon.damage)
    else
        local model = target.instance
        local hp = (model:GetAttribute("Health") or 1) - weapon.damage
        if hp <= 0 then model:Destroy() else model:SetAttribute("Health", hp) end
    end
end

local function modelPart(name, size, cframe, color, material, parent, collidable)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = material
    part.Anchored = true
    part.CanCollide = collidable
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local function createBuilding(player, itemName, position, direction)
    local item = Config.Items[itemName]
    local model = Instance.new("Model")
    model.Name = itemName
    model:SetAttribute("OwnerUserId", player.UserId)
    model:SetAttribute("Health", item.health)
    model.Parent = buildings
    local facing = if math.abs(direction.X) > math.abs(direction.Z) then math.rad(90) else 0
    if itemName == "WoodWall" or itemName == "StoneWall" then
        local stone = itemName == "StoneWall"
        model.PrimaryPart = modelPart("Wall", Vector3.new(12, 8, 3),
            CFrame.new(position + Vector3.new(0, 4, 0)) * CFrame.Angles(0, facing, 0),
            if stone then Color3.fromRGB(128, 134, 140) else Color3.fromRGB(166, 122, 72),
            if stone then Enum.Material.Slate else Enum.Material.WoodPlanks,
            model, true)
    elseif itemName == "Spikes" then
        local base = modelPart("Base", Vector3.new(9, 1, 9), CFrame.new(position + Vector3.new(0, 0.5, 0)),
            Color3.fromRGB(142, 106, 70), Enum.Material.Wood, model, false)
        model.PrimaryPart = base
        for _, offset in ipairs({
            Vector3.new(-3, 0, -3), Vector3.new(0, 0, -3), Vector3.new(3, 0, -3),
            Vector3.new(-3, 0, 0), Vector3.new(0, 0, 0), Vector3.new(3, 0, 0),
            Vector3.new(-3, 0, 3), Vector3.new(0, 0, 3), Vector3.new(3, 0, 3),
        }) do
            local spike = Instance.new("WedgePart")
            spike.Name = "Espinho"
            spike.Size = Vector3.new(2.5, 3.5, 2.5)
            spike.CFrame = CFrame.new(position + offset + Vector3.new(0, 2, 0))
            spike.Color = Color3.fromRGB(111, 80, 47)
            spike.Material = Enum.Material.Wood
            spike.Anchored = true
            spike.CanCollide = false
            spike.Parent = model
        end
        base.Touched:Connect(function(hit)
            if not model.Parent then return end
            local character = hit:FindFirstAncestorOfClass("Model")
            if not character then return end
            local victim = Players:GetPlayerFromCharacter(character)
            if not victim or victim.UserId == player.UserId then return end
            local hum = character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 or character:FindFirstChildOfClass("ForceField") then return end
            local now = os.clock()
            if (spikeCooldown[hum] or 0) + 1.3 > now then return end
            spikeCooldown[hum] = now
            recentDamage[hum] = {attacker = player, at = now}
            hum:TakeDamage(18)
        end)
    elseif itemName == "Windmill" then
        local base = modelPart("Torre", Vector3.new(4, 12, 4), CFrame.new(position + Vector3.new(0, 6, 0)),
            Color3.fromRGB(191, 150, 87), Enum.Material.Wood, model, true)
        model.PrimaryPart = base
        local rotor = Instance.new("Model")
        rotor.Name = "Rotor"
        rotor.Parent = model
        local blade1 = modelPart("PaHorizontal", Vector3.new(17, 1, 2.5),
            CFrame.new(position + Vector3.new(0, 12.5, 0)), Color3.fromRGB(226, 202, 135), Enum.Material.Wood, rotor, false)
        modelPart("PaVertical", Vector3.new(2.5, 1, 17),
            CFrame.new(position + Vector3.new(0, 12.5, 0)), Color3.fromRGB(226, 202, 135), Enum.Material.Wood, rotor, false)
        rotor.PrimaryPart = blade1
    end
    return model
end

local function build(player, root, itemName, direction)
    local item = Config.Items[itemName]
    local p = profiles[player]
    if not item or item.category ~= "Building" or not p then return end
    local total, same = 0, 0
    for _, model in ipairs(buildings:GetChildren()) do
        if model:GetAttribute("OwnerUserId") == player.UserId then
            total += 1
            if model.Name == itemName then same += 1 end
        end
    end
    if total >= Config.PlayerMaxStructures or same >= item.limit then
        notice(player, "Limite de construções alcançado.")
        return
    end
    for resource, cost in pairs(item.cost) do
        if (p.stock[resource] or 0) < cost then
            notice(player, "Recursos insuficientes: " .. item.label)
            return
        end
    end
    local point = root.Position + direction * Config.BuildDistance
    local position = Vector3.new(math.round(point.X / 3) * 3, 0, math.round(point.Z / 3) * 3)
    local max = Config.MapSize / 2 - 17
    if math.abs(position.X) > max or math.abs(position.Z) > max then return end
    if horizontalDistance(position, Vector3.zero) < Config.SpawnProtectionRadius then
        notice(player, "Não construa no ponto de nascimento.")
        return
    end
    for _, model in ipairs(buildings:GetChildren()) do
        if model:IsA("Model") and model.PrimaryPart and
            horizontalDistance(position, model.PrimaryPart.Position) < Config.BuildMinSeparation then
            notice(player, "Espaço ocupado.")
            return
        end
    end
    for _, model in ipairs(nodes:GetChildren()) do
        if model:IsA("Model") and model.PrimaryPart and horizontalDistance(position, model.PrimaryPart.Position) < 9 then
            notice(player, "Existe um recurso nesse espaço.")
            return
        end
    end
    for _, other in ipairs(Players:GetPlayers()) do
        local _, _, otherRoot = alive(other)
        if otherRoot and horizontalDistance(position, otherRoot.Position) < 5 then
            notice(player, "Há um jogador nesse espaço.")
            return
        end
    end
    for resource, cost in pairs(item.cost) do changeResource(player, resource, -cost) end
    createBuilding(player, itemName, position, direction)
end

local function eat(player, humanoid, itemName)
    local item = Config.Items[itemName]
    local p = profiles[player]
    if not p or not item or item.category ~= "Food" then return end
    if humanoid.Health >= humanoid.MaxHealth or p.stock.Food < item.foodCost then return end
    changeResource(player, "Food", -item.foodCost)
    humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + item.heal)
end

local function resetRun(player, resetKills)
    local p = profiles[player]
    if not p then return end
    for key, value in pairs(Config.StartingResources) do
        p.stock[key] = value
        player:SetAttribute(key, value)
    end
    local stats = player:FindFirstChild("leaderstats")
    local gold = stats and stats:FindFirstChild("Ouro")
    if gold then gold.Value = 0 end
    if resetKills then
        local kills = stats and stats:FindFirstChild("Abates")
        if kills then kills.Value = 0 end
    end
    p.xp = 0
    p.age = 1
    p.chosen = {}
    for _, name in ipairs({"Axe", "Sword", "StoneWall", "Cookie"}) do
        player:SetAttribute("Unlock" .. name, false)
    end
    player:SetAttribute("Age", 1)
    player:SetAttribute("XP", 0)
    player:SetAttribute("PendingUpgrade", 0)
    player:SetAttribute("SelectedItem", "Hammer")
end

actionRemote.OnServerEvent:Connect(function(player, action, itemName, suppliedDirection)
    if typeof(action) ~= "string" then return end
    if action == "Upgrade" then
        chooseUpgrade(player, itemName)
        return
    end
    if action == "Select" then
        if typeof(itemName) == "string" and unlocked(player, itemName) then
            player:SetAttribute("SelectedItem", itemName)
        end
        return
    end
    if action ~= "Use" or typeof(itemName) ~= "string" or not unlocked(player, itemName) then return end
    local item = Config.Items[itemName]
    if item.category ~= "Food" and player:GetAttribute("SelectedItem") ~= itemName then return end
    local _, hum, root = alive(player)
    local p = profiles[player]
    if not p or not hum or not root then return end
    local now = os.clock()
    local cooldown = if item.category == "Food" then Config.EatCooldown else Config.UseCooldown
    if (p.lastUse or -1e8) + cooldown > now then return end
    p.lastUse = now
    local direction = directionFor(root, suppliedDirection)
    if item.category == "Weapon" then
        swing(player, root, itemName, direction)
    elseif item.category == "Building" then
        build(player, root, itemName, direction)
    elseif item.category == "Food" then
        eat(player, hum, itemName)
    end
end)

local function addPlayer(player)
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player
    local gold = Instance.new("IntValue")
    gold.Name = "Ouro"
    gold.Parent = stats
    local kills = Instance.new("IntValue")
    kills.Name = "Abates"
    kills.Parent = stats
    profiles[player] = {stock = {}, xp = 0, age = 1, chosen = {}, lastUse = -1e8, firstSpawn = true}
    resetRun(player, true)
    player.CharacterAdded:Connect(function(char)
        local p = profiles[player]
        if not p then return end
        if p.firstSpawn then
            p.firstSpawn = false
        else
            resetRun(player, false)
            for _, model in ipairs(buildings:GetChildren()) do
                if model:GetAttribute("OwnerUserId") == player.UserId then model:Destroy() end
            end
        end
        local hum = char:WaitForChild("Humanoid", 10)
        if not hum or not hum:IsA("Humanoid") then return end
        Avatar.attach(player, char, hum)
        hum.Died:Connect(function()
            local record = recentDamage[hum]
            if record and os.clock() - record.at < 10 and record.attacker.Parent == Players then
                local killer = record.attacker
                local killerStats = killer:FindFirstChild("leaderstats")
                local counter = killerStats and killerStats:FindFirstChild("Abates")
                if counter then counter.Value += 1 end
                awardXP(killer, 40)
                notice(killer, "+1 abate!")
            end
            recentDamage[hum] = nil
            spikeCooldown[hum] = nil
        end)
    end)
end

Players.PlayerAdded:Connect(addPlayer)
for _, player in ipairs(Players:GetPlayers()) do addPlayer(player) end

Players.PlayerRemoving:Connect(function(player)
    profiles[player] = nil
    for _, model in ipairs(buildings:GetChildren()) do
        if model:GetAttribute("OwnerUserId") == player.UserId then model:Destroy() end
    end
end)

-- Cada moinho concede ouro e XP ao proprietário vivo enquanto a estrutura existir.
task.spawn(function()
    while true do
        task.wait(Config.WindmillTickSeconds)
        for _, model in ipairs(buildings:GetChildren()) do
            if model.Name == "Windmill" then
                local owner = Players:GetPlayerByUserId(model:GetAttribute("OwnerUserId"))
                if owner and profiles[owner] then
                    changeResource(owner, "Gold", Config.Items.Windmill.goldPerTick)
                    awardXP(owner, Config.Items.Windmill.goldPerTick)
                end
                local rotor = model:FindFirstChild("Rotor")
                if rotor and rotor:IsA("Model") and rotor.PrimaryPart then
                    rotor:PivotTo(rotor:GetPivot() * CFrame.Angles(0, math.rad(22), 0))
                end
            end
        end
    end
end)

print("[RoMoo io] Modo clássico: coleta por ataque, progressão, construções e moinhos ativos.")
