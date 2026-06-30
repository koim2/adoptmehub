-- Deobfuscated Adopt Me Hub (from koim2/adoptmehub test.lua)
-- Original source: uses InventoryEvent remote, auto‑farm, trade dupe, pet spawner GUI.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- GUI Library
local Lib = {}
function Lib:CreateWindow(name)
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.ResetOnSpawn = false
    if gethui then gui.Parent = gethui() else gui.Parent = LocalPlayer.PlayerGui end
    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 550, 0, 400)
    main.Position = UDim2.new(0.5, -275, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(30,30,30)
    main.BorderSizePixel = 0
    main.Draggable = true
    return gui, main
end

local gui, main = Lib:CreateWindow("Adopt Me Hub")

-- Tabs
local tabs = Instance.new("Frame", main)
tabs.Size = UDim2.new(0, 120, 1, 0)
tabs.BackgroundColor3 = Color3.fromRGB(25,25,25)
local function addTab(name)
    local btn = Instance.new("TextButton", tabs)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = name
    return btn
end

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -120, 1, 0)
content.Position = UDim2.new(0, 120, 0, 0)
content.BackgroundColor3 = Color3.fromRGB(35,35,35)

local currentTab = nil
local function showTab(frame)
    if currentTab then currentTab.Visible = false end
    frame.Visible = true
    currentTab = frame
end

-- Pet Spawner Tab
local petFrame = Instance.new("Frame", content)
petFrame.Size = UDim2.new(1, 0, 1, 0)
petFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)

local petTitle = Instance.new("TextLabel", petFrame)
petTitle.Text = "Pet Spawner"
petTitle.Size = UDim2.new(1,0,0,25)
petTitle.BackgroundColor3 = Color3.fromRGB(50,50,50)
petTitle.TextColor3 = Color3.new(1,1,1)
petTitle.Font = Enum.Font.GothamBold

local nameBox = Instance.new("TextBox", petFrame)
nameBox.Size = UDim2.new(0, 200, 0, 30)
nameBox.Position = UDim2.new(0.5, -100, 0, 50)
nameBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
nameBox.TextColor3 = Color3.new(1,1,1)
nameBox.PlaceholderText = "Pet Name"

local variantLabel = Instance.new("TextLabel", petFrame)
variantLabel.Text = "Variant:"
variantLabel.Size = UDim2.new(0, 80, 0, 20)
variantLabel.Position = UDim2.new(0.5, -100, 0, 90)
variantLabel.BackgroundTransparency = 1
variantLabel.TextColor3 = Color3.new(1,1,1)

local variantBox = Instance.new("TextBox", petFrame)
variantBox.Size = UDim2.new(0, 200, 0, 25)
variantBox.Position = UDim2.new(0.5, -100, 0, 110)
variantBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
variantBox.TextColor3 = Color3.new(1,1,1)
variantBox.Text = "Normal"

local spawnBtn = Instance.new("TextButton", petFrame)
spawnBtn.Size = UDim2.new(0, 150, 0, 35)
spawnBtn.Position = UDim2.new(0.5, -75, 0, 150)
spawnBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
spawnBtn.TextColor3 = Color3.new(1,1,1)
spawnBtn.Text = "SPAWN PET"
spawnBtn.Font = Enum.Font.GothamBold

local statusLabel = Instance.new("TextLabel", petFrame)
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 200)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.new(1,1,0)
statusLabel.Text = ""
statusLabel.Font = Enum.Font.Gotham

local inventoryEvent = ReplicatedStorage:FindFirstChild("InventoryEvent")
if not inventoryEvent then
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name == "InventoryEvent" then
            inventoryEvent = v
            break
        end
    end
end

local function spawnPet()
    local petName = nameBox.Text:match("^%s*(.-)%s*$")
    if petName == "" then
        statusLabel.Text = "Enter a pet name"
        return
    end
    local variant = variantBox.Text:match("^%s*(.-)%s*$") or "Normal"
    variant = variant:upper()
    if not (variant == "MFR" or variant == "NFR" or variant == "FR" or variant == "NORMAL") then
        statusLabel.Text = "Variant must be Normal, FR, NFR, or MFR"
        return
    end
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
        local success, err = pcall(function()
            inventoryEvent:FireServer(data)
        end)
        if success then
            statusLabel.Text = "Spawned " .. petName .. " (" .. variant .. ")"
        else
            statusLabel.Text = "Failed: " .. tostring(err)
        end
    else
        statusLabel.Text = "InventoryEvent remote not found"
    end
end
spawnBtn.MouseButton1Click:Connect(spawnPet)

-- Auto Farm Tab
local farmFrame = Instance.new("Frame", content)
farmFrame.Size = UDim2.new(1, 0, 1, 0)
farmFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
farmFrame.Visible = false

local farmTitle = Instance.new("TextLabel", farmFrame)
farmTitle.Text = "Auto Farm"
farmTitle.Size = UDim2.new(1,0,0,25)
farmTitle.BackgroundColor3 = Color3.fromRGB(50,50,50)
farmTitle.TextColor3 = Color3.new(1,1,1)
farmTitle.Font = Enum.Font.GothamBold

local farmToggle = Instance.new("TextButton", farmFrame)
farmToggle.Size = UDim2.new(0, 120, 0, 30)
farmToggle.Position = UDim2.new(0.5, -60, 0, 60)
farmToggle.BackgroundColor3 = Color3.fromRGB(200,0,0)
farmToggle.Text = "OFF"
local farming = false
farmToggle.MouseButton1Click:Connect(function()
    farming = not farming
    farmToggle.Text = farming and "ON" or "OFF"
    farmToggle.BackgroundColor3 = farming and Color3.fromRGB(0,180,0) or Color3.fromRGB(200,0,0)
    if farming then
        task.spawn(function()
            while farming do
                -- simple farm: fire touch interests on nearest task
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and obj.Parent and obj.Parent:FindFirstChildWhichIsA("ProximityPrompt") then
                            local dist = (char.HumanoidRootPart.Position - obj.Position).Magnitude
                            if dist < 30 then
                                firetouchinterest(char.HumanoidRootPart, obj, 0)
                                wait(0.05)
                                firetouchinterest(char.HumanoidRootPart, obj, 1)
                                break
                            end
                        end
                    end
                end
                wait(1)
            end
        end)
    end
end)

-- Trade Dupe Tab
local dupeFrame = Instance.new("Frame", content)
dupeFrame.Size = UDim2.new(1, 0, 1, 0)
dupeFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
dupeFrame.Visible = false

local dupeTitle = Instance.new("TextLabel", dupeFrame)
dupeTitle.Text = "Trade Dupe"
dupeTitle.Size = UDim2.new(1,0,0,25)
dupeTitle.BackgroundColor3 = Color3.fromRGB(50,50,50)
dupeTitle.TextColor3 = Color3.new(1,1,1)
dupeTitle.Font = Enum.Font.GothamBold

local dupeBtn = Instance.new("TextButton", dupeFrame)
dupeBtn.Size = UDim2.new(0, 150, 0, 35)
dupeBtn.Position = UDim2.new(0.5, -75, 0, 60)
dupeBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
dupeBtn.Text = "START DUPE"
dupeBtn.MouseButton1Click:Connect(function()
    local tradeEvent = ReplicatedStorage:FindFirstChild("TradeEvent")
    if not tradeEvent then return end
    local target = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then target = plr break end
    end
    if not target then return end
    for i = 1, 10 do
        tradeEvent:FireServer("request", target)
        wait(0.1)
        local gui = LocalPlayer.PlayerGui:FindFirstChild("TradeGUI")
        if gui and gui.Enabled then
            tradeEvent:FireServer("cancel")
        end
    end
end)

-- Tab buttons
local petTabBtn = addTab("Pet Spawner")
local farmTabBtn = addTab("Auto Farm")
local dupeTabBtn = addTab("Trade Dupe")

petTabBtn.MouseButton1Click:Connect(function() showTab(petFrame) end)
farmTabBtn.MouseButton1Click:Connect(function() showTab(farmFrame) end)
dupeTabBtn.MouseButton1Click:Connect(function() showTab(dupeFrame) end)

-- Start with pet tab
showTab(petFrame)

print("Adopt Me Hub loaded.")
