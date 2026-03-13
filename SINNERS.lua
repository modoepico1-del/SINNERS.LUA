local espEnabled     = false
local espObjects     = {}
local espConnections = {}

local function createESP(plr)
    if plr == LocalPlayer then return end
    if not plr.Character then return end
    if plr.Character:FindFirstChild("NightESP") then return end
    local c = plr.Character
    local charHrp = c:FindFirstChild("HumanoidRootPart")
    if not charHrp then return end
    local humanoid = c:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end

    local hitbox = Instance.new("BoxHandleAdornment")
    hitbox.Name = "NightESP"
    hitbox.Adornee = charHrp
    hitbox.Size = Vector3.new(4, 6, 2)
    hitbox.Color3 = Color3.fromRGB(255, 80, 80)
    hitbox.Transparency = 0.5
    hitbox.ZIndex = 10
    hitbox.AlwaysOnTop = true
    hitbox.Parent = c

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NightESP_Name"
    billboard.Adornee = charHrp
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = c

    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true

    espObjects[plr] = {box = hitbox, label = billboard, character = c}
end

local function removeESP(plr)
    pcall(function()
        if plr.Character then
            local hitbox = plr.Character:FindFirstChild("NightESP")
            if hitbox then hitbox:Destroy() end
            local label = plr.Character:FindFirstChild("NightESP_Name")
            if label then label:Destroy() end
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Automatic end
        end
        if espObjects[plr] then espObjects[plr] = nil end
    end)
end

local function enableESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if plr.Character then pcall(function() createESP(plr) end) end
            local conn = plr.CharacterAdded:Connect(function()
                task.wait(0.1)
                if espEnabled then pcall(function() createESP(plr) end) end
            end)
            table.insert(espConnections, conn)
        end
    end
    local playerAddedConn = Players.PlayerAdded:Connect(function(plr)
        if plr == LocalPlayer then return end
        local charAddedConn = plr.CharacterAdded:Connect(function()
            task.wait(0.1)
            if espEnabled then pcall(function() createESP(plr) end) end
        end)
        table.insert(espConnections, charAddedConn)
    end)
    table.insert(espConnections, playerAddedConn)
end

local function disableESP()
    for _, plr in ipairs(Players:GetPlayers()) do pcall(function() removeESP(plr) end) end
    for _, conn in ipairs(espConnections) do
        if conn and conn.Connected then conn:Disconnect() end
    end
    espConnections = {}
    espObjects = {}
end
