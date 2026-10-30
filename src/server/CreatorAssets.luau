--!nonstrict
-- Importador opcional de modelos FREE do Creator Store, executado pelo criador
-- no Command Bar do Roblox Studio, ANTES do Play. Nao roda durante a partida.
-- Usa AssetService:LoadAssetAsync (API atual); desativa/remover todo script
-- de modelos externos antes de armazenar em ServerStorage.
local AssetService=game:GetService("AssetService")
local ServerStorage=game:GetService("ServerStorage")
local RunService=game:GetService("RunService")
local Importer={}
Importer.Catalogue={
    {kind="Tree",id=3287226226,folder="RoMooResourceModels",
        label="Low-Poly Tree, por akbarbinta (2 MeshParts, 306 triangles)"},
    {kind="Wolf",id=12181904793,folder="RoMooAnimalModels",
        label="Wolf, por rpainter123 (47 MeshParts, 2 scripts no pacote original)"},
}

local function clean(container)
    local removed=0
    for _,desc in ipairs(container:GetDescendants()) do
        if desc:IsA("LuaSourceContainer") or desc:IsA("Tool")
            or desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction")
            or desc:IsA("BindableEvent") or desc:IsA("BindableFunction") then
            desc:Destroy()
            removed+=1
        elseif desc:IsA("BasePart") then
            desc.Anchored=true
            desc.CanCollide=false
            desc.CanTouch=false
            desc.CanQuery=false
        end
    end
    return removed
end

function Importer.install()
    assert(RunService:IsStudio(),"Importacao de assets so pode ser feita no Roblox Studio")
    local installed=0
    for _,entry in ipairs(Importer.Catalogue) do
        local directory=ServerStorage:FindFirstChild(entry.folder)
        if not directory then
            directory=Instance.new("Folder")
            directory.Name=entry.folder
            directory.Parent=ServerStorage
        end
        if directory:FindFirstChild(entry.kind) then
            print("[RoMoo Assets] Modelo ja importado, preservando:",
                directory.Name.."/"..entry.kind)
            continue
        end
        local success,asset=pcall(function()
            return AssetService:LoadAssetAsync(entry.id)
        end)
        if not success or not asset then
            warn("[RoMoo Assets] Falhou "..entry.label..": "..tostring(asset))
            warn("Verifique acesso ao modelo e a opcao Allow Loading Third Party Assets.")
            continue
        end
        local removed=clean(asset)
        local geometries=0
        for _,item in ipairs(asset:GetDescendants()) do
            if item:IsA("BasePart") then geometries+=1 end
        end
        if geometries==0 then
            asset:Destroy()
            warn("[RoMoo Assets] Asset sem malha 3D: "..entry.kind)
            continue
        end
        asset.Name=entry.kind
        asset.Parent=directory
        installed+=1
        print(("[RoMoo Assets] %s importado: %d pecas 3D; %d scripts/itens eliminados.")
            :format(entry.kind,geometries,removed))
    end
    print("[RoMoo Assets] Importacao concluida: "..installed.." novos modelos.")
    return installed
end
return Importer
