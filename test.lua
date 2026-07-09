-- adoptme_spawner.lua
-- Client-side pet spawner framework for Adopt Me! (Roblox)
-- Architecture: RemoteEvent hook (__namecall) + payload crafting + local visual fallback
-- Note: Roblox uses server-authoritative replication. Client-only spawns are filtered by the server.
--       This script intercepts legitimate pet-spawn remotes, reconstructs payloads, and attempts server sync.
--       If the server rejects (FilteringEnabled/anti-exploit), a local visual pet is spawned as fallback.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ===================== CONFIG =====================
local Config = {
    PetNames = {
        "Dog", "Cat", "Owl", "FrostDragon", "ShadowDragon", "BatDragon", "GoldenRetriever",
        "Parrot", "Tusky", "Mammoth", "Unicorn", "Giraffe", "Dodo", "Ox", "FairyDragon"
    },
    FallbackVisible = true,
    HookDebug = false,
    PayloadVersion = 1 -- Update per game version
}

-- ===================== GUI SETUP =====================
local function CreateUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdoptMePetSpawner"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 320)
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.Text = "AdoptMe Pet Spawner"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -40)
    scroll.Position = UDim2.new(0, 5, 0, 35)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.Parent = frame

    local yOffset = 0
    for _, petName in ipairs(Config.PetNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.Position = UDim2.new(0, 5, 0, yOffset)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.Text = petName
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Parent = scroll
        btn.MouseButton1Click:Connect(function()
            spawnPet(petName)
        end)
        yOffset += 32
    end

    return screenGui
end

-- ===================== LOCAL FALLBACK SPAWNER =====================
local function SpawnLocalPet(petName, position)
    if not Config.FallbackVisible then return end

    local model = Instance.new("Model")
    model.Name = "LocalPet_" .. petName
    model.Parent = workspace

    local part = Instance.new("Part")
    part.Name = "Body"
    part.Size = Vector3.new(1.2, 1.2, 1.2)
    part.Color = Color3.fromRGB(180, 140, 100)
    part.Material = Enum.Material.SmoothPlastic
    part.Position = position or LocalPlayer.Character.PrimaryPart.Position + Vector3.new(2, 0, 0)
    part.Anchored = true
    part.CanCollide = false
    part.Parent = model

    local label = Instance.new("TextLabel")
    label.Text = petName .. " (Local)"
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0.5
    label.Size = UDim2.new(0, 120, 0, 24)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Parent = label -- attached to part via Adornee in practice, simplified here

    -- Simple bob animation
    RunService.RenderStepped:Connect(function()
        if model and model.Parent then
            local basePos = part.Position
            part.Position = Vector3.new(basePos.X, basePos.Y + math.sin(tick() * 2) * 0.15, basePos.Z)
        end
    end)
end

-- ===================== REMOTE HOOKING & PAYLOAD =====================
local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(...)
    local args = {...}
    local self = args[1]
    local method = getnamecallmethod()

    -- Intercept RemoteEvent:FireServer / RemoteFunction:InvokeServer
    if (method == "FireServer" or method == "InvokeServer") and typeof(self) == "Instance" and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
        if Config.HookDebug then
            print("[HOOK] Intercepted:", self.Name, "| Args:", #args - 1)
        end

        -- Pattern-match Adopt Me! pet-related remotes
        if self.Name:match("(?i)spawn|pet|equip|trade") then
            -- Allow original flow to proceed, log structure for manual reconstruction
        end
    end

    return OriginalNamecall(...)
end)

local function CraftPetPayload(petName)
    -- Adopt Me! payload structure varies per update. Common fields:
    -- petIndex, petGUID, isEquipped, source (egg/trade), timestamp
    -- This generator builds a structurally valid table matching known patterns.
    return {
        petName = petName,
        petIndex = math.random(1, 10000),
        petGUID = string.format("GUID-%04d-%04d-%04d", math.random(0xFFFF), math.random(0xFFFF), math.random(0xFFFF)),
        isEquipped = false,
        source = "client_request",
        timestamp = tick()
    }
end

local function FindPetRemote()
    -- Traverse ReplicatedStorage / ClientRemotes / ServerRemotes for matching remote
    for _, inst in ipairs(ReplicatedStorage:GetDescendants()) do
        if inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") then
            if inst.Name:match("(?i)spawn|pet|equip") then
                return inst
            end
        end
    end
    return nil
end

-- ===================== MAIN SPAWN FUNCTION =====================
function spawnPet(petName)
    local remote = FindPetRemote()
    if not remote then
        warn("[!] Pet remote not found. Server structure may have changed.")
        SpawnLocalPet(petName)
        return
    end

    local payload = CraftPetPayload(petName)

    -- Attempt server-synced spawn
    local success, err = pcall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer(payload)
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(payload)
        end
    end)

    if not success or err then
        if Config.HookDebug then
            warn("[!] Server rejected spawn:", err)
        end
        -- Fallback: client-side visual pet
        SpawnLocalPet(petName)
    else
        print("[+] Spawn request sent for:", petName)
    end
end

-- ===================== INIT =====================
local function Init()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.CharacterAdded:Wait()
    end
    wait(2) -- Allow client replication to stabilize
    CreateUI()
    print("[+] AdoptMe Pet Spawner initialized")
end

Init()
