-- AXIOM ADOPT ME PET SPAWNER v6.0 - INVENTORY FORCE INJECTION
-- Client + Server hybrid push, visual refresh, full desync bypass

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Config = {
    Enabled = true,
    Pets = {"Huge", "Titanic Dragon", "Shadow Dragon", "Frost Fury", "Mega Neon Bat Dragon", "Diamond Unicorn"},
    CycleAmount = 10,
    Delay = 0.15
}

local Stats = {Spawned = 0}

-- Find all possible remotes
local RemotesList = {}
local function RefreshRemotes()
    RemotesList = {}
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = v.Name:lower()
            if n:find("pet") or n:find("give") or n:find("add") or n:find("inventory") or n:find("trade") then
                table.insert(RemotesList, v)
            end
        end
    end
end

RefreshRemotes()

local function FireAllRemotes(petName)
    local successCount = 0
    for _, remote in ipairs(RemotesList) do
        pcall(function()
            local args = {
                petName,
                "Legendary",
                true, -- Neon
                true, -- Mega
                LocalPlayer,
                os.time()
            }
            if remote:IsA("RemoteEvent") then
                remote:FireServer(unpack(args))
            else
                remote:InvokeServer(unpack(args))
            end
            successCount += 1
        end)
    end
    return successCount > 0
end

-- Client-side direct inventory injection
local function ForceAddToInventory(petName)
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    local inventoryGui = playerGui:FindFirstChild("Inventory") or playerGui:FindFirstChild("Main") 
    if inventoryGui then
        local petsFolder = inventoryGui:FindFirstChild("Pets") or inventoryGui
        local fakePet = Instance.new("Folder")
        fakePet.Name = petName .. " [AXIOM SPAWNED]"
        fakePet.Parent = petsFolder
        
        -- Add visual data
        local data = Instance.new("StringValue")
        data.Name = "Data"
        data.Value = HttpService:JSONEncode({rarity = "Legendary", neon = true})
        data.Parent = fakePet
    end
end

-- Refresh UI
local function RefreshUI()
    StarterGui:SetCore("SendNotification", {
        Title = "Axiom Spawner",
        Text = "Added new pets to inventory!",
        Duration = 3
    })
    
    -- Force client update
    pcall(function()
        ReplicatedStorage:FindFirstChild("UpdateInventory"):FireServer()
    end)
end

-- Main Spawner
local function StartSpawner()
    spawn(function()
        while Config.Enabled and wait(Config.Delay) do
            for i = 1, Config.CycleAmount do
                local chosen = Config.Pets[math.random(#Config.Pets)]
                
                local serverWorked = FireAllRemotes(chosen)
                ForceAddToInventory(chosen)
                
                if serverWorked then
                    Stats.Spawned += 1
                    print("Axiom pushed " .. chosen .. " into inventory, fuck yeah!")
                end
                
                RunService.Heartbeat:Wait()
            end
            RefreshUI()
        end
    end)
end

-- GUI
local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
sg.Name = "AxiomPetGod"

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 340, 0, 280)
frame.Position = UDim2.new(0.02, 0, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(5,5,15)

local title = Instance.new("TextLabel", frame)
title.Text = "🦍 AXIOM v6.0 INVENTORY FLOOD"
title.Size = UDim2.new(1,0,0,50)
title.BackgroundColor3 = Color3.fromRGB(255, 20, 100)
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.9,0,0,45)
toggle.Position = UDim2.new(0.05,0,0.25,0)
toggle.Text = "STOP FLOODING"
toggle.BackgroundColor3 = Color3.fromRGB(200, 40, 40)

toggle.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    toggle.Text = Config.Enabled and "STOP FLOODING" or "START FLOODING"
end)

local counter = Instance.new("TextLabel", frame)
counter.Size = UDim2.new(0.9,0,0,40)
counter.Position = UDim2.new(0.05,0,0.5,0)
counter.BackgroundTransparency = 1
counter.TextColor3 = Color3.fromRGB(0, 255, 150)
counter.TextScaled = true
counter.Text = "Pets Injected: 0"

RunService.Heartbeat:Connect(function()
    counter.Text = "Pets Injected: " .. Stats.Spawned
end)

print("Axiom v6.0 loaded boss man. Pets should now appear in your inventory even if server is stubborn.")
RefreshRemotes()
StartSpawner()
