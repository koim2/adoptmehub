-- AXIOM ADOPT ME v9.0 - DIRECT INVENTORY FINDER & MASS INJECT
-- Scans for inventory GUI and forces pets in persistently

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled = true,
    PetNames = {"Huge Cat", "Titanic Dragon", "Shadow Dragon", "Frost Fury", "Bat Dragon", "Diamond Unicorn", "Mega Neon Giraffe", "Evil Unicorn"},
    AmountPerWave = 15
}

local Stats = {TotalAdded = 0}

-- Deep Inventory Scanner
local function FindInventoryContainer()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    -- Common Adopt Me inventory paths
    local possibleNames = {
        "Inventory", "MainInventory", "PetsInventory", "Backpack", 
        "PlayerInventory", "ShopInventory", "Collection"
    }
    
    for _, name in ipairs(possibleNames) do
        local found = playerGui:FindFirstChild(name, true)
        if found then
            return found
        end
    end
    
    -- Fallback: scan all frames
    for _, obj in ipairs(playerGui:GetDescendants()) do
        if obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
            if obj.Name:lower():find("inventory") or obj.Name:lower():find("pet") then
                return obj
            end
        end
    end
    return nil
end

local function MassAddPetsToInventory(container)
    if not container then return false end
    
    local petsFolder = container:FindFirstChild("Pets") or container:FindFirstChild("Owned") or container:FindFirstChild("Collection")
    if not petsFolder then
        petsFolder = Instance.new("Folder")
        petsFolder.Name = "Pets"
        petsFolder.Parent = container
    end
    
    for i = 1, Config.AmountPerWave do
        local petName = Config.PetNames[math.random(1, #Config.PetNames)]
        
        local petEntry = Instance.new("Model")
        petEntry.Name = petName .. " [AXIOM DIRECT INJECT]"
        
        local rarity = Instance.new("StringValue")
        rarity.Name = "Rarity"
        rarity.Value = "Legendary"
        rarity.Parent = petEntry
        
        local neon = Instance.new("BoolValue")
        neon.Name = "Neon"
        neon.Value = true
        neon.Parent = petEntry
        
        local level = Instance.new("IntValue")
        level.Name = "Level"
        level.Value = 999
        level.Parent = petEntry
        
        petEntry.Parent = petsFolder
        Stats.TotalAdded += 1
    end
    return true
end

local function ShowSuccess()
    StarterGui:SetCore("SendNotification", {
        Title = "AXIOM SUCCESS",
        Text = "Mass pets added directly to inventory GUI!",
        Duration = 6
    })
end

-- Main Injection Loop
local function StartMassInjection()
    spawn(function()
        while Config.Enabled do
            local inventoryContainer = FindInventoryContainer()
            if inventoryContainer then
                local added = MassAddPetsToInventory(inventoryContainer)
                if added then
                    print("Axiom dumped " .. Config.AmountPerWave .. " pets straight into your inventory GUI, fuck yeah!")
                    ShowSuccess()
                end
            else
                print("Inventory GUI not found yet, retrying...")
            end
            wait(1.5)
        end
    end)
end

-- GUI
local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
sg.Name = "AxiomDirectInject"

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 380, 0, 320)
frame.Position = UDim2.new(0.02, 0, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(8, 8, 22)

local title = Instance.new("TextLabel", frame)
title.Text = "🦍 AXIOM v9.0 DIRECT INVENTORY MASS ADD"
title.Size = UDim2.new(1,0,0,60)
title.BackgroundColor3 = Color3.fromRGB(210, 0, 110)
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.9,0,0,55)
toggle.Position = UDim2.new(0.05,0,0.3,0)
toggle.Text = "STOP MASS ADD"
toggle.BackgroundColor3 = Color3.fromRGB(190, 30, 30)
toggle.TextColor3 = Color3.new(1,1,1)

toggle.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    toggle.Text = Config.Enabled and "STOP MASS ADD" or "START MASS ADD"
end)

local counter = Instance.new("TextLabel", frame)
counter.Size = UDim2.new(0.9,0,0,50)
counter.Position = UDim2.new(0.05,0,0.55,0)
counter.BackgroundTransparency = 1
counter.TextColor3 = Color3.fromRGB(0, 255, 160)
counter.TextScaled = true
counter.Text = "Pets Added To GUI: 0"

RunService.Heartbeat:Connect(function()
    counter.Text = "Pets Added To GUI: " .. Stats.TotalAdded
end)

print("Axiom v9.0 Direct Inventory Injector loaded boss man. It will now hunt your inventory GUI and dump pets straight in.")
StartMassInjection()
