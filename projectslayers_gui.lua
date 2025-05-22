-- Project Slayers Auto Farm GUI Script (Delta Compatible)
-- Created for private use, includes auto rejoin + persistence

if getgenv().isRunning then return end
getgenv().isRunning = true

-- Settings (persistent)
getgenv().ENABLE_KILL_AURA = getgenv().ENABLE_KILL_AURA or false
getgenv().ENABLE_TIME_STOP = getgenv().ENABLE_TIME_STOP or false
getgenv().AUTO_BOSS_FARM = getgenv().AUTO_BOSS_FARM or false

-- Services
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TPService = game:GetService("TeleportService")
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- GUI
local gui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
gui.Name = "SlayersUI"
local frame = Instance.new("Frame", gui)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.Size = UDim2.new(0, 200, 0, 170)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local function createBtn(name, posY, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 180, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(callback)
end

-- Buttons
createBtn("Toggle Kill Aura", 10, function()
    getgenv().ENABLE_KILL_AURA = not getgenv().ENABLE_KILL_AURA
end)

createBtn("Toggle Time Stop", 50, function()
    getgenv().ENABLE_TIME_STOP = not getgenv().ENABLE_TIME_STOP
end)

createBtn("Auto Boss Farm", 90, function()
    if getgenv().AUTO_BOSS_FARM then return end
    getgenv().AUTO_BOSS_FARM = true
    task.spawn(function()
        while getgenv().AUTO_BOSS_FARM do
            task.wait(2)
            for _, mob in pairs(workspace:GetDescendants()) do
                if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                    if mob.Name:lower():find("boss") and mob.Humanoid.Health > 0 then
                        hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0,0,-5)
                        RS.Remotes.Combat.Attack:FireServer("ArrowBarrage")
                    end
                end
            end
        end
    end)
end)

-- Core loops
task.spawn(function()
    while true do
        task.wait(0.2)

        if getgenv().ENABLE_TIME_STOP then
            for _, mob in pairs(workspace:GetDescendants()) do
                if mob:IsA("Model") and mob:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        mob.HumanoidRootPart.Anchored = true
                    end)
                end
            end
        end

        if getgenv().ENABLE_KILL_AURA then
            for _, mob in pairs(workspace:GetDescendants()) do
                if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                    if mob.Humanoid.Health > 0 and (mob.HumanoidRootPart.Position - hrp.Position).Magnitude < 30 then
                        RS.Remotes.Combat.Attack:FireServer("ArrowBarrage")
                        task.wait(0.5)
                        RS.Remotes.Combat.Attack:FireServer("ArrowLadder")
                        task.wait(0.5)
                        RS.Remotes.Combat.Attack:FireServer("ArrowRain")
                    end
                end
            end
        end
    end
end)

-- Auto Rejoin (Map & Level check)
task.spawn(function()
    local function getLevel()
        local data = plr:FindFirstChild("Data") or plr:WaitForChild("Data")
        return data:FindFirstChild("Level") and data.Level.Value or 1
    end

    local function getMapID()
        local level = getLevel()
        return level >= 50 and 2 or 1
    end

    local function rejoin()
        local mapID = getMapID()
        local privateCode = "h7xKkRpy"
        local serverLink = "ProjectSlayersMap" .. mapID
        TPService:TeleportToPrivateServer(serverLink, privateCode, {plr})
    end

    game:GetService("CoreGui"):WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay"):WaitForChild("ErrorPrompt").DescendantAdded:Connect(function(obj)
        if obj:IsA("TextLabel") and obj.Text:lower():find("lost connection") then
            task.wait(3)
            rejoin()
        end
    end)
end)
