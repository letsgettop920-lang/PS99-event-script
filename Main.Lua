-- ==========================================================
-- -- Custom PS99 Event Hub Framework (Updated Config)
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

-- 2. Your requested Configuration Table structure
getgenv().config = {
    autoFarm = false,
    speedMultiplier = 2000
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

-- -- Slider for Speed Configuration
Tab:Slider({
    Title = "Pet Speed Multiplier",
    Value = { Min = 100, Max = 6000, Default = getgenv().config.speedMultiplier },
    Callback = function(v) 
        getgenv().config.speedMultiplier = v 
    end
})

-- -- Toggle that updates getgenv().config.autoFarm directly
Tab:Toggle({
    Title = "Auto-Farm Breakables (Instance Aware)",
    Default = getgenv().config.autoFarm,
    Callback = function(state)
        -- Update your config table value instantly when toggled
        getgenv().config.autoFarm = state
        
        if state then
            WindUI:Notify({ Title = "Auto-Farm", Content = "config.autoFarm is now TRUE. Loop started!", Duration = 2 })
            
            -- Functional background loop that monitors config.autoFarm
            task.spawn(function()
                while getgenv().config.autoFarm do
                    pcall(function()
                        -- Find active instance container (Event rooms / mazes)
                        local things = workspace:FindFirstChild("__THINGS")
                        local instanceContainer = things and things:FindFirstChild("__INSTANCE_CONTAINER")
                        local activeContainer = instanceContainer and instanceContainer:FindFirstChild("Active")
                        
                        local targetBreakables = nil
                        if activeContainer then
                            for _, child in ipairs(activeContainer:GetChildren()) do
                                if child:FindFirstChild("Breakables") then
                                    targetBreakables = child.Breakables
                                    break
                                end
                            end
                        end
                        
                        if not targetBreakables and things then
                            targetBreakables = things:FindFirstChild("Breakables")
                        end

                        -- Locate active damage/break remote
                        local damageRemote = nil
                        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                            if remote:IsA("RemoteEvent") and (remote.Name:lower():find("break") or remote.Name:lower():find("tap")) then
                                damageRemote = remote
                                break
                            end
                        end

                        -- Fire remote action if target and remote exist
                        if targetBreakables and damageRemote then
                            for _, breakable in ipairs(targetBreakables:GetChildren()) do
                                if not getgenv().config.autoFarm then break end
                                pcall(function()
                                    damageRemote:FireServer(breakable.Name)
                                end)
                            end
                        end
                    end)
                    task.wait(0.5) -- Loop cooldown interval
                end
            end)
        else
            WindUI:Notify({ Title = "Auto-Farm", Content = "config.autoFarm is now FALSE. Loop stopped.", Duration = 2 })
        end
    end
})

-- -- Button: One-Time Manual Action
Tab:Button({
    Title = "Trigger Manual Breakables Once",
    Callback = function()
        pcall(function()
            local things = workspace:FindFirstChild("__THINGS")
            local breakables = things and things:FindFirstChild("Breakables")
            
            local damageRemote = nil
            for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") and remote.Name:lower():find("break") then
                    damageRemote = remote
                    break
                end
            end

            if breakables and damageRemote then
                for _, breakable in ipairs(breakables:GetChildren()) do
                    pcall(function()
                        damageRemote:FireServer(breakable.Name)
                    end)
                end
                WindUI:Notify({ Title = "Success!", Content = "Fired breakables manually.", Duration = 2 })
            else
                WindUI:Notify({ Title = "Notice", Content = "No breakables found to target.", Duration = 2 })
            end
        end)
    end
})

-- -- Button: Native Event Notice
Tab:Button({
    Title = "Auto-Join Active Event",
    Callback = function()
        WindUI:Notify({ Title = "PS99 Notice", Content = "Please use the official Event icon on your screen!", Duration = 3 })
    end
})

WindUI:Notify({ Title = "Loaded Successfully!", Content = "Config linked to toggles.", Duration = 3 })
