--!nonstrict
-- Progresso de idade e experiencia no servidor, inspirado em Economy.earnXP
-- do Moo-IO Lua. Nao recebe valores arbitrarios diretamente do cliente.
local Progression = {}

function Progression.threshold(age, config)
    local progression = config.Progression
    return math.max(1, math.floor(progression.BaseXP * progression.Growth ^ (age - 1) + .5))
end

function Progression.initialize(player, profile, config)
    profile.age = 1
    profile.xp = 0
    local needed = Progression.threshold(1, config)
    player:SetAttribute("Age", 1)
    player:SetAttribute("XP", 0)
    player:SetAttribute("XPToNext", needed)
end

function Progression.canUse(profile, blueprint)
    return profile and blueprint and
        (profile.age or 1) >= (blueprint.minAge or 1)
end

-- Um evento concede XP; atingir o nivel seguinte zera o contador,
-- seguindo o fluxo de Economy.earnXP do servidor de referencia.
-- Retorna a idade desbloqueada, ou nil quando nao houve subida de idade.
function Progression.award(player, profile, amount, config)
    if not profile or not profile.age then return nil end
    if typeof(amount) ~= "number" or amount ~= amount
        or amount < 0 or amount > 1000 or amount == math.huge then return nil end
    local settings = config.Progression
    if profile.age >= settings.MaxAge then return nil end
    local inc = math.floor(amount)
    if inc <= 0 then return nil end
    local required = Progression.threshold(profile.age, config)
    profile.xp = math.min(required, profile.xp + inc)
    if profile.xp >= required then
        profile.age += 1
        profile.xp = 0
        player:SetAttribute("Age", profile.age)
        player:SetAttribute("XP", 0)
        player:SetAttribute("XPToNext", if profile.age >= settings.MaxAge
            then 0 else Progression.threshold(profile.age, config))
        return profile.age
    end
    player:SetAttribute("XP", profile.xp)
    return nil
end

return Progression
