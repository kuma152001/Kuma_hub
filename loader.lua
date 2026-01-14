-- [[ CẢNH BÁO: TUYỆT ĐỐI KHÔNG PUBLIC CÔNG PHÁP MA ĐẠO NÀY ]] --
-- [[ NẾU TIẾT LỘ, TU VI SẼ BỊ PHẢN PHỆ, ACC SẼ BỊ BAN ]] --

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local KEY = "kuma1501"
local SCRIPT_URL = "https://raw.githubusercontent.com/kuma152001/Kuma_hub/main/herb.lua"

-- Dọn dẹp UI cũ
if CoreGui:FindFirstChild("KumaMaDaoUI") then CoreGui.KumaMaDaoUI:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "KumaMaDaoUI"
gui.Parent = CoreGui
gui.IgnoreGuiInset = true

-- Khung chính (Main Frame)
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = gui
Main.BackgroundColor3 = Color3.fromRGB(5, 5, 5) -- Đen sâu thẳm
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 400, 0, 260) -- Rộng hơn một chút để chứa ghi chú
Main.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 12)

-- Viền phát sáng màu Đỏ Ma Mị (Ma Dao Glow)
local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Thickness = 2.5
MainStroke.Color = Color3.fromRGB(200, 0, 0) -- Màu đỏ máu
MainStroke.Transparency = 0.3

-- Hiệu ứng Gradient xoay chậm (Ma đạo khí)
local BGGradient = Instance.new("UIGradient")
BGGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 0, 0))
})
BGGradient.Parent = Main

task.spawn(function()
    while true do
        TweenService:Create(BGGradient, TweenInfo.new(4, Enum.EasingStyle.Linear), {Rotation = 360}):Play()
        task.wait(4)
        BGGradient.Rotation = 0
    end
end)

-- Ghi chú tuyệt mật (Footer Note)
local WarningNote = Instance.new("TextLabel", Main)
WarningNote.Size = UDim2.new(1, 0, 0, 20)
WarningNote.Position = UDim2.new(0, 0, 1, -25)
WarningNote.BackgroundTransparency = 1
WarningNote.Text = "⚠️ Tuyệt đối không public công pháp ma đạo này"
WarningNote.TextColor3 = Color3.fromRGB(255, 50, 50)
WarningNote.Font = Enum.Font.GothamItalic
WarningNote.TextSize = 11
WarningNote.ZIndex = 10

-- Hiệu ứng nhấp nháy cho dòng ghi chú
task.spawn(function()
    while true do
        TweenService:Create(WarningNote, TweenInfo.new(1), {TextTransparency = 0.2}):Play()
        task.wait(1)
        TweenService:Create(WarningNote, TweenInfo.new(1), {TextTransparency = 0.8}):Play()
        task.wait(1)
    end
end)

-- Tiêu đề HUB
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 60)
Title.BackgroundTransparency = 1
Title.Text = "KUMA HUB"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 35
Title.ZIndex = 5

local SubTitle = Instance.new("TextLabel", Main)
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 55)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "DEMONIC FORBIDDEN METHOD"
SubTitle.TextColor3 = Color3.fromRGB(150, 0, 0)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 10
SubTitle.ZIndex = 5

-- Khung nhập Key
local InputContainer = Instance.new("Frame", Main)
InputContainer.Size = UDim2.new(0, 320, 0, 45)
InputContainer.Position = UDim2.new(0.5, -160, 0.45, 0)
InputContainer.BackgroundColor3 = Color3.fromRGB(15, 0, 0)
InputContainer.ZIndex = 5
Instance.new("UICorner", InputContainer).CornerRadius = UDim.new(0, 8)
local InputStroke = Instance.new("UIStroke", InputContainer)
InputStroke.Color = Color3.fromRGB(100, 0, 0)

local Box = Instance.new("TextBox", InputContainer)
Box.Size = UDim2.new(1, -20, 1, 0)
Box.Position = UDim2.new(0, 10, 0, 0)
Box.BackgroundTransparency = 1
Box.PlaceholderText = "Nhập Ma Đạo Ấn (Key)..."
Box.Text = ""
Box.TextColor3 = Color3.new(1, 1, 1)
Box.Font = Enum.Font.Gotham
Box.TextSize = 15
Box.ZIndex = 6

-- Nút Tiếp Tục
local UnlockBtn = Instance.new("TextButton", Main)
UnlockBtn.Size = UDim2.new(0, 320, 0, 45)
UnlockBtn.Position = UDim2.new(0.5, -160, 0.70, 0)
UnlockBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
UnlockBtn.Text = "KHỞI ĐỘNG CÔNG PHÁP"
UnlockBtn.TextColor3 = Color3.new(1, 1, 1)
UnlockBtn.Font = Enum.Font.GothamBold
UnlockBtn.TextSize = 14
UnlockBtn.ZIndex = 6
UnlockBtn.AutoButtonColor = false
Instance.new("UICorner", UnlockBtn).CornerRadius = UDim.new(0, 8)

-- Thanh Loading bí mật
local LoadFrame = Instance.new("Frame", Main)
LoadFrame.Size = UDim2.new(0, 320, 0, 2)
LoadFrame.Position = UDim2.new(0.5, -160, 0.90, 0)
LoadFrame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
LoadFrame.Visible = false
local LoadBar = Instance.new("Frame", LoadFrame)
LoadBar.Size = UDim2.new(0, 0, 1, 0)
LoadBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

-- Hàm Rung (Shake)
local function Shake()
    local orig = Main.Position
    for i = 1, 12 do
        Main.Position = orig + UDim2.new(0, math.random(-6,6), 0, math.random(-6,6))
        task.wait(0.01)
    end
    Main.Position = orig
end

-- Logic Nút Bấm
UnlockBtn.MouseButton1Click:Connect(function()
    if Box.Text == KEY then
        UnlockBtn.Visible = false
        InputContainer.Visible = false
        Title.Text = "THÀNH CÔNG"
        SubTitle.Text = "Đang khai mở thần thức..."
        LoadFrame.Visible = true
        
        LoadBar:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quad", 2.5)
        task.wait(2.6)
        
        gui:Destroy()
        loadstring(game:HttpGet(SCRIPT_URL .. "?t=" .. tick()))()
    else
        Shake()
        Box.Text = ""
        UnlockBtn.Text = "MA ẤN SAI LẦM!"
        task.wait(1.5)
        UnlockBtn.Text = "KHỞI ĐỘNG CÔNG PHÁP"
    end
end)

-- Hiệu ứng Hover nút
UnlockBtn.MouseEnter:Connect(function()
    TweenService:Create(UnlockBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.3), {Thickness = 4, Color = Color3.fromRGB(255, 50, 50)}):Play()
end)

UnlockBtn.MouseLeave:Connect(function()
    TweenService:Create(UnlockBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(180, 0, 0)}):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.3), {Thickness = 2.5, Color = Color3.fromRGB(200, 0, 0)}):Play()
end)

-- Hiệu ứng hiện hình
Main.Size = UDim2.new(0, 0, 0, 0)
Main:TweenSize(UDim2.new(0, 400, 0, 260), "Out", "Back", 0.8)
