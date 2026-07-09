-- adoptme_packet_interceptor_v2.3.lua
-- Version: 2.3 (FIXED: Replay logic corrected to strip 'self' from arguments)
-- Fix: Previous version sent the RemoteInstance itself as the first argument to FireServer.
--      This caused "argument #1 expects a string" errors inside the game's code.
--      Now correctly unpacks only payload arguments.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ===================== CONFIG =====================
local Config = {
    Debug = true,
    FilterKeywords = {"pet", "spawn", "hatch", "egg", "equip", "inventory"},
    InterceptEnabled = false
}

-- ===================== PACKET CACHE =====================
local PacketCache = {}
local OriginalNamecall = nil

local function IsRelevantPacket(args)
    -- Skip self (args[1]) for relevance check if needed, but checking payload is safer
    for i = 2, #args do
        local arg = args[i]
        if type(arg) == "string" then
            for _, keyword in ipairs(Config.FilterKeywords) do
                if arg:lower():find(keyword) then return true end
            end
        elseif type(arg) == "table" then
            for k, v in pairs(arg) do
                if type(v) == "string" and v:lower():find("pet") then return true end
            end
        end
    end
    return false
end

-- ===================== UI SETUP =====================
local statusLabel, enableBtn, disableBtn

local function CreateUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PacketInterceptor"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 250)
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.Text = "Packet Interceptor v2.3 [FIXED]"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame

    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Position = UDim2.new(0, 10, 0, 40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "STATUS: SAFE MODE (Not Intercepting)"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 13
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = frame

    enableBtn = Instance.new("TextButton")
    enableBtn.Size = UDim2.new(1, -20, 0, 40)
    enableBtn.Position = UDim2.new(0, 10, 0, 80)
    enableBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    enableBtn.Text = "ENABLE INTERCEPTOR"
    enableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enableBtn.Font = Enum.Font.GothamBold
    enableBtn.TextSize = 14
    enableBtn.Parent = frame
    enableBtn.MouseButton1Click:Connect(function()
        Config.InterceptEnabled = true
        statusLabel.Text = "STATUS: INTERCEPTING (Capturing Packets)"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        enableBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        enableBtn.Text = "INTERCEPTOR ACTIVE"
        enableBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        print("[+] Interceptor ENABLED.")
    end)

    disableBtn = Instance.new("TextButton")
    disableBtn.Size = UDim2.new(1, -20, 0, 40)
    disableBtn.Position = UDim2.new(0, 10, 0, 130)
    disableBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    disableBtn.Text = "DISABLE INTERCEPTOR"
    disableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    disableBtn.Font = Enum.Font.GothamBold
    disableBtn.TextSize = 14
    disableBtn.Parent = frame
    disableBtn.MouseButton1Click:Connect(function()
        Config.InterceptEnabled = false
        statusLabel.Text = "STATUS: SAFE MODE"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        enableBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        enableBtn.Text = "ENABLE INTERCEPTOR"
        enableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        print("[+] Interceptor DISABLED.")
    end)

    local replayBtn = Instance.new("TextButton")
    replayBtn.Size = UDim2.new(1, -20, 0, 40)
    replayBtn.Position = UDim2.new(0, 10, 0, 180)
    replayBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
    replayBtn.Text = "REPLAY LAST PACKET"
    replayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    replayBtn.Font = Enum.Font.GothamBold
    replayBtn.TextSize = 14
    replayBtn.Parent = frame
    replayBtn.MouseButton1Click:Connect(function()
        ReplayLastPacket()
    end)

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -20, 0, 40)
    infoLabel.Position = UDim2.new(0, 10, 0, 210)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "v2.3: Replay args fixed. Capture enabled."
    infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 11
    infoLabel.TextWrapped = true
    infoLabel.Parent = frame

    return screenGui
end

-- ===================== REPLAY FUNCTION (FIXED) =====================
function ReplayLastPacket()
    if #PacketCache == 0 then
        warn("[!] No packets captured yet.")
        return
    end

    local lastPacket = PacketCache[#PacketCache]
    local remote = lastPacket.Remote
    local rawArgs = lastPacket.Args -- Contains {self, arg1, arg2...}

    -- FIX: Create a new table excluding the first element (self)
    local payloadArgs = {}
    for i = 2, #rawArgs do
        table.insert(payloadArgs, rawArgs[i])
    end

    if Config.Debug then
        print("[+] Replaying packet:", remote.Name, "with", #payloadArgs, "args")
        for i, arg in ipairs(payloadArgs) do
            print("  Arg", i, ":", typeof(arg), tostring(arg))
        end
    end

    local success, err = pcall(function()
        -- Send only payload args, not the remote instance
        remote:FireServer(unpack(payloadArgs))
    end)

    if not success then
        warn("[!] Replay failed:", err)
    else
        print("[+] Replay sent successfully.")
    end
end

-- ===================== HOOKING =====================
OriginalNamecall = hookmetamethod(game, "__namecall", function(...)
    local args = {...}
    local self = args[1]
    local method = getnamecallmethod()

    local result = {OriginalNamecall(...)}

    if Config.InterceptEnabled and (method == "FireServer" or method == "InvokeServer") and typeof(self) == "Instance" and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
        if IsRelevantPacket(args) then
            table.insert(PacketCache, {
                Remote = self,
                Args = args
            })
            if Config.Debug then
                print("[INTERCEPT] Captured:", self.Name)
            end
            if statusLabel then
                statusLabel.Text = "Packet captured: " .. self.Name
            end
        end
    end

    return unpack(result)
end)

-- ===================== INIT =====================
local function Init()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.CharacterAdded:Wait()
    end
    wait(1)
    CreateUI()
    print("[+] Packet Interceptor v2.3 initialized.")
    print("[+] Replay logic fixed. Pets should work normally in SAFE MODE.")
end

Init()
