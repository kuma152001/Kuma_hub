-- ╔══════════════════════════════════════════════════════════════════╗
-- ║                    KumaLib v2.0  •  by Kuma                     ║
-- ║          Standalone GUI Library — Roblox Exploit Ready           ║
-- ║  Tương thích: Xeno, Solara, Synapse X, KRNL, Script-Ware, ...   ║
-- ╠══════════════════════════════════════════════════════════════════╣
-- ║  QUICK API:                                                      ║
-- ║   local K = loadstring(game:HttpGet(URL))()                      ║
-- ║   local Win = K:Window({ Title, Subtitle, Width, Height,         ║
-- ║                           Logo, Theme, ConfigFolder })           ║
-- ║   local Tab = Win:Tab("Name", "icon_id")                         ║
-- ║   local Sec = Tab:Section("Title")                               ║
-- ║   Sec / Tab:Toggle(cfg)  → { Get, Set, OnChange }               ║
-- ║   Sec / Tab:Button(cfg)                                          ║
-- ║   Sec / Tab:Slider(cfg)  → { Get, Set }                         ║
-- ║   Sec / Tab:Input(cfg)   → { Get, Set }                         ║
-- ║   Sec / Tab:Dropdown(cfg)→ { Get, Set }                          ║
-- ║   Sec / Tab:ColorPicker(cfg) → { Get, Set }                     ║
-- ║   Sec / Tab:Keybind(cfg) → { Get, Set }                         ║
-- ║   Sec / Tab:Label(cfg)                                           ║
-- ║   Sec / Tab:Separator()                                          ║
-- ║   Win:Notify({ Title, Message, Color, Duration, Icon })          ║
-- ║   Win:SelectTab(index)                                           ║
-- ║   Win:SetTheme(themeTable)                                       ║
-- ║   Win:ToggleUI()  /  Win:Show()  /  Win:Hide()                   ║
-- ║   Win:Destroy()                                                  ║
-- ║   Win.OnClose  — callback                                        ║
-- ╚══════════════════════════════════════════════════════════════════╝

if _G.__KumaLib_v2 then return _G.__KumaLib_v2 end

-- ══════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════
local TweenService    = game:GetService("TweenService")
local UIS             = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")
local Players         = game:GetService("Players")
local TextService     = game:GetService("TextService")
local HttpService     = game:GetService("HttpService")

local LocalPlayer     = Players.LocalPlayer
local Mouse           = LocalPlayer:GetMouse()

-- ══════════════════════════════════════════
--  DEFAULT THEME  (Amber / Orange)
-- ══════════════════════════════════════════
local DEFAULT_THEME = {
    -- Backgrounds
    bg          = Color3.fromRGB(14, 12, 10),
    bgPanel     = Color3.fromRGB(20, 17, 13),
    bgItem      = Color3.fromRGB(26, 22, 16),
    bgInput     = Color3.fromRGB(12, 10, 8),
    bgHover     = Color3.fromRGB(34, 28, 20),

    -- Borders
    border      = Color3.fromRGB(55, 45, 28),
    borderLight = Color3.fromRGB(80, 65, 38),

    -- Accent (amber-orange)
    accent      = Color3.fromRGB(245, 158, 11),   -- amber-500
    accentDark  = Color3.fromRGB(180, 110, 5),
    accentGlow  = Color3.fromRGB(251, 191, 36),   -- amber-400
    accentDeep  = Color3.fromRGB(120, 70, 2),

    -- Orange secondary
    orange      = Color3.fromRGB(249, 115, 22),   -- orange-500
    orangeLight = Color3.fromRGB(253, 186, 116),

    -- Text
    text        = Color3.fromRGB(255, 245, 225),
    textSub     = Color3.fromRGB(180, 160, 120),
    textDim     = Color3.fromRGB(100, 85, 60),
    textHint    = Color3.fromRGB(60, 50, 35),

    -- Status
    success     = Color3.fromRGB(52, 211, 153),
    warn        = Color3.fromRGB(245, 158, 11),
    danger      = Color3.fromRGB(239, 68, 68),
    info        = Color3.fromRGB(96, 165, 250),

    -- Misc
    white       = Color3.fromRGB(255, 255, 255),
    black       = Color3.fromRGB(0, 0, 0),
    transparent = Color3.fromRGB(0, 0, 0),

    -- Titlebar gradient colors
    titleGrad1  = Color3.fromRGB(30, 22, 10),
    titleGrad2  = Color3.fromRGB(20, 16, 8),

    -- Toggle / Slider fill
    toggleOn    = Color3.fromRGB(245, 158, 11),
    toggleOff   = Color3.fromRGB(45, 38, 25),
    sliderFill  = Color3.fromRGB(245, 158, 11),
    sliderTrack = Color3.fromRGB(35, 30, 18),
}

-- ══════════════════════════════════════════
--  TWEEN HELPER
-- ══════════════════════════════════════════
local function tw(obj, props, t, style, dir)
    if not obj or not obj.Parent then return end
    local ok, err = pcall(function()
        TweenService:Create(obj,
            TweenInfo.new(t or 0.18,
                style or Enum.EasingStyle.Quart,
                dir   or Enum.EasingDirection.Out),
            props
        ):Play()
    end)
end

local function twSpring(obj, props, t)
    tw(obj, props, t or 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

-- ══════════════════════════════════════════
--  INSTANCE FACTORY HELPERS
-- ══════════════════════════════════════════
local function mk(class, props, parent)
    local ok, inst = pcall(Instance.new, class)
    if not ok then return nil end
    for k, v in pairs(props or {}) do
        pcall(function() inst[k] = v end)
    end
    if parent then inst.Parent = parent end
    return inst
end

local function frame(props, parent)
    props.BackgroundTransparency = props.BackgroundTransparency or 1
    props.BorderSizePixel = 0
    return mk("Frame", props, parent)
end

local function label(props, parent)
    props.BackgroundTransparency = 1
    props.BorderSizePixel        = 0
    props.Font                   = props.Font or Enum.Font.GothamMedium
    props.TextColor3             = props.TextColor3 or DEFAULT_THEME.text
    props.TextXAlignment         = props.TextXAlignment or Enum.TextXAlignment.Left
    props.TextYAlignment         = props.TextYAlignment or Enum.TextYAlignment.Center
    props.TextTruncate           = props.TextTruncate or Enum.TextTruncate.AtEnd
    return mk("TextLabel", props, parent)
end

local function corner(r, parent)
    return mk("UICorner", {CornerRadius = UDim.new(0, r or 8)}, parent)
end

local function stroke(t, col, parent)
    return mk("UIStroke", {
        Thickness = t or 1,
        Color = col or DEFAULT_THEME.border,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function padding(top, right, bot, left, parent)
    return mk("UIPadding", {
        PaddingTop    = UDim.new(0, top   or 0),
        PaddingRight  = UDim.new(0, right or 0),
        PaddingBottom = UDim.new(0, bot   or 0),
        PaddingLeft   = UDim.new(0, left  or 0),
    }, parent)
end

local function listLayout(gap, dir, halign, valign, parent)
    return mk("UIListLayout", {
        Padding              = UDim.new(0, gap or 0),
        FillDirection        = dir    or Enum.FillDirection.Vertical,
        HorizontalAlignment  = halign or Enum.HorizontalAlignment.Left,
        VerticalAlignment    = valign or Enum.VerticalAlignment.Top,
        SortOrder            = Enum.SortOrder.LayoutOrder,
    }, parent)
end

local function gradient(c0, c1, rot, parent)
    return mk("UIGradient", {
        Color    = ColorSequence.new(c0, c1),
        Rotation = rot or 90,
    }, parent)
end

-- ══════════════════════════════════════════
--  ICON HELPER  (Roblox image IDs)
--  Trả về "rbxassetid://..." hoặc text emoji
-- ══════════════════════════════════════════
local ICONS = {
    home     = "rbxassetid://7733960981",
    settings = "rbxassetid://7733973796",
    info     = "rbxassetid://7734053495",
    warn     = "rbxassetid://7734053495",
    check    = "rbxassetid://7734057978",
    close    = "rbxassetid://7734053521",
    star     = "rbxassetid://7734049151",
    user     = "rbxassetid://7733960981",
    script   = "rbxassetid://7734053495",
    eye      = "rbxassetid://7734049151",
}

-- ══════════════════════════════════════════
--  CONNECTION POOL HELPER
-- ══════════════════════════════════════════
local function makePool()
    local pool = {}
    local function add(c) table.insert(pool, c) return c end
    local function clean()
        for _, c in ipairs(pool) do pcall(function() c:Disconnect() end) end
        pool = {}
    end
    return add, clean
end

-- ══════════════════════════════════════════
--  ITEM ROW BASE  (shared UI for all items)
-- ══════════════════════════════════════════
local function makeItemRow(parent, height, T)
    T = T or DEFAULT_THEME
    local row = frame({
        Size = UDim2.new(1, 0, 0, height or 40),
        BackgroundColor3 = T.bgItem,
        BackgroundTransparency = 0,
    }, parent)
    corner(8, row)
    local s = stroke(1, T.border, row)
    padding(0, 12, 0, 12, row)

    -- hover effect
    row.MouseEnter:Connect(function()
        tw(row, {BackgroundColor3 = T.bgHover})
        tw(s, {Color = T.borderLight})
    end)
    row.MouseLeave:Connect(function()
        tw(row, {BackgroundColor3 = T.bgItem})
        tw(s, {Color = T.border})
    end)

    return row, s
end

-- ══════════════════════════════════════════
--  SCROLLING PAGE FACTORY
-- ══════════════════════════════════════════
local function makePage(parent)
    local sf = mk("ScrollingFrame", {
        Size                  = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency= 1,
        BorderSizePixel       = 0,
        ScrollBarThickness    = 3,
        ScrollBarImageColor3  = DEFAULT_THEME.accent,
        CanvasSize            = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize   = Enum.AutomaticSize.Y,
        ScrollingDirection    = Enum.ScrollingDirection.Y,
        Visible               = false,
        ElasticBehavior       = Enum.ElasticBehavior.WhenScrollable,
    }, parent)
    padding(8, 10, 12, 10, sf)
    listLayout(6, nil, nil, nil, sf)
    return sf
end

-- ══════════════════════════════════════════
--  KUMA LIB  TABLE
-- ══════════════════════════════════════════
local KumaLib = {}
KumaLib.__index = KumaLib

-- ══════════════════════════════════════════════════════════════
--  WINDOW
-- ══════════════════════════════════════════════════════════════
--[[
    opts = {
        Title        = "My Hub",
        Subtitle     = "v1.0",
        Width        = 580,
        Height       = 620,
        GuiName      = "KumaLib",
        LogoId       = "rbxassetid://...",   -- optional logo image
        Theme        = themeTable,           -- optional custom theme
        HideKey      = Enum.KeyCode.RightAlt,-- toggle key (default RightAlt)
        LoadingTime  = 2,                    -- loading screen duration (0 to skip)
    }
]]
function KumaLib:Window(opts)
    opts = opts or {}
    local T        = opts.Theme    or DEFAULT_THEME
    local W        = opts.Width    or 580
    local H        = opts.Height   or 640
    local TITLE    = opts.Title    or "KumaLib"
    local SUBTITLE = opts.Subtitle or ""
    local GUINAME  = opts.GuiName  or "KumaLibGui"
    local HIDE_KEY = opts.HideKey  or Enum.KeyCode.RightAlt
    local LOGO_ID  = opts.LogoId   or nil
    local LOADING  = opts.LoadingTime ~= nil and opts.LoadingTime or 1.5

    -- Cleanup old GUI
    pcall(function()
        for _, g in ipairs(CoreGui:GetChildren()) do
            if g.Name == GUINAME then g:Destroy() end
        end
    end)

    -- ── ScreenGui ────────────────────────────────────
    local ScreenGui = mk("ScreenGui", {
        Name            = GUINAME,
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        DisplayOrder    = 999,
        IgnoreGuiInset  = true,
    }, CoreGui)

    local addConn, cleanConns = makePool()

    -- ── DROP SHADOW ──────────────────────────────────
    local Shadow = frame({
        Size = UDim2.new(0, W + 40, 0, H + 40),
        Position = UDim2.new(0.5, -(W+40)/2, 0.5, -(H+40)/2),
        BackgroundColor3 = T.black,
        BackgroundTransparency = 0.55,
        ZIndex = 0,
    }, ScreenGui)
    corner(18, Shadow)

    -- ── MAIN FRAME ───────────────────────────────────
    local Main = frame({
        Size     = UDim2.new(0, W, 0, H),
        Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
        BackgroundColor3 = T.bg,
        BackgroundTransparency = 0,
        ClipsDescendants = true,
        ZIndex = 1,
    }, ScreenGui)
    corner(14, Main)
    stroke(1.5, T.border, Main)

    -- Ambient glow on border
    local glowStroke = mk("UIStroke", {
        Thickness = 2,
        Color = T.accent,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Transparency = 0.7,
    }, Main)

    -- ── DRAG ─────────────────────────────────────────
    local dragging, dragStart, startPos = false, nil, nil
    addConn(Main.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = inp.Position
            -- Only drag from top ~50px
            local relY = pos.Y - Main.AbsolutePosition.Y
            if relY <= 50 then
                dragging = true
                dragStart = pos
                startPos = Main.Position
            end
        end
    end))
    addConn(Main.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))
    addConn(UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
            Shadow.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X - 20,
                startPos.Y.Scale, startPos.Y.Offset + d.Y - 20
            )
        end
    end))

    -- ── TITLE BAR ────────────────────────────────────
    local TitleBar = frame({
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = T.titleGrad1,
        BackgroundTransparency = 0,
    }, Main)
    gradient(
        T.titleGrad1,
        T.titleGrad2,
        180, TitleBar
    )
    stroke(1, T.border, TitleBar)

    -- Bottom accent line on titlebar
    local accentLine = frame({
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.accent,
        BackgroundTransparency = 0,
    }, TitleBar)
    gradient(
        T.accentDark,
        T.accentGlow,
        0, accentLine
    )

    -- Logo (optional)
    local titleX = 14
    if LOGO_ID then
        mk("ImageLabel", {
            Size = UDim2.new(0, 28, 0, 28),
            Position = UDim2.new(0, titleX, 0.5, -14),
            BackgroundTransparency = 1,
            Image = LOGO_ID,
        }, TitleBar)
        titleX = titleX + 36
    end

    -- Title text
    label({
        Size = UDim2.new(0, 200, 0, 22),
        Position = UDim2.new(0, titleX, 0, 8),
        Text = TITLE,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextColor3 = T.text,
    }, TitleBar)

    -- Subtitle
    label({
        Size = UDim2.new(0, 200, 0, 14),
        Position = UDim2.new(0, titleX, 0, 29),
        Text = SUBTITLE,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextColor3 = T.textSub,
    }, TitleBar)

    -- Status pill
    local statusPill = frame({
        Size = UDim2.new(0, 70, 0, 18),
        Position = UDim2.new(1, -165, 0.5, -9),
        BackgroundColor3 = T.accentDeep,
        BackgroundTransparency = 0,
    }, TitleBar)
    corner(9, statusPill)
    stroke(1, T.accent, statusPill)
    local statusDot = frame({
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0, 7, 0.5, -3),
        BackgroundColor3 = T.success,
        BackgroundTransparency = 0,
    }, statusPill)
    corner(3, statusDot)
    label({
        Size = UDim2.new(1, -18, 1, 0),
        Position = UDim2.new(0, 17, 0, 0),
        Text = "ACTIVE",
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        TextColor3 = T.accent,
    }, statusPill)

    -- Titlebar buttons
    local function makeTitleBtn(xRight, bgCol, icon, hoverCol)
        local b = mk("TextButton", {
            Size = UDim2.new(0, 26, 0, 26),
            Position = UDim2.new(1, xRight, 0.5, -13),
            BackgroundColor3 = bgCol,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Text = icon,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            TextColor3 = T.white,
            AutoButtonColor = false,
        }, TitleBar)
        corner(6, b)
        b.MouseEnter:Connect(function() tw(b, {BackgroundColor3 = hoverCol or bgCol:Lerp(T.white, 0.2)}) end)
        b.MouseLeave:Connect(function() tw(b, {BackgroundColor3 = bgCol}) end)
        return b
    end

    local BtnClose    = makeTitleBtn(-10,  T.danger,         "✕",  Color3.fromRGB(255, 100, 100))
    local BtnMinimize = makeTitleBtn(-42,  T.accentDeep,     "—",  T.accent)
    local BtnHide     = makeTitleBtn(-74,  Color3.fromRGB(40,35,20), "⊞",  T.accentDark)

    -- ── NOTIFICATION AREA (below titlebar) ───────────
    local NotifyHolder = frame({
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 54),
        ClipsDescendants = false,
        ZIndex = 20,
    }, Main)
    listLayout(4, nil, nil, nil, NotifyHolder)

    -- ── TAB BAR ──────────────────────────────────────
    local SIDEBAR_W = 130
    local Sidebar = frame({
        Size = UDim2.new(0, SIDEBAR_W, 1, -52),
        Position = UDim2.new(0, 0, 0, 52),
        BackgroundColor3 = T.bgPanel,
        BackgroundTransparency = 0,
    }, Main)
    stroke(1, T.border, Sidebar)
    padding(8, 0, 8, 0, Sidebar)
    local sidebarList = listLayout(3, nil, nil, nil, Sidebar)

    -- Sidebar bottom decoration
    local sideBottomLine = frame({
        Size = UDim2.new(0, 2, 0.6, 0),
        Position = UDim2.new(1, -1, 0.2, 0),
        BackgroundColor3 = T.accent,
        BackgroundTransparency = 0.6,
    }, Sidebar)

    -- ── CONTENT AREA ─────────────────────────────────
    local ContentArea = frame({
        Size = UDim2.new(1, -SIDEBAR_W, 1, -52),
        Position = UDim2.new(0, SIDEBAR_W, 0, 52),
        BackgroundColor3 = T.bg,
        BackgroundTransparency = 0,
        ClipsDescendants = true,
    }, Main)

    -- ── LOADING SCREEN ───────────────────────────────
    local LoadingFrame
    if LOADING > 0 then
        LoadingFrame = frame({
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = T.bg,
            BackgroundTransparency = 0,
            ZIndex = 50,
        }, Main)
        corner(14, LoadingFrame)

        -- Logo / spinner area
        local spinnerBg = frame({
            Size = UDim2.new(0, 60, 0, 60),
            Position = UDim2.new(0.5, -30, 0.4, -30),
            BackgroundColor3 = T.accentDeep,
            BackgroundTransparency = 0,
            ZIndex = 51,
        }, LoadingFrame)
        corner(30, spinnerBg)
        stroke(2, T.accent, spinnerBg)

        label({
            Size = UDim2.new(1, 0, 1, 0),
            Text = "🌟",
            TextSize = 26,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 52,
        }, spinnerBg)

        label({
            Size = UDim2.new(0.8, 0, 0, 24),
            Position = UDim2.new(0.1, 0, 0.4, 40),
            Text = TITLE,
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            TextColor3 = T.text,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 51,
        }, LoadingFrame)

        label({
            Size = UDim2.new(0.8, 0, 0, 18),
            Position = UDim2.new(0.1, 0, 0.4, 66),
            Text = "Đang khởi động...",
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextColor3 = T.textSub,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 51,
        }, LoadingFrame)

        -- Progress bar
        local progBg = frame({
            Size = UDim2.new(0.6, 0, 0, 4),
            Position = UDim2.new(0.2, 0, 0.4, 96),
            BackgroundColor3 = T.bgItem,
            BackgroundTransparency = 0,
            ZIndex = 51,
        }, LoadingFrame)
        corner(2, progBg)
        local progFill = frame({
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = T.accent,
            BackgroundTransparency = 0,
            ZIndex = 52,
        }, progBg)
        corner(2, progFill)

        -- Animate progress then hide
        task.spawn(function()
            tw(progFill, {Size = UDim2.new(1, 0, 1, 0)}, LOADING, Enum.EasingStyle.Quad)
            task.wait(LOADING)
            tw(LoadingFrame, {BackgroundTransparency = 1}, 0.3)
            task.wait(0.32)
            pcall(function() LoadingFrame:Destroy() end)
        end)
    end

    -- ══════════════════════════════════════════════════
    --  WINDOW OBJECT
    -- ══════════════════════════════════════════════════
    local Window = {}
    Window.OnClose = nil

    local tabList   = {}
    local activeTab = nil
    local visible   = true
    local minimized = false

    -- ── SetStatus ────────────────────────────────────
    function Window:SetStatus(color, text)
        tw(statusDot, {BackgroundColor3 = color or T.success})
        -- optional: update label
    end

    -- ── SetTheme ─────────────────────────────────────
    function Window:SetTheme(newTheme)
        for k, v in pairs(newTheme) do T[k] = v end
    end

    -- ── ToggleUI / Show / Hide ────────────────────────
    function Window:Show()
        visible = true
        Main.Visible = true
        Shadow.Visible = true
        twSpring(Main, {Size = UDim2.new(0, W, 0, H)}, 0.25)
    end

    function Window:Hide()
        visible = false
        tw(Main, {Size = UDim2.new(0, W, 0, 0)}, 0.2)
        task.delay(0.22, function()
            if not visible then
                Main.Visible = false
                Shadow.Visible = false
            end
        end)
    end

    function Window:ToggleUI()
        if visible then self:Hide() else self:Show() end
    end

    -- Toggle key
    addConn(UIS.InputBegan:Connect(function(inp, processed)
        if not processed and inp.KeyCode == HIDE_KEY then
            Window:ToggleUI()
        end
    end))

    -- ── Minimize ─────────────────────────────────────
    local function toggleMinimize()
        minimized = not minimized
        tw(Main, {Size = UDim2.new(0, W, 0, minimized and 52 or H)}, 0.22)
    end
    BtnMinimize.MouseButton1Click:Connect(toggleMinimize)

    -- ── Close ────────────────────────────────────────
    function Window:Destroy()
        cleanConns()
        tw(Main, {Size = UDim2.new(0, W, 0, 0), BackgroundTransparency = 1}, 0.2)
        tw(Shadow, {BackgroundTransparency = 1}, 0.2)
        task.delay(0.25, function()
            pcall(function() ScreenGui:Destroy() end)
        end)
    end

    BtnClose.MouseButton1Click:Connect(function()
        if Window.OnClose then pcall(Window.OnClose) end
        Window:Destroy()
    end)

    BtnHide.MouseButton1Click:Connect(function() Window:ToggleUI() end)

    -- ── SelectTab ────────────────────────────────────
    function Window:SelectTab(index)
        local t = tabList[index]
        if not t then return end
        if activeTab then
            activeTab.page.Visible = false
            tw(activeTab.btn, {BackgroundColor3 = T.bgItem, TextColor3 = T.textSub})
            tw(activeTab.indicator, {BackgroundTransparency = 1})
            tw(activeTab.icon, {ImageColor3 = T.textDim})
        end
        activeTab = t
        t.page.Visible = true
        tw(t.btn, {BackgroundColor3 = T.accentDeep, TextColor3 = T.accent})
        tw(t.indicator, {BackgroundTransparency = 0})
        tw(t.icon, {ImageColor3 = T.accent})
    end

    -- ══════════════════════════════════════════════════
    --  NOTIFY
    -- ══════════════════════════════════════════════════
    --[[
        Window:Notify({
            Title    = "Title",
            Message  = "Body text",
            Color    = Color3,       -- default: accent
            Duration = 4,            -- seconds
            Icon     = "✔",          -- emoji or nil
        })
    ]]
    function Window:Notify(cfg)
        cfg = cfg or {}
        local color    = cfg.Color    or T.accent
        local duration = cfg.Duration or 4
        local ntitle   = cfg.Title    or ""
        local nmsg     = cfg.Message  or ""
        local nicon    = cfg.Icon     or "🔔"

        local n = frame({
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = T.bgPanel,
            BackgroundTransparency = 0,
            ClipsDescendants = true,
            ZIndex = 30,
        }, NotifyHolder)
        corner(8, n)
        stroke(1, color, n)

        -- Left accent bar
        frame({
            Size = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = color,
            BackgroundTransparency = 0,
            ZIndex = 31,
        }, n)
        corner(2, n)

        label({
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 10, 0, 6),
            Text = nicon, TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 31,
        }, n)

        label({
            Size = UDim2.new(1, -40, 0, 14),
            Position = UDim2.new(0, 34, 0, 5),
            Text = ntitle, TextSize = 11,
            Font = Enum.Font.GothamBold,
            TextColor3 = T.text,
            ZIndex = 31,
        }, n)

        label({
            Size = UDim2.new(1, -40, 0, 12),
            Position = UDim2.new(0, 34, 0, 19),
            Text = nmsg, TextSize = 10,
            Font = Enum.Font.Gotham,
            TextColor3 = T.textSub,
            TextWrapped = true,
            ZIndex = 31,
        }, n)

        -- Animate in
        twSpring(n, {Size = UDim2.new(1, 0, 0, 36)}, 0.25)

        task.delay(duration, function()
            tw(n, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}, 0.25)
            task.wait(0.27)
            pcall(function() n:Destroy() end)
        end)

        return n
    end

    -- ══════════════════════════════════════════════════
    --  TAB
    -- ══════════════════════════════════════════════════
    --[[
        local Tab = Window:Tab("Combat", "rbxassetid://...")
        Returns Tab object with:
          Tab:Section, Tab:Toggle, Tab:Button, Tab:Slider,
          Tab:Input, Tab:Dropdown, Tab:ColorPicker,
          Tab:Keybind, Tab:Label, Tab:Separator, Tab:Custom
    ]]
    function Window:Tab(name, iconId)
        local page = makePage(ContentArea)

        -- Sidebar button
        local tabBtn = frame({
            Size = UDim2.new(1, -16, 0, 34),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundColor3 = T.bgItem,
            BackgroundTransparency = 0,
        }, Sidebar)
        corner(8, tabBtn)
        padding(0, 8, 0, 8, tabBtn)

        -- Left indicator
        local indicator = frame({
            Size = UDim2.new(0, 3, 0.65, 0),
            Position = UDim2.new(0, -9, 0.175, 0),
            BackgroundColor3 = T.accent,
            BackgroundTransparency = 1,
        }, tabBtn)
        corner(2, indicator)

        -- Icon
        local iconImg = mk("ImageLabel", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 2, 0.5, -8),
            BackgroundTransparency = 1,
            Image = iconId or "",
            ImageColor3 = T.textDim,
        }, tabBtn)

        local txtX = iconId and 22 or 4
        local tabLabel = label({
            Size = UDim2.new(1, -(txtX+2), 1, 0),
            Position = UDim2.new(0, txtX, 0, 0),
            Text = name,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            TextColor3 = T.textSub,
        }, tabBtn)

        -- Make clickable
        local clickOverlay = mk("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
        }, tabBtn)

        local t = {
            page      = page,
            btn       = tabBtn,
            indicator = indicator,
            icon      = iconImg,
            label     = tabLabel,
        }

        clickOverlay.MouseButton1Click:Connect(function()
            Window:SelectTab(#tabList)  -- will be overridden below
        end)

        -- Hover
        clickOverlay.MouseEnter:Connect(function()
            if activeTab ~= t then
                tw(tabBtn, {BackgroundColor3 = T.bgHover})
            end
        end)
        clickOverlay.MouseLeave:Connect(function()
            if activeTab ~= t then
                tw(tabBtn, {BackgroundColor3 = T.bgItem})
            end
        end)

        table.insert(tabList, t)
        local myIndex = #tabList

        -- Rewire click to use correct index
        clickOverlay.MouseButton1Click:Connect(function()
            Window:SelectTab(myIndex)
        end)

        -- Auto-activate first tab
        if myIndex == 1 then
            task.defer(function() Window:SelectTab(1) end)
        end

        -- ════════════════════════════════════════════
        --  ITEM BUILDER  (shared by Tab and Section)
        -- ════════════════════════════════════════════
        local function buildItems(targetPage)
            local Items = {}

            -- ── Section ──────────────────────────────
            function Items:Section(sectionTitle)
                local sec = frame({Size = UDim2.new(1, 0, 0, 22)}, targetPage)
                local line = frame({
                    Size = UDim2.new(1, -90, 0, 1),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    BackgroundColor3 = T.border,
                    BackgroundTransparency = 0,
                }, sec)
                local lbl = label({
                    Size = UDim2.new(0, 88, 1, 0),
                    Position = UDim2.new(1, -88, 0, 0),
                    Text = sectionTitle,
                    TextSize = 10,
                    Font = Enum.Font.GothamBold,
                    TextColor3 = T.accent,
                    TextXAlignment = Enum.TextXAlignment.Right,
                }, sec)

                -- Section gets its own Items builder (sub-section)
                return buildItems(targetPage)
            end

            -- ── Separator ────────────────────────────
            function Items:Separator()
                local sep = frame({
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = T.border,
                    BackgroundTransparency = 0,
                }, targetPage)
                return sep
            end

            -- ── Label ────────────────────────────────
            function Items:Label(cfg)
                cfg = cfg or {}
                local lbl = frame({
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = T.bgItem,
                    BackgroundTransparency = 0,
                }, targetPage)
                corner(8, lbl)
                padding(0, 12, 0, 12, lbl)
                label({
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = cfg.Text or "",
                    TextSize = cfg.TextSize or 11,
                    Font = Enum.Font.Gotham,
                    TextColor3 = cfg.Color or T.textSub,
                    TextWrapped = true,
                }, lbl)
                return lbl
            end

            -- ── Toggle ───────────────────────────────
            --[[
                Items:Toggle({
                    Label    = "God Mode",
                    Default  = false,
                    Tooltip  = "Enable god mode",
                    Callback = function(state) end,
                })
                Returns { Get, Set, OnChange }
            ]]
            function Items:Toggle(cfg)
                cfg = cfg or {}
                local defaultVal = cfg.Default  or false
                local cb         = cfg.Callback
                local state      = defaultVal

                local row = frame({
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundColor3 = T.bgItem,
                    BackgroundTransparency = 0,
                }, targetPage)
                corner(8, row)
                local rowStroke = stroke(1, T.border, row)
                padding(0, 12, 0, 12, row)

                label({
                    Size = UDim2.new(1, -52, 1, 0),
                    Text = cfg.Label or "Toggle",
                    TextSize = 12,
                    TextColor3 = T.text,
                    TextWrapped = true,
                }, row)

                -- Track
                local track = frame({
                    Size = UDim2.new(0, 36, 0, 20),
                    Position = UDim2.new(1, -36, 0.5, -10),
                    BackgroundColor3 = state and T.toggleOn or T.toggleOff,
                    BackgroundTransparency = 0,
                }, row)
                corner(10, track)
                stroke(1, state and T.accent or T.border, track)

                -- Thumb
                local thumb = frame({
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = state
                        and UDim2.new(1, -17, 0.5, -7)
                        or  UDim2.new(0, 3, 0.5, -7),
                    BackgroundColor3 = T.white,
                    BackgroundTransparency = 0,
                }, track)
                corner(7, thumb)

                local function setToggle(v, fireCallback)
                    state = v
                    tw(track, {BackgroundColor3 = v and T.toggleOn or T.toggleOff})
                    local ts = stroke(1, v and T.accent or T.border, track)
                    tw(thumb, {
                        Position = v
                            and UDim2.new(1, -17, 0.5, -7)
                            or  UDim2.new(0, 3, 0.5, -7)
                    })
                    if fireCallback ~= false and cb then
                        pcall(cb, state)
                    end
                end

                -- Row hover
                row.MouseEnter:Connect(function() tw(row,{BackgroundColor3=T.bgHover}) end)
                row.MouseLeave:Connect(function() tw(row,{BackgroundColor3=T.bgItem}) end)

                local clickBtn = mk("TextButton",{
                    Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",
                }, row)
                clickBtn.MouseButton1Click:Connect(function()
                    setToggle(not state)
                end)

                return {
                    Get      = function() return state end,
                    Set      = function(v) setToggle(v, true) end,
                    OnChange = function(fn) cb = fn end,
                    Frame    = row,
                }
            end

            -- ── Button ───────────────────────────────
            --[[
                Items:Button({
                    Label    = "Teleport",
                    Color    = Color3,    -- optional
                    Outline  = true,      -- optional outline style
                    Callback = function() end,
                })
            ]]
            function Items:Button(cfg)
                cfg = cfg or {}
                local color   = cfg.Color or T.accent
                local outline = cfg.Outline or false
                local cb      = cfg.Callback

                local b = mk("TextButton", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = outline and T.bgItem or color,
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                }, targetPage)
                corner(8, b)

                if outline then
                    stroke(1.5, color, b)
                end

                label({
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = cfg.Label or "Button",
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextColor3 = outline and color or T.white,
                    TextXAlignment = Enum.TextXAlignment.Center,
                }, b)

                b.MouseEnter:Connect(function()
                    tw(b, {BackgroundColor3 = outline and color:Lerp(T.bgItem, 0.7) or color:Lerp(T.white, 0.15)})
                end)
                b.MouseLeave:Connect(function()
                    tw(b, {BackgroundColor3 = outline and T.bgItem or color})
                end)
                b.MouseButton1Down:Connect(function()
                    tw(b, {BackgroundColor3 = color:Lerp(T.black, 0.15)}, 0.08)
                end)
                b.MouseButton1Up:Connect(function()
                    tw(b, {BackgroundColor3 = outline and T.bgItem or color})
                end)
                b.MouseButton1Click:Connect(function()
                    if cb then pcall(cb) end
                end)

                return b
            end

            -- ── Slider ───────────────────────────────
            --[[
                Items:Slider({
                    Label    = "Walk Speed",
                    Min      = 0,
                    Max      = 100,
                    Default  = 16,
                    Step     = 1,       -- optional, default 1
                    Suffix   = "",      -- optional e.g. "%"
                    Callback = function(value) end,
                })
                Returns { Get, Set }
            ]]
            function Items:Slider(cfg)
                cfg = cfg or {}
                local min_    = cfg.Min     or 0
                local max_    = cfg.Max     or 100
                local step    = cfg.Step    or 1
                local suffix  = cfg.Suffix  or ""
                local cb      = cfg.Callback
                local defVal  = math.clamp(cfg.Default or min_, min_, max_)
                local current = defVal

                local wrap = frame({
                    Size = UDim2.new(1, 0, 0, 54),
                    BackgroundColor3 = T.bgItem,
                    BackgroundTransparency = 0,
                }, targetPage)
                corner(8, wrap)
                stroke(1, T.border, wrap)
                padding(7, 12, 7, 12, wrap)

                -- Header row
                local topRow = frame({Size = UDim2.new(1, 0, 0, 18)}, wrap)
                label({
                    Size = UDim2.new(0.7, 0, 1, 0),
                    Text = cfg.Label or "Slider",
                    TextSize = 12,
                    TextColor3 = T.text,
                }, topRow)
                local valLabel = label({
                    Size = UDim2.new(0.3, 0, 1, 0),
                    Position = UDim2.new(0.7, 0, 0, 0),
                    Text = tostring(defVal)..suffix,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextColor3 = T.accentGlow,
                    TextXAlignment = Enum.TextXAlignment.Right,
                }, topRow)

                -- Track
                local trackBg = frame({
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 1, -10),
                    BackgroundColor3 = T.sliderTrack,
                    BackgroundTransparency = 0,
                }, wrap)
                corner(3, trackBg)

                local pct0 = (defVal - min_) / (max_ - min_)
                local fillBar = frame({
                    Size = UDim2.new(pct0, 0, 1, 0),
                    BackgroundColor3 = T.sliderFill,
                    BackgroundTransparency = 0,
                }, trackBg)
                corner(3, fillBar)
                gradient(T.accentDark, T.accentGlow, 0, fillBar)

                -- Thumb knob
                local knob = frame({
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(pct0, -7, 0.5, -7),
                    BackgroundColor3 = T.white,
                    BackgroundTransparency = 0,
                    ZIndex = 2,
                }, trackBg)
                corner(7, knob)
                stroke(2, T.accent, knob)

                local draggingSlider = false

                local function updateSlider(x)
                    local abs = trackBg.AbsolutePosition.X
                    local sz  = trackBg.AbsoluteSize.X
                    local p   = math.clamp((x - abs) / sz, 0, 1)
                    local raw = min_ + p * (max_ - min_)
                    local snapped = math.floor(raw / step + 0.5) * step
                    snapped = math.clamp(snapped, min_, max_)
                    local finalPct = (snapped - min_) / (max_ - min_)
                    current = snapped
                    fillBar.Size = UDim2.new(finalPct, 0, 1, 0)
                    knob.Position = UDim2.new(finalPct, -7, 0.5, -7)
                    valLabel.Text = tostring(snapped) .. suffix
                    if cb then pcall(cb, snapped) end
                end

                local hitbox = mk("TextButton", {
                    Size = UDim2.new(1, 0, 0, 22),
                    Position = UDim2.new(0, 0, 1, -16),
                    BackgroundTransparency = 1,
                    Text = "",
                }, wrap)
                hitbox.MouseButton1Down:Connect(function()
                    draggingSlider = true
                    updateSlider(Mouse.X)
                end)
                addConn(UIS.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end))
                addConn(UIS.InputChanged:Connect(function(inp)
                    if draggingSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(Mouse.X)
                    end
                end))

                return {
                    Get = function() return current end,
                    Set = function(v)
                        v = math.clamp(v, min_, max_)
                        local p = (v - min_) / (max_ - min_)
                        current = v
                        fillBar.Size = UDim2.new(p, 0, 1, 0)
                        knob.Position = UDim2.new(p, -7, 0.5, -7)
                        valLabel.Text = tostring(v) .. suffix
                    end,
                    Frame = wrap,
                }
            end

            -- ── TextInput ────────────────────────────
            --[[
                Items:Input({
                    Label       = "Player Name",
                    Default     = "",
                    Placeholder = "Enter text...",
                    NumbersOnly = false,
                    Callback    = function(text) end,  -- on FocusLost
                })
                Returns { Get, Set, TextBox }
            ]]
            function Items:Input(cfg)
                cfg = cfg or {}
                local cb = cfg.Callback

                local wrap = frame({
                    Size = UDim2.new(1, 0, 0, 56),
                    BackgroundColor3 = T.bgItem,
                    BackgroundTransparency = 0,
                }, targetPage)
                corner(8, wrap)
                stroke(1, T.border, wrap)
                padding(7, 12, 7, 12, wrap)

                label({
                    Size = UDim2.new(1, 0, 0, 16),
                    Text = cfg.Label or "Input",
                    TextSize = 11,
                    Font = Enum.Font.GothamMedium,
                    TextColor3 = T.textSub,
                }, wrap)

                local boxBg = frame({
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 1, -28),
                    BackgroundColor3 = T.bgInput,
                    BackgroundTransparency = 0,
                }, wrap)
                corner(6, boxBg)
                local boxStroke = stroke(1, T.border, boxBg)

                local box = mk("TextBox", {
                    Size = UDim2.new(1, -8, 1, 0),
                    Position = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Text = tostring(cfg.Default or ""),
                    PlaceholderText = cfg.Placeholder or "",
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextColor3 = T.text,
                    PlaceholderColor3 = T.textHint,
                    ClearTextOnFocus = false,
                }, boxBg)

                box.Focused:Connect(function()
                    tw(boxStroke, {Color = T.accent})
                end)
                box.FocusLost:Connect(function()
                    tw(boxStroke, {Color = T.border})
                    if cb then pcall(cb, box.Text) end
                end)

                if cfg.NumbersOnly then
                    box:GetPropertyChangedSignal("Text"):Connect(function()
                        box.Text = box.Text:gsub("[^%d%.%-]", "")
                    end)
                end

                return {
                    Get     = function() return box.Text end,
                    Set     = function(v) box.Text = tostring(v) end,
                    TextBox = box,
                    Frame   = wrap,
                }
            end

            -- ── Dropdown ─────────────────────────────
            --[[
                Items:Dropdown({
                    Label    = "Team",
                    Options  = {"Red", "Blue", "Green"},
                    Default  = "Red",
                    Multi    = false,   -- multi-select
                    Callback = function(selected) end,
                })
                Returns { Get, Set, Refresh }
            ]]
            function Items:Dropdown(cfg)
                cfg = cfg or {}
                local options    = cfg.Options  or {}
                local multi      = cfg.Multi    or false
                local cb         = cfg.Callback
                local selected   = {}
                local opened     = false

                -- Init default
                if cfg.Default then
                    if multi and type(cfg.Default) == "table" then
                        for _, v in ipairs(cfg.Default) do selected[v] = true end
                    elseif not multi then
                        selected[cfg.Default] = true
                    end
                end

                local function getDisplay()
                    local parts = {}
                    for v in pairs(selected) do table.insert(parts, v) end
                    if #parts == 0 then return "Chọn..." end
                    return table.concat(parts, ", ")
                end

                local wrap = frame({
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = T.bgItem,
                    BackgroundTransparency = 0,
                    ClipsDescendants = false,
                    ZIndex = 5,
                }, targetPage)
                corner(8, wrap)
                local wStroke = stroke(1, T.border, wrap)
                padding(0, 12, 0, 12, wrap)

                label({
                    Size = UDim2.new(0.45, 0, 1, 0),
                    Text = cfg.Label or "Dropdown",
                    TextSize = 12, TextColor3 = T.text,
                    ZIndex = 6,
                }, wrap)

                local dispBtn = mk("TextButton", {
                    Size = UDim2.new(0.53, 0, 0, 24),
                    Position = UDim2.new(0.47, 0, 0.5, -12),
                    BackgroundColor3 = T.bgInput,
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 6,
                }, wrap)
                corner(6, dispBtn)
                stroke(1, T.border, dispBtn)
                padding(0, 6, 0, 6, dispBtn)

                local dispLabel = label({
                    Size = UDim2.new(1, -18, 1, 0),
                    Text = getDisplay(),
                    TextSize = 11,
                    TextColor3 = T.textSub,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 7,
                }, dispBtn)

                label({
                    Size = UDim2.new(0, 14, 1, 0),
                    Position = UDim2.new(1, -14, 0, 0),
                    Text = "▾",
                    TextSize = 11,
                    TextColor3 = T.accent,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex = 7,
                }, dispBtn)

                -- Dropdown panel
                local panel = frame({
                    Size = UDim2.new(0.53, 0, 0, 0),
                    Position = UDim2.new(0.47, 0, 1, 2),
                    BackgroundColor3 = T.bgPanel,
                    BackgroundTransparency = 0,
                    ClipsDescendants = true,
                    ZIndex = 10,
                    Visible = false,
                }, wrap)
                corner(8, panel)
                stroke(1, T.border, panel)
                padding(4, 4, 4, 4, panel)

                local optList = listLayout(2, nil, nil, nil, panel)

                local function buildOptions()
                    for _, c in ipairs(panel:GetChildren()) do
                        if c:IsA("TextButton") or c:IsA("Frame") then c:Destroy() end
                    end
                    for _, opt in ipairs(options) do
                        local isSel = selected[opt]
                        local optBtn = mk("TextButton", {
                            Size = UDim2.new(1, 0, 0, 24),
                            BackgroundColor3 = isSel and T.accentDeep or T.bgItem,
                            BackgroundTransparency = 0,
                            BorderSizePixel = 0,
                            Text = "",
                            AutoButtonColor = false,
                            ZIndex = 11,
                        }, panel)
                        corner(6, optBtn)
                        padding(0, 6, 0, 6, optBtn)
                        label({
                            Size = UDim2.new(1, -18, 1, 0),
                            Text = opt,
                            TextSize = 11,
                            TextColor3 = isSel and T.accent or T.textSub,
                            ZIndex = 12,
                        }, optBtn)
                        if isSel then
                            label({
                                Size = UDim2.new(0, 14, 1, 0),
                                Position = UDim2.new(1, -14, 0, 0),
                                Text = "✓",
                                TextSize = 11,
                                TextColor3 = T.accent,
                                TextXAlignment = Enum.TextXAlignment.Center,
                                ZIndex = 12,
                            }, optBtn)
                        end

                        optBtn.MouseButton1Click:Connect(function()
                            if multi then
                                selected[opt] = not selected[opt] or nil
                            else
                                selected = {[opt] = true}
                                opened = false
                                tw(panel, {Size = UDim2.new(0.53, 0, 0, 0)}, 0.18)
                                task.delay(0.19, function() panel.Visible = false end)
                            end
                            dispLabel.Text = getDisplay()
                            buildOptions()
                            if cb then
                                if multi then
                                    local t2 = {}
                                    for v in pairs(selected) do table.insert(t2, v) end
                                    pcall(cb, t2)
                                else
                                    pcall(cb, opt)
                                end
                            end
                        end)

                        optBtn.MouseEnter:Connect(function() tw(optBtn,{BackgroundColor3=T.bgHover}) end)
                        optBtn.MouseLeave:Connect(function() tw(optBtn,{BackgroundColor3=isSel and T.accentDeep or T.bgItem}) end)
                    end
                end

                buildOptions()

                dispBtn.MouseButton1Click:Connect(function()
                    opened = not opened
                    if opened then
                        local count = #options
                        local panH  = math.min(count * 26 + 8, 160)
                        panel.Visible = true
                        tw(panel, {Size = UDim2.new(0.53, 0, 0, panH)}, 0.2)
                    else
                        tw(panel, {Size = UDim2.new(0.53, 0, 0, 0)}, 0.15)
                        task.delay(0.16, function() panel.Visible = false end)
                    end
                end)

                wrap.MouseEnter:Connect(function() tw(wStroke, {Color = T.borderLight}) end)
                wrap.MouseLeave:Connect(function() tw(wStroke, {Color = T.border}) end)

                return {
                    Get = function()
                        if multi then
                            local t2 = {}
                            for v in pairs(selected) do table.insert(t2, v) end
                            return t2
                        else
                            for v in pairs(selected) do return v end
                        end
                    end,
                    Set = function(v)
                        if multi and type(v) == "table" then
                            selected = {}
                            for _, k in ipairs(v) do selected[k] = true end
                        else
                            selected = {[tostring(v)] = true}
                        end
                        dispLabel.Text = getDisplay()
                        buildOptions()
                    end,
                    Refresh = function(newOpts)
                        options = newOpts
                        selected = {}
                        dispLabel.Text = getDisplay()
                        buildOptions()
                    end,
                    Frame = wrap,
                }
            end

            -- ── ColorPicker ──────────────────────────
            --[[
                Items:ColorPicker({
                    Label    = "ESP Color",
                    Default  = Color3.fromRGB(255,100,0),
                    Callback = function(color) end,
                })
                Returns { Get, Set }
            ]]
            function Items:ColorPicker(cfg)
                cfg = cfg or {}
                local cb      = cfg.Callback
                local current = cfg.Default or Color3.fromRGB(255, 100, 0)
                local opened  = false

                -- H, S, V state
                local H, S, V = Color3.toHSV(current)

                local wrap = frame({
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = T.bgItem,
                    BackgroundTransparency = 0,
                    ClipsDescendants = false,
                    ZIndex = 5,
                }, targetPage)
                corner(8, wrap)
                local wStroke = stroke(1, T.border, wrap)
                padding(0, 12, 0, 12, wrap)

                label({
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Text = cfg.Label or "Color Picker",
                    TextSize = 12, TextColor3 = T.text, ZIndex = 6,
                }, wrap)

                local previewBtn = mk("TextButton", {
                    Size = UDim2.new(0, 38, 0, 22),
                    Position = UDim2.new(1, -38, 0.5, -11),
                    BackgroundColor3 = current,
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Text = "", AutoButtonColor = false, ZIndex = 6,
                }, wrap)
                corner(6, previewBtn)
                stroke(1, T.border, previewBtn)

                -- Picker panel
                local panW, panH = 180, 140
                local panel = frame({
                    Size = UDim2.new(0, panW, 0, panH),
                    Position = UDim2.new(1, -(panW), 1, 4),
                    BackgroundColor3 = T.bgPanel,
                    BackgroundTransparency = 0,
                    ClipsDescendants = true,
                    ZIndex = 15,
                    Visible = false,
                }, wrap)
                corner(10, panel)
                stroke(1, T.border, panel)
                padding(8, 8, 8, 8, panel)

                -- SV Square (hue-fixed, draggable)
                local svBox = frame({
                    Size = UDim2.new(1, 0, 0, 80),
                    BackgroundColor3 = Color3.fromHSV(H, 1, 1),
                    BackgroundTransparency = 0,
                    ZIndex = 16,
                }, panel)
                corner(6, svBox)

                -- White gradient (left→right = saturation)
                mk("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
                    }),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1),
                    }),
                    Rotation = 0,
                }, svBox)

                -- Black gradient (top→bottom = value)
                local svOverlay = frame({
                    Size = UDim2.new(1,0,1,0),
                    BackgroundColor3 = T.black,
                    BackgroundTransparency = 0,
                    ZIndex = 17,
                }, svBox)
                mk("UIGradient", {
                    Color = ColorSequence.new(T.black, T.black),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0),
                    }),
                    Rotation = 90,
                }, svOverlay)

                -- SV cursor
                local svCursor = frame({
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(S, -5, 1 - V, -5),
                    BackgroundColor3 = T.white,
                    BackgroundTransparency = 0,
                    ZIndex = 18,
                }, svBox)
                corner(5, svCursor)
                stroke(2, T.black, svCursor)

                -- Hue bar
                local hueBar = frame({
                    Size = UDim2.new(1, 0, 0, 12),
                    Position = UDim2.new(0, 0, 1, -36),
                    BackgroundColor3 = T.white,
                    BackgroundTransparency = 0,
                    ZIndex = 16,
                }, panel)
                corner(4, hueBar)
                mk("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0/6, Color3.fromHSV(0/6,1,1)),
                        ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6,1,1)),
                        ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6,1,1)),
                        ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6,1,1)),
                        ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6,1,1)),
                        ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6,1,1)),
                        ColorSequenceKeypoint.new(1,   Color3.fromHSV(1,  1,1)),
                    }),
                    Rotation = 0,
                }, hueBar)

                local hueCursor = frame({
                    Size = UDim2.new(0, 4, 1, 4),
                    Position = UDim2.new(H, -2, 0, -2),
                    BackgroundColor3 = T.white,
                    BackgroundTransparency = 0,
                    ZIndex = 17,
                }, hueBar)
                corner(2, hueCursor)
                stroke(1, T.black, hueCursor)

                -- Hex input
                local hexBox = mk("TextBox", {
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 1, -20),
                    BackgroundColor3 = T.bgInput,
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Text = "",
                    TextSize = 10,
                    Font = Enum.Font.Code,
                    TextColor3 = T.text,
                    PlaceholderText = "#RRGGBB",
                    PlaceholderColor3 = T.textHint,
                    ClearTextOnFocus = false,
                    ZIndex = 16,
                }, panel)
                corner(4, hexBox)

                local function toHex(c)
                    return string.format("#%02X%02X%02X",
                        math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
                end

                local function applyColor(h, s, v)
                    H, S, V = h, s, v
                    current = Color3.fromHSV(H, S, V)
                    previewBtn.BackgroundColor3 = current
                    svBox.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                    svCursor.Position = UDim2.new(S, -5, 1 - V, -5)
                    hueCursor.Position = UDim2.new(H, -2, 0, -2)
                    hexBox.Text = toHex(current)
                    if cb then pcall(cb, current) end
                end

                applyColor(H, S, V)

                -- SV drag
                local draggingSV = false
                local svHit = mk("TextButton", {
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1, Text = "", ZIndex = 19,
                }, svBox)
                svHit.MouseButton1Down:Connect(function() draggingSV = true end)
                addConn(UIS.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = false end
                end))
                addConn(UIS.InputChanged:Connect(function(i)
                    if draggingSV and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local ax = svBox.AbsolutePosition.X
                        local ay = svBox.AbsolutePosition.Y
                        local aw = svBox.AbsoluteSize.X
                        local ah = svBox.AbsoluteSize.Y
                        local ns = math.clamp((Mouse.X - ax) / aw, 0, 1)
                        local nv = 1 - math.clamp((Mouse.Y - ay) / ah, 0, 1)
                        applyColor(H, ns, nv)
                    end
                end))

                -- Hue drag
                local draggingHue = false
                local hueHit = mk("TextButton", {
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1, Text = "", ZIndex = 17,
                }, hueBar)
                hueHit.MouseButton1Down:Connect(function() draggingHue = true end)
                addConn(UIS.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false end
                end))
                addConn(UIS.InputChanged:Connect(function(i)
                    if draggingHue and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local ax = hueBar.AbsolutePosition.X
                        local aw = hueBar.AbsoluteSize.X
                        local nh = math.clamp((Mouse.X - ax) / aw, 0, 1)
                        applyColor(nh, S, V)
                    end
                end))

                -- Hex input
                hexBox.FocusLost:Connect(function()
                    local hex = hexBox.Text:gsub("#", "")
                    if #hex == 6 then
                        local r = tonumber(hex:sub(1,2), 16)
                        local g = tonumber(hex:sub(3,4), 16)
                        local b = tonumber(hex:sub(5,6), 16)
                        if r and g and b then
                            local nh, ns, nv = Color3.toHSV(Color3.fromRGB(r,g,b))
                            applyColor(nh, ns, nv)
                        end
                    end
                end)

                previewBtn.MouseButton1Click:Connect(function()
                    opened = not opened
                    if opened then
                        panel.Visible = true
                        twSpring(panel, {Size = UDim2.new(0, panW, 0, panH)}, 0.22)
                    else
                        tw(panel, {Size = UDim2.new(0, panW, 0, 0)}, 0.15)
                        task.delay(0.16, function() panel.Visible = false end)
                    end
                end)

                wrap.MouseEnter:Connect(function() tw(wStroke,{Color=T.borderLight}) end)
                wrap.MouseLeave:Connect(function() tw(wStroke,{Color=T.border}) end)

                return {
                    Get   = function() return current end,
                    Set   = function(c)
                        local h,s,v = Color3.toHSV(c)
                        applyColor(h,s,v)
                    end,
                    Frame = wrap,
                }
            end

            -- ── Keybind ──────────────────────────────
            --[[
                Items:Keybind({
                    Label    = "Toggle Fly",
                    Default  = Enum.KeyCode.F,
                    Callback = function(keyCode) end,  -- fires on press
                })
                Returns { Get, Set }
            ]]
            function Items:Keybind(cfg)
                cfg = cfg or {}
                local cb      = cfg.Callback
                local current = cfg.Default or Enum.KeyCode.Unknown
                local listening = false

                local row = frame({
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = T.bgItem,
                    BackgroundTransparency = 0,
                }, targetPage)
                corner(8, row)
                local rStroke = stroke(1, T.border, row)
                padding(0, 12, 0, 12, row)

                label({
                    Size = UDim2.new(0.55, 0, 1, 0),
                    Text = cfg.Label or "Keybind",
                    TextSize = 12, TextColor3 = T.text,
                }, row)

                local keyBtn = mk("TextButton", {
                    Size = UDim2.new(0, 70, 0, 22),
                    Position = UDim2.new(1, -70, 0.5, -11),
                    BackgroundColor3 = T.accentDeep,
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Text = current.Name,
                    TextSize = 10,
                    Font = Enum.Font.GothamBold,
                    TextColor3 = T.accent,
                    AutoButtonColor = false,
                }, row)
                corner(6, keyBtn)
                stroke(1, T.accent, keyBtn)

                keyBtn.MouseButton1Click:Connect(function()
                    listening = not listening
                    keyBtn.Text = listening and "..." or current.Name
                    keyBtn.TextColor3 = listening and T.warn or T.accent
                    tw(keyBtn, {BackgroundColor3 = listening and T.accentDark or T.accentDeep})
                end)

                addConn(UIS.InputBegan:Connect(function(inp, processed)
                    if listening and not processed then
                        if inp.UserInputType == Enum.UserInputType.Keyboard then
                            current = inp.KeyCode
                            listening = false
                            keyBtn.Text = current.Name
                            keyBtn.TextColor3 = T.accent
                            tw(keyBtn, {BackgroundColor3 = T.accentDeep})
                        end
                    elseif not listening and not processed then
                        if inp.KeyCode == current then
                            if cb then pcall(cb, current) end
                        end
                    end
                end))

                row.MouseEnter:Connect(function() tw(row,{BackgroundColor3=T.bgHover}) end)
                row.MouseLeave:Connect(function() tw(row,{BackgroundColor3=T.bgItem}) end)

                return {
                    Get   = function() return current end,
                    Set   = function(k)
                        current = k
                        keyBtn.Text = k.Name
                    end,
                    Frame = row,
                }
            end

            -- ── Custom ───────────────────────────────
            function Items:Custom(instance)
                instance.Parent = targetPage
                return instance
            end

            -- ── GetPage ──────────────────────────────
            function Items:GetPage()
                return targetPage
            end

            return Items
        end

        -- Tab exposes the same item API plus Section
        local TabItems = buildItems(page)

        -- Override Section to return sub-items builder
        local originalSection = TabItems.Section
        function TabItems:Section(title)
            -- draw section header
            local sec = frame({Size = UDim2.new(1, 0, 0, 22)}, page)
            frame({
                Size = UDim2.new(1, -94, 0, 1),
                Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundColor3 = T.border,
                BackgroundTransparency = 0,
            }, sec)
            label({
                Size = UDim2.new(0, 92, 1, 0),
                Position = UDim2.new(1, -92, 0, 0),
                Text = title,
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                TextColor3 = T.accent,
                TextXAlignment = Enum.TextXAlignment.Right,
            }, sec)
            -- Return item builder for the same page (grouped visually)
            return buildItems(page)
        end

        return TabItems
    end

    -- ── GetTheme ─────────────────────────────────────
    function Window:GetTheme()
        return T
    end

    return Window
end

-- ══════════════════════════════════════════
--  ALIASES  (Rayfield-compat naming)
-- ══════════════════════════════════════════
KumaLib.CreateWindow = KumaLib.Window

-- ══════════════════════════════════════════
--  EXPORT
-- ══════════════════════════════════════════
_G.__KumaLib_v2 = KumaLib
return KumaLib

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  USAGE EXAMPLE:

  local K = loadstring(game:HttpGet("URL"))()

  local Win = K:Window({
      Title       = "🔥 My Script",
      Subtitle    = "v1.0  •  by Me",
      Width       = 580,
      Height      = 640,
      HideKey     = Enum.KeyCode.RightAlt,
      LoadingTime = 2,
  })

  local TabMain = Win:Tab("Main", "")
  local TabESP  = Win:Tab("ESP",  "")
  local TabMisc = Win:Tab("Misc", "")

  TabMain:Section("Movement")

  local wsToggle = TabMain:Toggle({
      Label    = "Infinite Speed",
      Default  = false,
      Callback = function(v)
          game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v and 100 or 16
      end,
  })

  TabMain:Slider({
      Label    = "Walk Speed",
      Min      = 16,
      Max      = 500,
      Default  = 16,
      Step     = 1,
      Suffix   = " st/s",
      Callback = function(v)
          game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
      end,
  })

  TabMain:Section("Players")

  TabMain:Dropdown({
      Label    = "Target",
      Options  = {"Player1", "Player2"},
      Default  = "Player1",
      Callback = function(v) print("Target:", v) end,
  })

  TabESP:ColorPicker({
      Label    = "ESP Color",
      Default  = Color3.fromRGB(255,165,0),
      Callback = function(c) print(c) end,
  })

  TabMisc:Keybind({
      Label    = "Toggle UI",
      Default  = Enum.KeyCode.RightAlt,
      Callback = function(k) Win:ToggleUI() end,
  })

  TabMisc:Input({
      Label       = "Teleport To",
      Placeholder = "Tên người chơi",
      Callback    = function(t) print("TP to:", t) end,
  })

  Win:Notify({
      Title    = "Đã tải xong!",
      Message  = "Script ready. Chúc vui.",
      Color    = Color3.fromRGB(245,158,11),
      Duration = 4,
      Icon     = "🔥",
  })
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
]]
