-- ===== KUMA HUB LOADER =====

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local KEY = "kuma1501"

local input = StarterGui:PromptTextInput(
    "KUMA HUB",
    "Nhập key để sử dụng:"
)

if tostring(input) ~= KEY then
    Players.LocalPlayer:Kick("Sai key!")
    return
end

loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/kuma152001/Kuma_hub/main/herb.lua"
))()
