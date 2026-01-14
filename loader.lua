-- [[ KUMA HUB ULTRA PRO - MA ĐẠO FINAL ]] --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local KEY = "kuma1501"
local SCRIPT_URL = "https://raw.githubusercontent.com/kuma152001/Kuma_hub/main/herb.lua"

-- Xóa UI cũ
if CoreGui:FindFirstChild("KumaMaDaoFinal") then CoreGui.KumaMaDaoFinal:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "KumaMaDaoFinal"
gui.Parent = CoreGui
gui.IgnoreGuiInset = true

-- Khung chính (Main)
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = gui
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 380, 0, 280)
Main.ClipsDescendants = true
Main.BackgroundTransparency = 1 -- Bắt đầu bằng trong suốt để hiện ra mượt

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 12)

-- Banner Ghi chú Ma Đạo (Nổi bật nhất)
local Banner = Instance.new("Frame", Main)
Banner.Size = UDim2.new(1, 0, 0, 35)
Banner.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
Banner.ZIndex = 2
local BannerCorner = Instance.new("UICorner", Banner)
BannerCorner.CornerRadius = UDim.new(0, 12)

local WarningText = Instance.new("TextLabel", Banner)
WarningText.Size = UDim2.new(1, 0, 1, 0)
WarningText.BackgroundTransparency = 1
WarningText.Text = "⚠️ TUYỆT ĐỐI KHÔNG PUBLIC CÔNG PHÁP NÀY"
WarningText.TextColor3 = Color3.new(1, 1, 1)
WarningText.Font = Enum.Font.GothamBold
WarningText.TextSize = 12
WarningText.ZIndex = 3

-- Viền Neon Đỏ
local Stroke = Instance.new("UIStroke", Main)
Stroke.Thickness = 2.5
Stroke.Color = Color3.fromRGB(255, 0, 0)
Stroke.Transparency = 1

-- Hiệu ứng Gradient Ma Khí xoay tròn
local BGGradient = Instance.new("UIGradient", Main)
BGGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 15)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
})
task.spawn(function()
    while true do
        BGGradient.Rotation = BGGradient.Rotation + 1
        task.wait(0.02)
    end
end)

-- Tiêu đề HUB
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "KUMA HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 38
Title.TextTransparency = 1

-- Ô nhập Key
local InputFrame = Instance.new("Frame", Main)
InputFrame.Size = UDim2.new(0, 300, 0, 45)
InputFrame.Position = UDim2.new(0.5, -150, 0.5, 0)
InputFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
InputFrame.BackgroundTransparency = 1
local InpCorner = Instance.new("UICorner", InputFrame)
local InpStroke = Instance.new("UIStroke", InputFrame)
InpStroke.Color = Color3.fromRGB(200, 0, 0)
InpStroke.Transparency = 1

local Box = Instance.new("TextBox", InputFrame)
Box.Size = UDim2.new(1, -20, 1, 0)
Box.Position = UDim2.new(0, 10, 0, 0)
Box.BackgroundTransparency = 1
Box.PlaceholderText = "Nhập Ma Đạo Ấn (Key)..."
Box.Text = ""
Box.TextColor3 = Color3.new(1, 1, 1)
Box.Font = Enum.Font.Gotham
Box.TextSize = 16
Box.TextTransparency = 1

-- Nút Unlock
local Btn = Instance.new("TextButton", Main)
Btn.Size = UDim2.new(0, 300, 0, 45)
Btn.Position = UDim2.new(0.5, -150, 0.72, 0)
Btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Btn.Text = "KHAI MỞ CÔNG PHÁP"
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 16
Btn.TextColor3 = Color3.new(1, 1, 1)
Btn.BackgroundTransparency = 1
Btn.TextTransparency = 1
Instance.new("UICorner", Btn)

-- Thanh Loading (Ẩn)
local LFrame = Instance.new("Frame", Main)
LFrame.Size = UDim2.new(0, 300, 0, 4)
LFrame.Position = UDim2.new(0.5, -150, 0.9, 0)
LFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
LFrame.Visible = false
local LBar = Instance.new("Frame", LFrame)
LBar.Size = UDim2.new(0, 0, 1, 0)
LBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

-- Hàm Rung
local function Shake()
    local orig = Main.Position
    for i = 1, 10 do
        Main.Position = orig + UDim2.new(0, math.random(-5,5), 0, math.random(-5,5))
        task.wait(0.01)
    end
    Main.Position = orig
end

-- Hiệu ứng hiện hình mượt mà (Fade In)
task.spawn(function()
    TweenService:Create(Main, TweenInfo.new(0.6), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Stroke, TweenInfo.new(0.6), {Transparency = 0.4}):Play()
    task.wait(0.2)
    TweenService:Create(Title, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
    task.wait(0.1)
    TweenService:Create(InputFrame, TweenInfo.new(0.6), {BackgroundTransparency = 0}):Play()
    TweenService:Create(InpStroke, TweenInfo.new(0.6), {Transparency = 0}):Play()
    TweenService:Create(Box, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
    task.wait(0.1)
    TweenService:Create(Btn, TweenInfo.new(0.6), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
end)

-- Logic
Btn.MouseButton1Click:Connect(function()
    if Box.Text == KEY then
        Btn.Visible = false
        InputFrame.Visible = false
        Title.Text = "THÀNH CÔNG"
        LFrame.Visible = true
        LBar:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 2)
        task.wait(2.1)
        gui:Destroy()
        loadstring(game:HttpGet(SCRIPT_URL .. "?t=" .. tick()))()
    else
        Shake()
        Box.Text = ""
        Btn.Text = "SAI MA ẤN!"
        task.wait(1)
        Btn.Text = "KHAI MỞ CÔNG PHÁP"
    end
end)
