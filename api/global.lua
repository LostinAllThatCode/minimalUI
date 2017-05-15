globals = getfenv(0)

function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then return nil
      else return a[i], t[a[i]]
      end
    end
    return iter
end

ScriptErrors:SetScript("OnShow", function(msg)
	local error_message = ScriptErrors_Message:GetText()
	mUI_DebugError(error_message)
	ScriptErrors:Hide()
end)

function mUI_RGBToHex(value)
	local hex = ""
	while(value > 0) do
		local index = math.fmod(value, 16) + 1
		value = math.floor(value / 16)
		hex = string.sub('0123456789ABCDEF', index, index) .. hex			
	end
	if(string.len(hex) == 0) then hex = '00' 
	elseif(string.len(hex) == 1) then hex = '0' .. hex
	end
	return hex
end

function mUI_HexFromColorTable(color_table) -- #ARGB
	return format("#%s%s%s%s", 
		mUI_RGBToHex(color_table.a * 255), 
		mUI_RGBToHex(color_table.r * 255), 
		mUI_RGBToHex(color_table.g * 255),
		mUI_RGBToHex(color_table.b * 255)
	)
end

function mUI_HexFromColors(a,r,g,b) -- #ARGB
	return format("#%s%s%s%s", mUI_RGBToHex(a * 255), mUI_RGBToHex(r * 255), mUI_RGBToHex(g * 255), mUI_RGBToHex(b * 255))
end

function mUI_HexToARGB(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)), tonumber("0x"..hex:sub(7,8))
end

function mUI_HexToARGBFloats(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)) / 255.0, tonumber("0x"..hex:sub(3,4)) / 255.0, tonumber("0x"..hex:sub(5,6)) / 255.0, tonumber("0x"..hex:sub(7,8)) / 255.0
end

function mUI_GetColor(color)
	return color.r, color.g, color.b, color.a
end

function mUI_DebugError(message, debugstack_depth)
	--if(mui_global==nil or mUI_GetVariableValue(mui_global["DEBUG"]) == false) then return end
	local debugmessage = debugstack(debugstack_depth or 2,1,1) or ""
	DEFAULT_CHAT_FRAME:AddMessage("|cffff5555Error: " .. tostring(message) .."\n"..debugmessage)
	--if(MUI_DEBUG_STACK_DEPTH > 0) then DEFAULT_CHAT_FRAME:AddMessage("|cffffaaaa     " .. debugmessage) end
end

function mUI_DebugMessage(message)
	--if(mui_global==nil or mUI_GetVariableValue(mui_global["DEBUG"]) == false) then return end
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff22DEBUG:|r |cffffff88" .. tostring(message))
end

function mUI_PrintMessage(message)
	DEFAULT_CHAT_FRAME:AddMessage(tostring(message))
end

function mUI_EventIsEither(evt, ...)
	local args = {...}
	for i, v in ipairs(args) do
		if(evt == v) then return true end
	end
	return false
end

function mUI_EventRegisterList(frame, ...)
	local args = {...}
	for i, v in ipairs(args) do
		frame:RegisterEvent(v)
	end
end

function mUI_GetClassColor(target)
	local _, class   = UnitClass(target)
	local colortable = mUI_GetVariableValue(mui_global["ClassColors"])
	local color      = colortable[class]
	if(color ~= nil)
	then
		return color
	else
		if(UnitIsEnemy("player", target)) then
			return {r=0.72, g=0.0, b=0.0, a=1.0}
		else
			return {r=0.0, g=0.72, b=0.0, a=1.0}
		end
	end
end

function mUI_GetPowerColor(target)
	local power      = UnitPowerType(target) + 1
	local colortable = mUI_GetVariableValue(mui_global["PowerColors"])
	local color      = colortable[power]
	if(color ~= nil)
	then
		return color
	else
		return {r=0.1, g=0.1, b=0.1, a=1.0}
	end
end

-- General UI stuff
-- 

function mUI_CreateDefaultFrame(parent, name, width, height, strata, backdrop, bg_color, border_color)
	local default_backdrop = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "Interface\\AddOns\\minimalUI\\img\\BorderShadow.tga", 
		tile = false, tileSize = 0, edgeSize = 16, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}
	local frame = CreateFrame("Frame", name, parent or UIParent)
	frame:SetFrameStrata(strata or "LOW")
	frame:SetWidth(width or 64)
	frame:SetHeight(height or 64)
	frame:SetPoint("CENTER", UIParent, "CENTER")
	frame:SetBackdrop(backdrop or default_backdrop)
	if(bg_color ~= nil)
	then
		frame:SetBackdropColor(bg_color.r, bg_color.g, bg_color.b, bg_color.a)
	else
		frame:SetBackdropColor(.1, .1, .1, 1)
	end
	if(border_color ~= nil)
	then
		frame:SetBackdropBorderColor(border_color.r, border_color.g, border_color.b, border_color.a)
	else
		frame:SetBackdropBorderColor(.6, .6, .6, 1)
	end
	return frame
end

function mUI_CreateDefaultUnitFrame(entity, name, width, height, strata, 
									backdrop, backgroundcolor, bordercolor, bar_backdrop, 
									hpcoloring, hpcolor, hpdeficitcolor, 
									mpcoloring, mpcolor, mpdeficitcolor)

	local SetBarColor = function(self)
		if(self.coltype == "CLASS") then
			self:SetBackdropColor( mUI_GetColor(mUI_GetClassColor(entity)) )
		elseif self.coltype == "POWER" then
			self:SetBackdropColor( mUI_GetColor(mUI_GetPowerColor(entity)) )
		else
			self:SetBackdropColor( mUI_GetColor(self.custom) )
		end
	end


	local unitframe = CreateFrame("Button", name .. entity, UIParent)

	unitframe.entitydata = {}
	unitframe.UpdateEntityData = function(self)
		self.entitydata.class 			= UnitClass(entity)
		self.entitydata.classification  = UnitClassification(entity)
		self.entitydata.hp 				= UnitHealth(entity) 
		self.entitydata.hpmax			= UnitHealthMax(entity) or 100
		self.entitydata.isdead 		 	= UnitIsDead(entity)
		self.entitydata.isghost 		= UnitIsGhost(entity)
		self.entitydata.mp 				= UnitMana(entity)
		self.entitydata.mpmax			= UnitManaMax(entity)
		self.entitydata.disconnected	= (self.entitydata.hpmax == 0 and self.entitydata.mpmax == 0)
	end

	unitframe:SetFrameStrata(strata or "LOW")
	unitframe:SetWidth(width or 64)
	unitframe:SetHeight(height or 64)
	unitframe:SetPoint("CENTER", UIParent, "CENTER")
	unitframe:SetBackdrop(backdrop)
	unitframe:SetBackdropColor(mUI_GetColor(backgroundcolor))
	unitframe:SetBackdropBorderColor(mUI_GetColor(bordercolor))
	-- TODO: change this to something the user can toggle for configuration purpose
	unitframe:SetMovable(true)
	unitframe:EnableMouse(true)
	unitframe:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	unitframe:RegisterForDrag("LeftButton")
	unitframe:SetScript("OnDragStart", function() this:StartMoving() end)
	unitframe:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)

-- Entity name label
	unitframe.entity_name = mUI_FontString(unitframe, nil, 18, {r=1,g=1,b=1,a=1}, UnitName(strlower(entity)))

-- Healthbar
	unitframe.hp_deficit = mUI_CreateDefaultFrame(unitframe, nil, 1, 16, strata, bar_backdrop, hpdeficitcolor)
	unitframe.hp_deficit:ClearAllPoints()
	unitframe.hp_deficit:SetPoint("TOPLEFT", unitframe, "TOPLEFT", 2, -2)
	unitframe.hp_deficit:SetPoint("RIGHT", unitframe, "RIGHT", -2, 0)
	unitframe.hp_deficit:SetFrameLevel(2)

	unitframe.hp = mUI_CreateDefaultFrame(unitframe, nil, 1, 16, strata, bar_backdrop)
	unitframe.hp:ClearAllPoints()
	unitframe.hp:SetPoint("TOPLEFT", unitframe.hp_deficit, "TOPLEFT")
	unitframe.hp:SetFrameLevel(3)
	unitframe.hp.text = mUI_FontString(unitframe.hp, nil, 12, {r=0,g=0,b=0,a=1})
	unitframe.hp:SetWidth( unitframe:GetWidth() - 4)
	unitframe.hp.text:SetAllPoints(unitframe.hp_deficit)

	unitframe.hp.coltype   = hpcoloring
	unitframe.hp.custom    = hpcolor
	unitframe.hp.SetColors = SetBarColor

-- Powerbar
 	unitframe.power_deficit = mUI_CreateDefaultFrame(unitframe, nil, 1, 12,  strata, bar_backdrop, mpdeficitcolor)
	unitframe.power_deficit:ClearAllPoints()
	unitframe.power_deficit:SetPoint("TOPLEFT", unitframe.hp_deficit, "BOTTOMLEFT", 0, -1)
	unitframe.power_deficit:SetPoint("RIGHT", unitframe, "RIGHT", -2, 0)
	unitframe.power_deficit:SetFrameLevel(2)

	unitframe.power = mUI_CreateDefaultFrame(unitframe, nil, 1, 12,  strata, bar_backdrop)
	unitframe.power:ClearAllPoints()
	unitframe.power:SetPoint("TOPLEFT", unitframe.power_deficit, "TOPLEFT")
	unitframe.power:SetFrameLevel(3)
	unitframe.power.text = mUI_FontString(unitframe.power, nil, 12, {r=0,g=0,b=0,a=1})
	unitframe.power:SetWidth( unitframe:GetWidth() - 4)
	unitframe.power.text:SetAllPoints(unitframe.power_deficit)

	unitframe.power.coltype   = mpcoloring
	unitframe.power.custom    = mpcolor
	unitframe.power.SetColors = SetBarColor

-- Initialize self updating funtions and event handling	
	unitframe.entity = strlower(entity)
	unitframe.Update = function(self)
		self:UpdateEntityData()
		self:UpdateHealth()
		self:UpdatePower()
		self.hp:SetColors()
		self.power:SetColors()
	end

	unitframe.UpdateHealth = function(self)
		local health_max 	 				= self.entitydata.hpmax
		local health_current 				= self.entitydata.hp
		local health_percentage				= health_current/health_max

		if(self.entitydata.isdead) then
			self.hp.text:SetText( "DEAD" )
		elseif(self.entitydata.isghost) then
			self.hp.text:SetText( "GHOST" )
		elseif(self.entitydata.disconnected) then
			self.hp.text:SetText( "DISCONNECTED" )
		else
			self.hp.text:SetText( health_current .. "/".. health_max)
		end

		if(health_percentage == 0)
		then
			self.hp:SetWidth(-1)	
		else
			self.hp:SetWidth(health_percentage * (self:GetWidth()-4))	
		end
	end
	unitframe.UpdatePower = function(self)
		local power_max			= self.entitydata.mpmax
		local power_current		= self.entitydata.mp
		local power_percentage  = power_current/power_max
		if(self.entitydata.isdead or self.entitydata.isghost or self.entitydata.disconnected)
		then
			self.power.text:SetText( "" )
		else
			self.power.text:SetText( power_current .. "/".. power_max)
		end

		if(power_percentage == 0)
		then
			self.power:SetWidth(-1)	
		else
			self.power:SetWidth(power_percentage * (self:GetWidth()-4))	
		end
	end

	unitframe:Update()

	return unitframe
end

function mUI_CreateDefaultButton(parent, name, text, width, height, fontsize, highlight_color)
   	local font = "Interface\\Addons\\minimalUI\\Fonts\\homespun.ttf"
	local default_backdrop = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "", 
		tile = false, tileSize = 0, edgeSize = 16, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}
  
	local button = CreateFrame("Button", nil, parent)
	button:SetPoint("CENTER", parent, "CENTER", 0, 0)
	button:SetHeight(height or 18)
	button:SetWidth(width or 64)
	button:SetBackdrop(default_backdrop)
	button:SetBackdropColor(.15, .15, .15, 1)
	button:SetBackdropBorderColor(.4, .4, .4, 1)
	button:SetFont(font, fontsize or 12)
	button:SetText(text)
	button:SetTextColor(1, 1, 1, 1)
	
	local highlight = button:CreateTexture()
	highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
	highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	if(highlight_color ~= nil)
	then
		highlight:SetTexture(highlight_color.r, highlight_color.g, highlight_color.b, highlight_color.a)
	else
		highlight:SetTexture(.5, .5, .5, .1)
	end
	button:SetHighlightTexture(highlight)
	
	return button
end

function mUI_CreateDefaultScrollframe(parent, name, width, height)
	local default_backdrop = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "", 
		tile = false, tileSize = 0, edgeSize = 16, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}

	local frame = CreateFrame("Frame", name, UIParent)
	frame:SetWidth(width or 120)
	frame:SetHeight(height or 120)
	frame:SetPoint("LEFT", UIParent, 'LEFT', 0, 0)
	frame:SetFrameStrata('DIALOG')

	frame:SetBackdrop(default_backdrop)
	frame:SetBackdropColor(.1, .1, .1, 1)
	frame:SetBackdropBorderColor(.25, .25, .25, 1)
   
	local scroll = CreateFrame("ScrollFrame", name.."ScrollFrame", UIParent, "UIPanelScrollFrameTemplate")
	scroll:SetPoint('TOPLEFT', frame, 'TOPLEFT', 10, -7)
   	scroll:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -30, 5)

	frame.scroll = scroll
	return frame
end

function mUI_CreateDefaultEditbox(parent, value, width, height, justifiyV, justifiyH)
   	local font = "Interface\\Addons\\minimalUI\\Fonts\\homespun.ttf"
	local default_backdrop = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "", 
		tile = false, tileSize = 0, edgeSize = 16, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}	
	
	local editbox = CreateFrame("Editbox", nil, parent)
	editbox:SetHeight(height or 18)
	editbox:SetWidth(width or 64)
	editbox:SetFont(font, 10)
	editbox:SetTextInsets(4,4,4,4) 
	editbox:SetAutoFocus(false)
	editbox:SetPoint("CENTER", parent, "CENTER", 0, 0)
	editbox:SetScript("OnEscapePressed", function() this:ClearFocus() end)
	editbox:SetScript("OnTabPressed", function() if this.next then this.next:SetFocus() end end)
	editbox:SetScript("OnEditFocusGained", function() this.hasFocus = true this:HighlightText() end)
   	editbox:SetScript("OnEditFocusLost", function() this.hasFocus = false this:HighlightText(0,0) end)   
   	editbox.hasFocus = false
   	editbox:SetBackdrop(default_backdrop) 
   	editbox:SetBackdropColor(.25, .25, .25, .9)
   	editbox:SetBackdropBorderColor(.4, .4, .4, 1)
   	editbox:SetText(value)

   	if(justifiyV ~= nil and justifiyV ~= "") then editbox:SetJustifyV(justifiyV) end
   	if(justifiyH ~= nil and justifiyH ~= "") then editbox:SetJustifyH(justifiyH) end
   	return editbox
end

function mUI_CreateColorPicker(parent, callback, width, height, initial_color)
	local default_backdrop = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "", 
		tile = false, tileSize = 0, edgeSize = 16, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}	
   
	local picker = CreateFrame("Button", nil, parent)
	picker:SetWidth(width or 18)
	picker:SetHeight(height or 18)
	picker:SetBackdrop(default_backdrop)

	if(initial_color ~= nil)
	then
		picker:SetBackdropColor(initial_color.r, initial_color.g, initial_color.b, initial_color.a)
	else
		picker:SetBackdropColor(1, 1, 1, 1)
	end
   picker:SetPoint("CENTER", parent)
   picker.callback = callback

   local picker_current  = 20
   local picker_interval = 20
   picker.internal = function()
   		if(picker_current >= picker_interval) then
      		local a, r, g, b = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
      		picker:SetBackdropColor(r, g, b, a)
      		if picker.callback then picker:callback(r, g, b, a) end
      		picker_current = 0
      	else
      		picker_current = picker_current + 1
      	end
   end
   
   picker:SetScript("OnClick", function()
		local r,g,b,a = picker:GetBackdropColor()
		ColorPickerFrame.hasOpacity = true
		ColorPickerFrame.opacity = a
		ColorPickerFrame.func = this.internal
		ColorPickerFrame.opacityFunc = this.internal
		ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
		ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
		OpacitySliderFrame:SetValue(a)
		ColorPickerFrame:Show();
		ColorPickerFrame:SetColorRGB(r,g,b);
   end)

   	local highlight = picker:CreateTexture()
	highlight:SetPoint("TOPLEFT", picker, "TOPLEFT", 1, -1)
	highlight:SetPoint("BOTTOMRIGHT", picker, "BOTTOMRIGHT", -1, 1)
	highlight:SetTexture(.3, .3, .3, .5)
	picker:SetHighlightTexture(highlight)

   picker:EnableMouse(true)
   return picker
end

function mUI_FontString(frame, font, size, color, text, justifiyV, justifiyH)
	if(frame == nil) then return end
	local fontstring = frame:CreateFontString(nil)
	fontstring:SetAllPoints(frame)
   	fontstring:SetFont(font or "Interface\\Addons\\minimalUI\\Fonts\\homespun.ttf", size or 10)

	if(color ~= nil)
	then
		fontstring:SetTextColor(color.r, color.g, color.b, color.a)
	else
		fontstring:SetTextColor(1,1,1,1)
	end

   	fontstring:SetText(text or "")
   	if(justifiyV ~= nil and justifiyV ~= "") then fontstring:SetJustifyV(justifiyV) end
   	if(justifiyH ~= nil and justifiyH ~= "") then fontstring:SetJustifyH(justifiyH) end
   	return fontstring
end

function mUI_CreateCheckButton(parent)
 	local checkbutton = CreateFrame("CheckButton", nil, parent)
	checkbutton:SetCheckedTexture("Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga")
	
	local tex = checkbutton:GetCheckedTexture() 
	tex:ClearAllPoints()
	tex:SetPoint("TOPLEFT", checkbutton, "TOPLEFT", 3, -3)
	tex:SetPoint("BOTTOMRIGHT", checkbutton, "BOTTOMRIGHT", -3, 3)
	tex:SetVertexColor(.6,.6,.6,1)

	local highlight = checkbutton:CreateTexture()
	highlight:SetPoint("TOPLEFT", checkbutton, "TOPLEFT", 1, -1)
	highlight:SetPoint("BOTTOMRIGHT", checkbutton, "BOTTOMRIGHT", -1, 1)
	highlight:SetTexture(.3, .3, .3, .5)
	checkbutton:SetHighlightTexture(highlight)
	return checkbutton
end

function mUI_ComboBox(parent)
	local combobox = CreateButton("Button", nil, parent)
	combobox:SetCheckedTexture("Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga")
	local tex = combobox:GetCheckedTexture() 
	tex:ClearAllPoints()
	tex:SetPoint("TOPLEFT", combobox, "TOPLEFT", 3, -3)
	tex:SetPoint("BOTTOMRIGHT", combobox, "BOTTOMRIGHT", -3, 3)
	tex:SetVertexColor(1,1,0,1)
	return combobox
end
