--!strict
-- Valores iniciais do MVP: ajustar somente depois dos testes em multiplayer.
local Config = {
    MapSize = 520,
    ResourceCount = 90,
    ResourceRespawnSeconds = 16,
    GatherRange = 15,
    AttackRange = 12,
    AttackDamage = 18,
    PlayerMaxStructures = 24,
    EatCost = 8,
    EatHeal = 28,
    StartingResources = {
        Wood = 0,
        Stone = 0,
        Gold = 0,
        Food = 0,
    },
    ResourceTypes = {
        Tree = { inventory = "Wood", reward = 5, health = 4 },
        Rock = { inventory = "Stone", reward = 4, health = 5 },
        Gold = { inventory = "Gold", reward = 3, health = 6 },
        Bush = { inventory = "Food", reward = 5, health = 3 },
    },
    Buildings = {
        Wall = {
            label = "Parede",
            cost = { Wood = 20, Stone = 5 },
            health = 140,
        },
        Trap = {
            label = "Armadilha",
            cost = { Wood = 12, Stone = 12 },
            health = 85,
        },
    },
    Cooldowns = {
        Gather = 0.4,
        Attack = 0.65,
        Build = 0.35,
        Eat = 0.6,
    },
}
return Config
