local HttpService = game:GetService('HttpService')
local UIS = game:GetService('UserInputService')
local RunS = game:GetService('RunService')
local RS = game:GetService('ReplicatedStorage')
local TS = game:GetService('TweenService')
local PS = game:GetService('PhysicsService')

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local Remotes = RS:WaitForChild('endpoints')
local Event = game:GetService("ReplicatedStorage").endpoints["client_to_server"]

local DifferentColorsPoints = {Color3.fromRGB(1, 81, 255), Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(255,255,0), Color3.fromRGB(255,0,255), Color3.fromRGB(0,255,255)}
MacroUnitsTextBlocks = {}
local RecordingMacro = false
local FPS = 0
local StartTime = os.time()
local IsLobby = workspace:FindFirstChild('_MAP_CONFIG') if IsLobby and IsLobby:FindFirstChild('IsLobby') then IsLobby = IsLobby.IsLobby.Value end
local IsGame = workspace:FindFirstChild('_waves_started')
local _DATA = workspace:FindFirstChild('_DATA')
local GameFinished
if _DATA then GameFinished = _DATA:FindFirstChild('GameFinished') end
local ResultUI = player.PlayerGui['ResultsUI']

	local RunService = game:GetService("RunService")	
	game:GetService("CoreGui").TopBarApp.Enabled = false
	game:GetService("Players").localPlayer.PlayerGui.Chat.Enabled = false
	game:GetService("CoreGui").PlayerList.Enabled = false	
	game:GetService("CoreGui").PlayerList.PlayerListMaster.Visible = false
	RunService:Set3dRenderingEnabled(false)
	setfpscap(10)
		
		if IsLobby then 	
			local ReduceCpuR = Instance.new("Frame")
			local Wave = Instance.new("TextLabel")
			local Time = Instance.new("TextLabel")
			
			ReduceCpuR.Name = "ReduceCpuR"
			ReduceCpuR.Parent = game:GetService("CoreGui")["KaChi Hub"]
			ReduceCpuR.AnchorPoint = Vector2.new(0.5, 0.5)
			ReduceCpuR.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			ReduceCpuR.BorderColor3 = Color3.fromRGB(27, 42, 53)
			ReduceCpuR.ZIndex = -1
			ReduceCpuR.BorderSizePixel = 0
			ReduceCpuR.Position = UDim2.new(0.5, 0, 0.5, 0)
			ReduceCpuR.Size = UDim2.new(1, 0, 2, 0)
		
			Wave.Name = "Wave"
			Wave.Parent = ReduceCpuR
			Wave.AnchorPoint = Vector2.new(0.5, 0.5)
			Wave.BackgroundTransparency = 1.000
			Wave.BorderColor3 = Color3.fromRGB(27, 42, 53)
			Wave.Position = UDim2.new(0.5, 0, 0.5, 0)
			Wave.Size = UDim2.new(0, 300, 0, 100)
			Wave.Font = Enum.Font.FredokaOne
			Wave.ZIndex = -1
			Wave.Text = "Waiting to join the game"
			Wave.TextColor3 = Color3.fromRGB(94, 94, 94)
			Wave.TextSize = 50.000
			Wave.TextStrokeTransparency = 0.500

			Time.Name = "Time"
			Time.Parent = ReduceCpuR
			Time.AnchorPoint = Vector2.new(0.5, 0.5)
			Time.BackgroundTransparency = 1.000
			Time.BorderColor3 = Color3.fromRGB(27, 42, 53)
			Time.BorderSizePixel = 0
			Time.ZIndex = -1
			Time.Position = UDim2.new(0.5, 0, 0.5, 40)
			Time.Size = UDim2.new(0, 300, 0, 100)
			Time.Font = Enum.Font.FredokaOne
			Time.Text = ""
			Time.TextColor3 = Color3.fromRGB(94, 94, 94)
			Time.TextSize = 30.000
			Time.TextStrokeTransparency = 0.500

			spawn(function()
				while wait() do
					pcall(function()
						for _, StoryRoom in ipairs(workspace._LOBBIES.Story:GetChildren()) do
							if StoryRoom.Owner.Value == game.Players.LocalPlayer then
								Time.Text = "World : "..StoryRoom.World.Value..' | '..StoryRoom.Level.Value              
							end    
						end
						for _, RaidRoom in ipairs(game:GetService("Workspace")["_RAID"].Raid:GetChildren()) do
							if RaidRoom.Owner.Value == game.Players.LocalPlayer then
								Time.Text = "World : "..RaidRoom.World.Value..' | '..RaidRoom.Level.Value                
							end    
						end
						for _, PortalRoom in ipairs(workspace._PORTALS.Lobbies:GetChildren()) do
							if PortalRoom.Owner.Value == game.Players.LocalPlayer then
								Time.Text = "World : "..PortalRoom.World.Value..' | '..PortalRoom.Level.Value                
							end    
						end
					end)
				end
			end)
			
		else	
			local ReduceCpuR = Instance.new("Frame")
			local Wave = Instance.new("TextLabel")
			local Time = Instance.new("TextLabel")

			ReduceCpuR.Name = "ReduceCpuR"
			ReduceCpuR.Parent = game:GetService("CoreGui")["KaChi Hub"]
			ReduceCpuR.AnchorPoint = Vector2.new(0.5, 0.5)
			ReduceCpuR.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			ReduceCpuR.BorderColor3 = Color3.fromRGB(27, 42, 53)
			ReduceCpuR.ZIndex = -1
			ReduceCpuR.BorderSizePixel = 0
			ReduceCpuR.Position = UDim2.new(0.5, 0, 0.5, 0)
			ReduceCpuR.Size = UDim2.new(1, 0, 2, 0)
		
			Wave.Name = "Wave"
			Wave.Parent = ReduceCpuR
			Wave.AnchorPoint = Vector2.new(0.5, 0.5)
			Wave.BackgroundTransparency = 1.000
			Wave.BorderColor3 = Color3.fromRGB(27, 42, 53)
			Wave.Position = UDim2.new(0.5, 0, 0.5, 0)
			Wave.Size = UDim2.new(0, 300, 0, 100)
			Wave.Font = Enum.Font.FredokaOne
			Wave.ZIndex = -1
			Wave.Text = "Wave : "..game.Players.LocalPlayer.PlayerGui.Waves.HealthBar.WaveNumber.Text
			Wave.TextColor3 = Color3.fromRGB(94, 94, 94)
			Wave.TextSize = 50.000
			Wave.TextStrokeTransparency = 0.500
		
			Time.Name = "Time"
			Time.Parent = ReduceCpuR
			Time.AnchorPoint = Vector2.new(0.5, 0.5)
			Time.BackgroundTransparency = 1.000
			Time.BorderColor3 = Color3.fromRGB(27, 42, 53)
			Time.BorderSizePixel = 0
			Time.ZIndex = -1
			Time.Position = UDim2.new(0.5, 0, 0.5, 40)
			Time.Size = UDim2.new(0, 300, 0, 100)
			Time.Font = Enum.Font.FredokaOne
			Time.Text = ""
			Time.TextColor3 = Color3.fromRGB(94, 94, 94)
			Time.TextSize = 30.000
			Time.TextStrokeTransparency = 0.500
			
			spawn(function()
				while wait() do
					pcall(function()
						Wave.Text = "Wave : "..game.Players.LocalPlayer.PlayerGui.Waves.HealthBar.WaveNumber.Text
							if game.Players.LocalPlayer.PlayerGui.Waves.HealthBar.Timer.Text > "0" then
								Time.Text = "Time : "..game.Players.LocalPlayer.PlayerGui.Waves.HealthBar.Timer.Text.." | ".."Tower : "..game.Players.LocalPlayer.PlayerGui.Waves.HealthBar.HPDisplay.Text
							else
								Time.Text = "Time : 0".." | ".."Tower : "..game.Players.LocalPlayer.PlayerGui.Waves.HealthBar.HPDisplay.Text
							end
						if GameFinished.Value == true then
							Time.Text = "Game Finished"
						end		
					end)
				end
			end)

		end
	else
		RunService:Set3dRenderingEnabled(true)	
		setfpscap(30)
		game:GetService("CoreGui").TopBarApp.Enabled = true
		game:GetService("Players").localPlayer.PlayerGui.Chat.Enabled = true
		game:GetService("CoreGui").PlayerList.Enabled = true
		game:GetService("CoreGui").PlayerList.PlayerListMaster.Visible = false
				
		if game:GetService("CoreGui")["KaChi Hub"]:FindFirstChild("ReduceCpuR") then	
			game:GetService("CoreGui")["KaChi Hub"]:FindFirstChild("ReduceCpuR"):Destroy()	
      game:GetService("CoreGui")["KaChi Hub"]:FindFirstChild("ReduceCpuR"):Destroy()
      game:GetService("CoreGui")["KaChi Hub"]:FindFirstChild("ReduceCpuR"):Destroy()
      game:GetService("CoreGui")["KaChi Hub"]:FindFirstChild("ReduceCpuR"):Destroy()
		end			
	end
