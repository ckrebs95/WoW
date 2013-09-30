-- WowObjects --

-- WowObject Class --

WowObject = {
	new = function(type, detail, subdetail)
		local self = {};
		self.Texture = nil;
		self.Name = "NoName";
		self.Type = type;
		self.Detail = detail;
		self.Subdetail = subdetail;


		-- Methods --
		self.DoAction = function()
			msg("Nothing To Do");
		end

		self.Pickup = function()
			msg("Pick up Item");
		end

		self.SetBinding = function(key)
		end

		self.PlaySound = function()
			PlaySound("igAbilityIconDrop");
		end

		return self;
	end,

	ClearBinding = function(key)
		local buttonFrame, parentFrame, name = CallbackFactory.Instance().AddCallback(WowObject.DoNothing);
		if(1 ~= SetOverrideBindingClick(parentFrame, true, key, name, "LeftButton")) then
			msg("Failed to bind companion to button click");
		end
	end,

	DoNothing = function()
	end,

	Load = function(object)
		if("item" == type) then
			object = WowItem.Load(Object)
		elseif("macro" == type) then
			object = WowMacro.Load(object)
		elseif("spell" == type) then
			object = WowSpell.Load(object)
		elseif("petaction" == type) then
			object = WowSpell.Load(object)
		--elseif("merchant"== type) then
			--object = SlotMerchant.new(detail,subdetail)
		elseif("companion" == type) then
			object = WowCompanion.Load(object)
		elseif("equipmentset" == type) then
			object = WowEquipmentSet.Load(object)
		else
			object = WowObject.new(type,detail, subdetail)
		end
		return object;
	end,

	-- Static Methods --
	Create = function(objectType, detail, subdetail)
		local object;
		if("item" == objectType) then
			object = WowItem.new(detail,subdetail)
		elseif("macro" == objectType) then
			object = WowMacro.new(detail)
		elseif("spell" == objectType) then
			object = WowSpell.new(objectType, detail,subdetail)
		elseif("petaction" == objectType) then
			object = WowSpell.new(objectType, detail,subdetail)
		elseif("merchant"== objectType) then
			object = SlotMerchant.new(detail,subdetail)
		elseif("companion" == objectType) then
			object = WowCompanion.new(detail,subdetail)
		elseif("equipmentset" == objectType) then
			object = WowEquipmentSet.new(objectType,detail,subdetail)
		elseif("callback" == objectType) then
			object = WowCallback.new(detail);
		else
			object = WowObject.new(objectType,detail, subdetail)
		end

		return object;
	end
}

local CallbackCursor = nil;

CallbackIcons = {
	new = function(self)
		self.point, self.relativeTo, self.relativePoint, self.xOfs, self.yOfs = self:GetPoint();
		--self:SetPoint(self.point, self.relativeTo, self.relativePoint, self.xOfs, self.yOfs);
		self.strata = self:GetFrameStrata();
		self.wowObject = WowCallback.new(self:GetName());
		self.wowObject.SetTextures(self);
		self:RegisterForDrag("LeftButton","RightButton")
		self:SetResizable(false);
		
		self.OnClick = function()
			self.wowObject.DoAction();
		end
		
		
		self.DragStart = function()
			self:SetMovable(true);
			self:StartMoving();
			self.isMoving = true;
			self:SetFrameStrata("TOOLTIP")
		end
		
		self.DragStop = function()
		
			self:SetFrameStrata(self.strata);
			self.isMoving = false;
			self:SetMovable(false);
			self:StopMovingOrSizing();

			self:ClearAllPoints();
			self:SetPoint(self.point, self.relativeTo, self.relativePoint, self.xOfs, self.yOfs);
			local x, y  = GetCursorPosition();
			RatPageController.Instance().CallbackDropped(self)
		end
		
		return self;
	end
}

WowCallback = {
	new = function(callbackName)
		local self = WowObject.new("callback", callbackName, "");
		self.CallbackName = callbackName;
		self.Texture = "Interface\\AddOns\\CyborgMMO7\\Graphics\\"..self.CallbackName.."Unselected.tga"
		
		self.SetTextures = function(buttonFrame)
			buttonFrame:SetNormalTexture("Interface\\AddOns\\CyborgMMO7\\Graphics\\"..self.CallbackName.."Unselected.tga")
			buttonFrame:SetPushedTexture("Interface\\AddOns\\CyborgMMO7\\Graphics\\"..self.CallbackName.."Down.tga")
			buttonFrame:SetHighlightTexture("Interface\\AddOns\\CyborgMMO7\\Graphics\\"..self.CallbackName.."Over.tga")
		end
		
		self.DoAction = function()
			local action = GetCallback(self.CallbackName)
			msg("calling callback:- "..self.CallbackName);
			action();
			
		end
		
		self.PickupCallback = function()
			
			local slot = nil;
			local observers = RatPageModel.Instance().GetAllObservers();
			for i = 1, (# observers) do
				if(MouseIsOver(observers[i])) then
					slot = observers[i];
					break;
				end
			end
			slot:SetNormalTexture(slot.UnCheckedTexture)
		end

		
		self.ClickHandler = function(self, button, down)
			msg("click handler");
			CallbackCursor:StopMoving();
			CallbackCursor:Hide();
			
			if("LeftButton" == button) then
			else
				
			end
		end
		
		self.Pickup = function()
			self.PlaySound()
			ClearCursor();
			self.PickupCallback();

		end
		
		
		self.SetBinding = function(key)
			local buttonFrame, parentFrame, name = CallbackFactory.Instance().AddCallback(self.DoAction);
			if(1 ~= SetOverrideBindingClick(CallbackFactory.Instance().Frame, true, key, name, "LeftButton")) then
				msg("Failed to Bind modeChange");
			end
		end
		
		return self;
	end
}

-- WowItem Class --

WowItem = {
	new = function(number, itemID)
		local self = WowObject.new("item", number, itemID); -- base class
		-- Set all the item info. --
		self.Name,
		self.Link,
		self.Rarity,
		self.Level,
		self.MinLevel,
		self.Type,
		self.SubType,
		self.StackCount,
		self.EquipLoc,
		self.Texture,
		self.SellPrice = GetItemInfo(itemID);

		-- override method --
		self.DoAction = function()
			msg("Use Item");
		end

		-- override method --
		self.Pickup = function()
			self.PlaySound()
			ClearCursor();
			--SetCursor(self.Texture);
			return PickupItem(self.Link);
		end

		self.SetBinding = function(key)
			SetOverrideBinding(CallbackFactory.Instance().Frame, true, key, "ITEM "..self.Name);
		end

		return self;
	end,
}

-- WowSpell Class --

WowSpell = {
	new = function(type, spellbookID, spellbook)
		local self = WowObject.new(type, spellbookID, spellbook) -- base class
		self.SpellbookID = spellbookID;
		self.Spellbook = spellbook;
		self.Name, self.Rank = GetSpellBookItemName(spellbookID, spellbook);
		self.Texture = GetSpellBookItemTexture(spellbookID, spellbook);
		self.Type = type;


		-- override method --
		self.DoAction = function()
			msg("Cast Spell");
		end

		-- override method --
		self.Pickup = function()
			self.PlaySound()
			ClearCursor();
			--SetCursor(self.Texture);
			return PickupSpellBookItem(self.SpellbookID, self.Spellbook);
		end

		self.SetBinding = function(key)
			msg("Binding to key "..key)
			self.Key = key
			SetOverrideBinding(CallbackFactory.Instance().Frame, true, self.Key, self.Type.." "..self.Name);
		end

    return self;

	end,

	Load = function(object)
		local o = WowSpell.new(object.Type, object.Detail, object.Subdetail);
		o.Name = object.Name;
		o.Texture = object.Texture;
		return o;
	end
}

-- WowMacro Class --

WowMacro = {
	new = function(index)
		local self = WowObject.new("macro", index, nil); -- base class
		-- Set all the item info. --
		self.Name,
		self.Texture,
		self.Body,
		self.isLocal = GetMacroInfo(index);
		self.Index = index;

		-- override method --
		self.DoAction = function()
			msg("Use Item");
		end

		-- override method --
		self.Pickup = function()
			self.PlaySound()
			ClearCursor();
			--SetCursor(self.Texture);
			return PickupMacro(self.Index);
		end

		self.SetBinding = function(key)
			self.Key = key;
			SetOverrideBinding(CallbackFactory.Instance().Frame, true, key, "MACRO "..self.Index);
		end

    return self;
  end,
}


-- WowCompanion Class --

WowCompanion = {
	new = function(index, SubType)
		local self = WowObject.new("companion", index, SubType); -- base class
		-- Set all the item info. --
		self.Id, self.Name, self.SpellId, self.Texture,	self.isSummoned = GetCompanionInfo(SubType, index);
		self.SubType = SubType;
		self.index = index;
		-- override method --
		self.DoAction = function()
			if((self.SubType == "MOUNT") and IsMounted()) then
				Dismount();
			else
				CallCompanion(self.SubType, self.index);
			end
		end

		-- override method --
		self.Pickup = function()
			self.PlaySound()
			return PickupCompanion(self.SubType, self.index);
		end

		self.SetBinding = function(key)
			self.Key = key
			local buttonFrame, parentFrame, name = CallbackFactory.Instance().AddCallback(self.DoAction);
			if(1 ~= SetOverrideBindingClick(parentFrame, true, key, name, "LeftButton")) then
				msg("Failed to bind companion to button click");
			end
			--SetOverrideBinding(hiddenModeChanger, true, key, "MACRO "..self.Index);
		end

		return self;
	end,

	Load = function(object)
		local o = WowCompanion.new(object.index, object.SubType);
		return o;
	end
}

-- WowMerchant Class --
WowMerchant = {
	new = function(index)
		local self = WowObject.new("macro", index, nil); -- base class
		-- Set all the item info. --
		self.Name,
		self.Texture,
		self.Price,
		self.Quantity,
		self.NumAvailable,
		self.IsUsable,
		self.ExtendedCost = GetMerchantItemInfo(index);
		self.Index = index;

		-- override method --
		self.DoAction = function()
			msg("Use Item");
		end

		-- override method --
		self.Pickup = function()
			self.PlaySound()
			ClearCursor();
			--SetCursor(self.Texture);
			return PickupMerchantItem(self.Index);
		end

		self.SetBinding = function(key)
			self.Key = key
			SetOverrideBinding(CallbackFactory.Instance().Frame, true, key, "MERCHANT "..self.Index);
		end

    return self;
  end,
}

-- WowEquipmentSet Class --
WowEquipmentSet = {
	new = function(objectType, name, index)
		local self = WowObject.new(objectType, name, index); -- base class
		-- Set all the item info. --
		texture, lessIndex = GetEquipmentSetInfoByName(name);
		self.Texture = "Interface\\Icons\\"..texture;
		self.Name = name
		self.Index = lessIndex+1;

		-- override method --
		self.DoAction = function()
			UseEquipmentSet(self.Name);
		end

		-- override method --
		self.Pickup = function()
			self.PlaySound()
			ClearCursor();
			--SetCursor(self.Texture);
			return PickupEquipmentSetByName(self.Name);
		end

		self.SetBinding = function(key)
			self.Key = key
			local buttonFrame, parentFrame, name = CallbackFactory.Instance().AddCallback(self.DoAction);
			if(1 ~= SetOverrideBindingClick(parentFrame, true, key, name, "LeftButton")) then
				msg("Failed to bind companion to button click");
			end
		end

    return self;
  end,
}


-- End Of WowObjects --
