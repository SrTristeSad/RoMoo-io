--!nonstrict
-- Efeitos locais leves: não criam partes replicadas nem alteram dano/recursos.
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Effects = {}

local palette = {
    Swing = Color3.fromRGB(235, 230, 209),
    Break = Color3.fromRGB(255, 204, 102),
    Gather = Color3.fromRGB(246, 213, 103),
    Hit = Color3.fromRGB(240, 110, 95),
    Build = Color3.fromRGB(113, 216, 143),
    Heal = Color3.fromRGB(95, 221, 151),
}
local resourceNames = {
    Wood = "madeira",
    Stone = "pedra",
    Gold = "ouro",
    Food = "comida",
}

local function worldPulse(kind, position)
    local color = palette[kind]
    if not color then return end
    local p = Instance.new("Part")
    p.Name = "RoMooFX_" .. kind
    p.Anchored = true
    p.CanCollide = false
    p.CanQuery = false
    p.CanTouch = false
    p.CastShadow = false
    p.Material = Enum.Material.Neon
    p.Shape = Enum.PartType.Ball
    p.Size = Vector3.new(1.1, 1.1, 1.1)
    p.Color = color
    p.Transparency = 0.42
    p.Position = position + Vector3.new(0, 1.5, 0)
    p.Parent = workspace
    local size = if kind == "Swing" then 5 else if kind == "Build" then 7 else 3.5
    local duration = if kind == "Build" then 0.42 else 0.26
    local tween = TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(size, .65, size),
        Transparency = 1,
    })
    tween:Play()
    Debris:AddItem(p, duration + .12)
end

local function floatingNumber(kind, position, number, detail)
    if kind == "Swing" or kind == "Build" or kind == "Break" then return end
    local text
    if kind == "Gather" then
        text = "+" .. tostring(math.floor(number)) .. " " .. (resourceNames[detail] or "recurso")
    elseif kind == "Heal" then
        text = "+" .. tostring(math.floor(number)) .. " VIDA"
    elseif kind == "Hit" then
        text = "-" .. tostring(math.floor(number))
    else
        return
    end

    local anchor = Instance.new("Part")
    anchor.Name = "RoMooFloatingText"
    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.CanQuery = false
    anchor.CanTouch = false
    anchor.Transparency = 1
    anchor.Size = Vector3.new(.1, .1, .1)
    anchor.Position = position + Vector3.new(0, 5, 0)
    anchor.Parent = workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.fromOffset(120, 34)
    billboard.AlwaysOnTop = true
    billboard.Adornee = anchor
    billboard.Parent = anchor

    local caption = Instance.new("TextLabel")
    caption.Name = "Value"
    caption.Size = UDim2.fromScale(1, 1)
    caption.BackgroundTransparency = 1
    caption.Font = Enum.Font.GothamBold
    caption.TextScaled = true
    caption.TextColor3 = palette[kind] or Color3.new(1, 1, 1)
    caption.TextStrokeTransparency = .25
    caption.Text = text
    caption.Parent = billboard

    TweenService:Create(anchor, TweenInfo.new(.72, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = anchor.Position + Vector3.new(0, 4.5, 0),
    }):Play()
    TweenService:Create(caption, TweenInfo.new(.72), {
        TextTransparency = 1, TextStrokeTransparency = 1,
    }):Play()
    Debris:AddItem(anchor, .85)
end

function Effects.start(remote)
    remote.OnClientEvent:Connect(function(kind, position, amount, detail)
        if typeof(kind) ~= "string" or typeof(position) ~= "Vector3" then return end
        if not palette[kind] then return end
        local value = if typeof(amount) == "number" then math.clamp(amount, 0, 100000) else 0
        local name = if typeof(detail) == "string" then detail else ""
        worldPulse(kind, position)
        floatingNumber(kind, position, value, name)
    end)
end

return Effects
