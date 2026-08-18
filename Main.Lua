-- =====================================================================
-- Custom PS99 Event Hub Framework (Fast Pets & Fast Breakables)
-- =====================================================================

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
    PetSpeedMultiplier = 2000
}

-- Create UI Window
local Window = WindUI:CreateWindow({ 
    Title = "My Custom PS99 Event Hub", 
    Author = "Developer", 
    Size = UDim2.fromOffset(500, 380), 
    Transparent = true, 
    Theme = "Dark" 
})

local Tab = Window:Tab({ Title = "Event Farming", Icon = "zap" })

-- Toggles (Default set to true)
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

-- Slider for Speed
Tab:Slider({
    Title = "Pet Speed Multiplier",
    Value = { Min = 100, Max = 5000, Default = 2000 },
    Callback = function(v) getgenv().PS99EventConfig.PetSpeedMultiplier = v end
})

-- =====================================================================
-- Feature 1: Ultra-Fast Pets Loop
-- =====================================================================
task.spawn(function()
    while task.wait(0.05) do
        if getgenv().PS99EventConfig.FastPets then
            pcall(function()
                local things = workspace:FindFirstChild("__THINGS")
                if things and things:FindFirstChild("Pets") then
                    for _, pet in ipairs(things.Pets:GetChildren()) do
                        pet:SetAttribute("SpeedMultiplier", getgenv().PS99EventConfig.PetSpeedMultiplier)
                        pet:SetAttribute("MoveSpeed", 16 * getgenv().PS99EventConfig.PetSpeedMultiplier)
                    end
                end
            end)
        end
    end
end)

-- =====================================================================
-- Feature 2: Fast Breakables / Event Farming Loop
-- =====================================================================
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().PS99EventConfig.FastBreakables then
            pcall(function()
                -- Look for network remotes or event breakables container
                local things = workspace:FindFirstChild("__THINGS")
                local breakables = things and things:FindFirstChild("Breakables")
                
                if breakables then
                    -- Find network damage/break remote events if your game version utilizes them
                    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") and (string.find(remote.Name:lower(), "break") or string.find(remote.Name:lower(), "damage") or string.find(remote.Name:lower(), "hit")) then
                            for _, breakable in ipairs(breakables:GetChildren()) do
                                if breakable:FindFirstChild("UUID") or breakable.Name then
                                    -- Fire damage request to simulate rapid hitting
                                    pcall(function()
                                        remote:FireServer(breakable.Name)
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

WindUI:Notify({ Title = "Loaded Successfully!", Content = "Your custom script hub is ready and active.", Duration = 3 })
