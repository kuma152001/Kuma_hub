-- [[ KUMA HUB ULTRA LOADER - PRESET DESIGN ]] --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local KEY = "kuma1501"
local SCRIPT_URL = "https://raw.githubusercontent.com/kuma152001/Kuma_hub/main/herb.lua"

-- Cleanup cũ
if CoreGui:FindFirstChild("KumaUltraUI") then CoreGui.KumaUltraUI:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "KumaUltraUI"
gui.Parent = CoreGui
gui.IgnoreGuiInset = true

-- Khung chính (Main)
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = gui
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 380, 0, 240)
Main.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 16)

-- Hiệu ứng dải màu chuyển động (Animated Gradient Background)
local BGGradient = Instance.new("UIGradient")
BGGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 30, 10)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
})
BGGradient.Parent = Main

task.spawn(function()
    while true do
        TweenService:Create(BGGradient, TweenInfo.new(3, Enum.EasingStyle.Linear), {Rotation = 360}):Play()
        task.wait(3)
        BGGradient.Rotation = 0
    end
end)

-- Viền phát sáng (Glow Stroke)
local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(255, 150, 0)
MainStroke.Transparency = 0.5

-- Decor: Các đốm sáng bay lơ lửng (Floating Particles)
for i = 1, 3 do
    local dot = Instance.new("Frame", Main)
    dot.Size = UDim2.new(0, 100, 0, 100)
    dot.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    dot.BackgroundTransparency = 0.9
    dot.Position = UDim2.new(math.random(), 0, math.random(), 0)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    task.spawn(function()
        while true do
            local newPos = UDim2.new(math.random(), -50, math.random(), -50)
            TweenService:Create(dot, TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = newPos}):Play()
            task.wait(5)
        end
    end)
end

-- Tiêu đề chính
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 60)
Title.BackgroundTransparency = 1
Title.Text = "KUMA HUB"
Title.TextColor3 = Color3.fromRGB(255, 180, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 32
Title.ZIndex = 5

local SubTitle = Instance.new("TextLabel", Main)
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 50)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "PREMIUM EXPLOIT SYSTEM"
SubTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 10
SubTitle.TextStrokeTransparency = 0.8
SubTitle.ZIndex = 5

-- Khung nhập Key (TextBox Container)
local InputContainer = Instance.new("Frame", Main)
InputContainer.Size = UDim2.new(0, 300, 0, 45)
InputContainer.Position = UDim2.new(0.5, -150, 0.45, 0)
InputContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
InputContainer.ZIndex = 5
Instance.new("UICorner", InputContainer).CornerRadius = UDim.new(0, 10)
local InputStroke = Instance.new("UIStroke", InputContainer)
InputStroke.Color = Color3.fromRGB(50, 50, 50)

local Box = Instance.new("TextBox", InputContainer)
Box.Size = UDim2.new(1, -20, 1, 0)
Box.Position = UDim2.new(0, 10, 0, 0)
Box.BackgroundTransparency = 1
Box.PlaceholderText = "Paste your key here..."
Box.Text = ""
Box.TextColor3 = Color3.new(1, 1, 1)
Box.Font = Enum.Font.Gotham
Box.TextSize = 16
Box.ZIndex = 6

-- Nút Unlock xịn
local UnlockBtn = Instance.new("TextButton", Main)
UnlockBtn.Size = UDim2.new(0, 300, 0, 45)
UnlockBtn.Position = UDim2.new(0.5, -150, 0.72, 0)
UnlockBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
UnlockBtn.Text = "CONTINUE"
UnlockBtn.TextColor3 = Color3.new(1, 1, 1)
UnlockBtn.Font = Enum.Font.GothamBold
UnlockBtn.TextSize = 16
UnlockBtn.ZIndex = 6
UnlockBtn.AutoButtonColor = false
Instance.new("UICorner", UnlockBtn).CornerRadius = UDim.new(0, 10)

-- Thanh Loading (Loading Bar - Ẩn lúc đầu)
local LoadFrame = Instance.new("Frame", Main)
LoadFrame.Size = UDim2.new(0, 300, 0, 4)
LoadFrame.Position = UDim2.new(0.5, -150, 0.92, 0)
LoadFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
LoadFrame.Visible = false
local LoadBar = Instance.new("Frame", LoadFrame)
LoadBar.Size = UDim2.new(0, 0, 1, 0)
LoadBar.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
Instance.new("UICorner", LoadFrame)
Instance.new("UICorner", LoadBar)

-- Hiệu ứng Button (Hover)
UnlockBtn.MouseEnter:Connect(function()
    TweenService:Create(UnlockBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 190, 0)}):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.3), {Transparency = 0, Thickness = 3}):Play()
end)

UnlockBtn.MouseLeave:Connect(function()
    TweenService:Create(UnlockBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 140, 0)}):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.3), {Transparency = 0.5, Thickness = 2}):Play()
end)

-- Hàm rung màn hình
local function Shake()
    local orig = Main.Position
    for i = 1, 10 do
        Main.Position = orig + UDim2.new(0, math.random(-5,5), 0, math.random(-5,5))
        task.wait(0.02)
    end
    Main.Position = orig
end

-- Logic chính
UnlockBtn.MouseButton1Click:Connect(function()
    if Box.Text == KEY then
        UnlockBtn.Visible = false
        InputContainer.Visible = false
        Title.Text = "AUTHENTICATED"
        SubTitle.Text = "Please wait, loading Kuma Hub..."
        LoadFrame.Visible = true
        
        -- Chạy thanh Loading
        LoadBar:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 2)
        task.wait(2.1)
        
        gui:Destroy()
        
        -- Load Script
        loadstring(game:HttpGet(SCRIPT_URL .. "?t=" .. tick()))()
    else
        Shake()
        Box.Text = ""
        UnlockBtn.Text = "INVALID KEY"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        task.wait(1.5)
        UnlockBtn.Text = "CONTINUE"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    end
end)

-- Entry Animation (Hiện hình mượt mà)
Main.Size = UDim2.new(0, 0, 0, 0)
Main:TweenSize(UDim2.new(0, 380, 0, 240), "Out", "Back", 0.7)
