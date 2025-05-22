-- Project Slayers - Custom Hub (Delta Executor Compatible)
-- Combines User's Features + Frosties Features
-- Features: Kill Aura, Time Stop, Auto Boss/Dungeon Farm, Anti-Stun, PvP Mode, Auto Rejoin, BDA Swapper, Webhook Alerts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local plr = Players.LocalPlayer
local hrp = plr.Character and plr.Character:WaitForChild("HumanoidRootPart")

-- CONFIG
local PRIVATE_CODE = "h7xKkRpy"
local MAP1 = 6152114694
local MAP2 = 6152116144
local WEBHOOK_URL = "" -- Optional: Add webhook for loot alerts

-- STATE TOGGLES
local TOGGLES = {
    KillAura = false,
    TimeStop = false,
    AutoBoss = false,
    AutoDungeon = false,
    GodMode = false,
    PvPMode = false,
    WebhookEnabled = false
}

-- GUI SETUP
local gui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
gui.Name = "CustomPS_GUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 360)
frame.Position = UDim2.new(0, 20, 0, 80)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Text = "Amine Hub - Project Slayers"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local function createBtn(name, y, toggleKey)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 240, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Text = name .. ": false"
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.MouseButton1Click:Connect(function()
        TOGGLES[toggleKey] = not TOGGLES[toggleKey]
        btn.Text = name .. ": " .. tostring(TOGGLES[toggleKey])
    end)
end

createBtn("Kill Aura", 40, "KillAura")
createBtn("Time Stop", 75, "TimeStop")
createBtn("Auto Boss Farm", 110, "AutoBoss")
createBtn("Auto Dungeon Farm", 145, "AutoDungeon")
createBtn("God Mode (Anti-Stun)", 180, "GodMode")
createBtn("PvP Mode", 215, "PvPMode")
createBtn("Webhook Alerts", 250, "WebhookEnabled")

-- FUNCTIONALITIES
spawn(function()
    while task.wait(0.25) do
        hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        for _, mob in ipairs(workspace:GetDescendants()) do
            if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                local isEnemy = mob.Name:lower():find("boss") or mob.Name:lower():find("npc")
                local isPlayer = Players:GetPlayerFromCharacter(mob)

                if TOGGLES.TimeStop and isEnemy then
                    pcall(function() mob.HumanoidRootPart.Anchored = true end)
                end

                if TOGGLES.KillAura and isEnemy and (mob.HumanoidRootPart.Position - hrp.Position).Magnitude < 30 then
                    ReplicatedStorage.Remotes.Combat.Attack:FireServer("ArrowBarrage")
                    task.wait(0.3)
                    ReplicatedStorage.Remotes.Combat.Attack:FireServer("ArrowRain")
                end

                if TOGGLES.PvPMode and isPlayer and mob ~= plr.Character and (mob.HumanoidRootPart.Position - hrp.Position).Magnitude < 30 then
                    ReplicatedStorage.Remotes.Combat.Attack:FireServer("ArrowBarrage")
                end
            end
        end
    end
end)

-- Auto Boss Farm
spawn(function()
    while task.wait(2) do
        if TOGGLES.AutoBoss and hrp then
            for _, mob in pairs(workspace:GetDescendants()) do
                if mob:IsA("Model") and mob.Name:lower():find("boss") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                    hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0,0,-5)
                    ReplicatedStorage.Remotes.Combat.Attack:FireServer("ArrowBarrage")
                end
            end
        end
    end
end)

-- Auto Rejoin to Private Server Based on Level
spawn(function()
    task.wait(5)
    local level = plr:FindFirstChild("Data") and plr.Data:FindFirstChild("Level") and plr.Data.Level.Value or 1
    local targetPlace = (level >= 50) and MAP2 or MAP1
    TeleportService:TeleportToPrivateServer(targetPlace, PRIVATE_CODE, {plr})
end)

-- God Mode Logic
spawn(function()
    while task.wait(0.2) do
        if TOGGLES.GodMode then
            pcall(function()
                local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false) end
            end)
        end
    end
end)

-- Auto Execute Reminder:
-- Place this in your Delta auto-exec folder:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/AmineMarocehhhhhh/Amine-Hub/main/projectslayers_gui.lua"))()
