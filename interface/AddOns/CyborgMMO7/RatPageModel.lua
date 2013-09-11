
-- Constants --
local RAT7 = { BUTTONS = 13, MODES = 3, SHIFT = 0}

local MIDDLEMOUSE = 1;

RatPageModel = {
	new = function()
	local self = {}
		self.m_Mode = 1;
		self.ObserverCount = 0;
		self.ObserverList = {}
		self.Data = {}

		for i = 1,RAT7.MODES do
			self.Data[i] = {}
			for j = 1, RAT7.BUTTONS do
				self.Data[i][j] = {};
			end
		end

		self.InitSaveData = function(data)
			for i = 1,RAT7.MODES do
				if (nil == data["Rat"][i]) then
					data["Rat"][i] = {}
				end
				for j = 1, RAT7.BUTTONS do
					if (nil == data["Rat"][i][j]) then
						data["Rat"][i][j] = {}
					end
				end
			end
		end


		self.LoadData = function()
			msg("Loading...")
			local data = GetSaveData();


			if (nil == data["Rat"]) then
				data["Rat"] = {}
				self.InitSaveData(data);
			end

			self.Data = data["Rat"]
			if(data ~= nil) then
				for mode = 1,RAT7.MODES do
					for button = 1, RAT7.BUTTONS do
						if(self.Data[mode][button] ~= nil) then
							object = WowObject.Create(self.Data[mode][button].Type, self.Data[mode][button].Detail, self.Data[mode][button].Subdetail);
							self.SetObjectOnButtonNoUpdate(button, mode, object);
						else
							object = WowObject.Create("", "", "");
							self.SetObjectOnButtonNoUpdate(button, mode, object);
							self.Data[mode][button] = object;
						end
					end
				end
				self.UpdateObservers();
			end
		end

		self.SaveData = function()
			msg("Saving...")
			SetSaveData(self.Data, "Rat");
		end

		self.SetMode = function(mode)
			self.m_Mode = mode;
			self.UpdateObservers();
		end

		self.GetMode = function()
			return self.m_Mode;
		end

		self.GetData = function()
			return self.Data, self.m_Mode;
		end

		self.GetObjectOnButton = function(button)
			if(nil == self.Data[self.m_Mode][button]) then
				return nil;
			else
				return self.Data[self.m_Mode][button]
			end
		end

		self.SetObjectOnButtonNoUpdate = function(button, mode, object)
			--msg("button = "..tostring(button).." mode = "..tostring(mode))
			self.Data[mode][button] = object;

			if(nil ~= object) then
				object.SetBinding(WowCommands[GetLocale()][((mode-1)*RAT7.BUTTONS)+button]);
				if("callback" == object.Type) then
					msg("trying to set texture")
					local slot = getglobal("defaultPageSlot"..button);
					slot:SetNormalTexture(object.Texture)
				end
			else
				msg("clearing "..button)
				WowObject.ClearBinding(WowCommands[GetLocale()][((mode-1)*RAT7.BUTTONS)+button])
			end
		end

		self.SetObjectOnButton = function(button, mode, object)
			self.SetObjectOnButtonNoUpdate(button, mode, object);
			self.UpdateObservers()
		end

		self.AddObserver = function(view)
			table.insert(self.ObserverList,view)
			self.observerCount = # self.ObserverList
		end
		
		self.GetAllObservers = function()
			return self.ObserverList;
		end

		self.UpdateObservers = function()
			for i = 1, (# self.ObserverList) do
				self.ObserverList[i].Update(self.Data, self.m_Mode)
			end
			self.SaveData()
		end
	return self;
	end,

	m_Instance = nil,

	Instance = function()
		if(nil == RatPageModel.m_Instance) then
			RatPageModel.m_Instance = RatPageModel.new();
		end
		return RatPageModel.m_Instance;
	end
}
