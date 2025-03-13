repeat task.wait() until game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name)

local Whitelist = getgenv().Config["Shrine"]["Accept"]
local Blacklist = getgenv().Config["Shrine"]["Deny"]
local priority = getgenv().Config["Shop"]["Buy Priority"]
local ignored = getgenv().Config["Shop"]["Ignored Buy"]

local player = game.Players.LocalPlayer
local targetPath = player.PlayerGui.DungeonUI.Main.Main.Outer.MainHolder.Outer.LevelSelection.Inset.MainRow
local StartHolder = player.PlayerGui.DungeonUI.Main.Main.Outer.MainHolder.Outer.StartHolder
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Event = game:GetService("ReplicatedStorage").endpoints["client_to_server"]
local IsLobby = workspace:FindFirstChild('_MAP_CONFIG') if IsLobby and IsLobby:FindFirstChild('IsLobby') then IsLobby = IsLobby.IsLobby.Value end
local IsGame = workspace:FindFirstChild('_waves_started')
local _DATA = workspace:FindFirstChild('_DATA')
local GameFinished
if _DATA then GameFinished = _DATA:FindFirstChild('GameFinished') end
local ResultUI = player.PlayerGui['ResultsUI']

local function getLevelData() 
    return game.Workspace._MAP_CONFIG:WaitForChild("GetLevelData"):InvokeServer() 
end

local function TPLobby ()
	game:GetService('TeleportService'):Teleport(8304191830, player)
end

local function showNotification(title, message)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = message,
        Duration = 3  -- ระยะเวลาในการแสดงข้อความ
    })
end

local function getChestCount(chestFrame)
    local amountLabel = chestFrame:FindFirstChild("Main")
        and chestFrame.Main:FindFirstChild("ItemHolder")
        and chestFrame.Main.ItemHolder:FindFirstChild("Amount")
    
    if amountLabel and amountLabel:IsA("TextLabel") then
        local amountText = amountLabel.Text:match("%d+")
        return tonumber(amountText) or 0
    end
    return 0
end

local function openChests(chestName, chestCount, isRare)
    for i = 1, chestCount do
        if isRare then
            local args = {[1] = true}
            game:GetService("ReplicatedStorage").endpoints.client_to_server.dungeon_open_chest:InvokeServer(unpack(args))
        else
            game:GetService("ReplicatedStorage").endpoints.client_to_server.dungeon_open_chest:InvokeServer()
        end
        task.wait(0.1)
    end
end

local function AutoOpenChest()
    local data = getLevelData()
    
    if type(data) == "table" and data._dungeon and data._dungeon.depth then
        local currentDepth = data._dungeon.depth
		local frames1 = StartHolder:GetChildren()

        if currentDepth >= 20 then
            showNotification("Test","Reached the required depth")
            
            local player = game.Players.LocalPlayer
            local scroll = player:WaitForChild("PlayerGui"):WaitForChild("DungeonUI")
                             :WaitForChild("Main"):WaitForChild("Main")
                             :WaitForChild("Outer"):WaitForChild("MainHolder")
                             :WaitForChild("Outer"):WaitForChild("OpenTreasure")
                             :WaitForChild("Inset"):WaitForChild("ItemsRows")
                             :WaitForChild("Scroll")
            
            local normalChest = scroll:FindFirstChild("ChestFrameNormal")
            local rareChest = scroll:FindFirstChild("ChestFrameRare")
            
            local normalCount = normalChest and getChestCount(normalChest) or 0
            local rareCount = rareChest and getChestCount(rareChest) or 0
            if normalCount > 0 then
                openChests("ChestFrameNormal", normalCount, false)
            end
            if rareCount > 0 then
                openChests("ChestFrameRare", rareCount, true)
            end
            game:GetService("ReplicatedStorage").endpoints.client_to_server.dungeon_continue_shop:InvokeServer()
            task.wait(1)
			TPLobby()
			
		else
            showNotification("Test","Not enough. Currently: " .. currentDepth .. " / 20")
            game:GetService("ReplicatedStorage").endpoints.client_to_server.dungeon_continue_shop:InvokeServer()
        end
    else
        showNotification("Test","Unable to get data or data is not in correct format.")
    end
end
local function clickButton(buttonPath)
    local button
    repeat
        button = buttonPath
        wait(0.1)
    until button and (button:IsA("ImageButton") or button:IsA("TextButton"))
    
    GuiService.SelectedObject = button
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
end

local function clickAnywhere(x, y)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local function ClickEndGame()
    clickButton(game.Players.LocalPlayer.PlayerGui.ResultsUI.Holder.Buttons.Next)
    task.wait(1)
    local screenWidth = workspace.CurrentCamera.ViewportSize.X
    local screenHeight = workspace.CurrentCamera.ViewportSize.Y
    for i = 1, 6 do
        local randomX = math.random(0, screenWidth)
        local randomY = math.random(0, screenHeight)
        
        clickAnywhere(0, 0)
        task.wait(1)
    end
    clickButton(game.Players.LocalPlayer.PlayerGui.ResultsUI.Finished.NextRetry)
end

local priorityList = getgenv().Config["Priority Item Join Dungeon"]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local shopPath = player:WaitForChild("PlayerGui"):WaitForChild("DungeonUI"):WaitForChild("Main"):WaitForChild("Main")
    :WaitForChild("Outer"):WaitForChild("MainHolder"):WaitForChild("Outer"):WaitForChild("ShopSelection")
local dungeonItemsPath = ReplicatedStorage:WaitForChild("packages"):WaitForChild("assets")
    :WaitForChild("gui"):WaitForChild("DungeonItems")
local moneyLabel = player:WaitForChild("PlayerGui"):WaitForChild("DungeonUI"):WaitForChild("Main"):WaitForChild("Main")
    :WaitForChild("Outer"):WaitForChild("MainHolder"):WaitForChild("Money"):WaitForChild("TitleMoney")


local imageLabels = {}
for _, imageLabel in pairs(dungeonItemsPath:GetDescendants()) do
    if imageLabel:IsA("ImageLabel") then
        table.insert(imageLabels, {Name = imageLabel.Name, Image = imageLabel.Image})
    end
end

local function checkShop()
    if shopPath.Visible == false then
        showNotification("Test","There is no shop.")
        return
    end

    showNotification("Test","Shop đang bán:")
    local scroll = shopPath:WaitForChild("Inset"):WaitForChild("ItemsRows"):WaitForChild("Scroll")
    local itemIndex = 1
    local itemsToBuy = {}
    for _, sellFrame in pairs(scroll:GetChildren()) do
        if sellFrame:IsA("Frame") and sellFrame.Name == "SellFrame" then
            if sellFrame:FindFirstChild("Configuration") then
                continue
            end

            local itemImage = sellFrame:WaitForChild("Main"):WaitForChild("ItemImage")
            local itemInfo = sellFrame:WaitForChild("Main"):WaitForChild("ItemInformation")
            local itemNameLabel = itemInfo:WaitForChild("ItemName")
            local itemInfoBuy = sellFrame:WaitForChild("Main"):WaitForChild("Buy")
            local itemPriceLabel = itemInfoBuy:WaitForChild("Main"):WaitForChild("Money"):WaitForChild("Title")

            local itemName = itemNameLabel.Text
            local itemPrice = tonumber(itemPriceLabel.Text)
            local itemImageId = itemImage.Image

            for _, data in pairs(imageLabels) do
                if data.Image == itemImageId then
                    print(string.format("[%d] %s | %s | %s | %d", itemIndex, data.Name, itemImageId, itemName, itemPrice))
                    if table.find(ignored, data.Name) then
                        print(string.format("Bỏ qua: %s", data.Name))
                    else
                        table.insert(itemsToBuy, {Index = itemIndex, Name = data.Name, Price = itemPrice})
                    end
                    itemIndex = itemIndex + 1
                end
            end
        end
    end
	
    if #itemsToBuy == 0 then
        showNotification("Test","No valid items to purchase, continue dungeon...")
         Event['dungeon_continue_shop']:InvokeServer()
        return
    end
	
    local playerMoney = tonumber(moneyLabel.Text)
    if not playerMoney then
        showNotification("Test","Error while taking player's money.")
        return
    end

    local buyQueue = {}
    for _, priorityName in ipairs(priority) do
        for _, item in ipairs(itemsToBuy) do
            if item.Name == priorityName then
                table.insert(buyQueue, item)
            end
        end
    end
    for _, item in ipairs(itemsToBuy) do
        if not table.find(priority, item.Name) then
            table.insert(buyQueue, item)
        end
    end
	
    for _, item in ipairs(buyQueue) do
        if playerMoney >= item.Price then
            print(string.format("Purchase successful: %s price %d", item.Name, item.Price))
            
            local args = {[1] = item.Index}
			Event['dungeon_buy_shop']:InvokeServer(unpack(args))	
			
            playerMoney = playerMoney - item.Price
        else
			showNotification("Test", string.format("Not enough money to buy: %s (%d need %d)", item.Name, playerMoney, item.Price))
        end
    end

    showNotification("Test","All valid items purchased. Continue dungeon...")
    --Event['dungeon_continue_shop']:InvokeServer()
	
end

local function calculatePartScore(part)
    local score = 0
    local itemsFound = {}
    if part then
        for _, imageLabel in ipairs(part:GetChildren()) do
            if imageLabel:IsA("ImageLabel") and imageLabel.Visible == true then
                local name = imageLabel.Name
                local priority = table.find(priorityList, name)
                
                if priority then
                    local points = #priorityList - priority + 1
                    score = score + points
                    table.insert(itemsFound, name)
                end
            end
        end
    end

    return score, itemsFound
end
local function calculateFrameScore(frame)
    local totalScore = 0
    local totalItemsFound = {}

    
    pcall(function()
        local frameTop = frame:FindFirstChild("FrameTop")
        if frameTop then
            local frameTopMain = frameTop:FindFirstChild("Frame")
            if frameTopMain then
                local levelAttributesTop = frameTopMain:FindFirstChild("Main")
                if levelAttributesTop then
                    local score, itemsFound = calculatePartScore(levelAttributesTop:FindFirstChild("LevelAttributes"))
                    totalScore = totalScore + (score or 0)
                    for _, item in ipairs(itemsFound or {}) do
                        table.insert(totalItemsFound, item)
                    end
                end
            end
        end
    end)

    pcall(function()
        local main = frame:FindFirstChild("Main")
        if main then
            local levelAttributes = main:FindFirstChild("LevelAttributes")
            if levelAttributes then
                local score, itemsFound = calculatePartScore(levelAttributes)
                totalScore = totalScore + (score or 0)
                for _, item in ipairs(itemsFound or {}) do
                    table.insert(totalItemsFound, item)
                end
            end
        end
    end)

    return totalScore, totalItemsFound
end

function AutoJoinDungeon()
    local frameData = {}
    local frames = targetPath:GetChildren()
    local frameIndex = 1
    local bestFrame = nil
	local frames1 = StartHolder:GetChildren()
	
	for _, frame in ipairs(frames1) do
		if frame:IsA("Frame") and frame.Name == "StartHolder" then
			if frame.Visible == true then
				game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("dungeon_start"):InvokeServer()
			end
		end
	end
	
    for _, frame in ipairs(frames) do
        if frame:IsA("Frame") and frame.Name == "Frame" then
            local score, itemsFound = calculateFrameScore(frame)
            local frameInfo = {
                Index = frameIndex,
                Score = score,
                Items = itemsFound
            }
            table.insert(frameData, frameInfo)

            if not bestFrame or score > bestFrame.Score then
                bestFrame = frameInfo
            end
            
            frameIndex = frameIndex + 1
        end
    end

    if not bestFrame then
        showNotification("Test","No suitable room found.")
        bestFrame = {
            Index = 1,
            Score = 0,
            Items = {}
        }
    end

    for _, data in ipairs(frameData) do
        print("Room " .. data.Index .. ": Total score = " .. data.Score .. ", Item = [" .. table.concat(data.Items, ", ") .. "]")
    end

    if bestFrame then
        print("Join the best room : Room " .. bestFrame.Index .. " Total score = " .. bestFrame.Score)
        local args = { tostring(bestFrame.Index) }
        Event['dungeon_enter_room']:InvokeServer(unpack(args))
	end
end

local function IsWhitelisted(name)
    for _, item in ipairs(Whitelist) do
        if name:sub(1, #item) == item then return true end
    end
    return false
end

local function IsBlacklisted(name)
    for _, item in ipairs(Blacklist) do
        if name:sub(1, #item) == item then return true end
    end
    return false
end

local function CheckShirine()
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local shrineRoom = playerGui:FindFirstChild("DungeonUI", true)
    if not shrineRoom then return end

    shrineRoom = shrineRoom:FindFirstChild("ShrineRoom", true)
    if not (shrineRoom and shrineRoom:IsA("Frame") and shrineRoom.Visible) then return end

    local itemsRows = shrineRoom:FindFirstChild("Inset", true)
    itemsRows = itemsRows and itemsRows:FindFirstChild("ItemsRows"):FindFirstChild("Scroll")
    if not itemsRows then return end

    local offeredItems = {}
    for _, itemFrame in ipairs(itemsRows:GetChildren()) do
        if itemFrame:IsA("Frame") and itemFrame.Name ~= "Configuration" then
            local itemImage = itemFrame:FindFirstChild("Main"):FindFirstChild("ItemHolder"):FindFirstChild("ItemImage")
            if itemImage and itemImage:IsA("ImageLabel") and itemImage.Image ~= "" then
                table.insert(offeredItems, itemImage.Image)
            end
        end
    end

    local dungeonItems = game:GetService("ReplicatedStorage"):FindFirstChild("packages")
    dungeonItems = dungeonItems and dungeonItems:FindFirstChild("assets")
    dungeonItems = dungeonItems and dungeonItems:FindFirstChild("gui")
    dungeonItems = dungeonItems and dungeonItems:FindFirstChild("DungeonItems")
    if not dungeonItems then return end

    local curseImages = {}
    for _, obj in ipairs(dungeonItems:GetDescendants()) do
        if obj:IsA("ImageLabel") and obj.Name:sub(1, 6) == "_curse" then
            if IsWhitelisted(obj.Name) and not IsBlacklisted(obj.Name) then
                if obj.Image and obj.Image ~= "" then
                    curseImages[obj.Image] = obj.Name
                end
            end
        end
    end

    local matchFound = false
    for _, offeredImageId in ipairs(offeredItems) do
        if curseImages[offeredImageId] then
            print("✅ Match found: " .. curseImages[offeredImageId] .. " | " .. offeredImageId)
            matchFound = true
        end
    end

    if matchFound then
        Event['dungeon_shrine_accept']:InvokeServer()
    else
        Event['dungeon_continue_shop']:InvokeServer()
		
    end
end

function CheckDie()
    local player = game.Players.LocalPlayer
    local youDiedFrame = player:FindFirstChild("PlayerGui"):FindFirstChild("DungeonUI")
                          :FindFirstChild("Main"):FindFirstChild("Main")
                          :FindFirstChild("Outer"):FindFirstChild("MainHolder")
                          :FindFirstChild("Outer"):FindFirstChild("YouDied")
    
    if youDiedFrame and youDiedFrame:IsA("Frame") then
        if youDiedFrame.Visible == true then
            Event['dungeon_continue_death']:InvokeServer()
        end
    end
end

-- เริ่มต้นโปรแกรม
local function endGameFunc ()
	local targetPlaceId = 8304191830
	task.spawn(function()
		while true do
			if game.PlaceId == targetPlaceId then
				while true do
					 CheckDie()
					 checkShop()
					 CheckShirine()
					 task.wait(3)
					 AutoJoinDungeon()
				end
			else
				while not GameFinished.Value do
					task.wait(1)
				end
				-- หลังจากเกมจบแล้ว
				showNotification("Test","Game Finished")
				while true do
					ClickEndGame()
					AutoOpenChest()
					CheckDie()
					checkShop()
					CheckShirine()
					task.wait(3)
					AutoJoinDungeon()
				end
			end
		end
	end)
end

if GameFinished and not IsLobby then
	repeat task.wait() until GameFinished.Value and ResultUI.Enabled

	endGameFunc()
else
	endGameFunc()
end
