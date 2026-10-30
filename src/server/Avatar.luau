--!nonstrict
-- Avatar Roblox original, sem ocultar partes ou substituir corpo por esferas.
local Avatar = {}
function Avatar.attach(player, character, humanoid)
    humanoid.WalkSpeed = 19
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    local head = character:WaitForChild("Head", 10)
    if not head then return end
    local overhead = Instance.new("BillboardGui")
    overhead.Name = "RoMooOverhead"
    overhead.Adornee = head
    overhead.Size = UDim2.fromOffset(150, 38)
    overhead.StudsOffsetWorldSpace = Vector3.new(0, 2.3, 0)
    overhead.AlwaysOnTop = true
    overhead.Parent = character
    local name = Instance.new("TextLabel")
    name.Size = UDim2.fromOffset(150, 22)
    name.BackgroundTransparency = 1
    name.TextScaled = true
    name.Font = Enum.Font.GothamBold
    name.TextColor3 = Color3.new(1, 1, 1)
    name.TextStrokeTransparency = .3
    name.Parent = overhead
    local track = Instance.new("Frame")
    track.Position = UDim2.fromOffset(25, 25)
    track.Size = UDim2.fromOffset(100, 8)
    track.BackgroundColor3 = Color3.fromRGB(70, 60, 60)
    track.BorderSizePixel = 0
    track.Parent = overhead
    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(1, 1)
    fill.BackgroundColor3 = Color3.fromRGB(66, 203, 93)
    fill.BorderSizePixel = 0
    fill.Parent = track
    local function update()
        local clan = player:GetAttribute("ClanCode")
        name.Text = if typeof(clan) == "string" and clan ~= "" then "[" .. clan .. "] " .. player.DisplayName else player.DisplayName
        fill.Size = UDim2.fromScale(math.clamp(humanoid.Health / math.max(1, humanoid.MaxHealth), 0, 1), 1)
    end
    local c1 = humanoid.HealthChanged:Connect(update)
    local c2 = player:GetAttributeChangedSignal("ClanCode"):Connect(update)
    character.Destroying:Connect(function() c1:Disconnect() c2:Disconnect() end)
    update()
end
return Avatar
