---------------------------------------------------------------------------------------
-- Carbonite - Addon for World of Warcraft(tm)
-- Copyright 2007-2012 Carbon Based Creations, LLC
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,f
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
local _G = getfenv(0)

Nx = LibStub("AceAddon-3.0"):NewAddon("Carbonite","AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0")	
local L = LibStub("AceLocale-3.0"):GetLocale("Carbonite", true)

Nx.WebSite = "wowinterface.com"
NXTITLEFULL = NXTITLE

Nx.VERMAJOR			= 5.1
Nx.VERMINOR			= .6			-- Not 0 is a test version
Nx.BUILD				= 292

Nx.VERSION			= Nx.VERMAJOR + Nx.VERMINOR / 100

Nx.VERSIONDATA			= .02				-- Main data
Nx.VERSIONCHAR			= .02				-- Character data
Nx.VERSIONCharData	= .4				-- Character specific saved data
Nx.VERSIONGATHER		= .75				-- Gathered data
Nx.VERSIONGOPTS		= .102			-- Global options
Nx.VERSIONHUDOPTS		= .03				-- HUD options
Nx.VERSIONList			= .1				-- List header data
Nx.VERSIONTaxiCap		= .5				-- Taxi capture data
Nx.VERSIONTRAVEL		= .5				-- Travel data
Nx.VERSIONWin			= .31				-- Window layouts
Nx.VERSIONTOOLBAR		= .1				-- Tool Bar data
Nx.VERSIONCAP			= .75				-- Captured data (quest recording)
Nx.VERSIONVENDORV		= .55				-- Visited vendor data
Nx.VERSIONTransferData = .1			-- Transfer data
Nx.TXTBLUE			= "|cffc0c0ff"

Nx.Tick = 0

Nx.Font = {}
Nx.Skin = {}
Nx.Window = {}
Nx.Menu = {}
Nx.MenuI = {}
Nx.List = {}
Nx.DropDown = {}
Nx.Button = {}
Nx.EditBox = {}
Nx.Graph = {}
Nx.Slider = {}
Nx.TabBar = {}
Nx.ToolBar = {}

Nx.Help = {}	
Nx.Help.Ad = {}

Nx.Proc = {}
Nx.Script = {}

Nx.Help.Logo = "Interface\\AddOns\\Carbonite\\Gfx\\Carbonite"

Nx.Opts = {}

Nx.Com = {}
Nx.Com.List = {}

Nx.HUD = {}

Nx.Map = {}
Nx.Map.Dock = {}
Nx.Map.Guide = {}
Nx.Map.Guide.PlayerTargets = {}
Nx.Travel = {}

Nx.Title = {}
Nx.AuctionAssist = {}
Nx.Combat = {}

Nx.UEvents = {}
Nx.UEvents.List = {}

Nx.DebugOn = false
Nx.NetSendPos = false
Nx.NetPlyrSendTime = GetTime()

Nx.GroupMembers = {}

Nx.Item = {}

Nx.NXMiniMapBut = {}

Nx.db = {}

Nx.ModuleUpdateIcon = {"test"}
Nx.RequestTime = false
Nx.FirstTry = true
Nx.Loaded = false
Nx.Initialized = false
Nx.PlayerFnd = false
Nx.ModQAction = ""
Nx.ModPAction = ""

function Nx.EmulateTomTom() 
	if _G.TomTom then
		return
	end
	local tom = {}
	_G.TomTom = tom
	tom["version"] = "v40200"
	tom["AddWaypoint"] = Nx.TTAddWaypoint
	tom["AddZWaypoint"] = Nx.TTAddZWaypoint
	tom["SetCustomWaypoint"] = Nx.TTSetCustomWaypoint
	tom["SetCustomMFWaypoint"] = Nx.TTSetCustomMFWaypoint
	tom["AddMFWaypoint"] = Nx.TTSetCustomMFWaypoint
	tom["RemoveWaypoint"] = Nx.TTRemoveWaypoint
	tom["SetCrazyArrow"] = Nx.TTSetCrazyArrow
	SLASH_WAY1 = '/way'
	SlashCmdList["WAY"] = function (msg, editbox)
		Nx:TTWayCmd(msg)
	end
end


Nx.EmulateTomTom()

local defaults = {
    char = {
		Map = {
  			ShowGatherA = false,
			ShowGatherH = false,
			ShowGatherM = false,
			ShowQuestGivers = 1,
			ShowMailboxes = true,
			ShowCCity = false,
			ShowCExtra = true,
			ShowCTown = false,
			ShowArchBlobs = true,
			ShowQuestBlobs = true,			
		},
	},
	global = {
	   Characters = {},	   
	},
	profile = {
		Battleground = {
			ShowStats = true
		},
		General = {
			CameraForceMaxDist = false,
			CaptureEnable = false,
			CaptureShare = true,
			ChatMsgFrm = "",
			GryphonsHide = true,
			LoginHideVer = true,
			TitleOff = true,
			TitleSoundOn = false,
		},		
		Guide = {
			VendorVMax = 60,
			GatherEnabled = true,
		},
		Comm = {
			Global = true,
			Zone = true,
			LvlUpShow = true,
			SendToFriends = true,
			SendToGuild = true,
			SendToZone = true,
		},
		Debug = {
		  VerDebug = false,
		  VerT = 0,
		  DebugMap = false,
		  DebugDock = false,
		  DBGather = false,
		  DBMapMax = false,
		  DebugCom = false,
		  DebugUnit = false,
		},
		Font = {
			Small = "Friz",
			SmallSize = 10,
			SmallSpacing = 0,
			Medium = "Friz",
			MediumSize = 12,
			MediumSpacing = 0,
			Map = "Friz",
			MapSize = 10,
			MapSpacing = 0,
			MapLoc = "Friz",
			MapLocSize = 10,
			MapLocSpacing = 0,
			Menu = "Friz",
			MenuSize = 10,
			MenuSpacing = 0,
		},
		Skin = {
		  Name = "",		  
		  WinBdColor = ".8|.8|1|1",
		  WinFixedBgColor = ".5|.5|.5|.5",
		  WinSizedBgColor = ".121|.121|.121|.88",
		},
		Map = {
			ButLAlt = "None",
			ButLCtrl = "Goto",
			ButM = "Show Player Zone",
			ButMAlt = "None",
			ButMCtrl = "None",
			ButR = "Menu",
			ButRAlt = "None",
			ButRCtrl = "None",
			But4 = "Show Selected Zone",
			But4Alt = "Add Note",
			But4Ctrl = "None",
			Compatability = false,
			DetailSize = 6,
			IconPOIAlpha = 1,
			IconGatherA = 0.7,
			IconGatherAtScale = 0.5,
			LineThick = 1.0,
			LocTipAnchor = "TopRight",
			LocTipAnchorRel = "None",
			MaxCenter = true,
			MaxMouseIgnore = false,
			MaxOverride = true,
			MaxRestoreHide = false,
			MouseIgnore = false,
			PlyrArrowSize = 32,
			RestoreScaleAfterTrack = true,
			RouteUse = true,
			TopTooltip = false,
			IconScaleMin = 1,
			ShowOthersInCities = true,
			ShowOthersInZone = true,
			ShowPalsInCities = true,
			ShowPOI = true,
			ShowTitleName = true,
			ShowTitleXY = true,
			ShowTitleSpeed = true,
			ShowTitle2 = false,
			ShowToolBar = true,
			ShowTrail = true,
			TrailCnt = 100,
			TrailDist = 2,
			TrailTime = 90,
			WOwn = true,
			ZoneDrawCnt = 3,   
		},
		MiniMap = {
			AboveIcons = false,
			ButColumns = 1,
			ButCorner = "TopRight",
			ButOwn = false,
			ButShowCarb = true,
			ButHide = false,
			ButLock = false,
			ButShowCalendar = true,
			ButShowClock = true,
			ButShowWorldMap = true,
			ButSpacing = 29,
			ButWinMinimize = false,
			DockHigh = "",
			DockAlways = false,
			DockBugged = true,
			DockIndoors = true,
			DockOnMax = false,
			DockSquare = true,
			DockBottom = false,
			DockRight = false,
			DockIScale = 1,
			DockZoom = 0,
			DXO = 0,
			DYO = 0,
			HideOnMax = false,
			InstanceTogFullSize = false,
			IndoorTogFullSize = false,
			BuggedTogFullSize = false,
			IScale = 1,
			MoveCapBars = true,
			NodeGD = 0,
			Own = false,
			ShowOldNameplate = true,
			Square = false,
		},
		Menu = {   
			CenterH = false,
			CenterV = false,
		},
		Route = {
			GatherRadius = 60,
			MergeRadius = 20,
			Recycle = false,
		},
		Track = {
			EmuTomTom = true,
			Hide = false,
			HideInBG = false,
			ShowDir = false,
			Lock = false,
			AGfx = "Gloss",
			ASize = 44,
			AXO = 0,
			AYO = 0,
			TBut = true,
			TButColor = "0|0|0|.101",
			TButCombatColor = "1|0|0|.101",
			TSoundOn = true,
			ATBGPal = true,
			ATCorpse = true,
			ATTaxi = true,
		},
		Version = {		
			OptionsVersion = 0,
		},
		WinSettings = {
		},
   },
}


function Nx:OnInitialize()
	local ver = GetBuildInfo()
	local v1, v2, v3 = Nx.Split (".", ver)
	v1 = tonumber (v1) or 0
	v2 = tonumber (v2) or 0
	v3 = tonumber (v3) or 0
	ver = v1 * 10000 + v2 * 100 + v3

	Nx.V30 = true

	if ver < 10000 or ver >= 40003 then		-- Patch 4
		Nx.V403 = true
	end

	if ver > 10000 and ver < 50000 then		-- Old?
		local s = "|cffff2020Carbonite requires WoW 5"
		DEFAULT_CHAT_FRAME:AddMessage (s)
		UIErrorsFrame:AddMessage (s)
		Nx.NXVerOld = true
	end
	Nx.TooltipLastDiffNumLines = 0	
	Nx.db = LibStub("AceDB-3.0"):New("CarbData",defaults, true)
	Nx.SetupConfig()	
	Nx:RegisterComm("carbmodule",Nx.ModChatReceive)	
end

function Nx:OnEnable()
end

function Nx:OnDisable()
end
---------------------------------------------------------------------

--------
-- Slash command parsing

function Nx.slashCommand (txt)

	local UEvents = Nx.UEvents	
	local cmd, a1, a2 = Nx.Split (" ", txt)
	cmd = strlower (cmd)

	a1 = a1 or ""
	a2 = a2 or ""

	if cmd == "" or cmd == "?" or cmd == "help" then

		Nx.prt ("Commands:")
		Nx.prt (" goto [zone] x y  (set map goto)")
		Nx.prt (" gotoadd [zone] x y  (add map goto)")
		Nx.prt (" menu  (open menu)")
		Nx.prt (" note [\"]name[\"] [zone] [x y]  (make map note)")
		Nx.prt (" options  (open options window)")
		Nx.prt (" resetwin  (reset window layouts)")
		Nx.prt (" rl  (reload UI)")
		Nx.prt (" track name  (track the player)")
		Nx.prt (" winpos name x y  (position a window)")
		Nx.prt (" winshow name [0/1]  (toggle or show a window)")
		Nx.prt (" winsize name w h  (size a window)")

	elseif cmd == "goto" then
		local map = Nx.Map:GetMap (1)
		local s = gsub (txt, "goto%s*", "")
		map:SetTargetAtStr (s)

	elseif cmd == "gotoadd" then
		local map = Nx.Map:GetMap (1)
		local s = gsub (txt, "gotoadd%s*", "")
		map:SetTargetAtStr (s, true)

	elseif cmd == "menu" then
		Nx.NXMiniMapBut:OpenMenu()

	elseif cmd == "options" then
		Nx.Opts:Open()

	elseif cmd == "resetwin" then
		Nx.Window:ResetLayouts()

	elseif cmd == "rl" then
		ReloadUI()

	elseif cmd == "track" then
		if a1 then
			local map = Nx.Map:GetMap (1)
			map.TrackPlyrs[a1] = true
		end

	elseif cmd == "winpos" then
		Nx.Window:ConsolePos (gsub (txt, "winpos%s*", ""))

	elseif cmd == "winshow" then
		Nx.Window:ConsoleShow (gsub (txt, "winshow%s*", ""))

	elseif cmd == "winsize" then
		Nx.Window:ConsoleSize (gsub (txt, "winsize%s*", ""))	

	elseif cmd == "gatherd" then
		Nx.db.profile.Debug.DBGather = not Nx.db.profile.Debug.DBGather

	elseif cmd == "herb" then
		UEvents:AddHerb (strtrim (a1 .. " " .. a2))

	elseif cmd == "dbmapmax" then
		Nx.db.profile.Debug.DBMapMax = not Nx.db.profile.Debug.DBMapMax

	elseif cmd == "mine" then
		UEvents:AddMine (strtrim (a1 .. " " .. a2))

	elseif cmd == "addopen" then
		UEvents:AddOpen (a1, a2)	

	elseif cmd == "c" then
		Nx.Combat:Open()

	elseif cmd == "cap" then
		Nx.CaptureItems()

	elseif cmd == "crash" then
		assert()

	elseif cmd == "com" then
		Nx.Com.List:Open()

	elseif cmd == "comd" then
		Nx.db.profile.Debug.DebugCom = not Nx.db.profile.Debug.DebugCom
		ReloadUI()

	elseif cmd == "comt" then
		Nx.Com:Test (a1, a2)

	elseif cmd == "comver" then
		if Nx.db.profile.Debug.VerDebug then			-- Stop casual use
			Nx.Com:GetUserVer()
		end

	elseif cmd == "d" then
		Nx.DebugOn = not Nx.DebugOn

	elseif cmd == "dock" then
		Nx.db.profile.Debug.DebugDock = not Nx.db.profile.Debug.DebugDock

	elseif cmd == "events" then
		UEvents.List:Open()

	elseif cmd == "g" then
		Nx.Graph:Create (20, 50, UIParent)

		local g2 = Nx.Graph:Create (200, 20, UIParent)
		g2.Frm:SetPoint ("CENTER", 0, 100)

	elseif cmd == "item" then
		local id = format ("Hitem:%s", a1)
		GameTooltip:SetOwner (UIParent, "ANCHOR_LEFT", 0, 0)
		GameTooltip:SetHyperlink (id)
		local name, iLink, iRarity, lvl, minLvl, type, subType, stackCount, equipLoc, tx = GetItemInfo (id)
		Nx.prt ("Item: %s %s", name or "nil", iLink or "")

	elseif cmd == "kill" then
		UEvents:AddKill (a1)

	elseif cmd == "loot" then
		Nx.LootOn = not Nx.LootOn
		Nx.prt ("Loot %s", Nx.LootOn and "On" or "Off")

	elseif cmd == "mapd" then
		Nx.db.profile.Debug.DebugMap = not Nx.db.profile.Debug.DebugMap
		ReloadUI()

	elseif cmd == "questclr" then
		Nx.Quest:ClearCaptured()

	elseif cmd == "unitc" then
		Nx.db.profile.Debug.DebugUnit = true
		Nx:UnitDCapture()

	elseif cmd == "unitd" then
		Nx.db.profile.Debug.DebugUnit = not Nx.db.profile.Debug.DebugUnit

	elseif cmd == "vehpos" then
		Nx.Map:GetMap (1):VehicleDumpPos()

	else
		local s = gsub (txt, "note%s*", "")
		Nx:SendCommMessage("carbmodule","CMD|" .. cmd .. "|" .. s,"WHISPER",UnitName("player"))
	end
end

--------------------------------------------------------------------------------
-- Startup

function Nx:NXOnLoad (frm)

	SlashCmdList["Carbonite"] = Nx.slashCommand
	SLASH_Carbonite1 = "/Carb"	

	self.Frm = frm		--V4 this
	self.TimeLast = 0
	self.ClassColorStrs = Nx.Util_coltrgb2colstr (RAID_CLASS_COLORS)

	self:RegisterEvent ("ADDON_LOADED", Nx.ADDON_LOADED)
	self:RegisterEvent ("UNIT_NAME_UPDATE", Nx.UNIT_NAME_UPDATE)
	self:RegisterEvent ("PLAYER_ENTERING_WORLD", Nx.UNIT_NAME_UPDATE)
	Nx.CalendarDate = 0		-- For safety if Map update happens early
end

--------
--
function Nx:SetupEverything()	
	if not Nx.FirstTry then
		return
	end
	Nx.FirstTry = false
	local fact = UnitFactionGroup ("player")
	Nx.PlFactionNum = strsub (fact, 1, 1) == "A" and 0 or 1

	Nx.AirshipType = Nx.PlFactionNum == 0 and "Airship Alliance" or "Airship Horde"
	
	Nx:InitGlobal()	
	
	Nx:prtSetChatFrame()

	if Nx.db.profile.General.LoginHideVer then			
		Nx.prt (NXTITLE.." |cffffffff"..Nx.VERMAJOR.."."..(Nx.VERMINOR*10).." B"..Nx.BUILD.." "..NXLOADING)
	end

	Nx:LocaleInit()
	
	Nx:InitEvents()

	Nx.Proc:Init()

	Nx.Opts:Init()
	
	Nx:UIInit()
	Nx.Item:Init()

	Nx.Help:Init()

	Nx.Title:Init()
	Nx.NXMiniMapBut:Init()
	
	Nx.Com:Init()
	Nx.HUD:Init()
	Nx.Map:Init()
	
	Nx:GatherInit()	-- Needs map init. May need to do before map open
	Nx.Map:Open()		
	Nx.Travel:Init()

	Nx.Combat:Init()

	Nx.Combat:Open()

	Nx.UEvents:Init()
	Nx.UEvents.List:Open()

	if Nx.db.profile.General.LoginHideVer then
		Nx.prt (NXLOAD_DONE)
	end		
	if Nx.Font.AddonLoaded then
		Nx.Font:AddonLoaded()
	end
	Nx.Initialized = true
	Nx:OnPlayer_login("PLAYER_LOGIN")	
end

function Nx:ADDON_LOADED (event, arg1, ...)
	Nx.Loaded = true
end

function Nx:UNIT_NAME_UPDATE (event, arg1, ...)
	Nx.PlayerFnd = true	
end

function Nx:LocaleInit()
	local loc = GetLocale()

	if Nx.db.profile.General.LoginHideVer then
		Nx.prt (" %s", loc)
	end

	if loc ~= "deDE" and loc ~= "frFR" and loc ~= "esES" and loc ~= "esMX" then
		loc = "enUS"
	end

	Nx.Locale = loc
end

--------
-- Register events

function Nx:InitEvents()

	local Com = Nx.Com
	local Guide = Nx.Map.Guide
	local events = {

		"PLAYER_LOGIN", Nx.OnPlayer_login,		

		"UPDATE_MOUSEOVER_UNIT", Nx.OnUpdate_mouseover_unit,

		"PLAYER_REGEN_DISABLED", Nx.OnPlayer_regen_disabled,
		"PLAYER_REGEN_ENABLED", Nx.OnPlayer_regen_enabled,
		"UNIT_SPELLCAST_SENT", Nx.OnUnit_spellcast_sent,

		"ZONE_CHANGED_NEW_AREA", Nx.OnZone_changed_new_area,
		"PLAYER_LEVEL_UP", Nx.OnPlayer_level_up,

		"GROUP_ROSTER_UPDATE", Nx.OnParty_members_changed,

		"UPDATE_BATTLEFIELD_SCORE", Nx.OnUpdate_battlefield_score,
		"UPDATE_WORLD_STATES", Nx.OnUpdate_battlefield_score,

		"PLAYER_LEAVING_WORLD", Com.OnEvent,		
		"FRIENDLIST_UPDATE", Com.OnFriendguild_update,
		"GUILD_ROSTER_UPDATE", Com.OnFriendguild_update,
		"CHAT_MSG_CHANNEL_JOIN", Com.OnChatEvent,
		"CHAT_MSG_CHANNEL_NOTICE", Com.OnChatEvent,
		"CHAT_MSG_CHANNEL_LEAVE", Com.OnChatEvent,
		"CHAT_MSG_CHANNEL", Com.OnChat_msg_channel,
		
		"CHANNEL_ROSTER_UPDATE", Com.OnChannel_roster_update,
	
		"CHAT_MSG_BG_SYSTEM_NEUTRAL", Nx.OnChat_msg_bg_system_neutral,

		"AUCTION_HOUSE_SHOW", Nx.AuctionAssist.OnAuction_house_show,
		"AUCTION_HOUSE_CLOSED", Nx.AuctionAssist.OnAuction_house_closed,
		"AUCTION_ITEM_LIST_UPDATE", Nx.AuctionAssist.OnAuction_item_list_update,

		"PLAYER_TARGET_CHANGED", Guide.OnPlayer_target_changed,
		"MERCHANT_SHOW", Guide.OnMerchant_show,
		"MERCHANT_UPDATE", Guide.OnMerchant_update,
		"GOSSIP_SHOW", Guide.OnGossip_show,
		"TRAINER_SHOW", Guide.OnTrainer_show,

		"TAXIMAP_OPENED", Nx.Travel.OnTaximap_opened,
	}

	local n = 1
	while events[n] do
		Nx:RegisterEvent (events[n], events[n + 1])
		n = n + 2
	end

end

--------
-- Register for event and set event handler
-- (event name, handler to call)

function Nx:RegisterEvent (event, handler)

	self.Frm:RegisterEvent (event)

	if not self.Events then
		self.Events = {}
	end

	self.Events[event] = handler
end

-- Handle frame events

function Nx:NXOnEvent (event, ...)
	local h = self.Events[event]
	if h then
		h (nil, event, ...)
	else
		assert (0)
	end
end

--------
-- Login message

function Nx:OnPlayer_login (event, ...)	
	Nx:OnParty_members_changed()	
	Nx:RecordCharacterLogin()	
	Nx.Com:OnEvent (event)
	Nx.InitWins()

	Nx.BlizzChatFrame_DisplayTimePlayed = ChatFrame_DisplayTimePlayed		-- Save func
	ChatFrame_DisplayTimePlayed = function() end

--	RequestTimePlayed()	-- Blizz does not do anymore on login???
	Nx.RequestTime = true;
end

--------

function Nx:OnUpdate_mouseover_unit (event, ...)
	if Nx.Quest then
		Nx.Quest:TooltipProcess (true)
	end

	local data, guid, id, typ = Nx:UnitDGet ("mouseover")
	if guid then

		local tip = GameTooltip

		if typ == 0 then
			tip:AddLine (format ("GUID player %s", strsub (guid, 6)))

		elseif typ == 3 then
			tip:AddLine (format ("GUID NPC %d", id))

			Nx:UnitDTip()

		elseif typ == 4 then
			tip:AddLine (format ("GUID pet %s", strsub (guid, 13)))
		end

		tip:AddLine (format (" %s", guid))
		tip:Show()	-- Adjusts size
	end
end

function Nx:UnitDGet (target)

	if Nx.db.profile.Debug.DebugUnit then

		local guid = UnitGUID (target)
		if guid then

			local id = tonumber (strsub (guid, 7, 10), 16)
			local typ = tonumber (strsub (guid, 5, 5), 16)

			local data = Nx.db.profile.Debug.DBUnit or {}
			local ver = 2

			if (data["Ver"] or 0) < ver then
				data = {}
				data["Ver"] = ver
			end

			Nx.db.profile.Debug.DBUnit = data

			return data, guid, id, typ
		end
	end
end

-- Capture pos of target

function Nx:UnitDCapture()

	local data, guid, id, typ = self:UnitDGet ("target")
	if data and typ == 3 then

		local mid = GetCurrentMapAreaID()
		local plZX, plZY = GetPlayerMapPosition ("player")
		if mid and (plZX > 0 or plZY > 0) then

			local s = data[id] or "0~0~~~~"
			local reactA, reactH, _, _, _, tipStr = Nx.Split ("~", s)

			data[id] = format ("%s~%s~%s~%s~0~%s", reactA, reactH, mid, self:PackXY (plZX * 100, plZY * 100), tipStr)

			Nx.prt ("UnitDCap: %s, %s, %s", id, plZX * 10000, plZY * 10000)

		else

			Nx.prt ("Unit map error")
		end
	end
end

function Nx:UnitDTip()

	local data, guid, id, typ = self:UnitDGet ("mouseover")
	if data and typ == 3 then

		local midCur = GetCurrentMapAreaID()
		local plZX, plZY = GetPlayerMapPosition ("player")
		if midCur and (plZX > 0 or plZY > 0) then

			local react = UnitReaction ("mouseover", "player")

			local s = data[id]

			local reactA, reactH, mid, xy, dist = Nx.Split ("~", s or "0~0~~000000~9")

			reactA = reactA or 0
			reactH = reactH or 0

			local x, y = self:UnpackXY (xy)

			if Nx.PlFactionNum == 0 then
				reactA = react
			else
				reactH = react
			end

			dist = tonumber (dist)

			local dcur = 9
			if CheckInteractDistance ("mouseover", 1) then	-- 28 yards
				dcur = 2
			end
			if CheckInteractDistance ("mouseover", 3) then	-- 9.9 yards
				dcur = 1
			end

			if dcur <= dist then
				dist = dcur
				mid = midCur
				x = plZX * 100
				y = plZY * 100
			end

			local tipStr = ""
			local tip = GameTooltip
			local textName = "GameTooltipTextLeft"

			for n = 1, tip:NumLines() do
				local s = _G[textName .. n]:GetText()
				if s then
					tipStr = tipStr .. s .. "^"
				end
			end

			data[id] = format ("%s~%s~%s~%s~%s~%s", reactA, reactH, mid, self:PackXY (x, y), dist, tipStr)

			if IsControlKeyDown() then
				Nx.prt ("UnitDTip: %s %s, %d, %d (%d)", id, react or "nil", x * 100 + .5, y * 100 + .5, dist)
			end

			if IsShiftKeyDown() and IsControlKeyDown() and (x > 0 or y > 0) then

				local Map = Nx.Map
				local mapId = Map:GetCurrentMapId()
				local m = Map:GetMap (1)

				local tar = m:SetTargetXY (mapId, x, y, "UnitD " .. id)
		  		tar.Radius = 1
			end

		else

			Nx.prt ("Unit map error")
		end
	end
end

function Nx:OnPlayer_regen_disabled()
	Nx.Window:UpdateCombat()
end

function Nx:OnPlayer_regen_enabled()
	Nx.Window:UpdateCombat()
end

function Nx:OnUnit_spellcast_sent (event, arg1, arg2, arg3, arg4)

	if arg1 == "player" then

		local Nx = Nx
		if arg2 == NXlHERBGATHERING then
			Nx.GatherTarget = Nx.TooltipLastText

			if Nx.db.profile.Debug.DBGather then
				Nx.prt ("Gather: %s %s", arg2, Nx.GatherTarget or "nil")
			end

			if Nx.GatherTarget then
				Nx.UEvents:AddHerb (Nx.GatherTarget)
				Nx.GatherTarget = nil
			end

		elseif arg2 == NXlMINING then
			Nx.GatherTarget = Nx.TooltipLastText

			if Nx.db.profile.Debug.DBGather then
				Nx.prt ("Gather: %s %s", arg2, Nx.GatherTarget)
			end

			if Nx.GatherTarget then
				Nx.UEvents:AddMine (Nx.GatherTarget)
				Nx.GatherTarget = nil
			end

		elseif arg2 == NXlARTIFACTS then

			Nx.UEvents:AddOpen ("Art", arg4)

		elseif arg2 == NXlEXTRACTGAS then

			Nx.UEvents:AddOpen ("Gas", NXlEXTRACTGAS)

		elseif arg2 == NXlOpening or arg2 == NXlOpeningNoText then
			Nx.GatherTarget = Nx.TooltipLastText

			if arg4 == NXlGLOWCAP then
				Nx.UEvents:AddHerb (arg4)

			elseif arg4 == NXlEverfrost then
				Nx.UEvents:AddOpen ("Everfrost", arg4)

			end
		end
	end
end

function Nx:OnZone_changed_new_area (event)

	Nx.UEvents:AddInfo ("Entered")

	Nx.Com:OnEvent (event)
end

function Nx:OnPlayer_level_up (event, arg1)

	Nx.UEvents:AddInfo (format ("Level %d", arg1))

	Nx.Com:OnPlayer_level_up (event, arg1)
end

function Nx.OnParty_members_changed()

	local self = Nx

	local members = {}
	self.GroupMembers = members

	local memberCnt = MAX_PARTY_MEMBERS
	local unitName = "party"

	if IsInRaid() then
		memberCnt = MAX_RAID_MEMBERS
		unitName = "raid"
	end

	self.GroupType = unitName

	for n = 1, memberCnt do

		local unit = unitName .. n
		local name = UnitName (unit)
		if name then
			members[name] = n
		end
	end
	if Nx.Quest then
		Nx.Quest.OnParty_members_changed()
	end
end

function Nx:OnUpdate_battlefield_score (event)

	local plName = UnitName ("player")
	local scores = GetNumBattlefieldScores()
	local cb = Nx.Combat

	local show

	for n = 1, scores do
		local name, kbs, hks, deaths, honor, faction, rank, race, class, classCap, damDone, healDone = GetBattlefieldScore (n)
		if name == plName then

			honor = floor (honor)	--V4 returns weird fractions

			local any = kbs + deaths + hks + honor

			if any > 0 and (cb.KBs ~= kbs or cb.Deaths ~= deaths or cb.HKs ~= hks or cb.Honor ~= honor) then
				cb.KBs = kbs
				cb.Deaths = deaths
				cb.HKs = hks
				cb.Honor = honor

				show = true
			end

			cb.DamDone = damDone
			cb.HealDone = healDone

			break
		end
	end

	if show and Nx.db.profile.Battleground.ShowStats then

		local kbrank = 1

		for n = 1, scores do
			local name, kbs = GetBattlefieldScore (n)
			if name ~= plName then

				if kbs > cb.KBs then
					kbrank = kbrank + 1
				end
			end
		end

		Nx.prt ("%s KB (#%d), %s Deaths, %s HK, %d Bonus", cb.KBs, kbrank, cb.Deaths, cb.HKs, cb.Honor)
	end

end

--------
-- Generic update

function Nx:NXOnUpdate (elapsed)

	local Nx = Nx

	if Nx.Loaded and Nx.PlayerFnd and not Nx.Initialized and not InCombatLockdown() then	-- Safety check		
		Nx:SetupEverything()		
		return
	end	
	if not Nx.Loaded or not Nx.PlayerFnd or not Nx.Initialized then
		return
	end
	Nx.Tick = Nx.Tick + 1
	if Nx.LootOn then
		Nx:LootIt()
	end
	Nx.Proc:OnUpdate (elapsed)

	-- Tooltip stuff

	if not GameTooltip:IsVisible() then
		Nx.TooltipLastDiffText = nil
	end

	local s = GameTooltipTextLeft1:GetText()
	if s then

		if Nx.Tick % 4 == 1 and GameTooltipTextLeft1:IsVisible() and #s > 5 then
			if Nx.TooltipLastDiffText ~= s or Nx.TooltipLastDiffNumLines ~= GameTooltip:NumLines() then
				if Nx.Quest then
					Nx.Quest:TooltipProcess()
				end
			end
		end
		Nx.TooltipLastText = s
	end

	if Nx.TooltipOwner then
		if not Nx.TooltipOwner:IsVisible() then
			if GameTooltip:IsOwned (Nx.TooltipOwner) then
				GameTooltip:Hide()
			end
			Nx.TooltipOwner = nil
		end
	end

	--

	if self.NetSendPos then

		local t = GetTime()

		if t > self.NetPlyrSendTime then

			local plX, plY = GetPlayerMapPosition ("player")

			if plX > 0 or plY > 0 then

				local s = format ("Map~%d~%d~%d", plX * 100000000, plY * 100000000, Nx.Map:GetCurrentMapId())
				Nx.prt ("NetSend %s", s)
				Nx.Com:Send ("Z", s)

				self.NetPlyrSendTime = t + 1.5
			end
		end
	end

	local combat = UnitAffectingCombat ("player")
	if Nx.InCombat ~= combat then

		Nx.InCombat = combat
	end

	Nx.Com:OnUpdate (elapsed)
	Nx.Map:MainOnUpdate (elapsed)

	if Nx.Quest then
		Nx.Quest:OnUpdate (elapsed)
	end

	if Nx.Tick % 11 == 0 then
		Nx:RecordCharacter()
	end	
end

--------
-- Loot vendor Test

function Nx:LootIt()

	local b = _G["GossipTitleButton1"]

	if b:IsVisible() then
		b:Click()
	end
end

--------
-- Show a generic message with optional function callback

function Nx:ShowMessage (msg, func1Txt, func1, func2Txt, func2)

	local pop = StaticPopupDialogs["NxMsg"]

	if not pop then

		pop = {
			["whileDead"] = 1,
			["hideOnEscape"] = 1,
			["timeout"] = 0,
		}
		StaticPopupDialogs["NxMsg"] = pop
	end

	pop["text"] = msg
	pop["button1"] = func1Txt
	pop["OnAccept"] = func1
	pop["button2"] = func2Txt
	pop["OnCancel"] = func2

	StaticPopup_Show ("NxMsg")
end

--------
-- Show a generic edit box with optional function callback

function Nx:ShowEditBox (msg, val, userData, funcAccept, funcCancel)

--	Nx.prt ("ShowEditBox")

	local pop = StaticPopupDialogs["NxEdit"]

	if not pop then

		pop = {
			["whileDead"] = 1,
			["hideOnEscape"] = 1,
			["timeout"] = 0,
			["exclusive"] = 1,
			["hasEditBox"] = 1,
		}
		StaticPopupDialogs["NxEdit"] = pop
	end

	pop["maxLetters"] = 110
	pop["text"] = msg

	Nx.ShowEditBoxVal = tostring (val)
	Nx.ShowEditBoxUData = userData
	Nx.ShowEditBoxFunc = funcAccept

	pop["OnAccept"] = function (this)
		if Nx.ShowEditBoxFunc then
			Nx.ShowEditBoxFunc (_G[this:GetName().."EditBox"]:GetText(), Nx.ShowEditBoxUData)
		end
	end

	pop["EditBoxOnEnterPressed"] = function (this)
		if Nx.ShowEditBoxFunc then
			Nx.ShowEditBoxFunc (_G[this:GetParent():GetName().."EditBox"]:GetText(), Nx.ShowEditBoxUData)
		end
		this:GetParent():Hide()
	end

	pop["EditBoxOnEscapePressed"] = function (this)
		this:GetParent():Hide()
	end

	pop["OnShow"] = function (this)
		ChatEdit_FocusActiveWindow()
		local eb = _G[this:GetName().."EditBox"]
		eb:SetFocus()
		eb:SetText (Nx.ShowEditBoxVal)
		eb:HighlightText()
	end

	pop["OnHide"] = function (this)
		_G[this:GetName().."EditBox"]:SetText ("")
	end

	pop["button1"] = ACCEPT
	pop["button2"] = CANCEL
	pop["OnCancel"] = funcCancel

	StaticPopup_Show ("NxEdit")
end

--------
-- Show a trial message

function Nx:ShowMessageTrial()
end

--------
-- Find active chat frame edit box. Added for patch 3.35 because there is one for each possible chat window now
-- Was called ChatFrameEditBox. Now ChatFrame1EditBox to ChatFrame10EditBox

function Nx:FindActiveChatFrameEditBox()
	return ChatEdit_GetActiveWindow()
end

--------
-- Get time in seconds * 100. Adds fake hundreths

function Nx:Time()

	local tm = time()

	if tm > self.TimeLast then
		self.TimeFrac = 0
	else
		self.TimeFrac = self.TimeFrac + 1
	end

	self.TimeLast = tm

	return tm * 100 + self.TimeFrac
end

function Nx:UnitIsPlusMob (target)
	local c = UnitClassification (target)
	return c == "elite" or c == "rareelite" or c == "worldboss"
end

--------------------------------------------------------------------------------
-- Global Data Management

-- Gather format {}
--  Herb [map id] = { [#] = { Id = #, Cnt = times gathered, X, Y } }
--  Mine ^

function Nx:InitGlobal()    
	if Nx.db.profile.Version.OptionsVersion < Nx.VERSIONDATA then

		if Nx.db.profile.Version.OptionsVersion > 0 then
			Nx.prt ("Reset old data %f", Nx.db.profile.Version.OptionsVersion)
		end

		Nx.db:ResetDB("Default")
		Nx.db.profile.Version.OptionsVersion = Nx.VERSIONDATA
		Nx.db.global.Characters = {}  -- Indexed by "Server.Name"
	end

	if not Nx.db.profile.Version.NXVer1 then
		Nx.db.profile.Version.NXVer1 = Nx.VERSION
	end
	Nx:InitCharacter()

	-- 

--	local unitName = Nx.DemungeStr ("TnjrManc")	-- UnitName
--	Nx.PlayerName = _G[unitName] (Nx.DemungeStr ("olbwdr"))		-- player

	-- Global options

	local opts = Nx.db.profile

	if not opts or opts.Version.OptionsVersion < Nx.VERSIONGOPTS then

		if opts and opts.Version.OptionsVersion < Nx.VERSIONGOPTS then
			Nx.prt ("Reset old global options %f", opts.Version.OptionsVersion)
			Nx:ShowMessage ("Options have been reset for the new version.\nPrivacy or other settings may have changed.", "OK")
		end

		opts = {}
		Nx.db:ResetDB("Default")
		Nx.db.profile.Version.OptionsVersion = Nx.VERSIONGOPTS

--		Nx.Opts:Reset()
	end

	-- Clean old junk

--	opts.NXCleaned = nil

	if not opts.NXCleaned then

		opts.NXCleaned = true

		local keep = {
			["Characters"] = 1,
			["NXCap"] = 1,
			["NXFav"] = 1,
			["NXGather"] = 1,
			["NXGOpts"] = 1,
			["NXHUDOpts"] = 1,
			["NXInfo"] = 1,
			["NXQOpts"] = 1,
			["NXSocial"] = 1,
			["NXTravel"] = 1,
			["NXVendorV"] = 1,
			["NXVendorVVersion"] = 1,
			["NXVer1"] = 1,
			["NXVerT"] = 1,
			["NXWare"] = 1,
			["Version"] = 1,
		}

		local cnt = 0
		if cnt > 0 then
			Nx.prt ("Cleaned %d items", cnt)
		end
	end
	
	-- HUD options

	local opts = Nx.db.profile.HUDOpts

	if not opts or opts.Version < Nx.VERSIONHUDOPTS then

		if opts then
			Nx.prt ("Reset old HUD options %f", opts.Version)
		end

		opts = {}
		Nx.db.profile.HUDOpts = opts
		opts.Version = Nx.VERSIONHUDOPTS

--		Nx.HUD:OptsReset()
	end

	-- Travel data

	local tr = Nx.db.char.Travel

	if not tr or tr.Version < Nx.VERSIONTRAVEL then

		if tr then
			Nx.prt ("Reset old travel data %f", tr.Version)
		end

		tr = {}
		Nx.db.char.Travel = tr
		tr.Version = Nx.VERSIONTRAVEL
	end

	tr["TaxiTime"] = tr["TaxiTime"] or {}
	
	local cd = Nx.db.char.Travel.Taxi

	if not cd or cd.Version < Nx.VERSIONCharData then
		cd = {}
		Nx.db.char.Travel.Taxi = cd
		cd.Version = Nx.VERSIONCharData
		cd["Taxi"] = {}		-- Taxi nodes we have
	end

	--

	-- Gather data

	local gath = Nx.db.profile.GatherData

	if not gath or gath.Version < Nx.VERSIONGATHER then

		if gath and gath.Version < 0 then
			Nx.DoGatherUpgrade = gath.Version

		else
			if gath then
				Nx.prt ("Reset old gather data %f", gath.Version)
			end

			gath = {}
			Nx.db.profile.GatherData = gath
			gath.NXHerb = {}
			gath.NXMine = {}
		end

		gath.Version = Nx.VERSIONGATHER
	end

	gath["Misc"] = gath["Misc"] or {}
--	gath.NXGas = gath.NXGas or {}

	-- Capture data

	local cap = Nx.db.global.Capture		-- Keep NX

--	cap = nil		-- Nuke test

	if not cap or cap.Version < Nx.VERSIONCAP then

--		if cap then
--			Nx.prt ("Reset old cap %f", cap.Version)
--		end

		cap = {}
		Nx.db.global.Capture = cap
		cap.Version = Nx.VERSIONCAP
		cap["Q"] = {}

--		Nx.HUD:OptsReset()
	end

	cap["NPC"] = cap["NPC"] or {}
end

--------
-- Get generic named data (global, character, database)

function Nx:GetData (name, ch)

	ch = ch or Nx.CurCharacter

	if name == "Events" then
		return ch.E

	elseif name == "List" then
		return ch["L"]

	elseif name == "Quests" then
		return ch.Q

	elseif name == "Win" then
		return Nx.db.profile.WinSettings

	elseif name == "Herb" then
		return Nx.db.profile.GatherData.NXHerb

	elseif name == "Mine" then
		return Nx.db.profile.GatherData.NXMine

	end
end

--------
-- Copy character data

function Nx:CopyCharacterData (srcName, dstName)

	if not srcName then

		-- Export me to everyone

		local sch = Nx.CurCharacter

		for rc, dch in pairs (Nx.db.global.Characters) do

			if dch ~= sch then
				dch["L"] = sch["L"]
				dch["TBar"] = sch["TBar"]
			end
		end
	else

		local sch = Nx:FindCharacter (srcName)
		local dch = Nx:FindCharacter (dstName)

		if not sch or not dch then
			Nx.prt ("Missing character data!")
			return
		end

		-- Change references. Save will make copy
		dch["L"] = sch["L"]
		dch["TBar"] = sch["TBar"]
	end

	return true
end

--------
-- Delete character data

function Nx:DeleteCharacterData (srcName)

	self:DeleteCharacter (srcName)
	self:CalcRealmChars()
	if Nx.Warehouse then
		self.Warehouse:Update()
	end
end

--------
-- Import/Export

function Nx:ImportCharacterData()

	local tData = CarboniteTransferData
	if not tData then
		Nx.prtError ("Carbonite Transfer addon is not loaded")
		return
	end

	local accountName = GetCVar ("accountName")
	if accountName == "" then
		Nx.prtError ("'Remember Account Name' must be checked")
		return
	end

	local realmName = GetRealmName()

	for aName, aData in pairs (tData) do

		if aName ~= accountName then

			if aData.Version ~= Nx.VERSIONTransferData then
				Nx.prt ("Account %s data has wrong version", aName)

			else
				for rName, rData in pairs (aData) do
					if rName == realmName then

						Nx.prt ("Importing account %s", aName)

						for cName, cData in pairs (rData) do

							local rc = rName .. "." .. cName

							Nx.db.global.Characters[rc] = cData
							cData["Account"] = aName			-- Remember source account
						end

						aData[rName] = nil
					end
				end
			end
		end
	end
end

function Nx:ExportCharacterData()

	local tData = CarboniteTransferData
	if not tData then
		Nx.prtError ("Carbonite Transfer addon is not loaded")
		return
	end

	local accountName = GetCVar ("accountName")
	if accountName == "" then
		Nx.prtError ("'Remember Account Name' must be checked on Login screen")
		return
	end

	Nx.prt ("Exporting account %s data", accountName)

	local realmName = GetRealmName()

	local act = tData[accountName]
	if not act or act.Version < Nx.VERSIONTransferData then
		act = {}
		act.Version = Nx.VERSIONTransferData
	end
	tData[accountName] = act

	local data = {}
	act[realmName] = data

	for cnum, rc in ipairs (Nx.RealmChars) do

		local rname, cname = Nx.Split (".", rc)

		local ch = Nx.db.global.Characters[rc]
		if ch then

			if not ch["Account"] then		-- Only export our own characters

				Nx.prt (" Exporting %s", cname)

				local t = Nx.Util_TCopyRecurse (ch)
				data[cname] = t

				t["E"] = nil
				t["L"] = nil
				t["Q"] = nil
				t["W"] = nil
				t["TBar"] = nil
			end
		end
	end
end

--------
-- Get data

function Nx:GetDataToolBar()
	return Nx.CurCharacter["TBar"]
end

--------
-- Get HUD options

function Nx:GetHUDOpts()
	return Nx.db.profile.HUDOpts
end
--------
-- Get Travel data

--function Nx:GetTravel (name)
--	return NxData.NXTravel[name]
--end

--------
-- Get Captured data

function Nx:GetCap()
	return Nx.db.global.Capture
end

function Nx:CaptureFind (t, key)

	assert (type (t) == "table" and key)

	local d = t[key] or {}
	t[key] = d
	return d
end

--------
-- Make packed XY string
-- (xy 0-100)

function Nx:PackXY (x, y)

	x = max (0, min (100, x))
	y = max (0, min (100, y))
	return format ("%03x%03x", x * 40.9 + .5, y * 40.9 + .5)		-- Round off
end

--------

function Nx:UnpackXY (xy)

	local x = tonumber (strsub (xy, 1, 3), 16) / 40.9
	local y = tonumber (strsub (xy, 4, 6), 16) / 40.9
	return x, y
end

--------------------------------------------------------------------------------
-- Character Data Management

-- Event format OLD! Now a packed string!
--  Type table [Info, Kill, Death, Mine, Herb]
--   All have: Name, Time, Map, X, Y
--   T added by GetAllEvents for type ("I" "K" "D" "M" "H")
--   Kill: Level

-- Quest format
--  table index [quest id]
--  string "STime"
--   S (status char): C completed, c not completed, W watched
--   Time is number from time()

function Nx:InitCharacter()

--	NxData.Characters = {}

	local chars = Nx.db.global.Characters
	local fullName = self:GetRealmCharName()
	local ch = chars[fullName]

	if not ch or ch.Version < Nx.VERSIONCHAR then
		-- Add a new character
		ch = {}
		chars[fullName] = ch

		ch.Version = Nx.VERSIONCHAR

		ch.E = {}	-- Events
		ch.Q = {}	-- Quests		
	end

	Nx.CurCharacter = ch

	ch["Opts"] = ch["Opts"] or {}		-- Character options	

	ch["L"] = ch["L"] or {}	-- List

	if not ch["TBar"] then
		ch["TBar"] = {}	-- Tool Bar layouts
	end

	ch["Profs"] = ch["Profs"] or {}	-- Professions
	ch["Professions"] = nil				-- Old

	self:DeleteOldEvents()

	ch.NXLoggedOnNum = ch.NXLoggedOnNum or 0 + 1
	--
	self:CalcRealmChars()
end


--------
-- 

function Nx:GetRealmCharName()
	return GetRealmName() .. "." .. UnitName ("player")
end

--------
-- 

function Nx:CalcRealmChars()

	local chars = Nx.db.global.Characters

	local realmName = GetRealmName()
	local fullName = realmName .. "." .. UnitName ("player")

	local t = {}

	for rc, v in pairs (chars) do
		if v ~= Nx.CurCharacter then

			local rname = Nx.Split (".", rc)
			if rname == realmName then
				tinsert (t, rc)
			end
		end
	end

	sort (t)		-- Alphabetical

	tinsert (t, 1, fullName)	-- Put me at top

	self.RealmChars = t

	-- Fix char data

	for cnum, rc in ipairs (self.RealmChars) do

		local ch = chars[rc]
		if ch then

			if ch["XP"] then
				ch["XPMax"] = ch["XPMax"] or 1
				ch["XPRest"] = ch["XPRest"] or 0
				ch["LXP"] = ch["LXP"] or 0
				ch["LXPMax"] = ch["LXPMax"] or 1
				ch["LXPRest"] = ch["LXPRest"] or 0
			end

			ch["TimePlayed"] = ch["TimePlayed"] or 0
		end
	end
end

--------
-- Find character data for a named character on current realm or all realms if "realm.name"

function Nx:FindCharacter (name)

	for cnum, rc in ipairs (Nx.RealmChars) do

		local ch = Nx.db.global.Characters[rc]
		if ch then

			local rname, cname = Nx.Split (".", rc)
			if cname == name then
				return ch
			end
		end
	end

	return Nx.db.global.Characters[name]
end

--------
-- Delete character data for a named character on current realm or all realms if "realm.name"

function Nx:DeleteCharacter (name)

	for cnum, rc in ipairs (Nx.RealmChars) do

		local ch = Nx.db.global.Characters[rc]
		if ch then

			local rname, cname = Nx.Split (".", rc)
			if cname == name then
				Nx.db.global.Characters[rc] = nil
				return
			end
		end
	end

	Nx.db.global.Characters[name] = nil
end

--------

function Nx:GetUnitClass()
	local _, cls = UnitClass ("player")
	cls = gsub (Nx.Util_CapStr (cls), "Deathknight", "Death Knight")
	return cls
end

--------
-- Record logged in state

function Nx:RecordCharacterLogin()

--	Nx.prt ("Log in %d", GetMoney())

	local ch = self.CurCharacter

	ch["LTime"] = time()
	ch["LvlTime"] = time()

	ch["LLevel"] = UnitLevel ("player")
	ch["Class"] = Nx:GetUnitClass()

	ch["LMoney"] = GetMoney()

	ch["LXP"] = UnitXP ("player")
	ch["LXPMax"] = UnitXPMax ("player")
	ch["LXPRest"] = GetXPExhaustion() or 0

	local _, arena = GetCurrencyInfo (390)
	local _, honor = GetCurrencyInfo (392)

	ch["LArenaPts"] = arena		--V4 gone GetArenaCurrency()
	ch["LHonor"] = honor			--V4 gone GetHonorCurrency()	
	Nx:RecordCharacter()
end

function Nx:RecordCharacter()

--	Nx.prt ("RecordCharacter")

	local ch = self.CurCharacter

	local map = self.Map:GetMap (1)
	if map.RMapId then
		ch["Pos"] = format ("%d^%f^%f", map.RMapId, map.PlyrRZX, map.PlyrRZY)
	end

	ch["Time"] = time()

	ch["Level"] = UnitLevel ("player")

	if ch["Level"] > ch["LLevel"] then	-- Made a level? Reset
		ch["LLevel"] = ch["Level"]
		ch["LvlTime"] = time()
		ch["LXP"] = UnitXP ("player")
		ch["LXPMax"] = UnitXPMax ("player")
		ch["LXPRest"] = GetXPExhaustion() or 0
	end

	ch["Money"] = GetMoney()

	ch["XP"] = UnitXP ("player")
	ch["XPMax"] = UnitXPMax ("player")
	ch["XPRest"] = GetXPExhaustion() or 0

	local _, conquest = GetCurrencyInfo (390)
	local _, honor = GetCurrencyInfo (392)
	local _, justice = GetCurrencyInfo (395)
	local _, valor = GetCurrencyInfo (396)
	ch["Conquest"] = conquest		--V4 gone GetArenaCurrency()
	ch["Honor"] = honor			--V4 gone GetHonorCurrency()
	ch["Valor"] = valor
	ch["Justice"] = justice
end

function Nx:DeleteOldEvents()

	for rc, ch in pairs (Nx.db.global.Characters) do
		if not ch.E or ch.E["Info"] then		-- Missing or has an old table? (User had missing table)
			ch.E = {}
		end

		self:DeleteOldEvent (ch.E, 60)
	end
end

function Nx:DeleteOldEvent (ev, maxE)
	if #ev > maxE then

		for n = 1, #ev - maxE do
			tremove (ev, 1)
		end
	end
end

--------
-- Add event
-- (event) 1 letter name: I,K,D,H,M
-- (data) is optional string

function Nx:AddEvent (event, name, time, mapId, x, y, data)

	local ev = Nx.CurCharacter.E

--[[
	local i = #ev + 1

	local item = {}

	item.NXName = name
	item.NXTime = time
	item.NXMapId = mapId
	item.NXX = x
	item.NXY = y
--]]

	local s = Nx:PackXY (x, y)
	name = gsub (name, "^", "")

	s = format ("%s^%.0f^%d^%s^%s", event, time, Nx.MapIdToNxzone[mapId] or 0, s, name)

	if data then
		s = s .. "^" .. data
	end

	tinsert (ev, s)
end

--------

--function Nx:GetEventType (evStr)
--	return strsub (evStr, 1, 1)
--end

--------

function Nx:GetEventMapId (evStr)

	local _, _, map = Nx.Split ("^", evStr)

	return self.NxzoneToMapId[tonumber (map)] or 0
end

--------

function Nx:UnpackEvent (evStr)

	local typ, tm, map, xy, text, data = Nx.Split ("^", evStr)

	tm = tonumber (tm)
	map = self.NxzoneToMapId[tonumber (map)] or 0

	local x, y = Nx:UnpackXY (xy)

	return typ, tm, map, x, y, text, data
end

--------

function Nx:AddInfoEvent (name, time, mapId, x, y)
	self:AddEvent ("I", name, time, mapId, x, y)
end

function Nx:AddDeathEvent (name, time, mapId, x, y)
	self:AddEvent ("D", name, time, mapId, x, y)
end

function Nx:AddKillEvent (name, time, mapId, x, y)

	local ev = self.CurCharacter.E

	local kills = 1

	for k, item in ipairs (ev) do

		local typ, tm, mapId, x, y, text = self:UnpackEvent (item)

		if typ == "K" and text == name then
			kills = kills + 1
		end
	end

	self:AddEvent ("K", name, time, mapId, x, y, format ("%d", kills))
end

function Nx:AddHerbEvent (name, time, mapId, x, y)
	self:AddEvent ("H", name, time, mapId, x, y)
end

function Nx:AddMineEvent (name, time, mapId, x, y)
	self:AddEvent ("M", name, time, mapId, x, y)
end

--------
-- Get status for a quest

function Nx:GetQuest (qId)

	local quest = Nx.CurCharacter.Q[qId]
	if not quest then
		return
	end

	local s1, s2, status, time = strfind (quest, "(%a)(%d+)")

--	Nx.prt ("GetQuest %s %d", status, time)

	return status, time
end

function Nx:SetQuest (qId, qStatus, qTime)

	qTime = qTime or 0

	Nx.CurCharacter.Q[qId] = qStatus .. qTime

--	Nx.prt ("SetQuest %s", Nx.CurCharacter.Q[qId])
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Title

function Nx.Title:Init()

	local f = CreateFrame ("Frame", nil, UIParent)
	f.NxInst = self
	self.Frm = f

	f:SetFrameStrata ("HIGH")

	f:SetWidth (400)
	f:SetHeight (192)

	local bk = {
		["bgFile"] = "Interface\\Buttons\\White8x8",
		["edgeFile"] = "Interface\\DialogFrame\\UI-DialogBox-Border",
		["tile"] = true,
		["tileSize"] = 16,
		["edgeSize"] = 16,
		["insets"] = { ["left"] = 2, ["right"] = 2, ["top"] = 2, ["bottom"] = 2 }
	}

	f:SetBackdrop (bk)
	f:SetBackdropColor (0, 0, .1, 1)

	local lf = CreateFrame ("Frame", nil, f)

	lf:SetWidth (256)
	lf:SetHeight (128)

	lf:SetPoint ("CENTER", 0, 0)

	local t = lf:CreateTexture()
	t:SetTexture (Nx.Help.Logo)
--	t:SetVertexColor (1, 1, 1, 1)
	t:SetAllPoints (lf)
	lf.texture = t

	for n = 1, 2 do
		local fstr = f:CreateFontString()
		self["NXFStr"..n] = fstr
		fstr:SetFontObject ("GameFontNormal")
		fstr:SetJustifyH ("CENTER")
		fstr:SetPoint ("TOPLEFT", 0, -158 - (n - 1) * 14)
		fstr:SetWidth (400)
		fstr:Show()
	end

	local str

	if Nx.VERMINOR > 0 then
		str = NXTITLEFULL .. " |cffe0e0ffVersion %d.%d Build %d"
	else
		str = NXTITLEFULL .. " |cffe0e0ffVersion %d.%d Build %d"
	end

	str = format (str, Nx.VERMAJOR,Nx.VERMINOR*10, Nx.BUILD)

	self.NXFStr1:SetText (str)
	self.NXFStr2:SetText ("|cffe0e0ffMaintained by Rythal of Moonguard")

	Nx.Proc:New (self, self.TickWait, 40)

--	f:Show()
end

function Nx.Title:TickWait (proc)

	Nx.Map:StartupZoom()
	Nx.Proc:SetFunc (proc, self.TickWait2)
	return 30
end

function Nx.Title:TickWait2 (proc)
	self.X = 0
	self.Y = GetScreenHeight() * .4
	self.XV = 0
	self.YV = 0
	self.Scale = .8
	self.ScaleTarget = .8
	self.Alpha = 0
	self.AlphaTarget = 1

--	Nx.prt ("Y %s", self.Y)
	
	if Nx.db.profile.General.TitleSoundOn then
		PlaySound ("ReadyCheck")
	end

	Nx.Proc:SetFunc (proc, self.Tick)
end

function Nx.Title:Tick()

	local this = self.Frm

--PAIDS!	
	if not Nx.db.profile.General.TitleOff then
		this:Hide()
	end
--PAIDE!

	self.X = self.X + self.XV
	self.Y = self.Y + self.YV

	self.Scale = Nx.Util_StepValue (self.Scale, self.ScaleTarget, .8 / 60)

	this:SetPoint ("CENTER", self.X / self.Scale, self.Y / self.Scale)
	this:SetScale (self.Scale)

--	Nx.prt ("Title %f %f", elapsed, self.Alpha)

	self.Alpha = Nx.Util_StepValue (self.Alpha, self.AlphaTarget, .8 / 60)
	this:SetAlpha (self.Alpha)

	if self.Alpha == 1 then

		local sw = GetScreenWidth() / 2
		local sh = GetScreenHeight() / 2
		self.XV = (sw * .95 - self.X) / 80
		self.YV = (sh * .95 - self.Y) / 80

		self.ScaleTarget = .03
		self.AlphaTarget = 0

		return 1 * 60
	end

	if self.Alpha == 0 then

		this:Hide()		
		return -1	-- Die
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Auction

--PAIDS!

function Nx.AuctionAssist.OnAuction_house_show()

--	Nx.prt ("OnAUCTION_HOUSE_SHOW")

	if IsAddOnLoaded ("Blizzard_AuctionUI") then
		hooksecurefunc ("AuctionFrameBrowse_Update", Nx.AuctionAssist.AuctionFrameBrowse_Update)
		Nx.AuctionAssist:Create()
	end
end

function Nx.AuctionAssist.OnAuction_house_closed()

--	Nx.prt ("OnAUCTION_HOUSE_CLOSED")

	local self = Nx.AuctionAssist
	if self.Win then
		self.Win:Show (false)
		self.ItemList:Empty()
	end
end

function Nx.AuctionAssist.OnAuction_item_list_update()
--	Nx.prt ("OnAUCTION_ITEM_LIST_UPDATE")
	Nx.AuctionAssist:Update()
end

--------
-- Create favorites window

function Nx.AuctionAssist:Create()
end

--------
-- On list events

function Nx.AuctionAssist:OnListEvent (eventName, sel, val2, click)

--	Nx.prt ("Guide list event "..eventName)

	local name = self.List:ItemGetData (sel)

	Nx.prt ("%s", name)

	BrowseName:SetText (name)
	AuctionFrameBrowse_Search()
end

function Nx.AuctionAssist:Update()

end

--------

function Nx.AuctionAssist.AuctionFrameBrowse_Update()

	if not Nx.AuctionShowBOPer then
		return
	end

--	Nx.prt ("Auction")

	local low = 99999999
	local lowName
	local lowIName

	local numBatchAuctions, totalAuctions = GetNumAuctionItems ("list")
	local offset = FauxScrollFrame_GetOffset (BrowseScrollFrame)
	local last = offset + NUM_BROWSE_TO_DISPLAY

--	Nx.prt ("Auction off %d %d %d", offset, numBatchAuctions, totalAuctions)

	for n = 1, NUM_AUCTION_ITEMS_PER_PAGE do

		local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner = GetAuctionItemInfo ("list", n)

--		Nx.prt ("Auction #%d %d %d", n, buyoutPrice, count)

		local index = n + NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse["page"]

		if index > numBatchAuctions + NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse["page"] then
			break
		end

		if bidAmount == 0 then
			requiredBid = minBid
		else
			requiredBid = bidAmount + minIncrement
		end

		if requiredBid >= MAXIMUM_BID_PRICE then
			buyoutPrice = requiredBid
		end

		if buyoutPrice > 0 then

			local price1 = floor (buyoutPrice / count)

			if n > offset and n <= last then

				local buttonName = "BrowseButton" .. (n - offset)
				local itemName = _G[buttonName .. "Name"]

				if itemName then

					if price1 < low then
						low = price1
						lowName = name
						lowIName = itemName
					end

--					Nx.prtVar ("name", buttonName)

					if count > 1 then

						itemName:SetText (format ("%s *", name))

						local color = ITEM_QUALITY_COLORS[quality]
						itemName:SetVertexColor (color.r, color.g, color.b)

						local bf = _G[buttonName.."BuyoutFrameMoney"]
						if bf then
							MoneyFrame_Update (bf:GetName(), price1)
						end
					end
				end

			elseif price1 < low then
				low = price1
				lowName = nil
			end
		end
	end

	if lowName then
		lowIName:SetText (format ("%s * low", lowName))
	end
end

--PAIDE!

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Combat

--------
-- Init combat

function Nx.Combat:Init()

	self.KBs = 0
	self.Deaths = 0
	self.HKs = 0
	self.Honor = 0
	self.DamDone = 0
	self.HealDone = 0

	self.Frm = nil
	self.HitPeak = 1
	self.HitTotal = 0
	self.HitBest = 0
	self.W = 400
	self.H = 80
	self.InCombat = false
	self.AttackerName = "?"
end

--------
-- Open and init or toggle combat frame

function Nx.Combat:Open()

--PAIDS!

	local win = self.Win

	if win then
		if win:IsShown() then
			win:Show (false)
		else
			win:Show()
		end
		return
	end


	self.EventTable = {
	}	

	local win = Nx.Window:Create ("NxCombat", nil, nil, nil, nil, nil, true)
	self.Win = win

	win:InitLayoutData (nil, -.7, -.7, -.3, -.06)

	win:CreateButtons (true)

	-- Create frame

	local f = CreateFrame ("Frame", nil, UIParent)
	self.Frm = f
	f.NxCombat = self

	win:Attach (f, 0, 1, 0, 1)

	f:SetScript ("OnEvent", self.OnEvent)

	f:RegisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")
	f:RegisterEvent ("CHAT_MSG_COMBAT_XP_GAIN")
	f:RegisterEvent ("CHAT_MSG_COMBAT_HONOR_GAIN")
	f:RegisterEvent ("CHAT_MSG_LOOT")
	f:RegisterEvent ("PLAYER_REGEN_DISABLED")
	f:RegisterEvent ("PLAYER_REGEN_ENABLED")

	for k, v in pairs (self.EventTable) do
		f:RegisterEvent (k)
	end

	f:RegisterEvent ("PLAYER_DEAD")

	f:SetScript ("OnUpdate", self.OnUpdate)

	f:SetScript ("OnEnter", self.OnEnter)
	f:SetScript ("OnLeave", self.OnEnter)
	f:EnableMouse (true)

	f:SetFrameStrata ("MEDIUM")

	local t = f:CreateTexture()
	t:SetTexture (.2, .2, .2, .5)
	t:SetAllPoints (f)
	f.texture = t

	f:Show()

	self:OpenGraph()

end

function Nx.Combat:OpenGraph()
	self.GraphHits = Nx.Graph:Create (self.W, 50, self.Frm)
	local f = self.GraphHits.MainFrm
	self.Win:Attach (f, 0, 1, 0, 1)
end

--------

function Nx.Combat:OnEvent (event, ...)

	local arg1, arg2, arg3 = select (1, ...)

	local Combat = Nx.Combat
	local UEvents = Nx.UEvents
	local prtD = Nx.prtD
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then

		local OBJ_AFFILIATION_MINE = 1
		local OBJ_TYPE_PET			= 0x00001000
		local OBJ_TYPE_GUARDIAN		= 0x00002000

		local time, cEvent, _hideCaster, sId, sName, sFlags, sf2, dId, dName, dFlags, df2, a1, a2, a3, a4 = select (1, ...)
		local pre, mid, post = Nx.Split ("_", cEvent)
		if not post then
			post = mid
		end

		if bit.band (sFlags, OBJ_AFFILIATION_MINE) > 0 then

			local spellId, spellName, spellSchool
			local i = 12

			if pre ~= "SWING" then
				spellId, spellName, spellSchool = select (12, ...)
				i = 15
			end

			local amount, school, resist, block, absorb, crit = select (i, ...)

			if post == "DAMAGE" then

				local v = amount

				local hitStr = crit and "|cffff00ffcrit" or "hit"

				if spellName then
					hitStr = spellName
					if mid == "PERIODIC" then
						hitStr = spellName .. " dot"
					end
					if crit then
						hitStr = hitStr .. " |cffff00ffcrit"
					end
				end
				local s = format ("|cff00ff00%s|r %s |cffff0000'%s'|r %d", sName or "?", hitStr, dName, amount)

				if bit.band (sFlags, OBJ_TYPE_PET + OBJ_TYPE_GUARDIAN) > 0 then
					if pre == "SPELL" then
						if crit then
							Combat:SetLine (v, "e0a000", s)
						else
							Combat:SetLine (v, "906000", s)
						end
					else
						if crit then
							Combat:SetLine (v, "e0a0a0", s)
						else
							Combat:SetLine (v, "806060", s)
						end
					end
				else
					if pre == "SPELL" then
						if crit then
							Combat:SetLine (v, "e0e000", s)
						else
							Combat:SetLine (v, "909000", s)
						end
					else
						if crit then
							Combat:SetLine (v, "e0e0e0", s)
						else
							Combat:SetLine (v, "808080", s)
						end
					end
				end

			elseif cEvent == "PARTY_KILL" then

				Combat:SetLine (-1, "e02020", "Killed " .. dName)
				UEvents:AddKill (dName)
			end

		elseif bit.band (dFlags, OBJ_AFFILIATION_MINE) > 0 then

			if post == "DAMAGE" and sName then
				Combat.AttackerName = sName
			end
		end
	elseif event == "CHAT_MSG_COMBAT_XP_GAIN" then
		local s1, s2, name = strfind (arg1, "gain (%d+) ex")
		if s1 then
			Combat:SetLine (-1, "20e020", arg1)
			UEvents:AddInfo ("+"..name.." xp")
		end
	elseif event == "CHAT_MSG_COMBAT_HONOR_GAIN" then
		local s1, s2, val = strfind (arg1, "(%d*%.%d+) %aonor")	--V4
		if s1 then
			UEvents:AddHonor ("+".. val .." honor")
			return
		end

		local s1, s2, name = strfind (arg1, "(%d+) %aonor")
		if s1 and name ~= "0" then
			UEvents:AddHonor ("+"..name.." honor")
		end

	elseif event == "CHAT_MSG_LOOT" then
		local s1, s2 = strfind (arg1, "Honor Points%.")	--V4
		if s1 then
			UEvents:AddHonor ("+1 honor")
			return
		end

		local s1, s2, val = strfind (arg1, "Honor Points x(%d+)")	--V4
		if s1 then
			UEvents:AddHonor ("+" .. val .. " honor")
			return
		end

	elseif event == "PLAYER_REGEN_DISABLED" then
		Combat:EnterCombat()

	elseif event == "PLAYER_REGEN_ENABLED" then
		Combat.InCombat = false

	elseif event == "PLAYER_DEAD" then
		UEvents:AddDeath (Combat.AttackerName)

	else
		if Combat.EventTable[event] then
			Combat.EventTable[event] (Combat, arg1)
		end

	end
end

function Nx.Combat:OnUpdate (...)

end

function Nx.Combat:OnEnter (motion)

end

--------
-- Start combat

function Nx.Combat:EnterCombat (value)

	if not self.InCombat then
		self.InCombat = true
		self.HitPeak = 10
		self.HitTotal = 0
		self.TimeStart = GetTime()

		self.GraphHits:Clear()
		self.GraphHits:SetPeak (self.HitPeak)
	end
end

--------
-- Set a new graph line to value

function Nx.Combat:SetLine (value, colorStr, infoStr)

	self:EnterCombat()

	if value > self.HitPeak then
		self.HitPeak = value
		self.GraphHits:SetPeak (self.HitPeak)
	end

	self.HitTotal = self.HitTotal + value

	if value > self.HitBest then
		self.HitBest = value
	end

	local time = GetTime() - self.TimeStart + .001		-- Dont allow zero

	self.GraphHits:SetLine (time, value, colorStr, infoStr)

	local txt = string.format ("Hit %3.0f Peak "..self.HitPeak.." Best "..self.HitBest.." Total %.0f Time %.2f DPS %.1f", value, self.HitTotal, time, self.HitTotal / time)
	self.Win:SetTitle (txt)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- User events recording and list

function Nx.UEvents:Init()

--	self.Sorted = {}
end

------
-- Add info to list

function Nx.UEvents:AddInfo (name)

	local mapId, x, y = self:GetPlyrPos()

	Nx:AddInfoEvent (name, Nx:Time(), mapId, x, y)

	self:UpdateAll()

	return mapId
end

------
-- Add player death to list

function Nx.UEvents:AddDeath (name)

	local mapId, x, y = self:GetPlyrPos()

	Nx:AddDeathEvent (name, Nx:Time(), mapId, x, y)

	self:UpdateAll()

--	Nx:SendComm (2, "Death "..name)

	if Nx.Map:IsBattleGroundMap (mapId) then
--		Nx.prt ("Req D")
		RequestBattlefieldScoreData()
	end
end

------
-- Add kill to list

function Nx.UEvents:AddKill (name)

	local mapId, x, y = self:GetPlyrPos()

	Nx:AddKillEvent (name, Nx:Time(), mapId, x, y)

	self:UpdateAll()

--	Nx:SendComm (2, "Killed "..name)
end

------
-- Add honor info to list

function Nx.UEvents:AddHonor (name)

	local mapId = self:AddInfo (name)

	if Nx.Map:IsBattleGroundMap (mapId) then
--		Nx.prt ("Req H")
		RequestBattlefieldScoreData()
	end
end

------
-- Add herb to list

function Nx.UEvents:AddHerb (name)

	local mapId, x, y = self:GetPlyrPos()
	if Nx.db.profile.Guide.GatherEnabled then
		local id = Nx:HerbNameToId (name)
		if id then

			Nx:AddHerbEvent (name, Nx:Time(), mapId, x, y)
			Nx:GatherHerb (id, mapId, x, y)
		end	
		self:UpdateAll (true)
	end		
end

------
-- Add mine to list

function Nx.UEvents:AddMine (name)

	local mapId, x, y = self:GetPlyrPos()
	if Nx.db.profile.Guide.GatherEnabled then
		local id = Nx:MineNameToId (name)
		if id then
			Nx:AddMineEvent (name, Nx:Time(), mapId, x, y)
			Nx:GatherMine (id, mapId, x, y)
		end
		self:UpdateAll (true)
	end
end

------
-- Add open to list

function Nx.UEvents:AddOpen (typ, name)

	local mapId = self:AddInfo (name)
	if Nx.db.profile.Guide.GatherEnabled then
		local mapId, x, y = self:GetPlyrPos()
		Nx:Gather ("Misc", typ, mapId, x, y)
		self:UpdateAll()
	end
end

--------
-- Get player map pos

function Nx.UEvents:GetPlyrPos()

	local mapId = Nx.Map:GetRealMapId()
	local map = Nx.Map:GetMap (1)
	return mapId, map.PlyrRZX, map.PlyrRZY
end

--------

function Nx.UEvents:UpdateAll (upGuide)

	self:Sort()
	self:UpdateMap (upGuide)
	self.List:Update()
end

--------
-- Sort compare

function Nx.UEvents.SortCmp (v1, v2)

--	prtD ("Sort "..v1.Time.." "..v2.Time)

	local _, tm1 = Nx.Split ("^", v1)
	local _, tm2 = Nx.Split ("^", v2)

	return tonumber (tm1) < tonumber (tm2)
end

--------

function Nx.UEvents:Sort()

--	wipe (self.Sorted)

--	Nx:AddAllEvents (self.Sorted)

--	sort (self.Sorted, self.SortCmp)

	sort (Nx.CurCharacter.E, self.SortCmp)		-- Should already be sorted, but whatever
end

--------
-- Open and init or toggle user events list

function Nx.UEvents.List:Open()

	local UEvents = Nx.UEvents

	local win = self.Win

	if win then
		if win:IsShown() then
			win:Show (false)
		else
			win:Show()
		end
		return
	end

	-- Create Window

	local win = Nx.Window:Create ("NxEventsList", nil, nil, nil, nil, nil, true)
	self.Win = win

	win:CreateButtons (true)

	win:InitLayoutData (nil, -.75, -.6, -.25, -.1)

	local list = Nx.List:Create ("Events", 2, -2, 100, 12 * 3, win.Frm)
	self.List = list
	list:ColumnAdd ("Time", 1, 70)
	list:ColumnAdd ("Event", 2, 140)
	list:ColumnAdd ("#", 3, 30, "CENTER")
	list:ColumnAdd ("Position", 4, 500)

	win:Attach (list.Frm, 0, 1, 0, 1)

	UEvents:UpdateAll()
end

------
function Nx.UEvents.List:Update()

	local Nx = Nx
	local UEvents = Nx.UEvents

	if not self.Win then
		return
	end

	local sorted = Nx.CurCharacter.E

	self.Win:SetTitle (format ("Events: %d", #sorted))

	local list = self.List
	local isLast = list:IsShowLast()
	list:Empty()

	for k, item in ipairs (sorted) do

		local typ, tm, mapId, x, y, text, data = Nx:UnpackEvent (item)

		list:ItemAdd()
		list:ItemSet (1, date ("%d %H:%M:%S", tm / 100))

		local eStr = text

		if typ == "D" then

			eStr = "|cffff6060Died! " .. text

		elseif typ == "K" then

			list:ItemSet (3, data)

			eStr = "|cffff60ffKilled " .. text

		elseif typ == "H" then

			eStr = "|cff60ff60Picked " .. text

		elseif typ == "M" then

			eStr = "|cffc0c0c0Mined " .. text

		end

		list:ItemSet (2, eStr)

		local mapName = Nx.Map:IdToName (mapId)

		local str = format ("%s %.0f %.0f", mapName, x, y)
		list:ItemSet (4, str)
	end

	list:Update (isLast)
end

------
-- Update user event data on map

function Nx.UEvents:UpdateMap (upGuide)

--	Nx.prt ("UEvents:UpdateMap")

	local Nx = Nx
	local Map = Nx.Map

	local mapId = Map:GetCurrentMapId()
	local m = Map:GetMap (1)

	if m then

		if upGuide then
			m.Guide:Update()
		end

		m:InitIconType ("Kill", nil, "Interface\\TargetingFrame\\UI-TargetingFrame-Skull", 16, 16)
		m:InitIconType ("Death", nil, "Interface\\TargetingFrame\\UI-TargetingFrame-Seal", 16, 16)

		local icon

		for k, item in ipairs (Nx.CurCharacter.E) do

			local iMapId = Nx:GetEventMapId (item)

			if iMapId == mapId then

				local typ, _, _, x, y, text = Nx:UnpackEvent (item)

				if typ == "K" then
					icon = m:AddIconPt ("Kill", x, y)
					m:SetIconTip (icon, text)

				elseif typ == "D" then
					icon = m:AddIconPt ("Death", x, y)
					m:SetIconTip (icon, text)
				end
			end
		end

	end
end

-------------------------------------------------------------------------------

Nx.GatherInfo = {
	[" "] = {	-- Misc
		["Art"] = { 0, "Trade_Archaeology",					"Artifact", "Artifact", "Artifact", "Artifact"	},
		["Everfrost"] = { 0, "spell_shadow_teleport",			NXlEverfrost, NXlEverfrost, NXlEverfrost, NXlEverfrost	},
		["Gas"] = { 0, "inv_gizmo_zapthrottlegascollector",	NXlGas, NXlGas, NXlGas, NXlGas	},
	},
	["H"] = {	-- Herbs
		{ 340, "INV_Misc_Herb_AncientLichen",		"Ancient Lichen",			"Urflechte",								"Lichen ancien",					"Liquen antiguo" },
		{ 220, "INV_Misc_Herb_13",						"Arthas' Tears",			"Arthas\226\128\153 Tr\195\164nen",	"Larmes d'Arthas ",				"L\195\161grimas de Arthas" },
		{ 300, "INV_Misc_Herb_17",						"Black Lotus",				"Schwarzer Lotus",						"Lotus noir",						"Loto negro" },
		{ 235, "INV_Misc_Herb_14",						"Blindweed",				"Blindkraut",								"Aveuglette",						"Carolina" },
		{ 1,   "INV_Misc_Herb_11a",					"Bloodthistle",			"Blutdistel",								"Chardon sanglant",				"Cardo de sangre" },
		{ 70,	 "INV_Misc_Root_01",						"Briarthorn",				"Wilddornrose",							"Eglantine",						"Brezospina" },
		{ 100, "INV_Misc_Herb_01",						"Bruiseweed",				"Beulengras",								"Doulourante",						"Hierba cardenal" },
		{ 270, "INV_Misc_Herb_DreamFoil",			"Dreamfoil",				"Traumblatt",								"Feuiller\195\170ve",			"Hojasue\195\177o" },
		{ 315, "INV_Misc_Herb_Dreamingglory",		"Dreaming Glory",			"Traumwinde",								"Glaurier",							"Gloria de ensue\195\177o" },
		{ 15,	 "INV_Misc_Herb_07",						"Earthroot",				"Erdwurzel",								"Terrestrine",						"Ra\195\173z de tierra" },
		{ 160, "INV_Misc_Herb_12",						"Fadeleaf",					"Blassblatt",								"P\195\162lerette",				"P\195\161lida" },
		{ 300, "INV_Misc_Herb_Felweed",				"Felweed",					"Teufelsgras",								"Gangrelette",						"Hierba vil" },
		{ 205, "INV_Misc_Herb_19",						"Firebloom",				"Feuerbl\195\188te",						"Fleur de feu",					"Flor de Fuego" },
		{ 335, "INV_Misc_Herb_Flamecap",				"Flame Cap",				"Flammenkappe",							"Chapeflamme",						"Copo de llamas" },
		{ 245, "INV_Mushroom_08",						"Ghost Mushroom",			"Geisterpilz",								"Champignon fant\195\180me",	"Champi\195\177\195\179n fantasma" },
		{ 260, "INV_Misc_Herb_SansamRoot",			"Golden Sansam",			"Goldener Sansam",						"Sansam dor\195\169",			"Sansam dorado" },
		{ 170, "INV_Misc_Herb_15",						"Goldthorn",				"Golddorn",									"Dor\195\169pine",				"Espina de oro" },
		{ 120, "INV_Misc_Dust_02",						"Grave Moss",				"Grabmoos",									"Tombeline",						"Musgo de tumba" },
		{ 250, "INV_Misc_Herb_16",						"Gromsblood",				"Gromsblut",								"Gromsang",							"Gromsanguina" },
		{ 290, "INV_Misc_Herb_IceCap",				"Icecap",					"Eiskappe",									"Chapeglace",						"Setelo" },
		{ 185, "INV_Misc_Herb_08",						"Khadgar's Whisker",		"Khadgars Schnurrbart",					"Moustache de Khadgar",			"Mostacho de Khadgar" },
		{ 125, "INV_Misc_Herb_03",						"Kingsblood",				"K\195\182nigsblut",						"Sang-royal",						"Sangrerregia" },
		{ 150, "INV_Misc_Root_02",						"Liferoot",					"Lebenswurz",								"Viet\195\169rule",				"Vidarra\195\173z" },
		{ 50,  "Spell_Shadow_DeathAndDecay",		"Mageroyal",				"Magusk\195\182nigskraut",				"Mage royal",						"Marregal" },
		{ 375, "INV_Misc_Herb_Manathistle",			"Mana Thistle",			"Manadistel",								"Chardon de mana",				"Cardo de man\195\161" },
		{ 280, "INV_Misc_Herb_MountainSilverSage","Mountain Silversage",	"Bergsilbersalbei",						"Sauge-argent des montagnes",	"Salviargenta de monta\195\177a" },
		{ 350, "INV_Misc_Herb_Netherbloom",			"Netherbloom",				"Netherbl\195\188te",					"N\195\169antine",				"Flor abisal" },
		{ 350, "INV_Enchant_DustSoul",				"Netherdust Bush",		"Netherstaubbusch",						"Buisson de pruin\195\169ante","Arbusto de polvo abisal" },
		{ 365, "INV_Misc_Herb_Nightmarevine",		"Nightmare Vine",			"Alptraumranke",							"Cauchemardelle",					"Vid Pesadilla" },
		{ 1,   "INV_Misc_Flower_02",					"Peacebloom",				"Friedensblume",							"Pacifique",						"Flor de paz" },
-- Sorrowmoss replaced Plaguebloom
		{ 285, "inv_misc_herb_plaguebloom",			"Sorrowmoss",				"Trauermoos",								"Chagrinelle",						"Musgopena" },
		{ 210, "INV_Misc_Herb_17",						"Purple Lotus",			"Lila Lotus",								"Lotus pourpre",					"Loto c\195\161rdeno" },
		{ 325, "INV_Misc_Herb_Ragveil",				"Ragveil",					"Zottelkappe",								"Voile-mis\195\168re",			"Velada" },
		{ 1,   "INV_Misc_Herb_10",						"Silverleaf",				"Silberblatt",								"Feuillargent",					"Hojaplata" },
		{ 85,  "INV_Misc_Herb_11",						"Stranglekelp",			"W\195\188rgetang",						"Etouffante",						"Alga estranguladora" },
		{ 230, "INV_Misc_Herb_18",						"Sungrass",					"Sonnengras",								"Soleillette",						"Solea" },
		{ 325, "INV_Misc_Herb_Terrocone",			"Terocone",					"Terozapfen",								"Teroc\195\180ne",				"Teropi\195\177a" },
		{ 115, "INV_Misc_Flower_01",					"Wild Steelbloom",		"Wildstahlblume",							"Aci\195\169rite sauvage",		"Ac\195\169rita salvaje" },
-- Dragon's Teeth replaced Wintersbite
		{ 195, "inv_misc_flower_03",					"Dragon's Teeth",			"Drachenzahn",								"Dents de dragon",				"Dientes de drag\195\179n" },
		{ 1,   "INV_Mushroom_02",						"Glowcap",					"Gl\195\188hkappe",						"Chapeluisant",					"Fluochampi\195\177\195\179n" },
		{ 350, "inv_misc_herb_goldclover",			"Goldclover",				"Goldklee",									"Tr\195\168fle dor\195\169",	"Tr\195\169bol de oro" },
		{ 385, "inv_misc_herb_talandrasrose",		"Talandra's Rose",		"Talandras Rose",							"Rose de Talandra",				"Rosa de Talandra" },
		{ 400, "inv_misc_herb_evergreenmoss",		"Adder's Tongue",			"Schlangenzunge",							"Verp\195\169renne",				"Lengua de v\195\173boris" },
		{ 400, "inv_misc_herb_goldclover",			"Frozen Herb",				"Gefrorenes Kraut",						"Herbe gel\195\169e",			"Hierba de escarcha" },
		{ 400, "inv_misc_herb_tigerlily",			"Tiger Lily",				"Tigerlilie",								"Lys tigr\195\169",				"Lirio atigrado" },
		{ 425, "inv_misc_herb_whispervine",			"Lichbloom",				"Lichbl\195\188te",						"Fleur-de-liche",					"Flor ex\195\161nime" },
		{ 435, "inv_misc_herb_icethorn",				"Icethorn",					"Eisdorn",									"Glac\195\169pine",				"Espina de hielo" },
		{ 450, "inv_misc_herb_frostlotus",			"Frost Lotus",				"Frostlotus",								"Lotus givr\195\169",			"Loto de escarcha" },
		{ 360, "inv_misc_herb_11a",					"Firethorn",				"Feuerdorn",								"Epine de feu",					"Espino de fuego" },
-- Cataclysm
		{ 425, "inv_misc_herb_azsharasveil",		"Azshara's Veil",			"Azsharas Schleier",						"Voile d'Azshara",				"Velo de Azshara" },
		{ 425, "inv_misc_herb_cinderbloom",			"Cinderbloom",				"Aschenbl\195\188te",					"Cendrelle",						"Flor de ceniza" },
		{ 425, "inv_misc_herb_stormvine",			"Stormvine",				"Sturmwinde",								"Vign\195\169tincelle",			"Vi\195\177\aviento" },
		{ 475, "inv_misc_herb_heartblossom",		"Heartblossom",			"Herzbl\195\188te",						"P\195\169tale de c\195\166ur", "Flor de coraz\195\179n" },
		{ 500, "inv_misc_herb_whiptail",				"Whiptail",					"Gertenrohr",								"Fouettine",						"Col\195\161tigo" },
		{ 525, "inv_misc_herb_twilightjasmine",	"Twilight Jasmine",		"Schattenjasmin",							"Jasmin cr\195\169pusculaire","Jazm\195\173n Crepuscular" },
-- Pandaria
	    { 600, "inv_misc_herb_foolscap", "Fool's Cap","Narrenkappe","Berluette","Flor del inocente"},
		{ 550, "inv_misc_herb_goldenlotus","Golden Lotus","Goldlotus","Lotus doré","Loto dorado"},
		{ 500, "inv_misc_herb_jadetealeaf","Green Tea Leaf","Teepflanze","Feuille de thé vert","Hoja de té verde"},
		{ 525, "inv_misc_herb_rainpoppy","Rain Poppy","Regenmohn","Pavot de pluie","Amapola de lluvia"},
		{ 575, "inv_misc_herb_shaherb","Sha-Touched Herb","Sha-berührtes Kraut","Plante touchée par les sha","Hierba influenciada por el sha"},
		{ 545, "inv_misc_herb_silkweed","Silkweed","Seidenkraut","Herbe à soie","Hierba sedosa"},
		{ 575, "inv_misc_herb_snowlily","Snow Lily","Schneelilie","Lys des neiges","Lirio de las nieves"},		
	},
	["M"] = {	-- Mine node
		{ 325,	"INV_Ore_Adamantium",		"Adamantite Deposit",		"Adamantitvorkommen",			"Gisement d'adamantite",			"Dep\195\179sito de adamantita" },
		{ 375,	"INV_Misc_Gem_01",			"Ancient Gem Vein",			"Uralte Edelsteinader",			"Ancien filon de gemmes",			"Fil\195\179n de gemas antiguo" },
		{ 1,		"INV_Ore_Copper_01",			"Copper Vein",					"Kupferader",						"Filon de cuivre",					"Fil\195\179n de cobre" },
		{ 230,	"INV_Ore_Mithril_01",		"Dark Iron Deposit",			"Dunkeleisenvorkommen",			"Gisement de sombrefer",			"Dep\195\179sito de hierro negro" },
		{ 275,	"INV_Ore_FelIron",			"Fel Iron Deposit",			"Teufelseisenvorkommen",		"Gisement de gangrefer",			"Dep\195\179sito de hierro vil" },
		{ 155,	"INV_Ore_Copper_01",			"Gold Vein",					"Goldader",							"Filon d'or",							"Fil\195\179n de oro" },
		{ 65,		"INV_Ore_Thorium_01",		"Incendicite Mineral Vein","Pyrophormineralvorkommen",	"Filon d'incendicite",				"Fil\195\179n de incendicita" },
		{ 150,	"INV_Ore_Mithril_01",		"Indurium Mineral Vein",	"Induriummineralvorkommen",	"Filon d'indurium",					"Fil\195\179n de indurio" },
		{ 125,	"INV_Ore_Iron_01",			"Iron Deposit",				"Eisenvorkommen",					"Gisement de fer",					"Dep\195\179sito de hierro" },
		{ 375,	"INV_Ore_Khorium",			"Khorium Vein",				"Khoriumader",						"Filon de khorium",					"Fil\195\179n de korio" },
		{ 305,	"INV_Stone_15",				"Large Obsidian Chunk",		"Gro\195\159er Obsidianbrocken", "Grand morceau d'obsidienne", "Trozo de obsidiana grande" },
		{ 75,		"INV_Ore_Thorium_01",		"Lesser Bloodstone Deposit", "Geringes Blutsteinvorkommen", "Gisement de pierre de sang inf\195\169rieure", "Dep\195\179sito de sangrita inferior" },
		{ 175,	"INV_Ore_Mithril_02",		"Mithril Deposit",			"Mithrilvorkommen",				"Gisement de mithril",				"Dep\195\179sito de mitril" },
		{ 275,	"INV_Ore_Ethernium_01",		"Nethercite Deposit",		"Netheritvorkommen",				"Gisement de n\195\169anticite", "Dep\195\179sito de abisalita" },
		{ 350,	"INV_Ore_Adamantium",		"Rich Adamantite Deposit",	"Reiches Adamantitvorkommen",	"Riche gisement d'adamantite",	"Dep\195\179sito rico en adamantita" },
		{ 255,	"INV_Ore_Thorium_02",		"Rich Thorium Vein",			"Reiche Thoriumader",			"Riche filon de thorium",			"Fil\195\179n de torio enriquecido" },
		{ 75,		"INV_Stone_16",				"Silver Vein",					"Silberader",						"Filon d'argent",						"Fil\195\179n de plata" },
		{ 305,	"INV_Misc_StoneTablet_01",	"Small Obsidian Chunk",		"Kleiner Obsidianbrocken",		"Petit morceau d'obsidienne",		"Trozo de obsidiana peque\195\177o" },
		{ 230,	"INV_Ore_Thorium_02",		"Small Thorium Vein",		"Kleine Thoriumader",			"Petit filon de thorium",			"Fil\195\179n peque\195\177o de torio" },
		{ 65,		"INV_Ore_Tin_01",				"Tin Vein",						"Zinnader",							"Filon d'\195\169tain",				"Fil\195\179n de esta\195\177o" },
		{ 230,	"INV_Ore_TrueSilver_01",	"Truesilver Deposit",		"Echtsilbervorkommen",			"Gisement de vrai-argent",			"Dep\195\179sito de veraplata" },
		{ 350,	"inv_ore_cobalt",				"Cobalt Deposit",				"Kobaltvorkommen",				"Gisement de cobalt",				"Dep\195\179sito de cobalto" },
		{ 375,	"inv_ore_cobalt",				"Rich Cobalt Deposit",		"Reiches Kobaltvorkommen",		"Riche gisement de cobalt",		"Dep\195\179sito de cobalto rico" },
		{ 400,	"inv_ore_saronite_01",		"Saronite Deposit",			"Saronitvorkommen",				"Gisement de saronite",				"Dep\195\179sito de saronita" },
		{ 425,	"inv_ore_saronite_01",		"Rich Saronite Deposit",	"Reiches Saronitvorkommen",	"Riche gisement de saronite",		"Dep\195\179sito de saronita rico" },
		{ 450,	"inv_ore_platinum_01",		"Titanium Vein",				"Titanader",						"Veine de titane",					"Fil\195\179n de titanio" },

-- Cataclysm
		{ 425,	"item_elementiumore",		"Obsidium Deposit",			"Obsidiumvorkommen",				"Morceau d'obsidium",						"Dep\195\179sito de obsidium" },
		{ 450,	"item_elementiumore",		"Rich Obsidium Deposit",	"Reiches Obsidiumvorkommen",	"Enorme bloc d'obsidienne",				"Dep\195\179sito de obsidium rico" },
		{ 475,	"item_pyriumore",				"Elementium Vein",			"Elementiumader",					"Filon d\195\169l\195\169mentium",		"Fil\195\179n de elementium" },
		{ 500,	"item_pyriumore",				"Rich Elementium Vein",		"Reiche Elementiumader",		"Riche filon d'\195\169l\195\169mentium", "Fil\195\179n de elementium rico" },
		{ 525,	"inv_ore_arcanite_01",		"Pyrite Deposit",				"Pyritvorkommen",					"Gisement de pyrite",						"Dep\195\179sito de pirita" },
		{ 525,	"inv_ore_arcanite_01",		"Rich Pyrite Deposit",		"Reiches Pyritvorkommen",		"Riche gisement de pyrite",				"Dep\195\179sito de pirita rico" },
-- Pandaria
        { 515, "inv_ore_ghostiron","Ghost Iron Deposit","Geistereisenvorkommen","Gisement d’ectofer","Depósito de hierro fantasma"},
		{ 550, "inv_ore_ghostiron","Rich Ghost Iron Deposit","Reiches Geistereisenvorkommen","Riche gisement d’ectofer","Depósito de hierro fantasma rico"},
		{ 550, "inv_ore_manticyte","Kyparite Deposit","Kyparitvorkommen","Gisement de kyparite","Depósito de kyparita"},
		{ 575, "inv_ore_manticyte","Rich Kyparite Deposit","Reiches Kyparitvorkommen","Riche gisement de kyparite","Depósito de kyparita rico"},
		{ 600, "inv_ore_trilliumwhite","Trillium Vein","Trilliumader","Filon de trillium","Filón de trillium"},
		{ 600, "INV_Ore_TrilliumWhite","Rich Trillium Vein","Reiche Trilliumader","Riche filon de trillium","Filón de trillium enriquecido"},
	}	
}

Nx.GatherRemap = {
	["NXHerb"] = {
		[47] = 46,		-- Icethorn
	},
	["NXMine"] = {
		[6] = 9,		-- Gold
		[17] = 20,	-- Silver
		[23] = 22,	-- Rich Cobalt Deposit
		[25] = 24,	-- Rich Saronite Deposit
		[26] = 24,	-- Titanium
	}
}

--------
-- Init. Call after map init

function Nx:GatherInit()

	self.GatherLocaleI = 3

	if Nx.Locale == "deDE" then
		self.GatherLocaleI = 4

	elseif Nx.Locale == "frFR" then
		self.GatherLocaleI = 5

	elseif Nx.Locale == "esES" or Nx.Locale == "esMX" then
		self.GatherLocaleI = 6
	end

	if self.DoGatherUpgrade then
		self.DoGatherUpgrade = nil
		Nx:GatherVerUpgrade()
	end

	Nx.GatherVerUpgrade = nil			-- Kill it
	Nx.GatherVerUpgradeType = nil		-- Kill it
end

function Nx:GetGather (typ, id)

	local v = Nx.GatherInfo[typ][id]

	if v then
		return v[self.GatherLocaleI], v[2], v[1]
	end
end

function Nx:HerbNameToId (name)

	local i = self.GatherLocaleI

	for k, v in ipairs (Nx.GatherInfo["H"]) do
		if v[i] == name then
			return k
		end
	end

	if Nx.db.profile.Debug.DBGather then
		Nx.prt ("Unknown herb %s", name)
	end
end

function Nx:MineNameToId (name)

	if Nx.Locale == "deDE" then

		name = gsub (name, "Br\195\188hschlammbedecktes ", "")

		if name == "reiches Thoriumvorkommen" then	-- Created when Ooze Covered removed
			name = "Reiches Thoriumvorkommen"
		end

		if name == "Thoriumvorkommen" then				-- Created when Ooze Covered removed
			name = "Kleines Thoriumvorkommen"
		end

	elseif Nx.Locale == "frFR" then

		name = gsub (name, " couvert de limon", "")		-- Ooze Covered
		name = gsub (name, " couvert de vase", "")		-- Ooze Covered

		if name == "Filon de thorium" then					-- Created when Ooze Covered removed
			name = "Petit filon de thorium"
		end

	elseif Nx.Locale == "esES" or Nx.Locale == "esMX" then

		name = gsub (name, " cubierto de moco", "")		-- Ooze Covered
		name = gsub (name, " cubierta de moco", "")		-- Ooze Covered

		if name == "Fil\195\179n de torio" then			-- Created when Ooze Covered removed
			name = "Fil\195\179n peque\195\177o de torio"
		end

	else
--		name = gsub (name, "Hakkari", "Rich")		-- Hakkari Thorium Vein
		name = gsub (name, "Ooze Covered ", "")
		if name == "Thorium Vein" then				-- Created when Ooze Covered removed
			name = "Small Thorium Vein"
		end
	end

	local i = self.GatherLocaleI

	for k, v in ipairs (Nx.GatherInfo["M"]) do
		if v[i] == name then
			return k
		end
	end

	if Nx.db.profile.Debug.DBGather then
		Nx.prt ("Unknown ore %s", name)
	end
end

--------
-- Upgrade gather data

function Nx:GatherVerUpgrade()

	Nx:GatherVerUpgradeType ("NXHerb")
	Nx:GatherVerUpgradeType ("NXMine")
end

function Nx:GatherVerUpgradeType (tName)

--[[
	local oldType = NxData.NXGather[tName]
	local newType = {}
	NxData.NXGather[tName] = newType

	for mapId, oldZone in pairs (oldType) do

		local zoneT = {}
		newType[mapId] = zoneT

		for _, node in ipairs (oldZone) do

			local x, y = Nx.Map:GetZonePos (mapId, node.NXX, node.NXY)		-- Needs map init
			if (x > 0 or y > 0) and x <= 100 and y <= 100 then

				local nodeT = zoneT[node.NXId] or {}
				zoneT[node.NXId] = nodeT

				local s = format ("%s^%d", Nx:PackXY (x, y), node.NXCnt)
				tinsert (nodeT, s)

--				Nx.prt ("%s %s %s", mapId, x, y)
--				Nx.prt (" %s", s)
--				Nx.prt (" %s %s", tonumber (strsub (s, 1, 3), 16) / 40.9, tonumber (strsub (s, 4, 6), 16) / 40.9)
			end
		end
	end
--]]
end

--------
-- Save location of gathered herb
-- xy is zone coords

function Nx:GatherHerb (id, mapId, x, y)
	self:Gather ("NXHerb", id, mapId, x, y)
end

--------
-- Save location of gathered mining
-- xy is zone coords

function Nx:GatherMine (id, mapId, x, y)
	self:Gather ("NXMine", id, mapId, x, y)
end

--------
-- Add gathered item. xy zone coords 0-100

function Nx:Gather (nodeType, id, mapId, x, y)

	local remap = self.GatherRemap[nodeType]
	if remap then
		id = remap[id] or id
	end

	local data = Nx.db.profile.GatherData[nodeType]

	local zoneT = data[mapId]
	if not zoneT then

--		Nx.prt ("Gather new %d", mapId)

		zoneT = {}
		data[mapId] = zoneT
	end

	local maxDist = (5 / Nx.Map:GetWorldZoneScale (mapId)) ^ 2

	local index
	local nodeT = zoneT[id] or {}
	zoneT[id] = nodeT

	for n, node in ipairs (nodeT) do

		local nx = tonumber (strsub (node, 1, 3), 16) / 40.9
		local ny = tonumber (strsub (node, 4, 6), 16) / 40.9
		local dist = (nx - x) ^ 2 + (ny - y) ^ 2

--		Nx.prt ("Gather %f %f %f (%.2f %.2f) (%.2f %.2f)", dist, maxDist, id, nx, ny, x, y)

		if dist < maxDist then		-- Squared compare
			index = n
			break
		end
	end

	local cnt = 1

	if not index then
		index = #nodeT + 1

	else
		local xy, nCnt = Nx.Split ("^", nodeT[index])
		local nx = tonumber (strsub (xy, 1, 3), 16) / 40.9
		local ny = tonumber (strsub (xy, 4, 6), 16) / 40.9
		cnt = nCnt + 1
		x = (nx * nCnt + x) / cnt
		y = (ny * nCnt + y) / cnt
	end

	nodeT[index] = format ("%s^%d", Nx:PackXY (x, y), cnt)
end

--------

function Nx:GatherUnpack (item)

	local xy = Nx.Split ("^", item)
	local x = tonumber (strsub (xy, 1, 3), 16) / 40.9
	local y = tonumber (strsub (xy, 4, 6), 16) / 40.9
	return x, y
end

--------

function Nx:GatherDeleteHerb()
	Nx.db.profile.GatherData.NXHerb = {}
end

function Nx:GatherDeleteMine()
	Nx.db.profile.GatherData.NXMine = {}
end

function Nx:GatherDeleteMisc()
	Nx.db.profile.GatherData["Misc"] = {}
end

--------

function Nx:GatherImportCarbHerb()
	Nx:GatherImportCarb ("NXHerb")
end

function Nx:GatherImportCarbMine()
	Nx:GatherImportCarb ("NXMine")
end

function Nx:GatherImportCarbMisc()
	Nx:GatherImportCarb ("Misc")
end

function Nx:GatherImportCarb (nodeType)

	if not CarboniteNodes then
		Nx.prt ("CarboniteNodes addon is not loaded!")
		return
	end

	local srcT = CarboniteNodes[nodeType]
	if srcT then

		local cnt = 0

		for mapId, zoneT in pairs (srcT) do
			for nodeId, nodeStr in pairs (zoneT) do
				for n = 1, #nodeStr, 6 do

					cnt = cnt + 1

					local nx = tonumber (strsub (nodeStr, n, n + 2), 16) / 40.9
					local ny = tonumber (strsub (nodeStr, n + 3, n + 5), 16) / 40.9

					if nx < .1 or nx > 99.9 or ny < .1 or ny > 99.9 then
--						Nx.prt ("bad node %s %s %s", mapId, nx, ny)
					else
						Nx:Gather (nodeType, nodeId, mapId, nx, ny)
					end

				end
			end
		end

		Nx.prt ("Imported %s %s", nodeType, cnt)
	end
end

--------
-- OLD cart import

--[[

function Nx:GatherImportCartHerb()
	Nx:GatherImportCart ("Herbalism")
end

function Nx:GatherImportCartMine()
	Nx:GatherImportCart ("Mining")
end

function Nx:GatherImportCart (typ)

	local notes = Cartographer_Notes
	local data = _G["Cartographer_" .. typ .. "DB"]

	if not data then
		Nx.prt ("Cartographer_%sDB missing", typ)
		return
	end

	if not notes then
		Nx.prt ("Cartographer notes missing")
		return
	end

	local getXY = notes["getXY"]
	if not getXY then
		Nx.prt ("Cartographer getXY missing")
		return
	end

	local nameToId = Nx.HerbNameToId
	local gather = Nx.GatherHerb
	if typ == "Mining" then
		nameToId = Nx.MineNameToId
		gather = Nx.GatherMine
	end

	local importCnt = 0

	for zName, zData in pairs (data) do

		if type (zData) == "table" then

			local mapId = Nx.MapNameToId[zName]
			if not mapId then
				Nx.prt ("Unknown zone %s", zName)

			else

				for id, name in pairs (zData) do

					local nodeId = nameToId (Nx, name)
					if nodeId then
						importCnt = importCnt + 1
						local x, y = getXY (id)
						gather (Nx, nodeId, mapId, x * 100, y * 100)

					else
						Nx.prt ("Import unknown %s", name)
					end
				end
			end
		end
	end

	Nx.prt ("Imported %s nodes", importCnt)
end

--]]

-------------------------------------------------------------------------------
-- Item handling

function Nx.Item:Init()

	self.Needed = {}
	self.Asked = {}
end

function Nx.Item:Load (id)

	if self.Asked[id] then	-- Ask once

--		Nx.prt ("Asked %s", id)

		if time() - self.Asked[id] > 600 then

			local name = GetItemInfo (id)
			if not name then
--				Nx.prt ("Item still missing %s", id)
				return -1	-- Never got item. Probably bad id
			end
		end

		return
	end

	local name, link = GetItemInfo (id)
	if not name then
--		self.Needed[id] = true
	end
end

function Nx.Item.EnableLoadFromServer()

--	Nx.prt ("EnableLoadFromServer")

	local self = Nx.Item

	self.TooltipFrm = CreateFrame ("GameTooltip", "NxTooltipItem", UIParent, "GameTooltipTemplate")
	self.TooltipFrm:SetOwner (UIParent, "ANCHOR_NONE")		-- We won't see with this anchor

	self.ItemsRequested = 0

	Item = Nx:ScheduleTimer (self.Timer, 1)
end

function Nx.Item.DisableLoadFromServer()

--	Nx.prt ("DisableLoadFromServer")

	local self = Nx.Item
	self.Needed = {}
	self.Load = function() end		-- Nuke function

	AskDeleteVV = Nx:ScheduleTimer (self.AskDeleteVV, 0)
end

function Nx.Item.AskDeleteVV()

	local function func()
			Nx.db.profile.VendorV = nil
			Nx.Map.Guide:UpdateVisitedVendors()
	end

	Nx:ShowMessage (Nx.TXTBLUE.."Carbonite:\n|cffffff60Delete visited vendor data?\nThis will stop the attempted retrieval of items on login.", "Delete", func, "Cancel")
end

function Nx.Item:ShowTooltip (id, compare)

--	Nx.prtVar ("ShowTooltip", id)

	local id = tostring (id)

	id = Nx.Split ("^", id)

	if not strfind (id, "item:") then
		if strfind (id, "quest:") then
		else
			id = "item:" .. id .. ":0:0:0:0:0:0:0"		-- Without the 7 ":0" Pawn prints an error
		end
	end

	GameTooltip:SetHyperlink (id)

	if compare then
		GameTooltip_ShowCompareItem()
	end
end

function Nx.Item:Timer()

	local id = next (self.Needed)

	if id then

		local tip = self.TooltipFrm

		self.Needed[id] = nil

		local name = GetItemInfo (id)
		if name then
			return .01		-- Already have
		end

--		Nx.prt ("Getting item %s", id)

		self.Asked[id] = time()

		if not strfind (id, "item:") then
			id = "item:" .. id
		end

		tip:SetHyperlink (id)

		self.ItemsRequested = self.ItemsRequested + 1

		if next (self.Needed) then		-- More?

			if Nx:TimeLeft(ItemDraw) == 0 then
				ItemDraw = Nx:ScheduleTimer ("DrawTimer",10)
			end
			return .1
		end

		ItemDraw = Nx:ScheduleTimer ("DrawTimer",3)
	end

	return 2
end

function Nx.Item:DrawTimer()

	if next (self.Needed) then		-- More?
		Nx.prt (" %d items retrieved", self.ItemsRequested)

	else
		Nx.prt ("Item retrieval from server complete")
	end

	local g = Nx.Map:GetMap (1).Guide
	g:UpdateVisitedVendors()
	g:Update()
end

-------------------------------------------------------------------------------
-- Minimap button functions

function Nx.NXMiniMapBut:Init()
	local f = NXMiniMapBut

	if not Nx.db.profile.MiniMap.ButOwn then
		f:RegisterForDrag ("LeftButton")
	end

	-- Create menu

	local menu = Nx.Menu:Create (f)
	self.Menu = menu

	menu:AddItem (0, "Help", self.Menu_OnShowHelp, self)
	menu:AddItem (0, "Options", self.Menu_OnOptions, self)

	menu:AddItem (0, "Show Map", self.Menu_OnShowMap, self)

--PAIDS!
	if not Nx.Free then

		menu:AddItem (0, "Show Combat Graph", self.Menu_OnShowCombat, self)
		menu:AddItem (0, "Show Events", self.Menu_OnShowEvents, self)
		menu:AddItem (0, "", nil, self)

	end
--PAIDE!

	local item = menu:AddItem (0, "Show Auction Buyout Per Item", self.Menu_OnShowAuction, self)
	item:SetChecked (false)

	if Nx.db.profile.Debug.DebugCom then
		menu:AddItem (0, "", nil, self)
		menu:AddItem (0, "Show Com Window", self.Menu_OnShowCom, self)
	end
	if Nx.db.profile.Debug.DebugMap then
		menu:AddItem (0, "", nil, self)
		menu:AddItem (0, "Toggle Profiling", self.Menu_OnProfiling, self)
	end

	-- Fix position if bad (does not work)

	NXMiniMapBut:SetClampedToScreen (true)

--	self:Move()

	-- Ask to disable profiling

	local ok, var = pcall (GetCVar, "scriptProfile")
	if ok and var ~= "0" then
		Nx:ShowMessage ("Profiling is on. This decreases game performance. Disable?", "Disable and Reload", self.ToggleProfiling, "Cancel")
	end
end

function Nx.NXMiniMapBut:Menu_OnShowHelp()
	Nx.Help:Open()
end

function Nx.NXMiniMapBut:Menu_OnOptions()
	Nx.Opts:Open()
end

function Nx.NXMiniMapBut:Menu_OnStartDemo()
	Nx.Help.Demo:Start()
end

function Nx.NXMiniMapBut:Menu_OnShowMap()
	Nx.Map:ToggleSize()
end

function Nx.NXMiniMapBut:Menu_OnShowCombat()
	Nx.Combat:Open()
end

function Nx.NXMiniMapBut:Menu_OnShowEvents()
	Nx.UEvents.List:Open()
end

function Nx.NXMiniMapBut:Menu_OnHideWatch (item)
	local hide = item:GetChecked()
	Nx.Quest.Watch.Win:Show (not hide)
end

function Nx.NXMiniMapBut:Menu_OnShowAuction (item)
	Nx.AuctionShowBOPer = item:GetChecked()

	if AuctionFrame and AuctionFrame:IsShown() then
		AuctionFrameBrowse_Update()
	end
end

function Nx.NXMiniMapBut:Menu_OnShowCom()
	Nx.Com.List:Open()
end

function Nx.NXMiniMapBut:Menu_OnProfiling()
	Nx:ShowMessage ("Toggle profiling? Reloads UI", "Reload", self.ToggleProfiling, "Cancel")
end

function Nx.NXMiniMapBut:ToggleProfiling()

	RegisterCVar ("scriptProfile")

	local var = GetCVar ("scriptProfile")
--	Nx.prtVar ("v:", var)
	var = var == "0" and "1" or "0"
	SetCVar ("scriptProfile", var)

--	Nx.prt (format ("Profiling %s", var))
	ReloadUI()
end

function Nx.NXMiniMapBut:NXOnEnter (frm)
	
	local mmown = Nx.db.profile.MiniMap.ButOwn
	local tip = GameTooltip

	--V4 this
	tip:SetOwner (frm, "ANCHOR_LEFT")
	tip:SetText (NXTITLEFULL .. " " .. Nx.VERMAJOR .. "." .. Nx.VERMINOR*10)	
	tip:AddLine ("Left click toggle Map", 1, 1, 1, 1)

	if mmown then
		tip:AddLine ("Shift left click toggle minimize", 1, 1, 1, 1)
	end

	tip:AddLine ("Alt left click toggle Watch List", 1, 1, 1, 1)
	tip:AddLine ("Middle click toggle Guide", 1, 1, 1, 1)
	tip:AddLine ("Right click for Menu", 1, 1, 1, 1)

	if not mmown then
		tip:AddLine ("Shift drag to move", 1, 1, 1, 1)
	end
	tip:AppendText ("")
end

function Nx.NXMiniMapBut:NXOnClick (button, down)

--	Nx.prt (button)

	if button == "LeftButton" then

		if IsShiftKeyDown() then			
			Nx.db.profile.MiniMap.ButWinMinimize = not Nx.db.profile.MiniMap.ButWinMinimize
			Nx.Map.Dock:UpdateOptions()

		elseif IsAltKeyDown() then
			local w = Nx.Quest.Watch.Win
			w:Show (not w:IsShown())

		else
			Nx.Map:ToggleSize (0)
		end

	elseif button == "MiddleButton" then

		Nx.Map:GetMap (1).Guide:ToggleShow()

	else
		self:OpenMenu()
	end
end

function Nx.NXMiniMapBut:OpenMenu()
	if self.Menu then			-- Someone had error with this nil
		self.Menu:Open()
	end
end

--------
-- Move the minimap button around the minimap

function Nx.NXMiniMapBut:NXOnUpdate (frm)

--	Nx.prtVar ("NXOnUpdate", frm)

	--V4 this
	if frm.NXDrag then

--		Nx.prt ("Drag")

		local mm = _G["Minimap"]

		local x, y = GetCursorPosition()
		local s = mm:GetEffectiveScale()
		self:Move (x / s, y / s)
	end
end

function Nx.NXMiniMapBut:Move (x, y)

	local but = NXMiniMapBut		-- 32x32

	local mm = _G["Minimap"]

	local l = mm:GetLeft() + 70				-- Minimap is 140x140
	local b = mm:GetBottom() + 70
--[[
	if not x then
		x = but:GetLeft()
		y = but:GetTop()
		Nx.prt ("xy %s %s", x, y)
	end
--]]
	x = x - l
	y = y - b

	local ang = atan2 (y, x)
	local r = (x ^ 2 + y ^ 2) ^ .5
	r = max (r, 79)
	r = min (r, 110)

	x = r * cos (ang)
	y = r * sin (ang)	
	but:SetPoint ("TOPLEFT", mm, "TOPLEFT", x + 54, y - 54)
	but:SetUserPlaced (true)
end

function Nx.ModChatReceive(msg,dist,target)
end

local TempTable = {}
setmetatable(TempTable, {__mode = "v"})

function Nx.Split(d, p)
  if p and not string.find(p,d) then		
	return p
  end    
  if p and #p <= 1 then return p end
  if TempTable[p] then 
	return unpack(TempTable[p],1,table.maxn(TempTable[p]))
  else
	local TempNum = 0
	local Tossaway = {}	
    while true do
      l=string.find(p,d,TempNum,true) 
      if l~=nil then 
        table.insert(Tossaway, string.sub(p,TempNum,l-1)) 
        TempNum=l+1 
      else
        table.insert(Tossaway, string.sub(p,TempNum)) 
        break 
      end
    end	
   TempTable[p] = Tossaway
   return unpack(Tossaway)
   end
end

-------------------------------------------------------------------------------
--EOF










