--!nonstrict
-- Estado temporario por vida. O servidor e a unica fonte de inventario,
-- idade e arma; abates/mortes pertencem a sessao, nao a cada vida.
local Progression = require(script.Parent:WaitForChild("Progression"))
local SessionState = {}

local stockAttributes = {
    Wood = "StartingWood",
    Stone = "StartingStone",
    Gold = "StartingGold",
    Food = "StartingFood",
}

function SessionState.resetForNewLife(player, profile, config)
    if not player or not profile then return false end
    profile.stock = {}
    for kind, configKey in pairs(stockAttributes) do
        local value = config[configKey]
        profile.stock[kind] = value
        player:SetAttribute(kind, value)
    end
    profile.weapon = "Hammer"
    profile.lastStrike = -1e8
    profile.lastEat = -1e8
    profile.lastBuild = -1e8
    profile.lastWeaponSelect = -1e8
    Progression.initialize(player, profile, config)
    player:SetAttribute("WeaponId", "Hammer")
    return true
end

function SessionState.create(player, config)
    local profile = {kills = 0, deaths = 0}
    SessionState.resetForNewLife(player, profile, config)
    player:SetAttribute("Kills", 0)
    player:SetAttribute("Deaths", 0)
    return profile
end

-- Um ForceField de nascimento protege contra golpes recebidos e impede
-- que o mesmo jogador agrida outros durante a invulnerabilidade.
function SessionState.canStrike(character)
    return character ~= nil and character.Parent ~= nil
        and character:FindFirstChildOfClass("ForceField") == nil
end

return SessionState
