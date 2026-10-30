--!nonstrict
-- Corrente +X e lentidao, portados da logica de movement.lua do Moo-IO.
-- Terrain.WaterWaveSpeed so muda ondas: a corrente precisa de movimento fisico.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Rules=require(script.Parent:WaitForChild("MapRules"))
local Flow={}
local states=setmetatable({},{__mode="k"})
local started=false
local function removeForce(record)
    if record and record.force then record.force:Destroy() record.force=nil end
    if record and record.attachment then record.attachment:Destroy() record.attachment=nil end
end
local function ensureForce(record,root)
    if record.root ~= root then
        removeForce(record)
        record.root=root
    end
    if record.force then return record.force end
    local attachment=Instance.new("Attachment")
    attachment.Name="RoMooRiverAttachment"
    attachment.Parent=root
    local force=Instance.new("VectorForce")
    force.Name="RoMooCurrentForce"
    force.Attachment0=attachment
    force.ApplyAtCenterOfMass=true
    force.RelativeTo=Enum.ActuatorRelativeTo.World
    force.Parent=root
    record.force=force
    record.attachment=attachment
    return force
end

function Flow.isInCurrent(config,position)
    return Rules.insideMap(config,position,4) and
        Rules.isRiver(config,position,-2.5) and
        position.Y > -10 and position.Y < 4
end

function Flow.start(config)
    if started then return end
    started=true
    local elapsed=0
    RunService.Heartbeat:Connect(function(dt)
        elapsed+=math.min(dt,.1)
        if elapsed<.09 then return end
        local step=elapsed
        elapsed=0
        for _,player in ipairs(Players:GetPlayers()) do
            local char=player.Character
            local humanoid=char and char:FindFirstChildOfClass("Humanoid")
            local root=char and char:FindFirstChild("HumanoidRootPart")
            if humanoid and root and humanoid.Health>0 then
                local wet=Flow.isInCurrent(config,root.Position)
                local state=states[humanoid]
                local snow=Rules.isSnow(config,root.Position)
                local factor=if wet then config.River.SwimSpeedMultiplier
                    else if snow then config.SnowSpeedMultiplier else 1
                local needsSlow=math.abs(factor-1)>.001
                if needsSlow then
                    if not state then
                        state={original=humanoid.WalkSpeed,root=root}
                        states[humanoid]=state
                    end
                    local desired=state.original*factor
                    if math.abs(humanoid.WalkSpeed-desired)>.1 then
                        humanoid.WalkSpeed=desired
                    end
                elseif state then
                    humanoid.WalkSpeed=state.original
                end
                if wet then
                    local record=state
                    if not record then
                        record={original=humanoid.WalkSpeed,root=root}
                        states[humanoid]=record
                    end
                    local force=ensureForce(record,root)
                    local speed=config.River.CurrentSpeed*config.River.CurrentDirection
                    local vx=root.AssemblyLinearVelocity.X
                    if math.abs(speed-vx)>1 and (speed-vx)*speed>0 then
                        force.Force=Vector3.new(root.AssemblyMass*24*config.River.CurrentDirection,0,0)
                    else
                        force.Force=Vector3.zero
                    end
                    humanoid:SetAttribute("RiverCurrent",true)
                else
                    if state then removeForce(state) end
                    if humanoid:GetAttribute("RiverCurrent") then
                        humanoid:SetAttribute("RiverCurrent",false)
                    end
                end
                if not needsSlow then states[humanoid]=nil end
            elseif humanoid and states[humanoid] then
                removeForce(states[humanoid])
                states[humanoid]=nil
            end
        end
    end)
    print("[RoMoo Rio] Correnteza +X por VectorForce, neve lenta e rio sem ponte.")
end

return Flow
