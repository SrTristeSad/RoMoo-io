--!nonstrict
-- Bloqueio fisico da linha de visao; somente obstaculos solidos contam.
-- Espinhos, decoracoes e outras pecas sem colisao nao impedem ataques.
-- Nao recebe IDs nem resultados de dano fornecidos pelo cliente.
local CombatVisibility = {}

function CombatVisibility.clear(fromPosition, toPosition, resources, buildings, targetModel)
    if typeof(fromPosition) ~= "Vector3" or typeof(toPosition) ~= "Vector3" then
        return false
    end
    local offset = toPosition - fromPosition
    local distance = offset.Magnitude
    if distance ~= distance or distance == math.huge then return false end
    if distance < 0.05 then return true end

    local blocking = {}
    if resources and resources.Parent then table.insert(blocking,resources) end
    if buildings and buildings.Parent then table.insert(blocking,buildings) end
    if #blocking == 0 then return true end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = blocking
    params.RespectCanCollide = true
    params.IgnoreWater = true
    local hit = workspace:Raycast(fromPosition,offset,params)
    return not hit or (targetModel and hit.Instance:IsDescendantOf(targetModel)) or false
end

return CombatVisibility
