local spartan = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local addon = spartan:GetModule("PlayerFrames");
----------------------------------------------------------------------------------------------------
suiChar.PlayerFrames = suiChar.PlayerFrames or {};
suiChar.PlayerFrames.Castbar = suiChar.PlayerFrames.Castbar or {};

local base_plate1 = [[Interface\AddOns\SpartanUI_PlayerFrames\media\base_plate1]]
local base_plate2 = [[Interface\AddOns\SpartanUI_PlayerFrames\media\base_plate2.blp]]
local base_ring1 = [[Interface\AddOns\SpartanUI_PlayerFrames\media\base_ring1]]
local base_plate3 = [[Interface\AddOns\SpartanUI_PlayerFrames\media\base_plate3]]
local base_ring3 = [[Interface\AddOns\SpartanUI_PlayerFrames\media\base_ring3]]

local colors = setmetatable({},{__index = oUF.colors});
for k,v in pairs(oUF.colors) do if not colors[k] then colors[k] = v end end
do -- setup custom colors that we want to use
	colors.health 		= {0,1,50/255};			-- the color of health bars
	colors.reaction[1]	= {1, 50/255, 0};		-- Hated
	colors.reaction[2]	= colors.reaction[1];	-- Hostile
	colors.reaction[3]	= {1, 150/255, 0};		-- Unfriendly
	colors.reaction[4]	= {1, 220/255, 0};		-- Neutral
	colors.reaction[5]	= colors.health;		-- Friendly
	colors.reaction[6]	= colors.health;		-- Honored
	colors.reaction[7]	= colors.health;		-- Revered
	colors.reaction[8]	= colors.health;		-- Exalted
end

local menu = function(self)
	local unit = string.gsub(self.unit,"(.)",string.upper,1);
	if (_G[unit..'FrameDropDown']) then
		ToggleDropDownMenu(1, nil, _G[unit..'FrameDropDown'], 'cursor')
	end
end

local threat = function(self,event,unit)
	if (not self.Portrait) then return; end
	if (not self.Portrait:IsObjectType("Texture")) then return; end
	unit = string.gsub(self.unit,"(.)",string.upper,1) or string.gsub(unit,"(.)",string.upper,1)
	local status
	if UnitExists(unit) then status = UnitThreatSituation(unit) else status = 0; end
	if (status and status > 0) then
		local r,g,b = GetThreatStatusColor(status);
		self.Portrait:SetVertexColor(r,g,b);
	else
		self.Portrait:SetVertexColor(1,1,1);
	end
end

local name = function(self)
	if (UnitIsEnemy(self.unit,"player")) then self.Name:SetTextColor(1, 50/255, 0);
	elseif (UnitIsUnit(self.unit,"player")) then self.Name:SetTextColor(1, 1, 1); 
	else
		local r,g,b = unpack(colors.reaction[UnitReaction(self.unit,"player")] or {1,1,1});
		self.Name:SetTextColor(r,g,b);
	end
end

local PostUpdateAura = function(self,unit)
	if suiChar and suiChar.PlayerFrames and suiChar.PlayerFrames[unit] == 0 then
		self:Hide();
	else
		self:Show();
	end
end

local PostCastStop = function(self)
	if self.Time then self.Time:SetTextColor(1,1,1); end
end

local PostCastStart = function(self,unit,name,rank,text,castid)
	self:SetStatusBarColor(1,0.7,0);
end

local PostChannelStart = function(self,unit,name,rank,text,castid)
	self:SetStatusBarColor(1,0.2,0.7);
end

local OnCastbarUpdate = function(self,elapsed)
	if self.casting then
		self.duration = self.duration + elapsed
		if (self.duration >= self.max) then
			self.casting = nil;
			self:Hide();
			if PostCastStop then PostCastStop(self:GetParent()); end
			if PostCastStop then PostCastStop(self); end
			return;
		end
		if self.Time then
			if self.delay ~= 0 then self.Time:SetTextColor(1,0,0); else self.Time:SetTextColor(1,1,1); end
			if suiChar.PlayerFrames.Castbar.text[self:GetParent().unit] == 1 then
				self.Time:SetFormattedText("%.1f",self.max - self.duration);
			else
				self.Time:SetFormattedText("%.1f",self.duration);
			end
		end
		if suiChar.PlayerFrames.Castbar[self:GetParent().unit] == 1 then
			self:SetValue(self.max-self.duration)
		else
			self:SetValue(self.duration)
		end
	elseif self.channeling then
		self.duration = self.duration - elapsed;
		if (self.duration <= 0) then
			self.channeling = nil;
			self:Hide();
			if PostChannelStop then PostChannelStop(self:GetParent()); end
			return;
		end
		if self.Time then
			if self.delay ~= 0 then self.Time:SetTextColor(1,0,0); else self.Time:SetTextColor(1,1,1); end
				self.Time:SetFormattedText("%.1f",self.max-self.duration);
		end
		if suiChar.PlayerFrames.Castbar[self:GetParent().unit] == 1 then
			self:SetValue(self.duration)
		else
			self:SetValue(self.max-self.duration)
		end
	else
		self.unitName = nil;
		self.channeling = nil;
		self:SetValue(1);
		self:Hide();
	end
end

local CreatePlayerFrame = function(self,unit)
	self:SetWidth(280); self:SetHeight(80);
	do -- setup base artwork
		local artwork = CreateFrame("Frame",nil,self);
		artwork:SetFrameStrata("BACKGROUND");
		artwork:SetFrameLevel(0); artwork:SetAllPoints(self);
		
		artwork.bg = artwork:CreateTexture(nil,"BACKGROUND");
		artwork.bg:SetPoint("CENTER");
		artwork.bg:SetTexture(base_plate1);
		
		self.Portrait = self:CreateTexture(nil,"BORDER");
		self.Portrait:SetWidth(64); self.Portrait:SetHeight(64);
		self.Portrait:SetPoint("CENTER",self,"CENTER",80,3);
		
		self.Threat = CreateFrame("Frame",nil,self);
		self.Threat.Override = threat;
	end
	do -- setup status bars
		do -- cast bar
			local cast = CreateFrame("StatusBar",nil,self);
			cast:SetFrameStrata("BACKGROUND"); cast:SetFrameLevel(2);
			cast:SetWidth(153); cast:SetHeight(16);
			cast:SetPoint("TOPLEFT",self,"TOPLEFT",36,-23);
			
			cast.Text = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Text:SetWidth(135); cast.Text:SetHeight(11);
			cast.Text:SetJustifyH("RIGHT"); cast.Text:SetJustifyV("MIDDLE");
			cast.Text:SetPoint("LEFT",cast,"LEFT",4,0);
			
			cast.Time = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Time:SetWidth(90); cast.Time:SetHeight(11);
			cast.Time:SetJustifyH("RIGHT"); cast.Time:SetJustifyV("MIDDLE");
			cast.Time:SetPoint("RIGHT",cast,"LEFT",-2,0);
			
			self.Castbar = cast;
			self.Castbar.OnUpdate = OnCastbarUpdate;
			self.Castbar.PostCastStart = PostCastStart;
			self.Castbar.PostChannelStart = PostChannelStart;
			self.Castbar.PostCastStop = PostCastStop;
		end
		do -- health bar
			local health = CreateFrame("StatusBar",nil,self);
			health:SetFrameStrata("BACKGROUND"); health:SetFrameLevel(2);
			health:SetSize(150, 16);
			health:SetPoint("TOPLEFT",self.Castbar,"BOTTOMLEFT",0,-2);
			
			health.value = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.value:SetSize(135, 11);
			health.value:SetJustifyH("RIGHT"); health.value:SetJustifyV("MIDDLE");
			health.value:SetPoint("LEFT",health,"LEFT",4,0);
			self:Tag(health.value, '[curhp]/[maxhp]')
			
			health.ratio = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.ratio:SetSize(90, 11);
			health.ratio:SetJustifyH("RIGHT"); health.ratio:SetJustifyV("MIDDLE");
			health.ratio:SetPoint("RIGHT",health,"LEFT",-2,0);
			self:Tag(health.ratio, '[perhp]%')
			
			self.Health = health;
			self.Health.frequentUpdates = true;
			self.Health.colorDisconnected = true;
			self.Health.colorHealth = true;
			
			-- Position and size
			local myBars = CreateFrame('StatusBar', nil, self.Health)
			myBars:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			myBars:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			myBars:SetStatusBarTexture("Interface\TargetingFrame\UI-StatusBar")
			myBars:SetStatusBarColor(0, 1, 0.5, 0.45)

			local otherBars = CreateFrame('StatusBar', nil, myBars)
			otherBars:SetPoint('TOPLEFT', myBars:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			otherBars:SetPoint('BOTTOMLEFT', myBars:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			otherBars:SetStatusBarTexture("Interface\TargetingFrame\UI-StatusBar")
			otherBars:SetStatusBarColor(0, 0.5, 1, 0.45)

			myBars:SetSize(150, 16)
			otherBars:SetSize(150, 16)
			
			self.HealPrediction = {
				myBar = myBars,
				otherBar = otherBars,
				maxOverflow = 1,
			}
			
		end
		do -- power bar
			local power = CreateFrame("StatusBar",nil,self);
			power:SetFrameStrata("BACKGROUND"); power:SetFrameLevel(2);
			power:SetWidth(155); power:SetHeight(14);
			power:SetPoint("TOPLEFT",self.Health,"BOTTOMLEFT",0,-2);
			
			power.value = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.value:SetWidth(135); power.value:SetHeight(11);
			power.value:SetJustifyH("RIGHT"); power.value:SetJustifyV("MIDDLE");
			power.value:SetPoint("LEFT",power,"LEFT",4,0);
			self:Tag(power.value, '[curpp]/[maxpp]')
			
			power.ratio = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.ratio:SetWidth(90); power.ratio:SetHeight(11);
			power.ratio:SetJustifyH("RIGHT"); power.ratio:SetJustifyV("MIDDLE");
			power.ratio:SetPoint("RIGHT",power,"LEFT",-2,0);
			self:Tag(power.ratio, '[perpp]%')
			
			self.Power = power;
			self.Power.colorPower = true;
			self.Power.frequentUpdates = true;
			
		end
	end
	do -- setup ring, icons, and text
		local ring = CreateFrame("Frame",nil,self);
		ring:SetFrameStrata("BACKGROUND");
		ring:SetAllPoints(self.Portrait); ring:SetFrameLevel(3);
		ring.bg = ring:CreateTexture(nil,"BACKGROUND");
		ring.bg:SetPoint("CENTER",ring,"CENTER",-80,-3);
		ring.bg:SetTexture(base_ring1);
		
		self.Name = ring:CreateFontString(nil, "BORDER","SUI_FontOutline12");
		self.Name:SetHeight(12); self.Name:SetWidth(170); self.Name:SetJustifyH("RIGHT");
		self.Name:SetPoint("TOPLEFT",self,"TOPLEFT",5,-6);
		self:Tag(self.Name, "[name]");
		
		self.Level = ring:CreateFontString(nil,"BORDER","SUI_FontOutline11");
		self.Level:SetWidth(40); self.Level:SetHeight(11);
		self.Level:SetJustifyH("CENTER"); self.Level:SetJustifyV("MIDDLE");
		self.Level:SetPoint("CENTER",ring,"CENTER",51,12);
		self:Tag(self.Level, "[level]");
		
		self.SUI_ClassIcon = ring:CreateTexture(nil,"BORDER");
		self.SUI_ClassIcon:SetWidth(22); self.SUI_ClassIcon:SetHeight(22);
		self.SUI_ClassIcon:SetPoint("CENTER",ring,"CENTER",-29,21);
		
		self.Leader = ring:CreateTexture(nil,"BORDER");
		self.Leader:SetWidth(20); self.Leader:SetHeight(20);
		self.Leader:SetPoint("CENTER",ring,"TOP");
		
		self.MasterLooter = ring:CreateTexture(nil,"BORDER");
		self.MasterLooter:SetWidth(18); self.MasterLooter:SetHeight(18);
		self.MasterLooter:SetPoint("CENTER",ring,"TOPRIGHT",-6,-6);
		
		self.PvP = ring:CreateTexture(nil,"BORDER");
		self.PvP:SetWidth(48); self.PvP:SetHeight(48);
		self.PvP:SetPoint("CENTER",ring,"CENTER",32,-40);
		
		self.LFDRole = ring:CreateTexture(nil,"BORDER");
		self.LFDRole:SetWidth(28); self.LFDRole:SetHeight(28);
		self.LFDRole:SetPoint("CENTER",ring,"CENTER",-20,-35);
		self.LFDRole:SetTexture[[Interface\AddOns\SpartanUI_PlayerFrames\media\icon_role]];
		
		self.Resting = ring:CreateTexture(nil,"ARTWORK");
		self.Resting:SetWidth(32); self.Resting:SetHeight(30);
		self.Resting:SetPoint("CENTER",self.SUI_ClassIcon,"CENTER");
		
		self.Combat = ring:CreateTexture(nil,"ARTWORK");
		self.Combat:SetWidth(32); self.Combat:SetHeight(32);
		self.Combat:SetPoint("CENTER",self.Level,"CENTER");
		
		self.RaidIcon = ring:CreateTexture(nil,"ARTWORK");
		self.RaidIcon:SetWidth(24); self.RaidIcon:SetHeight(24);
		self.RaidIcon:SetPoint("CENTER",ring,"LEFT",-2,-3);
		
		self.StatusText = ring:CreateFontString(nil, "OVERLAY", "SUI_FontOutline22");
		self.StatusText:SetPoint("CENTER",ring,"CENTER");
		self.StatusText:SetJustifyH("CENTER");
		self:Tag(self.StatusText, "[afkdnd]");
	end
	do -- setup buffs and debuffs
		self.Auras = CreateFrame("Frame",nil,self);
		self.Auras:SetWidth(22*10); self.Auras:SetHeight(22*2);
		self.Auras:SetPoint("BOTTOMLEFT",self,"TOPLEFT",10,0);
		self.Auras:SetFrameStrata("BACKGROUND");
		self.Auras:SetFrameLevel(4);
		-- settings
		self.Auras.size = 20; self.Auras.spacing = 1;
		self.Auras.initialAnchor = "BOTTOMLEFT";
		self.Auras["growth-x"] = "RIGHT";
		self.Auras["growth-y"] = "UP";
		self.Auras.gap = true;
		self.Auras.numBuffs = 10;
		self.Auras.numDebuffs = 10;
		
		self.Auras.PostUpdate = PostUpdateAura;
	end
	return self;
end

local CreateTargetFrame = function(self,unit)
	self:SetWidth(280); self:SetHeight(80);
	do --setup base artwork
		local artwork = CreateFrame("Frame",nil,self);
		artwork:SetFrameStrata("BACKGROUND");
		artwork:SetFrameLevel(0); artwork:SetAllPoints(self);
		
		artwork.bg = artwork:CreateTexture(nil,"BACKGROUND");
		artwork.bg:SetPoint("CENTER");
		artwork.bg:SetTexture(base_plate1);
		artwork.bg:SetTexCoord(1,0,0,1);
		
		self.Portrait = self:CreateTexture(nil,"BORDER");
		self.Portrait:SetWidth(64); self.Portrait:SetHeight(64);
		self.Portrait:SetPoint("CENTER",self,"CENTER",-80,3);
		
		self.Threat = CreateFrame("Frame",nil,self);
		self.Threat.Override = threat;
	end
	do -- setup status bars
		do -- cast bar
			local cast = CreateFrame("StatusBar",nil,self);
			cast:SetFrameStrata("BACKGROUND"); cast:SetFrameLevel(2);
			cast:SetWidth(153); cast:SetHeight(16);
			cast:SetPoint("TOPRIGHT",self,"TOPRIGHT",-36,-23);
			
			cast.Text = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Text:SetWidth(135); cast.Text:SetHeight(11);
			cast.Text:SetJustifyH("LEFT"); cast.Text:SetJustifyV("MIDDLE");
			cast.Text:SetPoint("RIGHT",cast,"RIGHT",-4,0);
			
			cast.Time = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Time:SetWidth(90); cast.Time:SetHeight(11);
			cast.Time:SetJustifyH("LEFT"); cast.Time:SetJustifyV("MIDDLE");
			cast.Time:SetPoint("LEFT",cast,"RIGHT",2,0);
			
			self.Castbar = cast;
			self.Castbar.OnUpdate = OnCastbarUpdate;
			self.Castbar.PostCastStart = PostCastStart;
			self.Castbar.PostChannelStart = PostChannelStart;
			self.Castbar.PostCastStop = PostCastStop;
		end
		do -- health bar
			local health = CreateFrame("StatusBar",nil,self);
			health:SetFrameStrata("BACKGROUND"); health:SetFrameLevel(2);
			health:SetWidth(150); health:SetHeight(16);
			health:SetPoint("TOPRIGHT",self.Castbar,"BOTTOMRIGHT",0,-2);
			
			health.value = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.value:SetWidth(135); health.value:SetHeight(11);
			health.value:SetJustifyH("LEFT"); health.value:SetJustifyV("MIDDLE");
			health.value:SetPoint("RIGHT",health,"RIGHT",-4,0);
			self:Tag(health.value, '[curhp]/[maxhp]')	
			
			health.ratio = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.ratio:SetWidth(90); health.ratio:SetHeight(11);
			health.ratio:SetJustifyH("LEFT"); health.ratio:SetJustifyV("MIDDLE");
			health.ratio:SetPoint("LEFT",health,"RIGHT",2,0);
			self:Tag(health.ratio, '[perhp]%')
			
			self.Health = health;
			self.Health.frequentUpdates = true;
			self.Health.colorTapping = true;
			self.Health.colorDisconnected = true;
			self.Health.colorHealth = true;
			self.Health.colorReaction = true;
			-- Position and size
			local myBars = CreateFrame('StatusBar', nil, self.Health)
			myBars:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			myBars:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			myBars:SetStatusBarTexture("Interface\TargetingFrame\UI-StatusBar")
			myBars:SetStatusBarColor(0, 1, 0.5, 0.45)

			local otherBars = CreateFrame('StatusBar', nil, myBars)
			otherBars:SetPoint('TOPLEFT', myBars:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			otherBars:SetPoint('BOTTOMLEFT', myBars:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			otherBars:SetStatusBarTexture("Interface\TargetingFrame\UI-StatusBar")
			otherBars:SetStatusBarColor(0, 0.5, 1, 0.45)

			myBars:SetSize(150, 16)
			otherBars:SetSize(150, 16)
			
			self.HealPrediction = {
				myBar = myBars,
				otherBar = otherBars,
				maxOverflow = 1,
			}
			
		end
		do -- power bar
			local power = CreateFrame("StatusBar",nil,self);
			power:SetFrameStrata("BACKGROUND"); power:SetFrameLevel(2);
			power:SetWidth(155); power:SetHeight(14);
			power:SetPoint("TOPRIGHT",self.Health,"BOTTOMRIGHT",0,-2);
			
			power.value = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.value:SetWidth(135); power.value:SetHeight(11);
			power.value:SetJustifyH("LEFT"); power.value:SetJustifyV("MIDDLE");
			power.value:SetPoint("RIGHT",power,"RIGHT",-4,0);
			self:Tag(power.value, '[curpp]/[maxpp]')
			
			power.ratio = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.ratio:SetWidth(90); power.ratio:SetHeight(11);
			power.ratio:SetJustifyH("LEFT"); power.ratio:SetJustifyV("MIDDLE");
			power.ratio:SetPoint("LEFT",power,"RIGHT",2,0);
			self:Tag(power.ratio, '[perpp]%')
			
			self.Power = power;
			self.Power.colorPower = true;
			self.Power.frequentUpdates = true;
			
		end
	end
	do -- setup ring, icons, and text
		local ring = CreateFrame("Frame",nil,self);
		ring:SetFrameStrata("BACKGROUND");
		ring:SetAllPoints(self.Portrait); ring:SetFrameLevel(3);
		ring.bg = ring:CreateTexture(nil,"BACKGROUND");
		ring.bg:SetPoint("CENTER",ring,"CENTER",80,-3);
		ring.bg:SetTexture(base_ring1);
		ring.bg:SetTexCoord(1,0,0,1);
		
		self.Name = ring:CreateFontString(nil, "BORDER","SUI_FontOutline12");
		self.Name:SetWidth(170); self.Name:SetHeight(12); 
		self.Name:SetJustifyH("LEFT"); self.Name:SetJustifyV("MIDDLE");
		self.Name:SetPoint("TOPRIGHT",self,"TOPRIGHT",-5,-6);
		self:Tag(self.Name,"[name]");
		
		self.Level = ring:CreateFontString(nil,"BORDER","SUI_FontOutline11");
		self.Level:SetWidth(40); self.Level:SetHeight(11);
		self.Level:SetJustifyH("CENTER"); self.Level:SetJustifyV("MIDDLE");
		self.Level:SetPoint("CENTER",ring,"CENTER",-50,12);
		self:Tag(self.Level, "[difficulty][level]");
		
		self.SUI_ClassIcon = ring:CreateTexture(nil,"BORDER");
		self.SUI_ClassIcon:SetWidth(22); self.SUI_ClassIcon:SetHeight(22);
		self.SUI_ClassIcon:SetPoint("CENTER",ring,"CENTER",29,21);
		
		self.Leader = ring:CreateTexture(nil,"BORDER");
		self.Leader:SetWidth(20); self.Leader:SetHeight(20);
		self.Leader:SetPoint("CENTER",ring,"TOP");
		
		self.MasterLooter = ring:CreateTexture(nil,"BORDER");
		self.MasterLooter:SetWidth(18); self.MasterLooter:SetHeight(18);
		self.MasterLooter:SetPoint("CENTER",ring,"TOPLEFT",6,-6);
		
		self.PvP = ring:CreateTexture(nil,"BORDER");
		self.PvP:SetWidth(48); self.PvP:SetHeight(48);
		self.PvP:SetPoint("CENTER",ring,"CENTER",-16,-40);
		
		self.LevelSkull = ring:CreateTexture(nil,"ARTWORK");
		self.LevelSkull:SetWidth(16); self.LevelSkull:SetHeight(16);
		self.LevelSkull:SetPoint("CENTER",self.Level,"CENTER");
		
		self.RareElite = ring:CreateTexture(nil,"ARTWORK");
		self.RareElite:SetWidth(150); self.RareElite:SetHeight(150);
		self.RareElite:SetPoint("CENTER",ring,"CENTER",-12,-4);
		
		self.RaidIcon = ring:CreateTexture(nil,"ARTWORK");
		self.RaidIcon:SetWidth(24); self.RaidIcon:SetHeight(24);
		self.RaidIcon:SetPoint("CENTER",ring,"RIGHT",2,-4);
		
		self.StatusText = ring:CreateFontString(nil, "OVERLAY", "SUI_FontOutline22");
		self.StatusText:SetPoint("CENTER",ring,"CENTER");
		self.StatusText:SetJustifyH("CENTER");
		self:Tag(self.StatusText, "[afkdnd]");
		
		self.CPoints = ring:CreateFontString(nil, "BORDER","SUI_FontOutline13");
		self.CPoints:SetPoint("TOPLEFT",ring,"BOTTOMRIGHT",8,-4);
		for i = 1, 5 do
			self.CPoints[i] = ring:CreateTexture(nil,"OVERLAY");
			self.CPoints[i]:SetTexture([[Interface\AddOns\SpartanUI_PlayerFrames\media\icon_combo]]);
			if (i == 1) then self.CPoints[1]:SetPoint("LEFT",self.CPoints,"RIGHT",1,-1); else 
				self.CPoints[i]:SetPoint("LEFT",self.CPoints[i-1],"RIGHT",-2,0);
			end
		end
		ring:SetScript("OnUpdate",function()
			if self.CPoints then
				local cp = GetComboPoints("player","target");
				self.CPoints:SetText( (cp > 0 and cp) or "");
			end
		end);
	end
	do -- setup buffs and debuffs
		self.Auras = CreateFrame("Frame",nil,self);
		self.Auras:SetWidth(22*10); self.Auras:SetHeight(22*2);
		self.Auras:SetPoint("BOTTOMRIGHT",self,"TOPRIGHT",-10,0);
		self.Auras:SetFrameStrata("BACKGROUND");
		self.Auras:SetFrameLevel(4);
		-- settings
		self.Auras.size = 20; self.Auras.spacing = 1;
		self.Auras.initialAnchor = "BOTTOMRIGHT";
		self.Auras["growth-x"] = "LEFT";
		self.Auras["growth-y"] = "UP";
		self.Auras.gap = false;
		self.Auras.numBuffs = 10;
		self.Auras.numDebuffs = 10;
		
		self.Auras.PostUpdate = PostUpdateAura;
	end
	return self;
end

local CreatePetFrame = function(self,unit)
	self:SetWidth(210); self:SetHeight(60);
	do -- setup base artwork
		local artwork = CreateFrame("Frame",nil,self);
		artwork:SetFrameStrata("BACKGROUND");
		artwork:SetFrameLevel(0); artwork:SetAllPoints(self);
		
		artwork.bg = artwork:CreateTexture(nil,"BACKGROUND");
		artwork.bg:SetPoint("CENTER"); artwork.bg:SetTexture(base_plate3);
		artwork.bg:SetWidth(256); artwork.bg:SetHeight(85);
		artwork.bg:SetTexCoord(0,1,0,85/128);
		
		self.Portrait = self:CreateTexture(nil,"BACKGROUND");
		self.Portrait:SetWidth(56); self.Portrait:SetHeight(50);
		self.Portrait:SetPoint("CENTER",self,"CENTER",87,-8);
		
		self.Threat = CreateFrame("Frame",nil,self);
		self.Threat.Override = threat;
	end
	do -- setup status bars
		do -- cast bar
			local cast = CreateFrame("StatusBar",nil,self);
			cast:SetFrameStrata("BACKGROUND"); cast:SetFrameLevel(2);
			cast:SetWidth(120); cast:SetHeight(15);
			cast:SetPoint("TOPLEFT",self,"TOPLEFT",36,-23);
			
			cast.Text = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Text:SetWidth(110); cast.Text:SetHeight(11);
			cast.Text:SetJustifyH("RIGHT"); cast.Text:SetJustifyV("MIDDLE");
			cast.Text:SetPoint("LEFT",cast,"LEFT",4,0);
			
			cast.Time = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Time:SetWidth(40); cast.Time:SetHeight(11);
			cast.Time:SetJustifyH("RIGHT"); cast.Time:SetJustifyV("MIDDLE");
			cast.Time:SetPoint("RIGHT",cast,"LEFT",-2,0);
			
			self.Castbar = cast;
			self.Castbar.OnUpdate = OnCastbarUpdate;
			self.Castbar.PostCastStart = PostCastStart;
			self.Castbar.PostChannelStart = PostChannelStart;
			self.Castbar.PostCastStop = PostCastStop;
		end
		do -- health bar
			local health = CreateFrame("StatusBar",nil,self);
			health:SetFrameStrata("BACKGROUND"); health:SetFrameLevel(2);
			health:SetWidth(120); health:SetHeight(16);
			health:SetPoint("TOPLEFT",self.Castbar,"BOTTOMLEFT",0,-2);
			
			health.value = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.value:SetWidth(110); health.value:SetHeight(11);
			health.value:SetJustifyH("RIGHT"); health.value:SetJustifyV("MIDDLE");
			health.value:SetPoint("LEFT",health,"LEFT",4,0);
			self:Tag(health.value, '[curhp]/[maxhp]')
			
			health.ratio = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.ratio:SetWidth(40); health.ratio:SetHeight(11);
			health.ratio:SetJustifyH("RIGHT"); health.ratio:SetJustifyV("MIDDLE");
			health.ratio:SetPoint("RIGHT",health,"LEFT",-2,0);
			self:Tag(health.ratio, '[perhp]%')
			
			self.Health = health;
			self.Health.colorHealth = true;
			self.Health.PostUpdate = PostUpdateHealth;
		end
		do -- power bar
			local power = CreateFrame("StatusBar",nil,self);
			power:SetFrameStrata("BACKGROUND"); power:SetFrameLevel(2);
			power:SetWidth(135); power:SetHeight(14);
			power:SetPoint("TOPLEFT",self.Health,"BOTTOMLEFT",0,-1);
			
			power.value = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.value:SetWidth(110); power.value:SetHeight(11);
			power.value:SetJustifyH("RIGHT"); power.value:SetJustifyV("MIDDLE");
			power.value:SetPoint("LEFT",power,"LEFT",4,0);
			self:Tag(power.value, '[curpp]/[maxpp]')
			
			power.ratio = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.ratio:SetWidth(40); power.ratio:SetHeight(11);
			power.ratio:SetJustifyH("RIGHT"); power.ratio:SetJustifyV("MIDDLE");
			power.ratio:SetPoint("RIGHT",power,"LEFT",-2,0);
			self:Tag(power.ratio, '[perpp]%')
			
			self.Power = power;
			self.Power.colorPower = true;
			self.Power.frequentUpdates = true;
		end
	end
	do -- setup ring, icons, and text
		local ring = CreateFrame("Frame",nil,self);
		ring:SetFrameStrata("BACKGROUND");
		ring:SetAllPoints(self.Portrait); ring:SetFrameLevel(3);
		ring.bg = ring:CreateTexture(nil,"BACKGROUND");
		ring.bg:SetPoint("CENTER",ring,"CENTER",-2,-3);
		ring.bg:SetTexture(base_ring3);
		ring.bg:SetTexCoord(1,0,0,1);
		
		self.Name = ring:CreateFontString(nil, "BORDER","SUI_FontOutline12");
		self.Name:SetHeight(12); self.Name:SetWidth(150); self.Name:SetJustifyH("RIGHT");
		self.Name:SetPoint("TOPLEFT",self,"TOPLEFT",3,-5);
		self:Tag(self.Name,"[name]");
		
		self.Level = ring:CreateFontString(nil,"BORDER","SUI_FontOutline10");
		self.Level:SetWidth(36); self.Level:SetHeight(11);
		self.Level:SetJustifyH("CENTER"); self.Level:SetJustifyV("MIDDLE");
		self.Level:SetPoint("CENTER",ring,"CENTER",24,25);
		self:Tag(self.Level, "[level]");
		
		self.SUI_ClassIcon = ring:CreateTexture(nil,"BORDER");
		self.SUI_ClassIcon:SetWidth(22); self.SUI_ClassIcon:SetHeight(22);
		self.SUI_ClassIcon:SetPoint("CENTER",ring,"CENTER",-27,24);
		
		self.PvP = ring:CreateTexture(nil,"BORDER");
		self.PvP:SetWidth(48); self.PvP:SetHeight(48);
		self.PvP:SetPoint("CENTER",ring,"CENTER",30,-36);
		
		self.Happiness = ring:CreateTexture(nil,"ARTWORK");
		self.Happiness:SetWidth(22); self.Happiness:SetHeight(22);
		self.Happiness:SetPoint("CENTER",ring,"CENTER",-27,24);
		
		self.RaidIcon = ring:CreateTexture(nil,"ARTWORK");
		self.RaidIcon:SetAllPoints(self.Portrait);
		
		self.RaidIcon = ring:CreateTexture(nil,"ARTWORK");
		self.RaidIcon:SetWidth(20); self.RaidIcon:SetHeight(20);
		self.RaidIcon:SetPoint("CENTER",ring,"LEFT",-5,0);
	end
	do -- setup buffs and debuffs
		self.Auras = CreateFrame("Frame",nil,self);
		self.Auras:SetWidth(17*11); self.Auras:SetHeight(16*1);
		self.Auras:SetPoint("BOTTOMLEFT",self,"TOPLEFT",10,0);
		self.Auras:SetFrameStrata("BACKGROUND");
		self.Auras:SetFrameLevel(4);
		-- settings
		self.Auras.size = 16;
		self.Auras.spacing = 1;
		self.Auras.initialAnchor = "BOTTOMLEFT";
		self.Auras["growth-x"] = "RIGHT";
		self.Auras["growth-y"] = "UP";
		self.Auras.gap = true;
		self.Auras.numBuffs = 8;
		self.Auras.numDebuffs = 3;
		
		self.Auras.PostUpdate = PostUpdateAura;
	end
	return self;
end

local CreateToTFrame = function(self,unit)
	self:SetWidth(210); self:SetHeight(60);
	do -- setup base artwork
		local artwork = CreateFrame("Frame",nil,self);
		artwork:SetFrameStrata("BACKGROUND");
		artwork:SetFrameLevel(0); artwork:SetAllPoints(self);
		
		artwork.bg = artwork:CreateTexture(nil,"BACKGROUND");
		artwork.bg:SetPoint("CENTER"); artwork.bg:SetTexture(base_plate3);
		artwork.bg:SetWidth(256); artwork.bg:SetHeight(85);
		artwork.bg:SetTexCoord(1,0,0,85/128);
		
		self.Portrait = self:CreateTexture(nil,"BACKGROUND");
		self.Portrait:SetWidth(56); self.Portrait:SetHeight(50);
		self.Portrait:SetPoint("CENTER",self,"CENTER",-83,-8);
		
		self.Threat = CreateFrame("Frame",nil,self);
		self.Threat.Override = threat;
	end
	do -- setup status bars
		do -- cast bar
			local cast = CreateFrame("StatusBar",nil,self);
			cast:SetFrameStrata("BACKGROUND"); cast:SetFrameLevel(2);
			cast:SetWidth(120); cast:SetHeight(15);
			cast:SetPoint("TOPRIGHT",self,"TOPRIGHT",-36,-23);
			
			cast.Text = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Text:SetWidth(110); cast.Text:SetHeight(11);
			cast.Text:SetJustifyH("LEFT"); cast.Text:SetJustifyV("MIDDLE");
			cast.Text:SetPoint("RIGHT",cast,"RIGHT",-4,0);
			
			cast.Time = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Time:SetWidth(40); cast.Time:SetHeight(11);
			cast.Time:SetJustifyH("LEFT"); cast.Time:SetJustifyV("MIDDLE");
			cast.Time:SetPoint("LEFT",cast,"RIGHT",4,0);
			
			self.Castbar = cast;
			self.Castbar.OnUpdate = OnCastbarUpdate;
			self.Castbar.PostCastStart = PostCastStart;
			self.Castbar.PostChannelStart = PostChannelStart;
			self.Castbar.PostCastStop = PostCastStop;
		end
		do -- health bar
			local health = CreateFrame("StatusBar",nil,self);
			health:SetFrameStrata("BACKGROUND"); health:SetFrameLevel(2);
			health:SetWidth(120); health:SetHeight(16);
			health:SetPoint("TOPRIGHT",self.Castbar,"BOTTOMRIGHT",0,-2);
			
			health.value = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.value:SetWidth(110); health.value:SetHeight(11);
			health.value:SetJustifyH("LEFT"); health.value:SetJustifyV("MIDDLE");
			health.value:SetPoint("RIGHT",health,"RIGHT",-4,0);
			self:Tag(health.value, '[curhp]/[maxhp]')
			
			health.ratio = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.ratio:SetWidth(40); health.ratio:SetHeight(11);
			health.ratio:SetJustifyH("LEFT"); health.ratio:SetJustifyV("MIDDLE");
			health.ratio:SetPoint("LEFT",health,"RIGHT",4,0);
			self:Tag(health.ratio, '[perhp]%')
			
			self.Health = health;
			self.Health.colorTapping = true;
			self.Health.colorDisconnected = true;
			self.Health.colorHealth = true;
			self.Health.colorReaction = true;
		end
		do -- power bar
			local power = CreateFrame("StatusBar",nil,self);
			power:SetFrameStrata("BACKGROUND"); power:SetFrameLevel(2);
			power:SetWidth(135); power:SetHeight(14);
			power:SetPoint("TOPRIGHT",self.Health,"BOTTOMRIGHT",0,-1);
			
			power.value = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.value:SetWidth(110); power.value:SetHeight(11);
			power.value:SetJustifyH("LEFT"); power.value:SetJustifyV("MIDDLE");
			power.value:SetPoint("RIGHT",power,"RIGHT",-4,0);
			self:Tag(power.value, '[curpp]/[maxpp]')
			
			power.ratio = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.ratio:SetWidth(40); power.ratio:SetHeight(11);
			power.ratio:SetJustifyH("LEFT"); power.ratio:SetJustifyV("MIDDLE");
			power.ratio:SetPoint("LEFT",power,"RIGHT",4,0);
			self:Tag(power.ratio, '[perpp]%')		
			
			self.Power = power;
			self.Power.colorPower = true;
			self.Power.frequentUpdates = true;
		end
	end
	do -- setup ring, icons, and text
		local ring = CreateFrame("Frame",nil,self);
		ring:SetFrameStrata("BACKGROUND");
		ring:SetAllPoints(self.Portrait); ring:SetFrameLevel(3);
		ring.bg = ring:CreateTexture(nil,"BACKGROUND");
		ring.bg:SetPoint("CENTER",ring,"CENTER",-2,-3);
		ring.bg:SetTexture(base_ring3);
		
		self.Name = ring:CreateFontString(nil, "BORDER","SUI_FontOutline12");
		self.Name:SetHeight(12); self.Name:SetWidth(150); self.Name:SetJustifyH("LEFT");
		self.Name:SetPoint("TOPRIGHT",self,"TOPRIGHT",-3,-5);
		self:Tag(self.Name,"[name]");
		
		self.Level = ring:CreateFontString(nil,"BORDER","SUI_FontOutline10");
		self.Level:SetWidth(36); self.Level:SetHeight(11);
		self.Level:SetJustifyH("CENTER"); self.Level:SetJustifyV("MIDDLE");
		self.Level:SetPoint("CENTER",ring,"CENTER",-27,25);
		self:Tag(self.Level, "[difficulty][level]");
		
		self.SUI_ClassIcon = ring:CreateTexture(nil,"BORDER");
		self.SUI_ClassIcon:SetWidth(22); self.SUI_ClassIcon:SetHeight(22);
		self.SUI_ClassIcon:SetPoint("CENTER",ring,"CENTER",23,24);
		
		self.PvP = ring:CreateTexture(nil,"BORDER");
		self.PvP:SetWidth(48); self.PvP:SetHeight(48);
		self.PvP:SetPoint("CENTER",ring,"CENTER",-14,-36);
		
		self.RaidIcon = ring:CreateTexture(nil,"ARTWORK");
		self.RaidIcon:SetWidth(20); self.RaidIcon:SetHeight(20);
		self.RaidIcon:SetPoint("CENTER",ring,"RIGHT",1,-1);
		
		self.StatusText = ring:CreateFontString(nil, "OVERLAY", "SUI_FontOutline18");
		self.StatusText:SetPoint("CENTER",ring,"CENTER");
		self.StatusText:SetJustifyH("CENTER");
		self:Tag(self.StatusText, "[afkdnd]");

	end
	do -- setup buffs and debuffs
		self.Auras = CreateFrame("Frame",nil,self);
		self.Auras:SetWidth(17*11); self.Auras:SetHeight(16*1);
		self.Auras:SetPoint("BOTTOMRIGHT",self,"TOPRIGHT",-10,0);
		self.Auras:SetFrameStrata("BACKGROUND");
		self.Auras:SetFrameLevel(4);
		-- settings
		self.Auras.size = 16;
		self.Auras.spacing = 1;
		self.Auras.initialAnchor = "BOTTOMRIGHT";
		self.Auras["growth-x"] = "LEFT";
		self.Auras["growth-y"] = "UP";
		self.Auras.gap = false;
		self.Auras.numBuffs = 8;
		self.Auras.numDebuffs = 3;
		
		self.Auras.PostUpdate = PostUpdateAura;
	end
	return self;
end

local CreateFocusFrame = function(self,unit)
	self:SetWidth(180); self:SetHeight(60);
	do --setup base artwork
		local artwork = CreateFrame("Frame",nil,self);
		artwork:SetFrameStrata("BACKGROUND");
		artwork:SetFrameLevel(0); artwork:SetAllPoints(self);
		
		artwork.bg = artwork:CreateTexture(nil,"BACKGROUND");
		artwork.bg:SetPoint("CENTER"); artwork.bg:SetTexture(base_plate2);
		artwork.bg:SetWidth(180); artwork.bg:SetHeight(60);
		if unit == "focus" then artwork.bg:SetTexCoord(0, 1, 0, 0.4) end
		if unit == "focustarget" then artwork.bg:SetTexCoord(0, 1, .5, .9) end
		
		self.Threat = CreateFrame("Frame",nil,self);
		self.Threat.Override = threat;
	end
	do -- setup status bars
		do -- health bar
			local health = CreateFrame("StatusBar",nil,self);
			health:SetFrameStrata("BACKGROUND"); health:SetFrameLevel(2);
			health:SetSize(85, 15);
			if unit == "focus" then health:SetPoint("CENTER",self,"CENTER",-5,-2) end
			if unit == "focustarget" then health:SetPoint("CENTER",self,"CENTER",-46,-2) end
			
			health.value = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.value:SetSize(80, 11);
			health.value:SetJustifyH("LEFT"); health.value:SetJustifyV("MIDDLE");
			if unit == "focus" then health.value:SetPoint("RIGHT",health,"RIGHT",0,0) end
			if unit == "focustarget" then health.value:SetPoint("LEFT",health,"LEFT",0,0) end
			self:Tag(health.value, '[curhp]/[maxhp]')
			
			health.ratio = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.ratio:SetSize(40, 11);
			health.ratio:SetJustifyH("LEFT"); health.ratio:SetJustifyV("MIDDLE");
			if unit == "focus" then health.ratio:SetPoint("LEFT",health,"LEFT",-30,0) end
			if unit == "focustarget" then health.ratio:SetPoint("LEFT",health,"RIGHT",1,0) end
			self:Tag(health.ratio, '[perhp]%')		
			
			self.Health = health;
			self.Health.colorTapping = true;
			self.Health.colorDisconnected = true;
			self.Health.colorHealth = true;
		end
		do -- power bar
			local power = CreateFrame("StatusBar",nil,self);
			power:SetFrameStrata("BACKGROUND"); power:SetFrameLevel(2);
			power:SetSize(85, 15);
			power:SetPoint("TOP",self.Health,"BOTTOM",0,-2);
			
			power.value = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.value:SetSize(85, 11);
			power.value:SetJustifyH("LEFT"); power.value:SetJustifyV("MIDDLE");
			power.value:SetPoint("TOP",self.Health.value,"BOTTOM",-1,-6);
			self:Tag(power.value, '[curpp]/[maxpp]')
			
			power.ratio = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.value:SetSize(40, 11);
			power.ratio:SetJustifyH("LEFT"); power.ratio:SetJustifyV("MIDDLE");
			power.ratio:SetPoint("TOP",self.Health.ratio,"BOTTOM",-4,-7);	
			self:Tag(power.ratio, '[perpp]%')		
			
			self.Power = power;
			self.Power.colorPower = true;
			self.Power.frequentUpdates = true;
		end
	end
	do -- setup ring, icons, and text
		local ring = CreateFrame("Frame",nil,self);
		--ring:SetFrameStrata("BACKGROUND");
		--ring:SetAllPoints(self); ring:SetFrameLevel(3);
		ring.bg = ring:CreateTexture(nil,"BACKGROUND");
		ring.bg:SetPoint("LEFT",ring,"LEFT",-2,-3);
		
		self.Name = ring:CreateFontString(nil, "BORDER","SUI_FontOutline12");
		self.Name:SetSize(110, 12); self.Name:SetJustifyH("LEFT");
		if unit == "focus" then
			self.Name:SetPoint("TOPLEFT",self,"TOPLEFT",20,-6);
		elseif unit == "focustarget" then
			self.Name:SetPoint("TOPLEFT",self,"TOPLEFT",2,-6);
		end
		self:Tag(self.Name,"[difficulty][level] [name]");
		
		self.LevelSkull = ring:CreateTexture(nil,"ARTWORK");
		self.LevelSkull:SetSize(16, 16);
		self.LevelSkull:SetPoint("CENTER",self.Name,"LEFT",8,0);
	end
	do -- setup buffs and debuffs
		self.Auras = CreateFrame("Frame",nil,self);
		self.Auras.PostUpdate = PostUpdateAura;
	end
	return self;
end

local CreateUnitFrame = function(self,unit)
	self.menu = menu;
	self:SetParent("SpartanUI");
	self:SetFrameStrata("BACKGROUND"); self:SetFrameLevel(1);
	self:SetScript("OnEnter", UnitFrame_OnEnter);
	self:SetScript("OnLeave", UnitFrame_OnLeave);
	self:RegisterForClicks("anyup");
	self:SetAttribute("*type2", "menu");
	self.colors = addon.colors;
	
	spartan:Print("Frame Created: "..tostring(unit))

	return (unit == "target" and CreateTargetFrame(self,unit)) or (unit == "targettarget" and CreateToTFrame(self,unit)) or (unit == "player" and CreatePlayerFrame(self,unit)) or (unit == "focus" and CreateFocusFrame(self,unit)) or (unit == "focustarget" and CreateFocusFrame(self,unit)) or (unit == "pet" and CreatePetFrame(self,unit) or CreateFocusFrame(self,unit));
end


oUF:RegisterStyle("Spartan_PlayerFrames", CreateUnitFrame);