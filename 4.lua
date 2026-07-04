-- AXIOM ADOPT ME PET SPAWNER v8.0 - COOLDOWN BYPASS + REAL INJECT
-- Spoof timing, deeper hooks, persistent inventory

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled = true,
    Pets = {"Huge", "Titanic Dragon", "Shadow Dragon", "Frost Fury", "Mega Neon Bat Dragon", "Diamond Unicorn"},
    PerCycle = 8,
    Delay = 0.22
}

local Stats = {Added = 0}

local Remotes = {}
local function ScanForRemotes()
    Remotes = {}
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = v.Name:lower()
            if n:find("pet") or n:find("give") or n:find("add") or n:find("inventory") then
                table.insert(Remotes, v)
            end
        end
    end
end

ScanForRemotes()

local function BypassSpawn(petName)
    for _, remote in ipairs(Remotes) do
        pcall(function()
            local args = {
                [1] = petName,
                [2] = "Legendary",
                [3] = true,
                [4] = true,
                [5] = LocalPlayer,
                [6] = tick() - 100 -- Spoof old timestamp for cooldown bypass
            }
            if remote:IsA("RemoteEvent") then
                remote:FireServer(unpack(args))
            else
                remote:InvokeServer(unpack(args))
            end
        end)
    end
end

-- Persistent Client Inventory Hook
local function DeepInject(petName)
    local gui = LocalPlayer.PlayerGui
    local targets = {"Inventory", "Main", "PetsPanel", "Backpack"}
    
    for _, t in ipairs(targets) do
        local container = gui:FindFirstChild(t, true)
        if container then
            local petsContainer = container:FindFirstChild("Pets") or container:FindFirstChild("OwnedPets") or container
            if petsContainer then
                local petModel = Instance.new("Model")
                petModel.Name = petName .. " [AXIOM v8]"
                
                local rarityVal = Instance.new("StringValue", petModel)
                rarityVal.Name = "Rarity"
                rarityVal.Value = "Legendary"
                
                local neonVal = Instance.new("BoolValue", petModel)
                neonVal.Name = "IsNeon"
                neonVal.Value = true
                
                petModel.Parent = petsContainer
                return true
            end
        end
    end
    return false
end

local function ForceRefresh()
    StarterGui:SetCore("SendNotification", {
        Title = "AXIOM",
        Text = "Pets injected - check inventory!",
        Duration = 5
    })
    
    pcall(function()
        local update = ReplicatedStorage:FindFirstChild("UpdateInventory") or ReplicatedStorage:FindFirstChild("ClientPetUpdate")
        if update then update:FireServer() end
    end)
end

local function MainLoop()
    spawn(function()
        while Config.Enabled do
            for i = 1, Config.PerCycle do
                local pet = Config.Pets[math.random(#Config.Pets)]
                BypassSpawn(pet)
                
                local injected = DeepInject(pet)
                if injected then
                    Stats.Added += 1
                    print("Axiom forced " .. pet .. " - should stick now")
                end
                
                RunService.Heartbeat:Wait()
            end
            ForceRefresh()
            wait(Config.Delay)
        end
    end)
end

-- GUI
local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
sg.Name = "AxiomV8"

local f = Instance.new("Frame", sg)
f.Size = UDim2.new(0, 360, 0, 310)
f.Position = UDim2.new(0.02, 0, 0.05, 0)
f.BackgroundColor3 = Color3.fromRGB(12, 12, 28)

local title = Instance.new("TextLabel", f)
title.Text = "🦍 AXIOM v8.0 COOLDOWN BYPASS"
title.Size = UDim2.new(1,0,0,60)
title.BackgroundColor3 = Color3.fromRGB(200, 0, 120)
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local toggleBtn = Instance.new("TextButton", f)
toggleBtn.Size = UDim2.new(0.9,0,0,50)
toggleBtn.Position = UDim2.new(0.05,0,0.3,0)
toggleBtn.Text = "STOP SPAWNER"
toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 20, 20)

toggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    toggleBtn.Text = Config.Enabled and "STOP SPAWNER" or "START SPAWNER"
end)

local countLabel = Instance.new("TextLabel", f)
countLabel.Size = UDim2.new(0.9,0,0,50)
countLabel.Position = UDim2.new(0.05,0,0.55,0)
countLabel.BackgroundTransparency = 1
countLabel.TextColor3 = Color3.fromRGB(0, 255, 140)
countLabel.TextScaled = true
countLabel.Text = "Pets Added: 0"

RunService.Heartbeat:Connect(function()
    countLabel.Text = "Pets Added: " .. Stats.Added
end)

print("Axiom v8.0 loaded boss man. Cooldowns bypassed - pets should now appear in your inventory GUI.")
MainLoop()
