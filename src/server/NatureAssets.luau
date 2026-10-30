--!nonstrict
-- Carrega somente malhas visuais de um pacote oficial do Roblox.
-- Nao incorpora scripts, humanoids ou assemblies do pacote externo.
-- Se o marketplace estiver inacessivel, o mapa usa as geometrias nativas.
local AssetService = game:GetService("AssetService")
local ServerStorage = game:GetService("ServerStorage")
local NatureAssets = {}
local HAS_PREPARED = false
local SOURCE_ID = 6933438443 -- Synty Nature Pack, publicado por @Roblox
local MAX_PER_KIND = 4

local function classify(text)
    local name = string.lower(text)
    if string.find(name,"tree",1,true) or string.find(name,"pine",1,true)
        or string.find(name,"oak",1,true) or string.find(name,"palm",1,true) then
        return "Tree"
    end
    if string.find(name,"bush",1,true) or string.find(name,"shrub",1,true) then
        return "Bush"
    end
    if string.find(name,"rock",1,true) or string.find(name,"boulder",1,true) then
        return "Rock"
    end
    return nil
end

local function withAncestors(node, boundary)
    local words = {node.Name}
    local cursor = node.Parent
    for _ = 1, 2 do
        if not cursor or cursor == boundary then break end
        table.insert(words,cursor.Name)
        cursor = cursor.Parent
    end
    return table.concat(words," ")
end

local function cleanVisual(model)
    local count = 0
    for _, item in ipairs(model:GetDescendants()) do
        if item:IsA("LuaSourceContainer") or item:IsA("Humanoid")
            or item:IsA("AnimationController") or item:IsA("Animator")
            or item:IsA("Constraint") then
            item:Destroy()
        elseif item:IsA("BasePart") then
            item.Anchored = true
            item.CanCollide = false
            item.CanTouch = false
            item.CanQuery = false
            item.Massless = true
            count += 1
        end
    end
    return count > 0
end

local function ensureLibrary()
    local library = ServerStorage:FindFirstChild("RoMooResourceModels")
    if not library then
        library = Instance.new("Folder")
        library.Name = "RoMooResourceModels"
        library.Parent = ServerStorage
    end
    return library
end

local function populated(library, kind)
    local existing = library:FindFirstChild(kind)
    if not existing then return false end
    if existing:IsA("Model") then return true end
    if existing:IsA("Folder") then
        for _, child in ipairs(existing:GetChildren()) do
            if child:IsA("Model") then return true end
        end
    end
    return false
end

-- Prefere modelos ja importados pelo usuario (Kenney, Synty ou autoria propria).
function NatureAssets.prepare(config)
    local library = ensureLibrary()
    if HAS_PREPARED or not config.NatureAssetsEnabled then return library end
    HAS_PREPARED = true

    local needed = {}
    for _, kind in ipairs({"Tree","Rock","Bush"}) do
        if not populated(library,kind) then needed[kind] = true end
    end
    if not next(needed) then return library end

    local ok, container = pcall(function()
        return AssetService:LoadAssetAsync(SOURCE_ID)
    end)
    if not ok or not container then
        warn("[RoMoo 3D] Nature Pack indisponivel. Usando os modelos nativos.")
        return library
    end

    local counts = {Tree=0,Rock=0,Bush=0}
    local used = {}
    local function add(kind, original)
        if not needed[kind] or counts[kind] >= MAX_PER_KIND then return end
        local candidate = original:Clone()
        local wrapper
        if candidate:IsA("Model") then
            wrapper = candidate
        else
            wrapper = Instance.new("Model")
            candidate.Parent = wrapper
            wrapper.PrimaryPart = candidate
        end
        if not cleanVisual(wrapper) then wrapper:Destroy() return end
        local group = library:FindFirstChild(kind)
        if not group then
            group = Instance.new("Folder")
            group.Name = kind
            group.Parent = library
        end
        -- Nao substitui pacotes selecionados manualmente no Studio.
        if not group:IsA("Folder") then wrapper:Destroy() return end
        counts[kind] += 1
        wrapper.Name = kind .. "Variant" .. counts[kind]
        wrapper.Parent = group
        used[original] = true
    end

    -- 1: objetos completos organizados como Model
    for _, item in ipairs(container:GetDescendants()) do
        if item:IsA("Model") then
            local kind = classify(item.Name)
            if kind and needed[kind] and counts[kind] < MAX_PER_KIND then
                local size = 0
                for _, part in ipairs(item:GetDescendants()) do
                    if part:IsA("BasePart") then size += 1 end
                end
                if size >= 1 and size <= 12 then
                    add(kind,item)
                end
            end
        end
    end
    -- 2: pacotes cujo item individual e um MeshPart (sem Model proprio)
    for _, item in ipairs(container:GetDescendants()) do
        if item:IsA("MeshPart") then
            local kind = classify(withAncestors(item,container))
            if kind and needed[kind] and counts[kind] < MAX_PER_KIND then
                local cursor=item.Parent
                local alreadyUsed=false
                while cursor and cursor~=container do
                    if used[cursor] then alreadyUsed=true break end
                    cursor=cursor.Parent
                end
                if not alreadyUsed then add(kind,item) end
            end
        end
    end
    container:Destroy()
    print(("[RoMoo 3D] Synty carregado: %d arvores, %d rochas, %d arbustos")
        :format(counts.Tree,counts.Rock,counts.Bush))
    return library
end

return NatureAssets
