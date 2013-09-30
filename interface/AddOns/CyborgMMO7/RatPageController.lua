RatPageController = {
	new = function()
		local self = {};
		RatPageModel.Instance().SetMode(1);

		self.SlotClicked = function(slot)
			local slotObject = nil
			slotObject = RatPageModel.Instance().GetObjectOnButton(slot.Id) --self.GetWowObject()
			RatPageModel.Instance().SetObjectOnButton(slot.Id, RatPageModel.Instance().GetMode(), self.GetCursorObject());

			if(slotObject ~= nil) then
				slotObject.Pickup();
			end

		end

		self.ModeClicked = function(mode)
			msg("Setting mode "..tostring(mode.Id));
			RatPageModel.Instance().SetMode(mode.Id);
		end

		self.GetCursorObject = function()
			local cursorObject = nil;
			if(nil ~= GetCursorInfo()) then
				local type, detail, subdetail = GetCursorInfo();
				cursorObject = WowObject.Create(type, detail, subdetail);
				ClearCursor();
			end
			return cursorObject;
		end
		
		self.CallbackDropped = function(callbackObject)
			local slot = nil;
			local observers = RatPageModel.Instance().GetAllObservers();
			for i = 1, (# observers) do
				if(MouseIsOver(observers[i])) then
					slot = observers[i];
					break;
				end
			end
			if(nil ~= slot) then 
				RatPageModel.Instance().SetObjectOnButton(slot.Id, RatPageModel.Instance().GetMode(), callbackObject.wowObject);
			end
		end
		
		

		self.Close = function()

		end

		self.Open = function()
		end

		return self;
	end,

	m_Instance = nil,

	Instance = function()
		if(nil == RatPageController.m_Instance) then
			RatPageController.m_Instance = RatPageController.new();
		end
		return RatPageController.m_Instance;
	end
}
