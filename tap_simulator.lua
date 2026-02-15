-- =================================================================
-- 🔴 CÀI ĐẶT QUAN TRỌNG: DÁN LINK SCRIPT CỦA BẠN VÀO DƯỚI ĐÂY
-- =================================================================
-- Bước 1: Copy toàn bộ script này, đăng lên Pastebin.com hoặc GitHub Gist.
-- Bước 2: Lấy link "Raw" (Ví dụ: https://pastebin.com/raw/AbCdEfGh).
-- Bước 3: Dán link đó vào giữa dấu ngoặc kép bên dưới.

getgenv().ScriptURL = "https://raw.githubusercontent.com/kuma152001/Kuma_hub/refs/heads/main/tap_simulator.lua" 
-- (Nếu bạn để trống hoặc link sai, chức năng tự chạy lại khi Rejoin sẽ không hoạt động)

-- =================================================================
-- 1. KILL SCRIPT CŨ & ANTI-AFK
-- =================================================================
if getgenv().TapSimInstance then
    getgenv().TapSimInstance = false
    task.wait(1)
end
getgenv().TapSimInstance = true

local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- =================================================================
-- 2. HỆ THỐNG AUTO EXECUTE (QUEUE ON TELEPORT) CHUẨN
-- =================================================================
local function QueueAutoExecute()
    local url = getgenv().ScriptURL
    if not url or url == "" or url:find("user/repo") then return end -- Kiểm tra nếu chưa thay link

    local queue_code = [[
        task.wait(5) -- Đợi game load xong 5 giây
        loadstring(game:HttpGet("]] .. url .. [["))()
    ]]

    if syn and syn.queue_on_teleport then
        syn.queue_on_teleport(queue_code)
    elseif queue_on_teleport then
        queue_on_teleport(queue_code)
    end
end

-- Gọi hàm này ngay khi script chạy để đăng ký cho lần teleport sau
QueueAutoExecute()

-- =================================================================
-- 3. KHỞI TẠO RAYFIELD
-- =================================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Tap Simulator - Ultimate V6",
   LoadingTitle = "Loading Remotes...",
   LoadingSubtitle = "Auto Execute & Save Config",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TapSimV6Config",
      FileName = "UserSetting"
   },
   KeySystem = false,
})

-- =================================================================
-- 4. HỆ THỐNG TÌM REMOTE & MAP
-- =================================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local TapEvent = nil
local OpenEggFunc = nil

local function SetupRemotes()
    for _, v in pairs(ReplicatedStorage:GetChildren()) do
        if v:FindFirstChild("Events") and v:FindFirstChild("Functions") then
            local Events = v:FindFirstChild("Events")
            local Functions = v:FindFirstChild("Functions")
            TapEvent = Events:FindFirstChild("Tap") or Events:FindFirstChild("") or Events:GetChildren()[1]
            OpenEggFunc = Functions:FindFirstChild("OpenEgg")
            return true
        end
    end
    return false
end

local function GetEggList()
    local Names = {}
    local Folder = Workspace:FindFirstChild("Eggs") or Workspace:FindFirstChild("Capsules")
    if Folder then
        for _, v in pairs(Folder:GetChildren()) do
            table.insert(Names, v.Name)
        end
    else
        Names = {"Basic", "Spotted", "Forest", "Valentine Event"}
    end
    table.sort(Names)
    return Names
end

SetupRemotes()
local CurrentEggList = GetEggList()

-- =================================================================
-- 5. BIẾN GLOBAL
-- =================================================================
getgenv().AutoTapRemote = false
getgenv().AutoTapClick = false
getgenv().AutoHatch = false
getgenv().SelectedEgg = CurrentEggList[1] or "Basic"
getgenv().CustomAmount = 1
getgenv().FastMode = true
getgenv().AutoRejoin = true

-- =================================================================
-- 6. AUTO REJOIN LOGIC
-- =================================================================
task.spawn(function()
    CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == 'ErrorPrompt' and getgenv().AutoRejoin then
            Rayfield:Notify({Title = "Mất kết nối", Content = "Đang Rejoin trong 3 giây...", Duration = 3})
            
            -- Đăng ký lại auto execute trước khi teleport
            QueueAutoExecute()
            
            task.wait(3)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end)
end)

-- =================================================================
-- 7. GIAO DIỆN
-- =================================================================

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local EggTab = Window:CreateTab("Auto Egg", 4483362458)
local MiscTab = Window:CreateTab("Cài đặt", 4483362458)

-- --- TAB FARM ---
FarmTab:CreateSection("Auto Click (Chuột)")
FarmTab:CreateToggle({
   Name = "Auto Click (Safe Mode)",
   CurrentValue = false,
   Flag = "AutoClickFlag",
   Callback = function(Value)
       getgenv().AutoTapClick = Value
       task.spawn(function()
           while getgenv().AutoTapClick and getgenv().TapSimInstance do
               VirtualUser:ClickButton1(Vector2.new(960, 540))
               task.wait(0.01)
           end
       end)
   end,
})

FarmTab:CreateSection("Auto Tap (Remote)")
FarmTab:CreateToggle({
   Name = "Auto Tap (Fast Mode)",
   CurrentValue = false,
   Flag = "AutoTapRemoteFlag", 
   Callback = function(Value)
       getgenv().AutoTapRemote = Value
       task.spawn(function()
           while getgenv().AutoTapRemote and getgenv().TapSimInstance do
               if TapEvent and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                   local args = {
                       [1] = LocalPlayer.Character.HumanoidRootPart.CFrame,
                       [2] = 42.25,
                       [4] = false
                   }
                   TapEvent:FireServer(unpack(args))
               end
               task.wait() 
           end
       end)
   end,
})

-- --- TAB EGG ---
EggTab:CreateSection("Cấu hình Trứng")

EggTab:CreateDropdown({
   Name = "Chọn Trứng",
   Options = CurrentEggList,
   CurrentOption = {CurrentEggList[1] or "Basic"},
   MultipleOptions = false,
   Flag = "EggSelectFlag",
   Callback = function(Option)
       getgenv().SelectedEgg = Option[1]
   end,
})

EggTab:CreateInput({
   Name = "Số lượng mở (Custom Amount)",
   PlaceholderText = "Nhập số (VD: 3, 8)",
   NumbersOnly = true,
   RemoveTextAfterFocusLost = false,
   Flag = "AmountInputFlag",
   Callback = function(Text)
       getgenv().CustomAmount = tonumber(Text) or 1
   end,
})

EggTab:CreateToggle({
   Name = "Fast Hatch (Không Delay)",
   CurrentValue = true,
   Flag = "FastModeFlag",
   Callback = function(Value)
       getgenv().FastMode = Value
   end,
})

EggTab:CreateSection("Kích hoạt")

EggTab:CreateToggle({
   Name = "BẮT ĐẦU AUTO HATCH",
   CurrentValue = false,
   Flag = "AutoHatchFlag",
   Callback = function(Value)
       getgenv().AutoHatch = Value
       task.spawn(function()
           while getgenv().AutoHatch and getgenv().TapSimInstance do
               if OpenEggFunc then
                   local args = {
                       [1] = getgenv().SelectedEgg,
                       [2] = getgenv().CustomAmount or 1
                   }
                   if getgenv().FastMode then
                       task.spawn(function() OpenEggFunc:InvokeServer(unpack(args)) end)
                       task.wait(0.1)
                   else
                       OpenEggFunc:InvokeServer(unpack(args))
                       task.wait(0.2)
                   end
               end
               if not getgenv().FastMode then task.wait(0.5) end
           end
       end)
   end,
})

-- --- TAB MISC ---
MiscTab:CreateSection("Hệ thống")

MiscTab:CreateToggle({
   Name = "Tự động kết nối lại (Auto Rejoin)",
   CurrentValue = true,
   Flag = "AutoRejoinFlag",
   Callback = function(Value)
       getgenv().AutoRejoin = Value
   end,
})

MiscTab:CreateButton({
   Name = "Lưu Cấu Hình (Save Config)",
   Callback = function()
       Rayfield:SaveConfiguration()
       Rayfield:Notify({Title = "Saved", Content = "Đã lưu! Script sẽ tự load khi bạn vào lại.", Duration = 3})
   end,
})

Rayfield:LoadConfiguration()
