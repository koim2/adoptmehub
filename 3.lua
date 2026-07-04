-- AXIOM ADOPT ME v13.0 - DRAGGABLE GUIS + RECURSIVE EXPLORER + PET FIX
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

local Config = {Enabled = true, Amount = 8}
local Stats = {Added = 0}

-- Draggable + Closable GUI Function
local function MakeDraggable(gui, closeBtn)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
        end
    end)
    gui.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    gui.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    if closeBtn then
        closeBtn.MouseButton1Click:Connect(function() gui.Parent:Destroy() end)
    end
end

-- === RECURSIVE REPLICATEDSTORAGE EXPLORER ===
local function CreateExplorer()
    local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    sg.Name = "AxiomExplorer"
    
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 450, 0, 520)
    frame.Position = UDim2.new(0.35, 0, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(18,18,38)
    MakeDraggable(frame)
    
    local title = Instance.new("TextLabel", frame)
    title.Text = "🧪 AXIOM SERVER EXPLORER"
    title.Size = UDim2.new(1,0,0,50)
    title.BackgroundColor3 = Color3.fromRGB(90,0,180)
    title.TextColor3 = Color3.new(1,1,1)
    title.TextScaled = true
    
    local close = Instance.new("TextButton", title)
    close.Text = "X"
    close.Size = UDim2.new(0,30,0,30)
    close.Position = UDim2.new(1,-35,0,10)
    close.BackgroundColor3 = Color3.fromRGB(200,0,0)
    
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1,-20,1,-80)
    scroll.Position = UDim2.new(0,10,0,60)
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.BackgroundTransparency = 0.7
    
    local layout = Instance.new("UIListLayout", scroll)
    
    local function AddItem(parent, item, depth)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,28)
        btn.Text = string.rep("  ", depth) .. "📁 " .. item.Name .. " [" .. item.ClassName .. "]"
        btn.BackgroundColor3 = Color3.fromRGB(40,40,80)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = parent
        scroll.CanvasSize = UDim2.new(0,0,0, scroll.CanvasSize.Y.Offset + 30)
        
        btn.MouseButton1Click:Connect(function()
            print("Axiom opened: " .. item:GetFullName())
            -- Expand children
            for _, child in ipairs(item:GetChildren()) do
                AddItem(parent, child, depth + 1)
            end
        end)
    end
    
    for _, item in ipairs(ReplicatedStorage:GetChildren()) do
        AddItem(scroll, item, 0)
    end
end

-- === PET INJECTOR ===
local function FindPetStorage()
    -- Common Adopt Me pet locations
    local locations = {Workspace:FindFirstChild("Pets"), LocalPlayer.PlayerGui, ReplicatedStorage}
    for _, loc in ipairs(locations) do
        if loc then
            for _, p in ipairs(loc:GetDescendants()) do
                if p.Name == "Snow Cat" or p.Name == "Shadow Dragon" then
                    return p.Parent
                end
            end
        end
    end
    return LocalPlayer.PlayerGui
end

local function InjectPets()
    spawn(function()
        while Config.Enabled do
            local storage = FindPetStorage()
            if storage then
                for i = 1, Config.Amount do
                    local newPet = Instance.new("Model")
                    newPet.Name = "Shadow Dragon [AXIOM]"
                    newPet.Parent = storage
                    Stats.Added += 1
                end
                StarterGui:SetCore("SendNotification", {Title="AXIOM", Text="Pets injected near storage!", Duration=3})
            end
            wait(1.2)
        end
    end)
end

local function CreateInjectorGUI()
    local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    sg.Name = "AxiomInjector"
    
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 380, 0, 300)
    f.Position = UDim2.new(0.02, 0, 0.2, 0)
    f.BackgroundColor3 = Color3.fromRGB(12,12,32)
    MakeDraggable(f)
    
    local title = Instance.new("TextLabel", f)
    title.Text = "🦍 AXIOM PET INJECTOR"
    title.Size = UDim2.new(1,0,0,50)
    title.BackgroundColor3 = Color3.fromRGB(210,0,100)
    title.TextColor3 = Color3.new(1,1,1)
    title.TextScaled = true
    
    local close = Instance.new("TextButton", title)
    close.Text = "X"
    close.Size = UDim2.new(0,30,0,30)
    close.Position = UDim2.new(1,-35,0,10)
    close.BackgroundColor3 = Color3.fromRGB(180,0,0)
    
    local toggle = Instance.new("TextButton", f)
    toggle.Text = "STOP INJECTING"
    toggle.Size = UDim2.new(0.9,0,0,50)
    toggle.Position = UDim2.new(0.05,0,0.3,0)
    toggle.BackgroundColor3 = Color3.fromRGB(170,30,30)
    
    toggle.MouseButton1Click:Connect(function()
        Config.Enabled = not Config.Enabled
        toggle.Text = Config.Enabled and "STOP INJECTING" or "START INJECTING"
    end)
    
    local label = Instance.new("TextLabel", f)
    label.Size = UDim2.new(0.9,0,0,60)
    label.Position = UDim2.new(0.05,0,0.55,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0,255,140)
    label.TextScaled = true
    label.Text = "Pets Added: 0"
    
    RunService.Heartbeat:Connect(function()
        label.Text = "Pets Added: " .. Stats.Added
    end)
    
    MakeDraggable(f, close)
end

print("Axiom v13.0 fully loaded boss man. Drag the GUIs, close with X, explore server files recursively.")
CreateExplorer()
CreateInjectorGUI()
InjectPets()
