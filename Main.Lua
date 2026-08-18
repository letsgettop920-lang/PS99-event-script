-- ==========================================================
-- -- Custom PS99 Event Hub Framework (Optimized & Lag-Free)
-- ==========================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 1. Load WindUI Library safely
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not success or not WindUI then
    warn("WindUI failed to load.")
    return
end

-- Global configuration table (Set to true by default)
getgenv().PS99EventConfig = {
    FastPets = true,
    FastBreakables = true,
    SpeedMultiplier = 2000
}

-- -- Create UI Window
local Window = WindUI:CreateWindow({
    Title = "My Custom PS99 Event Hub",
    Author = "Developer",
    Size = UDim2.fromOffset(500, 380),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "Event Farming", Icon = "zap" })

-- -- Toggles (Default set to true)
Tab:Toggle({
    Title = "Enable Ultra-Fast Pets",
    Default = true,
    Callback = function(v) getgenv().PS99EventConfig.FastPets = v end
})

Tab:Toggle({
    Title = "Enable Fast Breakables (Damage Loop)",
    Default = true,
    Callback = function(v) getgenv().PS99EventConfig.FastBreakables = v end
})

-- -- Slider for Speed
Tab:Slider({
    Title = "Pet Speed Multiplier",
    Value = { Min = 100, Max = 5000, Default = 2000 },
    Callback = function(v) getgenv().PS99EventConfig.SpeedMultiplier = v end
})

-- ==========================================================
-- -- Feature 1: Ultra-Fast Pets Loop
-- ==========================================================
task.spawn(function()
    while task.wait(0.2) do
        if getgenv().PS99EventConfig.FastPets then
            pcall(function()
                local things = workspace:FindFirstChild("__THINGS")
                if things and things:FindFirstChild("Pets") then
                    for _, pet in ipairs(things.Pets:GetChildren()) do
                        pet:SetAttribute("SpeedMultiplier", getgenv().PS99EventConfig.SpeedMultiplier)
                        pet:SetAttribute("MoveSpeed", 16 * getgenv().PS99EventConfig.SpeedMultiplier)
                    end
                end
            end)
        end
    end
end)

-- ==========================================================
-- -- Feature 2: Fast Breakables / Event Farming Loop (Optimized)
-- ==========================================================
-- Cache remote events ONCE so it doesn't lag the game every frame
local cachedRemotes = {}
task.spawn(function()
    pcall(function()
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local nameLower = remote.Name:lower()
                if string.find(nameLower, "break") or string.find(nameLower, "damage") or string.find(nameLower, "hit") then
                    table.insert(cachedRemotes, remote)
                end
            end
        end
    end)
end)

task.spawn(function()
    while task.wait(0.3) do
        if getgenv().PS99EventConfig.FastBreakables then
            pcall(function()
                local things = workspace:FindFirstChild("__THINGS")
                local breakables = things and things:FindFirstChild("Breakables")
                
                if breakables then
                    for _, breakable in ipairs(breakables:GetChildren()) do
                        local breakableId = breakable:FindFirstChild("UUID") or breakable.Name
                        if breakableId then
                            for _, remote in ipairs(cachedRemotes) do
                                pcall(function()
                                    remote:FireServer(breakable.Name)
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

WindUI:Notify({ Title = "Loaded Successfully!", Content = "Your optimized script hub is ready and active.", Duration = 3 })
