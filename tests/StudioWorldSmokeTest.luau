-- Cole no Command Bar do Roblox Studio após iniciar a sessão Play.
-- Validação rápida apenas do cenário; não substitui o teste com jogadores.
local world = workspace:WaitForChild("RoMooWorld", 15)
assert(world, "RoMooWorld ausente")
local resources = world:FindFirstChild("Resources")
local animals = world:FindFirstChild("Animals")
local decor = world:FindFirstChild("Decorations")
assert(resources and #resources:GetChildren() > 0, "Recursos ausentes")
assert(animals and #animals:GetChildren() > 0, "Animais ausentes")
assert(decor, "Decorações ausentes (veja Config.Decoration.Enabled)")
local parts = 0
local forbidden = 0
for _, part in ipairs(decor:GetDescendants()) do
    if part:IsA("BasePart") then
        parts += 1
        if part.CanCollide or part.CanTouch or part.CanQuery then forbidden += 1 end
    end
end
assert(parts > 0, "Decoração sem partes")
assert(forbidden == 0, "Há " .. forbidden .. " partes decorativas com física/query ativos")
local baseplate = workspace:FindFirstChild("Baseplate")
assert(baseplate == nil or baseplate.Size.X < 500, "Baseplate padrão sobreposta ao mapa")
print(string.format("[RoMoo Smoke] PASS: %d recursos, %d animais, %d peças de cenário",
    #resources:GetChildren(), #animals:GetChildren(), parts))
