--!nonstrict
-- O Moo-IO usa keepInWorld(); Roblox recebe colisoes invisiveis e seguranca
-- adicional de servidor para impedir quedas e teleporte fora dos limites.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Rules=require(script.Parent:WaitForChild("MapRules"))
local Boundary={}
local started=false

function Boundary.start(config)
    if started then return end
    started=true
    local elapsed=0
    RunService.Heartbeat:Connect(function(dt)
        elapsed+=math.min(dt,.1)
        if elapsed<.15 then return end
        elapsed=0
        for _,player in ipairs(Players:GetPlayers()) do
            local char=player.Character
            local root=char and char:FindFirstChild("HumanoidRootPart")
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            if not root or not hum or hum.Health<=0 then continue end
            local pos=root.Position
            local newPos=Rules.clampPoint(config,pos,5)
            local fell=pos.Y < -25
            if fell then
                -- Recuperacao de jogador que caiu atraves do leito ou da borda.
                newPos=Vector3.new(0,5,-64)
            end
            if fell or math.abs(pos.X-newPos.X)>.01 or
                math.abs(pos.Z-newPos.Z)>.01 then
                local rotation=root.CFrame - root.Position
                char:PivotTo(CFrame.new(newPos)*rotation)
                root.AssemblyLinearVelocity=Vector3.zero
            end
        end
    end)
end

return Boundary
