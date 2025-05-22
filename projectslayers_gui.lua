-- Project Slayers GUI Script (Delta Executor Compatible)
-- Features: Arrow BDA Kill Aura, Time Stop, Auto Boss Farm

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Toggles
local ENABLE_KILL_AURA = false
local ENABLE_TIME_STOP = false
local AUTO_BOSS_FARM = false

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
ScreenGui.Name = "ProjectSlayersGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0, 20, 0, 100)
Frame.Size = UDim2.new(0, 200, 0, 160)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0

local function createButton(name, yPos, callback)
    local button = Instance.new("TextButton", Frame)
    button.Size = UDim2.new(0, 180, 0, 40)
    button.Position = UDim2.new(0, 10, 0, yPos)
    button.Text = name
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.new(1,1,1)
    button.MouseButton1Click:Connect(callback)
end

-- Button Functions
createButton("Toggle Kill Aura", 10, function()
    ENABLE_KILL_AURA = not ENABLE_KILL_AURA
    Frame:FindFirstChild("KillAuraStatus").Text = "Kill Aura: " .. tostring(ENABLE_KILL_AURA)
end)

createButton("Toggle Time Stop", 60, function()
    ENABLE_TIME_STOP = not ENABLE_TIME_STOP
    Frame:FindFirstChild("TimeStopStatus").Text = "Time Stop: " .. tostring(ENABLE_TIME_STOP)
end)

createButton("Start Auto Boss Farm", 110, function()
    if AUTO_BOSS_FARM then return end
    AUTO_BOSS_FARM = true
    spawn(function()
        while AUTO_BOSS_FARM do
            wait(math.random(2,4))
            for _, mob in pairs(workspace:GetDescendants()) do
                if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                    if mob.Name:lower():find("boss") and mob.Humanoid.Health > 0 then
                        hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0,0,-5)
                        ReplicatedStorage.Remotes.Combat.Attack:FireServer("ArrowBarrage")
                    end
                end
            end
        end
    end)
end)

-- Status Labels
local killAuraStatus = Instance.new("TextLabel", Frame)
killAuraStatus.Name = "KillAuraStatus"
killAuraStatus.Position = UDim2.new(0, 10, 0, 150)
killAuraStatus.Size = UDim2.new(0, 180, 0, 20)
killAuraStatus.TextColor3 = Color3.new(1, 1, 1)
killAuraStatus.BackgroundTransparency = 1
killAuraStatus.Text = "Kill Aura: false"

local timeStopStatus = Instance.new("TextLabel", Frame)
timeStopStatus.Name = "TimeStopStatus"
timeStopStatus.Position = UDim2.new(0, 10, 0, 170)
timeStopStatus.Size = UDim2.new(0, 180, 0, 20)
timeStopStatus.TextColor3 = Color3.new(1, 1, 1)
timeStopStatus.BackgroundTransparency = 1
timeStopStatus.Text = "Time Stop: false"

-- Core Loop
spawn(function()
    while true do
        wait(0.2)

        if ENABLE_TIME_STOP then
            for _, mob in pairs(workspace:GetDescendants()) do
                if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        mob.HumanoidRootPart.Anchored = true
                    end)
                end
            end
        end

        if ENABLE_KILL_AURA then
            for _, mob in pairs(workspace:GetDescendants()) do
                if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                    if mob.Humanoid.Health > 0 and (mob.HumanoidRootPart.Position - hrp.Position).Magnitude < 30 then
                        ReplicatedStorage.Remotes.Combat.Attack:FireServer("ArrowBarrage")
                        wait(0.5)
                        ReplicatedStorage.Remotes.Combat.Attack:FireServer("ArrowLadder")
                        wait(0.5)
                        ReplicatedStorage.Remotes.Combat.Attack:FireServer("ArrowRain")
                    end
                end
            end
        end
    end
end)
