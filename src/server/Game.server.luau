--!nonstrict
-- Protótipo RoMoo 3D: marreta e coleta validadas exclusivamente no servidor.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local World = require(script.Parent:WaitForChild("World"))
local Avatar = require(script.Parent:WaitForChild("Avatar"))

local resources = World.create()
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

local profiles = {}

local function distance2D(a, b)
    local dx, dz = a.X-b.X, a.Z-b.Z
    return math.sqrt(dx*dx + dz*dz)
end

local function validEquippedHammer(player, character)
    local tool = character:FindFirstChild("Marreta")
    return tool and tool:IsA("Tool") and tool:FindFirstChild("Handle") ~= nil
        and player.Character == character
end

local function firstResourceOnPath(origin, destination)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = {resources}
    return workspace:Raycast(origin, destination - origin, params)
end

strike.OnServerEvent:Connect(function(player, candidate)
    local profile = profiles[player]
    if not profile or typeof(candidate) ~= "Instance" or not candidate:IsA("Model")
        or candidate.Parent ~= resources then return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root or humanoid.Health <= 0
        or not validEquippedHammer(player, character) then return end

    local now = os.clock()
    if now - profile.lastStrike < Config.HitCooldown then return end
    local core = candidate.PrimaryPart
    if not core or distance2D(root.Position, core.Position) > Config.HitRange then
        feedback:FireClient(player, "Muito longe! Aproxime-se do recurso.")
        return
    end

    -- O cliente pode sugerir um Model, mas não escolher recompensa nem distância.
    -- Proibir acertar recursos através de outro recurso entre o jogador e o alvo.
    local origin = root.Position + Vector3.new(0, 1, 0)
    local hit = firstResourceOnPath(origin, core.Position)
    if not hit or not hit.Instance:IsDescendantOf(candidate) then return end
    profile.lastStrike = now

    local stats, broken = World.hitNode(candidate)
    if not stats then return end

    local key = stats.inventory
    profile.stock[key] += stats.yield
    player:SetAttribute(key, profile.stock[key])
    local spot = core.Position
    feedback:FireAllClients("Impact", spot, candidate:GetAttribute("Kind"), broken)
    if broken then
        local kind = candidate:GetAttribute("Kind")
        local x, z = candidate:GetAttribute("SpawnX"), candidate:GetAttribute("SpawnZ")
        candidate:Destroy()
        task.delay(Config.RespawnSeconds, function()
            if resources.Parent then
                World.spawnNode(kind, Vector3.new(x, 0, z), resources)
            end
        end)
    end
end)

local function characterReady(player, character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if humanoid and humanoid:IsA("Humanoid") then
        Avatar.equip(player, character, humanoid)
    end
end

local function playerAdded(player)
    profiles[player] = {
        stock = {Wood = Config.StartingWood, Stone = Config.StartingStone, Gold = Config.StartingGold},
        lastStrike = -1e8,
    }
    player:SetAttribute("Wood", Config.StartingWood)
    player:SetAttribute("Stone", Config.StartingStone)
    player:SetAttribute("Gold", Config.StartingGold)
    player.CharacterAdded:Connect(function(character)
        task.spawn(characterReady, player, character)
    end)
    if player.Character then
        task.spawn(characterReady, player, player.Character)
    end
end

Players.PlayerAdded:Connect(playerAdded)
for _, player in ipairs(Players:GetPlayers()) do playerAdded(player) end
Players.PlayerRemoving:Connect(function(player) profiles[player] = nil end)

print("[RoMoo 3D] Marreta equipada, recursos quebráveis e coleta de madeira/pedra/ouro ativos.")
