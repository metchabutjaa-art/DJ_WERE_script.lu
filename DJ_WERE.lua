-- DJ_WERE รวม Aimbot FOV + จมดิน/รีตัว + GUI ลากได้
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

-- โลโก้นินจา ขอบบนซ้าย ลากได้
local logo = Instance.new("TextButton")
logo.Parent = gui
logo.Size = UDim2.new(0,60,0,60)
logo.Position = UDim2.new(0,10,0,10)
logo.Text = "忍"
logo.Font = Enum.Font.GothamBold
logo.TextSize = 40
logo.BackgroundColor3 = Color3.fromRGB(50,50,50)
logo.TextColor3 = Color3.fromRGB(255,255,255)
logo.AutoButtonColor = true

-- ฟังก์ชันลาก GUI
local function makeDraggable(frame)
    local dragging, dragInput, startPos, startInput
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = frame.Position
            startInput = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - startInput
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(logo)

-- Frame ฟังก์ชัน
local functionFrame = Instance.new("Frame")
functionFrame.Parent = gui
functionFrame.Size = UDim2.new(0,200,0,80)
functionFrame.Position = UDim2.new(0,80,0,10)
functionFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
functionFrame.Visible = true

-- ปุ่ม Aimbot
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

-- Raycast params สำหรับตรวจเป้าหมาย
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist
rayParams.IgnoreWater = true

-- ฟังก์ชันหาเป้าหมายใกล้ที่สุดใน FOV
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = 50 -- FOV
    for _,v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("HumanoidRootPart") then
            local headPos = v.Character.Head.Position
            local rootPos = v.Character.HumanoidRootPart.Position
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

-- ระบบเล็ง + จมดิน
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local originalPosition = rootPart.Position
local isSinking = false
local sinkDepth = 40
local rotationSpeed = math.rad(300)
local angle = 0

RunService.RenderStepped:Connect(function(delta)
    -- Aimbot
    if aimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end

    -- จมดินเมื่อเลือดน้อยกว่า30
    if humanoid.Health < 30 then
        if not isSinking then
            isSinking = true
            angle = 0
            originalPosition = rootPart.Position
        end
        angle = angle + rotationSpeed * delta
        rootPart.CFrame = CFrame.new(originalPosition - Vector3.new(0, sinkDepth, 0)) * CFrame.Angles(0, angle, 0)
    elseif isSinking and humanoid.Health >= 31 then
        isSinking = false
        rootPart.CFrame = CFrame.new(originalPosition)
    end
end)
