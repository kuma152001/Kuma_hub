--==============================================================
--  HERB COLLECTOR V62 (KHÔNG THƯ VIỆN - CHỐNG LỖI UI)
--==============================================================

local LP = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Xóa UI cũ nếu có
if game.CoreGui:FindFirstChild("KumaHerbUI") then game.CoreGui.KumaHerbUI:Destroy() end

-- [1] TẠO GIAO DIỆN GỐC (KHÔNG DÙNG THƯ VIỆN NGOÀI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KumaHerbUI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true -- Có thể kéo di chuyển menu
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "KUMA HUB V62"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Parent = MainFrame

-- Ô nhập tên cỏ
local Input = Instance.new("TextBox")
Input.Size = UDim2.new(0.9, 0, 0, 40)
Input.Position = UDim2.new(0.05, 0, 0.2, 0)
Input.PlaceholderText = "Nhập tên cỏ (VD: Green Lotus)"
Input.Text = ""
Input.Parent = MainFrame

-- Nút Bật/Tắt
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 50)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleBtn.Text = "AUTO: OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ToggleBtn.Parent = MainFrame

-- Nút Quét ESP (Để kiểm tra xem game có cỏ không)
local ESPBtn = Instance.new("TextButton")
ESPBtn.Size = UDim2.new(0.9, 0, 0, 50)
ESPBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
ESPBtn.Text = "HIỆN KHUNG CỎ (ESP)"
ESPBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
ESPBtn.Parent = MainFrame

-- [2] BIẾN ĐIỀU KHIỂN
local AutoEnabled = false
local TargetName = ""
local Speed = 120

ToggleBtn.MouseButton1Click:Connect(function()
    AutoEnabled = not AutoEnabled
    TargetName = Input.Text
    ToggleBtn.Text = AutoEnabled and "AUTO: ON" or "AUTO: OFF"
    ToggleBtn.BackgroundColor3 = AutoEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

-- [3] HỆ THỐNG DI CHUYỂN
local function MoveTo(targetPart)
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Parent = hrp

    local dist = (hrp.Position - targetPart.Position).Magnitude
    local tween = TweenService:Create(hrp, TweenInfo.new(dist/Speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPart.Position + Vector3.new(0,3,0))})
    
    tween:Play()
    tween.Completed:Wait()
    bv:Destroy()
end

-- [4] VÒNG LẶP CHÍNH
task.spawn(function()
    while true do
        if AutoEnabled and TargetName ~= "" then
            pcall(function()
                local closest = nil
                local dist = math.huge
                
                -- Quét toàn bộ map tìm ProximityPrompt có tên khớp
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") then
                        local obj = v.Parent
                        if string.find(obj.Name:lower(), TargetName:lower()) then
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                            if part then
                                local d = (part.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                                if d < dist then
                                    dist = d
                                    closest = {p = v, o = part}
                                end
                            end
                        end
                    end
                end

                if closest then
                    print("Tìm thấy cỏ, đang bay tới...")
                    MoveTo(closest.o)
                    task.wait(0.2)
                    fireproximityprompt(closest.p)
                    task.wait(0.5)
                else
                    print("Không tìm thấy cỏ nào tên: " .. TargetName)
                end
            end)
        end
        task.wait(1)
    end
end)

-- [5] HỆ THỐNG ESP (HIỆN KHUNG ĐỂ BIẾT CỎ Ở ĐÂU)
ESPBtn.MouseButton1Click:Connect(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local obj = v.Parent
            if not obj:FindFirstChild("HerbHighlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "HerbHighlight"
                hl.FillColor = Color3.new(0, 1, 0)
                hl.Parent = obj
                
                local bg = Instance.new("BillboardGui")
                bg.Size = UDim2.new(0, 100, 0, 20)
                bg.AlwaysOnTop = true
                bg.Parent = obj
                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(1,0,1,0)
                tl.Text = obj.Name
                tl.TextColor3 = Color3.new(1,1,1)
                tl.BackgroundTransparency = 1
                tl.Parent = bg
            end
        end
    end
end)
