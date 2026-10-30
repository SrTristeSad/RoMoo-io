--!nonstrict
-- Protótipo RoMoo 3D: marreta e coleta validadas exclusivamente no servidor.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local World = require(script.Parent:WaitForChild("World"))
local Avatar = require(script.Parent:WaitForChild("Avatar"))
local Wolves = require(script.Parent:WaitForChild("Wolves"))
local RiverFlow = require(script.Parent:WaitForChild("RiverFlow"))
local Boundaries = require(script.Parent:WaitForChild("Boundaries"))
local Melee = require(script.Parent:WaitForChild("Melee"))
local Structures = require(script.Parent:WaitForChild("Structures"))
local Progression = require(script.Parent:WaitForChild("Progression"))
local SessionState = require(script.Parent:WaitForChild("SessionState"))
local NatureAssets = require(script.Parent:WaitForChild("NatureAssets"))

NatureAssets.prepare(Config)
local resources = World.create()
local world = resources.Parent
local wolves = Wolves.start(world,resources)
RiverFlow.start(Config)
Boundaries.start(Config)
local namespace = ReplicatedStorage:WaitForChild("RoMoo")
local former = namespace:FindFirstChild("Remotes")
if former then former:Destroy() end
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = namespace
local strike = Instance.new("RemoteEvent")
strike.Name = "Strike"
strike.Parent = remotes
local feedback = Instance.new("RemoteEvent")
feedback.Name = "Feedback"
feedback.Parent = remotes
local eat = Instance.new("RemoteEvent")
eat.Name = "Eat"
eat.Parent = remotes
local build = Instance.new("RemoteEvent")
build.Name = "Build"
build.Parent = remotes
local selectWeapon = Instance.new("RemoteEvent")
selectWeapon.Name = "SelectWeapon"
selectWeapon.Parent = remotes

-- Cura somente no servidor: o cliente não pode inventar comida nem vida.
local profiles = {}

-- Apenas o servidor escolhe dano, alcance e tempo de recarga.
selectWeapon.OnServerEvent:Connect(function(player,id)
    local profile=profiles[player]
    if not profile or typeof(id)~="string" then return end
    local settings=Config.Weapons[id]
    if not settings or profile.age<settings.minAge then
        feedback:FireClient(player,"Notice","Arma ainda bloqueada")
        return
    end
    if profile.weapon==id then return end
    local now=os.clock()
    if now - (profile.lastWeaponSelect or -1e8)<.2 then return end
    local char=player.Character
    local tool=char and char:FindFirstChild("Marreta")
    if not tool or not tool:IsA("Tool") then return end
    if Avatar.applyWeaponVisual(tool,id) then
        profile.weapon=id
        profile.lastWeaponSelect=now
        player:SetAttribute("WeaponId",id)
        feedback:FireClient(player,"WeaponEquipped",id)
    end
end)

local function awardXP(player,profile,amount)
    local newAge=Progression.award(player,profile,amount,Config)
    if newAge then
        feedback:FireClient(player,"LevelUp",newAge)
        print(("[RoMoo Idade] %s alcancou a idade %d"):format(player.Name,newAge))
    end
end

-- Todas as estruturas são produzidas e atualizadas no servidor.
local buildings = Structures.start(world, resources, wolves, Config,
    function(player, amount)
        local profile=profiles[player]
        if not profile then return end
        profile.stock.Gold += amount
        player:SetAttribute("Gold",profile.stock.Gold)
        feedback:FireClient(player,"Income",amount)
    end,
    function(player, amount)
        local profile=profiles[player]
        if not profile then return end
        profile.stock.Food += amount
        player:SetAttribute("Food",profile.stock.Food)
        awardXP(player,profile,Config.Progression.XPFromWolf)
        feedback:FireClient(player,"Notice","Espinhos derrotaram um lobo: +"..amount.." comida")
    end,
    function(wolf, amount)
        return Wolves.hit(wolf,amount)
    end
)
Wolves.setStructures(buildings, Structures.damage)

build.OnServerEvent:Connect(function(player, kind, direction)
    local profile=profiles[player]
    if not profile or not Melee.validDirection(direction) then return end
    local now=os.clock()
    if now - (profile.lastBuild or -1e8) < Config.BuildCooldown then return end
    profile.lastBuild=now -- inclusive em tentativas rejeitadas: limita spam remoto
    local result,err=Structures.tryBuild(player,kind,direction,profile.stock,profile.age)
    if result then
        awardXP(player,profile,Config.Progression.XPFromBuild)
        feedback:FireClient(player,"Built",kind)
    else
        feedback:FireClient(player,"Notice",err or "Nao foi possivel construir")
    end
end)

eat.OnServerEvent:Connect(function(player)
    local profile = profiles[player]
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not profile or not humanoid or humanoid.Health <= 0 then return end
    local now = os.clock()
    if now - profile.lastEat < Config.EatCooldown then return end
    if (profile.stock.Food or 0) < Config.EatCost then
        feedback:FireClient(player, "Notice", "Precisa de " .. Config.EatCost .. " comidas para curar")
        return
    end
    if humanoid.Health >= humanoid.MaxHealth then
        feedback:FireClient(player, "Notice", "Vida ja esta cheia")
        return
    end
    profile.lastEat = now
    profile.stock.Food -= Config.EatCost
    player:SetAttribute("Food", profile.stock.Food)
    local before = humanoid.Health
    humanoid.Health = math.min(humanoid.MaxHealth, before + Config.EatHeal)
    feedback:FireClient(player,"Healed",math.floor(humanoid.Health-before+.5))
end)

local function equippedWeapon(player,character,profile)
    local tool=character and character:FindFirstChild("Marreta")
    if not tool or not tool:IsA("Tool") or not tool:FindFirstChild("Handle")
        or player.Character~=character then return nil end
    local id=profile.weapon or "Hammer"
    local config=Config.Weapons[id]
    if not config or profile.age<config.minAge then return nil end
    -- Se um exploit alterar a Tool localmente, o servidor continua verificando
    -- o valor que ele próprio atribuiu ao equipamento replicado.
    if tool:GetAttribute("WeaponId") ~= id then return nil end
    return config
end

-- Os alvos são resolvidos por Melee.choose; nada de confiar no clique exato.

strike.OnServerEvent:Connect(function(player, aim)
    local profile = profiles[player]
    if not profile then return end
    local facing = Melee.validDirection(aim)
    if not facing then return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root or humanoid.Health <= 0 then return end
    if not SessionState.canStrike(character) then return end
    local weapon = equippedWeapon(player,character,profile)
    if not weapon then return end
    local now = os.clock()
    if now-profile.lastStrike<weapon.cooldown then return end
    profile.lastStrike=now
    local candidate = Melee.choose(root,facing,resources,wolves,Config,buildings,weapon,player)
    if not candidate then return end
    local core = candidate.PrimaryPart
    if not core then return end
    local position = core.Position
    local opponent=Players:GetPlayerFromCharacter(candidate)
    if opponent and opponent~=player then
        local victimHum=candidate:FindFirstChildOfClass("Humanoid")
        if not victimHum or victimHum.Health<=0
            or candidate:FindFirstChildOfClass("ForceField") then return end
        local oldHealth=victimHum.Health
        victimHum:TakeDamage(weapon.pvpDamage)
        feedback:FireAllClients("Impact",position,"Player",false)
        feedback:FireClient(player,"PlayerHit",weapon.pvpDamage)
        if oldHealth>0 and victimHum.Health<=0 then
            profile.kills+=1
            player:SetAttribute("Kills",profile.kills)
            awardXP(player,profile,Config.Progression.XPFromPlayer)
            feedback:FireClient(player,"Notice","Adversario derrotado! +XP")
        end
        return
    end
    if candidate.Parent == buildings then
        if candidate:GetAttribute("OwnerUserId") ~= player.UserId then
            Structures.damage(candidate,weapon.structureDamage)
            feedback:FireAllClients("Impact",position,"Building",false)
        else
            feedback:FireClient(player,"Notice","Sua construcao esta protegida")
        end
        return
    end
    if candidate.Parent == wolves then
        local killed = Wolves.hit(candidate,weapon.wolfDamage)
        feedback:FireAllClients("Impact",position,"Wolf",false)
        if killed then
            profile.stock.Food+=Config.Wolf.FoodOnKill
            player:SetAttribute("Food",profile.stock.Food)
            awardXP(player,profile,Config.Progression.XPFromWolf)
            feedback:FireClient(player,"Gather",position,"Wolf",Config.Wolf.FoodOnKill)
        end
        return
    end
    -- Recursos naturais nunca têm HP nem são destruídos.
    local stats = World.hitNode(candidate)
    if not stats then return end
    local key = stats.inventory
    local amount=math.max(1,math.floor(stats.yield*weapon.gatherMultiplier+.5))
    profile.stock[key] += amount
    player:SetAttribute(key,profile.stock[key])
    awardXP(player,profile,amount)
    feedback:FireClient(player,"Gather",position,candidate:GetAttribute("Kind"),amount)
    feedback:FireAllClients("Impact",position,candidate:GetAttribute("Kind"),false)
end)

local function characterReady(player, character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if humanoid and humanoid:IsA("Humanoid") and player.Character==character then
        local profile=profiles[player]
        Avatar.equip(player,character,humanoid,profile and profile.weapon or "Hammer")
        humanoid.Died:Connect(function()
            local current=profiles[player]
            if current and player.Character==character then
                current.deaths += 1
                player:SetAttribute("Deaths",current.deaths)
                -- Partida por vidas: construcoes e progressao recomecam.
                Structures.clearOwner(player.UserId)
                SessionState.resetForNewLife(player,current,Config)
                feedback:FireClient(player,"RespawnReset")
            end
        end)
    end
end

local function playerAdded(player)
    profiles[player] = SessionState.create(player,Config)
    player.CharacterAdded:Connect(function(character)
        task.spawn(characterReady, player, character)
    end)
    if player.Character then
        task.spawn(characterReady, player, player.Character)
    end
end

Players.PlayerAdded:Connect(playerAdded)
for _, player in ipairs(Players:GetPlayers()) do playerAdded(player) end
Players.PlayerRemoving:Connect(function(player)
    Structures.clearOwner(player.UserId)
    profiles[player] = nil
end)

print("[RoMoo 3D] Mapa Moo-IO por setores, rio com correnteza, lobos 3D e coleta infinita.")
