--!nonstrict
-- Personagens 3D originais para Roblox; independentes de upload de mesh.
-- Quando uma malha CC0 importada estiver disponível ela tem prioridade.
local Gait = require(script.Parent:WaitForChild("CreatureGait"))
local Models = {}
local E = Enum.PartType

local function create(model, anchor, name, size, offset, color, shape, material, rotate)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = anchor * CFrame.new(offset) * (rotate or CFrame.identity)
    -- Tema cubico: todas as especies usam caixas de proporcoes variadas.
    p.Shape = E.Block
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = model
    return p
end

local function color(r,g,b)
    return Color3.fromRGB(r,g,b)
end

function Models.create(model, anchor, kind, primary)
    local wolf = kind == "Wolf"
    local sheep = kind == "Sheep"
    local bull = kind == "Bull" or kind == "Bully"
    local boar = kind == "Boar"
    local pig = kind == "Pig"
    local yeti = kind == "Yeti"
    local palette = {
        Cow = color(219,201,175), Pig = color(232,157,155), Sheep = color(239,236,217),
        Bull = color(124,83,61), Bully = color(87,60,52), Wolf = color(126,130,139),
        Boar = color(127,85,68), Yeti = color(233,241,243)
    }
    local base = palette[kind] or color(180,155,110)
    local dark = if wolf then color(66,70,83) else if pig then color(195,106,113)
        else if yeti then color(142,168,190) else color(87,63,49)
    local nose = if wolf or boar then dark else if pig then color(222,131,141)
        else color(195,153,143)
    local scale = if kind == "Bully" then 1.22 else if yeti then 1.15 else 1
    local bodyAnchor = anchor * CFrame.new(0, if scale > 1 then .35 else 0, 0)
    primary.Color = base
    primary.Transparency = 1
    -- Corpo e pernas: posição do Core fica 3 studs acima do chão.
    create(model, bodyAnchor, "Tronco", Vector3.new(5.7, 4.2, 7.6)*scale,
        Vector3.new(0, .1, 0), base, E.Ball)
    if yeti then
        create(model, bodyAnchor, "Peitoral", Vector3.new(5.8, 5.8, 4.2),
            Vector3.new(0,.8,-1), base, E.Ball)
    end
    for _, side in ipairs({-1,1}) do
        for _, z in ipairs({-2.65,2.4}) do
            local legColor = if wolf then dark else base
            local leg=create(model, bodyAnchor, "Perna", Vector3.new(1.45,3.2,1.5)*scale,
                Vector3.new(side*2.05,-2.02,z), legColor, E.Block)
            local hoof=create(model, bodyAnchor, "Casco", Vector3.new(1.65,.7,1.9)*scale,
                Vector3.new(side*2.05,-3.25,z-.2),
                if sheep or yeti then color(134,138,140) else dark, E.Block)
            -- Pernas diagonais alternadas, com a junta acima dos cascos.
            local hip=bodyAnchor*CFrame.new(side*2.05,-.65,z)
            local diagonal=if side*z>0 then 0 else math.pi
            Gait.register(model,leg,hoof,hip,diagonal)
        end
    end
    local headZ = if wolf or boar then -4.3 else -4.05
    create(model, bodyAnchor,"Cabeca",Vector3.new(4.3,3.95,4.5)*scale,
        Vector3.new(0,1.45,headZ),base,E.Ball)
    create(model, bodyAnchor,"Focinho",Vector3.new(if pig then 2.5 else 3.3,2.1,2.35)*scale,
        Vector3.new(0,.65,headZ-2.35),nose,E.Ball)
    if pig then
        for _, side in ipairs({-1,1}) do
            create(model,bodyAnchor,"Nariz",Vector3.new(.32,.53,.18),
                Vector3.new(side*.6,.62,headZ-3.52),dark,E.Ball)
        end
    end
    for _, side in ipairs({-1,1}) do
        create(model,bodyAnchor,"OlhoBranco",Vector3.new(.72,.82,.35),
            Vector3.new(side*1.3,1.75,headZ-2.11),color(248,246,237),E.Ball)
        create(model,bodyAnchor,"Pupila",Vector3.new(.38,.5,.23),
            Vector3.new(side*1.32,1.73,headZ-2.32),color(31,38,46),E.Ball)
        local ear = create(model,bodyAnchor,"Orelha",Vector3.new(1.4, if wolf then 2.45 else 1.4, 1.05)*scale,
            Vector3.new(side*2.15,3.08,headZ+.35),if wolf then dark else base,E.Ball,
            Enum.Material.SmoothPlastic,CFrame.Angles(0,0,math.rad(side*18)))
        if bull then
            create(model,bodyAnchor,"Chifre",Vector3.new(1.1,2.8,1.1)*scale,
                Vector3.new(side*2.9,3.9,headZ+.32),color(234,219,173),E.Ball,
                Enum.Material.SmoothPlastic,CFrame.Angles(0,0,math.rad(side*28)))
        elseif boar then
            create(model,bodyAnchor,"Presa",Vector3.new(.9,1.6,.8),
                Vector3.new(side*1.45,.35,headZ-2.95),color(235,221,192),E.Ball)
        end
    end
    if sheep then
        for _, pos in ipairs({
            Vector3.new(0,2.75,1.5),Vector3.new(1.8,2.4,1.2),
            Vector3.new(-1.8,2.4,1.2),Vector3.new(1.5,2.5,-1.1),
            Vector3.new(-1.5,2.5,-1.1),Vector3.new(0,3.05,-1.1),
            Vector3.new(0,3.1,headZ+.1)
        }) do
            create(model,bodyAnchor,"La",Vector3.new(3.5,2.8,3.5),
                pos,color(247,245,232),E.Ball)
        end
    elseif kind == "Cow" then
        for _, pos in ipairs({
            Vector3.new(-2.45,.95,1.25),
            Vector3.new(2.3,.55,-1.2),
            Vector3.new(.2,2.25,1.9)
        }) do
            create(model,bodyAnchor,"Mancha",Vector3.new(1.45,1.6,2.2),pos,
                color(94,78,73),E.Ball)
        end
    elseif wolf or boar then
        create(model,bodyAnchor,"Cauda",Vector3.new(1.45,1.65,3.8),
            Vector3.new(0,1.2,4.15),if wolf then dark else base,E.Ball,
            Enum.Material.SmoothPlastic,CFrame.Angles(math.rad(26),0,0))
    end
    return true
end

return Models
