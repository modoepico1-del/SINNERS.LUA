local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local Camera    = workspace.CurrentCamera

-- ─── AUTO STEAL ────────────────────────────────────────────────
local AUTO_STEAL_ENABLED = false

local AnimalsData = nil
pcall(function()
    AnimalsData = require(ReplicatedStorage:WaitForChild("Datas"):WaitForChild("Animals"))
end)

local allAnimalsCache   = {}
local PromptMemoryCache = {}
local InternalStealCache = {}
local LastTargetUID     = nil
local LastPlayerPosition = nil
local PlayerVelocity    = Vector3.zero

local AUTO_STEAL_PROX_RADIUS = 20
local IsStealing        = false
local StealProgress     = 0
local CurrentStealTarget = nil

local stealConnection   = nil
local velocityConnection = nil

local function getHRP()
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
end

local function isMyBase(plotName)
    local plot = workspace.Plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yourBase = sign:FindFirstChild("YourBase")
        if yourBase and yourBase:IsA("BillboardGui") then
            return yourBase.Enabled == true
        end
    end
    return false
end

local function scanSinglePlot(plot)
    if not plot or not plot:IsA("Model") then return end
    if isMyBase(plot.Name) then return end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return end
    for _, podium in ipairs(podiums:GetChildren()) do
        if podium:IsA("Model") and podium:FindFirstChild("Base") then
            local animalName = "Unknown"
            local spawn = podium.Base:FindFirstChild("Spawn")
            if spawn then
                for _, child in ipairs(spawn:GetChildren()) do
                    if child:IsA("Model") and child.Name ~= "PromptAttachment" then
                        animalName = child.Name
                        if AnimalsData then
                            local animalInfo = AnimalsData[animalName]
                            if animalInfo and animalInfo.DisplayName then
                                animalName = animalInfo.DisplayName
                            end
                        end
                        break
                    end
                end
            end
            table.insert(allAnimalsCache, {
                name = animalName,
                plot = plot.Name,
                slot = podium.Name,
                worldPosition = podium:GetPivot().Position,
                uid = plot.Name .. "_" .. podium.Name,
            })
        end
    end
end

local function initializeScanner()
    task.spawn(function()
        task.wait(2)
        local plots = workspace:WaitForChild("Plots", 10)
        if not plots then return end
        for _, plot in ipairs(plots:GetChildren()) do
            if plot:IsA("Model") then scanSinglePlot(plot) end
        end
        plots.ChildAdded:Connect(function(plot)
            if plot:IsA("Model") then task.wait(0.5); scanSinglePlot(plot) end
        end)
        task.spawn(function()
            while task.wait(5) do
                allAnimalsCache = {}
                for _, plot in ipairs(plots:GetChildren()) do
                    if plot:IsA("Model") then scanSinglePlot(plot) end
                end
            end
        end)
    end)
end

local function findProximityPromptForAnimal(animalData)
    if not animalData then return nil end
    local cachedPrompt = PromptMemoryCache[animalData.uid]
    if cachedPrompt and cachedPrompt.Parent then return cachedPrompt end
    local plot = workspace.Plots:FindFirstChild(animalData.plot)
    if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return nil end
    local podium = podiums:FindFirstChild(animalData.slot)
    if not podium then return nil end
    local base = podium:FindFirstChild("Base")
    if not base then return nil end
    local spawn = base:FindFirstChild("Spawn")
    if not spawn then return nil end
    local attach = spawn:FindFirstChild("PromptAttachment")
    if not attach then return nil end
    for _, p in ipairs(attach:GetChildren()) do
        if p:IsA("ProximityPrompt") then
            PromptMemoryCache[animalData.uid] = p
            return p
        end
    end
    return nil
end

local function shouldSteal(animalData)
    if not animalData or not animalData.worldPosition then return false end
    local hrp = getHRP()
    if not hrp then return false end
    return (hrp.Position - animalData.worldPosition).Magnitude <= AUTO_STEAL_PROX_RADIUS
end

local function buildStealCallbacks(prompt)
    if InternalStealCache[prompt] then return end
    local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
    local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(conns1) == "table" then
        for _, conn in ipairs(conns1) do
            if type(conn.Function) == "function" then table.insert(data.holdCallbacks, conn.Function) end
        end
    end
    local ok2, conns2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(conns2) == "table" then
        for _, conn in ipairs(conns2) do
            if type(conn.Function) == "function" then table.insert(data.triggerCallbacks, conn.Function) end
        end
    end
    if (#data.holdCallbacks > 0) or (#data.triggerCallbacks > 0) then
        InternalStealCache[prompt] = data
    end
end

local function executeInternalStealAsync(prompt, animalData)
    local data = InternalStealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    IsStealing = true
    StealProgress = 0
    CurrentStealTarget = animalData
    task.spawn(function()
        if #data.holdCallbacks > 0 then
            for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
        end
        local startTime = tick()
        while tick() - startTime < 1.3 do
            StealProgress = (tick() - startTime) / 1.3
            task.wait(0.05)
        end
        StealProgress = 1
        if #data.triggerCallbacks > 0 then
            for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
        end
        task.wait(0.1)
        data.ready = true
        task.wait(0.3)
        IsStealing = false
        StealProgress = 0
        CurrentStealTarget = nil
    end)
    return true
end

local function attemptSteal(prompt, animalData)
    if not prompt or not prompt.Parent then return false end
    buildStealCallbacks(prompt)
    if not InternalStealCache[prompt] then return false end
    return executeInternalStealAsync(prompt, animalData)
end

local function getNearestAnimal()
    local hrp = getHRP()
    if not hrp then return nil end
    local nearest, minDist = nil, math.huge
    for _, animalData in ipairs(allAnimalsCache) do
        if not isMyBase(animalData.plot) and animalData.worldPosition then
            local dist = (hrp.Position - animalData.worldPosition).Magnitude
            if dist < minDist then minDist = dist; nearest = animalData end
        end
    end
    return nearest
end

local function startAutoSteal()
    if stealConnection then stealConnection:Disconnect() end
    stealConnection = RunService.Heartbeat:Connect(function()
        if not AUTO_STEAL_ENABLED then return end
        if IsStealing then return end
        local targetAnimal = getNearestAnimal()
        if not targetAnimal then return end
        if not shouldSteal(targetAnimal) then return end
        if LastTargetUID ~= targetAnimal.uid then LastTargetUID = targetAnimal.uid end
        local prompt = PromptMemoryCache[targetAnimal.uid]
        if not prompt or not prompt.Parent then
            prompt = findProximityPromptForAnimal(targetAnimal)
        end
        if prompt then attemptSteal(prompt, targetAnimal) end
    end)
end

local function stopAutoSteal()
    AUTO_STEAL_ENABLED = false
    if stealConnection then stealConnection:Disconnect(); stealConnection = nil end
end

initializeScanner()
startAutoSteal()

-- ─── HITBOX ────────────────────────────────────────────────────
_G.HeadSize = 8
local SIDE_TEXT     = "SINNERS"
local hitboxEnabled = false
local hitboxCurrentTarget = nil
local FACES = {
    Enum.NormalId.Front, Enum.NormalId.Back,
    Enum.NormalId.Left,  Enum.NormalId.Right,
    Enum.NormalId.Top,   Enum.NormalId.Bottom
}

local function applyHitbox(plr)
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, c in ipairs(hrp:GetChildren()) do
        if c:IsA("SurfaceGui") then c:Destroy() end
    end
    for _, face in ipairs(FACES) do
        local sg = Instance.new("SurfaceGui")
        sg.Face           = face
        sg.Adornee        = hrp
        sg.AlwaysOnTop    = true
        sg.SizingMode     = Enum.SurfaceGuiSizingMode.PixelsPerStud
        sg.CanvasSize     = Vector2.new(100, 100)
        sg.Parent         = hrp
        local txt = Instance.new("TextLabel")
        txt.Size                  = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.Text                  = SIDE_TEXT
        txt.TextColor3            = Color3.fromRGB(180, 0, 255)
        txt.TextScaled            = true
        txt.Font                  = Enum.Font.GothamBold
        txt.Parent                = sg
    end
end

local function clearHitbox(plr)
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, c in ipairs(hrp:GetChildren()) do
        if c:IsA("SurfaceGui") then c:Destroy() end
    end
    -- restaurar tamaño original
    pcall(function() hrp.Size = Vector3.new(2, 2, 1) end)
end

local function getNearestPlayer()
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local nearest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
            if dist < minDist then minDist = dist; nearest = plr end
        end
    end
    return nearest
end

RunService.RenderStepped:Connect(function()
    if not hitboxEnabled then
        if hitboxCurrentTarget then
            clearHitbox(hitboxCurrentTarget)
            hitboxCurrentTarget = nil
        end
        return
    end
    local target = getNearestPlayer()
    if target ~= hitboxCurrentTarget then
        if hitboxCurrentTarget then clearHitbox(hitboxCurrentTarget) end
        hitboxCurrentTarget = target
        if hitboxCurrentTarget then applyHitbox(hitboxCurrentTarget) end
    end
    if hitboxCurrentTarget and hitboxCurrentTarget.Character then
        local hrp = hitboxCurrentTarget.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Size        = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
            hrp.Transparency = 0.7
            hrp.BrickColor  = BrickColor.new("Black")
            hrp.Material    = Enum.Material.Neon
            hrp.CanCollide  = false
        end
    end
end)

-- ─── SAVE / LOAD ───────────────────────────────────────────────
local CONFIG_FILE = "KMoneyHub_config.json"

local function saveConfig()
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode({
            AutoSteal = AUTO_STEAL_ENABLED,
            Hitbox    = hitboxEnabled,
        }))
    end)
end

local savedCfg = {}
pcall(function() savedCfg = HttpService:JSONDecode(readfile(CONFIG_FILE)) end)

-- ─── PALETA ────────────────────────────────────────────────────
local WHITE       = Color3.fromRGB(255, 255, 255)
local BLACK       = Color3.fromRGB(0, 0, 0)
local FULL_HEIGHT = 270

-- ─── GUI ───────────────────────────────────────────────────────
if CoreGui:FindFirstChild("KMoneyHub") then
    CoreGui:FindFirstChild("KMoneyHub"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "KMoneyHub"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder   = 999
pcall(function() ScreenGui.Parent = CoreGui end)

local Main = Instance.new("Frame", ScreenGui)
Main.Name                   = "Main"
Main.Size                   = UDim2.new(0, 270, 0, FULL_HEIGHT)
Main.Position               = UDim2.new(0.5, -135, 0.5, -105)
Main.BackgroundTransparency = 1
Main.BorderSizePixel        = 0
Main.ClipsDescendants       = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local grimStroke = Instance.new("UIStroke", Main)
grimStroke.Color        = BLACK
grimStroke.Thickness    = 2
grimStroke.Transparency = 0

local TopLine = Instance.new("Frame", Main)
TopLine.Size             = UDim2.new(1, 0, 0, 2)
TopLine.BackgroundColor3 = BLACK
TopLine.BorderSizePixel  = 0

local TitleBar = Instance.new("Frame", Main)
TitleBar.Size               = UDim2.new(1, 0, 0, 48)
TitleBar.Position           = UDim2.new(0, 0, 0, 2)
TitleBar.BackgroundTransparency = 1
TitleBar.BorderSizePixel    = 0

local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size                   = UDim2.new(1, -46, 1, 0)
TitleLbl.Position               = UDim2.new(0, 14, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text                   = "KMONEY HUB"
TitleLbl.TextColor3             = WHITE
TitleLbl.TextStrokeColor3       = BLACK
TitleLbl.TextStrokeTransparency = 0
TitleLbl.Font                   = Enum.Font.GothamBlack
TitleLbl.TextSize               = 16
TitleLbl.TextXAlignment         = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size               = UDim2.new(0, 26, 0, 26)
MinBtn.Position           = UDim2.new(1, -36, 0.5, -13)
MinBtn.BackgroundTransparency = 1
MinBtn.Text               = "—"
MinBtn.TextColor3         = WHITE
MinBtn.Font               = Enum.Font.GothamBold
MinBtn.TextSize           = 13
MinBtn.BorderSizePixel    = 0
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)
local minStroke = Instance.new("UIStroke", MinBtn)
minStroke.Color = BLACK; minStroke.Thickness = 1.5; minStroke.Transparency = 0

local Content = Instance.new("Frame", Main)
Content.Size                 = UDim2.new(1, 0, 1, -52)
Content.Position             = UDim2.new(0, 0, 0, 52)
Content.BackgroundTransparency = 1

local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quad)

-- ─── TOGGLE ROW HELPER ─────────────────────────────────────────
local function makeToggleRow(labelText, yOffset)
    local Row = Instance.new("Frame", Content)
    Row.Size                 = UDim2.new(1, -24, 0, 46)
    Row.Position             = UDim2.new(0, 12, 0, yOffset)
    Row.BackgroundTransparency = 1
    Row.BorderSizePixel      = 0
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)
    local rowStroke = Instance.new("UIStroke", Row)
    rowStroke.Color = BLACK; rowStroke.Thickness = 1.5; rowStroke.Transparency = 0

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Size = UDim2.new(1,-70,1,0); Lbl.Position = UDim2.new(0,14,0,0)
    Lbl.BackgroundTransparency = 1; Lbl.Text = labelText
    Lbl.TextColor3 = WHITE
    Lbl.TextStrokeColor3 = BLACK; Lbl.TextStrokeTransparency = 0
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 13; Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local Btn = Instance.new("TextButton", Row)
    Btn.Size = UDim2.new(0,46,0,24); Btn.Position = UDim2.new(1,-56,0.5,-12)
    Btn.BackgroundTransparency = 1; Btn.Text = ""; Btn.BorderSizePixel = 0
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1,0)
    local bStroke = Instance.new("UIStroke", Btn)
    bStroke.Color = BLACK; bStroke.Thickness = 1.5; bStroke.Transparency = 0

    local Knob = Instance.new("Frame", Btn)
    Knob.Size = UDim2.new(0,18,0,18); Knob.Position = UDim2.new(0,3,0.5,-9)
    Knob.BackgroundColor3 = WHITE; Knob.BorderSizePixel = 0
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)
    local kStroke = Instance.new("UIStroke", Knob)
    kStroke.Color = BLACK; kStroke.Thickness = 1; kStroke.Transparency = 0

    return Btn, Knob, bStroke, rowStroke
end

local function applyOn(b,k,s,rs)
    k.Position         = UDim2.new(1,-21,0.5,-9)
    k.BackgroundColor3 = BLACK
end

local function applyOff(b,k,s,rs)
    k.Position         = UDim2.new(0,3,0.5,-9)
    k.BackgroundColor3 = WHITE
end

-- ROW 1: Auto Steal
local T1,K1,S1,RS1 = makeToggleRow("Auto Steal", 10)
if savedCfg.AutoSteal then AUTO_STEAL_ENABLED=true; applyOn(T1,K1,S1,RS1) end
T1.MouseButton1Click:Connect(function()
    AUTO_STEAL_ENABLED = not AUTO_STEAL_ENABLED
    if AUTO_STEAL_ENABLED then
        TweenService:Create(K1,ti,{Position=UDim2.new(1,-21,0.5,-9),BackgroundColor3=BLACK}):Play()
    else
        TweenService:Create(K1,ti,{Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=WHITE}):Play()
    end
end)

-- ROW 2: Hitbox
local T2,K2,S2,RS2 = makeToggleRow("Hitbox", 66)
if savedCfg.Hitbox then hitboxEnabled=true; applyOn(T2,K2,S2,RS2) end
T2.MouseButton1Click:Connect(function()
    hitboxEnabled = not hitboxEnabled
    if hitboxEnabled then
        TweenService:Create(K2,ti,{Position=UDim2.new(1,-21,0.5,-9),BackgroundColor3=BLACK}):Play()
    else
        TweenService:Create(K2,ti,{Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=WHITE}):Play()
    end
end)

-- ─── SEPARATOR ─────────────────────────────────────────────────
local Sep = Instance.new("Frame", Content)
Sep.Size             = UDim2.new(1, -24, 0, 1)
Sep.Position         = UDim2.new(0, 12, 0, 132)
Sep.BackgroundColor3 = WHITE
Sep.BorderSizePixel  = 0

-- ─── SAVE BUTTON ───────────────────────────────────────────────
local SaveFrame = Instance.new("Frame", Content)
SaveFrame.Size               = UDim2.new(1, -24, 0, 40)
SaveFrame.Position           = UDim2.new(0, 12, 0, 144)
SaveFrame.BackgroundTransparency = 1

local SaveBtn = Instance.new("TextButton", SaveFrame)
SaveBtn.Size               = UDim2.new(1, 0, 1, 0)
SaveBtn.BackgroundTransparency = 1
SaveBtn.Text               = "SAVE CONFIG"
SaveBtn.Font               = Enum.Font.GothamBlack
SaveBtn.TextSize           = 13
SaveBtn.TextColor3         = WHITE
SaveBtn.TextStrokeColor3   = BLACK
SaveBtn.TextStrokeTransparency = 0
SaveBtn.BorderSizePixel    = 0
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 8)
local saveStroke = Instance.new("UIStroke", SaveBtn)
saveStroke.Color = BLACK; saveStroke.Thickness = 1.5; saveStroke.Transparency = 0

SaveBtn.MouseButton1Click:Connect(function()
    saveConfig()
    SaveBtn.Text = "SAVED!"
    task.wait(1)
    SaveBtn.Text = "SAVE CONFIG"
end)

-- ─── DRAGGABLE ─────────────────────────────────────────────────
do
    local dragging, dragStart, startPos = false, nil, nil
    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=inp.Position; startPos=Main.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
end

-- ─── MINIMIZAR ─────────────────────────────────────────────────
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    MinBtn.Text = minimized and "+" or "—"
    TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
        Size = minimized and UDim2.new(0,270,0,52) or UDim2.new(0,270,0,FULL_HEIGHT)
    }):Play()
end)

-- ─── NEON PULSE ────────────────────────────────────────────────
task.spawn(function()
    local t = 0
    while ScreenGui.Parent do
        t = t + 0.04
        local pulse = (math.sin(t) + 1) / 2
        grimStroke.Transparency = 0.05 + pulse * 0.5
        task.wait(0.03)
    end
end)

-- ─── OPEN ANIMATION ────────────────────────────────────────────
Main.Size = UDim2.new(0,0,0,0)
TweenService:Create(Main, TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Size=UDim2.new(0,270,0,FULL_HEIGHT)}):Play()
