--- START OF FILE KUMA HUB V3.1 - ULTRA OPTIMIZED ---

--[[ 
    🐻 KUMA HUB - CULTIVATION V3.1 (ULTRA OPTIMIZED) 🐻
    ---------------------------------------------------
    Phiên bản: V3.1 (PC/Mobile - Siêu nhẹ)
    Trạng thái: GIỮ NGUYÊN TÍNH NĂNG - TỐI ƯU SÂU RAM/GPU
]]

-- ==============================================================================
-- 0. KHỞI TẠO & DỊCH VỤ
-- ==============================================================================
local ScriptID = tick()
_G.KumaInstanceID = ScriptID

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local RE = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")
local VU = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local LP = Players.LocalPlayer
local IsMobile = UIS.TouchEnabled and not UIS.MouseEnabled
local SizeScale = IsMobile and 1.0 or 1.25 

-- Các hàm toán học/bảng tối ưu
local Vector3_new = Vector3.new
local Vector2_new = Vector2.new
local CFrame_new = CFrame.new
local UDim2_new = UDim2.new
local UDim_new = UDim.new
local Color3_fromRGB = Color3.fromRGB
local task_wait = task.wait
local task_spawn = task.spawn
local table_insert = table.insert
local table_remove = table.remove
local table_clear = table.clear
local math_floor = math.floor
local math_min = math.min
local pcall_func = pcall

local function IsAlive() 
    return _G.KumaInstanceID == ScriptID 
end

-- Dọn dẹp tài nguyên cũ để tránh tràn RAM khi thực thi lại script
pcall_func(function()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name:find("Kuma") or v.Name:find("Rayfield") or v.Name == "KumaMobileButton" then 
            v:Destroy() 
        end
    end
    local oldPlat = WS:FindFirstChild("Kuma_Platform")
    if oldPlat then oldPlat:Destroy() end
end)

task_spawn(function()
    repeat task_wait() until game:IsLoaded()

    -- ==============================================================================
    -- 1. BỘ THƯ VIỆN GUI (BUILDER) - GIỮ NGUYÊN CẤU TRÚC GỐC
    -- ==============================================================================
    local KumaUI = {}
    local KumaMainFrame = nil 
    local CurrentToggleKey = Enum.KeyCode.RightControl

    local function Create(className, properties, children)
        local obj = Instance.new(className)
        for k, v in pairs(properties or {}) do obj[k] = v end
        if children then for _, child in ipairs(children) do child.Parent = obj end end
        return obj
    end

    function KumaUI:CreateWindow(Settings)
        local Screen = Create("ScreenGui", {Name = "KumaHub_V3_Expanded", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
        
        UIS.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == CurrentToggleKey and KumaMainFrame then
                KumaMainFrame.Visible = not KumaMainFrame.Visible 
            end
        end)

        local Main = Create("Frame", {
            Name = "MainFrame", Size = UDim2_new(0.6, 0, 0.55, 0), Position = UDim2_new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2_new(0.5, 0.5), BackgroundColor3 = Color3_fromRGB(20, 20, 25),
            BorderSizePixel = 0, Active = true, Draggable = true, Parent = Screen, ClipsDescendants = true
        }, {
            Create("UISizeConstraint", {MinSize = IsMobile and Vector2_new(400, 280) or Vector2_new(550, 350)}),
            Create("UIStroke", {Color = Color3_fromRGB(255, 140, 0), Thickness = 2}),
            Create("UICorner", {CornerRadius = UDim_new(0, 8)})
        })
        KumaMainFrame = Main

        local MagicCircle = Create("ImageLabel", {
            Name = "CultivationBg", Parent = Main, BackgroundTransparency = 1, Position = UDim2_new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2_new(0.5, 0.5), Size = UDim2_new(0.8, 0, 1.4, 0),
            Image = "rbxassetid://18274441091", ImageColor3 = Color3_fromRGB(255, 140, 0), ImageTransparency = 0.92, ScaleType = Enum.ScaleType.Fit
        })
        TS:Create(MagicCircle, TweenInfo.new(20, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360}):Play()

        Create("TextLabel", {
            Text = Settings.Name, Size = UDim2_new(1, 0, 0, 35 * SizeScale), Position = UDim2_new(0, 0, 0, 5),
            BackgroundTransparency = 1, TextColor3 = Color3_fromRGB(255, 140, 0), Font = Enum.Font.FredokaOne,
            TextSize = 24 * SizeScale, TextXAlignment = Enum.TextXAlignment.Center, Parent = Main
        })

        local TabContainer = Create("ScrollingFrame", {
            Name = "TabContainer", Size = UDim2_new(1, -20, 0, 35 * SizeScale), Position = UDim2_new(0, 10, 0, 45 * SizeScale),
            BackgroundTransparency = 1, ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.X, CanvasSize = UDim2_new(0, 0, 0, 0), Parent = Main
        }, {
            Create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim_new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder})
        })

        local ContentContainer = Create("Frame", {
            Name = "Content", Size = UDim2_new(1, -20, 1, -(55 * SizeScale)), Position = UDim2_new(0, 10, 0, 85 * SizeScale),
            BackgroundColor3 = Color3_fromRGB(35, 35, 35), BackgroundTransparency = 0.6, Parent = Main
        }, { Create("UICorner", {CornerRadius = UDim_new(0, 6)}) })

        local WindowFunctions = {}
        local FirstTab = true

        function WindowFunctions:CreateTab(Name)
            local TabBtn = Create("TextButton", {
                Text = Name, Size = UDim2_new(0, 100 * SizeScale, 1, 0), BackgroundColor3 = Color3_fromRGB(45, 45, 45),
                TextColor3 = Color3_fromRGB(200, 200, 200), Font = Enum.Font.GothamBold, TextSize = 14 * SizeScale, Parent = TabContainer
            }, { Create("UICorner", {CornerRadius = UDim_new(0, 6)}) })

            local Page = Create("ScrollingFrame", {
                Name = Name .. "_Page", Size = UDim2_new(1, -10, 1, -10), Position = UDim2_new(0, 5, 0, 5),
                BackgroundTransparency = 1, ScrollBarThickness = 3, ScrollBarImageColor3 = Color3_fromRGB(255, 140, 0),
                Visible = FirstTab, Parent = ContentContainer
            })
            
            local PageLayout = Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim_new(0, 5)})
            PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2_new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 50) end)

            if FirstTab then TabBtn.TextColor3 = Color3_fromRGB(255, 140, 0) FirstTab = false end

            TabBtn.MouseButton1Click:Connect(function()
                for _, p in pairs(ContentContainer:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
                for _, b in pairs(TabContainer:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Color3_fromRGB(200, 200, 200) end end
                Page.Visible = true; TabBtn.TextColor3 = Color3_fromRGB(255, 140, 0)
            end)

            local TabFunc = {}
            local ItemHeight = 35 * SizeScale

            function TabFunc:CreateSection(Text)
                Create("TextLabel", {Text = "--- " .. Text .. " ---", Size = UDim2_new(1, 0, 0, 25 * SizeScale), BackgroundTransparency = 1, TextColor3 = Color3_fromRGB(255, 140, 0), Font = Enum.Font.SourceSansBold, TextSize = 16 * SizeScale, Parent = Page})
            end

            function TabFunc:CreateLabel(Text)
                local Lbl = Create("TextLabel", {Text = Text, Size = UDim2_new(1, 0, 0, 20 * SizeScale), BackgroundTransparency = 1, TextColor3 = Color3_fromRGB(180, 180, 180), Font = Enum.Font.SourceSansItalic, TextSize = 14 * SizeScale, TextXAlignment = Enum.TextXAlignment.Left, Parent = Page}, {Create("UIPadding", {PaddingLeft = UDim_new(0, 10)})})
                return {Set = function(_, NewText) Lbl.Text = NewText end}
            end

            function TabFunc:CreateToggle(Info)
                local IsOn = Info.CurrentValue
                local Status = Create("Frame", {Size = UDim2_new(0, 20 * SizeScale, 0, 20 * SizeScale), Position = UDim2_new(1, -(30 * SizeScale), 0.5, -(10 * SizeScale)), BackgroundColor3 = IsOn and Color3_fromRGB(0, 255, 100) or Color3_fromRGB(80, 80, 80)}, {Create("UICorner", {CornerRadius = UDim_new(0, 4)})})
                
                local Btn = Create("TextButton", {Text = "", Size = UDim2_new(1, 0, 0, ItemHeight), BackgroundColor3 = Color3_fromRGB(45, 45, 45), BackgroundTransparency = 0.5, Parent = Page}, {
                    Create("UICorner", {CornerRadius = UDim_new(0, 4)}), Status,
                    Create("TextLabel", {Text = Info.Name, Size = UDim2_new(0.8, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = Color3_fromRGB(240, 240, 240), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamMedium, TextSize = 13 * SizeScale}, {Create("UIPadding", {PaddingLeft = UDim_new(0, 10)})})
                })
                
                Btn.MouseButton1Click:Connect(function()
                    IsOn = not IsOn
                    Status.BackgroundColor3 = IsOn and Color3_fromRGB(0, 255, 100) or Color3_fromRGB(80, 80, 80)
                    pcall_func(Info.Callback, IsOn)
                end)
            end

            function TabFunc:CreateButton(Info)
                local Btn = Create("TextButton", {Text = Info.Name, Size = UDim2_new(1, 0, 0, ItemHeight), BackgroundColor3 = Color3_fromRGB(50, 50, 50), BackgroundTransparency = 0.5, TextColor3 = Color3_fromRGB(240, 240, 240), Font = Enum.Font.GothamMedium, TextSize = 13 * SizeScale, TextXAlignment = Enum.TextXAlignment.Left, Parent = Page}, {
                    Create("UICorner", {CornerRadius = UDim_new(0, 4)}), Create("UIPadding", {PaddingLeft = UDim_new(0, 10)})
                })
                Btn.MouseButton1Click:Connect(function() pcall_func(Info.Callback) end)
            end

            function TabFunc:CreateInput(Info)
                local Box = Create("TextBox", {PlaceholderText = Info.Name .. " (" .. (Info.PlaceholderText or "") .. ")", Text = "", Size = UDim2_new(1, 0, 0, ItemHeight), BackgroundColor3 = Color3_fromRGB(40, 40, 40), BackgroundTransparency = 0.5, TextColor3 = Color3_fromRGB(255, 140, 0), Font = Enum.Font.Gotham, TextSize = 13 * SizeScale, TextXAlignment = Enum.TextXAlignment.Left, Parent = Page}, {
                    Create("UICorner", {CornerRadius = UDim_new(0, 4)}), Create("UIPadding", {PaddingLeft = UDim_new(0, 10)})
                })
                Box.FocusLost:Connect(function() pcall_func(Info.Callback, Box.Text) end)
            end

            function TabFunc:CreateMultiInput(Infos)
                local Container = Create("Frame", {Name = "MultiInputRow", Size = UDim2_new(1, 0, 0, ItemHeight), BackgroundTransparency = 1, Parent = Page}, {
                    Create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim_new(0, 5)})
                })
                local WidthPerItem = (1 / #Infos)
                for i, Info in ipairs(Infos) do
                    local Box = Create("TextBox", {
                        Size = UDim2_new(WidthPerItem, -((5 * (#Infos-1)) / #Infos), 1, 0),
                        BackgroundColor3 = Color3_fromRGB(40, 40, 40), BackgroundTransparency = 0.5,
                        TextColor3 = Color3_fromRGB(255, 140, 0), PlaceholderText = Info.Name .. (Info.PlaceholderText and "\n("..Info.PlaceholderText..")" or ""),
                        Text = "", Font = Enum.Font.Gotham, TextSize = 12 * SizeScale, TextXAlignment = Enum.TextXAlignment.Center, Parent = Container
                    }, {Create("UICorner", {CornerRadius = UDim_new(0, 4)})})
                    Box.FocusLost:Connect(function() pcall_func(Info.Callback, Box.Text) end)
                end
            end

            function TabFunc:CreateKeybind(Info)
                local KeyDisplay = Create("TextLabel", {Size = UDim2_new(0, 80 * SizeScale, 0, 25 * SizeScale), Position = UDim2_new(1, -(90 * SizeScale), 0.5, -(12.5 * SizeScale)), BackgroundColor3 = Color3_fromRGB(30, 30, 30), TextColor3 = Color3_fromRGB(255, 170, 0), Text = Info.CurrentKey.Name, Font = Enum.Font.GothamBold, TextSize = 12 * SizeScale}, {Create("UICorner", {CornerRadius = UDim_new(0, 4)})})
                local Btn = Create("TextButton", {Text = "", Size = UDim2_new(1, 0, 0, ItemHeight), BackgroundColor3 = Color3_fromRGB(45, 45, 45), BackgroundTransparency = 0.5, Parent = Page}, {
                    Create("UICorner", {CornerRadius = UDim_new(0, 4)}), KeyDisplay,
                    Create("TextLabel", {Text = Info.Name, Size = UDim2_new(0.6, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = Color3_fromRGB(240, 240, 240), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamMedium, TextSize = 13 * SizeScale}, {Create("UIPadding", {PaddingLeft = UDim_new(0, 10)})})
                })
                
                Btn.MouseButton1Click:Connect(function()
                    KeyDisplay.Text = "..."
                    KeyDisplay.TextColor3 = Color3_fromRGB(255, 0, 0)
                    local con; con = UIS.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                            Info.CurrentKey = input.KeyCode; KeyDisplay.Text = input.KeyCode.Name; KeyDisplay.TextColor3 = Color3_fromRGB(255, 170, 0)
                            pcall_func(Info.Callback, input.KeyCode); con:Disconnect()
                        end
                    end)
                end)
            end

            function TabFunc:CreateDropdown(Info)
                local DropContainer = Create("Frame", {Size = UDim2_new(1, 0, 0, ItemHeight), BackgroundTransparency = 1, Parent = Page})
                local Title = Create("TextLabel", {Text = Info.Name .. ": " .. (Info.CurrentOption or ""), Size = UDim2_new(1, -25, 1, 0), BackgroundTransparency = 1, TextColor3 = Color3_fromRGB(240, 240, 240), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamMedium, TextSize = 13 * SizeScale}, {Create("UIPadding", {PaddingLeft = UDim_new(0, 10)})})
                local Arrow = Create("TextLabel", {Text = "▼", Size = UDim2_new(0, 25, 1, 0), Position = UDim2_new(1, -25, 0, 0), BackgroundTransparency = 1, TextColor3 = Color3_fromRGB(255, 140, 0), Font = Enum.Font.GothamBold, TextSize = 12 * SizeScale})
                local MainBtn = Create("TextButton", {Text = "", Size = UDim2_new(1, 0, 0, ItemHeight), BackgroundColor3 = Color3_fromRGB(45, 45, 45), BackgroundTransparency = 0.5, Parent = DropContainer}, {Create("UICorner", {CornerRadius = UDim_new(0, 4)}), Title, Arrow})
                
                local OptionList = Create("ScrollingFrame", {Visible = false, Size = UDim2_new(1, 0, 0, 0), Position = UDim2_new(0, 0, 0, ItemHeight + 2), BackgroundColor3 = Color3_fromRGB(35, 35, 35), ScrollBarThickness = 2, Parent = DropContainer, ZIndex = 10}, {Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder})})
                local IsOpen = false

                local function RefreshList()
                    for _, child in pairs(OptionList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                    for _, OptName in ipairs(Info.Options) do
                        local OptBtn = Create("TextButton", {Text = OptName, Size = UDim2_new(1, 0, 0, ItemHeight), BackgroundColor3 = Color3_fromRGB(40, 40, 40), TextColor3 = (OptName == Info.CurrentOption) and Color3_fromRGB(255, 140, 0) or Color3_fromRGB(200, 200, 200), Font = Enum.Font.Gotham, TextSize = 12 * SizeScale, Parent = OptionList})
                        OptBtn.MouseButton1Click:Connect(function()
                            Info.CurrentOption = OptName; Title.Text = Info.Name .. ": " .. OptName
                            pcall_func(Info.Callback, {OptName}); IsOpen = false; OptionList.Visible = false
                            DropContainer.Size = UDim2_new(1, 0, 0, ItemHeight); Arrow.Rotation = 0
                        end)
                    end
                    OptionList.CanvasSize = UDim2_new(0, 0, 0, #Info.Options * ItemHeight)
                end
                
                MainBtn.MouseButton1Click:Connect(function()
                    IsOpen = not IsOpen; OptionList.Visible = IsOpen
                    if IsOpen then
                        RefreshList(); local ListHeight = math_min(#Info.Options * ItemHeight, 150)
                        OptionList.Size = UDim2_new(1, 0, 0, ListHeight); DropContainer.Size = UDim2_new(1, 0, 0, ItemHeight + ListHeight + 5); Arrow.Rotation = 180
                    else
                        DropContainer.Size = UDim2_new(1, 0, 0, ItemHeight); Arrow.Rotation = 0
                    end
                end)
                return {Refresh = function(self, NewOpts, Keep) Info.Options = NewOpts; if not Keep then Info.CurrentOption = NewOpts[1] end Title.Text = Info.Name .. ": " .. (Info.CurrentOption or ""); if IsOpen then RefreshList() end end}
            end

            function TabFunc:CreateRecipeBoard(Recipes)
                local BoardFrame = Create("Frame", {Size = UDim2_new(1, 0, 0, 200), BackgroundColor3 = Color3_fromRGB(30, 30, 30), Parent = Page}, {Create("UICorner", {CornerRadius = UDim_new(0, 6)})})
                Create("TextLabel", {Text = "📖 DANH SÁCH CÔNG THỨC", Size = UDim2_new(1, 0, 0, 25), BackgroundTransparency = 1, TextColor3 = Color3_fromRGB(255, 170, 0), Font = Enum.Font.GothamBold, TextSize = 13, Parent = BoardFrame})
                local Scroller = Create("ScrollingFrame", {Position = UDim2_new(0, 5, 0, 30), Size = UDim2_new(1, -10, 1, -35), BackgroundTransparency = 1, ScrollBarThickness = 3, Parent = BoardFrame})
                local Layout = Create("UIListLayout", {Parent = Scroller, Padding = UDim_new(0, 5)})
                for _, recipe in ipairs(Recipes) do
                    local counts, parts = {}, {}
                    for _, item in ipairs(recipe.Items) do counts[item] = (counts[item] or 0) + 1 end
                    for name, count in pairs(counts) do table_insert(parts, name .. " x" .. count) end
                    Create("TextLabel", {Text = "• " .. recipe.Name .. ":\n   ➜ " .. table.concat(parts, ", "), Size = UDim2_new(1, 0, 0, 40), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3_fromRGB(220, 220, 220), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = Scroller})
                end
                Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroller.CanvasSize = UDim2_new(0, 0, 0, Layout.AbsoluteContentSize.Y) end)
            end

            function TabFunc:CreateSlider(Info)
                local F = Create("Frame", {Size = UDim2_new(1, 0, 0, 40 * SizeScale), BackgroundTransparency = 1, Parent = Page})
                local L = Create("TextLabel", {Text = Info.Name .. ": " .. Info.CurrentValue, Size = UDim2_new(1, 0, 0, 20 * SizeScale), BackgroundTransparency = 1, TextColor3 = Color3_fromRGB(200, 200, 200), Font = Enum.Font.Gotham, TextSize = 12 * SizeScale, TextXAlignment = Enum.TextXAlignment.Left, Parent = F}, {Create("UIPadding", {PaddingLeft = UDim_new(0, 10)})})
                Create("TextButton", {Text = "Thay đổi (Bấm)", Size = UDim2_new(1, 0, 0, 20 * SizeScale), Position = UDim2_new(0, 0, 0, 20 * SizeScale), BackgroundColor3 = Color3_fromRGB(40, 40, 40), BackgroundTransparency = 0.5, TextColor3 = Color3_fromRGB(150, 150, 150), Parent = F}, {Create("UICorner", {CornerRadius = UDim_new(0, 4)})}).MouseButton1Click:Connect(function()
                     Info.CurrentValue = Info.CurrentValue + Info.Increment; if Info.CurrentValue > Info.Range[2] then Info.CurrentValue = Info.Range[1] end
                     L.Text = Info.Name .. ": " .. math_floor(Info.CurrentValue*10)/10; pcall_func(Info.Callback, Info.CurrentValue)
                end)
            end
            return TabFunc
        end
        function WindowFunctions:LoadConfiguration() end 
        return WindowFunctions
    end

    local Rayfield = KumaUI 

    -- ==============================================================================
    -- 2. KHAI BÁO BIẾN & CẤU HÌNH (CONFIG)
    -- ==============================================================================
    local CollectRemote = RE:FindFirstChild("CollectHerb", true)
    local ConfigFolder = "KumaHub_Cultivation_V3" 
    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end

    local Default_Config = { 
        Tracking = {["Ginseng"]=false, ["Spirit Rose"]=false, ["Qi Flower"]=false, ["Qi Berries"]=false, ["Moon Flower"]=false, ["Death Flower"]=false},
        AutoLoot = false, InstantFarm = false, FarmAll = false, HoldDelay = 0.2, SyncDelay = 0.8,
        AutoReturnDeath = false, SavedPosition = nil, TempKey = "Z", ExtraKeys = {}, ExtraKeyDelay = 1.0,
        Waypoints = {}, WaypointDelay = 2, AutoWaypoint = false, AutoClean = true, FPSBoost = false,
        WhiteScreen = false, AntiAFK = true, DestroyMap = false,
        CraftEnabled = false, CraftRecipe = "Lesser Qi Condensation Pill", CraftYear = "1 Year", CraftAmount = 1, CraftBulkAmount = 1, CraftLevel = 1
    }

    _G.Config = HttpService:JSONDecode(HttpService:JSONEncode(Default_Config))
    local LocationCache = {} 
    local IsReturning = false 
    local SelectedProfile = ""
    local InputProfileName = ""

    -- ==============================================================================
    -- 3. CÁC HÀM HỖ TRỢ - TỐI ƯU HÓA SIÊU CẤP (ULTRA OPTIMIZATION)
    -- ==============================================================================
    local function GetPosition(obj)
        if obj:IsA("Model") then return obj:GetPivot().Position
        elseif obj:IsA("BasePart") then return obj.Position end
        return Vector3_new(0,0,0)
    end

    local function GetCleanName(obj)
        local name = obj.Name
        local bb = obj:FindFirstChildWhichIsA("BillboardGui", true)
        if bb then
            local lbl = bb:FindFirstChildWhichIsA("TextLabel", true)
            if lbl and lbl.Text ~= "" then name = lbl.Text end
        end
        return name:gsub("%[.-%]", ""):gsub("%d+ Year", ""):gsub("%d+Y", ""):match("^%s*(.-)%s*$")
    end

    local function PressKey(keyName)
        local key = Enum.KeyCode[keyName]
        if key then
            VIM:SendKeyEvent(true, key, false, game)
            task_wait(0.05)
            VIM:SendKeyEvent(false, key, false, game)
        end
    end

    local function EnsurePlatform()
        local p = WS:FindFirstChild("Kuma_Platform")
        if not p then
            p = Create("Part", {Name = "Kuma_Platform", Size = Vector3_new(100, 1, 100), Anchored = true, CanCollide = true, Material = Enum.Material.SmoothPlastic, Color = Color3_fromRGB(0, 255, 100), Transparency = 0.5, Parent = WS})
        end
        return p
    end

    -- Hàm NukeMap cải tiến: Xóa triệt để hơn nhưng an toàn cho Script
    local function NukeMap()
        if not _G.Config.DestroyMap then return end
        local plat = EnsurePlatform()
        if not _G.Config.AutoLoot and not _G.Config.InstantFarm and not _G.Config.AutoWaypoint then
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                plat.CFrame = LP.Character.HumanoidRootPart.CFrame - Vector3_new(0, 3.5, 0)
            end
        end
        for _, v in ipairs(WS:GetChildren()) do
            if v.Name ~= "Players" and v.Name ~= "Plants" and v.Name ~= "Camera" and v.Name ~= "Terrain" and v.Name ~= "Kuma_Platform" then
                if (v:IsA("Model") or v:IsA("Folder") or v:IsA("Part") or v:IsA("MeshPart")) and v ~= LP.Character then 
                    v:Destroy() 
                end
            end
        end
        WS.Terrain:Clear()
        collectgarbage("collect") -- Giải phóng RAM sau khi xóa map
    end

    -- [HÀM MỚI] SIÊU GIẢM RAM VÀ GPU (POTATO MODE) - ĐÃ NÂNG CẤP
    local function UltraRAMClean()
        -- Hạ thấp chất lượng đồ họa của Engine xuống mức 1
        pcall_func(function()
            settings().Rendering.QualityLevel = 1
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level0
        end)

        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("Texture") or v:IsA("Decal") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v:Destroy()
            elseif v:IsA("BasePart") and not v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
                v.CastShadow = false
            elseif v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then
                v.Enabled = false
            end
        end
        
        -- Tắt hiệu ứng nước và ánh sáng
        WS.Terrain.WaterWaveSize = 0
        WS.Terrain.WaterWaveSpeed = 0
        WS.Terrain.WaterReflectance = 0
        WS.Terrain.WaterTransparency = 0
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        
        collectgarbage("collect")
    end

    LP.Idled:Connect(function() if _G.Config.AntiAFK then VU:CaptureController() VU:ClickButton2(Vector2_new()) end end)

    local function GetMyProfiles()
        local files = listfiles(ConfigFolder)
        local myProfiles, prefix = {}, LP.UserId .. "_" 
        for _, file in ipairs(files) do
            local fileName = file:match("([^/]+)$") 
            if fileName:find("^" .. prefix) then table_insert(myProfiles, fileName:sub(#prefix + 1):gsub("%.json$", "")) end
        end
        return myProfiles
    end

    local function SaveUserProfile(name)
        if name == "" then return end
        local data = HttpService:JSONDecode(HttpService:JSONEncode(_G.Config))
        data.Waypoints = {}
        for _, cf in ipairs(_G.Config.Waypoints) do table_insert(data.Waypoints, {cf:GetComponents()}) end
        if _G.Config.SavedPosition then data.SavedPosition = {_G.Config.SavedPosition:GetComponents()} end
        writefile(ConfigFolder .. "/" .. LP.UserId .. "_" .. name .. ".json", HttpService:JSONEncode(data))
    end

    local function LoadUserProfile(name)
        local fileName = ConfigFolder .. "/" .. LP.UserId .. "_" .. name .. ".json"
        if not isfile(fileName) then return end
        local decoded = HttpService:JSONDecode(readfile(fileName))
        for k, v in pairs(decoded) do if k ~= "Waypoints" and k ~= "SavedPosition" then _G.Config[k] = v end end
        _G.Config.Waypoints = {}
        if decoded.Waypoints then for _, comps in ipairs(decoded.Waypoints) do table_insert(_G.Config.Waypoints, CFrame_new(unpack(comps))) end end
        if decoded.SavedPosition then _G.Config.SavedPosition = CFrame_new(unpack(decoded.SavedPosition)) end
    end

    -- ==============================================================================
    -- 4. GIAO DIỆN CHÍNH (GUI)
    -- ==============================================================================
    local Window = Rayfield:CreateWindow({ Name = "🐻 KUMA HUB V3.1 (ULTRA) 🐻", ConfigurationSaving = { Enabled = false } })

    local ShowMobileButton = IsMobile
    local MobileBtnInstance = nil

    local function CreateMobileButton()
        if MobileBtnInstance then MobileBtnInstance:Destroy() end
        local MobileScreen = Create("ScreenGui", {Name = "KumaMobileButton", Parent = CoreGui})
        MobileBtnInstance = MobileScreen
        local ToggleBtn = Create("TextButton", {Parent = MobileScreen, BackgroundColor3 = Color3_fromRGB(40, 40, 40), Position = UDim2_new(0.85, 0, 0.4, 0), Size = UDim2_new(0, 50, 0, 50), Font = Enum.Font.FredokaOne, Text = "🐻", TextColor3 = Color3_fromRGB(255, 255, 255), TextSize = 25, AutoButtonColor = true}, {
            Create("UICorner", {CornerRadius = UDim_new(1, 0)}),
            Create("UIStroke", {Color = Color3_fromRGB(255, 170, 0), Thickness = 2})
        })
        
        local dragging, dragStart, startPos
        ToggleBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = ToggleBtn.Position
            end
        end)
        ToggleBtn.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                ToggleBtn.Position = UDim2_new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        ToggleBtn.InputEnded:Connect(function(input) 
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false; if (input.Position - dragStart).Magnitude < 10 and KumaMainFrame then KumaMainFrame.Visible = not KumaMainFrame.Visible end
            end
        end)
    end

    if ShowMobileButton then task_spawn(CreateMobileButton) end

    -- =============================================================
    -- TAB 1: FARM
    -- =============================================================
    local TabFarm = Window:CreateTab("🌿 Farm")
    local StatusLabel = TabFarm:CreateLabel("Trạng thái: Đang nghỉ")

    TabFarm:CreateSection("Điều khiển Farm")
    TabFarm:CreateToggle({ Name = "⚡ Farm Từ Xa (Instant)", CurrentValue = false, Callback = function(V) _G.Config.InstantFarm = V if V then _G.Config.AutoLoot = false end end })
    TabFarm:CreateToggle({ Name = "▶ Farm Thường (Giữ E)", CurrentValue = false, Callback = function(V) _G.Config.AutoLoot = V if V then _G.Config.InstantFarm = false end end })
    TabFarm:CreateToggle({ Name = "🌍 Farm Tất Cả (Bỏ lọc)", CurrentValue = false, Callback = function(V) _G.Config.FarmAll = V end })

    TabFarm:CreateSection("🌿 Cấu Hình Lọc")
    for k, v in pairs(_G.Config.Tracking) do
        TabFarm:CreateToggle({ Name = k, CurrentValue = v, Callback = function(Val) _G.Config.Tracking[k] = Val end })
    end

    -- [SCANNER LOOP - TỐI ƯU HÓA]
    task_spawn(function()
        while IsAlive() do
            if _G.Config.AutoWaypoint then
                table_clear(LocationCache)
                task_wait(2) 
            elseif (_G.Config.AutoLoot or _G.Config.InstantFarm) then 
                if #LocationCache == 0 then
                    local plantFolder = WS:FindFirstChild("Plants")
                    local scanTarget = (plantFolder and plantFolder:GetChildren()) or WS:GetChildren() 
                    local tempCache = {}
                    local hasSelection = false
                    for _, val in pairs(_G.Config.Tracking) do if val == true then hasSelection = true break end end

                    if hasSelection or _G.Config.FarmAll then
                        StatusLabel:Set("Đang quét tìm cây...")
                        for _, v in ipairs(scanTarget) do
                            if (v:IsA("Model") or v:IsA("BasePart")) and v.Parent then
                                local cleanName = GetCleanName(v)
                                local isMatch = _G.Config.FarmAll
                                if not isMatch then
                                    for herbName, enabled in pairs(_G.Config.Tracking) do if enabled and cleanName:find(herbName) then isMatch = true break end end
                                end
                                
                                if isMatch then
                                    if v:FindFirstChildWhichIsA("ProximityPrompt", true) or v:FindFirstChildWhichIsA("ClickDetector", true) or _G.Config.InstantFarm then
                                        table_insert(tempCache, {Name = cleanName, Position = GetPosition(v), Instance = v})
                                    end
                                end
                            end
                        end
                        if #tempCache > 0 and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                            local myPos = LP.Character.HumanoidRootPart.Position
                            table.sort(tempCache, function(a, b) return (a.Position - myPos).Magnitude < (b.Position - myPos).Magnitude end)
                        end
                        LocationCache = tempCache
                        if #LocationCache > 0 then StatusLabel:Set("Tìm thấy: " .. #LocationCache .. " cây") end
                    else
                        LocationCache = {}
                        StatusLabel:Set("Vui lòng chọn loại cây!")
                    end
                end
                task_wait(0.5) 
            else
                table_clear(LocationCache)
                task_wait(1)
            end
        end
    end)

    -- [FARM MAIN LOOP]
    task_spawn(function()
        while IsAlive() do
            local success = pcall_func(function()
                if (_G.Config.AutoLoot or _G.Config.InstantFarm) and not IsReturning and not _G.Config.AutoWaypoint then
                    if #LocationCache > 0 then
                        local targetData = LocationCache[1]
                        if targetData and targetData.Instance and targetData.Instance.Parent then
                            local char = LP.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            local hum = char and char:FindFirstChild("Humanoid")
                            
                            if hrp and hum and hum.Health > 0 then
                                local tPos = GetPosition(targetData.Instance)
                                hrp.CFrame = CFrame_new(tPos) + Vector3_new(0, 3, 0)
                                EnsurePlatform().CFrame = hrp.CFrame - Vector3_new(0, 3.5, 0)
                                task_wait(_G.Config.SyncDelay)
                                
                                if targetData.Instance.Parent and (hrp.Position - tPos).Magnitude < 20 then
                                    if _G.Config.InstantFarm then 
                                        CollectRemote:FireServer(targetData.Instance)
                                    else 
                                        local prompt = targetData.Instance:FindFirstChildWhichIsA("ProximityPrompt", true)
                                        if prompt then
                                            prompt:InputHoldBegin()
                                            task_wait(prompt.HoldDuration + _G.Config.HoldDelay)
                                            prompt:InputHoldEnd()
                                        end
                                    end
                                end
                                table_remove(LocationCache, 1)
                            else
                                task_wait(1) 
                            end
                        else
                            table_remove(LocationCache, 1) 
                        end
                    else 
                        StatusLabel:Set("Đang đợi cây spawn...")
                        local p = WS:FindFirstChild("Kuma_Platform")
                        if p then p.CFrame = CFrame_new(0, -500, 0) end
                        task_wait(1) 
                    end
                else
                    task_wait(0.2)
                end
            end)
            if not success then task_wait(1) end
        end
    end)

    -- =============================================================
    -- TAB 2: TELE
    -- =============================================================
    local TabTele = Window:CreateTab("🚀 Dịch Chuyển")
    
    local Locations = {
        ["Small Village"] = CFrame_new(880, -65, 465), 
        ["40000x Zone"] = CFrame_new(-1069, 574, 609),
        ["Mob 5+"] = CFrame_new(-3495, 8, 5219),
        ["Mob 10+"] = CFrame_new(-2209, -8, 2253),
        ["Mob 15+"] = CFrame_new(-244, 12, 5509),
        ["Mob 18+"] = CFrame_new(62, 40, 133),
        ["Mob 20+"] = CFrame_new(-1701, -44, -90),
        ["Mob 25+"] = CFrame_new(-448, 49, 1724),
        ["sect"] = CFrame_new(-1426, 29, 1876)
    }
    
    local LocationNames = {}
    for name, _ in pairs(Locations) do table_insert(LocationNames, name) end
    table.sort(LocationNames)
    local SelectedLocation = LocationNames[1]

    TabTele:CreateDropdown({Name = "Chọn địa điểm", Options = LocationNames, CurrentOption = SelectedLocation, Callback = function(Option) SelectedLocation = Option[1] end})
    TabTele:CreateButton({Name = "🚀 Dịch chuyển đến địa điểm chọn", Callback = function() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.CFrame = Locations[SelectedLocation] end end})

    TabTele:CreateSection("Hệ thống tự quay lại")
    TabTele:CreateButton({ Name = "📍 Lưu vị trí hiện tại", Callback = function() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then _G.Config.SavedPosition = LP.Character.HumanoidRootPart.CFrame end end })
    TabTele:CreateButton({ Name = "🚨 Dịch chuyển về điểm lưu", Callback = function() if _G.Config.SavedPosition and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.CFrame = _G.Config.SavedPosition end end })
    TabTele:CreateToggle({ Name = "💀 Tự về khi chết (+ Phím)", CurrentValue = false, Callback = function(V) _G.Config.AutoReturnDeath = V end })
    
    LP.CharacterAdded:Connect(function(newChar)
        if _G.Config.AutoReturnDeath and _G.Config.SavedPosition then
            local hrp = newChar:WaitForChild("HumanoidRootPart", 10)
            local hum = newChar:WaitForChild("Humanoid", 10)
            if hrp and hum then
                task_wait(1.5)
                hrp.CFrame = _G.Config.SavedPosition
                if #_G.Config.ExtraKeys > 0 then
                    task_wait(0.8)
                    for _, k in ipairs(_G.Config.ExtraKeys) do if hum.Health > 0 then PressKey(k) task_wait(_G.Config.ExtraKeyDelay) end end
                end
            end
        end
    end)

    TabTele:CreateSection("Vòng lặp điểm (Waypoints)")
    local WaypointLabel = TabTele:CreateLabel("Điểm đã lưu: 0")
    TabTele:CreateButton({ Name = "➕ Thêm vị trí đứng", Callback = function() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then table_insert(_G.Config.Waypoints, LP.Character.HumanoidRootPart.CFrame) WaypointLabel:Set("Điểm đã lưu: " .. #_G.Config.Waypoints) end end})
    TabTele:CreateButton({ Name = "🗑 Xóa danh sách", Callback = function() _G.Config.Waypoints = {} WaypointLabel:Set("Điểm đã lưu: 0") end})
    TabTele:CreateToggle({ Name = "▶ Bắt đầu chạy vòng lặp", CurrentValue = false, Callback = function(V) _G.Config.AutoWaypoint = V end})
    
    task_spawn(function()
        while IsAlive() do
            if _G.Config.AutoWaypoint and #_G.Config.Waypoints > 0 and not _G.Config.AutoLoot and not _G.Config.InstantFarm then
                for i, cf in ipairs(_G.Config.Waypoints) do
                    if not _G.Config.AutoWaypoint then break end
                    EnsurePlatform().CFrame = cf - Vector3_new(0, 3.5, 0)
                    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.CFrame = cf end
                    task_wait(math_min(_G.Config.WaypointDelay, 0.1))
                    if _G.Config.DestroyMap then NukeMap() end
                end
                if _G.Config.AutoClean then table_clear(LocationCache) end
            else
                if not _G.Config.AutoLoot and not _G.Config.InstantFarm and not _G.Config.DestroyMap then
                    local p = WS:FindFirstChild("Kuma_Platform")
                    if p then p:Destroy() end
                end
                task_wait(1)
            end
        end
    end)

    -- =============================================================
    -- TAB 3: MISC (ESP & SPIN)
    -- =============================================================
    local TabMisc = Window:CreateTab("🧩 Khác")
    
    TabMisc:CreateSection("Hiển thị (ESP)")
    local ESP_NPC_Enabled = false
    local ESP_Player_Enabled = false
    local ESP_Storage = {} 

    local function RemoveESP_Obj(model)
        if ESP_Storage[model] then
            if ESP_Storage[model].Conn then ESP_Storage[model].Conn:Disconnect() end
            if ESP_Storage[model].Highlight then ESP_Storage[model].Highlight:Destroy() end
            if ESP_Storage[model].Billboard then ESP_Storage[model].Billboard:Destroy() end
            ESP_Storage[model] = nil
        end
    end

    local function CreateESP_V8(model, holder, color, isPlayer)
        if not model or ESP_Storage[model] then return end
        if model == LP.Character then return end
        
        local hum = model:FindFirstChild("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso") or model.PrimaryPart
        if not root or not hum or hum.Health <= 0 then return end
        if not isPlayer and Players:GetPlayerFromCharacter(model) then return end 

        local hl = Instance.new("Highlight")
        hl.Adornee = model
        hl.FillColor = color
        hl.OutlineColor = Color3_fromRGB(255, 255, 255)
        hl.FillTransparency = 0.65 
        hl.OutlineTransparency = 0.3
        pcall_func(function() hl.Parent = holder end)

        local bg = Create("BillboardGui", {Adornee = root, Size = UDim2_new(0, 150, 0, 40), StudsOffset = Vector3_new(0, 4.5, 0), AlwaysOnTop = true, Parent = holder})
        local t = Create("TextLabel", {Parent = bg, BackgroundTransparency = 1, Size = UDim2_new(1,0,1,0), TextColor3 = color, TextStrokeTransparency = 0, Font = Enum.Font.GothamBold, TextSize = 12})
        
        local function UpdateText()
            if hum and model and model.Parent then
                local distStr = ""
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and root then
                    distStr = string.format("\nDist: %d", math_floor((LP.Character.HumanoidRootPart.Position - root.Position).Magnitude))
                end
                t.Text = string.format("%s\n[%d/%d]%s", model.Name, math_floor(hum.Health), math_floor(hum.MaxHealth), distStr)
            else RemoveESP_Obj(model) end
        end
        UpdateText()

        local healthConn = hum.HealthChanged:Connect(UpdateText)
        local removingConn = model.AncestryChanged:Connect(function(_, parent) if not parent then RemoveESP_Obj(model) end end)
        ESP_Storage[model] = { Highlight = hl, Billboard = bg, Conn = healthConn }
    end

    local function StartSmartScan(targetType, folderName, color)
        local Holder = CoreGui:FindFirstChild(folderName) or Create("Folder", {Name = folderName, Parent = CoreGui})
        task_spawn(function()
            while IsAlive() do
                if (targetType == "NPC" and not ESP_NPC_Enabled) or (targetType == "PLAYER" and not ESP_Player_Enabled) then 
                    Holder:ClearAllChildren(); for m, _ in pairs(ESP_Storage) do RemoveESP_Obj(m) end; ESP_Storage = {}; break 
                end

                if targetType == "PLAYER" then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LP and p.Character then CreateESP_V8(p.Character, Holder, color, true) end
                    end
                elseif targetType == "NPC" then
                    local count = 0
                    for _, obj in ipairs(WS:GetDescendants()) do
                        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
                            CreateESP_V8(obj, Holder, color, false)
                        end
                        count = count + 1; if count % 350 == 0 then task_wait() end 
                    end
                end
                
                for model, _ in pairs(ESP_Storage) do
                    if not model.Parent or (model:FindFirstChild("Humanoid") and model.Humanoid.Health <= 0) then RemoveESP_Obj(model) end
                end
                task_wait(3)
            end
        end)
    end

    TabMisc:CreateToggle({Name = "🔥 Hiện NPC (Deep Scan)", CurrentValue = false, Callback = function(V) ESP_NPC_Enabled = V if V then StartSmartScan("NPC", "Kuma_ESP_NPC", Color3_fromRGB(255, 60, 60)) end end})
    TabMisc:CreateToggle({Name = "👤 Hiện Người Chơi (Dist)", CurrentValue = false, Callback = function(V) ESP_Player_Enabled = V if V then StartSmartScan("PLAYER", "Kuma_ESP_Player", Color3_fromRGB(0, 255, 100)) end end})
    
    TabMisc:CreateSection("Quay thưởng (Kuma V8 Safe)")
    local SpinStatus = TabMisc:CreateLabel("Trạng thái: Chờ...")
    _G.AutoRace = false; _G.AutoRoot = false; _G.SelectRank = 3; _G.SelectSlot = 1 
    local Ranks = {{Name="Common", Val=1}, {Name="Rare", Val=2}, {Name="Epic", Val=3}, {Name="Legendary", Val=4}, {Name="Mythic", Val=5}, {Name="secret", Val=6}}
    local RankNames = {} for _, r in ipairs(Ranks) do table_insert(RankNames, r.Name) end

    local function CheckStop()
        for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
            if gui:IsA("TextLabel") and gui.Visible and gui.Text:find("Rolled:") then
                for _, r in ipairs(Ranks) do if gui.Text:find(r.Name) and r.Val >= _G.SelectRank then return true, r.Name end end
            end
        end
        return false, nil
    end

    local function Spin(type)
        local events = RE:FindFirstChild("Events")
        if type == "Race" and events and events:FindFirstChild("RollRace") then events.RollRace:FireServer(_G.SelectSlot, true)
        elseif type == "Root" and events and events:FindFirstChild("RollSpiritRoot") then events.RollSpiritRoot:FireServer(_G.SelectSlot, true) end
    end

    TabMisc:CreateDropdown({Name = "🎯 Chọn Slot Quay", Options = {"Slot 1", "Slot 2", "Slot 3"}, CurrentOption = "Slot 1", Callback = function(Option) _G.SelectSlot = tonumber(Option[1]:match("%d")) end})
    TabMisc:CreateDropdown({Name = "Chọn Rank Dừng (>=)", Options = RankNames, CurrentOption = "Epic", Callback = function(Option) for _, r in ipairs(Ranks) do if r.Name == Option[1] then _G.SelectRank = r.Val end end end})
    TabMisc:CreateToggle({Name = "🌀 Auto Quay Tộc (Race)", CurrentValue = false, Callback = function(V) _G.AutoRace = V if V then _G.AutoRoot = false SpinStatus:Set("Auto Race: ON...") task_spawn(function() while _G.AutoRace and IsAlive() do Spin("Race") task_wait(0.1) local stop, r = CheckStop() if stop then _G.AutoRace = false SpinStatus:Set("DỪNG: " .. r) end end if not _G.AutoRace then SpinStatus:Set("Auto Race: OFF") end end) end end})
    TabMisc:CreateToggle({Name = "🌀 Auto Quay Linh Căn (Root)", CurrentValue = false, Callback = function(V) _G.AutoRoot = V if V then _G.AutoRace = false SpinStatus:Set("Auto Root: ON...") task_spawn(function() while _G.AutoRoot and IsAlive() do Spin("Root") task_wait(0.1) local stop, r = CheckStop() if stop then _G.AutoRoot = false SpinStatus:Set("DỪNG: " .. r) end end if not _G.AutoRoot then SpinStatus:Set("Auto Root: OFF") end end) end end})

    TabMisc:CreateSection("Chuỗi phím bổ trợ")
    local SequenceDisplay = TabMisc:CreateLabel("Phím hiện tại: [ Trống ]")
    local function UpdateKeys() if #_G.Config.ExtraKeys == 0 then SequenceDisplay:Set("Phím hiện tại: [ Trống ]") else SequenceDisplay:Set("Phím: " .. table.concat(_G.Config.ExtraKeys, " -> ")) end end
    TabMisc:CreateDropdown({ Name = "Chọn phím", Options = {"C", "G", "V", "B", "H", "E", "R", "Z", "Space"}, CurrentOption = "Z", Callback = function(O) _G.Config.TempKey = O[1] end})
    TabMisc:CreateButton({ Name = "➕ Thêm phím vào chuỗi", Callback = function() table_insert(_G.Config.ExtraKeys, _G.Config.TempKey) UpdateKeys() end})
    TabMisc:CreateButton({ Name = "🗑 Xóa chuỗi phím", Callback = function() _G.Config.ExtraKeys = {} UpdateKeys() end})

    -- =============================================================
    -- TAB 4: CRAFT
    -- =============================================================
    local TabCraft = Window:CreateTab("⚗ Chế Thuốc")
    local CraftRecipes = {
        {Name = "Lesser Qi Condensation Pill", Items = {"Qi Berries", "Qi Berries", "Spirit Rose", "Qi Flower"}},
        {Name = "Refined Qi Flow Pill",        Items = {"Ginseng", "Ginseng", "Spirit Rose", "Qi Flower"}},
        {Name = "Body Tempering Pill",         Items = {"Qi Berries", "Ginseng", "Qi Flower", "Moon Flower"}},
        {Name = "Blood Moon Fury Pill",        Items = {"Qi Berries", "Spirit Rose", "Moon Flower", "Death Flower"}},
        {Name = "Serene Fortune Pill",         Items = {"Spirit Rose", "Spirit Rose", "Death Flower", "Death Flower"}},
        {Name = "Harvester's Insight Pill",    Items = {"Qi Berries", "Ginseng", "Spirit Rose", "Qi Flower"}},
        {Name = "Spirit Shield Pill",          Items = {"Ginseng", "Ginseng", "Spirit Rose", "Moon Flower"}},
        {Name = "Moonlit Destruction Pill",    Items = {"Spirit Rose", "Qi Flower", "Moon Flower", "Death Flower"}},
        {Name = "Heaven-Defying Rebirth Pill", Items = {"Ginseng", "Death Flower", "Death Flower", "Death Flower"}}
    }
    local RecipeNames = {} for _, v in ipairs(CraftRecipes) do table_insert(RecipeNames, v.Name) end
    local YearToGrade = { ["100000 Year"] = 6, ["10000 Year"] = 5, ["1000 Year"] = 4, ["100 Year"] = 3, ["10 Year"] = 2, ["1 Year"] = 1 }
    
    TabCraft:CreateDropdown({ Name = "Công thức", Options = RecipeNames, CurrentOption = RecipeNames[1], Callback = function(O) _G.Config.CraftRecipe = O[1] end})
    TabCraft:CreateDropdown({ Name = "Niên đại (Năm)", Options = {"1 Year", "10 Year", "100 Year", "1000 Year", "10000 Year", "100000 Year"}, CurrentOption = "1 Year", Callback = function(O) _G.Config.CraftYear = O[1] end})
    
    TabCraft:CreateMultiInput({
        {Name = "Cấp Lò", PlaceholderText = "10", Callback = function(Text) _G.Config.CraftLevel = tonumber(Text) or 10 end},
        {Name = "Loop (Lần)", PlaceholderText = "1", Callback = function(Text) _G.Config.CraftAmount = tonumber(Text) or 1 end},
        {Name = "Bulk (Viên)", PlaceholderText = "1", Callback = function(Text) _G.Config.CraftBulkAmount = tonumber(Text) or 1 end}
    })

    TabCraft:CreateToggle({ Name = "▶ Bắt đầu chế thuốc", CurrentValue = false, Callback = function(V) 
        _G.Config.CraftEnabled = V 
        if V then 
            task_spawn(function() 
                local count = 0 
                while _G.Config.CraftEnabled and count < (_G.Config.CraftAmount or 1) and IsAlive() do 
                    count = count + 1 
                    local recipe = nil; for _,r in ipairs(CraftRecipes) do if r.Name == _G.Config.CraftRecipe then recipe = r break end end 
                    
                    if recipe then 
                        local Evt = RE:WaitForChild("Events")
                        local Remote_Reset = RE:FindFirstChild("ReturnHerbalAlchemy", true) 
                        if Remote_Reset then Remote_Reset:FireServer() end 
                        task_wait(0.5) 
                        for s, h in ipairs(recipe.Items) do 
                            if not _G.Config.CraftEnabled then break end 
                            Evt.UseHerbAlchemy:FireServer(h, _G.Config.CraftYear, s) 
                            task_wait(0.3) 
                        end 
                        if _G.Config.CraftEnabled then 
                            Evt.CraftPill:FireServer(_G.Config.CraftRecipe, YearToGrade[_G.Config.CraftYear], _G.Config.CraftLevel or 10, _G.Config.CraftBulkAmount or 1) 
                        end 
                    end 
                    task_wait(0.2) 
                end 
                _G.Config.CraftEnabled = false 
            end) 
        end 
    end})
    
    TabCraft:CreateRecipeBoard(CraftRecipes)

    -- =============================================================
    -- TAB 5: CÀI ĐẶT (SETTINGS) - NÂNG CẤP TỐI ƯU PC
    -- =============================================================
    local TabSettings = Window:CreateTab("⚙ Cài đặt")
    
    TabSettings:CreateSection("Tối ưu hóa SIÊU CẤP (Cho PC yếu)")
    -- NÚT: SIÊU GIẢM RAM (POTATO MODE)
    TabSettings:CreateButton({ Name = "🥔 Chế độ Khoai Tây (Tối ưu RAM/CPU)", Callback = function() 
        UltraRAMClean() 
    end})
    
    -- NÚT: MÀN HÌNH TRẮNG (Tắt 3D Rendering)
    TabSettings:CreateToggle({ Name = "📺 Màn hình trắng (Tắt GPU 100%)", CurrentValue = false, Callback = function(V) 
        RS:Set3dRenderingEnabled(not V) 
        if V then 
            -- Khi bật màn hình trắng, hiển thị thông báo tiết kiệm điện
            StatusLabel:Set("GPU ĐANG ĐƯỢC NGHỈ NGƠI...")
        else
            StatusLabel:Set("Trạng thái: Đang nghỉ")
        end
    end})

    TabSettings:CreateToggle({ Name = "🔥 Xóa Map Triệt Để", CurrentValue = false, Callback = function(V) 
        _G.Config.DestroyMap = V 
        if V then NukeMap() end 
    end})
    
    TabSettings:CreateSection("Thiết lập PC/Mobile")
    TabSettings:CreateKeybind({Name = "Phím Bật/Tắt GUI (PC)", CurrentKey = CurrentToggleKey, Callback = function(Key) CurrentToggleKey = Key end})
    TabSettings:CreateToggle({ Name = "Hiện nút Mobile (Góc trái)", CurrentValue = ShowMobileButton, Callback = function(V) if V then CreateMobileButton() else if MobileBtnInstance then MobileBtnInstance:Destroy() end end end})
    
    TabSettings:CreateSection("Tốc độ & Độ trễ")
    TabSettings:CreateSlider({ Name = "Độ trễ Tele Farm", Range = {0.5, 5}, Increment = 0.5, CurrentValue = 1.5, Callback = function(V) _G.Config.SyncDelay = V end})
    TabSettings:CreateSlider({ Name = "Chờ giữa các điểm tele Loop", Range = {0, 60}, Increment = 0.5, CurrentValue = 2.0, Callback = function(V) _G.Config.WaypointDelay = V end})
    
    TabSettings:CreateSection("Quản lý cấu hình")
    TabSettings:CreateInput({ Name = "Tên cấu hình", PlaceholderText = "VD: FarmSam", Callback = function(Text) InputProfileName = Text end})
    TabSettings:CreateButton({ Name = "💾 Lưu / Tạo cấu hình", Callback = function() SaveUserProfile(InputProfileName) end})
    local ProfileDropdown = TabSettings:CreateDropdown({ Name = "Chọn cấu hình", Options = GetMyProfiles(), CurrentOption = "", Callback = function(Option) SelectedProfile = Option[1] end})
    TabSettings:CreateButton({ Name = "📂 Tải cấu hình", Callback = function() LoadUserProfile(SelectedProfile) UpdateKeys() WaypointLabel:Set("Điểm đã lưu: " .. #_G.Config.Waypoints) end})
    TabSettings:CreateButton({ Name = "🔄 Làm mới danh sách", Callback = function() ProfileDropdown:Refresh(GetMyProfiles(), true) end})

    Rayfield:LoadConfiguration()
    
    -- Vòng lặp giải phóng RAM định kỳ (Mỗi 5 phút)
    task_spawn(function()
        while IsAlive() do
            task_wait(300)
            collectgarbage("collect")
        end
    end)
end)

--- END OF FILE ---
