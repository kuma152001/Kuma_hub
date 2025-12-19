--==============================================================
--  HERB COLLECTOR V63 (SIÊU ĐƠN GIẢN - TỰ ĐỘNG 100%)
--==============================================================

print("--- KUMA HUB V63 STARTING ---")

local LP = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Hàm thông báo lên màn hình (Dùng hệ thống mặc định của Roblox)
local function Notify(msg)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Kuma Hub V63",
        Text = msg,
        Duration = 5
    })
    print("[DEBUG]: " .. msg)
end

Notify("Script đang khởi động... Đợi 3 giây")
task.wait(3)

-- 1. TẠO NÚT BẬT/TẮT SIÊU NHỎ (Để chắc chắn hiện được)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KumaSimpleUI"
-- Thử parent vào PlayerGui nếu CoreGui lỗi
local successUI, errUI = pcall(function()
    ScreenGui.Parent = LP:WaitForChild("PlayerGui")
end)

local MainBtn = Instance.new("TextButton")
MainBtn.Size = UDim2.new(0, 150, 0, 50)
MainBtn.Position = UDim2.new(0.5, -75, 0, 50) -- Nằm chính giữa phía trên
MainBtn.Text = "BẮT ĐẦU NHẶT (OFF)"
MainBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
MainBtn.Parent = ScreenGui

local Running = false
local Speed = 100

-- 2. HỆ THỐNG DI CHUYỂN
local function MoveTo(targetPart)
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Parent = hrp

    -- Noclip xuyên tường
    local nc = RunService.Stepped:Connect(function()
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)

    local targetPos = targetPart.Position
    local dist = (hrp.Position - targetPos).Magnitude
    local tween = TweenService:Create(hrp, TweenInfo.new(dist/Speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos + Vector3.new(0,2,0))})
    
    tween:Play()
    tween.Completed:Wait()
    
    nc:Disconnect()
    bv:Destroy()
end

-- 3. LOGIC NHẶT MỌI THỨ
MainBtn.MouseButton1Click:Connect(function()
    Running = not Running
    if Running then
        MainBtn.Text = "ĐANG NHẶT (ON)"
        MainBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        Notify("Đã BẬT: Đang quét vật phẩm quanh đây...")
    else
        MainBtn.Text = "BẮT ĐẦU NHẶT (OFF)"
        MainBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        Notify("Đã TẮT.")
    end
end)

task.spawn(function()
    while true do
        if Running then
            pcall(function()
                local char = LP.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                
                local targetP = nil
                local targetO = nil
                local minDist = 1000 -- Chỉ nhặt trong bán kính 1000 studs

                -- Quét mọi ProximityPrompt có trên map
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") then
                        local obj = v.Parent
                        local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                        
                        if part then
                            local d = (part.Position - char.HumanoidRootPart.Position).Magnitude
                            if d < minDist then
                                minDist = d
                                targetP = v
                                targetO = part
                            end
                        end
                    end
                end

                if targetP and targetO then
                    Notify("Tìm thấy: " .. targetO.Name .. ". Đang bay tới!")
                    MoveTo(targetO)
                    task.wait(0.3)
                    fireproximityprompt(targetP)
                    task.wait(0.5)
                end
            end)
        end
        task.wait(1)
    end
end)
