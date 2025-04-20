-- Load Shiftlock
loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Shiftlock-22314"))()

-- Despair configuration
getgenv().despair = {
    Main = {
        ["Enabled"] = false,
        ["Keybind"] = "Q",
        ["Camlock"] = true,
        ["Prediction"] = 0.12828,
        ["Smoothness"] = 0.9,
        ["Shake"] = 0.1,
        ["Wallcheck"] = true,
        ["Part"] = "Uppertorso",
        ["Easing"] = Enum.EasingStyle.Exponential,
        ["AutoPrediction"] = false,
        ["Resolver"] = true,
        ["AirshotEnabled"] = true,
    },
    Jump = {
        ["JumpOffset"] = -1.5,
        ["FallOffset"] = 0,
    },
    Triggerbot = {
        ["Enabled"] = false,
        ["Delay"] = 0.01,
    },
    Silent = {
        ["Enabled"] = false,
        ["Prediction"] = 0.1567,
        ["AutoPrediction"] = false,
        ["Part"] = "Uppertorso",
        ["NearestPart"] = true,
        ["FOVSize"] = 300,
    },
    Whitelist = {
        AllowedUsers = {
            {"Siuanrehman", "rbxassetid://3296269340"},
            {"IZDIzd6", "rbxassetid://1234567890"},
            {"User3", "rbxassetid://1234567890"},
        },
    },
}

local function isUserWhitelisted(player)
    for _, allowedUser in ipairs(getgenv().despair.Whitelist.AllowedUsers) do
        if allowedUser[1] == player.Name or allowedUser[2] == player.UserId then
            return true
        end
    end
    return false
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not isUserWhitelisted(LocalPlayer) then
    LocalPlayer:Kick("You are not whitelisted")
    return
end

local faces = {"Front", "Back", "Bottom", "Top", "Right", "Left"}
local materials = {
    {"Wood", "3258599312"}, 
    {"WoodPlanks", "8676581022"},
    {"Minecraft", "8558400252"},
    {"Cobblestone", "5003953441"},
    {"Concrete", "7341687607"},
    {"DiamondPlate", "6849247561"},
    {"Fabric", "118776397"},
    {"Granite", "4722586771"},
    {"Grass", "4722588177"},
    {"Ice", "3823766459"},
    {"Marble", "62967586"},
    {"Metal", "62967586"},
    {"Sand", "152572215"}
}

function texture(ins, id)
    for _, v in pairs(faces) do
        local texture = Instance.new("Texture", ins)
        texture.ZIndex = 2147483647
        texture.Texture = "rbxassetid://" .. id
        texture.Face = Enum.NormalId[v]
        texture.Color3 = ins.Color
        texture.Transparency = ins.Transparency
    end
end

for _, part in pairs(workspace:GetDescendants()) do
    if part:IsA("BasePart") then
        for _, v in pairs(materials) do
            if part.Material.Name == v[1] then
                texture(part, v[2])
                part.Material = "SmoothPlastic"
            end
        end
    end
end

local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local CamlockButton = Instance.new("TextButton")
local TriggerbotButton = Instance.new("TextButton")
local SilentAimButton = Instance.new("TextButton")

local function createButton(button, position, text)
    button.Size = UDim2.new(0, 150, 0, 50)
    button.Position = position
    button.BackgroundTransparency = 0.5
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    button.Font = Enum.Font.Arcade
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Parent = ScreenGui
end

createButton(CamlockButton, UDim2.new(0.05, 0, 0.3, -25), "Camlock Off")
createButton(TriggerbotButton, UDim2.new(0.05, 0, 0.3, 35), "Triggerbot")
createButton(SilentAimButton, UDim2.new(0.05, 0, 0.3, 80), "Silent Aim")

local targetPlayer = nil
local lastKilledPlayer = nil
local highlight = nil

local function getFacingPlayer()
    local cameraPosition = Camera.CFrame.Position
    local cameraDirection = Camera.CFrame.LookVector
    local rayOrigin = cameraPosition
    local rayDirection = cameraDirection * 100
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection)

    if raycastResult and raycastResult.Instance then
        local player = Players:GetPlayerFromCharacter(raycastResult.Instance.Parent)
        if player and player.Team ~= LocalPlayer.Team then
            return player
        end
    end
    return nil
end

local function AimAt(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = target.Character.HumanoidRootPart.Position
        local cameraPosition = Camera.CFrame.Position
        local predictedPosition = targetPosition + (target.Character.HumanoidRootPart.Velocity * getgenv().despair.Main.Prediction)
        local aimCFrame = CFrame.new(cameraPosition, predictedPosition)
        Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, getgenv().despair.Main.Smoothness)
    end
end

local function AutoShoot()
    if getgenv().despair.Triggerbot.Enabled and targetPlayer then
        local character = LocalPlayer.Character
        if character then
            local tool = character:FindFirstChildOfClass("Tool")
            if tool and tool:IsA("Tool") then
                tool:Activate()
            end
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        if humanoid.Health <= 0 then
            targetPlayer = nil
            getgenv().despair.Main.Enabled = false
            CamlockButton.Text = "Camlock Off"
        else
            if getgenv().despair.Main.Enabled then
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") and targetPlayer.Character.Humanoid.Health <= 0 then
                    targetPlayer = lastKilledPlayer
                else
                    lastKilledPlayer = targetPlayer
                end

                targetPlayer = getFacingPlayer() or targetPlayer

                if targetPlayer then
                    AimAt(targetPlayer)
                    AutoShoot()

                    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                        local targetHumanoid = targetPlayer.Character.Humanoid
                        if targetHumanoid.Health <= 0 then
                            targetPlayer = nil
                        end
                    end
                end
            end
        end
    end
end)

CamlockButton.MouseButton1Click:Connect(function()
    getgenv().despair.Main.Enabled = not getgenv().despair.Main.Enabled
    CamlockButton.Text = getgenv().despair.Main.Enabled and "Camlock On" or "Camlock Off"
end)

TriggerbotButton.MouseButton1Click:Connect(function()
    getgenv().despair.Triggerbot.Enabled = not getgenv().despair.Triggerbot.Enabled
    TriggerbotButton.Text = getgenv().despair.Triggerbot.Enabled and "Triggerbot On" or "Triggerbot Off"
end)

SilentAimButton.MouseButton1Click:Connect(function()
    getgenv().despair.Silent.Enabled = not getgenv().despair.Silent.Enabled
    SilentAimButton.Text = getgenv().despair.Silent.Enabled and "Silent Aim On" or "Silent Aim Off"

    if getgenv().despair.Silent.Enabled then
        local fovCircle = Instance.new("Frame")
        fovCircle.Size = UDim2.new(0, getgenv().despair.Silent.FOVSize, 0, getgenv().despair.Silent.FOVSize)
        fovCircle.Position = UDim2.new(0.5, -getgenv().despair.Silent.FOVSize / 2, 0.5, -getgenv().despair.Silent.FOVSize / 2)
        fovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        fovCircle.BackgroundTransparency = 1
        fovCircle.Parent = ScreenGui
    else
        for _, child in pairs(ScreenGui:GetChildren()) do
            if child:IsA("Frame") and child.BackgroundTransparency == 1 then
                child:Destroy()
            end
        end
    end
end)
