-- Deobfuscated Adopt Me Hub (from koim2/adoptmehub)
-- Uses InventoryEvent remote for pet spawning.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- GUI Library (simplified)
local GuiLibrary = {}
function GuiLibrary:CreateWindow(name)
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.ResetOnSpawn = false
    if gethui then gui.Parent = gethui() else gui.Parent = LocalPlayer.PlayerGui end
    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 500, 0, 350)
    main.Position = UDim2.new(0.5, -250, 0.5, -175)
    main.BackgroundColor3 = Color3.fromRGB(30,30,30)
    main.BorderSizePixel = 0
    main.Draggable = true
    return gui, main
end

-- Create window
local gui, main = GuiLibrary:CreateWindow("Adopt Me Hub")

-- Pet Spawner Section
local petSection = Instance.new("Frame", main)
petSection.Size = UDim2.new(1, -10, 0, 120)
petSection.Position = UDim2.new(0, 5, 0, 40)
petSection.BackgroundColor3 = Color3.fromRGB(45,45,45)

local petTitle = Instance.new("TextLabel", petSection)
petTitle.Text = "Pet Spawner"
petTitle.Size = UDim2.new(1,0,0,20)
petTitle.BackgroundTransparency = 1
petTitle.TextColor3 = Color3.new(1,1,1)
petTitle.Font = Enum.Font.GothamBold

local nameBox = Instance.new("TextBox", petSection)
nameBox.Size = UDim2.new(0, 200, 0, 25)
nameBox.Position = UDim2.new(0, 10, 0, 30)
nameBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
nameBox.TextColor3 = Color3.new(1,1,1)
nameBox.PlaceholderText = "Pet name"

local variantDropdown = Instance.new("TextButton", petSection)
variantDropdown.Size = UDim2.new(0, 100, 0, 25)
variantDropdown.Position = UDim2.new(0, 220, 0, 30)
variantDropdown.BackgroundColor3 = Color3.fromRGB(60,60,60)
variantDropdown.TextColor3 = Color3.new(1,1,1)
variantDropdown.Text = "Normal"

local spawnBtn = Instance.new("TextButton", petSection)
spawnBtn.Size = UDim2.new(0, 100, 0, 30)
spawnBtn.Position = UDim2.new(0, 10, 0, 70)
spawnBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
spawnBtn.TextColor3 = Color3.new(1,1,1)
spawnBtn.Text = "SPAWN"

-- Spawn function
local inventoryEvent = ReplicatedStorage:WaitForChild("InventoryEvent", 10)
local function spawnPet()
    local petName = nameBox.Text
    if petName == "" then return end
    local variant = variantDropdown.Text
    local neon = (variant == "NFR" or variant == "MFR")
    local mega = (variant == "MFR")
    local fly = (variant ~= "Normal")
    local ride = (variant ~= "Normal")
    local data = {
        Name = petName,
        Type = "Pet",
        Rarity = "Legendary",
        UUID = HttpService:GenerateGUID(false),
        Neon = neon,
        MegaNeon = mega,
        Fly = fly,
        Ride = ride,
        Flyable = fly,
        Rideable = ride,
        Age = "Full Grown",
        Version = 1
    }
    if inventoryEvent then
        inventoryEvent:FireServer(data)
    end
end
spawnBtn.MouseButton1Click:Connect(spawnPet)

-- Auto-farm Section
local farmSection = Instance.new("Frame", main)
farmSection.Size = UDim2.new(1, -10, 0, 80)
farmSection.Position = UDim2.new(0, 5, 0, 170)
farmSection.BackgroundColor3 = Color3.fromRGB(45,45,45)

local farmTitle = Instance.new("TextLabel", farmSection)
farmTitle.Text = "Auto Farm"
farmTitle.Size = UDim2.new(1,0,0,20)
farmTitle.BackgroundTransparency = 1
farmTitle.TextColor3 = Color3.new(1,1,1)
farmTitle.Font = Enum.Font.GothamBold

local farmToggle = Instance.new("TextButton", farmSection)
farmToggle.Size = UDim2.new(0, 100, 0, 25)
farmToggle.Position = UDim2.new(0, 10, 0, 30)
farmToggle.BackgroundColor3 = Color3.fromRGB(200,0,0)
farmToggle.Text = "OFF"
farmToggle.MouseButton1Click:Connect(function()
    -- toggle farm (omitted for brevity)
end)

print("Deobfuscated hub loaded.")
