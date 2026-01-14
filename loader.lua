-- [[ KUMA HUB ULTRA PRO - MA ĐẠO CHÍ TÔN ]] --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local KEY = "kuma1501"
local SCRIPT_URL = "https://raw.githubusercontent.com/kuma152001/Kuma_hub/main/herb.lua"

if CoreGui:FindFirstChild("KumaMaDaoV5") then CoreGui.KumaMaDaoV5:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "KumaMaDaoV5"
gui.Parent = CoreGui
gui.IgnoreGuiInset = true

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = gui
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 380, 0, 280)
Main.ClipsDescendants = true
Main.BackgroundTransparency = 1

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 15)

-- Border Glow (Hiệu ứng viền phát sáng)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Thickness = 3
Stroke.Color = Color3.fromRGB(255, 0, 0)
Stroke.Transparency = 0.5

-- Hiệu ứng Breathing Glow cho viền
task.spawn(function()
    while true do
        TweenService:Create(Stroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.1, Thickness = 4.5}):Play()
        task.wait(1.5)
        TweenService:Create(Stroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.6, Thickness = 2.5}):Play()
        task.wait(1.5)
    end
end)

-- Hiệu ứng Ma Khí (Floating Particles)
local function CreateParticle()
    local p = Instance.new("Frame", Main)
    local size = math.random(2, 5)
    p.Size = UDim2.new(0, size, 0, size)
    p.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    p.BackgroundTransparency = 0.5
    p.Position = UDim2.new(math.random(), 0, 1, 0)
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    
    local speed = math.random(3, 7)
    TweenService:Create(p, TweenInfo.new(speed, Enum.EasingStyle.Linear), {
        Position = UDim2.new(math.random(), 0, -0.1, 0),
        BackgroundTransparency = 1
    }):Play()
    game:GetService("Debris"):AddItem(p, speed)
end

task.spawn(function()
    while true do
        if Main.Parent then CreateParticle() end
        task.wait(0.2)
    end
end)

-- Banner Cảnh Báo
local Banner = Instance.new("Frame", Main)
Banner.Size = UDim2.new(1, 0, 0, 35)
Banner.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
Banner.ZIndex = 2
local BannerCorner = Instance.new("UICorner", Banner)
BannerCorner.CornerRadius = UDim.new(0, 15)

local WarningText = Instance.new("TextLabel", Banner)
WarningText.Size = UDim2.new(1, 0, 1, 0)
WarningText.BackgroundTransparency = 1
WarningText.Text = "⚠️ TUYỆT ĐỐI KHÔNG PUBLIC CÔNG PHÁP NÀY"
WarningText.TextColor3 = Color3.new(1, 1, 1)
WarningText.Font = Enum.Font.GothamBold
WarningText.TextSize = 12
WarningText.ZIndex = 3

-- Hiệu ứng Flicker cho Warning Text
task.spawn(function()
    while true do
        WarningText.TextTransparency = 0
        task.wait(math.random(1, 5))
        WarningText.TextTransparency = 0.8
        task.wait(0.1)
        WarningText.TextTransparency = 0.2
        task.wait(0.1)
        WarningText.TextTransparency = 0.9
        task.wait(0.05)
    end
end)

-- Title
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 55)
Title.BackgroundTransparency = 1
Title.Text = "KUMA HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 42
Title.TextTransparency = 1

-- Input Frame
local InputFrame = Instance.new("Frame", Main)
InputFrame.Size = UDim2.new(0, 300, 0, 45)
InputFrame.Position = UDim2.new(0.5, -150, 0.52, 0)
InputFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
InputFrame.BackgroundTransparency = 1
local InpCorner = Instance.new("UICorner", InputFrame)
local InpStroke = Instance.new("UIStroke", InputFrame)
InpStroke.Color = Color3.fromRGB(150, 0, 0)
InpStroke.Transparency = 1

local Box = Instance.new("TextBox", InputFrame)
Box.Size = UDim2.new(1, -20, 1, 0)
Box.Position = UDim2.new(0, 10, 0, 0)
Box.BackgroundTransparency = 1
Box.PlaceholderText = "Nhập Ma Đạo Ấn..."
Box.Text = ""
Box.TextColor3 = Color3.new(1, 1, 1)
Box.Font = Enum.Font.Gotham
Box.TextSize = 16
Box.TextTransparency = 1

-- Unlock Button
local Btn = Instance.new("TextButton", Main)
Btn.Size = UDim2.new(0, 300, 0, 45)
Btn.Position = UDim2.new(0.5, -150, 0.75, 0)
Btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
Btn.Text = "KHAI MỞ MA GIỚI"
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 16
Btn.TextColor3 = Color3.new(1, 1, 1)
Btn.BackgroundTransparency = 1
Btn.TextTransparency = 1
Btn.AutoButtonColor = false
Instance.new("UICorner", Btn)

-- Loading System
local LFrame = Instance.new("Frame", Main)
LFrame.Size = UDim2.new(0, 300, 0, 6)
LFrame.Position = UDim2.new(0.5, -150, 0.9, 0)
LFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LFrame.Visible = false
local LBar = Instance.new("Frame", LFrame)
LBar.Size = UDim2.new(0, 0, 1, 0)
LBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Instance.new("UICorner", LFrame)
Instance.new("UICorner", LBar)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0.82, 0)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(150, 150, 150)
Status.Font = Enum.Font.GothamItalic
Status.TextSize = 12
Status.Text = ""

-- Fade In Animation
task.spawn(function()
    TweenService:Create(Main, TweenInfo.new(0.8), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Title, TweenInfo.new(0.8), {TextTransparency = 0}):Play()
    task.wait(0.3)
    TweenService:Create(InputFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
    TweenService:Create(InpStroke, TweenInfo.new(0.5), {Transparency = 0}):Play()
    TweenService:Create(Box, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    task.wait(0.2)
    TweenService:Create(Btn, TweenInfo.new(0.5), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
end)

-- Button Hover & Pulse
Btn.MouseEnter:Connect(function()
    TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 0, 0), Size = UDim2.new(0, 310, 0, 50), Position = UDim2.new(0.5, -155, 0.74, 0)}):Play()
end)
Btn.MouseLeave:Connect(function()
    TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(180, 0, 0), Size = UDim2.new(0, 300, 0, 45), Position = UDim2.new(0.5, -150, 0.75, 0)}):Play()
end)

-- Logic
Btn.MouseButton1Click:Connect(function()
    if Box.Text == KEY then
        Btn.Visible = false
        InputFrame.Visible = false
        Title.TextSize = 30
        Title.Text = "MA KHÍ QUÁN THÂN"
        LFrame.Visible = true
        
        local stages = {"Đang kết nối ma giới...", "Vận chuyển ma công...", "Khai mở thần thức...", "Thành công!"}
        for i, v in ipairs(stages) do
            Status.Text = v
            LBar:TweenSize(UDim2.new(i/4, 0, 1, 0), "Out", "Quad", 0.5)
            task.wait(0.6)
        end
        
        gui:Destroy()
        loadstring(game:HttpGet(SCRIPT_URL .. "?t=" .. tick()))()
    else
        Title.TextColor3 = Color3.fromRGB(255, 0, 0)
        Btn.Text = "MA ẤN SAI!"
        for i = 1, 10 do
            Main.Position = UDim2.new(0.5, math.random(-5,5), 0.5, math.random(-5,5))
            task.wait(0.01)
        end
        Main.Position = UDim2.new(0.5, 0, 0.5, 0)
        task.wait(1)
        Btn.Text = "KHAI MỞ MA GIỚI"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)
