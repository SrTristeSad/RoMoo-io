--!nonstrict
-- Adaptacao 3D do gerador de objects.lua e movimento.lua de Moo-IO (AGPL-3.0).
return {
    MapSize = 520,
    Seed = 20261030,
    StartingWood = 0, StartingStone = 0, StartingGold = 0, StartingFood = 0,
    HitRange = 17, HitCooldown = .42, HitArcDot = .38,
    -- Armas primarias 3D. Todas mantem a coleta ilimitada dos recursos naturais.
    Weapons = {
        Hammer = {label="MARRETA",minAge=1,range=17,cooldown=.42,
            wolfDamage=25,structureDamage=25,pvpDamage=12,gatherMultiplier=1},
        Axe = {label="MACHADO",minAge=3,range=16,cooldown=.53,
            wolfDamage=38,structureDamage=31,pvpDamage=18,gatherMultiplier=1.6},
        Sword = {label="ESPADA",minAge=5,range=19,cooldown=.38,
            wolfDamage=60,structureDamage=39,pvpDamage=34,gatherMultiplier=.5},
    },
    -- Alimento cura vida, como nas mecânicas clássicas.
    EatCost = 10, EatHeal = 32, EatCooldown = 1.25,
    -- Estruturas iniciais, com requisitos de madeira/pedra e limites por jogador.
    BuildDistance = 12, BuildCooldown = .4,
    -- A idade aumenta com coleta e combate (mecanica adaptada do MooMoo.io).
    Progression = {
        BaseXP = 100, Growth = 1.2, MaxAge = 9,
        XPFromWolf = 80, XPFromBuild = 15, XPFromPlayer = 100,
    },
    Buildings = {
        Wall = {label="PAREDE",cost={Wood=10},health=380,limit=30,minAge=1},
        Spikes = {label="ESPINHOS",cost={Wood=20,Stone=5},health=260,
            limit=15,damage=20,minAge=2},
        Windmill = {label="MOINHO",cost={Wood=50,Stone=10},
            health=450,limit=5,goldPerTick=2,interval=4,minAge=3},
        StoneWall = {label="MURO DE PEDRA",cost={Stone=30,Wood=10},
            health=1100,limit=22,minAge=4},
    },
    -- Original: areaCount=7, treesPerArea=9, bushesPerArea=3,
    -- totalRocks=32, goldOres=7 num mapa 14400; quantidades reduzidas
    -- ou adaptadas para modelos 3D no Roblox.
    AreaCount = 7, TreesPerArea = 7, BushesPerArea = 2,
    TotalRocks = 40, GoldOres = 12, MinimumSeparation = 9.0,
    SnowDepth = 86, DesertDepth = 86, SnowSpeedMultiplier = .75,
    ResourceTypes = {
        Tree = {label = "ARVORE", inventory = "Wood", yield = 5},
        Rock = {label = "PEDRA", inventory = "Stone", yield = 5},
        Gold = {label = "OURO", inventory = "Gold", yield = 3},
        Bush = {label = "FRUTA", inventory = "Food", yield = 5},
    },
    River = {
        -- O original tem rio horizontal, corrente para +X e sem pontes.
        Width = 26,
        BankWidth = 5,
        CurrentDirection = 1,
        CurrentSpeed = 12,
        SwimSpeedMultiplier = .42,
        WaterSurfaceY = 0,
    },
    Wolf = {
        SourceTypeId = 4,
        Count = 7,
        Health = 125,
        HammerDamage = 25,
        AttackDamage = 8,
        AttackDistance = 4.5,
        DetectionRadius = 64,
        Speed = 13,
        RespawnSeconds = 25,
        FoodOnKill = 40,
        WanderSpeed = 4,
    },
}
