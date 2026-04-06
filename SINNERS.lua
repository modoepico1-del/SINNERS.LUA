-- ██████████████████████████████████████████
-- ██       DRAGON x DEMON HUB               ██
-- ██   UI: Dragon Hub | Logic: Demontime     ██
-- ██████████████████████████████████████████

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local HttpService      = game:GetService("HttpService")

local me            = Players.LocalPlayer
local Camera        = workspace.CurrentCamera
local CONFIG_FILE   = "DRAGONDEMON_config.json"

-- ══════════════════════════════════════════
--              ESTADO GLOBAL
-- ══════════════════════════════════════════
local unwalkOn              = false
local unwalkConn            = nil
local xrayOn                = false
local xrayDescConn          = nil
local xrayCharConn          = nil
local originalTransparency  = {}
local espOn                 = false
local espObjects            = {}
local espConnections        = {}
local antiRagdollOn         = false
local antiRagdollMode       = nil
local ragdollConnections    = {}
local cachedCharData        = {}
local infJumpOn             = false
local autoStealActive       = false
local AUTO_STEAL_PROX_RADIUS = 7
local galaxySkyOn           = false
local batAimbotOn           = false
local batAimbotConnection   = nil
local speedOn               = false
local speedConnection       = nil
local speedNoStealValue     = 53
local speedStealValue       = 29
local fovValue              = 70
local FOV_MIN, FOV_MAX      = 70, 120
local AutoLeftEnabled       = false
local AutoRightEnabled      = false
local autoLeftConnection    = nil
local autoRightConnection   = nil
local autoLeftPhase         = 1
local autoRightPhase        = 1
local NORMAL_SPEED_ROUTE    = 60

-- ══════════════════════════════════════════
--           ROUTE POSITIONS
-- ══════════════════════════════════════════
local POS_L1 = Vector3.new(-476.48, -6.28,  92.73)
local POS_L2 = Vector3.new(-483.12, -4.95,  94.80)
local POS_R1 = Vector3.new(-476.16, -6.52,  25.62)
local POS_R2 = Vector3.new(-483.04, -5.09,  23.14)

-- ══════════════════════════════════════════
--           SAVE / LOAD CONFIG
-- ══════════════════════════════════════════
local savedCfg = {}
pcall(function() savedCfg = HttpService:JSONDecode(readfile(CONFIG_FILE)) end)

local function saveConfig()
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode({
            Unwalk      = unwalkOn,
            Xray        = xrayOn,
            ESP         = espOn,
            AntiRagdoll = antiRagdollOn,
            FOV         = fovValue,
            InfJump     = infJumpOn,
            AutoSteal   = autoStealActive,
            StealRadius = AUTO_STEAL_PROX_RADIUS,
            GalaxySky   = galaxySkyOn,
            SpeedNormal = speedNoStealValue,
            SpeedSteal  = speedStealValue,
        }))
    end)
end

-- ══════════════════════════════════════════
--              GUI HELPERS
-- ══════════════════════════════════════════
local function Make(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function Tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.15), props):Play()
end

-- ══════════════════════════════════════════
--              SCREENGUI
-- ══════════════════════════════════════════
local existing = game:GetService("CoreGui"):FindFirstChild("DragonDemonHub")
if existing then existing:Destroy() end

local ScreenGui = Make("ScreenGui", {
    Name            = "DragonDemonHub",
    ResetOnSpawn    = false,
    ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
    Parent          = (gethui and gethui()) or me:WaitForChild("PlayerGui"),
})

-- ══════════════════════════════════════════
--              MAIN FRAME
-- ══════════════════════════════════════════
local MainFrame = Make("Frame", {
    Name             = "MainFrame",
    Size             = UDim2.new(0, 340, 0, 480),
    Position         = UDim2.new(0.5, -170, 0.5, -240),
    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
    BorderSizePixel  = 0,
    Parent           = ScreenGui,
})
Make("UICorner",  { CornerRadius = UDim.new(0, 10), Parent = MainFrame })
Make("UIStroke",  { Color = Color3.fromRGB(50, 50, 50), Thickness = 1, Parent = MainFrame })

-- Drag
do
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = inp.Position; startPos = MainFrame.Position
        end
    end)
    MainFrame.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                           startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- ══════════════════════════════════════════
--              TOP BAR
-- ══════════════════════════════════════════
local TopBar = Make("Frame", {
    Size             = UDim2.new(1, 0, 0, 38),
    BackgroundColor3 = Color3.fromRGB(22, 22, 22),
    BorderSizePixel  = 0,
    Parent           = MainFrame,
})
Make("UICorner", { CornerRadius = UDim.new(0, 10), Parent = TopBar })

Make("TextLabel", {
    Text = "DRAGON×DEMON HUB",
    Size = UDim2.new(0, 170, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBlack,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar,
})

local CloseBtn = Make("TextButton", {
    Text = "−",
    Size = UDim2.new(0, 28, 0, 20),
    Position = UDim2.new(1, -32, 0.5, -10),
    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
    TextColor3 = Color3.fromRGB(200, 200, 200),
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    BorderSizePixel = 0,
    Parent = TopBar,
})
Make("UICorner", { CornerRadius = UDim.new(0, 5), Parent = CloseBtn })
CloseBtn.MouseButton1Click:Connect(function()
    Tween(MainFrame, { Size = UDim2.new(0, 340, 0, 0) }, 0.2)
    task.delay(0.22, function() MainFrame.Visible = false end)
end)

-- ══════════════════════════════════════════
--          LEFT PANEL (TABS)
-- ══════════════════════════════════════════
local LeftPanel = Make("Frame", {
    Size             = UDim2.new(0, 100, 1, -40),
    Position         = UDim2.new(0, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BorderSizePixel  = 0,
    Parent           = MainFrame,
})
Make("UICorner", { CornerRadius = UDim.new(0, 8), Parent = LeftPanel })

local RightPanel = Make("Frame", {
    Size             = UDim2.new(1, -108, 1, -48),
    Position         = UDim2.new(0, 106, 0, 44),
    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
    BorderSizePixel  = 0,
    Parent           = MainFrame,
})

-- ══════════════════════════════════════════
--              TAB SYSTEM
-- ══════════════════════════════════════════
local Tabs    = {}
local TabBtns = {}

local function CreateTab(name, index)
    local btn = Make("TextButton", {
        Text             = name,
        Size             = UDim2.new(1, -10, 0, 34),
        Position         = UDim2.new(0, 5, 0, 8 + (index - 1) * 40),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        TextColor3       = Color3.fromRGB(180, 180, 180),
        Font             = Enum.Font.GothamSemibold,
        TextSize         = 11,
        BorderSizePixel  = 0,
        Parent           = LeftPanel,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 7), Parent = btn })

    local scroll = Make("ScrollingFrame", {
        Size                = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        ScrollBarThickness  = 3,
        ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
        CanvasSize          = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible             = false,
        Parent              = RightPanel,
    })

    Tabs[name]    = scroll
    TabBtns[name] = btn
    return btn, scroll
end

local function SelectTab(name)
    for n, c in pairs(Tabs) do
        c.Visible = (n == name)
        local btn = TabBtns[n]
        if n == name then
            Tween(btn, { BackgroundColor3 = Color3.fromRGB(255,255,255), TextColor3 = Color3.fromRGB(10,10,10) })
            btn.Font = Enum.Font.GothamBlack
        else
            Tween(btn, { BackgroundColor3 = Color3.fromRGB(35,35,35), TextColor3 = Color3.fromRGB(180,180,180) })
            btn.Font = Enum.Font.GothamSemibold
        end
    end
end

-- ══════════════════════════════════════════
--          CREAR TABS
-- ══════════════════════════════════════════
local tabNames = {"Combat", "Movement", "Visual", "Auto", "Speed", "Settings"}
for i, name in ipairs(tabNames) do
    local btn, _ = CreateTab(name, i)
    btn.MouseButton1Click:Connect(function() SelectTab(name) end)
end

-- ══════════════════════════════════════════
--          UI COMPONENTES HELPERS
-- ══════════════════════════════════════════
local function SectionLabel(parent, text, yPos)
    Make("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -10, 0, 18),
        Position = UDim2.new(0, 5, 0, yPos),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(100, 100, 100),
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent,
    })
end

local function CreateToggle(parent, label, yPos, default, callback)
    local row = Make("Frame", {
        Size             = UDim2.new(1, -6, 0, 36),
        Position         = UDim2.new(0, 3, 0, yPos),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 7), Parent = row })

    Make("TextLabel", {
        Text = label,
        Size = UDim2.new(0.72, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local state = default or false
    local togBG = Make("Frame", {
        Size             = UDim2.new(0, 42, 0, 22),
        Position         = UDim2.new(1, -48, 0.5, -11),
        BackgroundColor3 = state and Color3.fromRGB(240,240,240) or Color3.fromRGB(55,55,55),
        BorderSizePixel  = 0,
        Parent           = row,
    })
    Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = togBG })

    local knob = Make("Frame", {
        Size             = UDim2.new(0, 16, 0, 16),
        Position         = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel  = 0,
        Parent           = togBG,
    })
    Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

    local clickBtn = Make("TextButton", {
        Text = "", Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1, Parent = row,
    })
    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        Tween(togBG, { BackgroundColor3 = state and Color3.fromRGB(240,240,240) or Color3.fromRGB(55,55,55) })
        Tween(knob,  { Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8) })
        if callback then callback(state) end
    end)

    return togBG, knob
end

local function CreateSlider(parent, label, yPos, value, minV, maxV, callback)
    local row = Make("Frame", {
        Size             = UDim2.new(1, -6, 0, 48),
        Position         = UDim2.new(0, 3, 0, yPos),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 7), Parent = row })

    Make("TextLabel", {
        Text = label,
        Size = UDim2.new(0.65, 0, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local valBox = Make("Frame", {
        Size             = UDim2.new(0, 54, 0, 24),
        Position         = UDim2.new(1, -58, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel  = 0,
        Parent           = row,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = valBox })

    local valLbl = Instance.new("TextBox")
    valLbl.Size = UDim2.new(1,0,1,0); valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(value); valLbl.TextColor3 = Color3.fromRGB(220,220,220)
    valLbl.Font = Enum.Font.GothamBold; valLbl.TextSize = 11
    valLbl.ClearTextOnFocus = false; valLbl.BorderSizePixel = 0
    valLbl.Parent = valBox

    local sliderBG = Make("Frame", {
        Size             = UDim2.new(1, -20, 0, 4),
        Position         = UDim2.new(0, 10, 1, -8),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        BorderSizePixel  = 0,
        Parent           = row,
    })
    Make("UICorner", { CornerRadius = UDim.new(1,0), Parent = sliderBG })

    local pct = math.clamp((value - minV) / (maxV - minV), 0, 1)
    local sliderFill = Make("Frame", {
        Size             = UDim2.new(pct, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(220, 220, 220),
        BorderSizePixel  = 0,
        Parent           = sliderBG,
    })
    Make("UICorner", { CornerRadius = UDim.new(1,0), Parent = sliderFill })

    valLbl.FocusLost:Connect(function()
        local v = tonumber(valLbl.Text)
        if v then
            v = math.clamp(v, minV, maxV)
            valLbl.Text = tostring(v)
            sliderFill.Size = UDim2.new((v-minV)/(maxV-minV), 0, 1, 0)
            if callback then callback(v) end
        else
            valLbl.Text = tostring(value)
        end
    end)

    local draggingSlider = false
    sliderBG.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if draggingSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((inp.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
            local newVal = math.floor(minV + rel * (maxV - minV))
            sliderFill.Size = UDim2.new(rel, 0, 1, 0)
            valLbl.Text = tostring(newVal)
            if callback then callback(newVal) end
        end
    end)
end

-- ══════════════════════════════════════════
--  LÓGICA: UNWALK
-- ══════════════════════════════════════════
local function enableUnwalk()
    local char = me.Character; if not char then return end
    local hum  = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local anim = hum:FindFirstChildOfClass("Animator"); if not anim then return end
    for _, t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop(0) end
    if unwalkConn then unwalkConn:Disconnect() end
    unwalkConn = RunService.Heartbeat:Connect(function()
        if not unwalkOn then unwalkConn:Disconnect(); unwalkConn = nil; return end
        local c = me.Character; if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid"); if not h then return end
        local an = h:FindFirstChildOfClass("Animator"); if not an then return end
        for _, t in ipairs(an:GetPlayingAnimationTracks()) do t:Stop(0) end
    end)
end
local function disableUnwalk()
    if unwalkConn then unwalkConn:Disconnect(); unwalkConn = nil end
end

-- ══════════════════════════════════════════
--  LÓGICA: XRAY
-- ══════════════════════════════════════════
local function startXray()
    pcall(function() Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9 end)
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Anchored then
                originalTransparency[obj] = obj.LocalTransparencyModifier
                obj.LocalTransparencyModifier = 0.85
            end
        end
    end)
    xrayDescConn = workspace.DescendantAdded:Connect(function(obj)
        if not xrayOn then return end
        pcall(function()
            if obj:IsA("BasePart") and obj.Anchored then
                originalTransparency[obj] = obj.LocalTransparencyModifier
                obj.LocalTransparencyModifier = 0.85
            end
        end)
    end)
end
local function stopXray()
    if xrayDescConn then xrayDescConn:Disconnect(); xrayDescConn = nil end
    if xrayCharConn then xrayCharConn:Disconnect(); xrayCharConn = nil end
    for obj, val in pairs(originalTransparency) do pcall(function() obj.LocalTransparencyModifier = val end) end
    originalTransparency = {}
end

-- ══════════════════════════════════════════
--  LÓGICA: ESP
-- ══════════════════════════════════════════
local ESP_COLOR = Color3.fromRGB(130, 180, 255)
local function createESP(plr)
    if plr == me then return end
    if not plr.Character then return end
    if plr.Character:FindFirstChild("DragonDemonESP") then return end
    local c = plr.Character
    local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local head = c:FindFirstChild("Head")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
    local hitbox = Instance.new("BoxHandleAdornment")
    hitbox.Name = "DragonDemonESP"; hitbox.Adornee = hrp
    hitbox.Size = Vector3.new(4,6,2); hitbox.Color3 = ESP_COLOR
    hitbox.Transparency = 0.3; hitbox.ZIndex = 10
    hitbox.AlwaysOnTop = true; hitbox.Parent = c
    espObjects[plr] = hitbox
    if head then
        local bb = Instance.new("BillboardGui")
        bb.Name = "DragonDemonESP_Name"; bb.Adornee = head
        bb.Size = UDim2.new(0,200,0,50); bb.StudsOffset = Vector3.new(0,3,0)
        bb.AlwaysOnTop = true; bb.Parent = c
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
        lbl.Text = plr.DisplayName or plr.Name; lbl.TextColor3 = ESP_COLOR
        lbl.Font = Enum.Font.GothamBold; lbl.TextScaled = true
        lbl.TextStrokeTransparency = 0.4; lbl.Parent = bb
    end
end
local function removeESP(plr)
    pcall(function()
        if plr.Character then
            local h = plr.Character:FindFirstChild("DragonDemonESP"); if h then h:Destroy() end
            local n = plr.Character:FindFirstChild("DragonDemonESP_Name"); if n then n:Destroy() end
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Automatic end
        end
        espObjects[plr] = nil
    end)
end
local function enableESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= me then
            if plr.Character then pcall(function() createESP(plr) end) end
            table.insert(espConnections, plr.CharacterAdded:Connect(function()
                task.wait(0.1); if espOn then pcall(function() createESP(plr) end) end
            end))
        end
    end
    table.insert(espConnections, Players.PlayerAdded:Connect(function(plr)
        if plr == me then return end
        table.insert(espConnections, plr.CharacterAdded:Connect(function()
            task.wait(0.1); if espOn then pcall(function() createESP(plr) end) end
        end))
    end))
end
local function disableESP()
    for _, plr in ipairs(Players:GetPlayers()) do pcall(function() removeESP(plr) end) end
    for _, conn in ipairs(espConnections) do if conn and conn.Connected then conn:Disconnect() end end
    espConnections = {}; espObjects = {}
end

-- ══════════════════════════════════════════
--  LÓGICA: ANTI RAGDOLL
-- ══════════════════════════════════════════
local function cacheCharacterData()
    local char = me.Character; if not char then return false end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end
    cachedCharData = { character = char, humanoid = hum, root = root }
    return true
end
local function disconnectAllRagdoll()
    for _, conn in ipairs(ragdollConnections) do pcall(function() conn:Disconnect() end) end
    ragdollConnections = {}
end
local function isRagdolled()
    if not cachedCharData.humanoid then return false end
    local state = cachedCharData.humanoid:GetState()
    return state == Enum.HumanoidStateType.Physics
        or state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.FallingDown
end
local function forceExitRagdoll()
    local hum  = cachedCharData.humanoid
    local root = cachedCharData.root
    if not hum or not root then return end
    if hum.Health > 0 then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end) end
    root.Anchored = false
    root.AssemblyLinearVelocity  = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end
local function antiRagdollLoop()
    while antiRagdollMode do
        task.wait()
        if not cachedCharData.humanoid then continue end
        if isRagdolled() then forceExitRagdoll() end
        local cam = workspace.CurrentCamera
        if cam and cachedCharData.humanoid and cam.CameraSubject ~= cachedCharData.humanoid then
            cam.CameraSubject = cachedCharData.humanoid
        end
    end
end
local function toggleAntiRagdoll(enable)
    if enable then
        disconnectAllRagdoll()
        if not cacheCharacterData() then return end
        antiRagdollMode = "v1"
        table.insert(ragdollConnections, me.CharacterAdded:Connect(function()
            task.wait(0.5); if antiRagdollMode then cacheCharacterData() end
        end))
        task.spawn(antiRagdollLoop)
    else
        antiRagdollMode = nil
        disconnectAllRagdoll()
        cachedCharData = {}
    end
end

-- ══════════════════════════════════════════
--  LÓGICA: INF JUMP
-- ══════════════════════════════════════════
UserInputService.JumpRequest:Connect(function()
    if not infJumpOn then return end
    local char = me.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50, hrp.AssemblyLinearVelocity.Z)
end)
RunService.Heartbeat:Connect(function()
    if not infJumpOn then return end
    local char = me.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    if hrp.AssemblyLinearVelocity.Y < -80 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -80, hrp.AssemblyLinearVelocity.Z)
    end
end)

-- ══════════════════════════════════════════
--  LÓGICA: GALAXY SKY
-- ══════════════════════════════════════════
local galaxySkyBright, galaxySkyBrightConn, galaxyBloom, galaxyCC
local galaxyPlanets = {}
local originalSkybox = nil

local function enableGalaxySky()
    originalSkybox = Lighting:FindFirstChildOfClass("Sky")
    if originalSkybox then originalSkybox.Parent = nil end
    galaxySkyBright = Instance.new("Sky")
    galaxySkyBright.SkyboxBk="rbxassetid://1534951537"; galaxySkyBright.SkyboxDn="rbxassetid://1534951537"
    galaxySkyBright.SkyboxFt="rbxassetid://1534951537"; galaxySkyBright.SkyboxLf="rbxassetid://1534951537"
    galaxySkyBright.SkyboxRt="rbxassetid://1534951537"; galaxySkyBright.SkyboxUp="rbxassetid://1534951537"
    galaxySkyBright.StarCount=10000; galaxySkyBright.CelestialBodiesShown=false; galaxySkyBright.Parent=Lighting
    galaxyBloom=Instance.new("BloomEffect"); galaxyBloom.Intensity=1.5; galaxyBloom.Size=40; galaxyBloom.Threshold=0.8; galaxyBloom.Parent=Lighting
    galaxyCC=Instance.new("ColorCorrectionEffect"); galaxyCC.Saturation=0.8; galaxyCC.Contrast=0.3; galaxyCC.TintColor=Color3.fromRGB(200,150,255); galaxyCC.Parent=Lighting
    Lighting.Ambient=Color3.fromRGB(120,60,180); Lighting.Brightness=3; Lighting.ClockTime=0
    galaxySkyBrightConn=RunService.Heartbeat:Connect(function()
        if not galaxySkyOn then return end
        local t=tick()*0.5
        Lighting.Ambient=Color3.fromRGB(120+math.sin(t)*60,50+math.sin(t*0.8)*40,180+math.sin(t*1.2)*50)
        if galaxyBloom then galaxyBloom.Intensity=1.2+math.sin(t*2)*0.4 end
    end)
end
local function disableGalaxySky()
    if galaxySkyBrightConn then galaxySkyBrightConn:Disconnect(); galaxySkyBrightConn=nil end
    if galaxySkyBright then galaxySkyBright:Destroy(); galaxySkyBright=nil end
    if originalSkybox then originalSkybox.Parent=Lighting end
    if galaxyBloom then galaxyBloom:Destroy(); galaxyBloom=nil end
    if galaxyCC then galaxyCC:Destroy(); galaxyCC=nil end
    for _, obj in ipairs(galaxyPlanets) do if obj then obj:Destroy() end end
    galaxyPlanets={}
    Lighting.Ambient=Color3.fromRGB(127,127,127); Lighting.Brightness=2; Lighting.ClockTime=14
end

-- ══════════════════════════════════════════
--  LÓGICA: BAT AIMBOT
-- ══════════════════════════════════════════
local function findBat()
    local c = me.Character; local bp = me:FindFirstChildOfClass("Backpack")
    if c then for _, ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    if bp then for _, ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    return nil
end
local function findNearestEnemy(myHRP)
    local nearest, nearestDist, nearestTorso = nil, math.huge, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= me and p.Character then
            local eh = p.Character:FindFirstChild("HumanoidRootPart")
            local tor = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if eh and hum and hum.Health > 0 then
                local d = (eh.Position - myHRP.Position).Magnitude
                if d < nearestDist then nearestDist = d; nearest = eh; nearestTorso = tor or eh end
            end
        end
    end
    return nearest, nearestDist, nearestTorso
end
local function startBatAimbot()
    if batAimbotConnection then return end
    batAimbotConnection = RunService.Heartbeat:Connect(function()
        if not batAimbotOn then return end
        local c = me.Character; if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        local bat = findBat()
        if bat and bat.Parent ~= c then hum:EquipTool(bat) end
        local _, _, torso = findNearestEnemy(h)
        if torso then
            local dir = (torso.Position - h.Position)
            local flatDir = Vector3.new(dir.X, 0, dir.Z)
            if flatDir.Magnitude > 1.5 then
                local mv = flatDir.Unit
                h.AssemblyLinearVelocity = Vector3.new(mv.X*55, h.AssemblyLinearVelocity.Y, mv.Z*55)
            end
        end
    end)
end
local function stopBatAimbot()
    if batAimbotConnection then batAimbotConnection:Disconnect(); batAimbotConnection = nil end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then
        batAimbotOn = not batAimbotOn
        if batAimbotOn then startBatAimbot() else stopBatAimbot() end
    end
end)

-- ══════════════════════════════════════════
--  LÓGICA: AUTO ROUTE
-- ══════════════════════════════════════════
local function faceSouth()
    local c = me.Character; if not c then return end
    local rp = c:FindFirstChild("HumanoidRootPart")
    if rp then rp.CFrame = CFrame.new(rp.Position) * CFrame.Angles(0, math.rad(180), 0) end
end
local function faceNorth()
    local c = me.Character; if not c then return end
    local rp = c:FindFirstChild("HumanoidRootPart")
    if rp then rp.CFrame = CFrame.new(rp.Position) * CFrame.Angles(0, 0, 0) end
end

local _routeBtnL, _routeBtnR = nil, nil
local currentRouteSide = nil

local function startAutoLeft()
    if autoLeftConnection then autoLeftConnection:Disconnect() end
    autoLeftPhase = 1; AutoLeftEnabled = true; currentRouteSide = "L"
    autoLeftConnection = RunService.Heartbeat:Connect(function()
        if not AutoLeftEnabled then return end
        local c = me.Character; if not c then return end
        local rp = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not rp or not hum then return end
        local spd = NORMAL_SPEED_ROUTE
        if autoLeftPhase == 1 then
            local tgt = Vector3.new(POS_L1.X, rp.Position.Y, POS_L1.Z)
            if (tgt - rp.Position).Magnitude < 1 then
                autoLeftPhase = 2
                local d = (POS_L2 - rp.Position); local mv = Vector3.new(d.X,0,d.Z).Unit
                hum:Move(mv,false); rp.AssemblyLinearVelocity = Vector3.new(mv.X*spd, rp.AssemblyLinearVelocity.Y, mv.Z*spd); return
            end
            local d = (POS_L1 - rp.Position); local mv = Vector3.new(d.X,0,d.Z).Unit
            hum:Move(mv,false); rp.AssemblyLinearVelocity = Vector3.new(mv.X*spd, rp.AssemblyLinearVelocity.Y, mv.Z*spd)
        elseif autoLeftPhase == 2 then
            local tgt = Vector3.new(POS_L2.X, rp.Position.Y, POS_L2.Z)
            if (tgt - rp.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false); rp.AssemblyLinearVelocity = Vector3.zero
                AutoLeftEnabled = false; currentRouteSide = nil
                if autoLeftConnection then autoLeftConnection:Disconnect(); autoLeftConnection = nil end
                autoLeftPhase = 1
                if _routeBtnL then Tween(_routeBtnL, {BackgroundColor3=Color3.fromRGB(35,35,35), TextColor3=Color3.fromRGB(210,210,210)}) end
                faceSouth(); return
            end
            local d = (POS_L2 - rp.Position); local mv = Vector3.new(d.X,0,d.Z).Unit
            hum:Move(mv,false); rp.AssemblyLinearVelocity = Vector3.new(mv.X*spd, rp.AssemblyLinearVelocity.Y, mv.Z*spd)
        end
    end)
end
local function stopAutoLeft()
    AutoLeftEnabled = false
    if autoLeftConnection then autoLeftConnection:Disconnect(); autoLeftConnection = nil end
    autoLeftPhase = 1
    local c = me.Character
    if c then local hum = c:FindFirstChildOfClass("Humanoid"); if hum then hum:Move(Vector3.zero, false) end end
end
local function startAutoRight()
    if autoRightConnection then autoRightConnection:Disconnect() end
    autoRightPhase = 1; AutoRightEnabled = true; currentRouteSide = "R"
    autoRightConnection = RunService.Heartbeat:Connect(function()
        if not AutoRightEnabled then return end
        local c = me.Character; if not c then return end
        local rp = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not rp or not hum then return end
        local spd = NORMAL_SPEED_ROUTE
        if autoRightPhase == 1 then
            local tgt = Vector3.new(POS_R1.X, rp.Position.Y, POS_R1.Z)
            if (tgt - rp.Position).Magnitude < 1 then
                autoRightPhase = 2
                local d = (POS_R2 - rp.Position); local mv = Vector3.new(d.X,0,d.Z).Unit
                hum:Move(mv,false); rp.AssemblyLinearVelocity = Vector3.new(mv.X*spd, rp.AssemblyLinearVelocity.Y, mv.Z*spd); return
            end
            local d = (POS_R1 - rp.Position); local mv = Vector3.new(d.X,0,d.Z).Unit
            hum:Move(mv,false); rp.AssemblyLinearVelocity = Vector3.new(mv.X*spd, rp.AssemblyLinearVelocity.Y, mv.Z*spd)
        elseif autoRightPhase == 2 then
            local tgt = Vector3.new(POS_R2.X, rp.Position.Y, POS_R2.Z)
            if (tgt - rp.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false); rp.AssemblyLinearVelocity = Vector3.zero
                AutoRightEnabled = false; currentRouteSide = nil
                if autoRightConnection then autoRightConnection:Disconnect(); autoRightConnection = nil end
                autoRightPhase = 1
                if _routeBtnR then Tween(_routeBtnR, {BackgroundColor3=Color3.fromRGB(35,35,35), TextColor3=Color3.fromRGB(210,210,210)}) end
                faceNorth(); return
            end
            local d = (POS_R2 - rp.Position); local mv = Vector3.new(d.X,0,d.Z).Unit
            hum:Move(mv,false); rp.AssemblyLinearVelocity = Vector3.new(mv.X*spd, rp.AssemblyLinearVelocity.Y, mv.Z*spd)
        end
    end)
end
local function stopAutoRight()
    AutoRightEnabled = false
    if autoRightConnection then autoRightConnection:Disconnect(); autoRightConnection = nil end
    autoRightPhase = 1
    local c = me.Character
    if c then local hum = c:FindFirstChildOfClass("Humanoid"); if hum then hum:Move(Vector3.zero, false) end end
end
local function stopRoute()
    stopAutoLeft(); stopAutoRight(); currentRouteSide = nil
end

-- ══════════════════════════════════════════
--  LÓGICA: AUTO STEAL
-- ══════════════════════════════════════════
local autoStealStealConnection = nil
local autoStealAnimalsCache    = {}
local autoStealPromptCache     = {}
local autoStealInternalCache   = {}
local autoStealIsStealing      = false
local autoStealScannerStarted  = false
local animalsDataAS            = {}
pcall(function()
    animalsDataAS = require(ReplicatedStorage:WaitForChild("Datas",5):WaitForChild("Animals",5))
end)

local stealCircle = nil
local circleConn  = nil

local function hideStealCircle()
    if stealCircle then stealCircle:Destroy(); stealCircle = nil end
    if circleConn  then circleConn:Disconnect(); circleConn = nil end
end
local function showStealCircle()
    if stealCircle then stealCircle:Destroy() end
    stealCircle = Instance.new("Part")
    stealCircle.Name = "StealCircle"; stealCircle.Anchored = true
    stealCircle.CanCollide = false; stealCircle.Transparency = 0.7
    stealCircle.Material = Enum.Material.Neon; stealCircle.Color = Color3.fromRGB(200,200,200)
    stealCircle.Shape = Enum.PartType.Cylinder
    stealCircle.Size = Vector3.new(0.05, AUTO_STEAL_PROX_RADIUS*2, AUTO_STEAL_PROX_RADIUS*2)
    stealCircle.Parent = workspace
    if circleConn then circleConn:Disconnect() end
    circleConn = RunService.Heartbeat:Connect(function()
        if not autoStealActive then hideStealCircle(); return end
        if stealCircle and me.Character then
            local root = me.Character:FindFirstChild("HumanoidRootPart")
            if root then
                stealCircle.CFrame = CFrame.new(root.Position + Vector3.new(0,-2.5,0)) * CFrame.Angles(0,0,math.rad(90))
                stealCircle.Size = Vector3.new(0.05, AUTO_STEAL_PROX_RADIUS*2, AUTO_STEAL_PROX_RADIUS*2)
            end
        end
    end)
end

local function autoSteal_isMyBase(plotName)
    local plots = workspace:FindFirstChild("Plots")
    local plot = plots and plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then return yb.Enabled == true end
    end
    return false
end
local function autoSteal_scanPlot(plot)
    if not plot or not plot:IsA("Model") then return end
    if autoSteal_isMyBase(plot.Name) then return end
    local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return end
    for _, podium in ipairs(podiums:GetChildren()) do
        if podium:IsA("Model") and podium:FindFirstChild("Base") then
            local animalName = "Unknown"
            local spawn = podium.Base:FindFirstChild("Spawn")
            if spawn then
                for _, child in ipairs(spawn:GetChildren()) do
                    if child:IsA("Model") and child.Name ~= "PromptAttachment" then
                        animalName = child.Name
                        local info = animalsDataAS[animalName]
                        if info and info.DisplayName then animalName = info.DisplayName end
                        break
                    end
                end
            end
            table.insert(autoStealAnimalsCache, {
                name = animalName, plot = plot.Name, slot = podium.Name,
                worldPosition = podium:GetPivot().Position,
                uid = plot.Name.."_"..podium.Name,
            })
        end
    end
end
local function autoSteal_initScanner()
    if autoStealScannerStarted then return end
    autoStealScannerStarted = true
    task.spawn(function()
        task.wait(2)
        local plots = workspace:WaitForChild("Plots", 10); if not plots then return end
        for _, plot in ipairs(plots:GetChildren()) do
            if plot:IsA("Model") then autoSteal_scanPlot(plot) end
        end
        plots.ChildAdded:Connect(function(plot)
            if plot:IsA("Model") then task.wait(0.5); autoSteal_scanPlot(plot) end
        end)
        task.spawn(function()
            while task.wait(5) do
                autoStealAnimalsCache = {}
                for _, plot in ipairs(plots:GetChildren()) do
                    if plot:IsA("Model") then autoSteal_scanPlot(plot) end
                end
            end
        end)
    end)
end
local function autoSteal_findPrompt(animalData)
    if not animalData then return nil end
    local cached = autoStealPromptCache[animalData.uid]
    if cached and cached.Parent then return cached end
    local plots = workspace:FindFirstChild("Plots")
    local plot = plots and plots:FindFirstChild(animalData.plot); if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return nil end
    local podium  = podiums:FindFirstChild(animalData.slot); if not podium then return nil end
    local base    = podium:FindFirstChild("Base"); if not base then return nil end
    local spawn   = base:FindFirstChild("Spawn"); if not spawn then return nil end
    local attach  = spawn:FindFirstChild("PromptAttachment"); if not attach then return nil end
    for _, p in ipairs(attach:GetChildren()) do
        if p:IsA("ProximityPrompt") then autoStealPromptCache[animalData.uid] = p; return p end
    end
    return nil
end
local function autoSteal_buildCallbacks(prompt)
    if autoStealInternalCache[prompt] then return end
    local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
    local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(conns1) == "table" then
        for _, conn in ipairs(conns1) do if type(conn.Function) == "function" then table.insert(data.holdCallbacks, conn.Function) end end
    end
    local ok2, conns2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(conns2) == "table" then
        for _, conn in ipairs(conns2) do if type(conn.Function) == "function" then table.insert(data.triggerCallbacks, conn.Function) end end
    end
    if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then autoStealInternalCache[prompt] = data end
end
local function autoSteal_execute(prompt)
    local data = autoStealInternalCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false; autoStealIsStealing = true
    task.spawn(function()
        for _, fn in ipairs(data.holdCallbacks)   do task.spawn(fn) end
        task.wait(0.2)
        for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
        task.wait(0.01); data.ready = true; task.wait(0.01); autoStealIsStealing = false
    end)
    return true
end
local function autoSteal_getNearest()
    local char = me.Character; if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"); if not hrp then return nil end
    local nearest, minDist = nil, math.huge
    for _, animalData in ipairs(autoStealAnimalsCache) do
        if not autoSteal_isMyBase(animalData.plot) and animalData.worldPosition then
            local dist = (hrp.Position - animalData.worldPosition).Magnitude
            if dist < minDist then minDist = dist; nearest = animalData end
        end
    end
    return nearest
end
local function startAutoStealLoop()
    if autoStealStealConnection then autoStealStealConnection:Disconnect() end
    autoStealStealConnection = RunService.Heartbeat:Connect(function()
        if not autoStealActive or autoStealIsStealing then return end
        local target = autoSteal_getNearest(); if not target or not target.worldPosition then return end
        local char = me.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"); if not hrp then return end
        if (hrp.Position - target.worldPosition).Magnitude > AUTO_STEAL_PROX_RADIUS then return end
        local prompt = autoStealPromptCache[target.uid]
        if not prompt or not prompt.Parent then prompt = autoSteal_findPrompt(target) end
        if prompt then autoSteal_buildCallbacks(prompt); autoSteal_execute(prompt) end
    end)
end
local function stopAutoStealLoop()
    if autoStealStealConnection then autoStealStealConnection:Disconnect(); autoStealStealConnection = nil end
    autoStealIsStealing = false
end
local function enableAutoSteal()
    autoStealActive = true; autoSteal_initScanner(); startAutoStealLoop(); showStealCircle()
end
local function disableAutoSteal()
    autoStealActive = false; stopAutoStealLoop(); hideStealCircle()
end

-- ══════════════════════════════════════════
--  SPEED ENGINE
-- ══════════════════════════════════════════
local speedBV = nil
local function removeSpeedBV()
    if speedBV and speedBV.Parent then speedBV:Destroy() end
    speedBV = nil
end
local function getSpeedBV()
    local char = me.Character; if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return nil end
    local existing = root:FindFirstChild("DragonDemonSpeedBV")
    if existing then return existing end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "DragonDemonSpeedBV"; bv.MaxForce = Vector3.new(1e5,0,1e5)
    bv.Velocity = Vector3.zero; bv.P = 1e4; bv.Parent = root
    speedBV = bv; return bv
end
RunService.Heartbeat:Connect(function()
    if not speedOn then removeSpeedBV(); return end
    local char = me.Character; if not char then removeSpeedBV(); return end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then removeSpeedBV(); return end
    if hum.Health <= 0 then removeSpeedBV(); return end
    local moveDir = hum.MoveDirection
    local spd = speedNoStealValue
    local bv = getSpeedBV(); if not bv then return end
    bv.Velocity = moveDir.Magnitude > 0.1 and moveDir * spd or Vector3.zero
end)
me.CharacterAdded:Connect(function() speedBV = nil end)

-- ══════════════════════════════════════════
--         SPEED BILLBOARD
-- ══════════════════════════════════════════
local speedBB = nil
local function makeSpeedBB()
    local c = me.Character; if not c then return end
    local head = c:FindFirstChild("Head"); if not head then return end
    if speedBB then pcall(function() speedBB:Destroy() end) end
    speedBB = Instance.new("BillboardGui")
    speedBB.Name = "DragonDemonSpeedBB"; speedBB.Adornee = head
    speedBB.Size = UDim2.new(0,160,0,36); speedBB.StudsOffset = Vector3.new(0,3.2,0)
    speedBB.AlwaysOnTop = true; speedBB.Parent = head
    local lbl = Instance.new("TextLabel")
    lbl.Name = "SpeedLbl"; lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0); lbl.TextStrokeTransparency = 0.3
    lbl.Font = Enum.Font.GothamBold; lbl.TextScaled = true; lbl.Text = "Speed: 0"
    lbl.Parent = speedBB
end
makeSpeedBB()
me.CharacterAdded:Connect(function(newChar)
    task.wait(0.15); makeSpeedBB()
end)
RunService.RenderStepped:Connect(function()
    if not speedBB or not speedBB.Parent then return end
    local c = me.Character; if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local lbl = speedBB:FindFirstChild("SpeedLbl"); if not lbl then return end
    local v = hrp.AssemblyLinearVelocity
    lbl.Text = "Speed: "..math.floor(Vector3.new(v.X,0,v.Z).Magnitude)
end)

-- ══════════════════════════════════════════
--         FOV UPDATE
-- ══════════════════════════════════════════
local function applyFOV(v)
    fovValue = v
    Camera.FieldOfView = v
end

-- ══════════════════════════════════════════
--         DARK MODE (siempre activo)
-- ══════════════════════════════════════════

-- ══════════════════════════════════════════
--    ████  BUILDING TABS CONTENT  ████
-- ══════════════════════════════════════════

-- ─── TAB: COMBAT ─────────────────────────
local CombatTab = Tabs["Combat"]
SectionLabel(CombatTab, "COMBAT", 4)
CreateToggle(CombatTab, "Bat Aimbot  [E]", 24, false, function(v)
    batAimbotOn = v
    if v then startBatAimbot() else stopBatAimbot() end
end)
CreateToggle(CombatTab, "Anti Ragdoll", 68, false, function(v)
    antiRagdollOn = v; toggleAntiRagdoll(v)
end)
CreateToggle(CombatTab, "Infinite Jump", 112, false, function(v)
    infJumpOn = v
end)
CreateToggle(CombatTab, "Unwalk", 156, false, function(v)
    unwalkOn = v
    if v then enableUnwalk() else disableUnwalk() end
end)

-- ─── TAB: MOVEMENT ───────────────────────
local MovTab = Tabs["Movement"]
SectionLabel(MovTab, "MOVEMENT", 4)
CreateToggle(MovTab, "Low Gravity", 24, false, function(v)
    workspace.Gravity = v and 30 or 196.2
end)
CreateToggle(MovTab, "No Clip", 68, false, function(v)
    if v then
        RunService.Stepped:Connect(function()
            local c = me.Character; if not c then return end
            for _, p in pairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end
end)

SectionLabel(MovTab, "AUTO ROUTE", 116)
local function MakeRouteBtn(label, xScale, side)
    local btn = Make("TextButton", {
        Text             = label,
        Size             = UDim2.new(0.46, 0, 0, 32),
        Position         = UDim2.new(xScale, 0, 0, 136),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        TextColor3       = Color3.fromRGB(210, 210, 210),
        Font             = Enum.Font.GothamBold,
        TextSize         = 10,
        BorderSizePixel  = 0,
        Parent           = MovTab,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 7), Parent = btn })
    if side == "L" then _routeBtnL = btn else _routeBtnR = btn end
    btn.MouseButton1Click:Connect(function()
        if currentRouteSide == side then
            stopRoute()
            Tween(btn, {BackgroundColor3=Color3.fromRGB(35,35,35), TextColor3=Color3.fromRGB(210,210,210)})
        else
            stopRoute()
            if _routeBtnL then Tween(_routeBtnL, {BackgroundColor3=Color3.fromRGB(35,35,35), TextColor3=Color3.fromRGB(210,210,210)}) end
            if _routeBtnR then Tween(_routeBtnR, {BackgroundColor3=Color3.fromRGB(35,35,35), TextColor3=Color3.fromRGB(210,210,210)}) end
            task.wait(0.05)
            Tween(btn, {BackgroundColor3=Color3.fromRGB(220,220,220), TextColor3=Color3.fromRGB(10,10,10)})
            if side == "L" then startAutoLeft() else startAutoRight() end
        end
    end)
    return btn
end
MakeRouteBtn("ROUTE LEFT ←", 0.02, "L")
MakeRouteBtn("ROUTE RIGHT →", 0.52, "R")

local stopRouteBtn = Make("TextButton", {
    Text             = "■  STOP",
    Size             = UDim2.new(0.96, 0, 0, 26),
    Position         = UDim2.new(0.02, 0, 0, 176),
    BackgroundColor3 = Color3.fromRGB(45, 20, 20),
    TextColor3       = Color3.fromRGB(220, 100, 100),
    Font             = Enum.Font.GothamBold,
    TextSize         = 10,
    BorderSizePixel  = 0,
    Parent           = MovTab,
})
Make("UICorner", { CornerRadius = UDim.new(0, 7), Parent = stopRouteBtn })
stopRouteBtn.MouseButton1Click:Connect(stopRoute)

-- ─── TAB: VISUAL ─────────────────────────
local VisTab = Tabs["Visual"]
SectionLabel(VisTab, "VISUAL", 4)
CreateToggle(VisTab, "ESP", 24, false, function(v)
    espOn = v; if v then enableESP() else disableESP() end
end)
CreateToggle(VisTab, "X-Ray", 68, false, function(v)
    xrayOn = v; if v then startXray() else stopXray() end
end)
CreateToggle(VisTab, "Galaxy Sky", 112, false, function(v)
    galaxySkyOn = v; if v then enableGalaxySky() else disableGalaxySky() end
end)

SectionLabel(VisTab, "FIELD OF VIEW", 158)
CreateSlider(VisTab, "FOV", 178, fovValue, FOV_MIN, FOV_MAX, function(v)
    applyFOV(v)
end)

-- ─── TAB: AUTO ───────────────────────────
local AutoTab = Tabs["Auto"]
SectionLabel(AutoTab, "AUTO FEATURES", 4)
CreateToggle(AutoTab, "Auto Steal", 24, false, function(v)
    if v then enableAutoSteal() else disableAutoSteal() end
end)
SectionLabel(AutoTab, "STEAL RADIUS", 70)
CreateSlider(AutoTab, "Radius (studs)", 90, AUTO_STEAL_PROX_RADIUS, 1, 50, function(v)
    AUTO_STEAL_PROX_RADIUS = v
    if stealCircle then stealCircle.Size = Vector3.new(0.05, v*2, v*2) end
end)

-- ─── TAB: SPEED ──────────────────────────
local SpdTab = Tabs["Speed"]
SectionLabel(SpdTab, "SPEED CONFIGURATION", 4)
CreateToggle(SpdTab, "Speed Enabled", 24, false, function(v)
    speedOn = v
    if not v then removeSpeedBV() end
end)
CreateSlider(SpdTab, "Normal Speed", 68, speedNoStealValue, 15, 200, function(v)
    speedNoStealValue = v
end)
CreateSlider(SpdTab, "Carry/Steal Speed", 124, speedStealValue, 15, 200, function(v)
    speedStealValue = v
end)

SectionLabel(SpdTab, "SPEED DISPLAY", 180)
CreateToggle(SpdTab, "Show Speed HUD", 200, true, function(v)
    if speedBB then speedBB.Enabled = v end
end)

-- ─── TAB: SETTINGS ───────────────────────
local SetTab = Tabs["Settings"]
SectionLabel(SetTab, "SETTINGS", 4)

local saveBtn = Make("TextButton", {
    Text             = "💾  SAVE CONFIG",
    Size             = UDim2.new(0.96, 0, 0, 34),
    Position         = UDim2.new(0.02, 0, 0, 24),
    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
    TextColor3       = Color3.fromRGB(210, 210, 210),
    Font             = Enum.Font.GothamBold,
    TextSize         = 11,
    BorderSizePixel  = 0,
    Parent           = SetTab,
})
Make("UICorner", { CornerRadius = UDim.new(0, 7), Parent = saveBtn })
saveBtn.MouseButton1Click:Connect(function()
    saveConfig()
    saveBtn.Text = "✓  SAVED!"
    task.delay(1.5, function() saveBtn.Text = "💾  SAVE CONFIG" end)
end)

Make("TextLabel", {
    Text = "DRAG the hub from the top bar",
    Size = UDim2.new(1, -10, 0, 20),
    Position = UDim2.new(0, 5, 0, 70),
    BackgroundTransparency = 1,
    TextColor3 = Color3.fromRGB(70, 70, 70),
    Font = Enum.Font.Gotham,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Center,
    Parent = SetTab,
})

-- ══════════════════════════════════════════
--    DEFAULT TAB + OPEN ANIMATION
-- ══════════════════════════════════════════
SelectTab("Combat")
MainFrame.Size = UDim2.new(0, 340, 0, 0)
Tween(MainFrame, { Size = UDim2.new(0, 340, 0, 480) }, 0.25)

-- ══════════════════════════════════════════
--    AUTO-LOAD CONFIG GUARDADO
-- ══════════════════════════════════════════
task.defer(function()
    if savedCfg.FOV then applyFOV(math.clamp(savedCfg.FOV, FOV_MIN, FOV_MAX)) end
    if savedCfg.StealRadius then AUTO_STEAL_PROX_RADIUS = math.clamp(savedCfg.StealRadius, 1, 999) end
    if savedCfg.SpeedNormal then speedNoStealValue = savedCfg.SpeedNormal end
    if savedCfg.SpeedSteal  then speedStealValue   = savedCfg.SpeedSteal  end
    if savedCfg.GalaxySky   then galaxySkyOn = true; enableGalaxySky() end
    if savedCfg.AutoSteal   then enableAutoSteal() end
end)

print("[DRAGON×DEMON HUB] Loaded!")
