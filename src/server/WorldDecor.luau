--!nonstrict
-- Cenário 3D autoral. Nenhum elemento decorativo interfere com colisões,
-- seleção de alvos ou construção. Os números são limitados para mobile.
local Decoration = {}
local rng = Random.new(302904)
local made = 0

local COLORS = {
    grass = {
        Color3.fromRGB(73, 148, 69),
        Color3.fromRGB(90, 166, 77),
        Color3.fromRGB(111, 187, 88),
        Color3.fromRGB(58, 134, 74),
    },
    petals = {
        Color3.fromRGB(253, 213, 89),
        Color3.fromRGB(244, 169, 190),
        Color3.fromRGB(237, 248, 230),
        Color3.fromRGB(181, 157, 224),
        Color3.fromRGB(255, 151, 104),
    },
    sand = {
        Color3.fromRGB(185, 156, 109),
        Color3.fromRGB(200, 170, 125),
        Color3.fromRGB(174, 152, 117),
    },
    stone = {
        Color3.fromRGB(116, 130, 122),
        Color3.fromRGB(139, 151, 142),
        Color3.fromRGB(151, 146, 127),
    },
}

local function choose(palette)
    return palette[rng:NextInteger(1, #palette)]
end

local function piece(parent, name, size, frame, color, shape, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = frame
    p.Shape = shape or Enum.PartType.Block
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    made += 1
    return p
end

local function distance2D(a, b)
    local dx, dz = a.X - b.X, a.Z - b.Z
    return dx * dx + dz * dz
end

local function pickPosition(zone, half, clearRadius, resources, decorationPoints, separation)
    for _ = 1, 35 do
        local x = rng:NextNumber(-half + 20, half - 20)
        local z
        if zone == "Grass" then
            z = rng:NextNumber(-half + 111, half - 111)
        elseif zone == "Snow" then
            z = rng:NextNumber(-half + 18, -half + 83)
        else
            z = rng:NextNumber(half - 83, half - 18)
        end
        local p = Vector3.new(x, 0, z)
        if distance2D(p, Vector3.zero) >= clearRadius * clearRadius then
            local valid = true
            for _, resource in ipairs(resources) do
                if distance2D(p, resource) < 8 * 8 then valid = false break end
            end
            if valid then
                for _, placed in ipairs(decorationPoints) do
                    if distance2D(p, placed) < separation * separation then
                        valid = false
                        break
                    end
                end
            end
            if valid then
                table.insert(decorationPoints, p)
                return p
            end
        end
    end
    return nil
end

local function grass(folder, pos)
    local rotation = rng:NextNumber(0, math.pi * 2)
    local c1 = choose(COLORS.grass)
    local c2 = choose(COLORS.grass)
    local size = rng:NextNumber(1.8, 3.0)
    piece(folder, "Grama", Vector3.new(0.7, size, 1.6),
        CFrame.new(pos + Vector3.new(-0.65, size / 2 + 0.12, 0)) *
        CFrame.Angles(0, rotation, math.rad(14)),
        c1, nil, Enum.Material.Grass)
    piece(folder, "Grama", Vector3.new(0.7, size * .85, 1.6),
        CFrame.new(pos + Vector3.new(0.65, size * .42 + 0.12, 0)) *
        CFrame.Angles(0, rotation + math.rad(90), math.rad(-18)),
        c2, nil, Enum.Material.Grass)
end

local function flower(folder, pos)
    local height = rng:NextNumber(1.8, 3.5)
    piece(folder, "Caule", Vector3.new(.35, height, .35),
        CFrame.new(pos + Vector3.new(0, height / 2 + .12, 0)),
        Color3.fromRGB(64, 132, 65))
    piece(folder, "Flor", Vector3.new(1.8, .8, 1.8),
        CFrame.new(pos + Vector3.new(0, height + .1, 0)),
        choose(COLORS.petals), Enum.PartType.Ball)
end

local function pebble(folder, pos, zone)
    local size = rng:NextNumber(1.3, 3)
    local colors = if zone == "Desert" then COLORS.sand else COLORS.stone
    piece(folder, "Pedrinha", Vector3.new(size, size * .52, size * .85),
        CFrame.new(pos + Vector3.new(0, .18, 0)) * CFrame.Angles(0, rng:NextNumber(0, 6.28), 0),
        choose(colors), Enum.PartType.Ball, Enum.Material.Slate)
end

local function pine(folder, pos)
    local height = rng:NextNumber(6, 9)
    piece(folder, "TroncoPinheiro", Vector3.new(.9, height * .7, .9),
        CFrame.new(pos + Vector3.new(0, height * .35, 0)),
        Color3.fromRGB(105, 87, 68), nil, Enum.Material.Wood)
    local greens = {Color3.fromRGB(47, 102, 84), Color3.fromRGB(57, 121, 102)}
    for i = 1, 3 do
        local size = (4.8 - i * .7)
        piece(folder, "FolhagemPinheiro",
            Vector3.new(size, 3.2, size),
            CFrame.new(pos + Vector3.new(0, i * 1.7 + 1.6, 0)),
            choose(greens), Enum.PartType.Ball, Enum.Material.Grass)
    end
end

local function cactus(folder, pos)
    local body = rng:NextNumber(4.6, 7.4)
    local dark = Color3.fromRGB(64, 135, 89)
    local lighter = Color3.fromRGB(89, 158, 103)
    piece(folder, "Cacto", Vector3.new(1.75, body, 1.75),
        CFrame.new(pos + Vector3.new(0, body / 2 + .05, 0)), dark)
    piece(folder, "BracoCacto", Vector3.new(2.5, .85, 1.2),
        CFrame.new(pos + Vector3.new(1.3, body * .56, 0)), lighter)
    piece(folder, "PontaCacto", Vector3.new(.9, 2.4, 1.2),
        CFrame.new(pos + Vector3.new(2.1, body * .56 + 1.1, 0)), dark)
end

function Decoration.generate(world, mapSize, resourcePositions, settings)
    local old = world:FindFirstChild("Decorations")
    if old then old:Destroy() end
    if settings and settings.Enabled == false then return nil end
    settings = settings or {}
    made = 0
    local folder = Instance.new("Folder")
    folder.Name = "Decorations"
    folder.Parent = world
    local points = {}
    local half = mapSize / 2
    local clearRadius = settings.SpawnClearRadius or 36
    local function scatter(count, zone, spacing, create)
        for _ = 1, count do
            local pos = pickPosition(zone, half, clearRadius, resourcePositions, points, spacing)
            if pos then create(folder, pos) end
        end
    end
    scatter(settings.GrassTufts or 160, "Grass", 3.4, grass)
    scatter(settings.Flowers or 40, "Grass", 3, flower)
    scatter(settings.MeadowPebbles or 40, "Grass", 3, function(p, v) pebble(p, v, "Grass") end)
    scatter(settings.SnowPines or 16, "Snow", 8, pine)
    scatter(settings.DesertCacti or 14, "Desert", 8, cactus)
    scatter(settings.DesertPebbles or 24, "Desert", 3, function(p, v) pebble(p, v, "Desert") end)
    print("[RoMoo Decor] " .. made .. " peças decorativas sem colisão criadas.")
    return folder
end

return Decoration
