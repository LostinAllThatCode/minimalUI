local unitframes = mUI:RegisterModule("unitframes")
local blizzard_ui_elements = { 	
	"PlayerFrame", "TargetFrame",
	"PartyMemberFrame1", "PartyMemberFrame2", 
	"PartyMemberFrame3", "PartyMemberFrame4" 
}

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

local function mUI_UnitframesGetBuffs(self)
	for slotindex, bufficon in ipairs(self.buffpanel.buffs) do
		local buff = { UnitBuff(self.entity, slotindex) }
		bufficon:SetTexture(buff[3] or "")		
	end
end

local function mUI_UnitframesAttachConfig(self, frame_layout, bars_layout, custom_layout)
	if(self.cfg == nil) then self.cfg = {} end
	self.cfg.frame  = frame_layout
	self.cfg.bars   = bars_layout
	self.cfg.custom = custom_layout
end

local function mUI_UnitFramesUpdateBars(self)
	local level = ""
	if(self.entitydata.classification ~= "normal") then
		level = " [".. self.entitydata.level .. " ".. strupper(self.entitydata.classification) .. "] "
	else
		level = " [".. self.entitydata.level .. "] "
	end
	local health_text =  level .. self.entitydata.name .. " " .. self.entitydata.hp .. "|".. self.entitydata.hpmax

	if(mUI_GetVariableValueByName(unitframes, "MenuA|General|Configuration_Mode") == false) then
		if(self.entitydata.isdead) then
			self.hp.text:SetText( " " .. self.entitydata.name)
			self.power.text:SetText( " DEAD " )
		elseif(self.entitydata.isghost) then
			self.hp.text:SetText( " " .. self.entitydata.name )
			self.power.text:SetText( " GHOST" )
		elseif(self.entitydata.disconnected) then
			self.hp.text:SetText( " " .. self.entitydata.name )
			self.power.text:SetText( " DISCONNECTED" )
		else
			self.hp.text:SetText( health_text )
			if(self.power:GetHeight() >= self.power.text:GetStringHeight()-2) then 
				self.power.text:SetText( " " .. self.entitydata.mp .. "|".. self.entitydata.mpmax)
			else
				self.power.text:SetText( " " )
			end
		end
	else
		self.hp.text:SetText( " NAME ")
		self.power.text:SetText( " MANA " )
	end

	local hp_max_size = self:GetWidth()-4
	local hp_percent  = self.entitydata.hp / self.entitydata.hpmax
	if(hp_percent == 0)
	then
		self.hp:SetWidth(-1)
	else
		self.hp:SetWidth(hp_percent * hp_max_size)
	end

	local power_max_size = self:GetWidth()-4
	local power_percent  = self.entitydata.mp / self.entitydata.mpmax
	if(power_percent == 0)
	then
		self.power:SetWidth(-1)
	else
		
		self.power:SetWidth(power_percent * power_max_size)
	end
end

local function mUI_UnitFramesUpdateBarColors(self)
	if(self.cfg.bars["HP_Bar_Color_Mode"].value == "CLASS") then
		classClr = mUI_GetClassColor(self.entity)
		self.hp:SetBackdropColor( classClr.r, classClr.g, classClr.b, self.cfg.bars["HP_Bar_Color"].value.a )
	elseif(self.cfg.bars["HP_Bar_Color_Mode"].value == "POWER") then
		powerClr = mUI_GetPowerColor(self.entity)
		self.hp:SetBackdropColor( powerClr.r, powerClr.g, powerClr.b, self.cfg.bars["HP_Bar_Color"].value.a )
	else
		self.hp:SetBackdropColor( mUI_GetColor(self.cfg.bars["HP_Bar_Color"].value) )
	end
	self.hp_deficit:SetBackdropColor( mUI_GetColor(self.cfg.bars["HP_Deficit_Bar_Color"].value) )

	if(self.cfg.bars["MP_Bar_Color_Mode"].value == "CLASS") then
		classClr = mUI_GetClassColor(self.entity)
		self.power:SetBackdropColor( classClr.r, classClr.g, classClr.b, self.cfg.bars["MP_Bar_Color"].value.a )
	elseif(self.cfg.bars["MP_Bar_Color_Mode"].value == "POWER") then
		powerClr = mUI_GetPowerColor(self.entity)
		self.power:SetBackdropColor( powerClr.r, powerClr.g, powerClr.b, self.cfg.bars["MP_Bar_Color"].value.a )
	else
		self.power:SetBackdropColor( mUI_GetColor(self.cfg.bars["MP_Bar_Color"].value) )
	end
	self.power_deficit:SetBackdropColor( mUI_GetColor(self.cfg.bars["MP_Deficit_Bar_Color"].value) )
end

local function mUI_UnitFramesFullUpdate(self)
	self:SetFrameStrata(self.cfg.custom["Strata"].value)
	self:SetWidth(self.cfg.custom["Frame_Width"].value)
	self:SetHeight(self.cfg.custom["Frame_Height"].value)
	self:SetBackdrop(DEFAULT_BACKDROP)
	self:SetBackdropColor(mUI_GetColor(self.cfg.frame["BG_Color"].value))
	self:SetBackdropBorderColor(mUI_GetColor(self.cfg.frame["Border_Color"].value))

	self.hp:SetHeight(self.cfg.custom["HP_Bar_Height"].value)
	self.hp:SetFrameStrata(self.cfg.custom["Strata"].value)
	self.hp:SetBackdrop(DEFAULT_BACKDROP_BORDERLESS)
	self.hp.text:SetFont(self.cfg.bars["HP_Font"].value, self.cfg.bars["HP_Font_Size"].value)
	self.hp.text:SetTextColor(mUI_GetColor(self.cfg.bars["HP_Font_Color"].value))
	self.hp.text:SetShadowColor(mUI_GetColor(self.cfg.bars["HP_Font_Shadow_Color"].value))

	self.hp_deficit:SetWidth(self.cfg.custom["Frame_Width"].value - 4)
	self.hp_deficit:SetHeight(self.cfg.custom["HP_Bar_Height"].value)
	self.hp_deficit:SetFrameStrata(self.cfg.custom["Strata"].value)
	self.hp_deficit:SetBackdrop(DEFAULT_BACKDROP_BORDERLESS)

	self.power:SetHeight(self.cfg.custom["MP_Bar_Height"].value)	
	self.power:SetFrameStrata(self.cfg.custom["Strata"].value)
	self.power:SetBackdrop(DEFAULT_BACKDROP_BORDERLESS)
	self.power.text:SetTextColor(mUI_GetColor(self.cfg.bars["MP_Font_Color"].value))
	self.power.text:SetFont(self.cfg.bars["MP_Font"].value, self.cfg.bars["MP_Font_Size"].value)
	self.power.text:SetShadowColor(mUI_GetColor(self.cfg.bars["MP_Font_Shadow_Color"].value))
	
	self.power_deficit:SetWidth(self.cfg.custom["Frame_Width"].value - 4)
	self.power_deficit:SetHeight(self.cfg.custom["MP_Bar_Height"].value)
	self.power_deficit:SetFrameStrata(self.cfg.custom["Strata"].value)
	self.power_deficit:SetBackdrop(DEFAULT_BACKDROP_BORDERLESS)

	if(self.rangecheck) then
		self.rangecheck.dtt     = interval or ( mUI_GetVariableValueByName(unitframes, "MenuA|Performance|Rangecheck_PartyRaid_Interval") / 1000.0)
	end

	if(self.dtt) then 
		self.dtt = mUI_GetVariableValueByName(unitframes, "MenuA|Performance|Target_Of_Target_Update_Interval") / 1000.0
	end

	self:DoUpdate()
end

local function mUI_UnitFramesUpdate(self)
	mUI_UnitframesGetBuffs(self)
	self:GetEntityData()
	self:UpdateBarColors()
	self:UpdateBars()
end

local function mUI_UnitFramesGetEntityData(self)
	if(self.entitydata == nil) then self.entitydata = {} end
	_, self.entitydata.class 		= UnitClass(self.entity)
	self.entitydata.name 			= UnitName(self.entity) or "Unknown"
	self.entitydata.level 			= UnitLevel(self.entity)
	self.entitydata.classification  = UnitClassification(self.entity)
	self.entitydata.hp 				= UnitHealth(self.entity) 
	self.entitydata.hpmax			= UnitHealthMax(self.entity) or 100
	self.entitydata.isdead 		 	= UnitIsDead(self.entity)
	self.entitydata.isghost 		= UnitIsGhost(self.entity)
	self.entitydata.mp 				= UnitMana(self.entity)
	self.entitydata.mpmax			= UnitManaMax(self.entity)
	self.entitydata.disconnected	= (self.entitydata.hpmax == 0 and self.entitydata.mpmax == 0)
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
	
	frame.hp_deficit = mUI_CreateDefaultFrame(frame, nil, frame:GetWidth()-4, 16)
	frame.hp_deficit:ClearAllPoints()
	frame.hp_deficit:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
	frame.hp_deficit:SetFrameLevel(2)

	frame.hp = mUI_CreateDefaultFrame(frame, nil, 1, 16)
	frame.hp:ClearAllPoints()
	frame.hp:SetPoint("TOPLEFT", frame.hp_deficit, "TOPLEFT")
	frame.hp:SetFrameLevel(3)
	frame.hp.text = mUI_FontString(frame.hp, nil, 12, {r=0,g=0,b=0,a=1})
	frame.hp.text:SetAllPoints(frame.hp_deficit)
	frame.hp.text:SetJustifyH("LEFT")
	frame.hp.text:SetJustifyV("CENTER")

	frame.power_deficit = mUI_CreateDefaultFrame(frame, nil, frame:GetWidth()-4, 16)
	frame.power_deficit:ClearAllPoints()
	frame.power_deficit:SetPoint("TOPLEFT", frame.hp_deficit, "BOTTOMLEFT", 0, -1)
	frame.power_deficit:SetFrameLevel(2)

	frame.power = mUI_CreateDefaultFrame(frame, nil, 1, 16)
	frame.power:ClearAllPoints()
	frame.power:SetPoint("TOPLEFT", frame.power_deficit, "TOPLEFT")
	frame.power:SetFrameLevel(3)
	frame.power.text = mUI_FontString(frame.power, nil, 12, {r=1,g=1,b=1,a=1})
	frame.power.text:SetAllPoints(frame.power_deficit)
	frame.power.text:SetJustifyH("LEFT")
	frame.power.text:SetJustifyV("TOP")

	frame.buffpanel = mUI_CreateDefaultFrame(frame, nil, 100, 16, "DIALOG")
	frame.buffpanel:SetPoint("BOTTOMLEFT", frame, "TOPLEFT")
	frame.buffpanel:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT")
	frame.buffpanel:SetBackdropColor(0,0,0,0)
	frame.buffpanel:SetFrameLevel(4)
	frame.buffpanel.buffs = {}
	for i=1, 10 do	
		frame.buffpanel.buffs[i] = frame.buffpanel:CreateTexture()
		frame.buffpanel.buffs[i]:SetPoint("TOPLEFT", frame.buffpanel, "TOPLEFT", ((i-1) * 16)+1, 0)
		frame.buffpanel.buffs[i]:SetHeight(16)
		frame.buffpanel.buffs[i]:SetWidth(16)
	end	

	frame.GetEntityData   = mUI_UnitFramesGetEntityData
	frame.UpdateBarColors = mUI_UnitFramesUpdateBarColors
	frame.UpdateBars 	  = mUI_UnitFramesUpdateBars
	frame.FullUpdate      = mUI_UnitFramesFullUpdate
	frame.DoUpdate   	  = mUI_UnitFramesUpdate

	frame:FullUpdate()
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

	mUI_SetVariable(self, "MenuA|General|Locked", 										"BOOLEAN", 			true)
	mUI_SetVariable(self, "MenuA|General|Configuration_Mode", 							"BOOLEAN", 			false) -- TODO: Make this a dropdown thing for None, Group, Raid

	mUI_SetVariable(self, "MenuA|Performance|Rangecheck_PartyRaid_Interval",			"NUMBERFIELD",		1000)
	mUI_SetVariable(self, "MenuA|Performance|Target_Of_Target_Update_Interval",			"NUMBERFIELD",		500)

	mUI_SetVariable(self, "MenuB|Background|Border_Color", 				"BORDERCOLOR", 		{r=1.0, g=0.0, b=1.0, a=0.0})
	mUI_SetVariable(self, "MenuB|Background|Border_Texture",			"TEXTURE", 			"Interface\\AddOns\\minimalUI\\img\\BorderShadow.tga")
	mUI_SetVariable(self, "MenuB|Background|BG_Color", 					"BGCOLOR",			{r=0.1, g=0.1, b=0.1, a=1.0})
	mUI_SetVariable(self, "MenuB|Background|BG_Texture",				"TEXTURE", 			"Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga")

	mUI_SetVariable(self, "MenuC|StatusBar|BG_Texture", 				"TEXTURE",			"Interface\\AddOns\\minimalUI\\img\\BackdropSolid.tga")
	
	mUI_SetVariable(self, "MenuC|StatusBar|HP_Bar_Color", 				"BGCOLOR",			{r=1.0, g=0.0, b=0.0, a=1.0})
	mUI_SetVariable(self, "MenuC|StatusBar|HP_Bar_Color_Mode",			"DYNAMIC_COLOR",	"CLASS")
	mUI_SetVariable(self, "MenuC|StatusBar|HP_Deficit_Bar_Color", 		"BGCOLOR",			{r=1.0, g=0.0, b=1.0, a=0.0})
	mUI_SetVariable(self, "MenuC|StatusBar|HP_Font",					"TEXTFIELD",		"Interface\\AddOns\\minimalUI\\Fonts\\homespun.ttf")
	mUI_SetVariable(self, "MenuC|StatusBar|HP_Font_Color",				"TEXTCOLOR",		{r=1.0, g=1.0, b=1.0, a=1.0})
	mUI_SetVariable(self, "MenuC|StatusBar|HP_Font_Shadow_Color",		"TEXTCOLOR",		{r=0.0, g=0.0, b=0.0, a=0.6})
	mUI_SetVariable(self, "MenuC|StatusBar|HP_Font_Size",				"NUMBERFIELD",		10)

	mUI_SetVariable(self, "MenuC|StatusBar|MP_Bar_Color", 				"BGCOLOR",			{r=1.0, g=0.0, b=0.0, a=1.0})
	mUI_SetVariable(self, "MenuC|StatusBar|MP_Bar_Color_Mode",			"DYNAMIC_COLOR",	"POWER")
	mUI_SetVariable(self, "MenuC|StatusBar|MP_Deficit_Bar_Color", 		"BGCOLOR",			{r=1.0, g=0.0, b=1.0, a=0.0})
	mUI_SetVariable(self, "MenuC|StatusBar|MP_Font",					"TEXTFIELD",		"Interface\\AddOns\\minimalUI\\Fonts\\homespun.ttf")
	mUI_SetVariable(self, "MenuC|StatusBar|MP_Font_Color",				"TEXTCOLOR",		{r=1.0, g=1.0, b=1.0, a=1.0})
	mUI_SetVariable(self, "MenuC|StatusBar|MP_Font_Shadow_Color",		"TEXTCOLOR",		{r=0.0, g=0.0, b=0.0, a=0.6})
	mUI_SetVariable(self, "MenuC|StatusBar|MP_Font_Size",				"NUMBERFIELD",		10)

	mUI_SetVariable(self, "MenuD|Player|Frame_Height",			"NUMBERFIELD", 		62)	
	mUI_SetVariable(self, "MenuD|Player|Frame_Width",			"NUMBERFIELD", 		180)
	mUI_SetVariable(self, "MenuD|Player|HP_Bar_Height",	 		"NUMBERFIELD", 		45)
	mUI_SetVariable(self, "MenuD|Player|MP_Bar_Height",	 		"NUMBERFIELD", 		12)
	mUI_SetVariable(self, "MenuD|Player|Strata", 				"STRATA", 			"LOW")	

	mUI_SetVariable(self, "MenuE|Target|MP_Bar_Height",			"NUMBERFIELD", 		12)
	mUI_SetVariable(self, "MenuE|Target|HP_Bar_Height",			"NUMBERFIELD", 		45)
	mUI_SetVariable(self, "MenuE|Target|Frame_Width", 			"NUMBERFIELD", 		180)
	mUI_SetVariable(self, "MenuE|Target|Frame_Height",			"NUMBERFIELD", 		62)
	mUI_SetVariable(self, "MenuE|Target|Strata", 				"STRATA", 			"LOW")

	mUI_SetVariable(self, "MenuF|TargetTarget|HP_Bar_Height",	"NUMBERFIELD", 		22)
	mUI_SetVariable(self, "MenuF|TargetTarget|MP_Bar_Height",	"NUMBERFIELD", 		3)
	mUI_SetVariable(self, "MenuF|TargetTarget|Frame_Width", 	"NUMBERFIELD", 		180)
	mUI_SetVariable(self, "MenuF|TargetTarget|Frame_Height",	"NUMBERFIELD", 		30)
	mUI_SetVariable(self, "MenuF|TargetTarget|Strata", 			"STRATA", 			"LOW")
	
	mUI_SetVariable(self, "MenuG|Party|HP_Bar_Height",			"NUMBERFIELD", 		23)
	mUI_SetVariable(self, "MenuG|Party|MP_Bar_Height",	 		"NUMBERFIELD", 		12)
	mUI_SetVariable(self, "MenuG|Party|Frame_Width", 			"NUMBERFIELD", 		180)
	mUI_SetVariable(self, "MenuG|Party|Frame_Height",			"NUMBERFIELD", 		40)
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
	for index, frame in ipairs(self.framelist) do frame:FullUpdate() end
end

function unitframes:OnEnable()
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
		if mUI_EventIsEither(event, "PARTY_MEMBERS_CHANGED", "PARTY_MEMBER_DISABLE", "PARTY_MEMBER_ENABLE") then
			local num_members = GetNumPartyMembers()
			for i=1, 4 do
				local identifier = "party"..i
				self[identifier]:DoUpdate()
				if(i > num_members) then
					self[identifier]:Hide()
				else
					self[identifier]:Show()
				end
			end
		end

		if mUI_EventIsEither(event, "UNIT_FACTION", "UPDATE_FACTION", "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_MANA", "UNIT_MAXMANA", "UNIT_RAGE", "UNIT_NAXRAGE", "UNIT_ENERGY", "UNIT_MAXENERGY") then 
			if(arg1 and self[arg1]) then self[arg1]:DoUpdate() end
		end

		if mUI_EventIsEither(event, "PLAYER_ENTERING_WORLD", "PLAYER_AURAS_CHANGED") then
			self.player:DoUpdate()
		end
	end)

	-- Registers all necessary event for the eventhandler
	mUI_EventRegisterList(eventhandler, 
		"UNIT_HEALTH", "UNIT_MAXHEALTH",  "UNIT_MANA", "UNIT_MAXMANA", "UNIT_RAGE",
	 	"UNIT_FACTION", "UPDATE_FACTION", 
		"UNIT_NAXRAGE", "UNIT_ENERGY", "UNIT_MAXENERGY", "PLAYER_ENTERING_WORLD", 
		"PARTY_MEMBERS_CHANGED", "PARTY_MEMBER_DISABLE", "PARTY_MEMBER_ENABLE",
		"PLAYER_AURAS_CHANGED"
	)


	-- Player unitframe initialiation
	self.player = CreateFrame("Button", "mUI"..self.name .. "player", UIParent, "SecureActionButtonTemplate")
	self.player:SetPoint("CENTER", UIParent, "CENTER", -200, 0)
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

	-- Target unitframe initialiation
	self.target = CreateFrame("Button", "mUI"..self.name .. "target", UIParent, "SecureUnitButtonTemplate")
	self.target:EnableMouse(true)
	self.target:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	self.target:RegisterEvent("PLAYER_TARGET_CHANGED", "UNIT_TARGET")
	self.target:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
	self.target:SetScript("OnEvent", function () this:DoUpdate() end)
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

	-- TargetTarget unitframe initialiation
	self.targettarget = CreateFrame("Button", "mUI"..self.name .. "targettarget", UIParent, "SecureUnitButtonTemplate")
	self.targettarget:SetPoint("CENTER", UIParent, "CENTER", -200, -100)
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
			this:DoUpdate()
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

	-- Party unitframe initialiation
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
			self[identifier]:SetPoint("TOPLEFT", party_relative, "BOTTOMLEFT", 0, -5)
		end

		mUI_UnitFramesSetRangeChecking(self[identifier], true)

		mUI_UnitframesInitialize(self[identifier], "party"..i, 
			mUI_GetVariableValueByName(self, "MenuB|Background"),
			mUI_GetVariableValueByName(self, "MenuC|StatusBar"),
			mUI_GetVariableValueByName(self, "MenuG|Party")
		)

		if(i > num_members) then self[identifier]:Hide() end
		party_relative = self[identifier]
	end
end