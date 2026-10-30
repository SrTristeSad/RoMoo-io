--!nonstrict
-- RoMoo: demonstracao focada na mecânica de sobrevivência com ferramentas nativas.
return {
    MapSize = 480,
    StartingWood = 0,
    StartingStone = 0,
    StartingGold = 0,
    HitRange = 17,
    HitCooldown = .42,
    RespawnSeconds = 12,
    ResourceTypes = {
        Tree = {label = "ÁRVORE", inventory = "Wood", hp = 75, damage = 25, yield = 5},
        Rock = {label = "PEDRA", inventory = "Stone", hp = 100, damage = 25, yield = 5},
        Gold = {label = "MINÉRIO DE OURO", inventory = "Gold", hp = 125, damage = 25, yield = 3},
    },
    River = {Width = 28, Depth = 6, BridgeX = 0, BridgeWidth = 13},
}
