mUI = CreateFrame("Frame", nil, UIParent)
mUI.modules = {}
mUI:RegisterEvent("ADDON_LOADED")

SLASH_MUI1 = '/mui'
function SlashCmdList.MUI(msg, editbox)
  if mUI.gui:IsVisible() then
    mUI.gui:Hide()
  else
    mUI.gui:Show()
  end
end

SLASH_RELOAD1 = '/rl'
function SlashCmdList.RELOAD(msg, editbox)
  ReloadUI()
end

function mUI:SetGridView(enabled)
	if(enabled) then
		self.grid_view:Show()
	else
		self.grid_view:Hide()
	end
end

function mUI:SetPixelPerfect(enabled)
  if(enabled == true) then
    local resolution = GetCVar("gxResolution")
    for screenwidth, screenheight in string.gmatch(resolution, "(.+)x(.+)") do
      local scale = (min(2, max(.64, 768/screenheight)))
      SetCVar("UseUIScale", 1)
      SetCVar("UIScale", scale)

      -- scale UIParent to native screensize
      UIParent:SetWidth(screenwidth)
      UIParent:SetHeight(screenheight)
      UIParent:SetPoint("CENTER",0,0)
    end
  else
  	SetCVar("UseUIScale", 0)
  end
end

function mUI:VariableChanged(var)
	if(var.name == "Pixel_Perfect_Mode") then
		mUI:SetPixelPerfect(var.value)
	end
end


mUI:SetScript("OnEvent", function()
	if(event == "ADDON_LOADED")
	then
		if(arg1 == "minimalUI")
		then			
			mUI_ConfigInitialize()

			for name in pairs(this.modules)
			do
				local module = this.modules[name]
				if(module ~= nil)
				then
					-- Module initialization
					if(mui_config[module.name] == nil)
					then
						mui_config[module.name] = {}
						mUI_SetVariable(module, "Menu0|Enabled", "BOOLEAN", true)
						module:OnLoadDefaults(mui_config[module.name])
					end
					module.config = mui_config[module.name]
					local IsEnabled = mUI_GetVariableValueByName(module, "Menu0|Enabled")
					if(IsEnabled)
					then
						module:OnEnable()
					else
						mUI_DebugMessage("|cffff88ffModule "..module.name .. " is disabled!")
					end
				end
			end

			this.gui = mUI_GenerateConfigFrame()
			this.gui:Hide()

			-- Grid view
			this.grid_view = CreateFrame("Frame")
			this.grid_view:SetWidth(GetScreenWidth())
			this.grid_view:SetHeight(GetScreenHeight())
			this.grid_view:SetPoint("CENTER", UIParent, "CENTER", -4, -4)
			this.grid_view:SetBackdrop({ 
				bgFile = "Interface\\AddOns\\minimalUI\\img\\Cross.tga", 
				edgeFile = "", 
				tile = true, tileSize = 0, edgeSize = 8, insets = { left = 0, right = 0, top = 0, bottom = 0 } 
			})
			this.grid_view:SetFrameStrata("BACKGROUND")
			this.grid_view:SetBackdropColor(0,1,0,1)
			this.grid_view:SetAlpha(.25)
			this.grid_view:Hide()
		end
	else
		for name in pairs(this.modules)
		do
			local module = this.modules[name]
			if(module ~= nil)
			then
				for i,e in ipairs(module.events) do
					if(event == module.events[i])
					then
						module:OnEvent(event, arg1, arg2, arg3, arg4)
					end
				end
			end
		end
		mUI_DebugMessage("Unhandled registered event. " .. event .. " " .. tostring(arg1))
	end
end)

-- Registers a module. Also registers events if specified as following arguments
-- Example: local newModule = mUI:RegisterEvent("myNewModule", "PLAYER_ENTERING_WORLD")
function mUI:RegisterModule(name, ...)
	if(self.modules[name] == nil)
	then
		self.modules[name] = {}
		self.modules[name].name = tostring(name)
		self.modules[name].events = {}
		self.modules[name].OnLoadDefaults 	= function() end -- stub function
		self.modules[name].OnEnable 		= function() end -- stub function
		self.modules[name].OnDisable 		= function() end -- stub function		                            		                 
		
		local arg = {...}
		if(arg ~= nil)
		then
			for i, v in ipairs(arg)
			do
				local event = tostring(arg[i])
        		self:RegisterEvent(event)
        		table.insert(self.modules[name].events, event)
      		end
		end
	end
	return self.modules[name]
end