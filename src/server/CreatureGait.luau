--!nonstrict
-- Animacao das patas em Parts 3D. Nao exige Skeleton, Humanoid ou AnimationId.
-- Registros fracos: modelos destruidos nao ficam retidos em memoria.
local Gait = {}
local rigs = setmetatable({}, {__mode = "k"})
local MAX_SWING = math.rad(24)

-- hip e um CFrame no mundo (junção perna/corpo) no instante de criacao.
-- Mantem deslocamentos locais fixos para evitar drift dos cascos/patas.
function Gait.register(model, leg, foot, hip, phase)
    local core = model and model.PrimaryPart
    if not core or not leg or not foot or typeof(hip) ~= "CFrame" then return false end
    if not leg:IsA("BasePart") or not foot:IsA("BasePart") then return false end
    local list = rigs[model]
    if not list then
        list = {}
        rigs[model] = list
    end
    table.insert(list, {
        leg = leg, foot = foot,
        hipLocal = core.CFrame:ToObjectSpace(hip),
        legLocal = hip:ToObjectSpace(leg.CFrame),
        footLocal = hip:ToObjectSpace(foot.CFrame),
        phase = phase or 0,
    })
    return true
end

-- Chamar depois de Model:PivotTo, que ja posiciona o corpo.
-- intensity=0 reseta as patas para a pose de repouso.
function Gait.animate(model, now, speed, intensity)
    local tracks = rigs[model]
    local core = model and model.PrimaryPart
    if not tracks or not core then return false end
    local strength = math.clamp(intensity or 0, 0, 1)
    local frequency = math.clamp((speed or 0) * .78, 0, 18)
    local root = core.CFrame
    for _,track in ipairs(tracks) do
        if track.leg.Parent and track.foot.Parent then
            local swing = math.sin(now * frequency + track.phase) * MAX_SWING * strength
            local frame = root * track.hipLocal * CFrame.Angles(swing, 0, 0)
            track.leg.CFrame = frame * track.legLocal
            track.foot.CFrame = frame * track.footLocal
        end
    end
    return true
end

return Gait
