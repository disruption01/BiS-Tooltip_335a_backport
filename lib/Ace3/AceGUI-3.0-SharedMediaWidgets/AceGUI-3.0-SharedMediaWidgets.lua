-- Widget is based on the AceGUIWidget-DropDown.lua supplied with AceGUI-3.0
-- Widget created by Yssaril

local AceGUI = LibStub("AceGUI-3.0")
local Media = LibStub("LibSharedMedia-3.0")

do
	local function readOnly (t)
		local proxy = {}
		local mt = {       -- create metatable
			__index = t,
			__newindex = function (t,k,v)
				error("attempt to update a read-only table", 2)
			end
		}
		setmetatable(proxy, mt)
		return proxy
    end
	local lists = readOnly{}
	rawset(lists, 'font', readOnly{})
	rawset(lists, 'sound', readOnly{})
	rawset(lists, 'statusbar', readOnly{})
	rawset(lists, 'border', readOnly{})
	rawset(lists, 'background', readOnly{})
	
	Media:RegisterCallback("LibSharedMedia_Registered", function(event, mediatype, key)
			if lists[mediatype] then
				rawset(lists[mediatype], key, key)
			end
		end)
		
	for k, v in pairs(Media:List("font")) do
		rawset(lists.font, v, v)
	end
	for k, v in pairs(Media:List("sound")) do
		rawset(lists.sound, v, v)
	end
	for k, v in pairs(Media:List("statusbar")) do
		rawset(lists.statusbar, v, v)
	end
	for k, v in pairs(Media:List("border")) do
		rawset(lists.border, v, v)
	end
	for k, v in pairs(Media:List("background")) do
		rawset(lists.background, v, v)
	end


	
	local min, max, floor = math.min, math.max, math.floor

	local function fixlevels(parent,...)
		local i = 1
		local child = select(i, ...)
		while child do
			child:SetFrameLevel(parent:GetFrameLevel()+1)
			fixlevels(child, child:GetChildren())
			i = i + 1
			child = select(i, ...)
		end
	end

	local function OnItemValueChanged(this, event, checked)
		local self = this.userdata.obj
		if self.multiselect then
			self:Fire("OnValueChanged", this.userdata.value, checked)
		else
			if checked then
				self:SetValue(this.userdata.value)
				self:Fire("OnValueChanged", this.userdata.value)
			else
				this:SetValue(true)
			end		
			self.pullout:Close()
		end
	end
	
	do
		local widgetType = "LSM30_Font_Item_Select"
		local widgetVersion = 1

		local function SetText(self, text)
			if text and text ~= '' then
				local _, size, outline= self.text:GetFont()
				self.text:SetFont(Media:Fetch('font',text),size,outline)
			end
			self.text:SetText(text or "")
		end
		
		local function Constructor()
			local self = AceGUI:Create("Dropdown-Item-Toggle")
			self.type = widgetType
			self.SetText = SetText
			return self
		end
		
		AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
	end

	do
		local widgetType = "LSM30_Statusbar_Item_Select"
		local widgetVersion = 1

		local function SetText(self, text)
			if text and text ~= '' then
				self.texture:SetTexture(Media:Fetch('statusbar',text))
				self.texture:SetVertexColor(.5,.5,.5)
			end
			self.text:SetText(text or "")
		end

		local function Constructor()
			local self = AceGUI:Create("Dropdown-Item-Toggle")
			self.type = widgetType
			self.SetText = SetText
			local texture = self.frame:CreateTexture(nil, "BACKGROUND")
			texture:SetTexture(0,0,0,0)
			texture:SetPoint("BOTTOMRIGHT",self.frame,"BOTTOMRIGHT",-4,1)
			texture:SetPoint("TOPLEFT",self.frame,"TOPLEFT",6,-1)
			self.texture = texture
			return self
		end
		
		AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
	end

	do
		local widgetType = "LSM30_Background_Item_Select"
		local widgetVersion = 1
			
		local function Frame_OnEnter(this)
			local self = this.obj

			if self.useHighlight then
				self.highlight:Show()
				self.texture:Show()
			end
			self:Fire("OnEnter")
			
			if self.specialOnEnter then
				self.specialOnEnter(self)
			end
		end

		local function Frame_OnLeave(this)
			local self = this.obj
			self.texture:Hide()
			self.highlight:Hide()
			self:Fire("OnLeave")
			
			if self.specialOnLeave then
				self.specialOnLeave(self)
			end
		end

		local function SetText(self, text)
			if text and text ~= '' then
				self.texture:SetTexture(Media:Fetch('background',text))
			end
			self.text:SetText(text or "")
		end
		
		local function Constructor()
			local self = AceGUI:Create("Dropdown-Item-Toggle")
			self.type = widgetType
			self.SetText = SetText
			local textureframe = CreateFrame('Frame')
			textureframe:SetFrameStrata("TOOLTIP")
			textureframe:SetWidth(128)
			textureframe:SetHeight(128)
			textureframe:SetPoint("LEFT",self.frame,"RIGHT",5,0)
			self.textureframe = textureframe
			local texture = textureframe:CreateTexture(nil, "OVERLAY")
			texture:SetTexture(0,0,0,0)
			texture:SetAllPoints(textureframe)
			texture:Hide()
			self.texture = texture
			self.frame:SetScript("OnEnter", Frame_OnEnter)
			self.frame:SetScript("OnLeave", Frame_OnLeave)
			return self
		end
		
		AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
	end
	
	do
		local widgetType = "LSM30_Sound_Item_Select"
		local widgetVersion = 1
			
		local function Frame_OnEnter(this)
			local self = this.obj

			if self.useHighlight then
				self.highlight:Show()
			end
			self:Fire("OnEnter")
			
			if self.specialOnEnter then
				self.specialOnEnter(self)
			end
		end

		local function Frame_OnLeave(this)
			local self = this.obj
			
			self.highlight:Hide()
			self:Fire("OnLeave")
			
			if self.specialOnLeave then
				self.specialOnLeave(self)
			end
		end

		local function OnAcquire(self)
			self.frame:SetToplevel(true)
			self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
		end

		local function OnRelease(self)
			self.pullout = nil
			self.frame:SetParent(nil)
			self.frame:ClearAllPoints()
			self.frame:Hide()
		end

		local function SetPullout(self, pullout)
			self.pullout = pullout
			
			self.frame:SetParent(nil)
			self.frame:SetParent(pullout.itemFrame)
			self.parent = pullout.itemFrame
			fixlevels(pullout.itemFrame, pullout.itemFrame:GetChildren())
		end

		local function SetText(self, text)
			self.sound = text or ''
			self.text:SetText(text or "")
		end

		local function GetText(self)
			return self.text:GetText()
		end

		local function SetPoint(self, ...)
			self.frame:SetPoint(...)
		end

		local function Show(self)
			self.frame:Show()
		end

		local function Hide(self)
			self.frame:Hide()
		end
		
		local function SetDisabled(self, disabled)
			self.disabled = disabled
			if disabled then
				self.useHighlight = false
				self.text:SetTextColor(.5, .5, .5)
			else
				self.useHighlight = true
				self.text:SetTextColor(1, 1, 1)
			end
		end
		
		local function SetOnLeave(self, func)
			self.specialOnLeave = func
		end

		local function SetOnEnter(self, func)
			self.specialOnEnter = func
		end

		local function UpdateToggle(self)
			if self.value then
				self.check:Show()
			else
				self.check:Hide()
			end
		end
		
		local function Frame_OnClick(this, button)
			local self = this.obj
			self.value = not self.value
			UpdateToggle(self)
			self:Fire("OnValueChanged", self.value)
		end
		
		local function Speaker_OnClick(this, button)
			local self = this.obj
			PlaySoundFile(Media:Fetch('sound',self.sound))
		end
		
		local function SetValue(self, value)
			self.value = value
			UpdateToggle(self)
		end
		
		local function Constructor()
			local count = AceGUI:GetNextWidgetNum(type)
			local frame = CreateFrame("Frame", "LSM30_Sound_DropDownItem"..count)
			local self = {}
			self.frame = frame
			frame.obj = self
			self.type = type
			
			self.useHighlight = true
			
			frame:SetHeight(17)
			frame:SetFrameStrata("FULLSCREEN_DIALOG")
			
			local button = CreateFrame("Button", nil, frame)
			button:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-22,0)
			button:SetPoint("TOPLEFT",frame,"TOPLEFT",0,0)
			self.button = button
			button.obj = self
			
			local speakerbutton = CreateFrame("Button", nil, frame)
			speakerbutton:SetWidth(16)
			speakerbutton:SetHeight(16)
			speakerbutton:SetPoint("RIGHT",frame,"RIGHT",-6,0)
			self.speakerbutton = speakerbutton
			speakerbutton.obj = self
			
			local speaker = frame:CreateTexture(nil, "BACKGROUND")
			speaker:SetTexture("Interface\\Common\\VoiceChat-Speaker")
			speaker:SetAllPoints(speakerbutton)
			self.speaker = speaker
			
			local speakeron = speakerbutton:CreateTexture(nil, "HIGHLIGHT")
			speakeron:SetTexture("Interface\\Common\\VoiceChat-On")
			speakeron:SetAllPoints(speakerbutton)
			self.speakeron = speakeron
			
			local text = frame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
			text:SetTextColor(1,1,1)
			text:SetJustifyH("LEFT")
			text:SetPoint("TOPLEFT",frame,"TOPLEFT",18,0)
			text:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-24,0)
			self.text = text

			local highlight = button:CreateTexture(nil, "OVERLAY")
			highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
			highlight:SetBlendMode("ADD")
			highlight:SetHeight(14)
			highlight:ClearAllPoints()
			highlight:SetPoint("RIGHT",frame,"RIGHT",-19,0)
			highlight:SetPoint("LEFT",frame,"LEFT",5,0)
			highlight:Hide()
			self.highlight = highlight
			
			local check = frame:CreateTexture("OVERLAY")	
			check:SetWidth(16)
			check:SetHeight(16)
			check:SetPoint("LEFT",frame,"LEFT",3,-1)
			check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
			check:Hide()
			self.check = check

			local sub = frame:CreateTexture("OVERLAY")
			sub:SetWidth(16)
			sub:SetHeight(16)
			sub:SetPoint("RIGHT",frame,"RIGHT",-3,-1)
			sub:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
			sub:Hide()
			self.sub = sub	
			
			button:SetScript("OnEnter", Frame_OnEnter)
			button:SetScript("OnLeave", Frame_OnLeave)
			
			self.OnAcquire = OnAcquire
			self.OnRelease = OnRelease
			
			self.SetPullout = SetPullout
			self.GetText	= GetText
			self.SetText	= SetText
			self.SetDisabled = SetDisabled
			
			self.SetPoint   = SetPoint
			self.Show	   = Show
			self.Hide	   = Hide
			
			self.SetOnLeave = SetOnLeave
			self.SetOnEnter = SetOnEnter
			
			self.button:SetScript("OnClick", Frame_OnClick)
			self.speakerbutton:SetScript("OnClick", Speaker_OnClick)
			
			self.SetValue = SetValue
			
			AceGUI:RegisterAsWidget(self)
			return self
		end
		
		AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
	end
	
	do
		local widgetType = "LSM30_Border_Item_Select"
		local widgetVersion = 1
			
		local function Frame_OnEnter(this)
			local self = this.obj

			if self.useHighlight then
				self.highlight:Show()
				self.border:Show()
			end
			self:Fire("OnEnter")
			
			if self.specialOnEnter then
				self.specialOnEnter(self)
			end
		end

		local function Frame_OnLeave(this)
			local self = this.obj
			self.border:Hide()
			self.highlight:Hide()
			self:Fire("OnLeave")
			
			if self.specialOnLeave then
				self.specialOnLeave(self)
			end
		end

		local function SetText(self, text)
			if text and text ~= '' then
				local backdropTable = self.border:GetBackdrop()
				backdropTable.edgeFile = Media:Fetch('border',text)
				self.border:SetBackdrop(backdropTable)
			end
			self.text:SetText(text or "")
		end
		
		local function Constructor()
			local self = AceGUI:Create("Dropdown-Item-Toggle")
			self.type = widgetType
			self.SetText = SetText
			local border = CreateFrame('Frame')
			border:SetFrameStrata("TOOLTIP")
			border:SetWidth(64)
			border:SetHeight(32)
			border:SetPoint("LEFT",self.frame,"RIGHT",5,0)
			border:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 4, right = 4, top = 4, bottom = 4 }})
			self.border = border
			border:Hide()
			self.frame:SetScript("OnEnter", Frame_OnEnter)
			self.frame:SetScript("OnLeave", Frame_OnLeave)
			return self
		end
		
		AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
	end
	
	do 
		local widgetType = "LSM30_Font"
		local widgetVersion = 1
		
		local function SetText(self, text)		
			if text and text ~= '' then
				local _, size, outline= self.text:GetFont()
				self.text:SetFont(Media:Fetch('font',text),size,outline)
			end
			self.text:SetText(text or "")
		end

		local function SetValue(self, value)
			if value then
				if value ~= '' then
					local _, size, outline= self.text:GetFont()
					self.text:SetFont(Media:Fetch('font',value),size,outline)
				end
				self:SetText(value or "")
			end
			self.value = value
		end
		
		local function AddListItem(self, value, text)
			local item = AceGUI:Create("LSM30_Font_Item_Select")
			item:SetText(text)
			item.userdata.obj = self
			item.userdata.value = value
			item:SetCallback("OnValueChanged", OnItemValueChanged)
			self.pullout:AddItem(item)
		end
		
		local sortlist = {}
		local function SetList(self, list)
			self.list = list or lists.font
			self.pullout:Clear()
			
			for v in pairs(self.list) do
				sortlist[#sortlist + 1] = v
			end
			table.sort(sortlist)
			
			for i, value in pairs(sortlist) do
				AddListItem(self, value, self.list[value])
				sortlist[i] = nil
			end
			if self.multiselect then
				AddCloseButton()
			end
		end
		
		local function Constructor()
			local self = AceGUI:Create("Dropdown")
			self.type = widgetType
			self.SetText = SetText
			self.SetValue = SetValue
			self.SetList = SetList
			return self
		end
		
		AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
	end
	
	do 
		local widgetType = "LSM30_Statusbar"
		local widgetVersion = 1
		
		local function SetText(self, text)
			if text and text ~= '' then
				self.texture:SetTexture(Media:Fetch('statusbar',text))
				self.texture:SetVertexColor(.5,.5,.5)
			end
			self.text:SetText(text or "")
		end
		
		local function AddListItem(self, value, text)
			local item = AceGUI:Create("LSM30_Statusbar_Item_Select")
			item:SetText(text)
			item.userdata.obj = self
			item.userdata.value = value
			item:SetCallback("OnValueChanged", OnItemValueChanged)
			self.pullout:AddItem(item)
		end
		
		local sortlist = {}
		local function SetList(self, list)
			self.list = list or lists.statusbar
			self.pullout:Clear()
			
			for v in pairs(self.list) do
				sortlist[#sortlist + 1] = v
			end
			table.sort(sortlist)
			
			for i, value in pairs(sortlist) do
				AddListItem(self, value, self.list[value])
				sortlist[i] = nil
			end
			if self.multiselect then
				AddCloseButton()
			end
		end
		
		local function Constructor()
			local self = AceGUI:Create("Dropdown")
			self.type = widgetType
			self.SetText = SetText
			self.SetList = SetList
			
			local left = _G[self.dropdown:GetName() .. "Left"]
			local middle = _G[self.dropdown:GetName() .. "Middle"]
			local right = _G[self.dropdown:GetName() .. "Right"]
			
			local texture = self.dropdown:CreateTexture(nil, "ARTWORK")
			texture:SetPoint("BOTTOMRIGHT", right, "BOTTOMRIGHT" ,-39, 26)
			texture:SetPoint("TOPLEFT", left, "TOPLEFT", 24, -24)
			self.texture = texture
			return self
		end
		
		AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
	end

	do 
		local widgetType = "LSM30_Background"
		local widgetVersion = 1
		
		local function Frame_OnEnter(this)
			local self = this.obj
			local text = self.text:GetText()
			if text ~= nil and text ~= '' then 
				self.textureframe:Show()
			end
		end
		
		local function Frame_OnLeave(this)
			local self = this.obj
			self.textureframe:Hide()
		end
		
		local function SetText(self, text)
			if text and text ~= '' then
				self.texture:SetTexture(Media:Fetch('background',text))
			end
			self.text:SetText(text or "")
		end
		
		local function AddListItem(self, value, text)
			local item = AceGUI:Create("LSM30_Background_Item_Select")
			item:SetText(text)
			item.userdata.obj = self
			item.userdata.value = value
			item:SetCallback("OnValueChanged", OnItemValueChanged)
			self.pullout:AddItem(item)
		end
		
		local sortlist = {}
		local function SetList(self, list)
			self.list = list or lists.background
			self.pullout:Clear()
			
			for v in pairs(self.list) do
				sortlist[#sortlist + 1] = v
			end
			table.sort(sortlist)
			
			for i, value in pairs(sortlist) do
				AddListItem(self, value, self.list[value])
				sortlist[i] = nil
			end
			if self.multiselect then
				AddCloseButton()
			end
		end
		
		local function Constructor()
			local self = AceGUI:Create("Dropdown")
			self.type = widgetType
			self.SetText = SetText
			self.SetList = SetList
			
			local left = _G[self.dropdown:GetName() .. "Left"]
			local middle = _G[self.dropdown:GetName() .. "Middle"]
			local right = _G[self.dropdown:GetName() .. "Right"]
			
			local textureframe = CreateFrame('Frame')
			textureframe:SetFrameStrata("TOOLTIP")
			textureframe:SetWidth(128)
			textureframe:SetHeight(128)
			textureframe:SetPoint("LEFT",right,"RIGHT",-15,0)
			self.textureframe = textureframe
			local texture = textureframe:CreateTexture(nil, "OVERLAY")
			texture:SetTexture(0,0,0,0)
			texture:SetAllPoints(textureframe)
			textureframe:Hide()
			self.texture = texture
			
			self.dropdown:EnableMouse(true)
			self.dropdown:SetScript("OnEnter", Frame_OnEnter)
			self.dropdown:SetScript("OnLeave", Frame_OnLeave)
			
			return self
		end
		
		AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
	end

	do 
		local widgetType = "LSM30_Sound"
		local widgetVersion = 1
		
		local function AddListItem(self, value, text)
			local item = AceGUI:Create("LSM30_Sound_Item_Select")
			item:SetText(text)
			item.userdata.obj = self
			item.userdata.value = value
			item:SetCallback("OnValueChanged", OnItemValueChanged)
			self.pullout:AddItem(item)
		end
		
		local sortlist = {}
		local function SetList(self, list)
			self.list = list or lists.sound
			self.pullout:Clear()
			
			for v in pairs(self.list) do
				sortlist[#sortlist + 1] = v
			end
			table.sort(sortlist)
			
			for i, value in pairs(sortlist) do
				AddListItem(self, value, self.list[value])
				sortlist[i] = nil
			end
			if self.multiselect then
				AddCloseButton()
			end
		end
		
		local function Constructor()
			local self = AceGUI:Create("Dropdown")
			self.type = widgetType
			self.SetList = SetList
			return self
		end

		AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
	end
	
	do 
		local widgetType = "LSM30_Border"
		local widgetVersion = 1
		
		local function Frame_OnEnter(this)
			local self = this.obj
			local text = self.text:GetText()
			if text ~= nil and text ~= '' then 
				self.borderframe:Show()
			end
		end
		
		local function Frame_OnLeave(this)
			local self = this.obj
			self.borderframe:Hide()
		end
		
		local function AddListItem(self, value, text)
			local item = AceGUI:Create("LSM30_Border_Item_Select")
			item:SetText(text)
			item.userdata.obj = self
			item.userdata.value = value
			item:SetCallback("OnValueChanged", OnItemValueChanged)
			self.pullout:AddItem(item)
		end
		
		local sortlist = {}
		local function SetList(self, list)
			self.list = list or lists.border
			self.pullout:Clear()
			
			for v in pairs(self.list) do
				sortlist[#sortlist + 1] = v
			end
			table.sort(sortlist)
			
			for i, value in pairs(sortlist) do
				AddListItem(self, value, self.list[value])
				sortlist[i] = nil
			end
			if self.multiselect then
				AddCloseButton()
			end
		end
		
		local function SetText(self, text)
			if text and text ~= '' then
				local backdropTable = self.borderframe:GetBackdrop()
				backdropTable.edgeFile = Media:Fetch('border',text)
				self.borderframe:SetBackdrop(backdropTable)
			end
			self.text:SetText(text or "")
		end
		
		local function Constructor()
			local self = AceGUI:Create("Dropdown")
			self.type = widgetType
			self.SetList = SetList
			self.SetText = SetText
			
			local left = _G[self.dropdown:GetName() .. "Left"]
			local middle = _G[self.dropdown:GetName() .. "Middle"]
			local right = _G[self.dropdown:GetName() .. "Right"]
			
			local borderframe = CreateFrame('Frame')
			borderframe:SetFrameStrata("TOOLTIP")
			borderframe:SetWidth(64)
			borderframe:SetHeight(32)
			borderframe:SetPoint("LEFT",right,"RIGHT",-15,0)
			borderframe:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 4, right = 4, top = 4, bottom = 4 }})
			self.borderframe = borderframe
			borderframe:Hide()
			
			self.dropdown:EnableMouse(true)
			self.dropdown:SetScript("OnEnter", Frame_OnEnter)
			self.dropdown:SetScript("OnLeave", Frame_OnLeave)
			
			return self
		end

		AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
	end

	AceGUIWidgetLSMlists = lists
end
