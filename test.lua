-- Deobfuscated reconstruction of uploaded Lua file
-- Original: (049043049061051)gsub(046043,functi.txt
-- Method: static decoding + sandboxed runtime tracing. The original is VM-obfuscated, so this is a behavioural reconstruction,
-- not a byte-for-byte source recovery.

-- Layer 1 anti-tamper gate:
local _XcTkS0
("1+1=3"):gsub(".+", function(y)
    _XcTkS0 = y
end)

if _XcTkS0 ~= "1+1=3" then
    return
end

-- The rest of the file:
-- 1) builds a shuffled constants table,
-- 2) decodes a custom-base64 alphabet:
--    xMnGR69htreiJA1oXN/+KIgbUuzvpwPECVmQ5qOd30ayjSWL8YTZDc7sfl24HkB
-- 3) runs a virtualized Lua bytecode interpreter.
--
-- Runtime behaviour observed in a sandbox:
-- Roblox GUI / exploit-style code named "Pet Spawner By Shxdrag".

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 250)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 3
stroke.Parent = mainFrame

task.spawn(function()
    -- Observed loop: repeatedly updates stroke.Color using Color3.fromHSV(h, 1, 1)
    -- and task.wait(0.05), making a rainbow border.
end)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Text = "Pet Spawner By Shxdrag"
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = topBar

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0.85, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.Parent = mainFrame

local petNameBox = Instance.new("TextBox")
petNameBox.Size = UDim2.new(0.8, 0, 0, 40)
petNameBox.Position = UDim2.new(0.1, 0, 0.25, 0)
petNameBox.PlaceholderText = "Enter Pet Name"
petNameBox.Text = ""
petNameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
petNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
petNameBox.Font = Enum.Font.Gotham
petNameBox.TextSize = 14
petNameBox.Parent = mainFrame

local petNameCorner = Instance.new("UICorner")
petNameCorner.CornerRadius = UDim.new(0, 8)
petNameCorner.Parent = petNameBox

local mfrColor = Color3.fromRGB(255, 100, 100)

local mfrButton = Instance.new("TextButton")
mfrButton.Size = UDim2.new(0.25, 0, 0, 30)
mfrButton.Position = UDim2.new(0.1, 0, 0.45, 0)
mfrButton.Text = "MFR"
mfrButton.BackgroundColor3 = mfrColor
mfrButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mfrButton.Font = Enum.Font.GothamBold
mfrButton.TextSize = 14
mfrButton.Parent = mainFrame

local mfrCorner = Instance.new("UICorner")
mfrCorner.CornerRadius = UDim.new(0, 8)
mfrCorner.Parent = mfrButton

mfrButton.MouseButton1Click:Connect(function()
    statusLabel.Text = "Selected: MFR"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
end)

-- The VM-obfuscated code crashes in this sandbox after the first button callback due to proxy limitations.
-- No loadstring/load dump was observed; it uses a VM rather than emitting plain Lua source.
