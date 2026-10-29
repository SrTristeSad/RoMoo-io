-- RoMoo.io: colar no Command Bar do Roblox Studio (Server), em Play.
-- Verifica apenas regras estáticas. Não testa alcance, IA nem multiplayer.
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
assert(#Config.AgeThresholds >= 9, "Menos de 9 idades")
for age = 2, 9 do
    local choices = Config.UpgradeChoices[age]
    assert(choices and #choices == 2, "Escolha ausente na idade " .. age)
    assert(choices[1] ~= choices[2], "Alternativas duplicadas")
    for _, name in ipairs(choices) do
        assert(Config.Items[name], "Item faltando: " .. name)
        assert(Config.Items[name].upgrade == age, "Upgrade errado: " .. name)
        local category = Config.Items[name].category
        assert(category == "Weapon" or category == "Building" or category == "Food",
            "Categoria inválida: " .. name)
    end
end
local seen = {}
for _, name in ipairs(Config.ItemOrder) do
    assert(not seen[name], "Item duplicado na hotbar: " .. name)
    assert(Config.Items[name], "Item inexistente na hotbar: " .. name)
    seen[name] = true
end
for name, item in pairs(Config.Items) do
    assert(seen[name], "Item faltando na hotbar: " .. name)
    if item.category == "Building" then
        assert(item.health > 0 and item.limit > 0, "Construção sem vida/limite: " .. name)
        assert(type(item.cost) == "table", "Construção sem custo: " .. name)
    elseif item.category == "Weapon" then
        assert(item.damage > 0 and item.range > 0, "Arma incompleta: " .. name)
    elseif item.category == "Food" then
        assert(item.heal > 0 and item.foodCost > 0, "Comida incompleta: " .. name)
    end
end
assert(#Config.ItemOrder == 21, "Esperados 21 itens cadastrados")
local initial = 0
for _, name in ipairs(Config.ItemOrder) do
    if not Config.Items[name].upgrade then initial += 1 end
end
assert(initial == 5, "Esperados 5 itens iniciais")
print("[RoMoo] PASS: 21 itens, 8 escolhas, 13 itens máximos visíveis na barra.")
