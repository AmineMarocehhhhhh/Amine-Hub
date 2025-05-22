auto-exec folder:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/AmineMarocehhhhhh/Amine-Hub/main/projectslayers_gui.lua"))()
-- Project Slayers Advanced Script (Frosties Style)
-- By: (Your Name)
-- Features: Auto-Farm, Auto-Loot, NoClip, Click TP, GUI Controls

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- GUI Settings (Saved)
local Settings = {
    AutoFarm = false,
    AutoLoot = false,
    AutoSell = false,
    NoClip = false,
    ClickTP = false,
    GuiPosition = UDim2.new(0.8, 0, 0.3, 0),
    GuiSize = UDim2.new(0.2, 0, 0.35, 0)
}

-- Load Settings (if saved)
local function LoadSettings()
    if isfile("ProjectSlayers_Settings.txt") then
        local data = readfile("ProjectSlayers_Settings.txt")
        Settings = game:GetService("HttpService"):JSONDecode(data)
    end
end

-- Save Settings
local function SaveSettings()
    writefile("ProjectSlayers_Settings.txt", game:GetService("HttpService"):JSONEncode(Settings))
end

LoadSettings()

-- GUI Setup (Frosties Style)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleText = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local ResizeButton = Instance.new("TextButton")
local AutoFarmToggle = Instance.new("TextButton")
local AutoLootToggle = Instance.new("TextButton")
local AutoSellToggle = Instance.new("TextButton")
local NoClipToggle = Instance.new("TextButton")
local ClickTPToggle = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

ScreenGui.Name = "ProjectSlayersGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.Position = Settings.GuiPosition
MainFrame.Size = Settings.GuiSize
MainFrame.Active = true
MainFrame.Draggable = false -- (Handled manually for better control)

TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0.1, 0)

TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0.05, 0, 0, 0)
TitleText.Size = UDim2.new(0.8, 0, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "Project Slayers v3.0"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left

CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(0.9, 0, 0, 0)
CloseButton.Size = UDim2.new(0.1, 0, 1, 0)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.TextSize = 14

ResizeButton.Name = "ResizeButton"
ResizeButton.Parent = MainFrame
ResizeButton.BackgroundTransparency = 1
ResizeButton.Position = UDim2.new(0.95, 0, 0.95, 0)
ResizeButton.Size = UDim2.new(0.05, 0, 0.05, 0)
ResizeButton.Font = Enum.Font.GothamBold
ResizeButton.Text = "↘"
ResizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
ResizeButton.TextSize = 14

-- Toggle Buttons
local function CreateToggleButton(name, text, positionY)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = MainFrame
    button.Position = UDim2.new(0.05, 0, positionY, 0)
    button.Size = UDim2.new(0.9, 0, 0.12, 0)
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.BorderColor3 = Color3.fromRGB(80, 80, 80)
    return button
end

AutoFarmToggle = CreateToggleButton("AutoFarmToggle", "Auto Farm: OFF", 0.15)
AutoLootToggle = CreateToggleButton("AutoLootToggle", "Auto Loot: OFF", 0.3)
AutoSellToggle = CreateToggleButton("AutoSellToggle", "Auto Sell: OFF", 0.45)
NoClipToggle = CreateToggleButton("NoClipToggle", "NoClip: OFF", 0.6)
ClickTPToggle = CreateToggleButton("ClickTPToggle", "Click TP: OFF", 0.75)

StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = MainFrame
StatusLabel.Position = UDim2.new(0.05, 0, 0.9, 0)
StatusLabel.Size = UDim2.new(0.9, 0, 0.08, 0)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 12
StatusLabel.BackgroundTransparency = 1

-- GUI Controls
local Dragging, DragInput, DragStart, StartPos
local Resizing, ResizeInput, ResizeStart, StartSize

-- Make GUI draggable
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
                Settings.GuiPosition = MainFrame.Position
                SaveSettings()
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and Dragging then
        local Delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end
end)

-- Make GUI resizable
ResizeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Resizing = true
        ResizeStart = input.Position
        StartSize = MainFrame.Size
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Resizing = false
                Settings.GuiSize = MainFrame.Size
                SaveSettings()
            end
        end)
    end
end)

ResizeButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and Resizing then
        local Delta = input.Position - ResizeStart
        MainFrame.Size = UDim2.new(StartSize.X.Scale, StartSize.X.Offset + Delta.X, StartSize.Y.Scale, StartSize.Y.Offset + Delta.Y)
    end
end)

-- Close GUI
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle GUI (F5)
    if input.KeyCode == Enum.KeyCode.F5 then
        MainFrame.Visible = not MainFrame.Visible
    end
    
    -- Toggle NoClip (N)
    if input.KeyCode == Enum.KeyCode.N then
        Settings.NoClip = not Settings.NoClip
        NoClipToggle.Text = "NoClip: " .. (Settings.NoClip and "ON" or "OFF")
        NoClipToggle.BackgroundColor3 = Settings.NoClip and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
    end
    
    -- Click TP (Right-Click)
    if Settings.ClickTP and input.UserInputType == Enum.UserInputType.MouseButton2 then
        local target = UserInputService:GetMouseLocation()
        local ray = Workspace:ScreenPointToRay(target.X, target.Y, 1000)
        local part, position = Workspace:FindPartOnRay(ray, Character)
        
        if position then
            local tween = TweenService:Create(
                RootPart,
                TweenInfo.new(0.5, Enum.EasingStyle.Linear),
                {CFrame = CFrame.new(position + Vector3.new(0, 3, 0))}
            )
            tween:Play()
        end
    end
end)

-- NoClip Loop
RunService.Stepped:Connect(function()
    if Settings.NoClip and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Auto-Farm Logic
local function AutoFarm()
    while Settings.AutoFarm do
        -- Find nearest boss
        local closestBoss = nil
        local closestDistance = math.huge
        
        for _, boss in pairs(Workspace:GetChildren()) do
            if boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
                local distance = (boss.HumanoidRootPart.Position - RootPart.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestBoss = boss
                end
            end
        end
        
        if closestBoss then
            StatusLabel.Text = "Status: Attacking Boss"
            Humanoid:MoveTo(closestBoss.HumanoidRootPart.Position)
            
            -- Face boss and attack
            RootPart.CFrame = CFrame.new(RootPart.Position, closestBoss.HumanoidRootPart.Position)
            local args = {
                [1] = "Melee",
                [2] = closestBoss.HumanoidRootPart.Position
            }
            game:GetService("ReplicatedStorage").CombatEvents.Hit:FireServer(unpack(args))
        else
            StatusLabel.Text = "Status: No Boss Found"
        end
        
        if Settings.AutoLoot then
            -- Auto-Loot nearby items
            for _, drop in pairs(Workspace.Drops:GetChildren()) do
                if (drop.Position - RootPart.Position).Magnitude < 15 then
                    firetouchinterest(RootPart, drop, 0)
                    firetouchinterest(RootPart, drop, 1)
                end
            end
        end
        
        wait(0.5)
    end
    StatusLabel.Text = "Status: Idle"
end

-- Toggle Functions
AutoFarmToggle.MouseButton1Click:Connect(function()
    Settings.AutoFarm = not Settings.AutoFarm
    AutoFarmToggle.Text = "Auto Farm: " .. (Settings.AutoFarm and "ON" or "OFF")
    AutoFarmToggle.BackgroundColor3 = Settings.AutoFarm and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
    
    if Settings.AutoFarm then
        coroutine.wrap(AutoFarm)()
    end
end)

AutoLootToggle.MouseButton1Click:Connect(function()
    Settings.AutoLoot = not Settings.AutoLoot
    AutoLootToggle.Text = "Auto Loot: " .. (Settings.AutoLoot and "ON" or "OFF")
    AutoLootToggle.BackgroundColor3 = Settings.AutoLoot and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
    SaveSettings()
end)

AutoSellToggle.MouseButton1Click:Connect(function()
    Settings.AutoSell = not Settings.AutoSell
    AutoSellToggle.Text = "Auto Sell: " .. (Settings.AutoSell and "ON" or "OFF")
    AutoSellToggle.BackgroundColor3 = Settings.AutoSell and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
    SaveSettings()
end)

NoClipToggle.MouseButton1Click:Connect(function()
    Settings.NoClip = not Settings.NoClip
    NoClipToggle.Text = "NoClip: " .. (Settings.NoClip and "ON" or "OFF")
    NoClipToggle.BackgroundColor3 = Settings.NoClip and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
    SaveSettings()
end)

ClickTPToggle.MouseButton1Click:Connect(function()
    Settings.ClickTP = not Settings.ClickTP
    ClickTPToggle.Text = "Click TP: " .. (Settings.ClickTP and "ON" or "OFF")
    ClickTPToggle.BackgroundColor3 = Settings.ClickTP and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
    SaveSettings()
end)

-- Initialize GUI
for _, button in pairs(MainFrame:GetChildren()) do
    if button:IsA("TextButton") then
        button.AutoButtonColor = false
    end
end

print("Project Slayers Script Loaded! (Press F5 to toggle GUI)")
