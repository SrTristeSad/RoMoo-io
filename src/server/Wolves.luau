--!nonstrict
-- Lobo 3D com corpo gerado em Parts, opcao para modelos da Creator Store
-- previamente importados com scripts removidos, IA autoritativa em servidor.
-- Wolf original Moo-IO: sourceTypeId=4, hostil, persegue e causa dano.
local Players=game:GetService("Players")
local ServerStorage=game:GetService("ServerStorage")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage:WaitForChild("RoMoo"):WaitForChild("Shared"):WaitForChild("Config"))
local Rules=require(script.Parent:WaitForChild("MapRules"))
local Wolves={}
local rng=Random.new(Config.Seed+42)
local folder=nil
local states={}
local mapResources=nil
local running=false
-- Spatial hash estático: recursos naturais não somem no MooMoo.io.
-- Evita examinar centenas de partes a cada passo de cada lobo.
local obstacleCells = {}
local obstacleTile = 15
local function cellIndex(v)
    return math.floor(v/obstacleTile)
end
local function cellKey(x,z)
    return tostring(x)..":"..tostring(z)
end
local function indexObstacles(resources)
    obstacleCells={}
    local total=0
    for _,node in ipairs(resources:GetChildren()) do
        local kind=node:GetAttribute("Kind")
        local part=node.PrimaryPart
        if part and (kind=="Tree" or kind=="Rock" or kind=="Gold") then
            local position=part.Position
            local key=cellKey(cellIndex(position.X),cellIndex(position.Z))
            if not obstacleCells[key] then obstacleCells[key]={} end
            table.insert(obstacleCells[key],{
                point=position,
                radius=if kind=="Tree" then 4.8 else 5.2,
            })
            total+=1
        end
    end
    print("[RoMoo Lobos] Obstaculos indexados: "..total)
end

local function part(model,name,size,offset,color,shape)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=offset
    p.Color=color
    p.Shape=shape or Enum.PartType.Block
    p.Material=Enum.Material.SmoothPlastic
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=model
    return p
end

local function fallback(model,cf)
    local fur=Color3.fromRGB(111,117,124)
    local dark=Color3.fromRGB(73,79,89)
    local cream=Color3.fromRGB(174,171,160)
    part(model,"Corpo",Vector3.new(3.3,2.5,5.2),
        cf*CFrame.new(0,.1,0),fur,Enum.PartType.Ball)
    part(model,"Peito",Vector3.new(2.4,2.0,2.2),
        cf*CFrame.new(0,.15,-1.6),cream,Enum.PartType.Ball)
    part(model,"Cabeca",Vector3.new(2.7,2.3,2.4),
        cf*CFrame.new(0,1,-2.55),fur,Enum.PartType.Ball)
    part(model,"Focinho",Vector3.new(1.6,1.05,1.65),
        cf*CFrame.new(0,.57,-4.12),cream,Enum.PartType.Ball)
    part(model,"Nariz",Vector3.new(.8,.48,.65),
        cf*CFrame.new(0,.8,-4.9),dark,Enum.PartType.Ball)
    for _,side in ipairs({-1,1}) do
        part(model,"Olho",Vector3.new(.37,.35,.25),
            cf*CFrame.new(side*.85,1.34,-3.62),
            Color3.fromRGB(237,195,112),Enum.PartType.Ball)
        part(model,"Pupila",Vector3.new(.17,.22,.15),
            cf*CFrame.new(side*.85,1.34,-3.77),
            Color3.fromRGB(20,25,27),Enum.PartType.Ball)
        part(model,"Orelha",Vector3.new(.85,1.65,.65),
            cf*CFrame.new(side*.94,2.3,-2.75)*
            CFrame.Angles(0,0,math.rad(side*13)),dark)
        for _,z in ipairs({-1.7,1.65}) do
            part(model,"Perna",Vector3.new(.87,2.1,1.05),
                cf*CFrame.new(side*1.13,-1.5,z),dark)
            part(model,"Pata",Vector3.new(1.0,.58,1.3),
                cf*CFrame.new(side*1.13,-2.43,z-.3),fur)
        end
    end
    part(model,"Cauda",Vector3.new(1.16,1.25,3.2),
        cf*CFrame.new(0,.7,3.3)*CFrame.Angles(math.rad(24),0,0),
        fur,Enum.PartType.Ball)
end

local function imported(model,cf)
    local library=ServerStorage:FindFirstChild("RoMooAnimalModels")
    local template=library and library:FindFirstChild("Wolf")
    if not template or not template:IsA("Model") then return false end
    local clone=template:Clone()
    clone.Name="Visual3D"
    for _,desc in ipairs(clone:GetDescendants()) do
        if desc:IsA("LuaSourceContainer") then
            desc:Destroy()
        elseif desc:IsA("BasePart") then
            desc.Anchored=true
            desc.CanCollide=false
            desc.CanTouch=false
            desc.CanQuery=false
        end
    end
    clone.Parent=model
    local success=pcall(function()
        local size=clone:GetExtentsSize()
        local longest=math.max(size.X,size.Y,size.Z)
        assert(longest>.02 and longest<5000)
        clone:ScaleTo(math.clamp(7.5/longest,.02,10))
        clone:PivotTo(cf)
    end)
    if not success then clone:Destroy() return false end
    return true
end

local function blockedByNaturalResource(position)
    local cx=cellIndex(position.X)
    local cz=cellIndex(position.Z)
    for ix=cx-1,cx+1 do
        for iz=cz-1,cz+1 do
            local cell=obstacleCells[cellKey(ix,iz)]
            if cell then
                for _,object in ipairs(cell) do
                    local dx=object.point.X-position.X
                    local dz=object.point.Z-position.Z
                    if dx*dx+dz*dz<object.radius*object.radius then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function freeSpawn(position)
    if not Rules.insideMap(Config,position,22) then return false end
    if Rules.isRiver(Config,position,17) or Rules.isDesert(Config,position) then return false end
    if (position-Vector3.new(0,0,-64)).Magnitude<75 then return false end
    if mapResources then
        for _,resource in ipairs(mapResources:GetChildren()) do
            local p=resource.PrimaryPart
            if p then
                local dx=p.Position.X-position.X
                local dz=p.Position.Z-position.Z
                if dx*dx+dz*dz<60 then return false end
            end
        end
    end
    for _,wolf in ipairs(folder:GetChildren()) do
        local root=wolf.PrimaryPart
        if root and (Vector2.new(root.Position.X-position.X,root.Position.Z-position.Z)).Magnitude<22 then
            return false
        end
    end
    return true
end

local function spawn()
    if not folder or not folder.Parent then return nil end
    local point=nil
    for attempt=1,190 do
        local x=rng:NextNumber(-Config.MapSize*.45,Config.MapSize*.45)
        local z=rng:NextNumber(-Config.MapSize*.45,30)
        local candidate=Vector3.new(x,2.8,z)
        if freeSpawn(candidate) then point=candidate break end
    end
    if not point then return nil end
    local model=Instance.new("Model")
    model.Name="Wolf"
    model:SetAttribute("Kind","Wolf")
    model:SetAttribute("SourceTypeId",Config.Wolf.SourceTypeId)
    model:SetAttribute("Health",Config.Wolf.Health)
    model:SetAttribute("MaxHealth",Config.Wolf.Health)
    model.Parent=folder
    local cf=CFrame.new(point)
    -- Hitbox ampliada para incluir cabeça, focinho e cauda 3D.
    local core=part(model,"Core",Vector3.new(4.7,5.2,10.3),cf,
        Color3.fromRGB(129,132,135))
    core.Transparency=1
    core.CanQuery=true
    model.PrimaryPart=core
    if not imported(model,cf) then fallback(model,cf) end

    local bar=Instance.new("BillboardGui")
    bar.Name="WolfHealth"
    bar.Size=UDim2.fromOffset(73,8)
    bar.StudsOffsetWorldSpace=Vector3.new(0,3.3,0)
    bar.Adornee=core
    bar.AlwaysOnTop=true
    bar.Enabled=false
    bar.Parent=model
    local back=Instance.new("Frame")
    back.Size=UDim2.fromScale(1,1)
    back.BorderSizePixel=0
    back.BackgroundColor3=Color3.fromRGB(74,56,59)
    back.Parent=bar
    local fill=Instance.new("Frame")
    fill.Name="Fill"
    fill.BorderSizePixel=0
    fill.BackgroundColor3=Color3.fromRGB(221,83,74)
    fill.Size=UDim2.fromScale(1,1)
    fill.Parent=back

    states[model]={hp=Config.Wolf.Health,lastAttack=0,
        wander=Vector3.new(0,0,-1),nextTurn=0,phase=rng:NextNumber()*10,
        scaredUntil=0}
    return model
end

local function nearestPlayer(position)
    local target,distance,hum,bestRoot=nil,Config.Wolf.DetectionRadius,nil,nil
    for _,player in ipairs(Players:GetPlayers()) do
        local char=player.Character
        local human=char and char:FindFirstChildOfClass("Humanoid")
        local root=char and char:FindFirstChild("HumanoidRootPart")
        if root and human and human.Health>0 and not char:FindFirstChildOfClass("ForceField") then
            local delta=Vector3.new(root.Position.X-position.X,0,root.Position.Z-position.Z)
            if delta.Magnitude<distance then
                target,distance,hum,bestRoot=delta,delta.Magnitude,human,root
            end
        end
    end
    return target,distance,hum,bestRoot
end

function Wolves.hit(model,damage)
    local state=states[model]
    if not state or not model.Parent or damage<=0 then return false end
    state.hp=math.max(0,state.hp-damage)
    model:SetAttribute("Health",state.hp)
    local ui=model:FindFirstChild("WolfHealth")
    if ui then
        ui.Enabled=state.hp>0
        local bg=ui:FindFirstChildOfClass("Frame")
        local fill=bg and bg:FindFirstChild("Fill")
        if fill then fill.Size=UDim2.fromScale(state.hp/Config.Wolf.Health,1) end
    end
    if state.hp==0 then
        states[model]=nil
        model:Destroy()
        task.delay(Config.Wolf.RespawnSeconds,function()
            if folder and folder.Parent then spawn() end
        end)
        return true
    end
    return false
end

function Wolves.start(world,resources)
    if running then return folder end
    running=true
    mapResources=resources
    indexObstacles(resources)
    folder=Instance.new("Folder")
    folder.Name="Wolves"
    folder.Parent=world
    for i=1,Config.Wolf.Count do spawn() end
    task.spawn(function()
        while folder and folder.Parent do
            local dt=math.min(task.wait(.16),.25)
            local now=os.clock()
            for model,state in pairs(states) do
                if not model.Parent or not model.PrimaryPart then
                    states[model]=nil
                    continue
                end
                local position=model.PrimaryPart.Position
                local delta,distance,hum,targetRoot=nearestPlayer(position)
                if targetRoot then
                    state.packTarget=targetRoot
                    state.packUntil=now+2.8
                else
                    -- Um lobo pode seguir por alguns segundos o alvo
                    -- alertado por outro lobo próximo.
                    local sharedTarget=nil
                    for other,ally in pairs(states) do
                        if other~=model and other.PrimaryPart and ally.packTarget
                            and ally.packTarget.Parent and ally.packUntil
                            and now<ally.packUntil
                            and (other.PrimaryPart.Position-position).Magnitude<32 then
                            sharedTarget=ally.packTarget
                            break
                        end
                    end
                    if sharedTarget then
                        state.packTarget=sharedTarget
                        state.packUntil=now+2
                        local shift=sharedTarget.Position-position
                        delta=Vector3.new(shift.X,0,shift.Z)
                        distance=delta.Magnitude
                        hum=sharedTarget.Parent:FindFirstChildOfClass("Humanoid")
                    elseif state.packTarget and state.packTarget.Parent
                        and state.packUntil and now<state.packUntil then
                        local shift=state.packTarget.Position-position
                        delta=Vector3.new(shift.X,0,shift.Z)
                        distance=delta.Magnitude
                        hum=state.packTarget.Parent:FindFirstChildOfClass("Humanoid")
                    end
                end
                local dir=state.wander
                local speed=Config.Wolf.WanderSpeed
                if delta and delta.Magnitude>.1 then
                    dir=delta.Unit
                    speed=Config.Wolf.Speed
                elseif now>state.nextTurn then
                    local angle=rng:NextNumber()*math.pi*2
                    dir=Vector3.new(math.cos(angle),0,math.sin(angle))
                    state.wander=dir
                    state.nextTurn=now+rng:NextNumber(1.7,4.2)
                end
                local newPos=position+dir*speed*dt
                newPos=Rules.clampPoint(Config,newPos,19)
                newPos=Vector3.new(newPos.X,2.8,newPos.Z)
                if Rules.isRiver(Config,newPos,8) or Rules.isDesert(Config,newPos) then
                    state.wander=-dir
                    state.nextTurn=now+1
                    newPos=position
                elseif blockedByNaturalResource(newPos) then
                    -- Contornar troncos e rochas por uma tangente.
                    local tangent=Vector3.new(-dir.Z,0,dir.X)
                    local candidate=Rules.clampPoint(Config,position+tangent*speed*dt,19)
                    if not blockedByNaturalResource(candidate)
                        and not Rules.isRiver(Config,candidate,8)
                        and not Rules.isDesert(Config,candidate) then
                        dir=tangent
                        newPos=Vector3.new(candidate.X,2.8,candidate.Z)
                    else
                        newPos=position
                        state.wander=-dir
                        state.nextTurn=now+.4
                    end
                end
                if (newPos-position).Magnitude>.01 then
                    local bounce=math.abs(math.sin(now*speed*.8+state.phase))*.12
                    newPos+=Vector3.new(0,bounce,0)
                    model:PivotTo(CFrame.lookAt(newPos,newPos+dir))
                end
                if hum and distance<Config.Wolf.AttackDistance and now-state.lastAttack>=1.4 then
                    if not hum.Parent:FindFirstChildOfClass("ForceField") then
                        state.lastAttack=now
                        hum:TakeDamage(Config.Wolf.AttackDamage)
                    end
                end
            end
        end
    end)
    print("[RoMoo Lobos] " .. #folder:GetChildren() .. " lobos 3D iniciados.")
    return folder
end

return Wolves
