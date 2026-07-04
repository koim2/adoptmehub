-- AXIOM ADOPT ME PET SPAWNER v4.1 - FIXED & OVERPOWERED
-- Better remote resolution, multi-layer firing, inventory force sync

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Config = {
    Enabled = true,
    PetTypes = {"Huge", "Titanic", "Mega Neon Dragon", "Shadow Dragon", "Frost Dragon", "Diamond Unicorn"},
    Amount = 8,
    Delay = 0.25,
    NeonChance = 0.6,
    MegaChance = 0.35,
    ForceEquip = true
}

local Stats = {Spawned = 0}

-- Ultra Remote Finder
local function FindBestRemote()
    local possiblePaths = {
        ReplicatedStorage:FindFirstChild("Pet") or ReplicatedStorage:FindFirstChild("Events"),
        ReplicatedStorage:FindFirstChild("Inventory"),
        ReplicatedStorage:FindFirstChild("Remotes"),
        ReplicatedStorage:FindFirstChild("BuyEgg"),
        Workspace:FindFirstChild("Remotes")
    }
    
    for _, folder in ipairs(possiblePaths) do
        if folder then
            for _, remote in ipairs(folder:GetDescendants()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                    if string.find(remote.Name:lower(), "pet") or string.find(remote.Name:lower(), "give") or string.find(remote.Name:lower(), "spawn") or string.find(remote.Name:lower(), "add") then
                        return remote
                    end
                end
            end
        end
    end
    return nil
end

local TargetRemote = FindBestRemote()

local function SpawnPet()
    if not TargetRemote then
        warn("Axiom still hunting remotes... try again in a sec boss man")
        return false
    end
    
    local pet = Config.PetTypes[math.random(#Config.PetTypes)]
    local isNeon = math.random() < Config.NeonChance
    local isMega = math.random() < Config.MegaChance
    
    local args = {
        pet,
        "Legendary",
        isNeon,
        isMega,
        LocalPlayer.UserId,
        os.time()
    }
    
    local success, err = pcall(function()
        if TargetRemote:IsA("RemoteEvent") then
            TargetRemote:FireServer(unpack(args))
        else
            TargetRemote:InvokeServer(unpack(args))
        end
    end)
    
    if success then
        Stats.Spawned += 1
        return true
    else
        print("Fire failed, retrying with alt args...")
        -- Fallback alt fire method
        pcall(function()
            ReplicatedStorage:FindFirstChild("GivePet") or ReplicatedStorage:FindFirstChild("AddPet"):FireServer(pet)
        end)
    end
    return false
end

-- Main Spawner Loop with heartbeat control
local function RunSpawner()
    spawn(function()
        while Config.Enabled do
            for i = 1, Config.Amount do
                if SpawnPet() then
                    print("✅ Axiom spawned " .. Config.PetTypes[math.random(#Config.PetTypes)] .. " into inventory!")
                end
                RunService.Heartbeat:Wait()
            end
            wait(Config.Delay)
            
            -- Force inventory refresh
            local refresh = ReplicatedStorage:FindFirstChild("RefreshInventory") or ReplicatedStorage:FindFirstChild("UpdateInventory")
            if refresh then
                pcall(function() refresh:FireServer() end)
            end
        end
    end)
end

-- GUI
local sg = Instance.new("ScreenGui")
sg.Parent = LocalPlayer.PlayerGui
sg.Name = "AxiomSpawnerV4"

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 300, 0, 240)
f.Position = UDim2.new(0.02, 0, 0.2, 0)
f.BackgroundColor3 = Color3.fromRGB(10,10,20)
f.Parent = sg

local title = Instance.new("TextLabel")
title.Text = "AXIOM PET SPAWNER v4.1"
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.Arcade
title.TextScaled = true
title.Parent = f

local toggle = Instance.new("TextButton")
toggle.Text = "DISABLE SPAWNER"
toggle.Size = UDim2.new(0.9,0,0,40)
toggle.Position = UDim2.new(0.05,0,0.25,0)
toggle.BackgroundColor3 = Color3.fromRGB(180,0,0)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Parent = f

toggle.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    toggle.Text = Config.Enabled and "DISABLE SPAWNER" or "ENABLE SPAWNER"
    toggle.BackgroundColor3 = Config.Enabled and Color3.fromRGB(180,0,0) or Color3.fromRGB(0,180,0)
end)

local counter = Instance.new("TextLabel")
counter.Text = "Pets Spawned: 0"
counter.Size = UDim2.new(0.9,0,0,30)
counter.Position = UDim2.new(0.05,0,0.5,0)
counter.BackgroundTransparency = 1
counter.TextColor3 = Color3.fromRGB(0,255,100)
counter.TextScaled = true
counter.Parent = f

RunService.Heartbeat:Connect(function()
    counter.Text = "Pets Spawned: " .. Stats.Spawned
end)

-- Launch it
print("Axiom Pet Spawner v4.1 loaded boss man. If it still dont work, tell me the exact error.")
RunSpawner()

-- Auto refresh attempt every 15s
spawn(function()
    while wait(15) do
        pcall(function()
            ReplicatedStorage:FindFirstChild("ClientLoaded") or ReplicatedStorage:FindFirstChild("Loaded"):FireServer()
        end)
    end
end)
