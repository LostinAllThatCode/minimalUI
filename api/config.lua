--
--
-- CONFIG V2
-- 
-- 

local function _mUI_SetVariableGroup(var, group_name)
	var.vtype  = "GROUP"
	var.name   = group_name
	var.value  = {}
end

local function _mUI_SetVariable(var, name, vtype, data, fqvn)
	var.vtype  = strupper(vtype)
	var.name   = name
	if(type(data) == "table") then
		var.value  = mUI_CopyTable(data)
	else
		var.value  = data
	end
	if(fqvn) then var.fqvn = fqvn end
end

function mUI_SetVariable(module, name, vtype, data)
	local groups      = { strsplit("|", name) }
	local group_count = #(groups)
	local variable    = mui_config[module.name] 
	if( variable == nil) then mUI_DebugError("Variable data is not valid") return end
	for index, group_name in pairs(groups) do
		if(variable[group_name] == nil) then
			if(group_count ~= index) then
				variable[group_name] = {}
				_mUI_SetVariableGroup(variable[group_name], group_name)
				variable = variable[group_name].value
			else
				variable[group_name] = {}
				_mUI_SetVariable(variable[group_name], group_name, vtype, data, name)
				return 0
			end
		else
			if(group_count == index) then
				_mUI_SetVariable(variable[group_name], group_name, vtype, data, name)
			else
				variable = variable[group_name].value
			end
		end
	end
end

function mUI_GetVariable(module, name)
	local groups      = { strsplit("|", name) }
	local group_count = #(groups)
	local variable    = mui_config[module.name]
	if( variable == nil) then mUI_DebugError("Variable data is not valid") return end

	for index, group_name in pairs(groups) do
		if(group_count == index) then
			return variable[group_name]
		else
			if(variable[group_name] == nil) then
				mUI_DebugError("Can't find variable group for " .. group_name .. " [name="..name.."]")
			end
			variable = variable[group_name].value
		end
	end
end

function mUI_GetVariableValueByName(module, name)
	local var = mUI_GetVariable(module, name)
	if(var == nil) then mUI_DebugError(name .. " does not exist in "..module.name) end
	return mUI_GetVariable(module, name).value
end

function mUI_GetVariableFQVN(module, var)
	return module.name .. var.fqvn
end

function mUI_VariableTypeEquals(var, vtype)
	return (var.vtype == strupper(vtype))
end

function mUI_VariableNameEquals(var, name)
	return (var.name == name)
end

function mUI_GetVariableValue(var)
	return var.value
end

-- callback get called like this callback( config, var )
function mUI_GetVariableRecursiveCallback(config, callback,  ...)
	for varname in pairs(config) do
		local var  = config[varname]
		callback(config, var, ...)
		if(var.vtype == "GROUP") then
			mUI_GetVariableRecursiveCallback(config[varname].value, callback, ...)
		end
	end
end

function mUI_GetVariableRecursiveCallbackSortedByKeys(config, callback, ...)
	for varname in pairsByKeys(config) do
		local var  = config[varname]
		callback(config, var, ...)
		if(var.vtype == "GROUP") then
			mUI_GetVariableRecursiveCallback(config[varname].value, callback, ...)
		end
	end
end

function mUI_CopyTable(src)
  local lookup_table = {}
  local function _copy(src)
    if type(src) ~= "table" then
      return src
    elseif lookup_table[src] then
      return lookup_table[src]
    end
    local new_table = {}
    lookup_table[src] = new_table
    for index, value in pairs(src) do
      new_table[_copy(index)] = _copy(value)
    end
    return setmetatable(new_table, getmetatable(src))
  end
  return _copy(src)
end

local function mUI_ConfigInitDB(version)
	mui_global = {}
	mui_global["VERSION"]  = {}
	_mUI_SetVariable(mui_global["VERSION"], "VERSION", "STRING", version)
	mui_global["DEBUG"]  = {}
	_mUI_SetVariable(mui_global["DEBUG"], "DEBUG", "BOOLEAN", false)
	mui_global["ClassColors"]  = {}
	_mUI_SetVariable(mui_global["ClassColors"], "ClassColors", "CLASS_COLORS", 
		{
   		["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43, a = 1 },
   		["MAGE"] 	= { r = 0.41, g = 0.8,  b = 0.94, a = 1 },
   		["ROGUE"] 	= { r = 1, 	  g = 0.96, b = 0.41, a = 1 },
   		["DRUID"] 	= { r = 1,    g = 0.49, b = 0.04, a = 1 },
   		["HUNTER"] 	= { r = 0.67, g = 0.83, b = 0.45, a = 1 },
   		["SHAMAN"] 	= { r = 0.14, g = 0.35, b = 1.0,  a = 1 },
   		["PRIEST"] 	= { r = 0.85, g = 0.85, b = 0.85, a = 1 },
   		["WARLOCK"] = { r = 0.58, g = 0.51, b = 0.79, a = 1 },
   		["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73, a = 1 }
		}
	)
	mui_global["PowerColors"] = {}
	_mUI_SetVariable(mui_global["PowerColors"], "PowerColors", "POWER_COLORS", 
		{
   		{ r = 0.41, g = 0.8,  b = 0.94, a = 1 }, -- MANA
   		{ r = 0.8,  g = 0.2,  b = 0.2,  a = 1 }, -- RAGE
   		{ r = 1, 	g = 0.5,  b = 0.25, a = 1 }, -- FOCUS
   		{ r = 1, 	g = 0.96, b = 0.41, a = 1 }	 -- ENERGY
		}
	)	
	mui_global["Pixel_Perfect_Mode"] = {}
	_mUI_SetVariable(mui_global["Pixel_Perfect_Mode"], "Pixel_Perfect_Mode", "BOOLEAN", GetCVar("UseUIScale"))

	if(mui_global["Profiles"] == nil) then mui_global["Profiles"] = {} end
end

function mUI_ConfigInitialize(mod_version)	
	local is_db_old = false
	if not mui_global or is_db_old then   -- TODO: REMOVE IN RELEASE
		mUI_ConfigInitDB(mod_version)
		mUI_DebugMessage("Initializing minimalUI. New SavedVariables are created.")
	else
		local db_version = "0.0.0"
		if(mui_global["VERSION"]) then
			db_version = mui_global["VERSION"].value
		end
		is_db_old = (db_version<mod_version)
		if(is_db_old) then
			mUI_ConfigInitDB(mod_version)
			mUI_DebugMessage("An older version of this mod was detected! SavedVariables will be resetted.")
		else
			mUI_DebugMessage("mUI_global_db exists already. db_version == mod_version")
		end
	end

	-- Initialize per character config
	if not mui_config or is_db_old then
		mUI_DebugMessage("Character config created |cffffff22"..UnitName("player"))
		mui_config = {}
		mui_config["VERSION"]  = {}
		_mUI_SetVariable(mui_config["VERSION"], "VERSION", "STRING", mod_version)
	else
		local db_user_version = "0.0.0"
		if(mui_config["VERSION"]) then
			db_user_version = mui_config["VERSION"].value
		end
		is_db_old = (db_user_version<mod_version)
		if(is_db_old) then
			mUI_DebugMessage("SavedVariables reset for " .. UnitName("player") .. ".")
			mui_config["VERSION"]  = {}
			_mUI_SetVariable(mui_config["VERSION"], "VERSION", "STRING", mod_version)
		else
			mUI_DebugMessage("mUI_user_db exists already. db_user_version == mod_version")
		end
	end
end

---
-- UI STUFF
-- 
-- 

function mUI_GenerateConfigFrame()
	local version = "0.0.0"
	if(mui_global["VERSION"]) then
	 	version = mui_global["VERSION"].value
	 end
   	local inline_backdrop = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "", 
		tile = false, tileSize = 0, edgeSize = 0, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}

	local title_font = "Interface\\AddOns\\minimalUI\\fonts\\visitor1.ttf"

	local mainframe  = mUI_CreateDefaultFrame(nil, "mConfigFrame", 800, 600, "DIALOG")
	mainframe.tabs 	 = {}
	mainframe:SetMovable(true)
	mainframe:EnableMouse(true)
	mainframe:RegisterForDrag("LeftButton")
	mainframe:SetScript("OnDragStart", function() this:StartMoving() end)
	mainframe:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)

	local function SetContent(scrollframe, tab_index)
		local prev_tab  = scrollframe:GetScrollChild()
		local tab 		= mainframe.tabs[tab_index]
		if(tab ~= nil)
		then
			if(prev_tab ~= nil and prev_tab ~= tab) then 
				prev_tab:Hide()
			end
			scrollframe:SetScrollChild(tab)
			scrollframe:SetVerticalScroll(0)
			tab:Show()
		else
			mUI_DebugError("Selected tab has no gui!")
		end	
	end

	mainframe.title = mUI_CreateDefaultFrame(mainframe, nil, 596, 18, "DIALOG", inline_backdrop)
	mainframe.title:ClearAllPoints()
	mainframe.title:SetPoint("TOPLEFT", mainframe, "TOPLEFT", 0, 0)
	mainframe.title:SetPoint("BOTTOMRIGHT", mainframe, "TOPRIGHT", 0, -18)
	mainframe.title:SetBackdropColor(0.20,0.20,0.20,1.00)
	mainframe.title.text = mUI_FontString(mainframe.title, title_font, 14, nil, " minimalUI - configuration gui - v"..version.." (beta)", "CENTER", "LEFT")

	mainframe.close = mUI_CreateDefaultButton(mainframe.title, nil, "X", 32, 16, 12)
	mainframe.close:ClearAllPoints()
	mainframe.close:SetBackdropColor(0.70,0.20,.20,1.00)
	mainframe.close:SetPoint("TOPRIGHT", mainframe.title, "TOPRIGHT", -1, -1)
	mainframe.close:SetScript("OnClick", function () mainframe:Hide() end)

	mainframe.sizing = mUI_CreateDefaultButton(mainframe.title, nil, "<|>", 32, 16, 12)
	mainframe.sizing:ClearAllPoints()
	mainframe.sizing:SetBackdropColor(0.12,0.12,0.12,1.00)
	mainframe.sizing:SetTextColor(0.0,0.50,0.75,1.00)
	mainframe.sizing:SetPoint("TOPRIGHT", mainframe.close, "TOPLEFT", -1, 0)
	mainframe.sizing:SetScript("OnClick", function () if(mainframe:GetHeight() == 600) then mainframe:SetHeight(250) else mainframe:SetHeight(600) mainframe.scrollframe:SetVerticalScroll(0) end end)

	mainframe.help = mUI_CreateDefaultButton(mainframe.title, nil, "?", 32, 16, 12)
	mainframe.help:ClearAllPoints()
	mainframe.help:SetBackdropColor(0.12,0.12,0.12,1.00)
	mainframe.help:SetTextColor(0.75,0.75,0.0,1.00)
	mainframe.help:SetPoint("TOPRIGHT", mainframe.sizing, "TOPLEFT", -1, 0)
	mainframe.help:SetScript("OnClick", function () SetContent(mainframe.scrollframe, 1)  end)

	mainframe.global = mUI_CreateDefaultButton(mainframe, nil, "GLOBAL", 120, 18)
	mainframe.global:SetBackdropBorderColor(.8, .8, .8, 1.0)
	mainframe.global:ClearAllPoints()
	mainframe.global:SetPoint("TOPLEFT", mainframe, "TOPLEFT", 15, -25)
	mainframe.global:SetScript("OnClick", function() SetContent(mainframe.scrollframe, 2) end)

	mainframe.scrollframe = CreateFrame("ScrollFrame", "mConfigFrameScrollFrame", mainframe)
	mainframe.scrollframe:SetPoint("TOPLEFT", mainframe, "TOPLEFT", 150, -25)
   	mainframe.scrollframe:SetPoint("BOTTOMRIGHT", mainframe, "BOTTOMRIGHT", 0, 5)
   	mainframe.scrollframe:EnableMouseWheel(1)
   	mainframe.scrollframe:SetScript("OnMouseWheel", function()
   		local stepsize	= 20
   		local current 	= this:GetVerticalScroll()
   		local max 	  	= this:GetScrollChild():GetHeight()
   		local direction = arg1 * -1
   		local dest 		= current + (stepsize * direction)
   		if(dest >= 0 and dest < (max - this:GetHeight() + stepsize)) then this:SetVerticalScroll(dest) end
   	end)

   	local infoframe = mUI_CreateDefaultFrame(mainframe, "mConfigFrameFirstFrame", mainframe:GetWidth() -155, 400, "DIALOG", inline_backdrop)
   	infoframe.info  = mUI_FontString(infoframe, nil, 14)
   	infoframe.info:SetJustifyV("TOP")
   	infoframe.info:SetJustifyH("LEFT")
   	infoframe.info:SetText("Welcome to the minimalUI configuration gui.\n\n" ..
   		"Press the |cffffff00?|r button in the top right corner to get back to this view.\n\n" ..
   		"Press the |cff0088FF<|>|r button in the top right corner to make this window smaller/bigger.\n\n" ..
   		"Press one of the buttons on the left side to get to the specific settings tab.\n" ..
   		"\n" ..
   		"If you have any suggestions or bugs please visit the following website and create an enhancement/issue on the ISSUES tab!\n\n"..
   		"|cff00BB00https://github.com/LostinAllThatCode/minimalUI|r\n\n" ..
   		"** IMPORTANT:\n\n"..
   		"Module |cff0088FF[UNITFRAMES]|r\n\n  Available text fields for \"Bar Text\":\n\n"..
   		"  $hp               - current health\n"..
   		"  $hpmax            - current maximum health\n"..
   		"  $mp               - current mana\n"..
   		"  $mpmax            - current maximum mana\n"..
   		"  $class            - current class\n"..
   		"  $classification   - WORLDBOSS, RARE, ELITE or RAREELITE\n"..
   		"  $level            - current level\n"..
   		"  $happiness        - current happiness (PET ONLY)\n"..
   		"  ------------------------------------------------\n"..
   		"  $CC               - colors following text in class color (use ||r to stop coloring)\n\n"..
   		"  You can also define colors by the ||cAARRGGBB tag and clear the color by ||r\n"..
   		"    Ex.: \n      ||cFF00FF00$level||r $name || Result: |cff00ff0070|r Thrall"
   		)
   	table.insert(mainframe.tabs, infoframe)

	local height = 1;
	local frame = mUI_CreateDefaultFrame(scrollframe, "mConfigFrameGlobalFrame", mainframe:GetWidth() -155, height, "DIALOG", inline_backdrop)
	frame:Hide()
	for entry in pairsByKeys(mui_global)
	do
		height = mUI_CreateConfigItem(mui_global[entry], frame, height, mUI)
	end	
	frame:SetHeight(height)
	table.insert(mainframe.tabs, frame)

   	local tab_index_start = 3
   	local prev_button     = mainframe.global
   	for v in pairs(mUI.modules) do
   		local module = mUI.modules[v]
   		local button = mUI_CreateDefaultButton(mainframe, nil, strupper(module.name), 120, 18)
   		button.id 	 = tab_index_start 
		button:SetBackdropBorderColor(.8, .8, .8, 1.0)
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", prev_button, "BOTTOMLEFT", 0, -5)
		button:SetScript("OnClick", function() SetContent(mainframe.scrollframe, this.id) end)

		local height = 1;
		local frame = mUI_CreateDefaultFrame(scrollframe, "mConfigFrame"..strupper(module.name).."Frame", mainframe:GetWidth() -155, height, "DIALOG", inline_backdrop)
		frame:Hide()

		if(mUI_GetVariableValueByName(module, "Menu0|Enabled") == true) then
			for entry in pairsByKeys(module.config)
			do
				height = mUI_CreateConfigItem(module.config[entry], frame, height, module)
			end	
		else
			height = mUI_CreateConfigItem(mUI_GetVariable(module, "Menu0|Enabled"), frame, height, module)
		end

		frame:SetHeight(height)
		table.insert(mainframe.tabs, frame)
		tab_index_start = tab_index_start + 1
   	end
	mainframe.scrollframe:SetScrollChild(infoframe)

   	-- TODO: remove in release
   	if(false) then
   		infoframe:Hide()
   		local tab = mainframe.tabs[#mainframe.tabs]
   		tab:Show()
		mainframe.scrollframe:SetScrollChild(tab)
	end
	-- ########################
   	
	return mainframe
end

function mUI_CreateConfigItem(entry, parent, current_height, module)
	local group_backdrop = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "Interface\\AddOns\\minimalUI\\img\\BorderShadow.tga", 
		tile = false, tileSize = 0, edgeSize = 16, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}

	local item_backdrop = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "", 
		tile = false, tileSize = 0, edgeSize = 16, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}

	local result_height = current_height or 0
	if(entry.vtype == "GROUP")
	then	
		if(strfind(entry.name, "Menu") ~= nil) then
			local group_height = result_height

			for subvar in pairsByKeys(entry.value) do
				group_height = mUI_CreateConfigItem(entry.value[subvar], parent, group_height, module)
			end

			local final_height = group_height - result_height
			if(final_height > 0)
			then
				result_height = group_height + 8
			end
		else
			local item = mUI_CreateDefaultFrame(parent, nil, parent:GetWidth()-22, 0, "DIALOG", item_backdrop)
			item:SetBackdropColor(.2, .2, .2, .75)

			item:ClearAllPoints()
			item:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, current_height * -1)
			item:SetHeight(16)
			item.text = mUI_FontString(item, "Interface\\Addons\\minimalUI\\Fonts\\LiberationMono-Bold.ttf", 14, nil, strupper(gsub(entry.name,"_", " ")), "TOP", "LEFT")
			item.text:SetPoint("TOPLEFT", item, "TOPLEFT", 2, -4)
			item.text:SetTextColor(.9,.9,.2, 1)

			local group_height = result_height + 18
			for subvar in pairsByKeys(entry.value) do
				group_height = mUI_CreateConfigItem(entry.value[subvar], parent, group_height, module, t)
			end

			local final_height = group_height - result_height - 18
			if(final_height > 0)
			then
				item:SetHeight(final_height + 18)
				result_height = group_height
			end
		end
	elseif(entry.vtype == "NUMBERFIELD")
	then
		result_height = mUI_CreateConfigItemNumberfield(entry, parent, current_height, module)
	elseif(entry.vtype == "TEXTFIELD" or entry.vtype == "TEXTURE")
	then
		result_height = mUI_CreateConfigItemTextfield(entry, parent, current_height, module)

	elseif(entry.vtype == "BGCOLOR" or entry.vtype == "BORDERCOLOR" or entry.vtype == "TEXTCOLOR")
	then
		result_height = mUI_CreateConfigItemColor(entry, parent, current_height, module)
	elseif(entry.vtype == "BOOLEAN")
	then
		result_height = mUI_CreateConfigItemBoolean(entry, parent, current_height, module)
	elseif(entry.vtype == "BACKDROP")
	then
		result_height = mUI_CreateConfigItemBackdrop(entry, parent, current_height, module)
	elseif(entry.vtype == "STRATA")
	then
		result_height = mUI_CreateConfigItemStrata(entry, parent, current_height, module)
	elseif(entry.vtype == "FONTSTYLE")
	then
		result_height = mUI_CreateConfigItemFontStyle(entry, parent, current_height, module)		
	elseif(entry.vtype == "DYNAMIC_COLOR")
	then
		result_height = mUI_CreateConfigItemDynamicColor(entry, parent, current_height, module)
	elseif(entry.vtype == "COMBOFONT")
	then
		result_height = mUI_CreateConfigItemComboFont(entry, parent, current_height, module)
	elseif(entry.vtype == "COMBOTEXTURE")
	then
		result_height = mUI_CreateConfigItemComboTexture(entry, parent, current_height, module)
	else
		--mUI_DebugMessage("unhandled type specifier: " .. entry.vtype)
	end
	return result_height
end

function mUI_CreateConfigItemNumberfield(var, parent, current_y, module)
	local item_backdrop = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "", 
		tile = false, tileSize = 0, edgeSize = 16, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}

	local value = mUI_CreateDefaultEditbox(parent, var.value, 100, 0, "TOP", "RIGHT")
	value:SetNumeric(true)
	value:SetBackdropColor(.1,.1,.1,1)
	value:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -17, current_y *-1)
	value:SetHeight(24)
	value:SetAutoFocus(false)

	value:SetScript("OnEnterPressed", function() 
		var.value = this:GetNumber()
		if(module) then module:VariableChanged(var) end
		this:ClearFocus()
	end)

	local item = mUI_CreateDefaultFrame(parent, nil, 0, 0, "DIALOG", item_backdrop)
	item:ClearAllPoints()
	item:SetBackdropColor(.13,.13,.13,1)
	item:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, current_y * -1)
	item:SetPoint("BOTTOMRIGHT", value, "BOTTOMLEFT", -1, 0)
	item:SetHeight(24)
	item.text = mUI_FontString(item, nil, 14, nil, gsub(var.name,"_", " "), "CENTER", "LEFT")
	item.text:SetPoint("TOPLEFT", item, "TOPLEFT", 8, -1)
	
	return current_y + 25
end

function mUI_CreateConfigItemTextfield(var, parent, current_y, module)
	local item_backdrop = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "", 
		tile = false, tileSize = 0, edgeSize = 16, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}

	local value = mUI_CreateDefaultEditbox(parent, var.value, 300, 0, "TOP", "RIGHT")
	value:SetBackdropColor(.1,.1,.1,1)
	value:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -17, current_y *-1)
	value:SetHeight(24)
	value:SetAutoFocus(false)

	value:SetScript("OnEnterPressed", function() 
		var.value = this:GetText()
		if(module) then module:VariableChanged(var) end
		this:ClearFocus()
	end)

	local item = mUI_CreateDefaultFrame(parent, nil, 0, 0, "DIALOG", item_backdrop)
	item:ClearAllPoints()
	item:SetBackdropColor(.13,.13,.13,1)
	item:SetBackdropColor(.13,.13,.13,1)
	item:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, current_y * -1)
	item:SetPoint("BOTTOMRIGHT", value, "BOTTOMLEFT", -1, 0)
	item:SetHeight(24)
	item.text = mUI_FontString(item, nil, 14, nil, gsub(var.name,"_", " "), "CENTER", "LEFT")
	item.text:SetPoint("TOPLEFT", item, "TOPLEFT", 8, -1)

	return current_y + 25
end

function mUI_CreateConfigItemBoolean(var, parent, current_y, module)
	local item_backdrop = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "", 
		tile = false, tileSize = 0, edgeSize = 16, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}

	local checkbox = mUI_CreateCheckButton(parent)
	checkbox:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -16, -1 * current_y)
	checkbox:SetBackdrop(item_backdrop)
	checkbox:SetBackdropColor(.12,.12,.12,1)
	checkbox:SetWidth(32)
	checkbox:SetHeight(24)
	checkbox:SetChecked(var.value)
	checkbox:SetScript("OnClick", function ()
		var.value = (this:GetChecked() == 1)
		if(module) then module:VariableChanged(var) end
	end)

	local item = mUI_CreateDefaultFrame(parent, nil, 0, 0, "DIALOG", item_backdrop)
	item:ClearAllPoints()
	item:SetBackdropColor(.13,.13,.13,1)
	item:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, current_y * -1)
	item:SetPoint("BOTTOMRIGHT", checkbox, "BOTTOMLEFT", -1, 0)
	item:SetHeight(24)
	item.text = mUI_FontString(item, nil, 14, nil, gsub(var.name,"_", " "), "CENTER", "LEFT")
	item.text:SetPoint("TOPLEFT", item, "TOPLEFT", 8, -1)
	
	return current_y + 25
end

function mUI_CreateConfigItemStrata(var, parent, current_y, module)
	local item_backdrop = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "", 
		tile = false, tileSize = 0, edgeSize = 0, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}

	local selected_color = { r=0.0, g=0.5, b=1.0, a=1 }
	local normal_color   = { r=0.12, g=0.12, b=0.12, a=1 }

	local highlightcolor = { r=0.78, g=0.29, b=0.00, a=1 }
	local last_btn = parent
	local STRATA_TABLE = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG" }
	local last_sel_btn = nil
	for i, strata in ipairs(STRATA_TABLE)
	do
		local btn  = mUI_CreateDefaultButton(parent, nil, strata, 65, 24, 10)
		btn:ClearAllPoints()
		btn:SetWidth(btn:GetTextWidth() + 20)
		if(var.value == strata)
		then
			btn:SetBackdropColor(mUI_GetColor(selected_color))
			btn:SetTextColor(0.0, 0.0, 0.0, 1.0)
			last_sel_btn = btn
		else
			btn:SetBackdropColor(mUI_GetColor(normal_color))
			btn:SetTextColor(1.0, 1.0, 1.0, 1.0)
		end
		if(last_btn == parent) then
			btn:SetPoint("TOPRIGHT", last_btn, "TOPRIGHT", -17, -1 * current_y)
		else
			btn:SetPoint("TOPRIGHT", last_btn, "TOPLEFT", -1, 0)
		end
		btn:SetScript("OnClick", function ()
			if(last_sel_btn ~= nil)
			then
				last_sel_btn:SetBackdropColor(mUI_GetColor(normal_color))
				last_sel_btn:SetTextColor(1.0, 1.0, 1.0, 1.0)
			end
			var.value = strata

			if(module) then module:VariableChanged(var) end

			btn:SetBackdropColor(mUI_GetColor(selected_color))
			btn:SetTextColor(0.0, 0.0, 0.0, 1.0)
			last_sel_btn = this
		end)
		last_btn = btn
	end
	local item = mUI_CreateDefaultFrame(parent, nil, 0, 0, "DIALOG", item_backdrop)
	item:ClearAllPoints()
	item:SetBackdropColor(.13,.13,.13,1)
	item:SetBackdropColor(.13,.13,.13,1)
	item:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, current_y * -1)
	item:SetPoint("BOTTOMRIGHT", last_btn, "BOTTOMLEFT", -1, 0)
	item:SetHeight(24)
	item.text = mUI_FontString(item, nil, 14, nil, gsub(var.name,"_", " "), "CENTER", "LEFT")
	item.text:SetPoint("TOPLEFT", item, "TOPLEFT", 8, -1)
	
	return current_y + 25
end

function mUI_CreateConfigItemDynamicColor(var, parent, current_y, module)
	local item_backdrop = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "", 
		tile = false, tileSize = 0, edgeSize = 16, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}

	local selected_color = { r=0.0, g=0.5, b=1.0, a=1 }
	local normal_color   = { r=0.12, g=0.12, b=0.12, a=1 }

	local highlightcolor = { r=0.78, g=0.29, b=0.00, a=1 }
	local last_btn = parent
	local DYNAMIC_COLOR_TABLE = { "CUSTOM", "CLASS", "POWER" }
	local last_sel_btn = nil
	for i, dyncolor in ipairs(DYNAMIC_COLOR_TABLE)
	do
		local btn  = mUI_CreateDefaultButton(parent, nil, dyncolor, 53, 24, 10)
		btn:ClearAllPoints()
		btn:SetWidth(btn:GetTextWidth() + 20)
		if(var.value == dyncolor)
		then
			btn:SetBackdropColor(mUI_GetColor(selected_color))
			btn:SetTextColor(0.0, 0.0, 0.0, 1.0)
			last_sel_btn = btn
		else
			btn:SetBackdropColor(mUI_GetColor(normal_color))
			btn:SetTextColor(1.0, 1.0, 1.0, 1.0)
		end
		if(last_btn == parent) then
			btn:SetPoint("TOPRIGHT", last_btn, "TOPRIGHT", -17, -1 * current_y)
		else
			btn:SetPoint("TOPRIGHT", last_btn, "TOPLEFT", -1, 0)
		end
		btn:SetScript("OnClick", function ()
			if(last_sel_btn ~= nil)
			then
				last_sel_btn:SetBackdropColor(mUI_GetColor(normal_color))
				last_sel_btn:SetTextColor(1.0, 1.0, 1.0, 1.0)
			end
			var.value = dyncolor
			if(module) then module:VariableChanged(var) end

			btn:SetBackdropColor(mUI_GetColor(selected_color))
			btn:SetTextColor(0.0, 0.0, 0.0, 1.0)
			last_sel_btn = this
		end)
		last_btn = btn
	end
	local item = mUI_CreateDefaultFrame(parent, nil, 0, 0, "DIALOG", item_backdrop)
	item:ClearAllPoints()
	item:SetBackdropColor(.13,.13,.13,1)
	item:SetBackdropColor(.13,.13,.13,1)
	item:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, current_y * -1)
	item:SetPoint("BOTTOMRIGHT", last_btn, "BOTTOMLEFT", -1, 0)
	item:SetHeight(24)
	item.text = mUI_FontString(item, nil, 14, nil, gsub(var.name,"_", " "), "CENTER", "LEFT")
	item.text:SetPoint("TOPLEFT", item, "TOPLEFT", 8, -1)
	
	return current_y + 25
end

function mUI_CreateConfigItemColor(var, parent, current_y, module)
	local item_backdrop = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "", 
		tile = false, tileSize = 0, edgeSize = 16, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}

	local callback = function(self, r, g, b, a)
		var.value = {r=r, g=g, b=b, a=a}
		if(module) then module:VariableChanged(var) end
		self.hexpanel:SetText(mUI_HexFromColors(a,r,g,b))
	end

	local color_picker       = mUI_CreateColorPicker(parent, callback, 100, 0, var.value)
	color_picker:ClearAllPoints()
	color_picker:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -17, current_y *-1)
	color_picker:SetHeight(24)

	local hex_editbox       = mUI_CreateDefaultEditbox(parent, mUI_HexFromColorTable(var.value), 98, 0, "TOP", "LEFT")
	hex_editbox:ClearAllPoints()
	hex_editbox:SetBackdropColor(.12,.12,.12,1)
	hex_editbox:SetPoint("TOPRIGHT", color_picker, "TOPLEFT", -1, 0)
	hex_editbox:SetHeight(24)
	hex_editbox:SetScript("OnEnterPressed", function()		
		local a,r,g,b = mUI_HexToARGBFloats(this:GetText())
		var.value = {r=r, g=g, b=b, a=a}
		if(module) then module:VariableChanged(var) end
		hex_editbox.picker:SetBackdropColor(r,g,b,a)
	end)
	hex_editbox.picker = color_picker
	color_picker.hexpanel = hex_editbox

	local item = mUI_CreateDefaultFrame(parent, nil, 0, 0, "DIALOG", item_backdrop)
	item:ClearAllPoints()
	item:SetBackdropColor(.13,.13,.13,1)
	item:SetBackdropColor(.13,.13,.13,1)
	item:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, current_y * -1)
	item:SetPoint("BOTTOMRIGHT", hex_editbox, "BOTTOMLEFT", -1, 0)
	item:SetHeight(24)
	item.text = mUI_FontString(item, nil, 14, nil, gsub(var.name,"_", " ") .. " [#AARRGGBB]", "CENTER", "LEFT")
	item.text:SetPoint("TOPLEFT", item, "TOPLEFT", 8, -1)

	return current_y + 25
end

function mUI_CreateConfigItemComboFont(var, parent, current_y, module)
	local function myCallback(self, index, value)
		local fontfull = value
		if(fontfull) then
			var.value = value
			if(module) then module:VariableChanged(var) end

			self:SetFont(fontfull, 12)
			local _,_,fontfile = strfind(fontfull, "([^\\]+)[.]") 
			if(fontfile) then
				self:SetText(fontfile)
			end
		end
	end

	local combo = mUI_ComboBox(parent, "FONT", myCallback)
	combo:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -16, -1 * current_y)
	combo:SetBackdropColor(.1,.1,.1,1)
	combo:SetWidth(200)
	combo:SetHeight(24)
	combo:SetValueHeight(14)

	combo:SetFont(var.value, 12)
	local _,_,fontfile = strfind(var.value, "([^\\]+)[.]") 
	if(fontfile) then combo:SetText(fontfile) end

	local item = mUI_CreateDefaultFrame(parent, nil, 0, 0, "DIALOG", item_backdrop)
	item:ClearAllPoints()
	item:SetBackdropColor(.13,.13,.13,1)
	item:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, current_y * -1)
	item:SetPoint("BOTTOMRIGHT", combo, "BOTTOMLEFT", -1, 0)
	item:SetHeight(16)
	item.text = mUI_FontString(item, nil, 14, nil, gsub(var.name,"_", " "), "CENTER", "LEFT")
	item.text:SetPoint("TOPLEFT", item, "TOPLEFT", 8, -1)

	return current_y + 25
end


function mUI_CreateConfigItemComboTexture(var, parent, current_y, module)
	local function myCallback(self, index, value)
		local texture_full = value
		if(texture_full) then
			var.value = value
			if(module) then module:VariableChanged(var) end
			self:SetNormalTexture(var.value)
			local _,_,texture = strfind(texture_full, "([^\\]+)[.]") 
			if(texture) then
				self:SetText(texture)
			end
		end
	end

	local combo = mUI_ComboBox(parent, "TEXTURE", myCallback)
	combo:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -16, -1 * current_y)
	combo:SetBackdropColor(.1,.1,.1,1)
	combo:SetWidth(200)
	combo:SetHeight(24)
	combo:SetValueHeight(24)
	combo:SetNormalTexture(var.value)
	local _,_,texture = strfind(var.value, "([^\\]+)[.]") 
	if(texture) then combo:SetText(texture) end

	local item = mUI_CreateDefaultFrame(parent, nil, 0, 0, "DIALOG", item_backdrop)
	item:ClearAllPoints()
	item:SetBackdropColor(.13,.13,.13,1)
	item:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, current_y * -1)
	item:SetPoint("BOTTOMRIGHT", combo, "BOTTOMLEFT", -1, 0)
	item:SetHeight(16)
	item.text = mUI_FontString(item, nil, 14, nil, gsub(var.name,"_", " "), "CENTER", "LEFT")
	item.text:SetPoint("TOPLEFT", item, "TOPLEFT", 8, -1)

	return current_y + 25
end