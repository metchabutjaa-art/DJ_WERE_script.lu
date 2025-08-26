local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
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

-- ไล่สีรุ้ง
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

-- Frame ฟังก์ชัน
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

-- ฟังก์ชันลากด้วย Touch
local function makeDraggableTouch(frame)
    local dragging = false
    local dragInput, startPos, startInputPos

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
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - startInputPos
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

-- Aimbot ปุ่มกด
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
end)

-- หาเป้าหมายใกล้ที่สุด
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist
rayParams.IgnoreWater = true

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = 50 -- FOV
    for _,v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("HumanoidRootPart") then
            local headPos = v.Character.Head.Position
            local rootPos = v.Character.HumanoidRootPart.Position
            -- ตรวจสอบการมองเห็น
            rayParams.FilterDescendantsInstances = {player.Character}
            local direction = headPos - Camera.CFrame.Position
            local rayResult = Workspace:Raycast(Camera.CFrame.Position, direction, rayParams)
            if rayResult and rayResult.Instance:IsDescendantOf(v.Character) then
                local dist3D = (player.Character.HumanoidRootPart.Position - rootPos).Magnitude
                if dist3D <= 60 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(headPos)
                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist2D < shortestDistance then
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

-- ระบบเล็ง
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)
