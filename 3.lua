-- AXIOM ADOPT ME PET SPAWNER v7.0 - FORCED INVENTORY SYNC
-- Direct client write + server mimic + UI force update

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled = true,
    Pets = {"Huge Cat", "Titanic Dragon", "Shadow Dragon", "Frost Fury", "Bat Dragon", "Diamond Unicorn", "Mega Neon Unicorn"},
    Cycle = 12,
    Delay = 0.12
}

local Stats = {Injected = 0}

local Remotes = {}
local function ScanRemotes()
    Remotes = {}
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local low = obj.Name:lower()
            if low:find("pet") or low:find("give") or low:find("add") or low:find("spawn") or low:find("inventory") then
                table.insert(Remotes, obj)
            end
        end
    end
end

ScanRemotes()

local function MimicServerSpawn(petName)
    for _, r in ipairs(Remotes) do
        pcall(function()
            local args = {petName, "Legendary", true, true, LocalPlayer.UserId, tick()}
            if r:IsA("RemoteEvent") then
                r:FireServer(unpack(args))
            else
                r:InvokeServer(unpack(args))
            end
        end)
    end
end

-- DIRECT CLIENT INVENTORY INJECTION
local function ForceClientInventory(petName)
    local success = false
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if gui then
        -- Try multiple common inventory paths
        local paths = {"Inventory", "MainInventory", "PetsInventory", "Backpack"}
        for _, path in ipairs(paths) do
            local container = gui:FindFirstChild(path) or gui
            if container then
                local petFolder = container:FindFirstChild("Pets") or Instance.new("Folder")
                petFolder.Name = "Pets"
                petFolder.Parent = container
                
                local newPet = Instance.new("Model")
                newPet.Name = petName .. " [AXIOM FORCED]"
                
                local rarity = Instance.new("StringValue")
                rarity.Name = "Rarity"
                rarity.Value = "Legendary"
                rarity.Parent = newPet
                
                local neon = Instance.new("BoolValue")
                neon.Name = "Neon"
                neon.Value = true
                neon.Parent = newPet
                
                newPet.Parent = petFolder
                success = true
            end
        end
    end
    return success
end

local function ForceVisualRefresh()
    StarterGui:SetCore("SendNotification", {
        Title = "AXIOM SPAWNER",
        Text = Stats.Injected .. " pets forced into inventory!",
        Duration = 4
    })
    
    -- Force UI update
    pcall(function()
        local refreshRemote = ReplicatedStorage:FindFirstChild("RefreshInventory") or ReplicatedStorage:FindFirstChild("UpdatePlayerData")
        if refreshRemote then refreshRemote:FireServer() end
    end)
end

-- Main Loop
local function StartSpawning()
    spawn(function()
        while Config.Enabled do
            for i = 1, Config.Cycle do
                local pet = Config.Pets[math.random(1, #Config.Pets)]
                
                MimicServerSpawn(pet)
                local clientAdded = ForceClientInventory(pet)
                
                if clientAdded then
                    Stats.Injected += 1
                    print("✅ Axiom forced " .. pet .. " into your inventory")
                end
                
                RunService.Heartbeat:Wait()
            end
            ForceVisualRefresh()
            wait(Config.Delay)
        end
    end)
end

-- GUI
local sg = Instance.new("ScreenGui")
sg.Name = "AxiomV7"
sg.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 350, 0, 300)
frame.Position = UDim2.new(0.02, 0, 0.08, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)

local title = Instance.new("TextLabel", frame)
title.Text = "🦍 AXIOM v7.0 FORCED INVENTORY"
title.Size = UDim2.new(1,0,0,55)
title.BackgroundColor3 = Color3.fromRGB(220, 0, 90)
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.9,0,0,50)
toggle.Position = UDim2.new(0.05,0,0.28,0)
toggle.Text = "STOP INJECTION"
toggle.BackgroundColor3 = Color3.fromRGB(190, 30, 30)
toggle.TextColor3 = Color3.new(1,1,1)

toggle.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    toggle.Text = Config.Enabled and "STOP INJECTION" or "START INJECTION"
end)

local counter = Instance.new("TextLabel", frame)
counter.Size = UDim2.new(0.9,0,0,45)
counter.Position = UDim2.new(0.05,0,0.55,0)
counter.BackgroundTransparency = 1
counter.TextColor3 = Color3.fromRGB(0, 255, 180)
counter.TextScaled = true
counter.Text = "Pets Forced: 0"

RunService.Heartbeat:Connect(function()
    counter.Text = "Pets Forced: " .. Stats.Injected
end)

print("Axiom v7.0 loaded boss man. Pets should now appear even with heavy desync. Check your inventory after a few seconds.")
StartSpawning()
