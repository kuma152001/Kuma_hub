--[[
    🐻 KUMA HUB - GOD MODE EDITION 🐻
    Phiên bản: Universal V2 (Max Features)
    Hỗ trợ: PC & Mobile (Solara, Delta, Fluxus, Hydrogen...)
    Ngôn ngữ: Tiếng Việt
]]

-- =========================================================
-- 1. KHỞI TẠO HỆ THỐNG & BIẾN
-- =========================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Biến Global quản lý trạng thái
getgenv().KumaConfig = {
    Speed = 16,
    Jump = 50,
    Fly = false,
    FlySpeed = 20,
    Noclip = false,
    InfJump = false,
    SpinBot = false,
    Fling = false,
    
    Aimbot = false,
    AimbotRadius = 150,
    AimbotTeamCheck = false,
    
    ESP = false,
    Hitbox = false,
    HitboxSize = 5,
    Fullbright = false,
    FOV = 70,
    
    SpectateTarget = nil
}

-- Hàm lấy danh sách người chơi
local PlayerList = {}
local function UpdatePlayerList()
    PlayerList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(PlayerList, p.Name) end
    end
end
UpdatePlayerList()

-- =========================================================
-- 2. GIAO DIỆN RAYFIELD (THEME KUMA)
-- =========================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🐻 KUMA HUB - UNIVERSAL",
   LoadingTitle = "Đang khởi động...",
   LoadingSubtitle = "Script by Kuma Team",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

-- =========================================================
-- TAB 1: MOVEMENT (BAY & CHẠY)
-- =========================================================
local TabMove = Window:CreateTab("🏃 Di Chuyển", 4483362458)

TabMove:CreateSection("✈️ Hệ thống Bay (Fly V3)")

TabMove:CreateToggle({
   Name = "Kích hoạt Bay (Fly)",
   CurrentValue = false,
   Callback = function(Value)
       getgenv().KumaConfig.Fly = Value
       if Value then
           -- Logic Fly
           local bv = Instance.new("BodyVelocity")
           bv.Name = "KumaFly"
           bv.MaxForce = Vector3.new(100000, 100000, 100000)
           
           if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
               bv.Parent = LocalPlayer.Character.HumanoidRootPart
           end
           
           task.spawn(function()
               while getgenv().KumaConfig.Fly and LocalPlayer.Character do
                   local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                   local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                   local cam = Workspace.CurrentCamera
                   
                   if hrp and hum and bv.Parent == hrp then
                       bv.Velocity = Vector3.new(0,0,0)
                       if hum.MoveDirection.Magnitude > 0 then
                           bv.Velocity = hum.MoveDirection * getgenv().KumaConfig.FlySpeed * 5
                       else
                           bv.Velocity = Vector3.new(0, 0, 0)
                       end
                       -- Giữ độ cao nếu không di chuyển
                       if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                           bv.Velocity = bv.Velocity + Vector3.new(0, getgenv().KumaConfig.FlySpeed * 2, 0)
                       elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                           bv.Velocity = bv.Velocity - Vector3.new(0, getgenv().KumaConfig.FlySpeed * 2, 0)
                       end
                   end
                   task.wait()
               end
               bv:Destroy()
           end)
       else
           if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
               local old = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("KumaFly")
               if old then old:Destroy() end
           end
       end
   end,
})

TabMove:CreateSlider({
   Name = "Tốc độ Bay",
   Range = {10, 100},
   Increment = 1,
   CurrentValue = 20,
   Callback = function(Value) getgenv().KumaConfig.FlySpeed = Value end,
})

TabMove:CreateSection("⚡ Tốc độ & Troll")

TabMove:CreateToggle({
   Name = "Bật Speed Hack",
   CurrentValue = false,
   Callback = function(Value)
       getgenv().KumaConfig.EnableSpeed = Value
       -- Speed Loop
       task.spawn(function()
           while getgenv().KumaConfig.EnableSpeed do
               if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                   LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().KumaConfig.Speed
               end
               task.wait()
           end
       end)
   end,
})

TabMove:CreateSlider({
   Name = "Chỉnh Speed",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value) getgenv().KumaConfig.Speed = Value end,
})

TabMove:CreateToggle({
   Name = "🌀 SpinBot (Xoay cực nhanh)",
   CurrentValue = false,
   Callback = function(Value)
       getgenv().KumaConfig.SpinBot = Value
       if Value then
           local bg = Instance.new("BodyAngularVelocity")
           bg.Name = "KumaSpin"
           bg.MaxTorque = Vector3.new(0, math.huge, 0)
           bg.AngularVelocity = Vector3.new(0, 50, 0)
           if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
               bg.Parent = LocalPlayer.Character.HumanoidRootPart
           end
       else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
               local old = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("KumaSpin")
               if old then old:Destroy() end
           end
       end
   end,
})

TabMove:CreateToggle({
   Name = "🌪️ Fling (Hất văng người khác)",
   CurrentValue = false,
   Callback = function(Value)
       getgenv().KumaConfig.Fling = Value
       if Value then
           task.spawn(function()
               local NoclipLoop = RunService.Stepped:Connect(function()
                   if getgenv().KumaConfig.Fling and LocalPlayer.Character then
                       for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                           if v:IsA("BasePart") then v.CanCollide = false end
                       end
                   end
               end)
               
               local bambam = Instance.new("BodyAngularVelocity")
               bambam.Name = "KumaFling"
               bambam.Parent = LocalPlayer.Character.HumanoidRootPart
               bambam.AngularVelocity = Vector3.new(0,99999,0)
               bambam.MaxTorque = Vector3.new(0,math.huge,0)
               bambam.P = math.huge
               
               while getgenv().KumaConfig.Fling and LocalPlayer.Character do
                   bambam.AngularVelocity = Vector3.new(0,99999,0)
                   LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0) -- Giữ vị trí để dễ điều khiển
                   task.wait(0.1)
               end
               if NoclipLoop then NoclipLoop:Disconnect() end
               bambam:Destroy()
           end)
       end
   end,
})

-- Các chức năng cơ bản khác
TabMove:CreateToggle({ Name = "Nhảy liên tục (Inf Jump)", CurrentValue = false, Callback = function(V) getgenv().KumaConfig.InfJump = V end})
TabMove:CreateToggle({ Name = "Đi xuyên tường (Noclip)", CurrentValue = false, Callback = function(V) getgenv().KumaConfig.Noclip = V end})

-- Logic Noclip & InfJump
RunService.Stepped:Connect(function()
    if getgenv().KumaConfig.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)
UserInputService.JumpRequest:Connect(function()
    if getgenv().KumaConfig.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
    end
end)


-- =========================================================
-- TAB 2: COMBAT (AIMBOT & HITBOX)
-- =========================================================
local TabCombat = Window:CreateTab("⚔️ Chiến Đấu", 4483362458)

TabCombat:CreateSection("🎯 Hỗ trợ ngắm (Aimbot)")

TabCombat:CreateToggle({
   Name = "🔫 Aimbot (Khóa Camera)",
   CurrentValue = false,
   Callback = function(Value) getgenv().KumaConfig.Aimbot = Value end,
})

TabCombat:CreateToggle({
   Name = "Bỏ qua đồng đội (Team Check)",
   CurrentValue = false,
   Callback = function(Value) getgenv().KumaConfig.AimbotTeamCheck = Value end,
})

-- Logic Aimbot
local function GetClosestPlayer()
    local target = nil
    local dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            -- Team Check
            if getgenv().KumaConfig.AimbotTeamCheck and v.Team == LocalPlayer.Team then
                continue 
            end
            
            local screenPoint = Camera:WorldToScreenPoint(v.Character.Head.Position)
            local vector, onScreen = Camera:WorldToScreenPoint(v.Character.Head.Position)
            
            if onScreen then
                local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(vector.X, vector.Y)).Magnitude
                if mag < dist and mag < getgenv().KumaConfig.AimbotRadius then
                    target = v
                    dist = mag
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if getgenv().KumaConfig.Aimbot then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

TabCombat:CreateSection("🥊 Hitbox (Đánh bao trúng)")

TabCombat:CreateToggle({
   Name = "Bật Hitbox Expander",
   CurrentValue = false,
   Callback = function(Value)
       getgenv().KumaConfig.Hitbox = Value
       if not Value then
           for _, plr in pairs(Players:GetPlayers()) do
               if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                   plr.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                   plr.Character.HumanoidRootPart.Transparency = 1
               end
           end
       end
   end,
})

TabCombat:CreateSlider({
   Name = "Độ rộng Hitbox",
   Range = {2, 30},
   Increment = 1,
   CurrentValue = 5,
   Callback = function(Value) getgenv().KumaConfig.HitboxSize = Value end,
})

-- Loop Hitbox
RunService.RenderStepped:Connect(function()
    if getgenv().KumaConfig.Hitbox then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    local hrp = plr.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(getgenv().KumaConfig.HitboxSize, getgenv().KumaConfig.HitboxSize, getgenv().KumaConfig.HitboxSize)
                    hrp.Transparency = 0.7
                    hrp.BrickColor = BrickColor.new("Really red")
                    hrp.Material = "Neon"
                    hrp.CanCollide = false
                end)
            end
        end
    end
end)

-- =========================================================
-- TAB 3: VISUALS (ESP & CAMERA)
-- =========================================================
local TabVisual = Window:CreateTab("👁️ Visuals", 4483362458)

local ESP_Folder = Instance.new("Folder", game.CoreGui)
ESP_Folder.Name = "KumaESP"

local function UpdateESP()
    ESP_Folder:ClearAllChildren()
    if getgenv().KumaConfig.ESP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hl = Instance.new("Highlight")
                hl.Adornee = plr.Character
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.5
                hl.Parent = ESP_Folder
            end
        end
    end
end

TabVisual:CreateToggle({
   Name = "🟥 ESP Player (Nhìn xuyên tường)",
   CurrentValue = false,
   Callback = function(Value)
       getgenv().KumaConfig.ESP = Value
       if Value then 
           RunService:BindToRenderStep("KumaESP", 1, UpdateESP)
       else
           RunService:UnbindFromRenderStep("KumaESP")
           ESP_Folder:ClearAllChildren()
       end
   end,
})

TabVisual:CreateSlider({
   Name = "🎥 FOV (Góc nhìn)",
   Range = {70, 120},
   Increment = 1,
   CurrentValue = 70,
   Callback = function(Value)
       Camera.FieldOfView = Value
   end,
})

TabVisual:CreateToggle({
   Name = "💡 Fullbright (Sáng max)",
   CurrentValue = false,
   Callback = function(Value)
       if Value then
           Lighting.Brightness = 2
           Lighting.ClockTime = 14
           Lighting.FogEnd = 100000
           Lighting.GlobalShadows = false
       else
           Lighting.Brightness = 1
           Lighting.GlobalShadows = true
       end
   end,
})

-- =========================================================
-- TAB 4: TELEPORT (NÂNG CẤP: WAYPOINTS & AUTO TP)
-- =========================================================
local TabTP = Window:CreateTab("🚀 Teleport", 4483362458)

-- Biến quản lý Waypoints
getgenv().KumaWaypoints = {}
local WaypointList = {}
local SelectedWaypoint = nil
local WaypointName = "Điểm 1"
getgenv().AutoTPActive = false
getgenv().AutoTPDelay = 5

-- Hàm cập nhật danh sách Dropdown
local function UpdateWaypointDropdown()
    WaypointList = {}
    for name, _ in pairs(getgenv().KumaWaypoints) do
        table.insert(WaypointList, name)
    end
    if #WaypointList == 0 then table.insert(WaypointList, "Chưa có điểm lưu") end
end

TabTP:CreateSection("📍 Quản lý tọa độ (Waypoints)")

TabTP:CreateInput({
   Name = "Tên điểm muốn lưu",
   PlaceholderText = "Nhập tên điểm...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       WaypointName = Text
   end,
})

local WPDropdown -- Khai báo trước để Refresh

TabTP:CreateButton({
   Name = "💾 Lưu vị trí hiện tại",
   Callback = function()
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
           local currentCF = LocalPlayer.Character.HumanoidRootPart.CFrame
           getgenv().KumaWaypoints[WaypointName] = currentCF
           
           UpdateWaypointDropdown()
           WPDropdown:Refresh(WaypointList)
           
           Rayfield:Notify({Title = "Kuma Hub", Content = "Đã lưu: " .. WaypointName, Duration = 2})
       end
   end,
})

WPDropdown = TabTP:CreateDropdown({
   Name = "Danh sách điểm đã lưu",
   Options = {"Chưa có điểm lưu"},
   CurrentOption = {""},
   MultipleOptions = false,
   Callback = function(Option)
       SelectedWaypoint = Option[1]
   end,
})

TabTP:CreateButton({
   Name = "🌀 Teleport tới điểm đã chọn",
   Callback = function()
       if SelectedWaypoint and getgenv().KumaWaypoints[SelectedWaypoint] then
           LocalPlayer.Character.HumanoidRootPart.CFrame = getgenv().KumaWaypoints[SelectedWaypoint]
       else
           Rayfield:Notify({Title = "Lỗi", Content = "Vui lòng chọn 1 điểm hợp lệ!", Duration = 2})
       end
   end,
})

TabTP:CreateButton({
   Name = "🗑️ Xóa điểm đã chọn",
   Callback = function()
       if SelectedWaypoint then
           getgenv().KumaWaypoints[SelectedWaypoint] = nil
           UpdateWaypointDropdown()
           WPDropdown:Refresh(WaypointList)
           Rayfield:Notify({Title = "Kuma Hub", Content = "Đã xóa điểm!", Duration = 2})
       end
   end,
})

TabTP:CreateSection("🔄 Auto Teleport Loop")

TabTP:CreateToggle({
   Name = "Kích hoạt Auto Tele (Vòng lặp)",
   CurrentValue = false,
   Callback = function(Value)
       getgenv().AutoTPActive = Value
       if Value then
           task.spawn(function()
               while getgenv().AutoTPActive do
                   local hasPoints = false
                   for name, cf in pairs(getgenv().KumaWaypoints) do
                       if not getgenv().AutoTPActive then break end
                       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                           LocalPlayer.Character.HumanoidRootPart.CFrame = cf
                           Rayfield:Notify({Title = "Auto TP", Content = "Đang tới: " .. name, Duration = 1})
                           hasPoints = true
                       end
                       task.wait(getgenv().AutoTPDelay)
                   end
                   if not hasPoints then 
                       Rayfield:Notify({Title = "Lỗi", Content = "Không có điểm nào để Auto TP!", Duration = 2})
                       getgenv().AutoTPActive = false
                       break 
                   end
                   task.wait(0.1)
               end
           end)
       end
   end,
})

TabTP:CreateSlider({
   Name = "Thời gian chờ (giây)",
   Range = {1, 60},
   Increment = 1,
   CurrentValue = 5,
   Callback = function(Value)
       getgenv().AutoTPDelay = Value
   end,
})

TabTP:CreateSection("👥 Teleport tới người chơi")

-- (Giữ nguyên phần chọn người chơi cũ của bạn ở đây)
local SelTP = nil
local TPDrop = TabTP:CreateDropdown({
   Name = "Chọn người chơi",
   Options = PlayerList,
   CurrentOption = "",
   Callback = function(Option) SelTP = Option[1] end,
})

TabTP:CreateButton({
   Name = "Bay tới người chơi",
   Callback = function()
       if SelTP then
           local t = Players:FindFirstChild(SelTP)
           if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
               LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame
           end
       end
   end,
})

TabTP:CreateButton({
   Name = "🔄 Làm mới danh sách Player",
   Callback = function() UpdatePlayerList() TPDrop:Refresh(PlayerList) end,
})

-- =========================================================
-- TAB 5: HỆ THỐNG
-- =========================================================
local TabSys = Window:CreateTab("⚙️ Hệ Thống", 4483362458)

TabSys:CreateButton({
   Name = "🚀 Tối ưu hóa FPS (Giảm lag)",
   Callback = function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
            if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end
        Rayfield:Notify({Title = "Kuma Hub", Content = "Đã giảm đồ họa để mượt hơn!", Duration = 2})
   end,
})

TabSys:CreateButton({
   Name = "🔄 Rejoin Server (Vào lại)",
   Callback = function()
       game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
   end,
})

Rayfield:LoadConfiguration()
