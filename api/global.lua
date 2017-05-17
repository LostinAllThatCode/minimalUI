globals = getfenv(0)

MUI_GLOBAL_FONT_TABLE = 
{
	"Interface\\AddOns\\minimalUI\\fonts\\8_Bit_Madness.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\alterebro.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\apple.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\Asai-Analogue.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\big_noodle_titling.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\BMSPA___.TTF",
	"Interface\\AddOns\\minimalUI\\fonts\\capture.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\CaviarDreams.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\homespun.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\LiberationMono-Bold.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\LiberationMono-Regular.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\macromedia.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\ostrich.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\pixelade.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\pixelbold.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\pricedown bl.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\silkscreen.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\uni.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\upheavtt.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\visitor1.ttf",
	"Interface\\AddOns\\minimalUI\\fonts\\visitor2.ttf"
}

MUI_GLOBAL_TEXTURE_TABLE = 
{
	"Interface\\AddOns\\minimalUI\\img\\Aluminium.tga",
	"Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga",
	"Interface\\AddOns\\minimalUI\\img\\BantoBar.tga",
	"Interface\\AddOns\\minimalUI\\img\\Bars.tga",
	"Interface\\AddOns\\minimalUI\\img\\BorderGlow.tga",
	"Interface\\AddOns\\minimalUI\\img\\BorderShadow.tga",
	"Interface\\AddOns\\minimalUI\\img\\Gloss.tga",
	"Interface\\AddOns\\minimalUI\\img\\Healbot.tga",
	"Interface\\AddOns\\minimalUI\\img\\Luna.tga",
	"Interface\\AddOns\\minimalUI\\img\\Otravi.tga",
	"Interface\\AddOns\\minimalUI\\img\\Smooth.tga",
	"Interface\\AddOns\\minimalUI\\img\\Striped.tga"
}

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
	elseif(string.len(hex) == 1) then hex = hex .. '0'
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

function mUI_HexFromColorTableToString(color_table) -- #ARGB
	return format("|c%s%s%s%s", 
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
	if(mui_global==nil or mUI_GetVariableValue(mui_global["DEBUG"]) == false) then return end
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
	local colortable = mui_global["ClassColors"].value
	local color      = colortable[class]
	if(color ~= nil)
	then
		return color
	else
		if(UnitIsEnemy("player", target)) then
			return {r=0.72, g=0.0, b=0.0, a=1.0}
		else
			return {r=.0, g=0.72, b=0.0, a=1.0}
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

function mUI_AddHighlight(frame, highlight_color, botattach)
	frame:EnableMouse(true)

	local highlight = frame:CreateTexture()
	highlight:SetHeight(1)
	highlight:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, -1)
	highlight:SetPoint("BOTTOMRIGHT", botattach or frame, "BOTTOMRIGHT", -1, 1)
	if(highlight_color ~= nil)
	then
		highlight:SetTexture(highlight_color.r, highlight_color.g, highlight_color.b, highlight_color.a)
	else
		highlight:SetTexture(.5, .5, .5, .1)
	end
	highlight:Hide()

	frame:SetScript("OnEnter", function () highlight:Show() end)
	frame:SetScript("OnLeave", function () highlight:Hide() end)
end

function mUI_CreateDefaultFrame(parent, name, width, height, strata, backdrop, bg_color, border_color)
	local default_backdrop = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "", 
		tile = false, tileSize = 0, edgeSize = 8, 
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

function mUI_CreateDefaultButton(parent, name, text, width, height, fontsize, highlight_color)
   	--local font = "Interface\\Addons\\minimalUI\\Fonts\\homespun.ttf"
   	local font = "Interface\\Addons\\minimalUI\\Fonts\\visitor1.ttf"
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
   	local font = "Interface\\Addons\\minimalUI\\Fonts\\LiberationMono-Regular.ttf"
	local default_backdrop = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "", 
		tile = false, tileSize = 0, edgeSize = 16, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}	
	
	local editbox = CreateFrame("Editbox", nil, parent)
	editbox:SetHeight(height or 18)
	editbox:SetWidth(width or 64)
	editbox:SetFont(font, 11)
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

   	local picker_interval = 10
   	picker.internal = function()
   		if(picker_current == nil) then picker_current = 0 end
   		if(picker_current > picker_interval or picker.released_mouse) then
      		local a, r, g, b = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
      		picker:SetBackdropColor(r, g, b, a)
      		if picker.callback then picker:callback(r, g, b, a) end	
      		picker_current = 0
      	else
      		picker_current = picker_current + 1
      	end
   	end
   	picker.cancel = function ()
   		picker:SetBackdropColor(unpack(ColorPickerFrame.previousValues))
   		if picker.callback then picker:callback(unpack(ColorPickerFrame.previousValues)) end
   	end
   
   	picker:SetScript("OnClick", function()
		local r,g,b,a = picker:GetBackdropColor()
		ColorPickerFrame.hasOpacity = true
		ColorPickerFrame.opacity = a
		ColorPickerFrame.func = this.internal
		ColorPickerFrame.cancelFunc = this.cancel
		ColorPickerFrame.previousValues = {r,g,b,a};
		ColorPickerFrame.opacityFunc = this.internal
		ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
		ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
		OpacitySliderFrame:SetValue(a)
		ColorPickerFrame:Show();
		ColorPickerFrame:SetColorRGB(r,g,b);
   	end)

	if(firstInit == nil) then
		firstInit = true
		ColorPickerFrame:SetScript("OnMouseUp", function()
			picker.released_mouse = true
		end)
		ColorPickerFrame:SetScript("OnMouseDown", function()
			picker.released_mouse = false
		end)
		OpacitySliderFrame:SetScript("OnMouseUp", function()
			--picker.released_mouse = true
			picker_current = 1
		end)
		OpacitySliderFrame:SetScript("OnMouseDown", function()
			picker.released_mouse = false
		end)
	end

   	local highlight = picker:CreateTexture()
	highlight:SetPoint("TOPLEFT", picker, "TOPLEFT", 1, -1)
	highlight:SetPoint("BOTTOMRIGHT", picker, "BOTTOMRIGHT", -1, 1)
	highlight:SetTexture(.3, .3, .3, .5)
	picker:SetHighlightTexture(highlight)

   picker:EnableMouse(true)
   return picker
end

function mUI_FontString(frame, font, size, color, text, justifiyV, justifiyH)
	--local deffont = "Interface\\Addons\\minimalUI\\Fonts\\visitor1.ttf"
	local deffont = "Interface\\Addons\\minimalUI\\Fonts\\LiberationMono-Bold.ttf"
	if(frame == nil) then return end
	local fontstring = frame:CreateFontString(nil)
	fontstring:SetAllPoints(frame)
   	fontstring:SetFont(font or deffont, 11)

	if(color ~= nil)
	then
		fontstring:SetTextColor(color.r, color.g, color.b, color.a)
	else
		fontstring:SetTextColor(1,1,1,1)
	end
	fontstring:SetShadowColor(0,0,0,1)
	fontstring:SetShadowOffset(1,-1)
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
	tex:SetVertexColor(0.0,0.5,1.0,1)

	local highlight = checkbutton:CreateTexture()
	highlight:SetPoint("TOPLEFT", checkbutton, "TOPLEFT", 1, -1)
	highlight:SetPoint("BOTTOMRIGHT", checkbutton, "BOTTOMRIGHT", -1, 1)
	highlight:SetTexture(.3, .3, .3, .5)
	checkbutton:SetHighlightTexture(highlight)
	return checkbutton
end


function mUI_ComboBox(parent, combo_type, callback)
	-- initialze a global set of dropdown menu items
	if(MUI_COMBO_DROPDOWN == nil) then
		MUI_COMBO_DROPDOWN = CreateFrame("Frame")
		MUI_COMBO_DROPDOWN:SetBackdrop({ 
			bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
			edgeFile = "", 
			tile = false, tileSize = 0, edgeSize = 16, 
			insets = { left = 0, right = 0, top = 0, bottom = 0 }
		})
		MUI_COMBO_DROPDOWN:SetFrameStrata("DIALOG")
		MUI_COMBO_DROPDOWN:SetFrameLevel(5)
		MUI_COMBO_DROPDOWN:SetBackdropColor(0,0,0,1)
		MUI_COMBO_DROPDOWN:SetScript("OnUpdate", function (this, elapsed)
			if(this.dt == nil) then this.dt = 0 end
			if(MouseIsOver(this) or MouseIsOver(this.PARENT)) then
				this.dt = 0
			else
				this.dt = this.dt + elapsed
				if(this.dt >= .25) then 
					this:Hide()
					this.dt = 0
				end
			end
		end)

		MUI_COMBO_DROPDOWN.FIELDS = {}
		for index=1, 20 do
			MUI_COMBO_DROPDOWN.FIELDS[index] = CreateFrame("Button", nil, MUI_COMBO_DROPDOWN)
			MUI_COMBO_DROPDOWN.FIELDS[index].index = index
			MUI_COMBO_DROPDOWN.FIELDS[index]:SetScript("OnClick", function (this, button)
				if(MUI_COMBO_DROPDOWN.CALLBACK and MUI_COMBO_DROPDOWN._VALUES) then 
					local value = MUI_COMBO_DROPDOWN._VALUES[this.index]
					MUI_COMBO_DROPDOWN.CALLBACK(MUI_COMBO_DROPDOWN.PARENT, this.index, value) 
				end
				MUI_COMBO_DROPDOWN:Hide()
				MUI_COMBO_DROPDOWN.dt = 0
			end)

			local highlight = MUI_COMBO_DROPDOWN.FIELDS[index]:CreateTexture()
			highlight:SetPoint("TOPLEFT", MUI_COMBO_DROPDOWN.FIELDS[index], "TOPLEFT", 1, -1)
			highlight:SetPoint("BOTTOMRIGHT", MUI_COMBO_DROPDOWN.FIELDS[index], "BOTTOMRIGHT", -1, 1)
			highlight:SetTexture(.5, .5, .5, .1)

			MUI_COMBO_DROPDOWN.FIELDS[index]:SetHighlightTexture(highlight)
		end

		MUI_COMBO_DROPDOWN:Hide()
	end

	local function MUI_COMBO_SET_VALUES(combobox, values, combo_type)
		MUI_COMBO_DROPDOWN._VALUES = values
		local height = 0
		local last = MUI_COMBO_DROPDOWN
		local offset = 0
		for index, field in ipairs(MUI_COMBO_DROPDOWN.FIELDS) do
			local value = values[index]
			if(values[index]) then
				field:SetPoint("TOPLEFT", last, "TOPLEFT", 0, offset)
				field:SetPoint("TOPRIGHT", last, "TOPRIGHT", 0, offset)
				if(combo_type == "FONT") then
					field:SetNormalTexture("")
					field:SetFont(value, combobox.value_height - 4)
					local _,_,fontfile = strfind(value, "([^\\]+)[.]") 
					if(fontfile) then field:SetText(fontfile) end
				elseif(combo_type == "TEXTURE") then
					field:SetFont("Interface\\Addons\\minimalUI\\Fonts\\visitor1.ttf", 12, "OUTLINE")
					field:SetText("")
					field:SetNormalTexture(value)
					local _,_,texturefile = strfind(value, "([^\\]+)[.]") 
					if(texturefile) then field:SetText(texturefile) end			
				else
					field:SetFont("Interface\\Addons\\minimalUI\\Fonts\\visitor1.ttf", 12)
					field:SetText(value)
				end
				field:SetHeight(combobox.value_height)
				field:Show()

				height = height + combobox.value_height
				last   = field
				offset = -combobox.value_height
			else
				field:Hide()
			end
		end	
		MUI_COMBO_DROPDOWN:SetHeight(height)
	end

	-- Where callback gets this parameters passed CALLBACK(self, index, value)
	local function MUI_COMBO_SET_CALLBACK(parent, callback)
		MUI_COMBO_DROPDOWN.CALLBACK = callback
		MUI_COMBO_DROPDOWN.PARENT   = parent
	end

	local function MUI_COMBO_SET_BACKDROPCOLOR(r,g,b,a)
		MUI_COMBO_DROPDOWN:SetBackdropColor(r,g,b,a-.05)
	end

	local function MUI_COMBO_SHOW(cbx)
		MUI_COMBO_DROPDOWN:SetPoint("TOPLEFT", cbx, "BOTTOMLEFT")
		MUI_COMBO_DROPDOWN:SetPoint("TOPRIGHT", cbx, "BOTTOMRIGHT")
		MUI_COMBO_DROPDOWN:Show()
	end

	-----------------------------------------------------------------
	
	local combobox = CreateFrame("Button", nil, parent)
	combobox:SetFont("Interface\\Addons\\minimalUI\\Fonts\\visitor1.ttf", 16, "OUTLINE")
	combobox.callback = callback
	combobox.combo_type = combo_type
	combobox.SetValueHeight = function (self, height)
		self.value_height = height
	end
	combobox:SetValueHeight(18)
	combobox:SetBackdrop({ 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "", 
		tile = false, tileSize = 0, edgeSize = 16, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	combobox:SetScript("OnClick", function ()
		MUI_COMBO_SET_BACKDROPCOLOR(this:GetBackdropColor())
		MUI_COMBO_SET_CALLBACK(this, this.callback)
		if(this.combo_type == "FONT") then
			MUI_COMBO_SET_VALUES(this, MUI_GLOBAL_FONT_TABLE, "FONT", this.value_height)
		elseif(this.combo_type == "TEXTURE") then
			MUI_COMBO_SET_VALUES(this, MUI_GLOBAL_TEXTURE_TABLE, "TEXTURE", this.value_height)
		else
			mUI_DebugMessage("unsupported dropdown type: " .. this.combo_type)
		end
		MUI_COMBO_SHOW(this)
	end)

	return combobox
end
