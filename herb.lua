--[[ 
    V61: ORION VERSION (Dành cho máy không hiện Rayfield)
    Tối ưu hóa: Không treo máy, không crash, tự động tìm cỏ.
]]

-- Xóa UI cũ nếu có
local uiName = "Orion"
if game.CoreGui:FindFirstChild(uiName) then
    game.CoreGui[uiName]:Destroy()
end

-- Tải thư viện Orion (Link cực kỳ ổn định)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "KuMa HUB - Herb V61", HidePremium = false, SaveConfig = true, ConfigFolder = "KumaV61", IntroText = "Khởi chạy V61..."})

-- BIẾN HỆ THỐNG
local LP = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

_G.AutoHerb = false
_G.SelectedHerbs = {}
_G.TweenSpeed = 120

-- HÀM TÌM CỎ
local function GetHerbs()
    local list = {}
    -- Tìm trong thư mục Herbs hoặc quét toàn bộ Map
    local folder = workspace:FindFirstChild("Herbs")
    local source = folder and folder:GetChildren() or workspace:GetDescendants()
    
    for _, v in ipairs(source) do
        if v:IsA("ProximityPrompt") then
            local name = v.Parent.Name
            if not table.find(list, name) then
                table.insert(list, name)
            end
        end
        if #list > 100 then break end -- Giới hạn để không lag
    end
    table.sort(list)
    return list
end

-- HÀM DI CHUYỂN
local function MoveTo(targetPart)
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    -- Chống rơi bằng BodyVelocity
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Parent = hrp

    -- Noclip xuyên tường
    local nc = RunService.Stepped:Connect(function()
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)

    local targetPos = targetPart.Position + Vector3.new(0, 3, 0)
    local dist = (hrp.Position - targetPos).Magnitude
    local tween = TweenService:Create(hrp, TweenInfo.new(dist / _G.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
    
    tween:Play()
    tween.Completed:Wait()

    nc:Disconnect()
    bv:Destroy()
end

-- TABS
local Tab = Window:MakeTab({
	Name = "Auto Collect",
	Icon = "rbxassetid://4483362458",
	PremiumOnly = false
})

Tab:AddDropdown({
	Name = "Chọn loại cỏ",
	Default = "",
	Options = GetHerbs(),
	Callback = function(Value)
		_G.SelectedHerbs = {Value} -- Với Orion dùng 1 loại hoặc chỉnh lại logic
	end    
})

Tab:AddButton({
	Name = "🔄 Làm mới danh sách cỏ",
	Callback = function()
      		OrionLib:MakeNotification({Name = "Thông báo", Content = "Đang quét map...", Time = 2})
		-- (Lưu ý: Dropdown Orion không hỗ trợ Refresh trực tiếp dễ dàng, bạn chọn loại đã hiện sẵn)
	end
})

Tab:AddToggle({
	Name = "Bật Auto Nhặt Cỏ",
	Default = false,
	Callback = function(Value)
		_G.AutoHerb = Value
	end    
})

Tab:AddSlider({
	Name = "Tốc độ bay",
	Min = 50,
	Max = 300,
	Default = 120,
	Color = Color3.fromRGB(255,255,255),
	Increment = 10,
	ValueName = "Speed",
	Callback = function(Value)
		_G.TweenSpeed = Value
	end    
})

-- VÒNG LẶP CHÍNH
task.spawn(function()
    while true do
        if _G.AutoHerb and #_G.SelectedHerbs > 0 then
            pcall(function()
                local targetP, targetO
                local dist = math.huge
                local myPos = LP.Character.HumanoidRootPart.Position

                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") then
                        local obj = v.Parent
                        if obj.Name == _G.SelectedHerbs[1] then
                            local p = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                            if p then
                                local d = (p.Position - myPos).Magnitude
                                if d < dist then
                                    dist = d; targetP = v; targetO = p
                                end
                            end
                        end
                    end
                end

                if targetP and targetO then
                    MoveTo(targetO)
                    task.wait(0.2)
                    fireproximityprompt(targetP)
                    task.wait(0.3)
                end
            end)
        end
        task.wait(1)
    end
end)

OrionLib:Init()
