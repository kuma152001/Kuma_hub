-- ╔══════════════════════════════════════════════════════╗
-- ║           KUMA HUB — Be a Lucky Block               ║
-- ║         Full Rewrite with Custom Per-Rarity GUI     ║
-- ╚══════════════════════════════════════════════════════╝

pcall(function() _G.ScriptRunning = false end)
task.wait(0.5)
pcall(function()
    for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
        if gui.Name == "KumaHub" or gui.Name == "Fluent" or gui.Name == "Rayfield" then
            pcall(function() gui:Destroy() end)
        end
    end
end)
task.wait(0.3)
_G.ScriptRunning = true

-- ════════════════════════════════════════════════════════
--  SERVICES & LOCALS
-- ════════════════════════════════════════════════════════
local Players       = game:GetService("Players")
local RS            = game:GetService("ReplicatedStorage")
local TweenService  = game:GetService("TweenService")
local UIS           = game:GetService("UserInputService")
local VirtualUser   = game:GetService("VirtualUser")
local player        = Players.LocalPlayer
local mouse         = player:GetMouse()

local knit = RS
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.7.0")
    :WaitForChild("knit")
    :WaitForChild("Services")

-- ════════════════════════════════════════════════════════
--  REMOTES
-- ════════════════════════════════════════════════════════
local claimGift       = knit:WaitForChild("PlaytimeRewardService"):WaitForChild("RF"):WaitForChild("ClaimGift")
local rebirth         = knit:WaitForChild("RebirthService"):WaitForChild("RF"):WaitForChild("Rebirth")
local claimPass       = knit:WaitForChild("SeasonPassService"):WaitForChild("RF"):WaitForChild("ClaimPassReward")
local redeemCode      = knit:WaitForChild("CodesService"):WaitForChild("RF"):WaitForChild("RedeemCode")
local buySkin         = knit:WaitForChild("SkinService"):WaitForChild("RF"):WaitForChild("BuySkin")
local sellRemote      = knit:WaitForChild("InventoryService"):WaitForChild("RF"):WaitForChild("SellBrainrot")
local pickupRemote    = knit:WaitForChild("ContainerService"):WaitForChild("RF"):WaitForChild("PickupBrainrot")
local upgradeSpd      = knit:WaitForChild("UpgradesService"):WaitForChild("RF"):WaitForChild("Upgrade")
local upgradeBR       = knit:WaitForChild("ContainerService"):WaitForChild("RF"):WaitForChild("UpgradeBrainrot")

-- ════════════════════════════════════════════════════════
--  BRAINROT DATA
-- ════════════════════════════════════════════════════════
local RARITY_ORDER = {"Normal","Candy","Gold","Diamond","Void"}
local RARITY_COLOR = {
    Normal  = Color3.fromRGB(156,163,175),
    Candy   = Color3.fromRGB(236, 72,153),
    Gold    = Color3.fromRGB(245,158, 11),
    Diamond = Color3.fromRGB( 59,130,246),
    Void    = Color3.fromRGB(139, 92,246),
}

-- keepState[name] = { keepAll=bool, rarities={Normal=bool,...} }
local keepState = {}

local BRAINROT_LIST = {
    -- { name, section, defaultRarity }
    -- SPECIAL
    {name="La Vacca Saturno Saturnita",  section="Special", rarity="Void"},
    {name="Las Vaquitas Saturnitas",      section="Special", rarity="Diamond"},
    {name="Agarrini Lapalini",            section="Special", rarity="Diamond"},
    {name="Pipi Potato",                  section="Special", rarity="Gold"},
    {name="Graipus Medus",               section="Special", rarity="Gold"},
    {name="Tigrullini Watermellini",      section="Special", rarity="Gold"},
    {name="Dragoni Cannelloni",           section="Special", rarity="Gold"},
    {name="Boneca Ambalabu",              section="Special", rarity="Gold"},
    {name="Karkirkur",                    section="Special", rarity="Candy"},
    {name="Luminous Yoni",               section="Special", rarity="Diamond"},
    {name="67",                           section="Special", rarity="Normal"},
    {name="Meow!",                        section="Special", rarity="Candy"},
    {name="Chachechi",                    section="Special", rarity="Gold"},
    {name="Strawberry Elephant",          section="Special", rarity="Gold"},
    -- CYBER
    {name="To To To Sahur",              section="Cyber",   rarity="Void"},
    -- ANGELIC
    {name="Angelzini Bananini",          section="Angelic", rarity="Diamond"},
    {name="Angela Larila",               section="Angelic", rarity="Diamond"},
    {name="Angel Bisonte Giuppitere",    section="Angelic", rarity="Diamond"},
    {name="Angel Job Job Sahur",         section="Angelic", rarity="Gold"},
    {name="Angelinni Octossini",         section="Angelic", rarity="Gold"},
    -- DEMONIC
    {name="Devilcino Assassino",         section="Demonic", rarity="Void"},
    {name="Devupat Kepat Prekupat",      section="Demonic", rarity="Diamond"},
    {name="Diavolero Tralala",           section="Demonic", rarity="Diamond"},
    {name="Malamevil",                   section="Demonic", rarity="Diamond"},
    {name="Devilivion",                  section="Demonic", rarity="Void"},
}

-- Init keep state: default giữ tất cả
for _, b in ipairs(BRAINROT_LIST) do
    keepState[b.name] = {
        keepAll  = true,
        rarities = {Normal=true, Candy=true, Gold=true, Diamond=true, Void=true},
    }
end

-- ════════════════════════════════════════════════════════
--  HELPER UTILS
-- ════════════════════════════════════════════════════════
local suffix = {K=1e3,M=1e6,B=1e9,T=1e12,Qa=1e15,Qi=1e18,Sx=1e21,Sp=1e24,Oc=1e27,No=1e30,Dc=1e33}
local function parseCash(text)
    text = text:gsub("%$",""):gsub(",",""):gsub("%s+","")
    local num = tonumber(text:match("[%d%.]+"))
    local suf = text:match("%a+")
    if not num then return 0 end
    if suf and suffix[suf] then return num * suffix[suf] end
    return num
end

local skins = {
    "prestige_mogging_luckyblock","mogging_luckyblock","colossus_luckyblock",
    "inferno_luckyblock","divine_luckyblock","spirit_luckyblock",
    "cyborg_luckyblock","void_luckyblock","gliched_luckyblock",
    "lava_luckyblock","freezy_luckyblock","fairy_luckyblock"
}

local function findMyPlot()
    local pf = workspace:FindFirstChild("Plots")
    if not pf then return nil end
    for _, outer in pairs(pf:GetChildren()) do
        local inner = outer:FindFirstChild(outer.Name)
        if inner then
            for _, v in pairs(inner:GetDescendants()) do
                if v:IsA("BillboardGui") and v.Name:find(player.Name) then return inner end
            end
        end
    end
    return nil
end

local function getMyModel()
    local f = workspace:FindFirstChild("RunningModels")
    if not f then return nil end
    for _, m in ipairs(f:GetChildren()) do
        if m:GetAttribute("OwnerId") == player.UserId then return m end
    end
    return nil
end

-- ════════════════════════════════════════════════════════
--  SELL LOGIC (Per-Rarity)
-- ════════════════════════════════════════════════════════
local function getBrainrotInfo(item)
    local rarity, name = "Normal", ""
    local rl = item:FindFirstChild("Rarity", true)
    if rl and rl:IsA("TextLabel") then rarity = rl.Text end
    local tf = item:FindFirstChild("Title", true)
    if tf then
        local tl = tf:FindFirstChild("TextLabel")
        if tl then name = tl.Text end
    end
    if name == "" then
        for _, c in pairs(item:GetDescendants()) do
            if c:IsA("TextLabel") and c.Name == "TextLabel" then
                local t = c.Text
                if t ~= "" and not t:find("%$") and t ~= "Sell $" then name = t; break end
            end
        end
    end
    return name, rarity
end

local function shouldSellBrainrot(name, rarity)
    local s = keepState[name]
    if not s then return true end -- không có trong danh sách → bán
    if s.keepAll then return false end
    return not (s.rarities[rarity] == true)
end

local function sellBrainrots()
    local count = 0
    pcall(function()
        local sf = player.PlayerGui.Windows.SellBrainrots.ShopContainer.ScrollingFrame
        for _, item in pairs(sf:GetChildren()) do
            local entityId = item:GetAttribute("EntityId")
            if not entityId then continue end
            local name, rarity = getBrainrotInfo(item)
            if shouldSellBrainrot(name, rarity) then
                pcall(function() sellRemote:InvokeServer(entityId) end)
                count = count + 1
                task.wait(0.1)
            end
        end
    end)
    return count
end

-- ════════════════════════════════════════════════════════
--  GUI BUILDER
-- ════════════════════════════════════════════════════════
local CoreGui = game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KumaHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- ── COLORS ──────────────────────────────────────────────
local C = {
    bg        = Color3.fromRGB(15, 15, 20),
    surface   = Color3.fromRGB(22, 22, 30),
    surface2  = Color3.fromRGB(30, 30, 40),
    border    = Color3.fromRGB(50, 50, 68),
    accent    = Color3.fromRGB(99,102,241),
    accentHov = Color3.fromRGB(129,140,248),
    text      = Color3.fromRGB(240,240,255),
    textMuted = Color3.fromRGB(130,130,160),
    textDim   = Color3.fromRGB( 80, 80,110),
    success   = Color3.fromRGB( 52,211,153),
    warn      = Color3.fromRGB(251,191, 36),
    danger    = Color3.fromRGB(239, 68, 68),
    white     = Color3.fromRGB(255,255,255),
}

-- ── TWEEN HELPERS ────────────────────────────────────────
local function tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

-- ── INSTANCE FACTORY ────────────────────────────────────
local function mk(class, props, parent)
    local inst = Instance.new(class)
    for k,v in pairs(props or {}) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

local function frame(props, parent)
    props.BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(0,0,0)
    props.BackgroundTransparency = props.BackgroundTransparency or 1
    props.BorderSizePixel = 0
    return mk("Frame", props, parent)
end

local function label(props, parent)
    props.BackgroundTransparency = 1
    props.BorderSizePixel = 0
    props.Font = props.Font or Enum.Font.GothamMedium
    props.TextColor3 = props.TextColor3 or C.text
    props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    return mk("TextLabel", props, parent)
end

local function btn(props, parent)
    props.BackgroundColor3 = props.BackgroundColor3 or C.surface2
    props.BorderSizePixel = 0
    props.Font = props.Font or Enum.Font.GothamMedium
    props.TextColor3 = props.TextColor3 or C.text
    props.AutoButtonColor = false
    local b = mk("TextButton", props, parent)
    mk("UICorner", {CornerRadius=UDim.new(0,6)}, b)
    b.MouseEnter:Connect(function() tween(b, {BackgroundColor3=C.surface2:Lerp(C.white,0.07)}) end)
    b.MouseLeave:Connect(function() tween(b, {BackgroundColor3=props.BackgroundColor3}) end)
    b.MouseButton1Down:Connect(function() tween(b, {BackgroundColor3=C.accent}, 0.08) end)
    b.MouseButton1Up:Connect(function() tween(b, {BackgroundColor3=props.BackgroundColor3}) end)
    return b
end

local function corner(r, parent)
    return mk("UICorner", {CornerRadius=UDim.new(0,r)}, parent)
end
local function stroke(t, color, parent)
    return mk("UIStroke", {Thickness=t, Color=color or C.border, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, parent)
end
local function padding(a,b2,c,d2, parent)
    return mk("UIPadding",{PaddingTop=UDim.new(0,a),PaddingRight=UDim.new(0,b2),PaddingBottom=UDim.new(0,c),PaddingLeft=UDim.new(0,d2)},parent)
end
local function listLayout(pad, parent)
    return mk("UIListLayout",{Padding=UDim.new(0,pad),SortOrder=Enum.SortOrder.LayoutOrder,FillDirection=Enum.FillDirection.Vertical},parent)
end

-- ════════════════════════════════════════════════════════
--  MAIN WINDOW
-- ════════════════════════════════════════════════════════
local Main = frame({
    Size = UDim2.new(0,520,0,580),
    Position = UDim2.new(0.5,-260,0.5,-290),
    BackgroundColor3 = C.bg,
    BackgroundTransparency = 0,
    ClipsDescendants = true,
}, ScreenGui)
corner(12, Main)
stroke(1, C.border, Main)

-- Drag
do
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = inp.Position
            startPos  = Main.Position
        end
    end)
    Main.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ── TITLE BAR ───────────────────────────────────────────
local TitleBar = frame({
    Size = UDim2.new(1,0,0,44),
    BackgroundColor3 = C.surface,
    BackgroundTransparency = 0,
}, Main)
stroke(1, C.border, TitleBar)

label({
    Size = UDim2.new(1,-100,1,0),
    Position = UDim2.new(0,14,0,0),
    Text = "🎲  Kuma Hub",
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextColor3 = C.text,
}, TitleBar)

local CloseBtn = btn({
    Size = UDim2.new(0,28,0,28),
    Position = UDim2.new(1,-38,0.5,-14),
    Text = "✕",
    TextSize = 13,
    BackgroundColor3 = C.danger,
    TextColor3 = C.white,
}, TitleBar)
corner(6, CloseBtn)
CloseBtn.MouseButton1Click:Connect(function()
    _G.ScriptRunning = false
    tween(Main, {Size=UDim2.new(0,520,0,0)}, 0.2)
    task.wait(0.22)
    ScreenGui:Destroy()
end)

local MinBtn = btn({
    Size = UDim2.new(0,28,0,28),
    Position = UDim2.new(1,-70,0.5,-14),
    Text = "—",
    TextSize = 13,
    BackgroundColor3 = C.warn,
    TextColor3 = Color3.fromRGB(60,40,0),
}, TitleBar)
corner(6, MinBtn)
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        tween(Main, {Size=UDim2.new(0,520,0,44)}, 0.2)
    else
        tween(Main, {Size=UDim2.new(0,520,0,580)}, 0.2)
    end
end)

-- ── NOTIFY SYSTEM ───────────────────────────────────────
local NotifyStack = frame({Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,0,44)}, Main)
mk("UIListLayout",{Padding=UDim.new(0,2),FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder},NotifyStack)

local function notify(msg, color)
    color = color or C.accent
    local n = frame({
        Size = UDim2.new(1,0,0,28),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.15,
        ClipsDescendants = true,
    }, NotifyStack)
    corner(4, n)
    label({
        Size = UDim2.new(1,-10,1,0),
        Position = UDim2.new(0,8,0,0),
        Text = msg,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextColor3 = C.white,
    }, n)
    task.delay(3, function()
        tween(n, {BackgroundTransparency=1}, 0.3)
        tween(n, {Size=UDim2.new(1,0,0,0)}, 0.3)
        task.wait(0.35)
        pcall(function() n:Destroy() end)
    end)
end

-- ── TAB BAR ─────────────────────────────────────────────
local TabBar = frame({
    Size = UDim2.new(1,0,0,36),
    Position = UDim2.new(0,0,0,44),
    BackgroundColor3 = C.surface,
    BackgroundTransparency = 0,
}, Main)
stroke(1, C.border, TabBar)
padding(0,8,0,8, TabBar)
mk("UIListLayout",{Padding=UDim.new(0,4),FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder},TabBar)

-- ── CONTENT AREA ────────────────────────────────────────
local Content = frame({
    Size = UDim2.new(1,0,1,-80),
    Position = UDim2.new(0,0,0,80),
    ClipsDescendants = true,
}, Main)

-- ── SCROLL FRAME FACTORY ────────────────────────────────
local function makeScrollPage()
    local sf = mk("ScrollingFrame",{
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.accent,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, Content)
    padding(8,8,8,8, sf)
    listLayout(6, sf)
    return sf
end

-- ════════════════════════════════════════════════════════
--  COMPONENT LIBRARY
-- ════════════════════════════════════════════════════════

-- Section Header
local function mkSection(text, parent)
    local h = frame({Size=UDim2.new(1,0,0,24),BackgroundTransparency=1}, parent)
    local line = frame({Size=UDim2.new(1,-80,0,1),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=C.border,BackgroundTransparency=0}, h)
    label({
        Size=UDim2.new(0,80,1,0),Position=UDim2.new(1,-80,0,0),
        Text=text, TextSize=11, Font=Enum.Font.GothamBold,
        TextColor3=C.textDim, TextXAlignment=Enum.TextXAlignment.Right,
    }, h)
    return h
end

-- Toggle Row
local function mkToggle(labelText, defaultVal, callback, parent)
    local row = frame({
        Size=UDim2.new(1,0,0,36),
        BackgroundColor3=C.surface,
        BackgroundTransparency=0,
    }, parent)
    corner(8, row)
    stroke(1, C.border, row)
    padding(0,10,0,12, row)

    label({
        Size=UDim2.new(1,-46,1,0),
        Text=labelText, TextSize=12,
        TextColor3=C.text, TextWrapped=true,
    }, row)

    local track = frame({
        Size=UDim2.new(0,34,0,18),
        Position=UDim2.new(1,-34,0.5,-9),
        BackgroundColor3=defaultVal and C.accent or C.border,
        BackgroundTransparency=0,
    }, row)
    corner(9, track)

    local thumb = frame({
        Size=UDim2.new(0,12,0,12),
        Position=defaultVal and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6),
        BackgroundColor3=C.white,
        BackgroundTransparency=0,
    }, track)
    corner(6, thumb)

    local state = defaultVal
    local clickable = mk("TextButton",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",
    }, row)

    clickable.MouseButton1Click:Connect(function()
        state = not state
        tween(track, {BackgroundColor3=state and C.accent or C.border})
        tween(thumb, {Position=state and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)})
        callback(state)
    end)
    -- expose setter
    return {
        frame = row,
        set = function(v)
            state = v
            tween(track, {BackgroundColor3=v and C.accent or C.border})
            tween(thumb, {Position=v and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)})
        end,
        get = function() return state end,
    }
end

-- Button Row
local function mkButton(labelText, accentColor, callback, parent)
    accentColor = accentColor or C.accent
    local b = btn({
        Size=UDim2.new(1,0,0,34),
        Text=labelText, TextSize=12,
        BackgroundColor3=accentColor,
        TextColor3=C.white,
        Font=Enum.Font.GothamMedium,
    }, parent)
    corner(8, b)
    b.MouseEnter:Connect(function() tween(b,{BackgroundColor3=accentColor:Lerp(C.white,0.12)}) end)
    b.MouseLeave:Connect(function() tween(b,{BackgroundColor3=accentColor}) end)
    b.MouseButton1Click:Connect(callback)
    return b
end

-- Slider Row
local function mkSlider(labelText, min_, max_, default, callback, parent)
    local wrap = frame({Size=UDim2.new(1,0,0,52),BackgroundColor3=C.surface,BackgroundTransparency=0}, parent)
    corner(8, wrap)
    stroke(1, C.border, wrap)
    padding(6,10,6,12, wrap)

    local topRow = frame({Size=UDim2.new(1,0,0,18)}, wrap)
    label({Size=UDim2.new(0.8,0,1,0),Text=labelText,TextSize=12,TextColor3=C.text}, topRow)
    local valLabel = label({
        Size=UDim2.new(0.2,0,1,0),Position=UDim2.new(0.8,0,0,0),
        Text=tostring(default), TextSize=12, TextColor3=C.accentHov,
        TextXAlignment=Enum.TextXAlignment.Right,
    }, topRow)

    local trackBg = frame({
        Size=UDim2.new(1,0,0,4),Position=UDim2.new(0,0,1,-2),
        BackgroundColor3=C.border,BackgroundTransparency=0,
    }, wrap)
    corner(2, trackBg)

    local fill = frame({
        Size=UDim2.new((default-min_)/(max_-min_),0,1,0),
        BackgroundColor3=C.accent,BackgroundTransparency=0,
    }, trackBg)
    corner(2, fill)

    local value = default
    local draggingSlider = false

    local hitbox = mk("TextButton",{
        Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,1,-12),
        BackgroundTransparency=1, Text="",
    }, wrap)

    local function updateFromX(x)
        local abs = hitbox.AbsolutePosition.X
        local w   = hitbox.AbsoluteSize.X
        local pct = math.clamp((x - abs) / w, 0, 1)
        value = math.floor(min_ + pct * (max_ - min_))
        fill.Size = UDim2.new(pct,0,1,0)
        valLabel.Text = tostring(value)
        callback(value)
    end

    hitbox.MouseButton1Down:Connect(function() draggingSlider=true; updateFromX(mouse.X) end)
    hitbox.MouseButton1Up:Connect(function() draggingSlider=false end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then draggingSlider=false end
    end)
    UIS.InputChanged:Connect(function(inp)
        if draggingSlider and inp.UserInputType==Enum.UserInputType.MouseMovement then
            updateFromX(mouse.X)
        end
    end)
    return wrap
end

-- Input Row
local function mkInput(labelText, default, callback, parent)
    local wrap = frame({Size=UDim2.new(1,0,0,52),BackgroundColor3=C.surface,BackgroundTransparency=0}, parent)
    corner(8, wrap)
    stroke(1, C.border, wrap)
    padding(6,10,6,12, wrap)

    label({Size=UDim2.new(1,0,0,18),Text=labelText,TextSize=12,TextColor3=C.text}, wrap)

    local box = mk("TextBox",{
        Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,1,-26),
        BackgroundColor3=C.bg,BackgroundTransparency=0,
        BorderSizePixel=0,
        Text=tostring(default),TextSize=12,Font=Enum.Font.Gotham,
        TextColor3=C.text,PlaceholderColor3=C.textDim,
        ClearTextOnFocus=false,
    }, wrap)
    corner(4, box)
    stroke(1, C.border, box)
    padding(0,4,0,4, box)

    box.FocusLost:Connect(function()
        callback(box.Text)
    end)
    return wrap
end

-- ════════════════════════════════════════════════════════
--  TAB SYSTEM
-- ════════════════════════════════════════════════════════
local tabs = {}
local activeTab = nil

local function makeTab(name, icon)
    local page = makeScrollPage()

    local tabBtn = btn({
        Size=UDim2.new(0,0,0,26),
        AutomaticSize=Enum.AutomaticSize.X,
        Text=icon.."  "..name,
        TextSize=11,
        Font=Enum.Font.GothamMedium,
        BackgroundColor3=C.surface2,
        TextColor3=C.textMuted,
    }, TabBar)
    corner(6, tabBtn)
    padding(0,10,0,10, tabBtn)

    local t = {name=name, page=page, btn=tabBtn}

    tabBtn.MouseButton1Click:Connect(function()
        if activeTab then
            activeTab.page.Visible = false
            tween(activeTab.btn, {BackgroundColor3=C.surface2, TextColor3=C.textMuted})
        end
        activeTab = t
        page.Visible = true
        tween(tabBtn, {BackgroundColor3=C.accent, TextColor3=C.white})
    end)

    table.insert(tabs, t)
    return page
end

-- ════════════════════════════════════════════════════════
--  PAGES
-- ════════════════════════════════════════════════════════
local ChinhPage   = makeTab("Chính",    "⚙")
local NangCapPage = makeTab("Nâng Cấp", "⬆")
local BrainrotPage= makeTab("Brainrot", "🤖")
local BanPage     = makeTab("Bán",      "💰")
local ChiSoPage   = makeTab("Chỉ Số",  "📊")

-- Activate first tab
tabs[1].page.Visible = true
tween(tabs[1].btn, {BackgroundColor3=C.accent, TextColor3=C.white})
activeTab = tabs[1]

-- ════════════════════════════════════════════════════════
--  TAB: CHÍNH
-- ════════════════════════════════════════════════════════
do
    local p = ChinhPage
    mkSection("Phần thưởng", p)

    -- Auto Playtime Reward
    local autoClaimingPR = false
    mkToggle("Tự Động Nhận Thưởng Thời Gian Chơi", false, function(state)
        autoClaimingPR = state
        if not state then return end
        task.spawn(function()
            while autoClaimingPR and _G.ScriptRunning do
                for i = 1,12 do
                    if not autoClaimingPR or not _G.ScriptRunning then break end
                    pcall(function() claimGift:InvokeServer(i) end)
                    task.wait(0.25)
                end
                task.wait(1)
            end
        end)
    end, p)

    -- Auto Rebirth
    local runningRebirth = false
    mkToggle("Tự Động Rebirth", false, function(state)
        runningRebirth = state
        if not state then return end
        task.spawn(function()
            while runningRebirth and _G.ScriptRunning do
                pcall(function() rebirth:InvokeServer() end)
                task.wait(1)
            end
        end)
    end, p)

    -- Auto Claim Event Pass
    local runningEPR = false
    mkToggle("Tự Động Nhận Thưởng Sự Kiện (Season Pass)", false, function(state)
        runningEPR = state
        if not state then return end
        task.spawn(function()
            while runningEPR and _G.ScriptRunning do
                pcall(function()
                    local w = player.PlayerGui:FindFirstChild("Windows"); if not w then return end
                    local e = w:FindFirstChild("Event"); if not e then return end
                    local f = e:FindFirstChild("Frame"); if not f then return end
                    local f2= f:FindFirstChild("Frame"); if not f2 then return end
                    local pw= f2:FindFirstChild("Windows"); if not pw then return end
                    local pa= pw:FindFirstChild("Pass"); if not pa then return end
                    local m = pa:FindFirstChild("Main"); if not m then return end
                    local sf= m:FindFirstChild("ScrollingFrame"); if not sf then return end
                    for i=1,10 do
                        if not runningEPR or not _G.ScriptRunning then break end
                        local item = sf:FindFirstChild(tostring(i))
                        if item and item:FindFirstChild("Frame") and item.Frame:FindFirstChild("Free") then
                            local free = item.Frame.Free
                            local locked  = free:FindFirstChild("Locked")
                            local claimed = free:FindFirstChild("Claimed")
                            if claimed and claimed.Visible then continue end
                            if locked and not locked.Visible then
                                pcall(function() claimPass:InvokeServer("Free", i) end)
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end, p)

    mkSection("Shop & Code", p)

    -- Redeem codes
    mkButton("Nhập Tất Cả Code", C.accent, function()
        for _, code in ipairs({"release"}) do
            pcall(function() redeemCode:InvokeServer(code) end)
            task.wait(1)
        end
        notify("✅ Đã nhập tất cả code!", C.success)
    end, p)

    -- Auto Buy Best Luckyblock
    local runningABL = false
    mkToggle("Tự Động Mua Luckyblock Tốt Nhất", false, function(state)
        runningABL = state
        if not state then return end
        task.spawn(function()
            while runningABL and _G.ScriptRunning do
                pcall(function()
                    local gui = player.PlayerGui:FindFirstChild("Windows"); if not gui then return end
                    local ps  = gui:FindFirstChild("PickaxeShop"); if not ps then return end
                    local sf  = ps:FindFirstChild("ShopContainer") and ps.ShopContainer:FindFirstChild("ScrollingFrame")
                    if not sf then return end
                    local cash = player.leaderstats.Cash.Value
                    local bestSkin, bestPrice = nil, 0
                    for _, name in ipairs(skins) do
                        local item = sf:FindFirstChild(name)
                        if item then
                            local b2 = item:FindFirstChild("Main") and item.Main:FindFirstChild("Buy") and item.Main.Buy:FindFirstChild("BuyButton")
                            if b2 and b2.Visible then
                                local cl = b2:FindFirstChild("Cash")
                                if cl then
                                    local price = parseCash(cl.Text)
                                    if cash >= price and price > bestPrice then
                                        bestSkin = name; bestPrice = price
                                    end
                                end
                            end
                        end
                    end
                    if bestSkin then pcall(function() buySkin:InvokeServer(bestSkin) end) end
                end)
                task.wait(0.5)
            end
        end)
    end, p)

    mkSection("Inventory", p)

    -- Sell held brainrot
    mkButton("Bán Brainrot Đang Cầm", Color3.fromRGB(239,68,68), function()
        local char = player.Character or player.CharacterAdded:Wait()
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then notify("⚠ Hãy cầm Brainrot muốn bán!", C.warn); return end
        local eid = tool:GetAttribute("EntityId")
        if not eid then return end
        knit:WaitForChild("InventoryService"):WaitForChild("RF"):WaitForChild("SellBrainrot"):InvokeServer(eid)
        notify("💸 Đã bán: "..tool.Name, C.success)
    end, p)

    -- Pickup all
    mkButton("Thu Gom Tất Cả Brainrot", Color3.fromRGB(16,185,129), function()
        task.spawn(function()
            local myPlot = findMyPlot()
            if not myPlot then notify("⚠ Không tìm thấy plot!", C.warn); return end
            local containers = myPlot:FindFirstChild("Containers"); if not containers then return end
            for i=1,30 do
                local cf = containers:FindFirstChild(tostring(i))
                if cf and cf:FindFirstChild(tostring(i)) then
                    local container = cf[tostring(i)]
                    local inner = container:FindFirstChild("InnerModel")
                    if inner and #inner:GetChildren() > 0 then
                        pcall(function() pickupRemote:InvokeServer(tostring(i)) end)
                        task.wait(0.1)
                    end
                end
            end
            notify("✅ Đã thu gom toàn bộ Brainrot!", C.success)
        end)
    end, p)

    mkSection("Thu Tiền Tự Động", p)

    local collectInterval = 1
    mkSlider("Chu Kỳ Thu Tiền (giây)", 1, 50, 10, function(v) collectInterval = v/10 end, p)

    local sethidden = getgenv().sethiddenproperty
    local function collectCash()
        if not sethidden then return end
        local char = player.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local myPlot = findMyPlot(); if not myPlot then return end
        local containers = myPlot:FindFirstChild("Containers"); if not containers then return end
        for i=1,30 do
            pcall(function()
                local cf = containers:FindFirstChild(tostring(i)); if not cf then return end
                local inner = cf:FindFirstChild(tostring(i)); if not inner then return end
                local col = inner:FindFirstChild("Collection"); if not col then return end
                local pad = col:FindFirstChild("CollectionPad"); if not pad then return end
                local orig = pad.CFrame
                sethidden(pad,"CFrame", hrp.CFrame + Vector3.new(0,-3,0))
                task.wait(0.1)
                sethidden(pad,"CFrame", orig)
            end)
            task.wait(0.05)
        end
    end

    local runningCollect = false
    mkToggle("Tự Động Thu Tiền", false, function(state)
        runningCollect = state
        if not state then return end
        task.spawn(function()
            while runningCollect and _G.ScriptRunning do
                collectCash()
                task.wait(collectInterval)
            end
        end)
    end, p)

    mkButton("Thu Tiền 1 Lần", C.accent, function()
        task.spawn(function()
            collectCash()
            notify("✅ Đã thu toàn bộ tiền!", C.success)
        end)
    end, p)

    mkSection("Tiện Ích", p)

    mkButton("Reset Nhân Vật", Color3.fromRGB(100,100,130), function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
    end, p)

    mkButton("Ẩn / Hiện GUI", Color3.fromRGB(80,80,110), function()
        Main.Visible = not Main.Visible
    end, p)
end

-- ════════════════════════════════════════════════════════
--  TAB: NÂNG CẤP
-- ════════════════════════════════════════════════════════
do
    local p = NangCapPage
    mkSection("Nâng Cấp Tốc Độ", p)

    local upgradeAmount = 1
    local upgradeDelay  = 0.5
    local runningSpeed  = false

    mkInput("Số Lượng Mỗi Lần Nâng Cấp", "1", function(v) upgradeAmount = tonumber(v) or 1 end, p)
    mkSlider("Chu Kỳ (giây ×0.1)", 0, 50, 5, function(v) upgradeDelay = v/10 end, p)

    mkToggle("Tự Động Nâng Cấp Tốc Độ Di Chuyển", false, function(state)
        runningSpeed = state
        if not state then return end
        task.spawn(function()
            while runningSpeed and _G.ScriptRunning do
                pcall(function() upgradeSpd:InvokeServer("MovementSpeed", upgradeAmount) end)
                task.wait(upgradeDelay)
            end
        end)
    end, p)

    mkSection("Nâng Cấp Brainrot (Container)", p)

    local brainrotDelay  = 0.5
    local runningBR1, runningBR2, runningBR3 = false, false, false

    mkSlider("Chu Kỳ Nâng Cấp (giây ×0.1)", 1, 50, 5, function(v) brainrotDelay = v/10 end, p)

    mkToggle("Tự Động Nâng Cấp Tầng 1 (1–10)", false, function(state)
        runningBR1 = state
        if not state then return end
        task.spawn(function()
            while runningBR1 and _G.ScriptRunning do
                for i=1,10 do
                    if not runningBR1 or not _G.ScriptRunning then break end
                    pcall(function() upgradeBR:InvokeServer(tostring(i)) end)
                    task.wait(brainrotDelay)
                end
            end
        end)
    end, p)

    mkToggle("Tự Động Nâng Cấp Tầng 2 (11–20)", false, function(state)
        runningBR2 = state
        if not state then return end
        task.spawn(function()
            while runningBR2 and _G.ScriptRunning do
                for i=11,20 do
                    if not runningBR2 or not _G.ScriptRunning then break end
                    pcall(function() upgradeBR:InvokeServer(tostring(i)) end)
                    task.wait(brainrotDelay)
                end
            end
        end)
    end, p)

    mkToggle("Tự Động Nâng Cấp Tầng 3 (21–30)", false, function(state)
        runningBR3 = state
        if not state then return end
        task.spawn(function()
            while runningBR3 and _G.ScriptRunning do
                for i=21,30 do
                    if not runningBR3 or not _G.ScriptRunning then break end
                    pcall(function() upgradeBR:InvokeServer(tostring(i)) end)
                    task.wait(brainrotDelay)
                end
            end
        end)
    end, p)

    mkButton("Nâng Cấp Tất Cả 1 Lần (1–30)", C.accent, function()
        task.spawn(function()
            for i=1,30 do
                pcall(function() upgradeBR:InvokeServer(tostring(i)) end)
                task.wait(brainrotDelay)
            end
            notify("✅ Đã nâng cấp 30 container!", C.success)
        end)
    end, p)
end

-- ════════════════════════════════════════════════════════
--  TAB: BRAINROT
-- ════════════════════════════════════════════════════════
do
    local p = BrainrotPage
    mkSection("Điều Khiển Boss", p)

    local storedParts = {}
    local bossFolder  = workspace:WaitForChild("BossTouchDetectors")

    mkToggle("Xóa Cạm Bẫy Boss Xấu", false, function(state)
        if state then
            storedParts = {}
            for _, obj in ipairs(bossFolder:GetChildren()) do
                if obj.Name ~= "base14" then
                    table.insert(storedParts, obj)
                    obj.Parent = nil
                end
            end
        else
            for _, obj in ipairs(storedParts) do
                if obj then obj.Parent = bossFolder end
            end
            storedParts = {}
        end
    end, p)

    mkButton("Dịch Chuyển Tất Cả Đến Cuối", Color3.fromRGB(139,92,246), function()
        local modelsFolder = workspace:WaitForChild("RunningModels")
        local target = workspace:WaitForChild("CollectZones"):WaitForChild("base14")
        for _, obj in ipairs(modelsFolder:GetChildren()) do
            if obj:IsA("Model") then
                if obj.PrimaryPart then obj:SetPrimaryPartCFrame(target.CFrame)
                else local part = obj:FindFirstChildWhichIsA("BasePart"); if part then part.CFrame = target.CFrame end end
            elseif obj:IsA("BasePart") then obj.CFrame = target.CFrame end
        end
        notify("✅ Đã dịch chuyển tất cả model!", C.success)
    end, p)

    mkSection("Farm Brainrot", p)

    local runningFarm = false
    mkToggle("Tự Động Farm Brainrot Tốt Nhất", false, function(state)
        runningFarm = state
        if not state then return end
        task.spawn(function()
            while runningFarm and _G.ScriptRunning do
                local character = player.Character or player.CharacterAdded:Wait()
                local root      = character:WaitForChild("HumanoidRootPart")
                local humanoid  = character:WaitForChild("Humanoid")
                local modelsFolder = workspace:WaitForChild("RunningModels")
                local target    = workspace:WaitForChild("CollectZones"):WaitForChild("base14")
                root.CFrame = CFrame.new(715, 39, -2122)
                task.wait(0.3)
                humanoid:MoveTo(Vector3.new(710, 39, -2122))
                local ownedModel = nil
                repeat
                    task.wait(0.3)
                    for _, obj in ipairs(modelsFolder:GetChildren()) do
                        if obj:IsA("Model") and obj:GetAttribute("OwnerId") == player.UserId then
                            ownedModel = obj; break
                        end
                    end
                until ownedModel or not runningFarm or not _G.ScriptRunning
                if not runningFarm or not _G.ScriptRunning then break end
                if ownedModel.PrimaryPart then ownedModel:SetPrimaryPartCFrame(target.CFrame)
                else local part = ownedModel:FindFirstChildWhichIsA("BasePart"); if part then part.CFrame = target.CFrame end end
                task.wait(0.7)
                if ownedModel and ownedModel.Parent == modelsFolder then
                    if ownedModel.PrimaryPart then ownedModel:SetPrimaryPartCFrame(target.CFrame * CFrame.new(0,-5,0))
                    else local part = ownedModel:FindFirstChildWhichIsA("BasePart"); if part then part.CFrame = target.CFrame * CFrame.new(0,-5,0) end end
                end
                repeat task.wait(0.3) until not runningFarm or not _G.ScriptRunning or (ownedModel==nil or ownedModel.Parent~=modelsFolder)
                if not runningFarm or not _G.ScriptRunning then break end
                local oldChar = player.Character
                repeat task.wait(0.2) until not runningFarm or not _G.ScriptRunning or (player.Character~=oldChar and player.Character~=nil)
                if not runningFarm or not _G.ScriptRunning then break end
                task.wait(0.4)
                local newChar = player.Character
                local newRoot = newChar:WaitForChild("HumanoidRootPart")
                newRoot.CFrame = CFrame.new(737, 39, -2118)
                task.wait(2.1)
            end
        end)
    end, p)
end

-- ════════════════════════════════════════════════════════
--  TAB: BÁN BRAINROT (Per-Rarity GUI)
-- ════════════════════════════════════════════════════════
do
    local p = BanPage

    -- ── MASTER TOGGLE ───────────────────────────────────
    mkSection("Cài Đặt Tổng", p)

    local masterToggle = mkToggle("Giữ Tất Cả Brainrot (bật = không bán gì)", true, function(state)
        for _, b in ipairs(BRAINROT_LIST) do
            keepState[b.name].keepAll = state
        end
    end, p)

    -- ── BRAINROT CARDS ──────────────────────────────────
    local lastSection = ""
    local sectionIcons = {Special="★ ",Cyber="◈ ",Angelic="✦ ",Demonic="◆ "}

    for _, b in ipairs(BRAINROT_LIST) do
        local bname = b.name

        if b.section ~= lastSection then
            lastSection = b.section
            mkSection((sectionIcons[b.section] or "")..b.section, p)
        end

        -- Card container
        local card = frame({
            Size = UDim2.new(1,0,0,42),
            BackgroundColor3 = C.surface,
            BackgroundTransparency = 0,
            ClipsDescendants = true,
        }, p)
        corner(8, card)
        stroke(1, C.border, card)

        -- Rarity dot
        local dot = frame({
            Size = UDim2.new(0,7,0,7),
            Position = UDim2.new(0,10,0.5,-3.5),
            BackgroundColor3 = RARITY_COLOR[b.rarity] or C.textDim,
            BackgroundTransparency = 0,
        }, card)
        corner(4, dot)

        -- Name label
        label({
            Size = UDim2.new(1,-170,1,0),
            Position = UDim2.new(0,24,0,0),
            Text = bname,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            TextColor3 = C.text,
            TextWrapped = false,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, card)

        -- Rarity badge
        local badgeColors = {
            Normal  = {bg=Color3.fromRGB(40,40,50),  tx=Color3.fromRGB(180,180,200)},
            Candy   = {bg=Color3.fromRGB(80,20,60),  tx=Color3.fromRGB(249,168,212)},
            Gold    = {bg=Color3.fromRGB(80,55,10),  tx=Color3.fromRGB(253,230,138)},
            Diamond = {bg=Color3.fromRGB(20,40,80),  tx=Color3.fromRGB(147,197,253)},
            Void    = {bg=Color3.fromRGB(50,20,80),  tx=Color3.fromRGB(196,181,253)},
        }
        local bc = badgeColors[b.rarity] or badgeColors.Normal
        local badge = frame({
            Size = UDim2.new(0,56,0,18),
            Position = UDim2.new(1,-130,0.5,-9),
            BackgroundColor3 = bc.bg,
            BackgroundTransparency = 0,
        }, card)
        corner(9, badge)
        label({
            Size = UDim2.new(1,0,1,0),
            Text = b.rarity,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            TextColor3 = bc.tx,
            TextXAlignment = Enum.TextXAlignment.Center,
        }, badge)

        -- Keep-All toggle on card
        local keepTrack = frame({
            Size=UDim2.new(0,34,0,18),
            Position=UDim2.new(1,-46,0.5,-9),
            BackgroundColor3=C.accent,BackgroundTransparency=0,
        }, card)
        corner(9, keepTrack)
        local keepThumb = frame({
            Size=UDim2.new(0,12,0,12),
            Position=UDim2.new(1,-15,0.5,-6),
            BackgroundColor3=C.white,BackgroundTransparency=0,
        }, keepTrack)
        corner(6, keepThumb)

        local keepAllState = true

        -- Expand arrow
        local arrow = label({
            Size=UDim2.new(0,16,1,0),
            Position=UDim2.new(1,-16,0,0),
            Text="▾",TextSize=12,
            TextColor3=C.textDim,
            TextXAlignment=Enum.TextXAlignment.Center,
        }, card)

        -- Rarity sub-panel (hidden by default)
        local rarityPanel = frame({
            Size=UDim2.new(1,-16,0,0),
            Position=UDim2.new(0,8,0,42),
            BackgroundTransparency=1,
            ClipsDescendants=false,
        }, card)
        local rarityPanelLayout = listLayout(4, rarityPanel)

        -- Build rarity rows
        local rarityToggles = {}
        for _, rar in ipairs(RARITY_ORDER) do
            local rrow = frame({
                Size=UDim2.new(1,0,0,28),
                BackgroundColor3=C.surface2,BackgroundTransparency=0,
            }, rarityPanel)
            corner(6, rrow)

            local rdot = frame({
                Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,8,0.5,-3),
                BackgroundColor3=RARITY_COLOR[rar],BackgroundTransparency=0,
            }, rrow)
            corner(3, rdot)

            label({
                Size=UDim2.new(1,-60,1,0),Position=UDim2.new(0,20,0,0),
                Text=rar,TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.textMuted,
            }, rrow)

            local rtrack = frame({
                Size=UDim2.new(0,30,0,16),Position=UDim2.new(1,-38,0.5,-8),
                BackgroundColor3=C.accent,BackgroundTransparency=0,
            }, rrow)
            corner(8, rtrack)
            local rthumb = frame({
                Size=UDim2.new(0,10,0,10),Position=UDim2.new(1,-13,0.5,-5),
                BackgroundColor3=C.white,BackgroundTransparency=0,
            }, rtrack)
            corner(5, rthumb)

            local rState = true
            rarityToggles[rar] = {
                track=rtrack, thumb=rthumb,
                set = function(v)
                    rState = v
                    keepState[bname].rarities[rar] = v
                    tween(rtrack,{BackgroundColor3=v and C.accent or C.border})
                    tween(rthumb,{Position=v and UDim2.new(1,-13,0.5,-5) or UDim2.new(0,3,0.5,-5)})
                end,
                get = function() return rState end,
            }

            local rhit = mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""},rrow)
            local _rar = rar
            rhit.MouseButton1Click:Connect(function()
                if keepAllState then return end
                rarityToggles[_rar].set(not rarityToggles[_rar].get())
            end)
        end

        -- Panel height
        local panelExpanded = false
        local panelH = #RARITY_ORDER * 32

        local function setPanelState(expanded)
            panelExpanded = expanded
            local targetH = expanded and (42 + 8 + panelH) or 42
            tween(card, {Size=UDim2.new(1,0,0,targetH)}, 0.2, Enum.EasingStyle.Quad)
            arrow.Text = expanded and "▴" or "▾"
        end

        -- keepAll toggle click
        local keepHit = mk("TextButton",{
            Size=UDim2.new(0,44,0,30),
            Position=UDim2.new(1,-52,0.5,-15),
            BackgroundTransparency=1,Text="",
        }, card)
        keepHit.MouseButton1Click:Connect(function()
            keepAllState = not keepAllState
            keepState[bname].keepAll = keepAllState
            tween(keepTrack,{BackgroundColor3=keepAllState and C.accent or C.border})
            tween(keepThumb,{Position=keepAllState and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)})
            if keepAllState then
                setPanelState(false)
            end
        end)

        -- expand click (anywhere on card except toggle)
        local expandHit = mk("TextButton",{
            Size=UDim2.new(1,-60,1,0),BackgroundTransparency=1,Text="",
        }, card)
        expandHit.MouseButton1Click:Connect(function()
            if keepAllState then return end
            setPanelState(not panelExpanded)
        end)
    end

    -- ── SELL CONTROLS ───────────────────────────────────
    mkSection("Thực Hiện", p)

    mkButton("Bán Brainrot 1 Lần", Color3.fromRGB(239,68,68), function()
        local count = sellBrainrots()
        notify("💸 Đã bán "..count.." brainrot!", count>0 and C.success or C.textMuted)
    end, p)

    local runningAutoSell = false
    mkToggle("Tự Động Bán Brainrot", false, function(state)
        runningAutoSell = state
        if not state then return end
        task.spawn(function()
            while runningAutoSell and _G.ScriptRunning do
                local count = sellBrainrots()
                if count > 0 then
                    notify("💸 Đã bán "..count.." brainrot!", C.success)
                end
                task.wait(2)
            end
        end)
    end, p)
end

-- ════════════════════════════════════════════════════════
--  TAB: CHỈ SỐ
-- ════════════════════════════════════════════════════════
do
    local p = ChiSoPage
    mkSection("Tốc Độ Luckyblock", p)

    local sliderVal = 1000
    local runningCustomSpeed = false
    local originalSpeed, currentModel = nil, nil

    mkToggle("Bật Tốc Độ Tùy Chỉnh", false, function(state)
        runningCustomSpeed = state
        if not state then
            local m = getMyModel()
            if m and originalSpeed ~= nil then m:SetAttribute("MovementSpeed", originalSpeed) end
            originalSpeed = nil; currentModel = nil
        end
    end, p)

    mkSlider("Tốc Độ Luckyblock", 50, 3000, 1000, function(v) sliderVal = v end, p)

    task.spawn(function()
        while _G.ScriptRunning do
            if runningCustomSpeed then
                local m = getMyModel()
                if m then
                    if m ~= currentModel then
                        currentModel = m
                        originalSpeed = m:GetAttribute("MovementSpeed")
                    end
                    m:SetAttribute("MovementSpeed", sliderVal)
                else currentModel = nil end
            end
            task.wait(0.2)
        end
    end)
end

-- ════════════════════════════════════════════════════════
--  ANTI AFK
-- ════════════════════════════════════════════════════════
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
task.spawn(function()
    while _G.ScriptRunning do
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(0.1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
        task.wait(180)
    end
end)
task.spawn(function()
    while _G.ScriptRunning do
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
        task.wait(240)
    end
end)

-- Notify loaded
task.wait(0.5)
notify("✅ Kuma Hub loaded! Be a Lucky Block", C.accent)
