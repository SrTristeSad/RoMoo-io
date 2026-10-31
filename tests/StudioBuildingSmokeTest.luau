--!nonstrict
-- Cole no Command Bar do SERVIDOR durante Play. Faz/retira UMA construção
-- por tipo e restaura o inventário do jogador. Não executa código de terceiros.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local scripts=game:GetService("ServerScriptService"):WaitForChild("RoMoo")
local Config=require(ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local Structures=require(scripts:WaitForChild("Structures"))
local Rules=require(scripts:WaitForChild("MapRules"))
local player=Players:GetPlayers()[1]
assert(player and player.Character and player.Character.PrimaryPart,"Entre no Play antes do teste")
local char=player.Character
local original=char:GetPivot()
local stock={Wood=250,Stone=150,Gold=0,Food=0}
local oldWood,oldStone=player:GetAttribute("Wood"),player:GetAttribute("Stone")
local buildings=workspace:WaitForChild("RoMooWorld"):WaitForChild("Buildings")
local natural=workspace.RoMooWorld:WaitForChild("Resources")
local wolfFolder=workspace.RoMooWorld:WaitForChild("Wolves")
assert(Config.Buildings.Wall and Config.Buildings.Spikes
    and Config.Buildings.Windmill and Config.Buildings.StoneWall)
assert(Config.Buildings.StoneWall.minAge==4)
assert(Config.Buildings.StoneWall.health>Config.Buildings.Wall.health)
assert(Config.Buildings.Wall.cost.Wood > 0)
assert(Config.Buildings.Spikes.cost.Stone > 0)
assert(Config.Buildings.Windmill.goldPerTick > 0)
assert(Structures.folder()==buildings,"Instancia incorreta de Buildings")
local invalid,err=Structures.tryBuild(player,"Wall",Vector3.new(1,0,0),{Wood=0,Stone=0},9)
assert(invalid==nil and err,"Construcao gratuita com inventario vazio")
local nilModel=Structures.tryBuild(player,"NaoExiste",Vector3.new(1,0,0),stock,9)
assert(nilModel==nil,"Aceitou estrutura desconhecida")
local locked,reason=Structures.tryBuild(player,"StoneWall",Vector3.new(1,0,0),stock,1)
assert(not locked and reason and reason:find("idade"),
    "Muro de pedra desbloqueado antes da idade 4")

local function sample(kind)
    for x=-160,160,19 do
        for z=-195,190,19 do
            local loc=Vector3.new(x,0,z)
            local placement=Vector3.new(math.floor((x+12)/2+.5)*2,0,
                math.floor(z/2+.5)*2)
            if Rules.insideMap(Config,placement,14)
                and not Rules.isRiver(Config,placement,7)
                and (placement-Vector3.new(0,0,-64)).Magnitude>=17 then
                local clear=true
                for _,node in ipairs(natural:GetChildren()) do
                    local p=node.PrimaryPart
                    if p then
                        local d=Vector2.new(placement.X-p.Position.X,placement.Z-p.Position.Z).Magnitude
                        if d<9 then clear=false break end
                    end
                end
                if clear then
                    char:PivotTo(CFrame.new(x,4,z))
                    local a,b=Structures.tryBuild(player,kind,Vector3.new(1,0,0),stock,9)
                    if a then return a end
                end
            end
        end
    end
    return nil
end

for _,kind in ipairs({"Wall","Spikes","Windmill","StoneWall"}) do
    local before=stock.Wood
    local built=sample(kind)
    assert(built and built.Parent==buildings,"Nao conseguiu construir "..kind)
    assert(built:GetAttribute("OwnerUserId")==player.UserId,"Propriedade incorreta")
    assert(built:GetAttribute("Health")==Config.Buildings[kind].health,"Vida inicial incorreta")
    for _,part in ipairs(built:GetDescendants()) do
        if part:IsA("BasePart") then
            if part==built.PrimaryPart then
                assert(part.CanQuery,"Core nao pode perder deteccao de ataque")
            else
                assert(not part.CanQuery and not part.CanCollide,
                    "Decoracao nao deve multiplicar colisoes ou consultas")
            end
        end
    end
    assert(stock.Wood==before-Config.Buildings[kind].cost.Wood,"Custo de madeira incorreto")
    assert(Structures.damage(built,4)==false,"Destruicao com dano insuficiente")
    assert(built:GetAttribute("Health")==Config.Buildings[kind].health-4)
    assert(Structures.damage(built,100000)==true,"Nao destruiu estrutura apos dano fatal")
    assert(built.Parent==nil,"Estrutura destruida ainda no mundo")
end
for _,node in ipairs(natural:GetChildren()) do
    assert(node:GetAttribute("Health")==nil and node.Parent==natural,
        "Recurso natural foi destruido/danificado")
end
char:PivotTo(original)
player:SetAttribute("Wood",oldWood or 0)
player:SetAttribute("Stone",oldStone or 0)
print("[RoMoo] PASS: parede, espinhos, moinho, muro de pedra, requisitos de idade, custos e recursos infinitos.")
