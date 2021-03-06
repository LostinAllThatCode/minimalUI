local unitframes = mUI:RegisterModule("unitframes")
local blizzard_ui_elements = { 	
	"PlayerFrame", "TargetFrame",
	"PartyMemberFrame1", "PartyMemberFrame2", 
	"PartyMemberFrame3", "PartyMemberFrame4" 
}

local MUI_UNITFRAMES_MAX_BUFFS   = 40
local MUI_UNITFRAMES_MAX_DEBUFFS = 40

unitframes.framelist = {}

local DEFAULT_BACKDROP = { 
	bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
	edgeFile = "Interface\\AddOns\\minimalUI\\img\\BorderShadow.tga", 
	tile = false, tileSize = 0, edgeSize = 16, insets = { left = 0, right = 0, top = 0, bottom = 0 } 
}	

local DEFAULT_BACKDROP_BORDERLESS = { 
	bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
	edgeFile = "", 
	tile = false, tileSize = 0, edgeSize = 16, insets = { left = 0, right = 0, top = 0, bottom = 0 } 
}

local function mUI_ParseText(self, text)
	local return_string = text
	return_string = gsub(return_string, '||','\124')
	return_string = gsub(return_string, '($CC)', mUI_HexFromColorTableToString(mUI_GetClassColor(self.entity)))
	return_string = gsub(return_string, "($name)", self.entitydata.name or "")
	return_string = gsub(return_string, "($hpmax)", self.entitydata.hpmax or "")
	return_string = gsub(return_string, "($hp)", self.entitydata.hp or "")
	return_string = gsub(return_string, "($mpmax)", self.entitydata.mpmax or "")
	return_string = gsub(return_string, "($mp)", self.entitydata.mp or "")
	return_string = gsub(return_string, "($level)", self.entitydata.level or "")
	return_string = gsub(return_string, "($classification)", self.entitydata.classification or "")
	return_string = gsub(return_string, "($class)", self.entitydata.class or "")
	return return_string
end

local function mUI_UnitframesGetComboPoints(self)
	self.entitydata.combopoints = GetComboPoints("player", "target")
	if(self.entitydata.combopoints > 0) then
		self.combobar:Show()
		local pointx = 0
		local Frame_Width = self:GetWidth()
		local combo_point_size = Frame_Width / 5
		for i, point in ipairs(self.combobar.points) do
			point:SetPoint("TOPLEFT", self.combobar, "TOPLEFT", pointx + 1, -2)
			point:SetPoint("BOTTOMLEFT", self.combobar, "BOTTOMLEFT", pointx + 1, 2)
			point:SetWidth(combo_point_size-2)
			if(i <= self.entitydata.combopoints) then
				point:Show()
			else
				point:Hide()
			end
			pointx = pointx + combo_point_size
		end
	else
		self.combobar:Hide()
	end
end
local function mUI_UnitframesGetBuffs(self)
	if(mUI_GetVariableValueByName(unitframes, "MenuA|General|Configuration_Mode") == false) then
		for slotindex, bufficon in ipairs(self.buffpanel.buffs) do
			local buff = { UnitBuff(self.entity, slotindex) }			
			if(buff[3]) then
				bufficon.icon:SetTexture(buff[3])
				bufficon:Show()
			else
				bufficon:Hide()
			end
			if(buff[4] ~= 1) then
				bufficon.count:SetText(buff[4])
			else
				bufficon.count:SetText("")
			end
		end

		for slotindex, bufficon in ipairs(self.debuffpanel.buffs) do
			local buff = { UnitDebuff(self.entity, slotindex) }
			if(buff[3]) then
				bufficon.icon:SetTexture(buff[3])
				bufficon:Show()
			else
				bufficon:Hide()
			end
			if(buff[4] ~= 1) then
				bufficon.count:SetText(buff[4])
			else
				bufficon.count:SetText("")
			end
		end
	else
		for slotindex, bufficon in ipairs(self.buffpanel.buffs) do
			if(slotindex > self.cfg.custom["Buff_Count"].value) then break end
			bufficon:Show()
			bufficon.icon:SetTexture("")
			bufficon.count:SetText(slotindex)
		end
		for slotindex, bufficon in ipairs(self.debuffpanel.buffs) do
			if(slotindex > self.cfg.custom["Debuff_Count"].value) then break end
			bufficon:Show()
			bufficon.icon:SetTexture("")
			bufficon.count:SetText(slotindex)
		end
	end
end

local function mUI_UnitframesAttachConfig(self, frame_layout, bars_layout, custom_layout)
	if(self.cfg == nil) then self.cfg = {} end
	self.cfg.frame  = frame_layout
	self.cfg.bars   = bars_layout
	self.cfg.custom = custom_layout
end

local function mUI_UnitFramesUpdateBars(self)

	if(mUI_GetVariableValueByName(unitframes, "MenuA|General|Configuration_Mode") == false) then
		if(self.entitydata.isdead) then
			self.hp.lt:SetText( " " .. self.entitydata.name)
			self.hp.rt:SetText( "DEAD ")
			self.power.lt:SetText( " " )
			self.power.rt:SetText( " " )
		elseif(self.entitydata.isghost) then
			self.hp.lt:SetText( " " .. self.entitydata.name)
			self.hp.rt:SetText( "GHOST ")
			self.power.lt:SetText( " " )
			self.power.rt:SetText( " " )
		elseif(self.entitydata.disconnected) then
			self.hp.lt:SetText( " " .. self.entitydata.name)
			self.hp.rt:SetText( "DISCONNECTED ")
			self.power.lt:SetText( " " )
			self.power.rt:SetText( " " )
		else
			self.hp.lt:SetText(mUI_ParseText(self, self.cfg.custom["HP_Bar_Text_Left"].value))
			self.hp.rt:SetText(mUI_ParseText(self, self.cfg.custom["HP_Bar_Text_Right"].value))

			if(self.cfg.custom["MP_Bar_Text_Left"] and self.cfg.custom["MP_Bar_Text_Right"]) then
				self.power.lt:SetText(mUI_ParseText(self, self.cfg.custom["MP_Bar_Text_Left"].value))
				self.power.rt:SetText(mUI_ParseText(self, self.cfg.custom["MP_Bar_Text_Right"].value))
			else
				self.power.lt:SetText( " " )
				self.power.rt:SetText( " " )
			end
		end

		self.hp:SetMinMaxValues(0, self.entitydata.hpmax)
		self.hp:SetValue(self.entitydata.hp)
		self.power:SetMinMaxValues(0, self.entitydata.mpmax)
		self.power:SetValue(self.entitydata.mp)
	else
		self.hp.lt:SetText( " HP LEFT ")
		self.hp.rt:SetText( " HP RIGHT ")
		self.power.lt:SetText( " MP LEFT " )
		self.power.rt:SetText( " MP RIGHT " )
		self.hp:SetMinMaxValues(0, self.entitydata.hpmax)
		self.hp:SetValue(self.entitydata.hp/2)
		self.power:SetMinMaxValues(0, self.entitydata.mpmax)
		self.power:SetValue(self.entitydata.mpmax/2)
	end
end

local function mUI_UnitFramesUpdateBarColors(self)
	if(self.cfg.bars["HP_Bar_Color_Mode"].value == "CLASS") then
		classClr = mUI_GetClassColor(self.entity)
		self.hp:SetStatusBarColor( classClr.r, classClr.g, classClr.b, self.cfg.bars["HP_Bar_Color"].value.a )	
	elseif(self.cfg.bars["HP_Bar_Color_Mode"].value == "POWER") then
		powerClr = mUI_GetPowerColor(self.entity)
		self.hp:SetStatusBarColor( powerClr.r, powerClr.g, powerClr.b, self.cfg.bars["HP_Bar_Color"].value.a )	
	else
		self.hp:SetStatusBarColor( mUI_GetColor(self.cfg.bars["HP_Bar_Color"].value) )
	end
	self.hp_deficit:SetBackdropColor( mUI_GetColor(self.cfg.bars["HP_Deficit_Bar_Color"].value) )

	if(self.cfg.bars["MP_Bar_Color_Mode"].value == "CLASS") then
		classClr = mUI_GetClassColor(self.entity)
		self.power:SetStatusBarColor( classClr.r, classClr.g, classClr.b, self.cfg.bars["MP_Bar_Color"].value.a )	
	elseif(self.cfg.bars["MP_Bar_Color_Mode"].value == "POWER") then
		powerClr = mUI_GetPowerColor(self.entity)
		self.power:SetStatusBarColor( powerClr.r, powerClr.g, powerClr.b, self.cfg.bars["MP_Bar_Color"].value.a )	
	else
		self.power:SetStatusBarColor( mUI_GetColor(self.cfg.bars["MP_Bar_Color"].value) )
	end
	self.power_deficit:SetBackdropColor( mUI_GetColor(self.cfg.bars["MP_Deficit_Bar_Color"].value) )
end

local function mUI_UnitFramesGetEntityData(self)
	if(self.entitydata == nil) then self.entitydata = {} end

	_, self.entitydata.class 		= UnitClass(self.entity)
	self.entitydata.name 			= UnitName(self.entity) or "Unknown"
	self.entitydata.level 			= UnitLevel(self.entity)
	self.entitydata.classification  = strupper(UnitClassification(self.entity))
	if( self.entitydata.classification == "NORMAL" or 
		self.entitydata.classification == "TRIVIAL" or
		self.entitydata.classification == "MINUs") then
		self.entitydata.classification = ""
	end
	self.entitydata.hp 				= UnitHealth(self.entity) 
	self.entitydata.hpmax			= UnitHealthMax(self.entity) or 100
	self.entitydata.isdead 		 	= UnitIsDead(self.entity)
	self.entitydata.isghost 		= UnitIsGhost(self.entity)
	self.entitydata.mp 				= UnitMana(self.entity)
	self.entitydata.mpmax			= UnitManaMax(self.entity)
	self.entitydata.disconnected	= (self.entitydata.hpmax == 0 and self.entitydata.mpmax == 0)

	if(self.entity == "target" and self.combobar) then
	end
end

local function mUI_UnitFramesUpdate(self)
	if(self.buffpanel and self.debuffpanel) then mUI_UnitframesGetBuffs(self) end
	if(self.entity == "target" and self.combobar) then mUI_UnitframesGetComboPoints(self) end
	mUI_UnitFramesGetEntityData(self)
	mUI_UnitFramesUpdateBarColors(self)
	mUI_UnitFramesUpdateBars(self)
end

local function mUI_UnitFramesFullUpdate(self)
	local Frame_Width = self.cfg.custom["Frame_Width"].value

	self:SetFrameStrata(self.cfg.custom["Strata"].value)
	self:SetWidth(Frame_Width)
	self:SetHeight(self.cfg.custom["Frame_Height"].value)
	self:SetBackdrop(DEFAULT_BACKDROP)
	self:SetBackdropColor(mUI_GetColor(self.cfg.frame["BG_Color"].value))
	self:SetBackdropBorderColor(mUI_GetColor(self.cfg.frame["Border_Color"].value))

	self.hp:SetHeight(self.cfg.custom["HP_Bar_Height"].value)
	self.hp:SetFrameStrata(self.cfg.custom["Strata"].value)
	self.hp:SetStatusBarTexture(self.cfg.bars["BG_Texture"].value)
	                                                                                    
	self.hp.lt:SetFont(self.cfg.bars["HP_Font"].value, self.cfg.bars["HP_Font_Size"].value)
	self.hp.lt:SetTextColor(mUI_GetColor(self.cfg.bars["HP_Font_Color"].value))
	self.hp.lt:SetShadowColor(mUI_GetColor(self.cfg.bars["HP_Font_Shadow_Color"].value))
	self.hp.rt:SetFont(self.cfg.bars["HP_Font"].value, self.cfg.bars["HP_Font_Size"].value)
	self.hp.rt:SetTextColor(mUI_GetColor(self.cfg.bars["HP_Font_Color"].value))
	self.hp.rt:SetShadowColor(mUI_GetColor(self.cfg.bars["HP_Font_Shadow_Color"].value))

	self.hp_deficit:SetHeight(self.cfg.custom["HP_Bar_Height"].value)
	self.hp_deficit:SetFrameStrata(self.cfg.custom["Strata"].value)
	self.hp_deficit:SetBackdrop(DEFAULT_BACKDROP_BORDERLESS)

	self.power:SetHeight(self.cfg.custom["MP_Bar_Height"].value)	
	self.power:SetFrameStrata(self.cfg.custom["Strata"].value)
	self.power:SetStatusBarTexture(self.cfg.bars["BG_Texture"].value)

	self.power.lt:SetFont(self.cfg.bars["MP_Font"].value, self.cfg.bars["MP_Font_Size"].value)
	self.power.lt:SetTextColor(mUI_GetColor(self.cfg.bars["MP_Font_Color"].value))
	self.power.lt:SetShadowColor(mUI_GetColor(self.cfg.bars["MP_Font_Shadow_Color"].value))
	self.power.rt:SetFont(self.cfg.bars["MP_Font"].value, self.cfg.bars["MP_Font_Size"].value)
	self.power.rt:SetTextColor(mUI_GetColor(self.cfg.bars["MP_Font_Color"].value))
	self.power.rt:SetShadowColor(mUI_GetColor(self.cfg.bars["MP_Font_Shadow_Color"].value))

	self.power_deficit:SetHeight(self.cfg.custom["MP_Bar_Height"].value)
	self.power_deficit:SetFrameStrata(self.cfg.custom["Strata"].value)
	self.power_deficit:SetBackdrop(DEFAULT_BACKDROP_BORDERLESS)

	local buffcolor = mUI_GetVariableValueByName(unitframes, "MenuA|General|Buff_Border_Color")
	local debuffcolor = mUI_GetVariableValueByName(unitframes, "MenuA|General|Debuff_Border_Color")

	if(self.buffpanel and self.debuffpanel) then	
		local buffsize = self.cfg.custom["Buff_Size"].value
		local iconx    = 0
		local icony    = 0
		for slotindex, buff in ipairs(self.buffpanel.buffs) do
			if(slotindex > self.cfg.custom["Buff_Count"].value) then buff:Hide() else buff:Show() end
			buff.bg:SetPoint("TOPLEFT", self.buffpanel, "TOPLEFT", iconx, icony)
			buff.bg:SetHeight(buffsize)
			buff.bg:SetWidth(buffsize)
			buff.bg:SetTexture(buffcolor.r,buffcolor.g,buffcolor.g,buffcolor.a)
			buff.inlay:SetTexture(0,0,0,1)
			buff.icon:SetTexCoord(.1, .9, .1, .9)
			iconx = iconx + buffsize + 1
			if((iconx+buffsize) >= Frame_Width) then
				iconx = 0
				icony = icony - buffsize - 1
			end
		end	

		local debuffsize = self.cfg.custom["Debuff_Size"].value
		iconx            = 0
		icony            = 0
		for slotindex, debuff in ipairs(self.debuffpanel.buffs) do
			if(slotindex > self.cfg.custom["Debuff_Count"].value) then debuff:Hide() else debuff:Show() end
			debuff.bg:SetPoint("BOTTOMLEFT", self.debuffpanel, "BOTTOMLEFT", iconx, icony)
			debuff.bg:SetHeight(debuffsize)
			debuff.bg:SetWidth(debuffsize)
			debuff.bg:SetTexture(debuffcolor.r,debuffcolor.g,debuffcolor.g,debuffcolor.a)	
			debuff.inlay:SetTexture(0,0,0,1)
			debuff.icon:SetTexCoord(.1, .9, .1, .9)		
			iconx = iconx + debuffsize + 1
			if((iconx+debuffsize) >= Frame_Width) then
				iconx = 0
				icony = icony + debuffsize + 1
			end
		end	
	end

	if(self.rangecheck) then
		self.rangecheck.dtt = interval or ( mUI_GetVariableValueByName(unitframes, "MenuA|Performance|Rangecheck_PartyRaid_Interval") / 1000.0)
	end

	if(self.dtt) then 
		self.dtt = mUI_GetVariableValueByName(unitframes, "MenuA|Performance|Target_Of_Target_Update_Interval") / 1000.0
	end

	mUI_UnitFramesUpdate(self)
end

local function mUI_UnitFramesSetRangeChecking(self, enabled, interval)
	if(self.entity == "player" or self.entity == "target") then return end 
	if(self.rangecheck == nil) then 
		self.rangecheck = {}

		self.rangecheck.enabled = enabled or true
		self.rangecheck.dt      = 0.0
		self.rangecheck.dtt     = interval or ( mUI_GetVariableValueByName(unitframes, "MenuA|Performance|Rangecheck_PartyRaid_Interval") / 1000.0)

		self:SetScript("OnUpdate", function (this, elapsed)
			if(this.rangecheck.enabled) then
				this.rangecheck.dt = this.rangecheck.dt + elapsed
				if(this.rangecheck.dt >= this.rangecheck.dtt) then
					this.rangecheck.dt = 0.0
					if(UnitInRange(this.entity)) then
						this:SetAlpha(1)
					else
						this:SetAlpha(.5)
					end
				end
			end
		end)
	else
		self.rangecheck.dtt     = interval or ( mUI_GetVariableValueByName(unitframes, "MenuA|Performance|Rangecheck_PartyRaid_Interval") / 1000.0)
	end
end

function mUI_UnitframesInitialize(frame, entity, frame_layout, bars_layout, custom_layout)
	mUI_UnitframesAttachConfig(frame, frame_layout, bars_layout, custom_layout)
	frame.entity = entity
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetMovable(true)
	frame:SetScript("OnDragStart", function() 
		if(mUI_GetVariableValueByName(unitframes, "MenuA|General|Locked") == false) then
			if(this.entity == "party2" or this.entity == "party3" or this.entity == "party4") then
				unitframes["party1"]:StartMoving() 
			else
				this:StartMoving() 
			end
		end
	end)
	frame:SetScript("OnDragStop", function() 
		if(mUI_GetVariableValueByName(unitframes, "MenuA|General|Locked") == false) then
			if(this.entity == "party2" or this.entity == "party3" or this.entity == "party4") then
				unitframes["party1"]:StopMovingOrSizing()
			else
				this:StopMovingOrSizing() 
			end
		end	
	end)

	frame:SetAttribute('type1', 'target')	
	frame:SetAttribute('type2', 'menu')
	
	frame:SetScript("OnEnter", function()
    	GameTooltip_SetDefaultAnchor(GameTooltip, this)
    	GameTooltip:SetUnit(this.entity)
    	GameTooltip:Show()
  	end)
	
	frame.hp_deficit = mUI_CreateDefaultFrame(frame, nil, 0, 16)
	frame.hp_deficit:ClearAllPoints()
	frame.hp_deficit:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
	frame.hp_deficit:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
	frame.hp_deficit:SetFrameLevel(2)

	frame.hp = CreateFrame("StatusBar", nil, frame)
	frame.hp:SetAllPoints(frame.hp_deficit)

	frame.hp.lt = mUI_FontString(frame.hp, nil, 12, nil, "left text", "TOP", "LEFT")
	frame.hp.rt = mUI_FontString(frame.hp, nil, 12, nil, "right text", "TOP", "RIGHT")

	frame.power_deficit = mUI_CreateDefaultFrame(frame, nil, 0, 16)
	frame.power_deficit:ClearAllPoints()
	frame.power_deficit:SetPoint("TOPLEFT", frame.hp_deficit, "BOTTOMLEFT", 0, -1)
	frame.power_deficit:SetPoint("TOPRIGHT", frame.hp_deficit, "TOPRIGHT", 0, -1)
	frame.power_deficit:SetFrameLevel(2)

	frame.power = CreateFrame("StatusBar", nil, frame)
	frame.power:SetAllPoints(frame.power_deficit)

	frame.power.lt = mUI_FontString(frame.power, nil, 12, nil, "left text", "TOP", "LEFT")
	frame.power.rt = mUI_FontString(frame.power, nil, 12, nil, "right text", "TOP", "RIGHT")

	if(entity ~= "targettarget") then
		frame.buffpanel = mUI_CreateDefaultFrame(frame, nil, 100, 18, "DIALOG")
		frame.buffpanel:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -1)
		frame.buffpanel:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT",0, -1)
		frame.buffpanel:SetBackdrop(nil)
		frame.buffpanel:SetFrameLevel(4)
		frame.buffpanel.buffs = {}
	
		for i=1, MUI_UNITFRAMES_MAX_BUFFS do
			frame.buffpanel.buffs[i]       = CreateFrame("Frame", nil, frame)
			frame.buffpanel.buffs[i].bg    = frame.buffpanel.buffs[i]:CreateTexture(nil, "BACKGROUND")

			frame.buffpanel.buffs[i].inlay = frame.buffpanel.buffs[i]:CreateTexture(nil, "BORDER")
			frame.buffpanel.buffs[i].inlay:SetPoint("TOPLEFT", frame.buffpanel.buffs[i].bg, "TOPLEFT", 1, -1)
			frame.buffpanel.buffs[i].inlay:SetPoint("BOTTOMRIGHT", frame.buffpanel.buffs[i].bg, "BOTTOMRIGHT", -1, 1)

			frame.buffpanel.buffs[i].icon  = frame.buffpanel.buffs[i]:CreateTexture(nil, "ARTWORK")
			frame.buffpanel.buffs[i].icon:SetPoint("TOPLEFT", frame.buffpanel.buffs[i].inlay, "TOPLEFT", 1, -1)
			frame.buffpanel.buffs[i].icon:SetPoint("BOTTOMRIGHT", frame.buffpanel.buffs[i].inlay, "BOTTOMRIGHT", -1, 1)

			frame.buffpanel.buffs[i].count = mUI_FontString(frame.buffpanel.buffs[i], nil, 10, nil, "", "BOTTOM", "RIGHT")

			frame.buffpanel.buffs[i]:SetAllPoints(frame.buffpanel.buffs[i].bg)
			frame.buffpanel.buffs[i]:EnableMouse(true)
			frame.buffpanel.buffs[i]:SetScript("OnEnter", function ()
				GameTooltip_SetDefaultAnchor(GameTooltip, this)
    			GameTooltip:SetUnitBuff(entity, i)
    			GameTooltip:Show()
			end)
			frame.buffpanel.buffs[i]:SetScript("OnLeave", function ()
    			GameTooltip:Hide()
			end)
		end	

		frame.debuffpanel = mUI_CreateDefaultFrame(frame, nil, 100, 18, "DIALOG")
		frame.debuffpanel:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 1)
		frame.debuffpanel:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 1)
		frame.debuffpanel:SetBackdrop(nil)
		frame.debuffpanel:SetFrameLevel(4)
		frame.debuffpanel.buffs = {}
		
		for i=1, MUI_UNITFRAMES_MAX_DEBUFFS do
			frame.debuffpanel.buffs[i]       = CreateFrame("Frame",nil,frame)
			frame.debuffpanel.buffs[i].bg    = frame.debuffpanel.buffs[i]:CreateTexture(nil, "BACKGROUND")

			frame.debuffpanel.buffs[i].inlay = frame.debuffpanel.buffs[i]:CreateTexture(nil, "BORDER")
			frame.debuffpanel.buffs[i].inlay:SetPoint("TOPLEFT", frame.debuffpanel.buffs[i].bg, "TOPLEFT", 1, -1)
			frame.debuffpanel.buffs[i].inlay:SetPoint("BOTTOMRIGHT", frame.debuffpanel.buffs[i].bg, "BOTTOMRIGHT", -1, 1)			

			frame.debuffpanel.buffs[i].icon  = frame.debuffpanel.buffs[i]:CreateTexture(nil, "ARTWORK")
			frame.debuffpanel.buffs[i].icon:SetPoint("TOPLEFT", frame.debuffpanel.buffs[i].inlay, "TOPLEFT", 1, -1)
			frame.debuffpanel.buffs[i].icon:SetPoint("BOTTOMRIGHT", frame.debuffpanel.buffs[i].inlay, "BOTTOMRIGHT", -1, 1)

			frame.debuffpanel.buffs[i].count = mUI_FontString(frame.debuffpanel.buffs[i], nil, 10, nil, "", "BOTTOM", "RIGHT")

			frame.debuffpanel.buffs[i]:SetAllPoints(frame.debuffpanel.buffs[i].bg)
			frame.debuffpanel.buffs[i]:EnableMouse(true)
			frame.debuffpanel.buffs[i]:SetScript("OnEnter", function ()
				GameTooltip_SetDefaultAnchor(GameTooltip, this)
    			GameTooltip:SetUnitDebuff(entity, i)
    			GameTooltip:Show()
			end)
			frame.debuffpanel.buffs[i]:SetScript("OnLeave", function ()
    			GameTooltip:Hide()
			end)
		end
	end
	mUI_UnitFramesFullUpdate(frame)
	table.insert(unitframes.framelist, frame)
end

function unitframes:OnLoadDefaults(config)
	local default_backdrop = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "Interface\\AddOns\\minimalUI\\img\\BorderShadow.tga", 
		tile = false, tileSize = 0, edgeSize = 16, insets = { left = 0, right = 0, top = 0, bottom = 0 } 
	}
	local default_backdrop_noborder = { 
		bgFile = "Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga", 
		edgeFile = "", 
		tile = false, tileSize = 0, edgeSize = 16, insets = { left = 0, right = 0, top = 0, bottom = 0 } 
	}

	mUI_SetVariable(self, "MenuA|General|Locked", 				"BOOLEAN", true)
	mUI_SetVariable(self, "MenuA|General|Configuration_Mode", 	"BOOLEAN", false) -- TODO: Make this a dropdown thing for None, Group, Raid
	mUI_SetVariable(self, "MenuA|General|Buff_Border_Color", 	"BGCOLOR", {r=1,g=1,b=1,a=.25}) -- TODO: Make this a dropdown thing for None, Group, Raid
	mUI_SetVariable(self, "MenuA|General|Debuff_Border_Color", 	"BGCOLOR", {r=1,g=0,b=0,a=.75}) -- TODO: Make this a dropdown thing for None, Group, Raid

	mUI_SetVariable(self, "MenuA|Performance|Rangecheck_PartyRaid_Interval",	"NUMBERFIELD",	500)
	mUI_SetVariable(self, "MenuA|Performance|Target_Of_Target_Update_Interval",	"NUMBERFIELD",	250)

	mUI_SetVariable(self, "MenuB|Background|Border_Color", 				"BORDERCOLOR", 		{r=1.0, g=0.0, b=1.0, a=0.0})
	mUI_SetVariable(self, "MenuB|Background|Border_Texture",			"COMBOTEXTURE", 	"Interface\\AddOns\\minimalUI\\img\\BorderShadow.tga")
	mUI_SetVariable(self, "MenuB|Background|BG_Color", 					"BGCOLOR",			{r=0.1, g=0.1, b=0.1, a=1.0})
	mUI_SetVariable(self, "MenuB|Background|BG_Texture",				"COMBOTEXTURE", 	"Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga")

	mUI_SetVariable(self, "MenuC|StatusBar|BG_Texture", 				"COMBOTEXTURE",		"Interface\\AddOns\\minimalUI\\img\\BantoBar.tga")	
	mUI_SetVariable(self, "MenuC|StatusBar|HP_Bar_Color", 				"BGCOLOR",			{r=0.09, g=0.09, b=0.09, a=1.0})
	mUI_SetVariable(self, "MenuC|StatusBar|HP_Bar_Color_Mode",			"DYNAMIC_COLOR",	"CUSTOM")
	mUI_SetVariable(self, "MenuC|StatusBar|HP_Deficit_Bar_Color", 		"BGCOLOR",			{r=0.29, g=0.29, b=0.29, a=1.0})
	mUI_SetVariable(self, "MenuC|StatusBar|HP_Font",					"COMBOFONT",		"Interface\\AddOns\\minimalUI\\Fonts\\big_noodle_titling.ttf")
	mUI_SetVariable(self, "MenuC|StatusBar|HP_Font_Color",				"TEXTCOLOR",		{r=1.0, g=1.0, b=1.0, a=1.0})
	mUI_SetVariable(self, "MenuC|StatusBar|HP_Font_Shadow_Color",		"TEXTCOLOR",		{r=0.0, g=0.0, b=0.0, a=0.4})
	mUI_SetVariable(self, "MenuC|StatusBar|HP_Font_Size",				"NUMBERFIELD",		18)
	mUI_SetVariable(self, "MenuC|StatusBar|MP_Bar_Color", 				"BGCOLOR",			{r=1.0, g=0.0, b=0.0, a=1.0})
	mUI_SetVariable(self, "MenuC|StatusBar|MP_Bar_Color_Mode",			"DYNAMIC_COLOR",	"POWER")
	mUI_SetVariable(self, "MenuC|StatusBar|MP_Deficit_Bar_Color", 		"BGCOLOR",			{r=0.35, g=0.35, b=0.35, a=1.0})
	mUI_SetVariable(self, "MenuC|StatusBar|MP_Font",					"COMBOFONT",		"Interface\\AddOns\\minimalUI\\Fonts\\big_noodle_titling.ttf")
	mUI_SetVariable(self, "MenuC|StatusBar|MP_Font_Color",				"TEXTCOLOR",		{r=1.0, g=1.0, b=1.0, a=1.0})
	mUI_SetVariable(self, "MenuC|StatusBar|MP_Font_Shadow_Color",		"TEXTCOLOR",		{r=0.0, g=0.0, b=0.0, a=0.4})
	mUI_SetVariable(self, "MenuC|StatusBar|MP_Font_Size",				"NUMBERFIELD",		11)

	mUI_SetVariable(self, "MenuD|Player|Buff_Count",			"NUMBERFIELD", 		16)	
	mUI_SetVariable(self, "MenuD|Player|Buff_Size",				"NUMBERFIELD", 		24)	
	mUI_SetVariable(self, "MenuD|Player|Debuff_Count",			"NUMBERFIELD", 		12)	
	mUI_SetVariable(self, "MenuD|Player|Debuff_Size",			"NUMBERFIELD", 		32)	
	mUI_SetVariable(self, "MenuD|Player|Frame_Height",			"NUMBERFIELD", 		62)	
	mUI_SetVariable(self, "MenuD|Player|Frame_Width",			"NUMBERFIELD", 		200)
	mUI_SetVariable(self, "MenuD|Player|HP_Bar_Height",	 		"NUMBERFIELD", 		45)
	mUI_SetVariable(self, "MenuD|Player|HP_Bar_Text_Left", 		"TEXTFIELD", 		"$name")
	mUI_SetVariable(self, "MenuD|Player|HP_Bar_Text_Right",		"TEXTFIELD", 		"$hp")
	mUI_SetVariable(self, "MenuD|Player|MP_Bar_Height",	 		"NUMBERFIELD", 		12)
	mUI_SetVariable(self, "MenuD|Player|MP_Bar_Text_Left", 		"TEXTFIELD", 		"$class")
	mUI_SetVariable(self, "MenuD|Player|MP_Bar_Text_Right",		"TEXTFIELD", 		"$mp")
	mUI_SetVariable(self, "MenuD|Player|Strata", 				"STRATA", 			"LOW")

	mUI_SetVariable(self, "MenuD|Pet|Buff_Count",				"NUMBERFIELD", 		10)	
	mUI_SetVariable(self, "MenuD|Pet|Buff_Size",				"NUMBERFIELD", 		14)	
	mUI_SetVariable(self, "MenuD|Pet|Debuff_Count",				"NUMBERFIELD", 		10)	
	mUI_SetVariable(self, "MenuD|Pet|Debuff_Size",				"NUMBERFIELD", 		19)	
	mUI_SetVariable(self, "MenuD|Pet|Frame_Height",				"NUMBERFIELD", 		35)	
	mUI_SetVariable(self, "MenuD|Pet|Frame_Width",				"NUMBERFIELD", 		200)
	mUI_SetVariable(self, "MenuD|Pet|HP_Bar_Text_Left", 		"TEXTFIELD", 		"$level $name $happiness")
	mUI_SetVariable(self, "MenuD|Pet|HP_Bar_Text_Right",		"TEXTFIELD", 		"$hp|$hpmax")
	mUI_SetVariable(self, "MenuD|Pet|HP_Bar_Height",	 		"NUMBERFIELD", 		18)
	mUI_SetVariable(self, "MenuD|Pet|MP_Bar_Text_Left", 		"TEXTFIELD", 		"$class")
	mUI_SetVariable(self, "MenuD|Pet|MP_Bar_Text_Right",		"TEXTFIELD", 		"$mp|$mpmax")
	mUI_SetVariable(self, "MenuD|Pet|MP_Bar_Height",	 		"NUMBERFIELD", 		12)
	mUI_SetVariable(self, "MenuD|Pet|Strata", 					"STRATA", 			"LOW")	

	mUI_SetVariable(self, "MenuE|Target|Buff_Count",			"NUMBERFIELD", 		16)	
	mUI_SetVariable(self, "MenuE|Target|Buff_Size",				"NUMBERFIELD", 		24)	
	mUI_SetVariable(self, "MenuE|Target|Debuff_Count",			"NUMBERFIELD", 		20)	
	mUI_SetVariable(self, "MenuE|Target|Debuff_Size",			"NUMBERFIELD", 		19)	
	mUI_SetVariable(self, "MenuE|Target|Frame_Height",			"NUMBERFIELD", 		62)
	mUI_SetVariable(self, "MenuE|Target|Frame_Width", 			"NUMBERFIELD", 		200)
	mUI_SetVariable(self, "MenuE|Target|HP_Bar_Height",			"NUMBERFIELD", 		45)
	mUI_SetVariable(self, "MenuE|Target|HP_Bar_Text_Left", 		"TEXTFIELD", 		"$level $classification|n$name")
	mUI_SetVariable(self, "MenuE|Target|HP_Bar_Text_Right",		"TEXTFIELD", 		"$hp|n$hpmax")
	mUI_SetVariable(self, "MenuE|Target|MP_Bar_Height",			"NUMBERFIELD", 		12)
	mUI_SetVariable(self, "MenuE|Target|MP_Bar_Text_Left", 		"TEXTFIELD", 		"$class")
	mUI_SetVariable(self, "MenuE|Target|MP_Bar_Text_Right",		"TEXTFIELD", 		"$mp|$mpmax")
	mUI_SetVariable(self, "MenuE|Target|Strata", 				"STRATA", 			"LOW")
	
	mUI_SetVariable(self, "MenuF|TargetTarget|Frame_Height",		"NUMBERFIELD", 		30)
	mUI_SetVariable(self, "MenuF|TargetTarget|Frame_Width", 		"NUMBERFIELD", 		200)
	mUI_SetVariable(self, "MenuF|TargetTarget|HP_Bar_Height",		"NUMBERFIELD", 		22)
	mUI_SetVariable(self, "MenuF|TargetTarget|HP_Bar_Text_Left", 	"TEXTFIELD", 		"$name")
	mUI_SetVariable(self, "MenuF|TargetTarget|HP_Bar_Text_Right",	"TEXTFIELD", 		"")
	mUI_SetVariable(self, "MenuF|TargetTarget|MP_Bar_Height",		"NUMBERFIELD", 		3)
	mUI_SetVariable(self, "MenuF|TargetTarget|Strata", 				"STRATA", 			"LOW")
	
	mUI_SetVariable(self, "MenuG|Party|Buff_Count",				"NUMBERFIELD", 		10)	
	mUI_SetVariable(self, "MenuG|Party|Buff_Size",				"NUMBERFIELD", 		16)	
	mUI_SetVariable(self, "MenuG|Party|Debuff_Count",			"NUMBERFIELD", 		7)	
	mUI_SetVariable(self, "MenuG|Party|Debuff_Size",			"NUMBERFIELD", 		24)	
	mUI_SetVariable(self, "MenuG|Party|Frame_Height",			"NUMBERFIELD", 		40)
	mUI_SetVariable(self, "MenuG|Party|Frame_Width", 			"NUMBERFIELD", 		180)
	mUI_SetVariable(self, "MenuG|Party|Group_Spacing_Y",		"NUMBERFIELD", 		45)
	mUI_SetVariable(self, "MenuG|Party|HP_Bar_Height",			"NUMBERFIELD", 		23)
	mUI_SetVariable(self, "MenuG|Party|HP_Bar_Text_Left", 		"TEXTFIELD", 		"$name")
	mUI_SetVariable(self, "MenuG|Party|HP_Bar_Text_Right",		"TEXTFIELD", 		"$hp|$hpmax")
	mUI_SetVariable(self, "MenuG|Party|MP_Bar_Height",	 		"NUMBERFIELD", 		12)
	mUI_SetVariable(self, "MenuG|Party|MP_Bar_Text_Left", 		"TEXTFIELD", 		"$class")
	mUI_SetVariable(self, "MenuG|Party|MP_Bar_Text_Right",		"TEXTFIELD", 		"$mp|$mpmax")
	mUI_SetVariable(self, "MenuG|Party|Strata", 				"STRATA", 			"LOW")
end

function unitframes:VariableChanged(var)
	if(var == nil) then return end
	
	if(var.fqvn == "Menu0|Enabled") then
		ReloadUI()
	end

	if(var.name == "Locked") then
		if(var.value) then
			mUI:SetGridView(false)
		else
			mUI:SetGridView(true)
		end
		return nil
	end	

	if(var.name == "Group_Spacing_Y") then
		for i=2, 4 do
			self["party"..i]:SetPoint("TOPLEFT", self["party"..(i-1)], "BOTTOMLEFT", 0, -1*var.value)
		end
	end

	if(var.name == "Configuration_Mode") then
		local num_members = GetNumPartyMembers()
		for i=1, 4 do			
			local identifier = "party"..i
			if(var.value) then 
				self[identifier]:Show() 
			else
				if(i > num_members) then 
					self[identifier]:Hide()
				else
					self[identifier]:Show()
				end
			end
		end
	end

	if(var.fqvn == "MenuB|Background|BG_Texture") then
		DEFAULT_BACKDROP.bgFile = var.value
	elseif(var.fqvn == "MenuB|Background|Border_Texture") then
		DEFAULT_BACKDROP.edgeFile = var.value
	elseif(var.fqvn == "MenuC|StatusBar|BG_Texture") then
		DEFAULT_BACKDROP_BORDERLESS.bgFile = var.value
	end

	for index, frame in ipairs(self.framelist) do mUI_UnitFramesFullUpdate(frame) end
end

function unitframes:OnEnable()
	-- By default configuration mode is set to false!
	mUI_SetVariable(self, "MenuA|General|Configuration_Mode", "BOOLEAN", false) 

	-- Disable all classic wow unitframes and unregister their events
	for i, frame in ipairs(blizzard_ui_elements) do
		local f = globals[frame]
		if(f) then
			f:Hide()
			f:UnregisterAllEvents()
			f.Show = function () return end
		else
			mUI_DebugMessage("Unable to hide ".. frame ..". Probably doesn't exist.")
		end
	end

	-- Creates an eventhandler for all necessary events
	local eventhandler = CreateFrame("Frame")
	eventhandler:SetScript("OnEvent", function ()
		if mUI_EventIsEither(event, "UNIT_AURA", "UNIT_FACTION", "UPDATE_FACTION", "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_MANA", "UNIT_MAXMANA", "UNIT_RAGE", "UNIT_NAXRAGE", "UNIT_ENERGY", "UNIT_MAXENERGY") then 
			if(arg1 and self[arg1]) then mUI_UnitFramesUpdate(self[arg1]) end
		end

		if mUI_EventIsEither(event, "PLAYER_ENTERING_WORLD", "PLAYER_AURAS_CHANGED") then
			mUI_UnitFramesUpdate(self.player)
		end
	end)

	-- Registers all necessary event for the eventhandler
	mUI_EventRegisterList(eventhandler, 
		"UNIT_HEALTH", "UNIT_MAXHEALTH",  "UNIT_MANA", "UNIT_MAXMANA", "UNIT_RAGE",
	 	"UNIT_FACTION", "UPDATE_FACTION", "UNIT_AURA", 
		"UNIT_NAXRAGE", "UNIT_ENERGY", "UNIT_MAXENERGY", "PLAYER_ENTERING_WORLD",
		"PLAYER_AURAS_CHANGED"
	)

	-- Player unitframe initialization
	self.player = CreateFrame("Button", "mUI"..self.name .. "player", UIParent, "SecureActionButtonTemplate")
	self.player:SetPoint("CENTER", UIParent, "CENTER", -200, -200)
	self.player:SetAttribute("unit", "player")
	self.player:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	self.player.menu = function (self)
		ToggleDropDownMenu(1, nil, getglobal("PlayerFrameDropDown"), "cursor")
	end
	mUI_UnitframesInitialize(self.player, "player", 
		mUI_GetVariableValueByName(self, "MenuB|Background"),
		mUI_GetVariableValueByName(self, "MenuC|StatusBar"),
		mUI_GetVariableValueByName(self, "MenuD|Player")
	)
	
	-- Player unitframe initialization
	self.pet = CreateFrame("Button", "mUI"..self.name .. "pet", UIParent, "SecureActionButtonTemplate")
	self.pet:SetPoint("CENTER", UIParent, "CENTER", -420, -200)
	self.pet:SetAttribute("unit", "pet")
	self.pet:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	self.pet.menu = function (self)
		ToggleDropDownMenu(1, nil, getglobal("PetFrameDropDown"), "cursor")
	end
	mUI_UnitframesInitialize(self.pet, "pet", 
		mUI_GetVariableValueByName(self, "MenuB|Background"),
		mUI_GetVariableValueByName(self, "MenuC|StatusBar"),
		mUI_GetVariableValueByName(self, "MenuD|Pet")
	)
	RegisterUnitWatch(self.pet)

	-- Target unitframe initialization
	self.target = CreateFrame("Button", "mUI"..self.name .. "target", UIParent, "SecureUnitButtonTemplate")
	self.target:EnableMouse(true)
	self.target:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	self.target:RegisterEvent("PLAYER_TARGET_CHANGED", "UNIT_TARGET")
	self.target:SetPoint("CENTER", UIParent, "CENTER", 200, -200)
	self.target:SetScript("OnEvent", function () mUI_UnitFramesUpdate(this) end)
	self.target.menu = function (self)
		ToggleDropDownMenu(1, nil, getglobal("TargetFrameDropDown"), "cursor")
	end
	mUI_UnitframesInitialize(self.target, "target", 
		mUI_GetVariableValueByName(self, "MenuB|Background"),
		mUI_GetVariableValueByName(self, "MenuC|StatusBar"),
		mUI_GetVariableValueByName(self, "MenuE|Target")
	)
	self.target:SetAttribute("unit", "target")
	RegisterUnitWatch(self.target)

	-- Target combobar initialization
	self.target.combobar = CreateFrame("Frame", nil, self.target)
	self.target.combobar:SetPoint("TOPLEFT", self.target, "TOPLEFT", 0, 5)
	self.target.combobar:SetPoint("TOPRIGHT", self.target, "TOPRIGHT", 0, 5)
	self.target.combobar:SetBackdrop(DEFAULT_BACKDROP_BORDERLESS)
	self.target.combobar:SetBackdropColor(0,0,0,.75)
	self.target.combobar:SetHeight(6)
	self.target.combobar:SetFrameLevel(4)
	self.target.combobar.points = {}
	for i=1, 5 do
		self.target.combobar.points[i] = self.target.combobar:CreateTexture()
		self.target.combobar.points[i]:SetTexture(1,.96,0.41,1.0)
	end	

	-- TargetTarget unitframe initialization
	self.targettarget = CreateFrame("Button", "mUI"..self.name .. "targettarget", UIParent, "SecureUnitButtonTemplate")
	self.targettarget:SetPoint("CENTER", UIParent, "CENTER", 420, -200)
	self.targettarget:SetAttribute('unit', "targettarget")
	mUI_UnitframesInitialize(self.targettarget, "targettarget", 
		mUI_GetVariableValueByName(self, "MenuB|Background"),
		mUI_GetVariableValueByName(self, "MenuC|StatusBar"),
		mUI_GetVariableValueByName(self, "MenuF|TargetTarget")
	)
	self.targettarget:SetScript("OnUpdate", function (this, elapsed)
		if(this.dt == nil) then this.dt = 0.0 end
		if(this.dtt == nil) then this.dtt = mUI_GetVariableValueByName(unitframes, "MenuA|Performance|Target_Of_Target_Update_Interval") / 1000.0 end
		this.dt = this.dt + elapsed
		if(this.dt >= this.dtt) then
			mUI_UnitFramesUpdate(this)
			if(UnitExists("targettarget")) then
				this:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
				this:SetAlpha(1)
			else
				this:RegisterForClicks('RightButtonUp')
				this:SetAlpha(0)
			end
			this.dt = 0
		end
	end)
	RegisterUnitWatch(self.targettarget)

	-- Party unitframe initialization
	local party_offset = mUI_GetVariableValueByName(self, "MenuG|Party|Group_Spacing_Y")
	local num_members = GetNumPartyMembers()
	local party_relative = UIParent
	for i=1, 4 do
		local identifier = "party"..i
		self[identifier] = CreateFrame("Button", "mUI"..self.name .. "party"..i, UIParent, "SecureUnitButtonTemplate")
		self[identifier]:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
		self[identifier]:SetAttribute('unit', "party"..i)
		self[identifier].menu = function (self)
			ToggleDropDownMenu(1, nil, getglobal("PartyMemberFrame"..i.."DropDown"),"cursor")
		end

		if(party_relative == UIParent) then
			self[identifier]:SetPoint("TOPLEFT", party_relative, "TOPLEFT", 15, -15)
		else
			self[identifier]:SetPoint("TOPLEFT", party_relative, "BOTTOMLEFT", 0, -1*party_offset)
		end

		mUI_UnitFramesSetRangeChecking(self[identifier], true)

		mUI_UnitframesInitialize(self[identifier], "party"..i, 
			mUI_GetVariableValueByName(self, "MenuB|Background"),
			mUI_GetVariableValueByName(self, "MenuC|StatusBar"),
			mUI_GetVariableValueByName(self, "MenuG|Party")
		)
		RegisterUnitWatch(self[identifier])
		if(i > num_members) then self[identifier]:Hide() end
		party_relative = self[identifier]
	end
end