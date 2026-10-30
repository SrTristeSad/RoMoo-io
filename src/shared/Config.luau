--!nonstrict
-- RoMoo: demonstracao focada na mecânica de sobrevivência com ferramentas nativas.
return {
    MapSize = 480,
    StartingWood = 0,
    StartingStone = 0,
    StartingGold = 0,
    HitRange = 17,
    HitCooldown = .42,
    ResourceTypes = {
        -- Como no MooMoo.io, recursos naturais são inesgotáveis: cada golpe rende materiais.
        Tree = {label = "ÁRVORE", inventory = "Wood", yield = 5},
        Rock = {label = "PEDRA", inventory = "Stone", yield = 5},
        Gold = {label = "MINÉRIO DE OURO", inventory = "Gold", yield = 3},
    },
    River = {Width = 28, Depth = 6, BridgeX = 0, BridgeWidth = 13},
}
