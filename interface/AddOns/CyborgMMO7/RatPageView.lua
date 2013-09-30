RatPageView = {
	new = function(self)
		msg("new Rat Page View");
		for _, child in ipairs(self:GetChildren()) do
			child.Register();
		end
		
		self.SlotClicked = function(slot)
			msg("View Recieved Click")
			RatPageController.Instance().SlotClicked(slot)
		end

		self.ModeClicked = function(mode)
			msg("View Recieved Click")
			RatPageController.Instance().ModeClicked(mode)
		end

		self.RegisterMode = function()
			msg("ModeRegistered")
		end

		self.RegisterSlot = function()
			msg("SlotRegistered")
		end
		return self;
	end
}

RatQuickPageView = {
	new = function(self)
		for _, child in ipairs(self:GetChildren()) do
			child.Register();
		end

		self.SlotClicked = function(slot)
			RatPageController.Instance().SlotClicked(slot)
		end

		return self;
	end
}

-- Slot Class --
SlotView = {
	new = function(self, parent)
		self._assignedWowObject = nil;
		self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		self.Id = self:GetID();
		RatPageModel.Instance().AddObserver(self);
		self.UnCheckedTexture = self:GetNormalTexture();

		-- Object Method --
		self.Clicked = function()
			self:GetParent().SlotClicked(self)

			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			--GameTooltip:SetText(self:GetID());
		end

		self.Update = function(data, activeMode)
			local icon = _G[self:GetName().."Icon"];
			if(nil ~= data[activeMode][self.Id]) then
				self:SetChecked(true);
				icon:SetTexture(data[activeMode][self.Id].Texture);
			else
				icon:SetTexture(nil);
				self:SetChecked(false);
			end


		end

		return self;
	end,
}

SlotMiniView = {
	new = function(self, parent)
		self._assignedWowObject = nil;
		self.Id = self:GetID();
		RatPageModel.Instance().AddObserver(self);
		self.UnCheckedTexture = self:GetNormalTexture();

		self.Update = function(data, activeMode)
			local icon = _G[self:GetName().."Icon"];
			if(nil ~= data[activeMode][self.Id]) then
				self:SetChecked(true);

				icon:SetTexture(data[activeMode][self.Id].Texture);
				icon:SetAlpha(.5);
			else
				icon:SetTexture(nil);
				self:SetChecked(false);
			end
		end

		return	self;
	end
}


-- ModeButton --
ModeView = {
	new = function(self)
	self.Id = self:GetID();
	self.Name = self:GetName();
	RatPageModel.Instance().AddObserver(self);
	if(self.Id ~= 1) then
		self:Hide()
	end

		self.Clicked = function()
			local nextMode;
			if(self.Id == 1) then
				nextMode = getglobal("Mode2");
			else
				if(self.Id == 2) then
					nextMode = getglobal("Mode3");
				else
					nextMode = getglobal("Mode1");
				end
			end
			self:GetParent().ModeClicked(nextMode)
		end

		self.Update = function(data, activeMode)
			if(self.Id == activeMode) then
				self:Show()
			else
				self:Hide()
			end

		end

	return self;
	end
}
