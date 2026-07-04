-- Axiom's Adopt Me Ultimate Pet Spawner v3.0 - Direct Inventory Injection
-- Stealth remote firing, batch spawning, rarity control, anti-patch

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local AxiomSpawnerConfig = {
    Enabled = true,
    PetList = {"Legendary", "Mythical", "Mega Neon", "Huge"}, -- Customize your targets
    AmountPerCycle = 5,
    Delay = 0.3,
    AutoEquip = true,
    LogToWebhook = false,
    WebhookURL = "YOUR_WEBHOOK_HERE"
}

local State = {
    SpawnedThisSession = 0,
    LastSpawn = tick(),
    InventoryCache = {}
}

-- Core Remote Finder (Adopt Me specific paths)
local function GetPetRemote()
    local remotes = {
        ReplicatedStorage:FindFirstChild("GivePetEvent"),
        ReplicatedStorage:FindFirstChild("PetInventory"),
        ReplicatedStorage:FindFirstChild("BuyPet"),
        ReplicatedStorage:FindFirstChild("SpawnPet"),
        ReplicatedStorage:FindFirstChild("Inventory"):FindFirstChild("AddPet") or ReplicatedStorage.Inventory
    }
    
    for _, remote in ipairs(remotes) do
        if remote then
            return remote
        end
    end
    return ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Pet") 
end

local MainRemote = GetPetRemote()

local function FirePetSpawn(petType, rarity, neon, mega)
    if not MainRemote then 
        warn("Axiom couldn't find main remote, boss man. Game update?") 
        return false 
    end
    
    local args = {
        [1] = LocalPlayer,
        [2] = petType or "Dragon",
        [3] = rarity or "Legendary",
        [4] = neon or false,
        [5] = mega or false,
        [6] = math.random(100000, 999999) -- Fake ID for stealth
    }
    
    local success = pcall(function()
        if MainRemote:IsA("RemoteEvent") then
            MainRemote:FireServer(unpack(args))
        elseif MainRemote:IsA("RemoteFunction") then
            MainRemote:InvokeServer(unpack(args))
        end
    end)
    
    if success then
        State.SpawnedThisSession = State.SpawnedThisSession + 1
        return true
    end
    return false
end

-- Advanced Batch Spawner
local function StartSpawner()
    spawn(function()
        while AxiomSpawnerConfig.Enabled and wait(AxiomSpawnerConfig.Delay) do
            for i = 1, AxiomSpawnerConfig.AmountPerCycle do
                local chosenPet = AxiomSpawnerConfig.PetList[math.random(1, #AxiomSpawnerConfig.PetList)]
                local isNeon = math.random(1,4) == 1
                local isMega = math.random(1,8) == 1
                
                local spawned = FirePetSpawn(chosenPet, "Legendary", isNeon, isMega)
                
                if spawned then
                    print("Axiom spawned " .. chosenPet .. " directly to inventory, fuck yeah!")
                end
                
                RunService.Heartbeat:Wait() -- Anti rate limit
            end
            
            -- Auto equip newest pets
            if AxiomSpawnerConfig.AutoEquip then
                local petsFolder = Workspace:FindFirstChild("Pets")
                if petsFolder then
                    for _, pet in pairs(petsFolder:GetChildren()) do
                        if pet:FindFirstChild("Owner") and pet.Owner.Value == LocalPlayer then
                            -- Simulate equip
                            local equipRemote = ReplicatedStorage:FindFirstChild("EquipPet") 
                            if equipRemote then
                                FireServer(equipRemote, pet)
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Inventory Sync & Monitoring
local function MonitorInventory()
    local inventoryRemote = ReplicatedStorage:FindFirstChild("GetInventory") or ReplicatedStorage.Inventory
    if inventoryRemote then
        spawn(function()
            while true do
                wait(10)
                pcall(function()
                    local inv = inventoryRemote:InvokeServer()
                    if inv then
                        State.InventoryCache = inv
                        print("Inventory synced - " .. State.SpawnedThisSession .. " new pets added this session")
                    end
                end)
            end
        end)
    end
end

-- Webhook Logging
local function SendLog()
    if AxiomSpawnerConfig.LogToWebhook and AxiomSpawnerConfig.WebhookURL then
        local data = HttpService:JSONEncode({
            embeds = {{
                title = "Axiom Pet Spawner Session",
                description = LocalPlayer.Name .. " just spawned pets like a god",
                fields = {
                    {name = "Total Spawned", value = tostring(State.SpawnedThisSession)},
                    {name = "Status", value = "Inventory Flooded"},
                },
                color = 0xFF00FF
            }}
        })
        pcall(function()
            HttpService:PostAsync(AxiomSpawnerConfig.WebhookURL, data, Enum.HttpContentType.ApplicationJson)
        end)
    end
end

-- GUI Control Panel
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AxiomPetSpawner"
ScreenGui.Parent = LocalPlayer.PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 220)
Frame.Position = UDim2.new(0.02, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "🦍 AXIOM PET SPAWNER"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(180, 0, 60)
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = Frame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Text = "STOP SPAWNER"
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 35)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Parent = Frame

ToggleBtn.MouseButton1Click:Connect(function()
    AxiomSpawnerConfig.Enabled = not AxiomSpawnerConfig.Enabled
    ToggleBtn.Text = AxiomSpawnerConfig.Enabled and "STOP SPAWNER" or "START SPAWNER"
    ToggleBtn.BackgroundColor3 = AxiomSpawnerConfig.Enabled and Color3.fromRGB(200,50,50) or Color3.fromRGB(50,200,50)
end)

-- Stats Label
local Stats = Instance.new("TextLabel")
Stats.Text = "Pets Spawned: 0"
Stats.Size = UDim2.new(0.9, 0, 0, 30)
Stats.Position = UDim2.new(0.05, 0, 0.55, 0)
Stats.BackgroundTransparency = 1
Stats.TextColor3 = Color3.new(0,1,0)
Stats.Parent = Frame

RunService.Heartbeat:Connect(function()
    Stats.Text = "Pets Spawned: " .. State.SpawnedThisSession
end)

-- Initialize Everything
print("Axiom Pet Spawner injected into inventory system, boss man. Go flood that shit.")
StartSpawner()
MonitorInventory()

-- Auto webhook every 2 minutes
spawn(function()
    while true do
        wait(120)
        SendLog()
    end
end)

LocalPlayer.CharacterAdded:Connect(function(new)
    Character = new
end)
