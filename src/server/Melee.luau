--!nonstrict
-- Combate corpo a corpo 3D inspirado no cone de golpes do Moo-IO.
-- O cliente envia apenas o vetor de mira. O servidor resolve o alvo
-- usando alcance, angulo e bloqueio. Regras testaveis sem eventos de rede.
local Players = game:GetService("Players")
local Melee = {}

function Melee.validDirection(aim)
    if typeof(aim) ~= "Vector3" then return nil end
    if aim.X ~= aim.X or aim.Y ~= aim.Y or aim.Z ~= aim.Z then return nil end
    if math.abs(aim.X)>2 or math.abs(aim.Z)>2 or math.abs(aim.Y)>.2 then return nil end
    local horizontal = Vector3.new(aim.X,0,aim.Z)
    if horizontal.Magnitude<.7 or horizontal.Magnitude>1.5 then return nil end
    return horizontal.Unit
end

local function parentTarget(part, resources, animals, buildings, characters, wildlife)
    local model = part:FindFirstAncestorOfClass("Model")
    while model and model.Parent ~= resources and model.Parent ~= animals
        and model.Parent ~= wildlife and model.Parent ~= buildings
        and not characters[model] do
        local parent = model.Parent
        model = if parent and parent:IsA("Model") then parent
            else parent and parent:FindFirstAncestorOfClass("Model")
    end
    return if model and (model.Parent == resources or model.Parent == animals
        or model.Parent == wildlife or model.Parent == buildings or characters[model])
        then model else nil
end

function Melee.choose(root, direction, resources, animals, config, buildings, weapon, attacker, wildlife)
    if not root or not root.Parent then return nil end
    local forward = Melee.validDirection(direction)
    if not forward then return nil end

    local overlap = OverlapParams.new()
    overlap.FilterType = Enum.RaycastFilterType.Include
    local targets = {resources, animals}
    if buildings then table.insert(targets, buildings) end
    if wildlife then table.insert(targets, wildlife) end
    -- Apenas personagens vivos, que nao sejam o autor do ataque.
    local characters = {}
    if attacker then
        for _,player in ipairs(Players:GetPlayers()) do
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if player ~= attacker and char and hum and hum.Health > 0
                and not char:FindFirstChildOfClass("ForceField") then
                characters[char] = player
                table.insert(targets, char)
            end
        end
    end
    overlap.FilterDescendantsInstances = targets
    overlap.MaxParts = 120

    local sight = RaycastParams.new()
    sight.FilterType = Enum.RaycastFilterType.Include
    sight.FilterDescendantsInstances = targets

    local hitRange = weapon and weapon.range or config.HitRange
    local origin = root.Position
    local visited = {}
    local best, lowest = nil, math.huge
    local parts = workspace:GetPartBoundsInRadius(origin, hitRange+3, overlap)
    for _, part in ipairs(parts) do
        local model = parentTarget(part, resources, animals, buildings, characters, wildlife)
        if model and not visited[model] and model.PrimaryPart then
            visited[model]=true
            local center = model.PrimaryPart.Position
            local delta = Vector3.new(center.X-origin.X,0,center.Z-origin.Z)
            local distance = delta.Magnitude
            if distance>.3 and distance<=hitRange
                and math.abs(center.Y-origin.Y)<11 then
                local alignment = delta.Unit:Dot(forward)
                if alignment >= (config.HitArcDot or .38) then
                    local eye = origin + Vector3.new(0,.9,0)
                    local result = workspace:Raycast(eye,center-eye,sight)
                    if not result or result.Instance:IsDescendantOf(model) then
                        local score = distance + (1-alignment)*9
                        if score<lowest then
                            lowest=score
                            best=model
                        end
                    end
                end
            end
        end
    end
    return best
end

return Melee
