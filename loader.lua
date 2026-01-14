-- [[ 📜 CỔ MA THẦN LỤC - KUMA HUB V9 (CINEMATIC XIANXIA) 📜 ]] --
-- [[ CẢNH BÁO: TUYỆT ĐỐI KHÔNG PUBLIC CÔNG PHÁP MA ĐẠO NÀY ]] --

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local KEY = "kuma1501"
local SCRIPT_URL = "https://raw.githubusercontent.com/kuma152001/Kuma_hub/main/herb.lua"

if CoreGui:FindFirstChild("KumaXianxiaV9") then CoreGui.KumaXianxiaV9:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "KumaXianxiaV9"
gui.Parent = CoreGui
gui.IgnoreGuiInset = true

-- Hàm kéo UI
local function MakeDraggable(Frame, DragPart)
    local dragging, dragInput, dragStart, startPos
    DragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Khung chính (Ancient Scroll Style)
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = gui
Main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 420, 0, 310)
Main.ClipsDescendants = true
Main.ZIndex = 1

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 20)

-- Viền phát sáng rực rỡ (Aura)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Thickness = 3
Stroke.Color = Color3.fromRGB(255, 0, 0)
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Hiệu ứng Nền Ma Đạo (Demonic Essence)
local BGGradient = Instance.new("UIGradient", Main)
BGGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 0, 0))
})
task.spawn(function()
    while Main and Main.Parent do
        BGGradient.Rotation = BGGradient.Rotation + 1.5
        task.wait(0.02)
    end
end)

-- Banner Cảnh Báo Tuyệt Mật
local Banner = Instance.new("Frame", Main)
Banner.Size = UDim2.new(1, -40, 0, 32)
Banner.Position = UDim2.new(0, 20, 0, 15)
Banner.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
Banner.ZIndex = 5
Instance.new("UICorner", Banner).CornerRadius = UDim.new(0, 10)

local WarningText = Instance.new("TextLabel", Banner)
WarningText.Size = UDim2.new(1, 0, 1, 0)
WarningText.BackgroundTransparency = 1
WarningText.Text = "࿇ TUYỆT ĐỐI KHÔNG PUBLIC CÔNG PHÁP NÀY ࿇"
WarningText.TextColor3 = Color3.new(1, 1, 1)
WarningText.Font = Enum.Font.Antique
WarningText.TextSize = 13
WarningText.ZIndex = 6

-- Tiêu đề tự động chuyển đổi (Morphing Title)
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 60)
Title.Position = UDim2.new(0, 0, 0, 65)
Title.BackgroundTransparency = 1
Title.Text = "KUMA HUB"
Title.TextColor3 = Color3.fromRGB(255, 215, 0) -- Vàng Kim
Title.Font = Enum.Font.Garamond
Title.TextSize = 48
Title.ZIndex = 10

local Titles = {"KUMA HUB", "CỔ MA THẦN LỤC", "NGHỊCH THIÊN CẢI MỆNH"}
task.spawn(function()
    local i = 1
    while Main and Main.Parent do
        task.wait(3)
        TweenService:Create(Title, TweenInfo.new(1), {TextTransparency = 1}):Play()
        task.wait(1)
        i = (i % #Titles) + 1
        Title.Text = Titles[i]
        TweenService:Create(Title, TweenInfo.new(1), {TextTransparency = 0}):Play()
    end
end)

-- Linh Khí bay lơ lửng
local function CreateEssence()
    local p = Instance.new("Frame", Main)
    p.Size = UDim2.new(0, 3, 0, 3)
    p.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    p.BackgroundTransparency = 0.3
    p.Position = UDim2.new(math.random(), 0, 1, 0)
    p.ZIndex = 2
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    local speed = math.random(4, 8)
    TweenService:Create(p, TweenInfo.new(speed, Enum.EasingStyle.Linear), {
        Position = UDim2.new(math.random(), 0, -0.1, 0),
        BackgroundTransparency = 1
    }):Play()
    game:GetService("Debris"):AddItem(p, speed)
end
task.spawn(function() while Main and Main.Parent do CreateEssence(); task.wait(0.3) end end)

-- Khung nhập Linh Ấn
local InputFrame = Instance.new("Frame", Main)
InputFrame.Size = UDim2.new(0, 340, 0, 45)
InputFrame.Position = UDim2.new(0.5, -170, 0.55, 0)
InputFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
InputFrame.ZIndex = 10
Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 12)
local InpStroke = Instance.new("UIStroke", InputFrame)
InpStroke.Color = Color3.fromRGB(200, 0, 0)

local Box = Instance.new("TextBox", InputFrame)
Box.Size = UDim2.new(1, -20, 1, 0)
Box.Position = UDim2.new(0, 10, 0, 0)
Box.BackgroundTransparency = 1
Box.PlaceholderText = "Dán Linh Ấn (Key) để đột phá..."
Box.Text = ""
Box.TextColor3 = Color3.fromRGB(255, 215, 0)
Box.Font = Enum.Font.Garamond
Box.TextSize = 18
Box.ZIndex = 11

-- Nút Bấm Khai Mở
local Btn = Instance.new("TextButton", Main)
Btn.Size = UDim2.new(0, 340, 0, 50)
Btn.Position = UDim2.new(0.5, -170, 0.78, 0)
Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Btn.Text = "ĐỘT PHÁ XIỀNG XÍCH"
Btn.Font = Enum.Font.Antique
Btn.TextSize = 24
Btn.TextColor3 = Color3.new(1, 1, 1)
Btn.ZIndex = 10
Btn.AutoButtonColor = false
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 12)

-- Thanh Chu Thiên Loading
local LFrame = Instance.new("Frame", Main)
LFrame.Size = UDim2.new(0, 340, 0, 4)
LFrame.Position = UDim2.new(0.5, -170, 0.94, 0)
LFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LFrame.Visible = false
LFrame.ZIndex = 10
local LBar = Instance.new("Frame", LFrame)
LBar.Size = UDim2.new(0, 0, 1, 0)
LBar.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
Instance.new("UICorner", LBar)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0.89, 0)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(255, 215, 0)
Status.Font = Enum.Font.Antique
Status.TextSize = 14
Status.Text = ""
Status.ZIndex = 10

-- Kéo UI
MakeDraggable(Main, Title)

-- Hiệu ứng Pulse (Nhịp đập ma đạo)
task.spawn(function()
    while Main and Main.Parent do
        TweenService:Create(Stroke, TweenInfo.new(1.5), {Thickness = 5, Transparency = 0.1}):Play()
        TweenService:Create(Btn, TweenInfo.new(1.5), {BackgroundColor3 = Color3.fromRGB(200, 0, 0)}):Play()
        task.wait(1.5)
        TweenService:Create(Stroke, TweenInfo.new(1.5), {Thickness = 2, Transparency = 0.5}):Play()
        TweenService:Create(Btn, TweenInfo.new(1.5), {BackgroundColor3 = Color3.fromRGB(120, 0, 0)}):Play()
        task.wait(1.5)
    end
end)

-- Logic
Btn.MouseButton1Click:Connect(function()
    if Box.Text == KEY then
        Btn.Visible = false
        InputFrame.Visible = false
        Title.Text = "NGHỊCH THIÊN THÀNH CÔNG"
        LFrame.Visible = true
        
        local stages = {
            {txt = "Đang tụ linh khí...", p = 0.25},
            {txt = "Vận chuyển Tiểu Chu Thiên...", p = 0.5},
            {txt = "Vận chuyển Đại Chu Thiên...", p = 0.8},
            {txt = "Đang Độ Kiếp...", p = 1.0}
        }
        
        for _, s in ipairs(stages) do
            Status.Text = s.txt
            LBar:TweenSize(UDim2.new(s.p, 0, 1, 0), "Out", "Quad", 0.8)
            task.wait(1)
        end
        
        gui:Destroy()
        loadstring(game:HttpGet(SCRIPT_URL .. "?t=" .. tick()))()
    else
        Box.Text = ""
        Btn.Text = "LINH ẤN SAI LẦM!"
        Btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        task.wait(1)
        Btn.Text = "ĐỘT PHÁ XIỀNG XÍCH"
    end
end)

print("Kuma Demonic Scripture Loaded!")
