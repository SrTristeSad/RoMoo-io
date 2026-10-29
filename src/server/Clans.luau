--!nonstrict
-- Clãs temporários da sessão: código público, até oito jogadores, sem DataStore.
local Players = game:GetService("Players")

local Clans = {}
local groups = {}
local membership = {}
local LIMIT = 8
local random = Random.new()

-- Código numérico criado pelo servidor: não é texto livre gerado pelo usuário.
-- Evita exibir texto sem filtragem do Roblox; nomes personalizados exigirão TextService.
local function validJoinCode(raw)
    if typeof(raw) ~= "string" or #raw > 8 then return nil end
    if not raw:match("^%d%d%d%d%d%d$") then return nil end
    return raw
end

local function uniqueCode()
    for _ = 1, 80 do
        local code = tostring(random:NextInteger(100000, 999999))
        if not groups[code] then return code end
    end
    return nil
end

local function memberCount(group)
    local count = 0
    for player in pairs(group.members) do
        if player.Parent == Players then count += 1 end
    end
    return count
end

local function update(group)
    local count = memberCount(group)
    for player in pairs(group.members) do
        if player.Parent == Players then
            player:SetAttribute("ClanCode", group.code)
            player:SetAttribute("ClanLeader", player.UserId == group.leader)
            player:SetAttribute("ClanMembers", count)
        end
    end
end

function Clans.code(player)
    return membership[player]
end

function Clans.allies(a, b)
    if a == b then return true end
    if not a or not b then return false end
    local key = membership[a]
    return key ~= nil and key == membership[b]
end

function Clans.create(player)
    if membership[player] then return false, "Saia do clã atual primeiro." end
    local code = uniqueCode()
    if not code then return false, "Não foi possível criar o clã agora." end
    local group = {code = code, leader = player.UserId, members = {[player] = true}}
    groups[code] = group
    membership[player] = code
    update(group)
    return true, "Clã " .. code .. " criado. Compartilhe o código!"
end

function Clans.join(player, raw)
    if membership[player] then return false, "Saia do clã atual primeiro." end
    local code = validJoinCode(raw)
    if not code then return false, "Código inválido (6 números)." end
    local group = groups[code]
    if not group then return false, "Clã não encontrado nesta partida." end
    if memberCount(group) >= LIMIT then return false, "Este clã está cheio." end
    group.members[player] = true
    membership[player] = code
    update(group)
    return true, "Você entrou no clã " .. code .. "."
end

function Clans.leave(player)
    local code = membership[player]
    if not code then return false, "Você não está em um clã." end
    membership[player] = nil
    player:SetAttribute("ClanCode", "")
    player:SetAttribute("ClanLeader", false)
    player:SetAttribute("ClanMembers", 0)
    local group = groups[code]
    if group then
        group.members[player] = nil
        if memberCount(group) == 0 then
            groups[code] = nil
        else
            if group.leader == player.UserId then
                for nextPlayer in pairs(group.members) do
                    if nextPlayer.Parent == Players then
                        group.leader = nextPlayer.UserId
                        break
                    end
                end
            end
            update(group)
        end
    end
    return true, "Você saiu do clã " .. code .. "."
end

function Clans.remove(player)
    if membership[player] then Clans.leave(player) end
end

return Clans
