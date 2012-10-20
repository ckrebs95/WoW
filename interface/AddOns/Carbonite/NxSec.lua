---------------------------------------------------------------------------------------
-- NxSec - Security code
-- Copyright 2007-2012 Carbon Based Creations, LLC
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Carbonite - Addon for World of Warcraft(tm)
-- Copyright 2007-2012 Carbon Based Creations, LLC
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------------------------

function Nx.Sec:Start()

--	Nx.prt ("Sec Start %s", date ("%H%M%S", time()))

	Nx.Timer:Start (0, .1, self, self.ValidateTime)
end

--------
-- Validate time to see if we have expired. Runs before Validate

function Nx.Sec:ValidateTime()

	local dt = self:Date()
	local x = 121128

--	Nx.prt ("ValTime %s, Exp %s", dt, x)

	if dt >= x then
		Nx.Timer:Start (-1, 0, self, self.OldMsg)
	end

	Nx.Timer:Start (0, 0, self, self.Validate)	-- Switch timer function

	return .1
end

function Nx.Sec:Date()
	local w,m,d,y = CalendarGetDate()
	y = y - 2000
	return y*10000+m*100+d
end

--------
-- Show expired message

function Nx.Sec:OldMsg()

	local s = "\n|cffff4040This version is pretty old.\n|rVisit |cff40ff40" .. Nx.WebSite .. "|r and check for a newer version."

--	Nx:ShowMessage (s, "OK")
--	Nx.prt (s)
end

--------
-- Validate nothing

function Nx.Sec:Validate()

	self:Unlock()

	self.Validate = nil	-- Kill self
end

--------
--

function Nx.Sec:Unlock()

--	Nx.prt ("Sec Unlock %s", date ("%H%M%S", time()))

	local Nx = Nx

	local function func()
		Nx.Fav.ToggleShow = function (self) Nx.Fav.ToggleShow_(self) end
		if Nx.Info then
			Nx.Info.Update = function (self) Nx.Info.Update_(self) end
		end
		Nx.Map.Guide.ToggleShow = function (self) Nx.Map.Guide.ToggleShow_(self) end
		Nx.Quest.List.Update = function (self) Nx.Quest.List.Update_(self) end
		Nx.Quest.Watch.Update = function (self) Nx.Quest.Watch.Update_(self) end
		Nx.Social.List.Update = function (self) self:Update_() end
		Nx.Warehouse.ToggleShow = function (self) Nx.Warehouse.ToggleShow_(self) end
	end

	--

	func()
	Nx.Help.Demo:StartOnce()

	self.Unlock = nil		-- Kill self
end

-------------------------------------------------------------------------------
-- EOF

















