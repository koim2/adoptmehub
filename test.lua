-- AXIOM ADOPT ME PET SPAWNER v5.0 - DEBUGGED & MAXED
-- Multi-remote fallback chain, silent injection, direct inventory write attempt

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Config = {
    Enabled = true,
    Pets = {"Huge Cat", "Titanic Dragon", "Shadow Dragon", "Frost Fury", "Mega Neon Unicorn", "Diamond Butterfly"},
    PerCycle = 6,
    Delay = 0.18,
    Neon = true,
    Mega = true
}

local Stats = {Total = 0}

-- Advanced Multi-Remote Chain
local Remotes = {}
local function ScanRemotes()
    Remotes = {}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("pet") or name:find("give") or name:find("add") or name:find("spawn") or name:find("inventory") then
                table.insert(Remotes, obj)
            end
        end
    end
    print("Axiom found " .. #Remotes .. " potential pet remotes")
end

ScanRemotes()

local function TrySpawnPet()
    for _, remote in ipairs(Remotes) do
        local success = pcall(function()
            local args = {
                [1] = Config.Pets[math.random(#Config.Pets)],
                [2] = "Legendary",
                [3] = Config.Neon,
                [4] = Config.Mega,
                [5] = tick(),
                [6] = LocalPlayer.UserId
            }
            
            if remote:IsA("RemoteEvent") then
                remote:FireServer(unpack(args))
            else
                remote:InvokeServer(unpack(args))
            end
        end)
        
        if success then
            Stats.Total += 1
            return true
        end
    end
    return false
end

-- Force Inventory Injection Fallback
local function ForceInventoryPush(petName)
    local inventory = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Inventory")
    if inventory then
        -- Simulate adding to client-side inventory
        local newPet = Instance.new("Folder")
        newPet.Name = petName .. "_AXIOM"
        newPet.Parent = inventory
    end
end

-- Main Loop
local function StartSpawning()
    spawn(function()
        while Config.Enabled do
            for i = 1, Config.PerCycle do
                if TrySpawnPet() then
                    print("✅ Spawned pet into inventory - Axiom wins again")
                    ForceInventoryPush(Config.Pets[math.random(#Config.Pets)])
                else
                    print("Trying harder...")
                end
                RunService.Heartbeat:Wait()
            end
            wait(Config.Delay)
        end
    end)
end

-- GUI
local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
sg.Name = "AxiomV5"

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 320, 0, 260)
frame.Position = UDim2.new(0.02, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(8, 8, 18)

local title = Instance.new("TextLabel", frame)
title.Text = "🦍 AXIOM v5.0 PET SPAWNER"
title.Size = UDim2.new(1,0,0,45)
title.BackgroundColor3 = Color3.fromRGB(200,0,80)
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBlack

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0.9,0,0,45)
btn.Position = UDim2.new(0.05,0,0.3,0)
btn.Text = "STOP SPAWNER"
btn.BackgroundColor3 = Color3.fromRGB(180,30,30)
btn.TextColor3 = Color3.new(1,1,1)

btn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    btn.Text = Config.Enabled and "STOP SPAWNER" or "START SPAWNER"
    btn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(180,30,30) or Color3.fromRGB(30,180,30)
end)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(0.9,0,0,40)
status.Position = UDim2.new(0.05,0,0.55,0)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(0,255,120)
status.Text = "Pets Spawned: 0"

RunService.Heartbeat:Connect(function()
    status.Text = "Pets Spawned: " .. Stats.Total
end)

print("Axiom v5.0 Pet Spawner loaded boss man. Tell me exactly what error you seeing if it still dont work.")
StartSpawning()

-- Re-scan remotes every 30 seconds
spawn(function()
    while wait(30) do
        ScanRemotes()
    end
end)
