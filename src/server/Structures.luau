--!nonstrict
-- Estruturas 3D autoritativas do RoMoo; retorno das construções MooMoo.io.
-- Recursos naturais permanecem infinitos. Apenas estruturas têm durabilidade.
local Players = game:GetService("Players")
local Rules = require(script.Parent:WaitForChild("MapRules"))
local Melee = require(script.Parent:WaitForChild("Melee"))

local Structures = {}
local folder, resources, animals, config
local grantGold, grantWolfFood, hitWolf
local registered = {}
local ownerCounts = {}
local lastSpikeHit = {}
local running = false

local function geometry(parent, name, size, cf, color, material, collidable, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material
    p.Shape = shape or Enum.PartType.Block
    p.Anchored = true
    p.CanCollide = collidable == true
    p.CanTouch = false
    p.CanQuery = collidable == true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function buildShape(kind, position, direction, userId)
    local blueprint = config.Buildings[kind]
    local model = Instance.new("Model")
    model.Name = kind
    model:SetAttribute("Kind", kind)
    model:SetAttribute("OwnerUserId", userId)
    model:SetAttribute("Health", blueprint.health)
    model:SetAttribute("MaxHealth", blueprint.health)
    local cf = CFrame.lookAt(position, position + direction)
    if kind == "Wall" then
        local main = geometry(model, "Core", Vector3.new(10, 6, 2),
            cf * CFrame.new(0, 3, 0), Color3.fromRGB(141, 98, 61),
            Enum.Material.WoodPlanks, true)
        model.PrimaryPart = main
        for i = -1, 1 do
            geometry(model, "MadeiraVertical", Vector3.new(1.15, 6.7, 2.4),
                cf * CFrame.new(i * 3.8, 3, 0), Color3.fromRGB(99, 68, 42),
                Enum.Material.Wood, true)
        end
        geometry(model, "Reforco", Vector3.new(10.7, .72, 2.5),
            cf * CFrame.new(0, 5.5, 0), Color3.fromRGB(105, 74, 46),
            Enum.Material.Wood, true)
    elseif kind == "StoneWall" then
        -- Muro resistente com blocos de pedra nativa, desbloqueado na idade 4.
        local wall = geometry(model, "Core", Vector3.new(11.5, 7, 2.8),
            cf * CFrame.new(0, 3.5, 0), Color3.fromRGB(118, 126, 132),
            Enum.Material.Slate, true)
        model.PrimaryPart = wall
        for layer = 0, 2 do
            for column = -1, 1 do
                local x = column * 3.55 + (if layer % 2 == 0 then 0 else .45)
                geometry(model, "PedraTalhada",
                    Vector3.new(3.36, 2.08, 3.05),
                    cf * CFrame.new(x, 1.13 + layer * 2.18, -.04),
                    if (layer + column) % 2 == 0 then Color3.fromRGB(146, 151, 152)
                    else Color3.fromRGB(106, 114, 120),
                    Enum.Material.Rock, true)
            end
        end
        geometry(model, "TopoDePedra", Vector3.new(12.4, .75, 3.4),
            cf * CFrame.new(0, 7.1, 0), Color3.fromRGB(98, 108, 112),
            Enum.Material.Slate, true)
    elseif kind == "Spikes" then
        local base = geometry(model, "Core", Vector3.new(8, .7, 8),
            cf * CFrame.new(0, .35, 0), Color3.fromRGB(95, 80, 59),
            Enum.Material.Wood, false)
        base.CanQuery = true
        model.PrimaryPart = base
        for x = -1,1 do
            for z = -1,1 do
                local spike = Instance.new("WedgePart")
                spike.Name = "Espinho"
                spike.Size = Vector3.new(1.65, 4.0, 1.7)
                spike.CFrame = cf * CFrame.new(x * 2.35, 2.25, z * 2.3)
                spike.Color = Color3.fromRGB(156, 159, 150)
                spike.Material = Enum.Material.Metal
                spike.Anchored = true
                spike.CanCollide = false
                spike.CanTouch = false
                spike.CanQuery = false
                spike.Parent = model
            end
        end
    elseif kind == "Windmill" then
        local main = geometry(model, "Core", Vector3.new(3.8, 9, 3.8),
            cf * CFrame.new(0, 4.5, 0), Color3.fromRGB(146, 110, 73),
            Enum.Material.Wood, true)
        model.PrimaryPart = main
        geometry(model, "Telhado", Vector3.new(6, 1.2, 6),
            cf * CFrame.new(0, 9.3, 0), Color3.fromRGB(99, 73, 55),
            Enum.Material.WoodPlanks, true)
        local blades = Instance.new("Folder")
        blades.Name = "Pas"
        blades.Parent = model
        local pivot = cf * CFrame.new(0, 7.6, -2.5)
        model:SetAttribute("RotorBaseX", pivot.Position.X)
        model:SetAttribute("RotorBaseY", pivot.Position.Y)
        model:SetAttribute("RotorBaseZ", pivot.Position.Z)
        for i = 0,3 do
            local a = math.pi * i * .5
            geometry(blades, "Pa", Vector3.new(1.0, 4.3, .4),
                pivot * CFrame.Angles(0,0,a) * CFrame.new(0, 2.15, 0),
                Color3.fromRGB(219, 204, 169), Enum.Material.WoodPlanks, false)
        end
    else
        model:Destroy()
        return nil
    end
    model.Parent = folder
    return model
end

local function healthBar(model, remaining, maximum)
    local gui = model:FindFirstChild("BuildingHealth")
    if not gui then
        gui = Instance.new("BillboardGui")
        gui.Name = "BuildingHealth"
        gui.Adornee = model.PrimaryPart
        gui.Size = UDim2.fromOffset(70, 9)
        gui.StudsOffsetWorldSpace = Vector3.new(0, 6, 0)
        gui.AlwaysOnTop = true
        gui.Parent = model
        local track = Instance.new("Frame")
        track.Name = "Track"
        track.BorderSizePixel = 0
        track.BackgroundColor3 = Color3.fromRGB(61, 56, 53)
        track.Size = UDim2.fromScale(1,1)
        track.Parent = gui
        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.BorderSizePixel = 0
        fill.BackgroundColor3 = Color3.fromRGB(227, 174, 64)
        fill.Size = UDim2.fromScale(1,1)
        fill.Parent = track
    end
    local track = gui:FindFirstChild("Track")
    local fill = track and track:FindFirstChild("Fill")
    if fill then fill.Size = UDim2.fromScale(math.clamp(remaining / maximum,0,1),1) end
end

local function destroy(model)
    local info = registered[model]
    if not info then return end
    registered[model] = nil
    local count = ownerCounts[info.userId]
    if count then count[info.kind] = math.max(0,(count[info.kind] or 0)-1) end
    model:Destroy()
end

-- Evita bases orfas, renda de moinhos antigos e limites de construcao
-- desatualizados apos morte ou desconexao do dono.
function Structures.clearOwner(userId)
    if typeof(userId) ~= "number" then return end
    local owned = {}
    for model, info in pairs(registered) do
        if info.userId == userId then table.insert(owned, model) end
    end
    for _, model in ipairs(owned) do destroy(model) end
    ownerCounts[userId] = nil
end

function Structures.damage(model, amount)
    if not registered[model] or typeof(amount) ~= "number" or amount <= 0 then return false end
    local maxHp = model:GetAttribute("MaxHealth")
    local health = model:GetAttribute("Health")
    if typeof(health)~="number" or typeof(maxHp)~="number" then return false end
    health = math.max(0,health - amount)
    model:SetAttribute("Health",health)
    if health == 0 then destroy(model) return true end
    healthBar(model,health,maxHp)
    return false
end

local function placementCheck(player,kind,direction)
    if not folder or not folder.Parent then return nil,"Mundo nao disponivel" end
    if typeof(kind)~="string" or not config.Buildings[kind] then
        return nil,"Construcao desconhecida"
    end
    local facing = Melee.validDirection(direction)
    if not facing then return nil,"Direcao invalida" end
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid or humanoid.Health<=0 then return nil,"Jogador sem vida" end
    local placement = root.Position + facing*config.BuildDistance
    -- Snap para grade de dois studs e altitude fixa do terreno plano.
    placement = Vector3.new(math.floor(placement.X/2+.5)*2,0,
        math.floor(placement.Z/2+.5)*2)
    if not Rules.insideMap(config,placement,14) then return nil,"Perto da borda" end
    if Rules.isRiver(config,placement,7) then return nil,"Nao pode construir no rio" end
    if (placement - Vector3.new(0,0,-64)).Magnitude<17 then
        return nil,"Nao bloqueie o nascimento"
    end
    for _,item in ipairs(resources:GetChildren()) do
        local p=item.PrimaryPart
        if p then
            local dx,dz=placement.X-p.Position.X,placement.Z-p.Position.Z
            local clearance=if item:GetAttribute("Kind")=="Tree" then 7.5 else 7
            if dx*dx+dz*dz < clearance*clearance then
                return nil,"Afaste-se de arvores e pedras"
            end
        end
    end
    for _,structure in ipairs(folder:GetChildren()) do
        if structure.PrimaryPart then
            local p=structure.PrimaryPart.Position
            local dx,dz=placement.X-p.X,placement.Z-p.Z
            if dx*dx+dz*dz < 9*9 then return nil,"Construcao muito proxima" end
        end
    end
    for _,wolf in ipairs(animals:GetChildren()) do
        local p=wolf.PrimaryPart
        if p and (Vector2.new(placement.X-p.Position.X,placement.Z-p.Position.Z)).Magnitude<8 then
            return nil,"Lobo no local"
        end
    end
    for _,other in ipairs(Players:GetPlayers()) do
        if other~=player and other.Character and other.Character.PrimaryPart then
            local p=other.Character.PrimaryPart.Position
            if (Vector2.new(placement.X-p.X,placement.Z-p.Z)).Magnitude<8 then
                return nil,"Outro jogador no local"
            end
        end
    end
    return placement,nil,facing
end

-- Pureza da posição: custos/contagens não são alterados até todos os checks.
function Structures.tryBuild(player,kind,direction,stock,age)
    if typeof(stock)~="table" then return nil,"Inventario invalido" end
    local blueprint = typeof(kind)=="string" and config.Buildings[kind]
    if not blueprint then return nil,"Construcao desconhecida" end
    if typeof(age) ~= "number" or age < (blueprint.minAge or 1) then
        return nil,"Desbloqueia na idade "..tostring(blueprint.minAge or 1)
    end
    local count = ownerCounts[player.UserId] or {}
    if (count[kind] or 0)>=blueprint.limit then return nil,"Limite de "..kind.." atingido" end
    for material,price in pairs(blueprint.cost) do
        if typeof(stock[material])~="number" or stock[material]<price then
            return nil,"Faltam "..material.." ("..price..")"
        end
    end
    local position,err,facing = placementCheck(player,kind,direction)
    if not position then return nil,err end
    local model = buildShape(kind,position,facing,player.UserId)
    if not model then return nil,"Falha ao construir" end
    for material,price in pairs(blueprint.cost) do
        stock[material]-=price
        player:SetAttribute(material,stock[material])
    end
    if not ownerCounts[player.UserId] then ownerCounts[player.UserId]={} end
    ownerCounts[player.UserId][kind]=(ownerCounts[player.UserId][kind] or 0)+1
    registered[model]={kind=kind,userId=player.UserId,lastGold=os.clock(),spin=0}
    return model,nil
end

function Structures.start(world,nodes,wolves,settings,onGold,onWolfFood,onHitWolf)
    if running then return folder end
    running=true
    resources=nodes
    animals=wolves
    config=settings
    grantGold=onGold
    grantWolfFood=onWolfFood
    hitWolf=onHitWolf
    folder=Instance.new("Folder")
    folder.Name="Buildings"
    folder.Parent=world

    task.spawn(function()
        while folder and folder.Parent do
            local dt = math.min(task.wait(.2),.4)
            local now=os.clock()
            for model,info in pairs(registered) do
                if not model.Parent then
                    registered[model]=nil
                    continue
                end
                if info.kind=="Windmill" then
                    info.spin+=dt * 1.7
                    local blades=model:FindFirstChild("Pas")
                    local base=model.PrimaryPart and model.PrimaryPart.CFrame
                    if base and blades then
                        local hub = base*CFrame.new(0,3.1,-2.5)
                        for i,blade in ipairs(blades:GetChildren()) do
                            local angle=info.spin+(i-1)*math.pi*.5
                            blade.CFrame=hub*CFrame.Angles(0,0,angle)*CFrame.new(0,2.15,0)
                        end
                    end
                    if now-info.lastGold>=config.Buildings.Windmill.interval then
                        info.lastGold=now
                        local owner=Players:GetPlayerByUserId(info.userId)
                        if owner then grantGold(owner,config.Buildings.Windmill.goldPerTick) end
                    end
                elseif info.kind=="Spikes" and model.PrimaryPart then
                    local position=model.PrimaryPart.Position
                    for _,wolf in ipairs(animals:GetChildren()) do
                        local p=wolf.PrimaryPart
                        if p and (Vector2.new(position.X-p.Position.X,position.Z-p.Position.Z)).Magnitude < 5.2 then
                            local last=lastSpikeHit[wolf] or 0
                            if now-last >= 1.1 then
                                lastSpikeHit[wolf]=now
                                local killed=hitWolf(wolf,config.Buildings.Spikes.damage)
                                if killed then
                                    local owner=Players:GetPlayerByUserId(info.userId)
                                    if owner then grantWolfFood(owner,config.Wolf.FoodOnKill) end
                                    lastSpikeHit[wolf]=nil
                                end
                            end
                        end
                    end
                    for _,other in ipairs(Players:GetPlayers()) do
                        if other.UserId~=info.userId then
                            local char=other.Character
                            local p=char and char:FindFirstChild("HumanoidRootPart")
                            local hum=char and char:FindFirstChildOfClass("Humanoid")
                            if p and hum and hum.Health>0 and
                                (Vector2.new(position.X-p.Position.X,position.Z-p.Position.Z)).Magnitude<5 then
                                local last=lastSpikeHit[hum] or 0
                                if now-last>=1.1 then
                                    lastSpikeHit[hum]=now
                                    hum:TakeDamage(config.Buildings.Spikes.damage)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    return folder
end

function Structures.folder()
    return folder
end

return Structures
