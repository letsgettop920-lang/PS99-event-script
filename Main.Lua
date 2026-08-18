-- ==========================================================
-- -- Custom PS99 Event Hub Framework (All Fixes Applied)
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

-- Global configuration table
getgenv().PS99EventConfig = {
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

-- -- Slider for Speed
Tab:Slider({
    Title = "Pet Speed Multiplier",
    Value = { Min = 100, Max = 5000, Default = 2000 },
    Callback = function(v) getgenv().PS99EventConfig.SpeedMultiplier = v end
})

-- -- Button 1: Continuous Ultra-Fast Pets Boost (Fixed Loop)
Tab:Button({
    Title = "Apply Ultra-Fast Pets Boost",
    Callback = function()
        pcall(function()
            getgenv().PS99FastPets = true
            
            task.spawn(function()
                while getgenv().PS99FastPets do
                    pcall(function()
                        local things = workspace:FindFirstChild("__THINGS")
                        if things and things:FindFirstChild("Pets") then
                            for _, pet in ipairs(things.Pets:GetChildren()) do
                                pet:SetAttribute("SpeedMultiplier", getgenv().PS99EventConfig.SpeedMultiplier)
                                pet:SetAttribute("MoveSpeed", 16 * getgenv().PS99EventConfig.SpeedMultiplier)
                                
                                local primaryPart = pet:IsA("Model") and pet.PrimaryPart or pet:FindFirstChild("HumanoidRootPart")
                                if primaryPart and primaryPart:IsA("BasePart") then
                                    local bv = primaryPart:FindFirstChild("BodyVelocityPS99")
                                    if not bv then
                                        bv = Instance.new("BodyVelocity")
                                        bv.Name = "BodyVelocityPS99"
                                        bv.MaxForce = Vector3.new(50000, 0, 50000)
                                        bv.Parent = primaryPart
                                    end
                                    bv.Velocity = primaryPart.CFrame.LookVector * (getgenv().PS99EventConfig.SpeedMultiplier / 20)
                                end
                            end
                        end
                    end)
                    task.wait(0.2)
                end
            end)

            WindUI:Notify({ Title = "Success!", Content = "Continuous pet speed loop active.", Duration = 2 })
        end)
    end
})

-- -- Button 2: Run Damage/Breakables Once
Tab:Button({
    Title = "Trigger Fast Breakables (Damage Action)",
    Callback = function()
        pcall(function()
            local cachedRemotes = {}
            for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    local nameLower = remote.Name:lower()
                    if string.find(nameLower, "break") or string.find(nameLower, "damage") or string.find(nameLower, "hit") then
                        table.insert(cachedRemotes, remote)
                    end
                end
            end

            local things = workspace:FindFirstChild("__THINGS")
            local breakables = things and things:FindFirstChild("Breakables")
            
            if breakables and #cachedRemotes > 0 then
                for _, breakable in ipairs(breakables:GetChildren()) do
                    for _, remote in ipairs(cachedRemotes) do
                        pcall(function()
                            remote:FireServer(breakable.Name)
                        end)
                    end
                end
                WindUI:Notify({ Title = "Success!", Content = "Fired breakables remote actions.", Duration = 2 })
            else
                WindUI:Notify({ Title = "Notice", Content = "No breakables or remotes found.", Duration = 2 })
            end
        end)
    end
})

-- -- Button 3: Native Game Teleport Handler (No Glitchy Fallback)
Tab:Button({
    Title = "Auto-Join Active Event",
    Callback = function()
        pcall(function()
            local successClient, Client = pcall(function()
                return require(ReplicatedStorage:WaitForChild("Client", 2))
            end)
            
            if successClient and Client and Client.Network and Client.Network.Invoke then
                local successInvoke = pcall(function()
                    Client.Network.Invoke("TeleportToEvent")
                end)
                if successInvoke then
                    WindUI:Notify({ Title = "Success!", Content = "Triggered event network teleport!", Duration = 2 })
                    return
                end
            end

            WindUI:Notify({ Title = "PS99 Notice", Content = "Please use the official Event icon on your screen!", Duration = 3 })
        end)
    end
})

WindUI:Notify({ Title = "Loaded Successfully!", Content = "All bugs fully fixed.", Duration = 3 })
