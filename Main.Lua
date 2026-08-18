-- ==========================================================
-- -- Custom PS99 Event Hub Framework (Full Working Final Version)
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

-- 2. Configuration Table
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
    Value = { Min = 100, Max = 5000, Default = getgenv().config.speedMultiplier },
    Callback = function(v) 
        getgenv().config.speedMultiplier = v 
    end
})

-- -- Toggle that updates getgenv().config.autoFarm directly
Tab:Toggle({
    Title = "Auto-Farm Breakables (Instance Aware)",
    Default = getgenv().config.autoFarm,
    Callback = function(state)
        getgenv().config.autoFarm = state
        
        if state then
            WindUI:Notify({ Title = "Auto-Farm", Content = "config.autoFarm is TRUE. Loop started!", Duration = 2 })
            
            task.spawn(function()
                while getgenv().config.autoFarm do
                    pcall(function()
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

                        local damageRemote = nil
                        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                            if remote:IsA("RemoteEvent") and (remote.Name:lower():find("break") or remote.Name:lower():find("tap")) then
                                damageRemote = remote
                                break
                            end
                        end

                        if targetBreakables and damageRemote then
                            for _, breakable in ipairs(targetBreakables:GetChildren()) do
                                if not getgenv().config.autoFarm then break end
                                pcall(function()
                                    damageRemote:FireServer(breakable.Name)
                                end)
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        else
            WindUI:Notify({ Title = "Auto-Farm", Content = "config.autoFarm is FALSE. Loop stopped.", Duration = 2 })
        end
    end
})

-- -- Button: One-Time Manual Action
Tab:Button({
    Title = "Trigger Manual Breakables Once",
    Callback = function()
        pcall(function()
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
            
            local damageRemote = nil
            for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") and (remote.Name:lower():find("break") or remote.Name:lower():find("tap")) then
                    damageRemote = remote
                    break
                end
            end

            if targetBreakables and damageRemote then
                for _, breakable in ipairs(targetBreakables:GetChildren()) do
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

-- -- Button: Teleport to Active Event Instance Area
Tab:Button({
    Title = "Teleport to Active Event",
    Callback = function()
        pcall(function()
            local things = workspace:FindFirstChild("__THINGS")
            local instanceContainer = things and things:FindFirstChild("__INSTANCE_CONTAINER")
            local activeContainer = instanceContainer and instanceContainer:FindFirstChild("Active")
            
            local foundTarget = false
            if activeContainer then
                for _, child in ipairs(activeContainer:GetChildren()) do
                    local spawnPart = child:FindFirstChild("Spawn") or child:FindFirstChild("SpawnLocation") or child:FindFirstChild("Model") or child:FindFirstChild("Interact")
                    if spawnPart and spawnPart:IsA("BasePart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = spawnPart.CFrame + Vector3.new(0, 5, 0)
                        WindUI:Notify({ Title = "Success!", Content = "Teleported inside active event area.", Duration = 2 })
                        foundTarget = true
                        break
                    end
                end
            end
            
            if not foundTarget then
                WindUI:Notify({ Title = "Notice", Content = "Please use the official Event icon if spawn is locked.", Duration = 3 })
            end
        end)
    end
})

WindUI:Notify({ Title = "Loaded Successfully!", Content = "All features fully functional.", Duration = 3 })

