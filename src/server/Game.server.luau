--!strict
-- RoMoo io MVP: servidor é a autoridade sobre inventário, alcance e dano.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local World = require(script.Parent:WaitForChild("World"))

local nodes, buildings = World.create()
local sharedFolder = ReplicatedStorage:WaitForChild("RoMoo")

local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = sharedFolder

local actionRemote = Instance.new("RemoteEvent")
actionRemote.Name = "Action"
actionRemote.Parent = remotes

local noticeRemote = Instance.new("RemoteEvent")
noticeRemote.Name = "Notice"
noticeRemote.Parent = remotes

local inventories = {}
local cooldowns = {}
local recentDamage = {}
local spikeHits = {}

local function notify(player, message)
    noticeRemote:FireClient(player, message)
end

local function getAlive(player)
    local character = player.Character
    if not character then return nil, nil, nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root or humanoid.Health <= 0 then
        return nil, nil, nil
    end
    return character, humanoid, root
end

local function distanceXZ(a, b)
    return (Vector2.new(a.X, a.Z) - Vector2.new(b.X, b.Z)).Magnitude
end

local function addResource(player, key, amount)
    local stock = inventories[player]
    if not stock then return end
    stock[key] = (stock[key] or 0) + amount
    player:SetAttribute(key, stock[key])
    if key == "Gold" then
        local stats = player:FindFirstChild("leaderstats")
        local gold = stats and stats:FindFirstChild("Ouro")
        if gold then gold.Value = stock.Gold end
    end
end

local function findNode(position)
    local closest = nil
    local bestDistance = Config.GatherRange
    for _, model in ipairs(nodes:GetChildren()) do
        if model:IsA("Model") and model.PrimaryPart then
            local distance = distanceXZ(position, model.PrimaryPart.Position)
            if distance < bestDistance then
                closest = model
                bestDistance = distance
            end
        end
    end
    return closest
end

local function gather(player, root)
    local model = findNode(root.Position)
    if not model or not model.PrimaryPart then
        notify(player, "Chegue perto de uma árvore, rocha ou arbusto.")
        return
    end
    local kind = model:GetAttribute("Kind")
    local entry = Config.ResourceTypes[kind]
    if not entry then return end

    local position = model.PrimaryPart.Position
    local stockPosition = Vector3.new(position.X, 0, position.Z)
    addResource(player, entry.inventory, entry.reward)
    local health = (model:GetAttribute("Health") or 1) - 1
    if health > 0 then
        model:SetAttribute("Health", health)
    else
        model:Destroy()
        task.delay(Config.ResourceRespawnSeconds, function()
            if nodes.Parent then
                World.spawnNode(kind, stockPosition, nodes)
            end
        end)
    end
end

local function findEnemy(player, position)
    local targetHumanoid = nil
    local targetPlayer = nil
    local bestDistance = Config.AttackRange
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            local character, humanoid, root = getAlive(other)
            if character and humanoid and root then
                local distance = distanceXZ(position, root.Position)
                if distance < bestDistance then
                    targetHumanoid, targetPlayer = humanoid, other
                    bestDistance = distance
                end
            end
        end
    end
    return targetHumanoid, targetPlayer
end

local function findEnemyBuilding(player, position)
    local closest = nil
    local bestDistance = Config.AttackRange
    for _, model in ipairs(buildings:GetChildren()) do
        if model:IsA("Model") and model.PrimaryPart and model:GetAttribute("OwnerUserId") ~= player.UserId then
            local distance = distanceXZ(position, model.PrimaryPart.Position)
            if distance < bestDistance then
                closest = model
                bestDistance = distance
            end
        end
    end
    return closest
end

local function attack(player, root)
    local humanoid, enemy = findEnemy(player, root.Position)
    if humanoid and enemy then
        if not enemy.Character or enemy.Character:FindFirstChildOfClass("ForceField") then
            notify(player, "O jogador ainda está protegido ao nascer.")
            return
        end
        recentDamage[humanoid] = { attacker = player, at = os.clock() }
        humanoid:TakeDamage(Config.AttackDamage)
        return
    end
    local building = findEnemyBuilding(player, root.Position)
    if building then
        local health = (building:GetAttribute("Health") or 1) - Config.AttackDamage
        if health <= 0 then
            building:Destroy()
        else
            building:SetAttribute("Health", health)
        end
        return
    end
    notify(player, "Nenhum adversário ou construção inimiga no alcance.")
end

local function makeBuildingPart(name, size, cf, color, material, model, collidable)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material
    p.Anchored = true
    p.CanCollide = collidable
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = model
    return p
end

local function createBuilding(player, kind, center, facing)
    local definition = Config.Buildings[kind]
    local model = Instance.new("Model")
    model.Name = kind
    model:SetAttribute("OwnerUserId", player.UserId)
    model:SetAttribute("Health", definition.health)
    model.Parent = buildings

    if kind == "Wall" then
        local turn = if math.abs(facing.X) > math.abs(facing.Z) then math.rad(90) else 0
        local base = makeBuildingPart(
            "WallBlock", Vector3.new(12, 8, 2),
            CFrame.new(center + Vector3.new(0, 4, 0)) * CFrame.Angles(0, turn, 0),
            Color3.fromRGB(150, 108, 61), Enum.Material.WoodPlanks, model, true
        )
        model.PrimaryPart = base
    else
        local trigger = makeBuildingPart(
            "TrapTrigger", Vector3.new(7, 1, 7), CFrame.new(center + Vector3.new(0, 0.5, 0)),
            Color3.fromRGB(132, 92, 58), Enum.Material.WoodPlanks, model, false
        )
        model.PrimaryPart = trigger
        for _, offset in ipairs({
            Vector3.new(-2, 0, -2), Vector3.new(2, 0, -2),
            Vector3.new(-2, 0, 2), Vector3.new(2, 0, 2),
        }) do
            local spike = Instance.new("WedgePart")
            spike.Name = "Espinho"
            spike.Size = Vector3.new(2, 3, 2)
            spike.CFrame = CFrame.new(center + offset + Vector3.new(0, 2, 0))
            spike.Color = Color3.fromRGB(121, 82, 55)
            spike.Material = Enum.Material.Wood
            spike.Anchored = true
            spike.CanCollide = false
            spike.Parent = model
        end
        trigger.Touched:Connect(function(hit)
            if not model.Parent then return end
            local character = hit:FindFirstAncestorOfClass("Model")
            if not character then return end
            local victim = Players:GetPlayerFromCharacter(character)
            if not victim or victim.UserId == player.UserId then return end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return end
            if character:FindFirstChildOfClass("ForceField") then return end
            local now = os.clock()
            if (spikeHits[humanoid] or 0) + 1.3 > now then return end
            spikeHits[humanoid] = now
            recentDamage[humanoid] = { attacker = player, at = now }
            humanoid:TakeDamage(12)
        end)
    end
    return model
end

local function build(player, root, kind)
    local definition = Config.Buildings[kind]
    if not definition then return end
    local stock = inventories[player]
    if not stock then return end

    local total = 0
    for _, model in ipairs(buildings:GetChildren()) do
        if model:GetAttribute("OwnerUserId") == player.UserId then
            total += 1
        end
    end
    if total >= Config.PlayerMaxStructures then
        notify(player, "Limite de construções alcançado.")
        return
    end

    for resource, amount in pairs(definition.cost) do
        if (stock[resource] or 0) < amount then
            notify(player, "Recursos insuficientes para construir " .. definition.label .. ".")
            return
        end
    end

    local position = root.Position + root.CFrame.LookVector * 10
    local center = Vector3.new(math.round(position.X / 4) * 4, 0, math.round(position.Z / 4) * 4)
    if math.abs(center.X) > Config.MapSize / 2 - 18 or math.abs(center.Z) > Config.MapSize / 2 - 18 then
        notify(player, "Muito perto da borda do mapa.")
        return
    end
    if distanceXZ(center, Vector3.zero) < 26 then
        notify(player, "Não é permitido construir perto do ponto de nascimento.")
        return
    end
    for _, model in ipairs(buildings:GetChildren()) do
        if model:IsA("Model") and model.PrimaryPart and distanceXZ(center, model.PrimaryPart.Position) < 12 then
            notify(player, "Existe outra construção nesse espaço.")
            return
        end
    end
    for _, model in ipairs(nodes:GetChildren()) do
        if model:IsA("Model") and model.PrimaryPart and distanceXZ(center, model.PrimaryPart.Position) < 8 then
            notify(player, "Há um recurso natural nesse espaço.")
            return
        end
    end

    for resource, amount in pairs(definition.cost) do
        addResource(player, resource, -amount)
    end
    createBuilding(player, kind, center, root.CFrame.LookVector)
    notify(player, definition.label .. " construída!")
end

local function eat(player, humanoid)
    local stock = inventories[player]
    if not stock then return end
    if humanoid.Health >= humanoid.MaxHealth then
        notify(player, "Sua vida já está cheia.")
        return
    end
    if (stock.Food or 0) < Config.EatCost then
        notify(player, "Você precisa de mais comida.")
        return
    end
    addResource(player, "Food", -Config.EatCost)
    humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + Config.EatHeal)
end

local function canAct(player, action)
    local interval = Config.Cooldowns[action]
    if not interval then return false end
    local now = os.clock()
    local playerCooldowns = cooldowns[player]
    if not playerCooldowns then return false end
    if (playerCooldowns[action] or -1e8) + interval > now then return false end
    playerCooldowns[action] = now
    return true
end

actionRemote.OnServerEvent:Connect(function(player, action, argument)
    if typeof(action) ~= "string" then return end
    local _, humanoid, root = getAlive(player)
    if not humanoid or not root then return end
    local cooldownKind = if action == "Wall" or action == "Trap" then "Build" else action
    if not canAct(player, cooldownKind) then return end

    if action == "Gather" then
        gather(player, root)
    elseif action == "Attack" then
        attack(player, root)
    elseif action == "Eat" then
        eat(player, humanoid)
    elseif action == "Wall" or action == "Trap" then
        build(player, root, action)
    end
end)

local function onPlayerAdded(player)
    local stock = {}
    for name, quantity in pairs(Config.StartingResources) do
        stock[name] = quantity
        player:SetAttribute(name, quantity)
    end
    player:SetAttribute("Eliminations", 0)
    inventories[player] = stock
    cooldowns[player] = {}

    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player
    local gold = Instance.new("IntValue")
    gold.Name = "Ouro"
    gold.Value = 0
    gold.Parent = stats
    local kills = Instance.new("IntValue")
    kills.Name = "Abates"
    kills.Value = 0
    kills.Parent = stats

    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid", 10)
        if not humanoid or not humanoid:IsA("Humanoid") then return end
        humanoid.Died:Connect(function()
            local damage = recentDamage[humanoid]
            if damage and os.clock() - damage.at < 10 and damage.attacker.Parent == Players then
                local killer = damage.attacker
                killer:SetAttribute("Eliminations", (killer:GetAttribute("Eliminations") or 0) + 1)
                local killerStats = killer:FindFirstChild("leaderstats")
                local counter = killerStats and killerStats:FindFirstChild("Abates")
                if counter then counter.Value += 1 end
                notify(killer, "+1 abate!")
            end
            recentDamage[humanoid] = nil
            spikeHits[humanoid] = nil
        end)
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end

Players.PlayerRemoving:Connect(function(player)
    inventories[player] = nil
    cooldowns[player] = nil
    for _, model in ipairs(buildings:GetChildren()) do
        if model:GetAttribute("OwnerUserId") == player.UserId then
            model:Destroy()
        end
    end
end)

print("[RoMoo io] MVP 0.1 iniciado: mapa, coleta, PvP e construções.")
