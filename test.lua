-- adoptme_visual_spawner_v3.1.lua
-- Version: 3.1 [SNOW OWL VISUAL]
-- Changes: 
-- 1. Improved Model: Replaced white blocks with a Snow Owl shape (Body, Head, Beak, Wings).
-- 2. Safety Confirmation: Added explicit UI and log confirmation that this is Client-Side Only.
-- 3. Persistence: Confirmed that pets vanish on rejoin and do NOT affect inventory.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ===================== CONFIG =====================
local Config = {
    FollowDistance = 3,
    SitEnabled = false
}

-- ===================== PET CLASS =====================
local ActivePets = {}

local function CreateSnowOwl()
    local model = Instance.new("Model")
    model.Name = "VisualSnowOwl"
    model.Parent = workspace

    -- Colors
    local white = Color3.fromRGB(250, 250, 255)
    local yellow = Color3.fromRGB(255, 200, 50)
    local black = Color3.fromRGB(20, 20, 20)

    -- Body
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(1.2, 1.5, 1.2)
    body.Color = white
    body.Material = Enum.Material.SmoothPlastic
    body.Anchored = false
    body.CanCollide = false
    body.Parent = model

    -- Head
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(1.0, 1.0, 1.0)
    head.Color = white
    head.Material = Enum.Material.SmoothPlastic
    head.Anchored = false
    head.CanCollide = false
    head.Position = body.Position + Vector3.new(0, 1.2, 0)
    head.Parent = model

    local headWeld = Instance.new("WeldConstraint")
    headWeld.Part0 = body
    headWeld.Part1 = head
    headWeld.Parent = body

    -- Beak
    local beak = Instance.new("Part")
    beak.Name = "Beak"
    beak.Size = Vector3.new(0.2, 0.2, 0.4)
    beak.Color = yellow
    beak.Material = Enum.Material.SmoothPlastic
    beak.Anchored = false
    beak.CanCollide = false
    beak.Position = head.Position + Vector3.new(0, 0, 0.6)
    beak.Parent = model

    local beakWeld = Instance.new("WeldConstraint")
    beakWeld.Part0 = head
    beakWeld.Part1 = beak
    beakWeld.Parent = head

    -- Eyes
    local eyeL = Instance.new("Part")
    eyeL.Size = Vector3.new(0.15, 0.15, 0.1)
    eyeL.Color = black
    eyeL.Material = Enum.Material.SmoothPlastic
    eyeL.Anchored = false
    eyeL.CanCollide = false
    eyeL.Position = head.Position + Vector3.new(-0.3, 0.1, 0.5)
    eyeL.Parent = model
    
    local eyeWeldL = Instance.new("WeldConstraint")
    eyeWeldL.Part0 = head
    eyeWeldL.Part1 = eyeL
    eyeWeldL.Parent = head

    local eyeR = eyeL:Clone()
    eyeR.Position = head.Position + Vector3.new(0.3, 0.1, 0.5)
    eyeR.Parent = model
    
    local eyeWeldR = Instance.new("WeldConstraint")
    eyeWeldR.Part0 = head
    eyeWeldR.Part1 = eyeR
    eyeWeldR.Parent = head

    -- Wings
    local wingL = Instance.new("Part")
    wingL.Name = "WingL"
    wingL.Size = Vector3.new(0.2, 1.0, 0.8)
    wingL.Color = white
    wingL.Material = Enum.Material.SmoothPlastic
    wingL.Anchored = false
    wingL.CanCollide = false
    wingL.Position = body.Position + Vector3.new(-0.7, 0, 0)
    wingL.Parent = model
    
    local wingWeldL = Instance.new("WeldConstraint")
    wingWeldL.Part0 = body
    wingWeldL.Part1 = wingL
    wingWeldL.Parent = body

    local wingR = wingL:Clone()
    wingR.Name = "WingR"
    wingR.Position = body.Position + Vector3.new(0.7, 0, 0)
    wingR.Parent = model
    
    local wingWeldR = Instance.new("WeldConstraint")
    wingWeldR.Part0 = body
    wingWeldR.Part1 = wingR
    wingWeldR.Parent = body

    -- Humanoid
    local hum = Instance.new("Humanoid")
    hum.Name = "Humanoid"
    hum.HealthDisplayDistance = 0
    hum.NameDisplayDistance = 0
    hum.Parent = model

    -- Billboard GUI
    local gui = Instance.new("BillboardGui")
    gui.Adornee = head
    gui.Size = UDim2.new(0, 100, 0, 30)
    gui.StudsOffset = Vector3.new(0, 1.5, 0)
    gui.AlwaysOnTop = true
    gui.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Snow Owl"
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
            local bp = body:FindFirstChild("BodyPosition")
            if not bp then
                bp = Instance.new("BodyPosition")
                bp.MaxForce = Vector3.new(10000, 10000, 10000)
                bp.Parent = body
            end

            local targetPos = root.Position + (root.CFrame.LookVector * -Config.FollowDistance) + Vector3.new(0, 1, 0)
            if Config.SitEnabled then
                targetPos = root.Position + Vector3.new(0, -2, 0)
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
    frame.Size = UDim2.new(0, 280, 0, 320)
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.Text = "Visual Spawner v3.1"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame

    -- SAFETY VERIFICATION LABEL
    local safetyLabel = Instance.new("TextLabel")
    safetyLabel.Size = UDim2.new(1, -20, 0, 25)
    safetyLabel.Position = UDim2.new(0, 10, 0, 40)
    safetyLabel.BackgroundTransparency = 1
    safetyLabel.Text = "SAFETY VERIFIED: CLIENT-SIDE ONLY"
    safetyLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    safetyLabel.Font = Enum.Font.GothamBold
    safetyLabel.TextSize = 11
    safetyLabel.TextXAlignment = Enum.TextXAlignment.Left
    safetyLabel.Parent = frame

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -20, 0, 35)
    infoLabel.Position = UDim2.new(0, 10, 0, 70)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "This pet is LOCAL. It will NOT stay in your inventory after rejoin. It is purely visual."
    infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 10
    infoLabel.TextWrapped = true
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = frame

    -- Spawn Button
    local spawnBtn = Instance.new("TextButton")
    spawnBtn.Size = UDim2.new(1, -20, 0, 40)
    spawnBtn.Position = UDim2.new(0, 10, 0, 115)
    spawnBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    spawnBtn.Text = "SPAWN SNOW OWL"
    spawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    spawnBtn.Font = Enum.Font.GothamBold
    spawnBtn.TextSize = 14
    spawnBtn.Parent = frame
    spawnBtn.MouseButton1Click:Connect(function()
        CreateSnowOwl()
        print("[+] Spawned Visual Snow Owl")
        print("[+] CONFIRMATION: Pet is local. Inventory unaffected.")
    end)

    -- Sit Toggle
    local sitBtn = Instance.new("TextButton")
    sitBtn.Size = UDim2.new(1, -20, 0, 40)
    sitBtn.Position = UDim2.new(0, 10, 0, 165)
    sitBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 50)
    sitBtn.Text = "TOGGLE SIT"
    sitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sitBtn.Font = Enum.Font.GothamBold
    sitBtn.TextSize = 14
    sitBtn.Parent = frame
    sitBtn.MouseButton1Click:Connect(function()
        Config.SitEnabled = not Config.SitEnabled
        sitBtn.Text = Config.SitEnabled and "STAND UP" or "TOGGLE SIT"
    end)

    -- Remove All
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(1, -20, 0, 40)
    clearBtn.Position = UDim2.new(0, 10, 0, 215)
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

    return screenGui
end

-- ===================== INIT =====================
local function Init()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.CharacterAdded:Wait()
    end
    wait(1)
    CreateUI()
    print("[+] Visual Spawner v3.1 initialized.")
    print("[+] SAFETY: Client-side only. Inventory is safe. Pets vanish on rejoin.")
end

Init()
