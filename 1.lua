-- adoptme_visual_spawner_v3.0.lua
-- Version: 3.0 [LOCAL VISUAL SPAWNER]
-- Architecture: Client-Side Injection. Bypasses broken game systems.
-- Note: The game client is currently throwing errors (PetStateReplicator/NetEvent).
--       This script ignores the game's broken logic and spawns a pet directly in the workspace.
--       It will look real, follow you, and sit on command. It will NOT sync to server (due to client errors).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- ===================== CONFIG =====================
local Config = {
    PetColor = Color3.fromRGB(255, 255, 255), -- Default White (Snow Owl)
    FollowDistance = 3,
    SitEnabled = false
}

-- ===================== PET CLASS =====================
local ActivePets = {}

local function CreateVisualPet(name, color)
    local model = Instance.new("Model")
    model.Name = "VisualPet_" .. name
    model.Parent = workspace

    -- Body
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(1.5, 1.5, 1.5)
    body.Color = color
    body.Material = Enum.Material.SmoothPlastic
    body.Anchored = false
    body.CanCollide = false
    body.Parent = model

    -- Head
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(1.2, 1.2, 1.2)
    head.Color = color
    head.Material = Enum.Material.SmoothPlastic
    head.Anchored = false
    head.CanCollide = false
    head.Position = body.Position + Vector3.new(0, 1.2, 0)
    head.Parent = model

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = body
    weld.Part1 = head
    weld.Parent = body

    -- Humanoid (Required for some game interactions)
    local hum = Instance.new("Humanoid")
    hum.Name = "Humanoid"
    hum.HealthDisplayDistance = 0
    hum.NameDisplayDistance = 0
    hum.Parent = model

    -- Billboard GUI (Name Tag)
    local gui = Instance.new("BillboardGui")
    gui.Adornee = head
    gui.Size = UDim2.new(0, 100, 0, 30)
    gui.StudsOffset = Vector3.new(0, 2, 0)
    gui.AlwaysOnTop = true
    gui.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Parent = gui

    -- Position near player
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        body.Position = char.HumanoidRootPart.Position + Vector3.new(3, 0, 0)
    end

    table.insert(ActivePets, model)
    return model
end

-- ===================== FOLLOW LOGIC =====================
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local root = char.HumanoidRootPart
    local offset = Vector3.new(0, 0, Config.FollowDistance)

    for _, pet in ipairs(ActivePets) do
        if pet and pet.Parent and pet:FindFirstChild("Body") then
            local body = pet.Body
            -- Simple follow logic using BodyPosition
            local bp = body:FindFirstChild("BodyPosition")
            if not bp then
                bp = Instance.new("BodyPosition")
                bp.MaxForce = Vector3.new(10000, 10000, 10000)
                bp.Parent = body
            end

            local targetPos = root.Position + (root.CFrame.LookVector * -Config.FollowDistance) + Vector3.new(0, 1, 0)
            if Config.SitEnabled then
                targetPos = root.Position + Vector3.new(0, -2, 0) -- Sit at feet
            end

            bp.Position = targetPos
        end
    end
end)

-- ===================== UI SETUP =====================
local function CreateUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VisualSpawner"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 300)
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.Text = "Visual Spawner v3.0"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 20)
    status.Position = UDim2.new(0, 10, 0, 40)
    status.BackgroundTransparency = 1
    status.Text = "MODE: CLIENT-SIDE (No Server Sync)"
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
    status.Font = Enum.Font.GothamBold
    status.TextSize = 10
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = frame

    -- Spawn Button
    local spawnBtn = Instance.new("TextButton")
    spawnBtn.Size = UDim2.new(1, -20, 0, 40)
    spawnBtn.Position = UDim2.new(0, 10, 0, 80)
    spawnBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    spawnBtn.Text = "SPAWN SNOW OWL"
    spawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    spawnBtn.Font = Enum.Font.GothamBold
    spawnBtn.TextSize = 14
    spawnBtn.Parent = frame
    spawnBtn.MouseButton1Click:Connect(function()
        CreateVisualPet("Snow Owl", Color3.fromRGB(240, 248, 255))
        print("[+] Spawned Visual Snow Owl")
    end)

    -- Sit Toggle
    local sitBtn = Instance.new("TextButton")
    sitBtn.Size = UDim2.new(1, -20, 0, 40)
    sitBtn.Position = UDim2.new(0, 10, 0, 130)
    sitBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 50)
    sitBtn.Text = "TOGGLE SIT"
    sitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sitBtn.Font = Enum.Font.GothamBold
    sitBtn.TextSize = 14
    sitBtn.Parent = frame
    sitBtn.MouseButton1Click:Connect(function()
        Config.SitEnabled = not Config.SitEnabled
        sitBtn.Text = Config.SitEnabled and "STAND UP" or "TOGGLE SIT"
        print("[+] Sit mode:", Config.SitEnabled)
    end)

    -- Remove All
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(1, -20, 0, 40)
    clearBtn.Position = UDim2.new(0, 10, 0, 180)
    clearBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    clearBtn.Text = "REMOVE ALL"
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 14
    clearBtn.Parent = frame
    clearBtn.MouseButton1Click:Connect(function()
        for _, pet in ipairs(ActivePets) do
            if pet then pet:Destroy() end
        end
        ActivePets = {}
        print("[+] Removed all pets")
    end)

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -20, 0, 60)
    info.Position = UDim2.new(0, 10, 0, 230)
    info.BackgroundTransparency = 1
    info.Text = "NOTE: Game client errors detected. This spawner works locally to bypass broken game systems."
    info.TextColor3 = Color3.fromRGB(180, 180, 180)
    info.Font = Enum.Font.Gotham
    info.TextSize = 10
    info.TextWrapped = true
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = frame

    return screenGui
end

-- ===================== INIT =====================
local function Init()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.CharacterAdded:Wait()
    end
    wait(1)
    CreateUI()
    print("[+] Visual Spawner v3.0 initialized.")
    print("[+] Bypassing broken client systems.")
    print("[+] Spawn pets to see them follow you.")
end

Init()
