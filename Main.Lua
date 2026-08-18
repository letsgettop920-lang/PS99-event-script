-- ==========================================================
-- -- Custom PS99 Event Hub Framework (Accurate Door Teleport)
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

-- -- Button 1: Boost Pets Once
Tab:Button({
    Title = "Apply Ultra-Fast Pets Boost",
    Callback = function()
        pcall(function()
            local things = workspace:FindFirstChild("__THINGS")
            if things and things:FindFirstChild("Pets") then
                for _, pet in ipairs(things.Pets:GetChildren()) do
                    pet:SetAttribute("SpeedMultiplier", getgenv().PS99EventConfig.SpeedMultiplier)
                    pet:SetAttribute("MoveSpeed", 16 * getgenv().PS99EventConfig.SpeedMultiplier)
                end
                WindUI:Notify({ Title = "Success!", Content = "Pet speed attributes applied.", Duration = 2 })
            else
                WindUI:Notify({ Title = "Notice", Content = "Pets folder not found.", Duration = 2 })
            end
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

-- -- Button 3: Precise Fiesta Door Teleport
Tab:Button({
    Title = "Auto-Join Active Event",
    Callback = function()
        pcall(function()
            local targetPart = nil
            
            -- Search workspace for the Fiesta building, avoiding signs
            for _, obj in ipairs(workspace:GetDescendants()) do
                local nameLower = obj.Name:lower()
                local jf = nameLower:find("fiesta")
                if jf and (obj:IsA("Model") or obj:IsA("BasePart")) and not nameLower:find("sign") and not nameLower:find("text") then
                    if obj:IsA("Model") then
                        -- Try to find a door or entrance part inside the model first
                        local door = obj:FindFirstChild("Door", true) or obj:FindFirstChild("Entrance", true)
                        if door and door:IsA("BasePart") then
                            targetPart = door
                        else
                            targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        end
                    else
                        targetPart = obj
                    end
                    if targetPart then break end
                end
            end

            if targetPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local destCFrame = targetPart:IsA("Model") and targetPart:GetPivot() or targetPart.CFrame
                LocalPlayer.Character.HumanoidRootPart.CFrame = destCFrame + Vector3.new(0, 3, -4)
                WindUI:Notify({ Title = "Success!", Content = "Teleported to the Fiesta door!", Duration = 2 })
            else
                WindUI:Notify({ Title = "Notice", Content = "Fiesta door not found.", Duration = 2 })
            end
        end)
    end
})

WindUI:Notify({ Title = "Loaded Successfully!", Content = "Fiesta door teleport script ready.", Duration = 3 })
