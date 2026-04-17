-- =============================================
-- Kanka Auto Potion Crafter v2 - Recipe Saver
-- (by KankaScripter)
-- Kullanıcı marketi kendisi açar → miktarları girer → script kaydeder → oto crate
-- Tam istediğin sistem: birden fazla potion recipe destekler
-- =============================================

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==================== UI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KankaAutoPotionV2"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 520)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundTransparency = 1
title.Text = "🧪 KANKA AUTO POTION v2"
title.TextColor3 = Color3.fromRGB(0, 255, 120)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, 0, 0, 25)
subtitle.Position = UDim2.new(0, 0, 0, 55)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Recipe Saver • Marketi sen aç, ben oto yapayım kanka"
subtitle.TextColor3 = Color3.fromRGB(140, 140, 140)
subtitle.TextScaled = true
subtitle.Font = Enum.Font.Gotham
subtitle.Parent = mainFrame

-- Recipe name input + Save
local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(0.65, 0, 0, 40)
nameBox.Position = UDim2.new(0.05, 0, 0, 95)
nameBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
nameBox.PlaceholderText = "Recipe ismi (ör: SuperPotion)"
nameBox.Text = ""
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.TextScaled = true
nameBox.Font = Enum.Font.Gotham
nameBox.Parent = mainFrame
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 10)

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0.25, 0, 0, 40)
saveBtn.Position = UDim2.new(0.72, 0, 0, 95)
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
saveBtn.Text = "📋 KAYDET"
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.TextScaled = true
saveBtn.Font = Enum.Font.GothamBold
saveBtn.Parent = mainFrame
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 10)

-- Aktif recipe gösterimi
local activeLabel = Instance.new("TextLabel")
activeLabel.Size = UDim2.new(0.9, 0, 0, 35)
activeLabel.Position = UDim2.new(0.05, 0, 0, 145)
activeLabel.BackgroundTransparency = 1
activeLabel.Text = "Aktif Recipe: Yok"
activeLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
activeLabel.TextScaled = true
activeLabel.Font = Enum.Font.GothamSemibold
activeLabel.TextXAlignment = Enum.TextXAlignment.Left
activeLabel.Parent = mainFrame

-- Saved recipes list (ScrollingFrame)
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(0.9, 0, 0, 160)
scroll.Position = UDim2.new(0.05, 0, 0, 190)
scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
scroll.ScrollBarThickness = 6
scroll.Parent = mainFrame
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 12)
local uiList = Instance.new("UIListLayout", scroll)
uiList.Padding = UDim.new(0, 6)
uiList.SortOrder = Enum.SortOrder.LayoutOrder

-- Oto Crate toggle
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0.9, 0, 0, 65)
autoBtn.Position = UDim2.new(0.05, 0, 0, 370)
autoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
autoBtn.Text = "🚀 OTO CRATE BAŞLAT"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextScaled = true
autoBtn.Font = Enum.Font.GothamBold
autoBtn.Parent = mainFrame
Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 16)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0, 40)
status.Position = UDim2.new(0.05, 0, 0, 445)
status.BackgroundTransparency = 1
status.Text = "Market aç, miktar gir, KAYDET'e bas kanka"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.TextScaled = true
status.Font = Enum.Font.Gotham
status.TextWrapped = true
status.Parent = mainFrame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 10)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame

-- ==================== DRAGGABLE ====================
local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)
mainFrame.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
mainFrame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- ==================== DATA ====================
local savedRecipes = {}      -- [recipeName] = {ingredients = {["Power"] = 1, ["Lucky"] = 15, ...}}
local currentRecipe = nil    -- aktif recipe ismi
local autoEnabled = false

-- Helper: TextBox'un yanındaki label'ı bul (çoğu oyunda çalışır)
local function getAssociatedLabel(box)
	local parent = box.Parent
	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA("TextLabel") and child.Text:len() > 2 and not tonumber(child.Text) then
			-- Temiz isim döndür (Power :  vs. sadece Power)
			return child.Text:gsub("[:%s%d]+$", ""):gsub("%s+", " "):match("^%s*(.-)%s*$")
		end
	end
	-- Fallback
	if box.PlaceholderText and box.PlaceholderText ~= "" then
		return box.PlaceholderText:gsub("[:%s%d]+$", ""):match("^%s*(.-)%s*$")
	end
	return box.Name
end

-- Mevcut marketten recipe capture et
local function captureRecipe()
	local rec = {}
	for _, obj in ipairs(playerGui:GetDescendants()) do
		if obj:IsA("TextBox") then
			local num = tonumber(obj.Text)
			if num and num > 0 then
				local label = getAssociatedLabel(obj)
				if label and label ~= "" then
					rec[label] = num
				end
			end
		end
	end
	return rec
end

-- Recipe özet stringi
local function getRecipeSummary(recipe)
	local parts = {}
	for item, qty in pairs(recipe) do
		table.insert(parts, item .. ":" .. qty)
	end
	table.sort(parts)
	return table.concat(parts, " • ")
end

-- UI listesini yenile
local function updateRecipeList()
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	
	for name, recipe in pairs(savedRecipes) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -10, 0, 45)
		btn.BackgroundColor3 = (name == currentRecipe) and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(40, 40, 40)
		btn.Text = "📌 " .. name .. "\n" .. getRecipeSummary(recipe)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextScaled = true
		btn.Font = Enum.Font.Gotham
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Parent = scroll
		
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
		
		btn.MouseButton1Click:Connect(function()
			currentRecipe = name
			activeLabel.Text = "Aktif Recipe: " .. name .. "\n" .. getRecipeSummary(savedRecipes[name])
			updateRecipeList()
			status.Text = name .. " aktif edildi kanka"
		end)
	end
	
	scroll.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 20)
end

-- TextBox'a miktar yaz
local function applyRecipe(recipe)
	if not recipe then return 0 end
	local applied = 0
	for _, obj in ipairs(playerGui:GetDescendants()) do
		if obj:IsA("TextBox") then
			local label = getAssociatedLabel(obj)
			if label and recipe[label] then
				obj.Text = tostring(recipe[label])
				applied = applied + 1
			end
		end
	end
	return applied
end

-- Buton bul ve tıkla (Add / Crate)
local function findAndClick(keywords)
	for _, obj in ipairs(playerGui:GetDescendants()) do
		if obj:IsA("TextButton") or obj:IsA("ImageButton") then
			local txt = (obj.Text or ""):lower()
			for _, kw in ipairs(keywords) do
				if txt:find(kw:lower()) or txt == kw:lower() then
					local pos = obj.AbsolutePosition + obj.AbsoluteSize / 2
					VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
					task.wait(0.05)
					VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
					return true
				end
			end
		end
	end
	return false
end

local addKeywords = {"add", "ekle", "+", "add item"}
local craftKeywords = {"crate", "craft", "yap", "create", "mix", "karıştır", "üret", "potion"}

-- ==================== SAVE BUTTON ====================
saveBtn.MouseButton1Click:Connect(function()
	local rec = captureRecipe()
	if next(rec) == nil then
		status.Text = "❌ Market UI'sinde miktar görmedim kanka!"
		return
	end
	
	local rName = nameBox.Text ~= "" and nameBox.Text or ("Potion " .. (#savedRecipes + 1))
	savedRecipes[rName] = rec
	currentRecipe = rName
	
	activeLabel.Text = "Aktif Recipe: " .. rName .. "\n" .. getRecipeSummary(rec)
	updateRecipeList()
	
	status.Text = "✅ " .. rName .. " kaydedildi! (" .. getRecipeSummary(rec) .. ")"
	nameBox.Text = ""
end)

-- ==================== AUTO TOGGLE ====================
autoBtn.MouseButton1Click:Connect(function()
	if not currentRecipe then
		status.Text = "Önce bir recipe kaydet kanka!"
		return
	end
	
	autoEnabled = not autoEnabled
	
	if autoEnabled then
		autoBtn.Text = "⏹️ OTO CRATE DURDUR"
		autoBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
		status.Text = currentRecipe .. " oto crate çalışıyor..."
		
		task.spawn(function()
			while autoEnabled and currentRecipe do
				local recipe = savedRecipes[currentRecipe]
				local setCount = applyRecipe(recipe)
				
				if setCount == 0 then
					status.Text = "Market UI'sini aç kanka! (miktar kutuları bulunamadı)"
					task.wait(2)
					continue
				end
				
				task.wait(0.4)
				local added = findAndClick(addKeywords)
				task.wait(0.7)
				local crafted = findAndClick(craftKeywords)
				
				status.Text = "✅ " .. currentRecipe .. " • " .. setCount .. " item eklendi • Crafted!"
				task.wait(1.2) -- oyun animasyonuna göre ayarla istersen
			end
			
			autoBtn.Text = "🚀 OTO CRATE BAŞLAT"
			autoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
			status.Text = "Durduruldu"
		end)
	else
		autoBtn.Text = "🚀 OTO CRATE BAŞLAT"
		autoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
	end
end)

print("✅ Kanka Auto Potion v2 yüklendi!")
print("   → Market aç, miktarları gir, KAYDET butonuna bas")
print("   → Oto Crate ile otomatik ekle + crate yap kanka 🔥")
