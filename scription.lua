-- Gui to Lua (Fixed)
-- Version: 3.2

-- Instances:
local MainGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local ButtonRemoter = Instance.new("TextButton")
local RemoteSelected = Instance.new("TextLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local Fires = Instance.new("TextButton")
local Box = Instance.new("TextBox")
local TextLabel = Instance.new("TextLabel")
local LocalScript = Instance.new("LocalScript")

--Properties:
MainGui.Name = "MainGui"
MainGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.ResetOnSpawn = false

Main.Name = "Main"
Main.Parent = MainGui
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.35, 0, 0.27, 0)
Main.Size = UDim2.new(0.3, 0, 0.45, 0)

RemoteSelected.Name = "RemoteSelected"
RemoteSelected.Parent = Main
RemoteSelected.BackgroundColor3 = Color3.fromRGB(92, 101, 124)
RemoteSelected.BorderSizePixel = 0
RemoteSelected.Position = UDim2.new(0.62, 0, 0.03, 0)
RemoteSelected.Size = UDim2.new(0.36, 0, 0.08, 0)
RemoteSelected.Font = Enum.Font.SourceSansBold
RemoteSelected.Text = "[NONE]"
RemoteSelected.TextColor3 = Color3.fromRGB(255, 255, 255)
RemoteSelected.TextScaled = true
RemoteSelected.TextWrapped = true

ScrollingFrame.Parent = Main
ScrollingFrame.Active = true
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(92, 101, 124)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Position = UDim2.new(0.04, 0, 0.03, 0)
ScrollingFrame.Size = UDim2.new(0.54, 0, 0.83, 0)
UIListLayout.Parent = ScrollingFrame

Fires.Name = "Fires"
Fires.Parent = Main
Fires.BackgroundColor3 = Color3.fromRGB(81, 89, 109)
Fires.BorderSizePixel = 0
Fires.Position = UDim2.new(0.62, 0, 0.88, 0)
Fires.Size = UDim2.new(0.36, 0, 0.08, 0)
Fires.Font = Enum.Font.SourceSansBold
Fires.Text = "Fires All"
Fires.TextColor3 = Color3.fromRGB(255, 255, 255)
Fires.TextScaled = true
Fires.TextWrapped = true

Box.Name = "Box"
Box.Parent = Main
Box.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
Box.BorderSizePixel = 0
Box.Position = UDim2.new(0.09, 0, 0.89, 0)
Box.Size = UDim2.new(0.49, 0, 0.08, 0)
Box.ClearTextOnFocus = false
Box.Font = Enum.Font.SourceSansBold
Box.PlaceholderText = "require().blah(urname) or code"
Box.Text = ""
Box.TextColor3 = Color3.fromRGB(255, 255, 255)
Box.TextScaled = true
Box.TextWrapped = true
Box.TextXAlignment = Enum.TextXAlignment.Left

TextLabel.Parent = Main
TextLabel.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0.05, 0, 0.89, 0)
TextLabel.Size = UDim2.new(0.04, 0, 0.08, 0)
TextLabel.Font = Enum.Font.SourceSansBold
TextLabel.Text = ">"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.TextWrapped = true

ButtonRemoter.Name = "ButtonRemoter"
ButtonRemoter.Parent = Main
ButtonRemoter.BackgroundColor3 = Color3.fromRGB(70, 77, 94)
ButtonRemoter.BorderSizePixel = 0
ButtonRemoter.Size = UDim2.new(0.94, 0, 0.05, 0)
ButtonRemoter.Font = Enum.Font.SourceSansBold
ButtonRemoter.Text = "Oldest"
ButtonRemoter.TextColor3 = Color3.fromRGB(255, 255, 255)
ButtonRemoter.TextScaled = true
ButtonRemoter.TextWrapped = true
ButtonRemoter.Visible = false -- Hidden template

-- LocalScript (Fixed)
LocalScript.Parent = Main

LocalScript.Source = [[
	local rep = game:GetService("ReplicatedStorage")

	local parentUI = script.Parent
	local Scrolling = parentUI:WaitForChild("ScrollingFrame")
	local RemoteCountLabel = parentUI:WaitForChild("RemoteSelected")
	local FireAllButton = parentUI:WaitForChild("Fires")
	local BTN = parentUI:WaitForChild("ButtonRemoter")
	local Box = parentUI:WaitForChild("Box")

	local remotes = {}
	local db = false
	local scripts = ""

	local function safeFire(remote)
		local ok = pcall(function()
			if remote:IsA("RemoteEvent") then
				remote:FireServer(scripts)
			elseif remote:IsA("RemoteFunction") then
				remote:InvokeServer(scripts)
			end
		end)
		return ok
	end

	-- Build buttons
	for i, v in pairs(rep:GetDescendants()) do
		if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
			table.insert(remotes, v)
			local clone = BTN:Clone()
			clone.Parent = Scrolling
			clone.Visible = true
			clone.Text = i .. ". " .. v.Name

			clone.MouseEnter:Connect(function()
				clone.Text = v:GetFullName()
			end)

			clone.MouseLeave:Connect(function()
				clone.Text = i .. ". " .. v.Name
			end)

			clone.MouseButton1Click:Connect(function()
				safeFire(v)
				clone.Text = "[FIRED] " .. v.Name
				task.wait(0.4)
				clone.Text = i .. ". " .. v.Name
			end)
		end
	end

	RemoteCountLabel.Text = ("Remotes: %d"):format(#remotes)

	FireAllButton.MouseButton1Click:Connect(function()
		if db then return end
		db = true

		local fires, success, fail = 0, 0, 0
		local alreadyfires = {}

		for i, remote in ipairs(remotes) do
			if table.find(alreadyfires, remote.Name) then continue end
			table.insert(alreadyfires, remote.Name)
			fires += 1
			FireAllButton.Text = ("Firing [%d/%d]"):format(fires, #remotes)

			if safeFire(remote) then
				success += 1
			else
				fail += 1
			end

			task.wait(i / 5)
		end

		table.clear(alreadyfires)
		FireAllButton.Text = ("Done ✅ [%d success / %d fail]"):format(success, fail)
		task.wait(1.5)
		FireAllButton.Text = "Fires All"

		db = false
	end)

	Box.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			scripts = Box.Text
		end
	end)
]]
