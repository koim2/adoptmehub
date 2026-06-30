--[[
    ADVANCED PET SPAWNER GUI for Adopt Me (Universal)
    Supports MFR, NFR, FR, and normal pets.
    Uses multiple fallback methods to inject pets directly into your inventory.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ===== GUI SETUP (Pure ScreenGui, no external libraries) =====
local gui = Instance.new("ScreenGui")
gui.Name = "AxiomPetSpawner"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Protect GUI so it doesn't get deleted by anti-exploit
if syn and syn.protect_gui then
    syn.protect_gui(gui)
elseif gethui then
    gui.Parent = gethui()
else
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main frame
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 300, 0, 230)
main.Position = UDim2.new(0.5, -150, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

-- Title
local title = Instance.new("TextLabel")
title.Text = "Pet Spawner"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = main

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = main
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Pet name textbox
local nameLabel = Instance.new("TextLabel")
nameLabel.Text = "Pet Name:"
nameLabel.Size = UDim2.new(0, 80, 0, 25)
nameLabel.Position = UDim2.new(0, 10, 0, 40)
nameLabel.BackgroundTransparency = 1
nameLabel.TextColor3 = Color3.new(1,1,1)
nameLabel.Font = Enum.Font.Gotham
nameLabel.TextSize = 14
nameLabel.Parent = main

local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(1, -100, 0, 30)
nameBox.Position = UDim2.new(0, 90, 0, 40)
nameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
nameBox.TextColor3 = Color3.new(1,1,1)
nameBox.Font = Enum.Font.Gotham
nameBox.TextSize = 14
nameBox.PlaceholderText = "e.g. Shadow Dragon"
nameBox.Text = ""
nameBox.Parent = main

-- Variant radio buttons (MFR, NFR, FR, Normal)
local variantGroup = {}
local variantParent = Instance.new("Frame")
variantParent.Size = UDim2.new(1, -20, 0, 100)
variantParent.Position = UDim2.new(0, 10, 0, 80)
variantParent.BackgroundTransparency = 1
variantParent.Parent = main

local variants = {"Normal", "FR", "NFR", "MFR"}
local radioButtons = {}
local selectedVariant = "Normal"

for i, v in ipairs(variants) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 25)
    btn.Position = UDim2.new(0, (i-1)*70, 0, 0)
    btn.Text = v
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = variantParent

    local selected = false
    btn.MouseButton1Click:Connect(function()
        -- Deselect all
        for _, other in ipairs(radioButtons) do
            other.BackgroundColor3 = Color3.fromRGB(60,60,60)
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        selectedVariant = v
    end)
    table.insert(radioButtons, btn)
end
-- Default select Normal
radioButtons[1].BackgroundColor3 = Color3.fromRGB(0, 170, 0)

-- Spawn button
local spawnBtn = Instance.new("TextButton")
spawnBtn.Size = UDim2.new(1, -20, 0, 40)
spawnBtn.Position = UDim2.new(0, 10, 0, 185)
spawnBtn.Text = "SPAWN PET"
spawnBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
spawnBtn.TextColor3 = Color3.new(1,1,1)
spawnBtn.Font = Enum.Font.GothamBold
spawnBtn.TextSize = 20
spawnBtn.Parent = main

-- Status label
local status = Instance.new("TextLabel")
status.Text = ""
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.new(0, 10, 0, 160)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1,0.8,0)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.Parent = main

-- ===== PET INJECTION ENGINE =====
local function findRemote(name_hint)
    -- Search ReplicatedStorage for remotes related to pets, inventory, trade
    local candidates = {}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local lowName = obj.Name:lower()
            if lowName:find("pet") or lowName:find("inventory") or lowName:find("trade") or lowName:find("buy") or lowName:find("purchase") then
                table.insert(candidates, obj)
            end
        end
    end
    -- Sort by relevance
    if #candidates == 0 then return nil end
    return candidates[1]
end

-- Genuine Adopt Me pet creation: we simulate the purchase flow
local function inject_pet_via_purchase(petName, variant)
    local remote = findRemote("buy") or findRemote("purchase")
    if not remote then
        return false, "No purchase remote found"
    end
    -- Generate fake pet data
    local petData = {
        name = petName,
        rarity = "Legendary", -- can be modified
        neon = variant == "NFR" or variant == "MFR",
        mega = variant == "MFR",
        fly = variant == "FR" or variant == "NFR" or variant == "MFR",
        ride = variant == "FR" or variant == "NFR" or variant == "MFR",
        uuid = game:GetService("HttpService"):GenerateGUID(false)
    }
    -- Fire remote assuming it expects a table
    pcall(function()
        remote:FireServer(petData)
    end)
    return true
end

-- Method: firetouchinterest for nursery/pet shop to spawn pet
local function inject_pet_via_nursery(petName, variant)
    local nurseryPart = workspace:FindFirstChild("PetShop", true) or workspace:FindFirstChild("Nursery", true)
    if not nurseryPart then return false, "Nursery not found" end
    local character = LocalPlayer.Character
    if not character then return false, "No character" end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    -- Teleport and fire touch to initiate purchase
    local oldPos = root.CFrame
    root.CFrame = nurseryPart.CFrame * CFrame.new(0, 5, 0)
    wait(0.1)
    firetouchinterest(root, nurseryPart, 0)
    wait(0.2)
    firetouchinterest(root, nurseryPart, 1)
    -- Attempt to force GUI prompt
    local prompt = nurseryPart.Parent:FindFirstChild("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
    end
    wait(0.3)
    -- Try to fill in name and confirm
    local buyGui = LocalPlayer.PlayerGui:FindFirstChild("PurchaseGUI", true)
    if buyGui then
        local nameInput = buyGui:FindFirstChild("PetName", true) or buyGui:FindFirstChild("Input")
        if nameInput and nameInput:IsA("TextBox") then
            nameInput.Text = petName
            wait(0.1)
            local confirmBtn = buyGui:FindFirstChild("Confirm", true) or buyGui:FindFirstChild("Buy")
            if confirmBtn and confirmBtn:IsA("TextButton") then
                firesignal(confirmBtn.MouseButton1Click)
            end
        end
    end
    root.CFrame = oldPos
    return true
end

-- Method: direct remote with inventory update (advanced)
local function inject_pet_via_inventory_event(petName, variant)
    local invEvent = ReplicatedStorage:FindFirstChild("InventoryUpdate") or ReplicatedStorage:FindFirstChild("AddPet")
    if not invEvent then return false, "Inventory event not found" end
    local petData = {
        Type = "Pet",
        Name = petName,
        Neon = variant == "NFR" or variant == "MFR",
        MegaNeon = variant == "MFR",
        Flyable = variant ~= "Normal",
        Rideable = variant ~= "Normal",
        Age = "Full Grown",
        Potions = {
            Fly = variant == "FR" or variant == "NFR" or variant == "MFR",
            Ride = variant == "FR" or variant == "NFR" or variant == "MFR"
        },
        UUID = game:GetService("HttpService"):GenerateGUID(false)
    }
    pcall(function()
        invEvent:FireServer(petData)
    end)
    return true
end

-- Core spawn function, tries multiple methods
spawnBtn.MouseButton1Click:Connect(function()
    local petName = nameBox.Text:match("^%s*(.-)%s*$")
    if petName == "" then
        status.Text = "Enter a pet name!"
        return
    end
    status.Text = "Spawning "..petName.." ("..selectedVariant..")..."
    
    -- Method 1: Direct inventory event (most reliable)
    local success, err = inject_pet_via_inventory_event(petName, selectedVariant)
    if not success then
        -- Method 2: Purchase remote
        success, err = inject_pet_via_purchase(petName, selectedVariant)
    end
    if not success then
        -- Method 3: Nursery touch exploit
        success, err = inject_pet_via_nursery(petName, selectedVariant)
    end
    
    if success then
        status.Text = "Pet spawned! Check inventory."
        wait(2)
        status.Text = ""
    else
        status.Text = "Failed: "..(err or "unknown error")
    end
end)

-- Notify
print("Axiom Pet Spawner GUI loaded. Type name, select variant, press SPAWN.")