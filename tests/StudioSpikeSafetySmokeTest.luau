--!nonstrict
-- Executar no Server Command Bar em modo Play.
-- Garante que os espinhos respeitam ForceField e nunca atingem o dono.
local Players=game:GetService("Players")
local ServerScriptService=game:GetService("ServerScriptService")
local Structures=require(ServerScriptService:WaitForChild("RoMoo"):WaitForChild("Structures"))
local dummy=Instance.new("Model")
dummy.Name="SpikeTestCharacter"
dummy.Parent=workspace
local human=Instance.new("Humanoid")
human.MaxHealth=100
human.Health=100
human.Parent=dummy
local victim={UserId=-90001,Character=dummy}
assert(Structures.canSpikeHitPlayer(victim,-90002),"Inimigo valido deveria sofrer dano")
assert(not Structures.canSpikeHitPlayer(victim,victim.UserId),"Dono nao pode sofrer dano")
local shield=Instance.new("ForceField")
shield.Parent=dummy
assert(not Structures.canSpikeHitPlayer(victim,-90002),"Protecao de nascimento ignorada")
shield:Destroy()
human.Health=0
assert(not Structures.canSpikeHitPlayer(victim,-90002),"Jogador morto elegivel para dano")
human.Health=100
assert(Structures.canSpikeHitPlayer(victim,-90002),"Nao reativou depois de remover protecao")
victim.Character=nil
assert(not Structures.canSpikeHitPlayer(victim,-90002),"Personagem ausente aceito")
dummy:Destroy()
local world=workspace:WaitForChild("RoMooWorld")
local wildlife=world:WaitForChild("Animals")
local wolves=world:WaitForChild("Wolves")
assert(wildlife.Parent==world and wolves.Parent==world,"Fauna indisponivel")
assert(wildlife~=wolves,"Lobos duplicados na fauna")
assert(world:FindFirstChild("Buildings"),"Pasta de construcao indisponivel")
print("[RoMoo SPIKES] PASS: ForceField, dono, personagem morto, fauna separada.")
