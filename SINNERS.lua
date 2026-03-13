local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")

local player    = Players.LocalPlayer
local Camera    = workspace.CurrentCamera

local WHITE       = Color3.fromRGB(255, 255, 255)
local BLACK       = Color3.fromRGB(0, 0, 0)
local FULL_HEIGHT = 60

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
Main.Position               = UDim2.new(0.5, -135, 0.5, -30)
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

-- Draggable
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

-- Minimizar
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    MinBtn.Text = minimized and "+" or "—"
    TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
        Size = minimized and UDim2.new(0,270,0,52) or UDim2.new(0,270,0,FULL_HEIGHT)
    }):Play()
end)

-- Neon pulse
task.spawn(function()
    local t = 0
    while ScreenGui.Parent do
        t = t + 0.04
        local pulse = (math.sin(t) + 1) / 2
        grimStroke.Transparency = 0.05 + pulse * 0.5
        task.wait(0.03)
    end
end)

-- Animacion de apertura
Main.Size = UDim2.new(0,0,0,0)
TweenService:Create(Main, TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Size=UDim2.new(0,270,0,FULL_HEIGHT)}):Play()
