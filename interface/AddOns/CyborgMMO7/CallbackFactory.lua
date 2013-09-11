-- the function call backs

CallbackFactory = {
	new = function()
		local self = {}
		self.Frame = CreateFrame("Frame","CallbackFactoryFrame", UIParent);
		self.Callbacks = {}
		self.Id = 1;

		self.AddCallback = function(fn)
			local name = "Button"..self.Id
			self.Callbacks[name] = CreateFrame("Button", name, self.Frame)
			self.Callbacks[name]:SetScript("OnClick", fn);
			self.Id = self.Id + 1;
			return self.Callbacks[name], self.Frame, name;
		end

		self.RemoveCallback = function(name)
			self.Callbacks[name] = nil
		end

		return self;
	end,

	m_Instance = nil,

	Instance = function()
		if(nil == CallbackFactory.m_Instance) then
			CallbackFactory.m_Instance = CallbackFactory.new();
		end
		return CallbackFactory.m_Instance;
	end

}


GetCallback = function(callbackName)
	local callback = nil
	if("Map" == callbackName) then
		callback = ToggleMap;
	elseif("CharacterPage" == callbackName) then
		callback = ToggleCharacterPage;
	elseif("Spellbook" == callbackName) then
		callback = ToggleSpellbook;
	elseif("Macros" == callbackName) then
		callback = ToggleMacros;
	elseif("QuestLog" == callbackName) then
		callback = ToggleQuests;
	elseif("Achievement" == callbackName) then
		callback = ToggleAchievements;
	elseif("Inventory" == callbackName) then
		callback = ToggleBags; 
	end;
	return callback;
end


ToggleMap = function()
	ToggleFrame(WorldMapFrame)
end

ToggleCharacterPage = function()
	ToggleCharacter("PaperDollFrame")
end

ToggleSpellbook = function()
	ToggleFrame(SpellBookFrame)
	if(SpellBookFrame:IsShown()) then
		SpellbookMicroButton:SetButtonState("PUSHED", 1);
	else
		SpellbookMicroButton:SetButtonState("NORMAL");
	end

end

ToggleMacros = function()
	if(MacroFrame:IsShown() and MacroFrame:IsVisible()) then
		HideUIPanel(MacroFrame);
	else
		ShowMacroFrame();
	end
end

ToggleQuests = function()
	ToggleFrame(QuestLogFrame);
	if ( QuestLogFrame:IsShown() ) then
		QuestLogMicroButton:SetButtonState("PUSHED", 1);
	else
		QuestLogMicroButton:SetButtonState("NORMAL");
	end
end

ToggleAchievements = function()
	ToggleAchievementFrame();
	if ( AchievementFrame and AchievementFrame:IsShown() ) then
		AchievementMicroButton:SetButtonState("PUSHED", 1);
	else
		if ( ( HasCompletedAnyAchievement() or IsInGuild() ) and CanShowAchievementUI() ) then
			AchievementMicroButton:Enable();
			AchievementMicroButton:SetButtonState("NORMAL");
		else
			AchievementMicroButton:Disable();
		end
	end
end

ToggleBags = function()
	ToggleAllBags();
end