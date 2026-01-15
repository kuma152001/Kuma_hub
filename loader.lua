-- [[ 📜 CỔ MA ĐẾ TÔN - KUMA HUB V10 (CINEMATIC WIDE) 📜 ]] --
-- [[ CẢNH BÁO: TUYỆT ĐỐI KHÔNG PUBLIC CÔNG PHÁP MA ĐẠO NÀY ]] --

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local KEY = "kuma1501"
local SCRIPT_URL = "https://raw.githubusercontent.com/kuma152001/Kuma_hub/main/herb.lua"

if CoreGui:FindFirstChild("KumaXianxiaV10") then CoreGui.KumaXianxiaV10:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "KumaXianxiaV10"
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

-- Khung chính (Kích thước mở rộng 500x350)
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = gui
Main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 500, 0, 350) -- Tăng kích thước cực rộng
Main.ClipsDescendants = true
Main.ZIndex = 1

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 25)

-- Viền Neon "Ma Quang" (Chế độ Border để không đè chữ)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Thickness = 3.5
Stroke.Color = Color3.fromRGB(255, 0, 0)
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border -- Viền tỏa ra ngoài

-- Nền Gradient xoay cực nhanh (Ma Khí Bạo Phát)
local BGGradient = Instance.new("UIGradient", Main)
BGGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 0, 0))
})
task.spawn(function()
    while Main and Main.Parent do
        BGGradient.Rotation = BGGradient.Rotation + 2
        task.wait(0.02)
    end
end)

-- Banner Cảnh Báo (Thiết kế lại rộng hơn)
local Banner = Instance.new("Frame", Main)
Banner.Size = UDim2.new(1, -60, 0, 35)
Banner.Position = UDim2.new(0, 30, 0, 20)
Banner.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Banner.ZIndex = 5
Instance.new("UICorner", Banner).CornerRadius = UDim.new(0, 12)

local WarningText = Instance.new("TextLabel", Banner)
WarningText.Size = UDim2.new(1, 0, 1, 0)
WarningText.BackgroundTransparency = 1
WarningText.Text = "࿇ TUYỆT ĐỐI KHÔNG PUBLIC CÔNG PHÁP NÀY ࿇"
WarningText.TextColor3 = Color3.new(1, 1, 1)
WarningText.Font = Enum.Font.Antique
WarningText.TextSize = 15
WarningText.ZIndex = 6

-- Tiêu đề Morphing (Tăng size và khoảng cách)
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 80)
Title.Position = UDim2.new(0, 0, 0, 70)
Title.BackgroundTransparency = 1
Title.Text = "KUMA HUB"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.Garamond
Title.TextSize = 55 -- Chữ to hơn
Title.ZIndex = 10

local Titles = {"KUMA HUB", "HỆ THỐNG NGHỊCH THIÊN"}
task.spawn(function()
    local i = 1
    while Main and Main.Parent do
        task.wait(3.5)
        TweenService:Create(Title, TweenInfo.new(1.2), {TextTransparency = 1, TextSize = 40}):Play()
        task.wait(1.2)
        i = (i % #Titles) + 1
        Title.Text = Titles[i]
        TweenService:Create(Title, TweenInfo.new(1.2), {TextTransparency = 0, TextSize = 55}):Play()
    end
end)

-- Đốm sáng linh khí rực rỡ hơn
local function CreateSoul()
    local p = Instance.new("Frame", Main)
    p.Size = UDim2.new(0, 5, 0, 5)
    p.BackgroundColor3 = Color3.fromRGB(255, 230, 100)
    p.BackgroundTransparency = 0.2
    p.Position = UDim2.new(math.random(), 0, 1.1, 0)
    p.ZIndex = 2
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    local speed = math.random(3, 6)
    TweenService:Create(p, TweenInfo.new(speed, Enum.EasingStyle.Sine), {
        Position = UDim2.new(math.random(), 0, -0.2, 0),
        BackgroundTransparency = 1
    }):Play()
    game:GetService("Debris"):AddItem(p, speed)
end
task.spawn(function() while Main and Main.Parent do CreateSoul(); task.wait(0.2) end end)

-- Khung nhập Linh Ấn (Rộng rãi)
local InputFrame = Instance.new("Frame", Main)
InputFrame.Size = UDim2.new(0, 400, 0, 50) -- Rộng hơn
InputFrame.Position = UDim2.new(0.5, -200, 0.58, 0)
InputFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
InputFrame.ZIndex = 10
Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 15)
local InpStroke = Instance.new("UIStroke", InputFrame)
InpStroke.Color = Color3.fromRGB(255, 0, 0)
InpStroke.Thickness = 2

local Box = Instance.new("TextBox", InputFrame)
Box.Size = UDim2.new(1, -30, 1, 0)
Box.Position = UDim2.new(0, 15, 0, 0)
Box.BackgroundTransparency = 1
Box.PlaceholderText = "Dán Linh Ấn (Key) để đột phá..."
Box.Text = ""
Box.TextColor3 = Color3.fromRGB(255, 215, 0)
Box.Font = Enum.Font.Garamond
Box.TextSize = 20
Box.ZIndex = 11

-- Nút Bấm Khai Mở (Rực cháy)
local Btn = Instance.new("TextButton", Main)
Btn.Size = UDim2.new(0, 400, 0, 55)
Btn.Position = UDim2.new(0.5, -200, 0.78, 0)
Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Btn.Text = "ĐỘT PHÁ XIỀNG XÍCH"
Btn.Font = Enum.Font.Antique
Btn.TextSize = 26
Btn.TextColor3 = Color3.new(1, 1, 1)
Btn.ZIndex = 10
Btn.AutoButtonColor = false
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 15)

-- Thanh Loading Chu Thiên
local LFrame = Instance.new("Frame", Main)
LFrame.Size = UDim2.new(0, 400, 0, 5)
LFrame.Position = UDim2.new(0.5, -200, 0.95, 0)
LFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LFrame.Visible = false
LFrame.ZIndex = 10
local LBar = Instance.new("Frame", LFrame)
LBar.Size = UDim2.new(0, 0, 1, 0)
LBar.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
Instance.new("UICorner", LBar)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, 0, 0, 25)
Status.Position = UDim2.new(0, 0, 0.88, 0)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(255, 215, 0)
Status.Font = Enum.Font.Antique
Status.TextSize = 16
Status.Text = ""
Status.ZIndex = 10

-- Kéo UI
MakeDraggable(Main, Title)

-- Hiệu ứng Pulse (Nhịp đập của UI)
task.spawn(function()
    while Main and Main.Parent do
        TweenService:Create(Stroke, TweenInfo.new(1.2), {Thickness = 6, Transparency = 0.2}):Play()
        TweenService:Create(Btn, TweenInfo.new(1.2), {BackgroundColor3 = Color3.fromRGB(220, 0, 0)}):Play()
        task.wait(1.2)
        TweenService:Create(Stroke, TweenInfo.new(1.2), {Thickness = 2, Transparency = 0.6}):Play()
        TweenService:Create(Btn, TweenInfo.new(1.2), {BackgroundColor3 = Color3.fromRGB(150, 0, 0)}):Play()
        task.wait(1.2)
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
            {txt = "Đang khởi động hệ thống", p = 0.5},
            {txt = "Chào mừng túc chủ", p = 0.8},
            {txt = "Đang Độ Kiếp...", p = 1.0}
        }
        
        for _, s in ipairs(stages) do
            Status.Text = s.txt
            LBar:TweenSize(UDim2.new(s.p, 0, 1, 0), "Out", "Quad", 1)
            task.wait(1.2)
        end
        
        gui:Destroy()
        loadstring(game:HttpGet(SCRIPT_URL .. "?t=" .. tick()))()
    else
        Box.Text = ""
        Btn.Text = "LINH ẤN SAI LẦM!"
        Btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        local orig = Main.Position
        for _ = 1, 8 do
            Main.Position = orig + UDim2.new(0, math.random(-8, 8), 0, math.random(-8, 8))
            task.wait(0.02)
        end
        Main.Position = orig
        task.wait(1)
        Btn.Text = "ĐỘT PHÁ XIỀNG XÍCH"
    end
end)

print("Kuma Demonic Immortal Loader Ready!")
