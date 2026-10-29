--!nonstrict
-- RoMoo io: regras do modo clássico. Números de balanceamento provisórios.
local Config = {
    MapSize = 520,
    ResourceCount = 90,
    -- Cenário bonito sem exagerar no número de partes para celulares.
    Decoration = {
        Enabled = true,
        GrassTufts = 160,
        Flowers = 40,
        MeadowPebbles = 40,
        SnowPines = 16,
        DesertCacti = 14,
        DesertPebbles = 24,
        SpawnClearRadius = 36,
        ShowGrid = false,
    },
    ResourceRespawnSeconds = 18,
    GatherRange = 15,
    AttackRange = 15,
    BuildDistance = 11,
    BuildMinSeparation = 11,
    SpawnProtectionRadius = 28,
    UseCooldown = 0.45,
    EatCooldown = 0.45,
    WindmillTickSeconds = 1,
    PlayerMaxStructures = 65,
    StartingResources = {Wood = 0, Stone = 0, Gold = 0, Food = 0},
    -- XP acumulado exigido para cada idade.
    AgeThresholds = {0, 300, 660, 1092, 1611, 2234, 2981, 3877, 4952, 6242},
    ResourceTypes = {
        Tree = {inventory = "Wood", reward = 5, health = 4},
        Rock = {inventory = "Stone", reward = 5, health = 5},
        Gold = {inventory = "Gold", reward = 5, health = 6},
        Bush = {inventory = "Food", reward = 5, health = 3},
    },
    -- Ordem da hotbar compartilhada por PC e celular.
    ItemOrder = {"Hammer", "Food", "WoodWall", "Spikes", "Windmill", "Axe", "Sword", "StoneWall", "Cookie"},
    Items = {
        Hammer = {label = "MARTELO", category = "Weapon", damage = 25, gather = 1, range = 15},
        Axe = {label = "MACHADO", category = "Weapon", damage = 30, gather = 2, range = 15, upgrade = 2},
        Sword = {label = "ESPADA", category = "Weapon", damage = 35, gather = 1, range = 18, upgrade = 2},
        Food = {label = "MAÇÃ", category = "Food", heal = 28, foodCost = 8},
        Cookie = {label = "BISCOITO", category = "Food", heal = 45, foodCost = 12, upgrade = 3},
        WoodWall = {label = "PAREDE", category = "Building", health = 140, limit = 30, cost = {Wood = 10}},
        Spikes = {label = "ESPINHOS", category = "Building", health = 120, limit = 20, cost = {Wood = 20, Stone = 5}},
        Windmill = {label = "MOINHO", category = "Building", health = 400, limit = 7, cost = {Wood = 50, Stone = 10}, goldPerTick = 1},
        StoneWall = {label = "PEDRA", category = "Building", health = 300, limit = 30, cost = {Stone = 25}, upgrade = 3},
    },
    UpgradeChoices = {
        [2] = {"Axe", "Sword"},
        [3] = {"Cookie", "StoneWall"},
    },
}
return Config
