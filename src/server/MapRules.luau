--!nonstrict
-- Posicionamento de biomas e rio alinhados ao gerador do Moo-IO em Lua.
local Rules = {}
function Rules.riverHalf(config)
    return config.River.Width * .5
end
function Rules.isRiver(config, position, margin)
    -- O rio original cruza o centro do mapa, no eixo horizontal.
    return math.abs(position.Z) <= Rules.riverHalf(config) + (margin or 0)
end
function Rules.isSnow(config, position)
    return position.Z <= -config.MapSize*.5 + config.SnowDepth
end
function Rules.isDesert(config, position)
    return position.Z >= config.MapSize*.5 - config.DesertDepth
end
function Rules.insideMap(config, position, margin)
    local half = config.MapSize*.5 - (margin or 0)
    return math.abs(position.X) <= half and math.abs(position.Z) <= half
end
function Rules.clampPoint(config, point, margin)
    local half = config.MapSize*.5 - (margin or 0)
    return Vector3.new(math.clamp(point.X,-half,half),point.Y,math.clamp(point.Z,-half,half))
end
function Rules.canPlaceTree(config, position)
    -- O original nao coloca arvores dentro do rio nem no bioma deserto;
    -- evita uma faixa de margem, para manter margens caminhaveis.
    return Rules.insideMap(config,position,14)
        and not Rules.isRiver(config,position,14)
        and not Rules.isDesert(config,position)
end
function Rules.canPlaceBush(config, position)
    return Rules.insideMap(config,position,14)
        and not Rules.isRiver(config,position,9)
end
return Rules
