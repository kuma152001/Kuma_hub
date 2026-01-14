-- [[ KUMA HUB PRO LOADER - MODERN DESIGN ]] --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

local KEY = "kuma1501"
local SCRIPT_URL = "https://raw.githubusercontent.com/kuma152001/Kuma_hub/main/herb.lua"

-- Cleanup
if CoreGui:FindFirstChild("KumaKeyUI_Pro") then CoreGui.KumaKeyUI_Pro:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "KumaKeyUI_Pro"
gui.Parent = CoreGui
gui.IgnoreGuiInset = true

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = gui
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.5, -160, 0.5, -100) -- Căn giữa
Main.Size = UDim2.new(0, 320, 0, 200)
Main.ClipsDescendants = true
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 1.2, 0) -- Bắt đầu từ dưới màn hình để chạy hiệu ứng trượt lên

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 12)

-- Border Glow (Viền Neon)
local Stroke = Instance.new("UIStroke")
Stroke.Parent = Main
Stroke.Color = Color3.fromRGB(255, 140, 0)
Stroke.Thickness = 2
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Title Section
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "🐻 KUMA HUB"
Title.TextColor3 = Color3.fromRGB(255, 170, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24

local SubTitle = Instance.new("TextLabel", Main)
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 40)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Please enter your access key"
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 12

-- Key Input Box
local InputFrame = Instance.new("Frame", Main)
InputFrame.Size = UDim2.new(0, 260, 0, 45)
InputFrame.Position = UDim2.new(0.5, -130, 0.45, 0)
InputFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
local InputCorner = Instance.new("UICorner", InputFrame)

local Box = Instance.new("TextBox", InputFrame)
Box.Size = UDim2.new(1, -20, 1, 0)
Box.Position = UDim2.new(0, 10, 0, 0)
Box.BackgroundTransparency = 1
Box.PlaceholderText = "Enter Key Here..."
Box.Text = ""
Box.TextColor3 = Color3.new(1, 1, 1)
Box.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
Box.Font = Enum.Font.Gotham
Box.TextSize = 16

-- Unlock Button
local Btn = Instance.new("TextButton", Main)
Btn.Size = UDim2.new(0, 260, 0, 40)
Btn.Position = UDim2.new(0.5, -130, 0.75, 0)
Btn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
Btn.Text = "UNLOCK ACCESS"
Btn.TextColor3 = Color3.new(1, 1, 1)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 14
Btn.AutoButtonColor = false
local BtnCorner = Instance.new("UICorner", Btn)

-- Gradient cho Nút
local Grad = Instance.new("UIGradient", Btn)
Grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 0))
})

-- Animations & Logic
local function ShakeUI()
    local originalPos = UDim2.new(0.5, 0, 0.5, 0)
    for i = 1, 6 do
        local xOffset = (i % 2 == 0 and 10 or -10)
        TweenService:Create(Main, TweenInfo.new(0.05), {Position = UDim2.new(0.5, xOffset, 0.5, 0)}):Play()
        task.wait(0.05)
    end
    TweenService:Create(Main, TweenInfo.new(0.05), {Position = originalPos}):Play()
end

-- Hiệu ứng di chuột (Hover)
Btn.MouseEnter:Connect(function()
    TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 200, 0)}):Play()
    TweenService:Create(Stroke, TweenInfo.new(0.3), {Thickness = 4}):Play()
end)

Btn.MouseLeave:Connect(function()
    TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 140, 0)}):Play()
    TweenService:Create(Stroke, TweenInfo.new(0.3), {Thickness = 2}):Play()
end)

-- Hiệu ứng mượt trượt lên khi mở
Main:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Back", 0.6, true)

-- Logic Click
Btn.MouseButton1Click:Connect(function()
    if Box.Text == KEY then
        Btn.Text = "SUCCESS! LOADING..."
        TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 200, 100)}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(0, 255, 120)}):Play()
        
        task.wait(1)
        
        -- Hiệu ứng biến mất
        Main:TweenPosition(UDim2.new(0.5, 0, 1.2, 0), "In", "Back", 0.5, true)
        task.wait(0.5)
        gui:Destroy()

        -- Tải script kèm Cache Buster để luôn lấy bản mới nhất
        local success, err = pcall(function()
            loadstring(game:HttpGet(SCRIPT_URL .. "?t=" .. tick()))()
        end)
        
        if not success then
            warn("KUMA HUB Load Error: " .. tostring(err))
        end
    else
        Box.Text = ""
        Btn.Text = "INVALID KEY!"
        ShakeUI()
        task.wait(1)
        Btn.Text = "UNLOCK ACCESS"
    end
end)
