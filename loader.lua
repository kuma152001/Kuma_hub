-- [[ ⛩️ KUMA HUB - GATEKEEPER SYSTEM (V2.2 STYLE) ⛩️ ]] --
-- [[ Đồng bộ giao diện + Lưu Key 24h ]] --

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- ==============================================================================
-- 0. CẤU HÌNH & LOGIC LƯU KEY
-- ==============================================================================
local CORRECT_KEY = "kuma1501" -- Key của bạn
local SCRIPT_URL = "https://raw.githubusercontent.com/kuma152001/Kuma_hub/main/herb.lua"
local KEY_FILE = "KumaHub_License_V2.json"
local ONE_DAY_SECONDS = 86400 -- 24 giờ

-- Hàm load Hub chính
local function LoadMainHub()
    loadstring(game:HttpGet(SCRIPT_URL .. "?t=" .. tostring(os.time())))()
end

-- Kiểm tra xem Key cũ còn hạn không
local function CheckSavedKey()
    if isfile(KEY_FILE) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(KEY_FILE))
        end)
        
        if success and result then
            local savedKey = result.Key
            local savedTime = result.Time
            local currentTime = os.time()
            
            -- Nếu Key đúng VÀ chưa quá 24h
            if savedKey == CORRECT_KEY and (currentTime - savedTime) < ONE_DAY_SECONDS then
                return true
            end
        end
    end
    return false
end

-- Lưu Key mới vào file
local function SaveKeyData()
    local data = {
        Key = CORRECT_KEY,
        Time = os.time()
    }
    writefile(KEY_FILE, HttpService:JSONEncode(data))
end

-- ==============================================================================
-- 1. KIỂM TRA TỰ ĐỘNG (AUTO LOGIN)
-- ==============================================================================
if CheckSavedKey() then
    -- Tạo một thông báo nhỏ trước khi vào thẳng
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCore("SendNotification", {
        Title = "Kuma Hub Security",
        Text = "Linh Ấn cũ vẫn còn hiệu lực. Đang vào...",
        Duration = 3
    })
    LoadMainHub()
    return -- Dừng script Key System tại đây, không hiện GUI
end

-- ==============================================================================
-- 2. GIAO DIỆN NHẬP KEY (NẾU CHƯA CÓ KEY)
-- ==============================================================================

-- Xóa GUI cũ
if CoreGui:FindFirstChild("KumaGatekeeper") then CoreGui.KumaGatekeeper:Destroy() end

local Screen = Instance.new("ScreenGui")
Screen.Name = "KumaGatekeeper"
Screen.Parent = CoreGui
Screen.IgnoreGuiInset = true
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Nhận diện Mobile để chỉnh size
local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local Scale = IsMobile and 1.0 or 1.2

-- Khung Chính (Main Frame)
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 450 * Scale, 0, 300 * Scale)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25) -- Màu nền tối giống Hub chính
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = Screen

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(255, 140, 0) -- Màu Cam đặc trưng
MainStroke.Thickness = 2
MainStroke.Transparency = 0.5

-- [[ VISUAL: HIỆU ỨNG TRẬN PHÁP NỀN ]] --
local MagicCircle = Instance.new("ImageLabel")
MagicCircle.Name = "BgCircle"
MagicCircle.Parent = Main
MagicCircle.BackgroundTransparency = 1
MagicCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
MagicCircle.AnchorPoint = Vector2.new(0.5, 0.5)
MagicCircle.Size = UDim2.new(1.2, 0, 1.8, 0) -- To hơn khung
MagicCircle.Image = "rbxassetid://18274441091" -- ID Trận pháp giống Hub chính
MagicCircle.ImageColor3 = Color3.fromRGB(255, 100, 0)
MagicCircle.ImageTransparency = 0.85
MagicCircle.ScaleType = Enum.ScaleType.Fit

-- Xoay trận pháp
local TweenRot = TweenService:Create(MagicCircle, TweenInfo.new(25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
TweenRot:Play()

-- Tiêu đề
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.Text = "HỘ PHÁP TRẬN"
Title.Size = UDim2.new(1, 0, 0, 50 * Scale)
Title.Position = UDim2.new(0, 0, 0.1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 160, 0)
Title.Font = Enum.Font.FredokaOne
Title.TextSize = 26 * Scale
Title.TextStrokeTransparency = 0.8

local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = Main
SubTitle.Text = "Vui lòng nhập Linh Ấn để đột phá"
SubTitle.Size = UDim2.new(1, 0, 0, 20 * Scale)
SubTitle.Position = UDim2.new(0, 0, 0.25, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 14 * Scale

-- Khung chứa Input
local InputContainer = Instance.new("Frame")
InputContainer.Size = UDim2.new(0.8, 0, 0, 45 * Scale)
InputContainer.Position = UDim2.new(0.5, 0, 0.45, 0)
InputContainer.AnchorPoint = Vector2.new(0.5, 0.5)
InputContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
InputContainer.Parent = Main
Instance.new("UICorner", InputContainer).CornerRadius = UDim.new(0, 6)
local InputStroke = Instance.new("UIStroke", InputContainer)
InputStroke.Color = Color3.fromRGB(60, 60, 60)
InputStroke.Thickness = 1

local KeyBox = Instance.new("TextBox")
KeyBox.Parent = InputContainer
KeyBox.Size = UDim2.new(1, -20, 1, 0)
KeyBox.Position = UDim2.new(0, 10, 0, 0)
KeyBox.BackgroundTransparency = 1
KeyBox.PlaceholderText = "Nhập Key tại đây..."
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
KeyBox.Font = Enum.Font.GothamBold
KeyBox.TextSize = 14 * Scale
KeyBox.TextXAlignment = Enum.TextXAlignment.Center

-- Nút Xác Nhận
local EnterBtn = Instance.new("TextButton")
EnterBtn.Parent = Main
EnterBtn.Text = "KHAI MỞ (ENTER)"
EnterBtn.Size = UDim2.new(0.6, 0, 0, 45 * Scale)
EnterBtn.Position = UDim2.new(0.5, 0, 0.75, 0)
EnterBtn.AnchorPoint = Vector2.new(0.5, 0.5)
EnterBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
EnterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EnterBtn.Font = Enum.Font.FredokaOne
EnterBtn.TextSize = 18 * Scale
EnterBtn.AutoButtonColor = true
Instance.new("UICorner", EnterBtn).CornerRadius = UDim.new(0, 8)

-- Hiệu ứng Glow cho nút
local BtnGlow = Instance.new("UIStroke", EnterBtn)
BtnGlow.Color = Color3.fromRGB(255, 160, 50)
BtnGlow.Thickness = 2
BtnGlow.Transparency = 0.5
task.spawn(function()
    while EnterBtn and EnterBtn.Parent do
        TweenService:Create(BtnGlow, TweenInfo.new(1), {Transparency = 0}):Play()
        task.wait(1)
        TweenService:Create(BtnGlow, TweenInfo.new(1), {Transparency = 0.8}):Play()
        task.wait(1)
    end
end)

-- Nút lấy Key (Link)
local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Parent = Main
GetKeyBtn.Text = "Chưa có Linh Ấn? Bấm để lấy"
GetKeyBtn.Size = UDim2.new(1, 0, 0, 20 * Scale)
GetKeyBtn.Position = UDim2.new(0, 0, 0.9, 0)
GetKeyBtn.BackgroundTransparency = 1
GetKeyBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
GetKeyBtn.Font = Enum.Font.Gotham
GetKeyBtn.TextSize = 12 * Scale

-- LOGIC XỬ LÝ
local Processing = false

local function ShakeUI()
    local origin = Main.Position
    for i = 1, 10 do
        Main.Position = origin + UDim2.new(0, math.random(-5, 5), 0, math.random(-5, 5))
        task.wait(0.03)
    end
    Main.Position = origin
end

local function OnSubmit()
    if Processing then return end
    Processing = true
    
    local input = KeyBox.Text
    -- Xóa khoảng trắng thừa
    input = input:gsub("^%s*(.-)%s*$", "%1")
    
    if input == CORRECT_KEY then
        -- HIỆU ỨNG THÀNH CÔNG
        EnterBtn.Text = "ĐỘT PHÁ THÀNH CÔNG!"
        EnterBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        TweenService:Create(MainStroke, TweenInfo.new(0.5), {Color = Color3.fromRGB(0, 255, 100)}):Play()
        
        -- Lưu Key
        SaveKeyData()
        
        task.wait(1)
        
        -- Biến mất UI
        TweenService:Create(Main, TweenInfo.new(0.5), {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        Screen:Destroy()
        
        -- Load Hub
        LoadMainHub()
    else
        -- HIỆU ỨNG THẤT BẠI
        EnterBtn.Text = "LINH ẤN SAI LẦM!"
        EnterBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ShakeUI()
        task.wait(1)
        EnterBtn.Text = "KHAI MỞ (ENTER)"
        EnterBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        Processing = false
    end
end

EnterBtn.MouseButton1Click:Connect(OnSubmit)
GetKeyBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/kuma1501") -- Link Discord ví dụ
    GetKeyBtn.Text = "Đã copy Link Discord!"
    task.wait(2)
    GetKeyBtn.Text = "Chưa có Linh Ấn? Bấm để lấy"
end)

-- Hiệu ứng kéo thả UI (Draggable)
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
