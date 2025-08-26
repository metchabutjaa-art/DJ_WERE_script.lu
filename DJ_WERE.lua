local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

-- ข้อความกลางจอสวย ๆ สีรุ้ง
local textLabel = Instance.new("TextLabel")
textLabel.Parent = gui
textLabel.Size = UDim2.new(0,600,0,50)
textLabel.Position = UDim2.new(0.5,-300,0.4,0)
textLabel.Text = "DJ_WERE - สคริปต์นี้ใช้ได้เฉพาะคนรู้จัก"
textLabel.Font = Enum.Font.GothamBold
textLabel.TextSize = 28
textLabel.TextColor3 = Color3.fromRGB(255,0,0)
textLabel.BackgroundTransparency = 1
textLabel.TextStrokeTransparency = 0
textLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)

local hue = 0
RunService.RenderStepped:Connect(function(delta)
    hue = (hue + delta*50) % 360
    textLabel.TextColor3 = Color3.fromHSV(hue/360,1,1)
end)

-- โลโก้นินจา ขอบบนซ้าย
local logo = Instance.new("TextButton")
logo.Parent = gui
logo.Size = UDim2.new(0,60,0,60)
logo.Position = UDim2.new(0,10,0,10)
logo.Text = "忍"
logo.Font = Enum.Font.GothamBold
logo.TextSize = 40
logo.TextColor3 = Color3.fromRGB(255,255,255)
logo.BackgroundColor3 = Color3.fromRGB(50,50,50)
logo.AutoButtonColor = true
logo.Visible = false

-- Frame ฟังก์ชัน Aimbot
local functionFrame = Instance.new("Frame")
functionFrame.Parent = gui
functionFrame.Size = UDim2.new(0,200,0,80)
functionFrame.Position = UDim2.new(0,80,0,10)
functionFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
functionFrame.Visible = false

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(255,255,255)
stroke.Transparency = 0.3
stroke.Parent = functionFrame

-- Touch Drag
local function makeDraggableTouch(frame)
    local dragging = false
    local startPos, startInputPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = frame.Position
            startInputPos = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            startInputPos = input.Position
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and startInputPos then
            local delta = input.Position - startInputPos
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggableTouch(logo)
makeDraggableTouch(functionFrame)

-- กดโลโก้นินจาโชว์/ซ่อน Frame
logo.MouseButton1Click:Connect(function()
    functionFrame.Visible = not functionFrame.Visible
end)

-- GUI ขึ้นหลังข้อความหาย
delay(3, function()
    textLabel:Destroy()
    functionFrame.Visible = true
    logo.Visible = true
end)

-- FOV Circle GUI
local fovCircle = Instance.new("Frame")
fovCircle.Parent = gui
fovCircle.Size = UDim2.new(0,100,0,100)
fovCircle.Position = UDim2.new(0.5,-50,0.5,-50)
fovCircle.BackgroundColor3 = Color3.fromHSV(0,1,1)
fovCircle.BorderSizePixel = 2
fovCircle.Visible = false

-- Aimbot
local aimbotEnabled = false
local button = Instance.new("TextButton")
button.Parent = functionFrame
button.Size = UDim2.new(0,160,0,35)
button.Position = UDim2.new(0,10,0,10)
button.Text = "Aimbot: ปิด"
button.BackgroundColor3 = Color3.fromRGB(50,50,50)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Font = Enum.Font.GothamBold
button.TextSize = 18

button.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    button.Text = aimbotEnabled and "Aimbot: เปิด" or "Aimbot: ปิด"
    button.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(60,150,60) or Color3.fromRGB(50,50,50)
    fovCircle.Visible = aimbotEnabled
end)

local RaycastParams = RaycastParams.new()
RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
RaycastParams.IgnoreWater = true

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = 50
    for i,v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("HumanoidRootPart") then
            local headPos = v.Character.Head.Position
            RaycastParams.FilterDescendantsInstances = {player.Character}
            local direction = headPos - Camera.CFrame.Position
            local rayResult = Workspace:Raycast(Camera.CFrame.Position, direction, RaycastParams)
            if rayResult and rayResult.Instance:IsDescendantOf(v.Character) then
                local dist3D = (player.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if dist3D <= 60 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(headPos)
                    if onScreen then
                        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist2D <= shortestDistance then
                            shortestDistance = dist2D
                            closestPlayer = v
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- จมดิน 40 studs + หมุน
local originalPosition = rootPart.Position
local isSinking = false
local sinkDepth = 40
local rotationSpeed = math.rad(300)
local angle = 0

RunService.RenderStepped:Connect(function(delta)
    if aimbotEnabled then
        local target = getClosestPlayer()
        if target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end

    if humanoid.Health <= 30 then
        if not isSinking then
            isSinking = true
            angle = 0
        end
        angle = angle + rotationSpeed*delta
        rootPart.CFrame = CFrame.new(originalPosition - Vector3.new(0,sinkDepth,0)) * CFrame.Angles(0,angle,0)
    elseif isSinking and humanoid.Health >= 31 then
        isSinking = false
        rootPart.CFrame = CFrame.new(originalPosition)
    end
end)