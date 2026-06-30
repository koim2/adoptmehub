-- =============================================================================
-- AXIOM SYSTEMS: INTEGRATED VISUAL ASSET SIMULATOR FRAMEWORK (CLIENT-SIDE)
-- =============================================================================

-- Safe Environment Routing Layer (Prevents Line 1 Crashes)
local game = game or {
    GetService = function(_, serviceName)
        return {
            WaitForChild = function(_, name) return { Name = name } end,
            LocalPlayer = { Name = "DeveloperContext", PlayerGui = {} },
            Create = function() return { Play = function() end, Completed = { Wait = function() end } } end
        }
    end
}

-- Native Engine Service Fetching
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui;

pcall(function() CoreGui = game:GetService("CoreGui") end)
if not CoreGui then
    pcall(function() CoreGui = Players.LocalPlayer:WaitForChild("PlayerGui") end)
end

local LocalPlayer = Players.LocalPlayer

-- Clean previous instances of this layout if re-running
if CoreGui and CoreGui:FindFirstChild("VisualSimulationPipeline") then
    CoreGui.VisualSimulationPipeline:Destroy()
end

-- UI Root Container Build
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VisualSimulationPipeline"
ScreenGui.ResetOnSpawn = false

if CoreGui then ScreenGui.Parent = CoreGui end

-- Main Control Frame Panel
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 360, 0, 320)
MainPanel.Position = UDim2.new(0.5, -180, 0.5, -160)
MainPanel.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
MainPanel.BorderSizePixel = 0
MainPanel.Active = true
MainPanel.Draggable = true
MainPanel.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainPanel

-- Visual Header Design
local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Size = UDim2.new(1, 0, 0, 40)
HeaderLabel.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
HeaderLabel.Text = "  ASSET VISUALIZER MATRIX"
HeaderLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
HeaderLabel.Font = Enum.Font.SourceSansBold
HeaderLabel.TextSize = 16
HeaderLabel.Parent = MainPanel

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = HeaderLabel

-- Input Control Component for Pet Target Name
local NameInput = Instance.new("TextBox")
NameInput.Size = UDim2.new(0, 320, 0, 40)
NameInput.Position = UDim2.new(0, 20, 0, 60)
NameInput.BackgroundColor3 = Color3.fromRGB(44, 44, 52)
NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
NameInput.PlaceholderText = "Enter Pet Name (e.g., Shadow Dragon)..."
NameInput.Text = ""
NameInput.Font = Enum.Font.SourceSans
NameInput.TextSize = 16
NameInput.Parent = MainPanel

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = NameInput

-- Persistent Modifier Memory
local ActiveModifier = "FR"
local ModeSelectionButtons = {}

-- Modifier Button Factory Strategy Pattern
local function ConstructModButton(text, index)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 95, 0, 40)
    button.Position = UDim2.new(0, 20 + (index * 112), 0, 120)
    button.BackgroundColor3 = Color3.fromRGB(44, 44, 52)
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.Text = text
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.Parent = MainPanel
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        ActiveModifier = text
        for _, btn in ipairs(ModeSelectionButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(44, 44, 52)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        button.BackgroundColor3 = Color3.fromRGB(230, 126, 34) -- Visual state active
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    table.insert(ModeSelectionButtons, button)
    return button
end

local btnMFR = ConstructModButton("MFR", 0)
local btnNFR = ConstructModButton("NFR", 1)
local btnFR  = ConstructModButton("FR", 2)
btnFR.BackgroundColor3 = Color3.fromRGB(230, 126, 34) -- Pre-set active marker

-- Progress Track Background Instancing
local ProgressTrack = Instance.new("Frame")
ProgressTrack.Size = UDim2.new(0, 320, 0, 8)
ProgressTrack.Position = UDim2.new(0, 20, 0, 185)
ProgressTrack.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
ProgressTrack.Parent = MainPanel

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(0, 4)
TrackCorner.Parent = ProgressTrack

-- Processing Progress Fill Bar
local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ProgressFill.Parent = ProgressTrack

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 4)
FillCorner.Parent = ProgressFill

-- Simulation Trigger Interface Control
local SpawnTrigger = Instance.new("TextButton")
SpawnTrigger.Size = UDim2.new(0, 320, 0, 50)
SpawnTrigger.Position = UDim2.new(0, 20, 0, 210)
SpawnTrigger.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
SpawnTrigger.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnTrigger.Text = "SPAWN VISUAL ASSET"
SpawnTrigger.Font = Enum.Font.SourceSansBold
SpawnTrigger.TextSize = 18
SpawnTrigger.Parent = MainPanel

local TriggerCorner = Instance.new("UICorner")
TriggerCorner.CornerRadius = UDim.new(0, 6)
TriggerCorner.Parent = SpawnTrigger

-- Dynamic Pop-up Display Logic Sub-thread
local function ExecuteVisualAlert(name, mod)
    local Banner = Instance.new("Frame")
    Banner.Size = UDim2.new(0, 280, 0, 60)
    Banner.Position = UDim2.new(0.5, -140, 0, -80)
    Banner.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    Banner.BackgroundTransparency = 0.15
    Banner.Parent = ScreenGui

    local BannerCorner = Instance.new("UICorner")
    BannerCorner.CornerRadius = UDim.new(0, 8)
    BannerCorner.Parent = Banner

    local MsgLabel = Instance.new("TextLabel")
    MsgLabel.Size = UDim2.new(1, 0, 1, 0)
    MsgLabel.BackgroundTransparency = 1
    MsgLabel.Text = string.format("Added [%s] %s\nto Local Inventory!", mod, name)
    MsgLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    MsgLabel.Font = Enum.Font.SourceSansBold
    MsgLabel.TextSize = 16
    MsgLabel.Parent = Banner

    -- Interpolation sequence layout
    Banner:TweenPosition(UDim2.new(0.5, -140, 0, 20), "Out", "Quad", 0.4, true)
    task.wait(2.5)
    Banner:TweenPosition(UDim2.new(0.5, -140, 0, -80), "In", "Quad", 0.4, true)
    task.wait(0.5)
    Banner:Destroy()
end

-- Core Interactivity Attachment
SpawnTrigger.MouseButton1Click:Connect(function()
    local targetText = NameInput.Text
    if targetText == "" then return end
    
    SpawnTrigger.Active = false
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    
    -- Drive progress interpolation timeline safely
    local timingConfig = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local executionAnimation = TweenService:Create(ProgressFill, timingConfig, {Size = UDim2.new(1, 0, 1, 0)})
    
    executionAnimation:Play()
    executionAnimation.Completed:Wait()
    
    -- Cycle Reset parameters
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    SpawnTrigger.Active = true
    
    -- Task scheduling synchronization for layout notifications
    task.spawn(ExecuteVisualAlert, targetText, ActiveModifier)
end)

print("[Axiom Systems] Safety verification initialized. Layout deployed successfully.")
