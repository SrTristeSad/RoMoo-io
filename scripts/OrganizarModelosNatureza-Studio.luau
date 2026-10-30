--!nonstrict
-- Script da Command Bar do SERVIDOR em modo EDICAO.
-- Importe os .glb da pasta assets/nature pelo menu Arquivo > Importar,
-- selecione os Models resultantes e execute este conteudo na Command Bar.
-- Nao executar durante Play. Originais permanecem na Workspace para revisao.
local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")
assert(RunService:IsStudio() and not RunService:IsRunning(),
    "Use a Command Bar durante a EDICAO, nao no Play.")
local src = Selection:Get()
assert(#src>0,"Selecione os Models importados no Explorer antes de rodar.")
local names = {
    ["tree-default"]="Tree",["tree-oak"]="Tree",["tree-cone"]="Tree",
    ["tree-pinetalla"]="Tree",["rock-largea"]="Rock",["rock-largeb"]="Rock",
    ["plant-bushlarge"]="Bush",["plant-bushdetailed"]="Bush",
    ["cactus-tall"]="Cactus",["cactus-short"]="Cactus",
}
local library = ServerStorage:FindFirstChild("RoMooResourceModels")
if not library then
    library=Instance.new("Folder")
    library.Name="RoMooResourceModels"
    library.Parent=ServerStorage
end
local added=0
local function classify(model)
    local lower=string.lower(model.Name)
    lower=string.gsub(lower,"%.glb$","")
    for prefix,kind in pairs(names) do
        if lower==prefix or string.find(lower,prefix,1,true) then
            return prefix,kind
        end
    end
    return nil,nil
end
for _,original in ipairs(src) do
    if original:IsA("Model") or original:IsA("MeshPart") then
        local name,kind=classify(original)
        if kind then
            local folder=library:FindFirstChild(kind)
            if not folder then
                folder=Instance.new("Folder")
                folder.Name=kind
                folder.Parent=library
            end
            if not folder:IsA("Folder") then
                warn("Conflito de nome em RoMooResourceModels."..kind)
                continue
            end
            local duplicate=original:Clone()
            if duplicate:IsA("MeshPart") then
                local wrapper=Instance.new("Model")
                duplicate.Parent=wrapper
                wrapper.PrimaryPart=duplicate
                duplicate=wrapper
            end
            duplicate.Name=name
            for _,item in ipairs(duplicate:GetDescendants()) do
                if item:IsA("LuaSourceContainer") then item:Destroy() end
                if item:IsA("BasePart") then
                    item.Anchored=true
                    item.CanCollide=false
                    item.CanTouch=false
                    item.CanQuery=false
                end
            end
            local old=folder:FindFirstChild(name)
            if old then old:Destroy() end
            duplicate.Parent=folder
            added+=1
        else
            warn("Modelo nao reconhecido: "..original.Name)
        end
    end
end
print("[RoMoo] Modelos preparados: "..added..
    ". Rode Play para testar as arvores e rochas 3D.")
