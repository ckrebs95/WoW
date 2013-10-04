local addonName, vars = ...
local L = vars.L
ProfessionsVault = LibStub("AceAddon-3.0"):NewAddon(addonName)
local addon = ProfessionsVault 
addon.vars = vars
local addon_website = "http://www.wowace.com/addons/professionsvault/"
local AceGUI = LibStub("AceGUI-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local PVLDB
local minimapIcon = LibStub("LibDBIcon-1.0")
vars.svnrev = vars.svnrev or {}
local svnrev = vars.svnrev
svnrev["ProfessionsVault.lua"] = tonumber(("$Revision: 523 $"):match("%d+"))
local DB_VERSION_MAJOR = 1
local DB_VERSION_MINOR = 4
local _G = _G
local bit, date, math, format, string, table, type, tonumber, pairs, ipairs, unpack, strtrim, strsplit, time, wipe, select, getglobal, mod, ceil = 
      bit, date, math, format, string, table, type, tonumber, pairs, ipairs, unpack, strtrim, strsplit, time, wipe, select, getglobal, mod, ceil
local GetItemInfo, GetSpellInfo, GetTime, UnitIsInMyGuild, InCombatLockdown, GetActionInfo = 
      GetItemInfo, GetSpellInfo, GetTime, UnitIsInMyGuild, InCombatLockdown, GetActionInfo

vars.stub = false
local function ShowStub() 
  if addon.stubshown then return end
  addon.stubshown = true
  local msg = "Blizzard Patch 5.4 has seriously broken the operation of TradeSkill hyperlinks, breaking addons such as ProfessionsVault. Please help complain on the Blizzard Bug Report Forums:"
  local url = "http://us.battle.net/wow/en/forum/1012660/"

  DEFAULT_CHAT_FRAME:AddMessage("\124cFF00FF00"..addonName.."\124r: "..msg.."\n  "..url)

  StaticPopupDialogs["PROFESSIONSVAULT_STUB"] = {
    preferredIndex = 3, -- reduce the chance of UI taint
    text = msg.."\n(Press Control+C to copy URL)",
    button1 = OKAY,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    enterClicksFirstButton = true,
    --showAlert = true,
    hasEditBox = true,
    editBoxWidth = 350,
    OnShow = function (self, data)
      self.editBox:SetText(url)
      self.editBox:HighlightText()
      self.editBox:SetScript("OnEnterPressed",function() StaticPopup_Hide("PROFESSIONSVAULT_STUB") end)
      self.editBox:SetScript("OnEscapePressed",function() StaticPopup_Hide("PROFESSIONSVAULT_STUB") end)
    end,
    OnHide = function (self, data)
      self.editBox:SetScript("OnEnterPressed", nil)
      self.editBox:SetScript("OnEscapePressed", nil)
    end,
    EditBoxOnTextChanged = function (self, data)
      self:SetText(url)
      self:HighlightText()
    end,
  }
  StaticPopup_Show("PROFESSIONSVAULT_STUB")
  return
end
local function StubCheck()
  if not addon.trade_skill_show then -- link activation failure
    ShowStub()
  end
end
if vars.stub then
  ShowStub()
  return
end

local defaults = {
  profile = {
    debug = false, -- for addon debugging
    autoclose = false, -- close win after using a link
    tooltips = true, -- show tooltips in the ProfessionsVault window
    autoscan = true, -- scan on pattern learn
    locked = false, -- frame lock
    updatemsg = true,
    recipetooltips = true,
    ahcolor = true,
    ahscan = true,
    merchantcolor = true,
    bagcolor = true,
    bankcolor = true,
    mailcolor = true,
    colorttnames = false,
    colorwinnames = true,
    selfdata = true,
    altdata = true,
    otherdata = false,
    factiondata = false,
    realmdata = false,
    grpbyprof = false,
    trainreminder = true,
    ldbself = true,
    ldbeinstein = true,
    ldbfavorite = true,
    pos = {
      height = 432,
      width  = 600,
      left   = GetScreenWidth()/2-250,
      top    = GetScreenHeight()/2+200,
    },
    treestatus = {
      treewidth = 230,
    },
    minimap = {
      hide = false,
    },
    charcolor = {
      self =   { 0x0, 0xff, 0x0  },
      alt =    { 0x0, 0xff, 0x33 },
      other =  { 0x0, 0xcc, 0xcc },
      falt =   { 0xff, 0x0, 0x0 },
      fother = { 0xff, 0x33, 0x33 },
      system = { 0xff, 0xff, 0x0 },
    },
    recipecolor = {
      learn_self  = { 1.0, 1.0, 1.0 },
      learn_alt   = { 0.3, 1.0, 0.3 },
      learn_other = { 0.3, 1.0, 0.3 },
      learn_falt  = { 0.3, 1.0, 0.3 },
      learn_fother= { 0.3, 1.0, 0.3 },
      skill_self  = { 1.0, 1.0, 0.1 },
      skill_alt   = { 1.0, 1.0, 0.1 },
      skill_other = { 1.0, 1.0, 0.1 },
      skill_falt  = { 1.0, 1.0, 0.1 },
      skill_fother= { 1.0, 1.0, 0.1 },
      known_self  = { 0.3, 0.3, 1.0 },
      known_alt   = { 0.3, 0.3, 1.0 },
      known_other = { 0.3, 0.3, 1.0 },
      known_falt  = { 0.3, 0.3, 1.0 },
      known_fother= { 0.3, 0.3, 1.0 },
      unknown     = { 1.0, 0.1, 0.1 },
      dunno       = { 1.0, 0.1, 0.1 },
    },
  }
}

local GetTradeSkillListLink = GetTradeSkillListLink

local headerfont = GameFontHighlightLarge
local bodyfont = GameFontHighlightLarge
local activateontree = true
local useMerchantTimer = true
local enhanceColorPicker = true
local ttwrapwidth = 50 -- tooltip wrap width, 0 for auto
local gamerankmax = 600
local maxcachesz = 200
local useeinstein = false
local useguildhack = true
local link3build = 17191
local einstein = L["All Recipes"]
local allexpand = "All Expand"
local allexpandplus = "Interface\\Buttons\\UI-PlusButton-UP"
local allexpandminus = "Interface\\Buttons\\UI-MinusButton-UP"
local locale = GetLocale()
if locale == "enGB" then locale = "enUS" end
local rcolortable
local DB, DBc, settings
local charName
local optionsFrame, colorFrame, unhideFrame
local allianceRace = { -- Pandaren handed specially
         ["Human"]=true, ["Dwarf"]=true, ["Gnome"]=true, ["NightElf"]=true, ["Draenei"]=true, ["Worgen"]=true
      }


BINDING_NAME_PROFESSIONSVAULT = L["Show/Hide the ProfessionsVault window"]
BINDING_HEADER_PROFESSIONSVAULT = "ProfessionsVault"

local PID_ALCH = 2259
local PID_BS   = 2018
local PID_ENCH = 7411
local PID_ENG  = 4036
local PID_HERB = 2366
local PID_SKIN = 8613
local PID_INSC = 45357
local PID_JC   = 25229
local PID_LW   = 2108
local PID_MINE = 2575
local PID_SMELT= 2656
local PID_TAIL = 3908
local PID_ARCH = 78670
local PID_COOK = 2550
local PID_FA   = 3273
local PID_FISH = 131474

-- ticket 88 / 110: the trade spell is "Herb Gathering" but GetProfessionInfo is "Herbalism"
local NAME_HERB
if locale == "deDE" then
  NAME_HERB = "Kr\195\164uterkunde"
elseif locale == "ruRU" then
  NAME_HERB = "\208\162\209\128\208\176\208\178\208\189\208\184\209\135\208\181\209\129\209\130\208\178\208\190"
elseif locale == "zhTW" then
  NAME_HERB = "\232\141\137\232\151\165\229\173\184"
elseif locale == "koKR" then
  NAME_HERB = GetSpellInfo(9134):match("^([^%s]+)")
elseif locale == "zhCN" then
  NAME_HERB = GetSpellInfo(13839):match("^([^%s]+)")
else -- use a different spellid to extract the correct spelling for most locales
  NAME_HERB = GetSpellInfo(9134):match("%s*([^%s]+)$"):gsub("^(%l)",string.upper)
end
--[[
print(locale,NAME_HERB)
for _,i in pairs({ GetProfessions() }) do print(GetProfessionInfo(i)); if NAME_HERB == GetProfessionInfo(i) then print("MATCH") end end 
for _,id in pairs({124353, 13614, 13839, 9134, 88717}) do print(id,(GetSpellInfo(id))) end
]]

local primaryProf = {  -- 0 == no tradeskill, 1 == broken
        [PID_ALCH] = { -- Alchemy
	            28677, -- Elixer Master 
		    28675, -- Potion Master
		    28672, -- Transmutation Master
		 },
	[PID_BS] = { -- Blacksmithing
	            9787, -- Weaponsmith
		    9788, -- Armorsmith
	         },
	[PID_ENCH] = true, -- Enchanting
	[PID_ENG] = { -- Engineering
	            20219, -- Gnomish Engineer
		    20222, -- Goblin Engineer
	         },
	[PID_INSC] = true, -- Inscription 
	[PID_JC] = true, -- Jewelcrafting 
	[PID_LW] = { -- Leatherworking
                    10656, -- Dragonscale Leatherworking
                    10660, -- Tribal Leatherworking
                    10658, -- Elemental Leatherworking
	         },
	[PID_TAIL] = { -- Tailoring
	            26797, -- Spellfire Tailoring
		    26798, -- Mooncloth Tailoring
		    26801, -- Shadoweave Tailoring
		 },
	[PID_SKIN] =  true, -- Skinning
	[PID_HERB] =  { PID_HERB, NAME_HERB }, -- Herbalism
	[PID_MINE] =  true, -- Mining
	[PID_SMELT] = true, -- Smelting
}
local secondaryProf = { 
	[PID_ARCH] = true, -- Archaeology
	[PID_COOK] = { -- Cooking
	  125584, -- Way of the Wok
	  125586, -- Way of the Pot
	  125589, -- Way of the Brew
	  124694, -- Way of the Grill
	  125588, -- Way of the Oven
	  125587, -- Way of the Steamer
	},
	[PID_FA] =   true, -- First Aid 
	[PID_FISH] = true, -- Fishing
}

local magicIDs = {
	[PID_ALCH] = 171,
	[PID_ARCH] = 794,
	[PID_BS]   = 164,
	[PID_COOK] = 185,
	[PID_ENCH] = 333,
	[PID_ENG]  = 202,
	[PID_FA]   = 129,
	[PID_FISH] = 356,
	[PID_HERB] = 182,
	[PID_INSC] = 773,
	[PID_JC]   = 755,
	[PID_LW]   = 165,
	[PID_MINE] = 186,
	[PID_SMELT] = 186,
	[PID_SKIN] = 393,
	[PID_TAIL] = 197,
}

local nolinkProf = {  -- professions that dont have a trade: link
	[GetSpellInfo(PID_MINE)] = true,  
	[GetSpellInfo(PID_SMELT)] = true,
	[GetSpellInfo(PID_FISH)] = true, 
	[GetSpellInfo(PID_ARCH)] = true, 
	[GetSpellInfo(PID_HERB)] = true, 
	[NAME_HERB]              = true, 
	[GetSpellInfo(PID_SKIN)] = true, 
	[GetSpellInfo(53428)] = true, -- Runeforging
}
local nocastProf = { -- professions that can't be safely cast
	[GetSpellInfo(PID_MINE)] = true,  
	[GetSpellInfo(PID_FISH)] = true, 
	[GetSpellInfo(PID_HERB)] = true, 
	[NAME_HERB]              = true, 
	[GetSpellInfo(PID_SKIN)] = true, 
}
local function translateIDs(t) 
  local r = {}
  for k,v in pairs(t) do
    local name, _, icon = GetSpellInfo(k)
    if not name then
      print("Failed to find spellID "..k)
    else
      if k == PID_HERB then name = NAME_HERB end
      r[name] = {}
      r[name].icon = icon
      r[name].spellid = k
      r[name].magic = magicIDs[k]
      if nolinkProf[name] then
        r[name].nolink = true
      end
      if nocastProf[name] then
        r[name].nocast = true
      end
      local aliases = {}
      if type(v) == "table" then
	for _,a in ipairs(v) do
	  local an = (tonumber(a) and GetSpellInfo(a)) or a
	  table.insert(aliases, an)
	end
      end
      r[name].aliases = aliases
    end
  end
  return r
end
primaryProf = translateIDs(primaryProf)
secondaryProf = translateIDs(secondaryProf)
local allProf = {}
local allProfSorted = {}
do 
  for p,v in pairs(primaryProf) do allProf[p]=v ; table.insert(allProfSorted, p) end
  table.sort(allProfSorted)
  local tmp = {}
  for p,v in pairs(secondaryProf) do allProf[p]=v ; table.insert(tmp, p)end
  table.sort(tmp)
  for _,v in ipairs(tmp) do table.insert(allProfSorted, v) end
  --myprint(allProfSorted)
end

local profranks = { -- min and max for each skill level
  { learn=0,   max=75,  exp=0  },
  { learn=50,  max=150, exp=0 },
  { learn=125, max=225, exp=0 },
  { learn=200, max=300, exp=0 },  
  { learn=275, max=375, exp=1 },  
  { learn=350, max=450, exp=2 },  
  { learn=425, max=525, exp=3 },  
  { learn=500, max=600, exp=4 },  
}

-- minimum player level for training each skill level
local proflvl_craft  = { 5,  10, 20, 35, 50, 65, 75, 80, }
local proflvl_gather = { 1,  1,  10, 25, 40, 55, 75, 80, }
local proflvls = {
  [PID_COOK] = { 1,  1,  1,  1,  1,  1,  1,  80, },
  [PID_FA]   = { 1,  1,  1,  35, 50, 65, 75, 80, },
  [PID_FISH] = { 1,  1,  1,  1,  1,  1,  1,  1,  },
  [PID_ARCH] = { 20, 20, 20, 35, 50, 65, 75, 80, },
  [PID_BS]   = proflvl_craft,
  [PID_ALCH] = proflvl_craft,  
  [PID_TAIL] = proflvl_craft,  
  [PID_INSC] = proflvl_craft,  
  [PID_JC]   = proflvl_craft,
  [PID_ENG]  = proflvl_craft,
  [PID_LW]   = proflvl_craft,
  [PID_MINE] = proflvl_gather,
  [PID_SKIN] = proflvl_gather,
  [PID_HERB] = proflvl_gather,
}
  
-- returns true when a player with given ranks and level should visit a trainer
function addon:canLearn(pid, rank, rankmax, level)
  local lvlmap = proflvls[pid]
  if not lvlmap then return false end
  rankmax = math.floor(rankmax/25)*25 -- round away racial bonuses
  local learnskill 
  for skill, info in ipairs(profranks) do
    if rank >= info.learn and rankmax < info.max and
       GetExpansionLevel() >= info.exp then
      learnskill = skill
      break
    end
  end
  if not learnskill then return false end
  return level >= lvlmap[learnskill]
end  

function addon:checkLearn()
  addon.learnmsg = addon.learnmsg or {}
  local level = UnitLevel("player")
  for pname, pinfo in pairs(DBc) do
    local pid = allProf[pname] and allProf[pname].spellid
    if pid and addon:canLearn(pid, pinfo.rank, pinfo.rankmax, level) and 
       not addon.learnmsg[pname..pinfo.rankmax] and
       settings.trainreminder then
       addon.learnmsg[pname..pinfo.rankmax] = true
       addon.chatMsg(pname.." "..pinfo.rank..": "..string.format(L["Visit a %s trainer!"],pname))
    end
  end
end

local LFaction = {
  Alliance = FACTION_ALLIANCE,
  Horde = FACTION_HORDE
}
local recipeMatchClass = "^"..ITEM_CLASSES_ALLOWED:gsub("%%s","(.+)")
local recipeMatchRace = "^"..ITEM_RACES_ALLOWED:gsub("%%s","(.+)")

local function chatMsg(msg)
     DEFAULT_CHAT_FRAME:AddMessage("\124cFF00FF00"..addonName.."\124r: "..msg)
end
addon.chatMsg = chatMsg
local function debug(msg)
  if settings and settings.debug then
     DEFAULT_CHAT_FRAME:AddMessage("\124cFFFF0000"..addonName.."\124r: "..msg)
  end
end
addon.debug = debug
function addon:usingColor() 
  return settings.recipetooltips or
         settings.ahcolor or settings.merchantcolor or settings.bagcolor or
         settings.bankcolor or settings.mailcolor
end

local function table_clone(t)
  if not t then return nil end
  local r = {}
  for k,v in pairs(t) do
    local nk,nv = k,v
    if type(k) == "table" then
      nk = table_clone(k)
    end
    if type(v) == "table" then
      nv = table_clone(v)
    end
    r[nk] = nv
  end
  return r
end

local function table_size(t)
  if not t then return 0 end
  local c = 0
  for _ in pairs(t) do c = c + 1 end
  return c
end

local function myOptions() 
local PV_unhide
return {
  type = "group",
  args = {
   general = {
    type = "group",
    inline = true,
    name = L["General"],
    set = function(info,val)
            local s = settings ; for i = 2,#info-1 do s = s[info[i]] end
            s[info[#info]] = val; debug(info[#info].." set to: "..tostring(val))
            addon:RefreshTooltips()
          end,
    get = function(info)
            local s = settings ; for i = 2,#info-1 do s = s[info[i]] end
            return s[info[#info]] 
          end,
    args = {
    debug = {
      name = L["Debug"],
      desc = L["Toggle debugging output"],
      type = "toggle",
      guiHidden = true,
    },
    reset = {
      name = L["Reset"],
      desc = L["Reset the database"],
      type = "execute",
      order = 120,
      func = function() addon:Reset(); end,
    },
    dump = {
      name = L["Dump"],
      desc = L["Dump the database to chat window"],
      type = "execute",
      guiHidden = true,
      func = function() addon:Dump()  end,
    },
    save = {
      name = L["Save"],
      desc = L["Save this trade skill to ProfessionsVault"],
      type = "execute",
      guiHidden = true,
      func = function() addon:UpdateTrade(true) end,
    },
    scan = {
      name = L["Scan My Professions"],
      desc = L["Scan My Professions"],
      type = "execute",
      guiHidden = true,
      func = function() addon:ScanProfessions()  end,
    },
    oheader = {
      name = L["General Options"],
      type = "header",
      cmdHidden = true,
      order = 0,
    },
    ttheader = {
      name = L["Actions"],
      type = "header",
      cmdHidden = true,
      order = 100,
    },
    aheader = {
      name = L["Recipe Options"],
      type = "header",
      cmdHidden = true,
      order = 44,
    },
    show = {
      name = L["Show"],
      desc = L["Show/Hide the ProfessionsVault window"],
      type = "execute",
      order = 110,
      func = function() addon:ToggleWindow()  end,
    },
    kheader = {
      name = L["Keybinding"],
      type = "header",
      cmdHidden = true,
      order = 200,
    },
    togglebind = {
      desc = L["Bind a key to toggle the ProfessionsVault window"],
      type = "keybinding",
      name = L["Show/Hide the ProfessionsVault window"],
      cmdHidden = true,
      order = 210,
      width = "double",
      set = function(info,val) 
         local b1, b2 = GetBindingKey("PROFESSIONSVAULT")
         if b1 then SetBinding(b1) end
         if b2 then SetBinding(b2) end
         SetBinding(val, "PROFESSIONSVAULT") 
	 SaveBindings(GetCurrentBindingSet())
      end,
      get = function(info) return GetBindingKey("PROFESSIONSVAULT") end
    },
    config = {
      name = L["Config"],
      desc = L["Show the ProfessionsVault configuration window"],
      type = "execute",
      guiHidden = true,
      func = function() addon:Config()  end,
    },
    autoclose = {
      name = L["Autoclose"],
      desc = L["Automatically close the ProfessionsVault window when opening a profession"],
      type = "toggle",
      order = 10,
    },
    tooltips = {
      name = L["Tooltips"],
      desc = L["Show tooltips in the ProfessionsVault window"],
      type = "toggle",
      order = 30,
    },
    updatemsg = {
      name = L["Update Messages"],
      desc = L["Print messages to the chat window to show database updates"],
      type = "toggle",
      order = 41,
    },
    ahscan = {
      name = L["AH scan button"],
      desc = L["Enable the AH scanning button on the auction frame"],
      type = "toggle",
      order = 42,
    },
    trainreminder = {
      name = L["Training reminder"],
      desc = L["Print a reminder when you can train a new profession rank"],
      type = "toggle",
      order = 43,
    },
    autoscan = {
      name = L["Scan on recipe learn"],
      desc = L["Prompt to perform an update scan when a new recipe is learned"],
      type = "toggle",
      order = 35,
    },
    recipetooltips = {
      name = L["Recipe Tooltips"],
      desc = L["Enhance recipe tooltips with ProfessionsVault character data"],
      type = "toggle",
      order = 45,
    },
    ahcolor = {
      name = L["AH coloring"],
      desc = L["Color recipes in the AH window with ProfessionsVault character data"],
      type = "toggle",
      order = 47,
    },
    merchantcolor = {
      name = L["Merchant coloring"],
      desc = L["Color recipes in the merchant window with ProfessionsVault character data"],
      type = "toggle",
      order = 48,
    },
    bagcolor = {
      name = L["Bag coloring"],
      desc = L["Color recipes in player bags with ProfessionsVault character data"],
      type = "toggle",
      order = 49,
    },
    bankcolor = {
      name = L["Bank coloring"],
      desc = L["Color recipes in bank and guild bank with ProfessionsVault character data"],
      type = "toggle",
      order = 49,
      set = function(info,val) settings.bankcolor = val ; 
                addon:RefreshTooltips()
                if GuildBankFrame_Update then GuildBankFrame_Update(true) end
            end,
    },
    mailcolor = {
      name = L["Mail coloring"],
      desc = L["Color recipes in mailbox with ProfessionsVault character data"],
      type = "toggle",
      order = 49,
      set = function(info,val) settings.mailcolor = val ; addon:RefreshTooltips(); InboxFrame_Update(true) end,
    },
    dheader = {
      name = L["Recipe Data Options"],
      type = "header",
      cmdHidden = true,
      order = 50,
    },
    selfdata = {
      name = L["Include self"],
      desc = L["Include profession data from self"],
      type = "toggle",
      order = 51,
      disabled = function() return not addon:usingColor() end,
    },
    altdata = {
      name = L["Include alts"],
      desc = L["Include profession data from alts"],
      type = "toggle",
      order = 52,
      disabled = function() return not addon:usingColor() end,
    },
    otherdata = {
      name = L["Include others"],
      desc = L["Include profession data from non-alts"],
      type = "toggle",
      order = 53,
      disabled = function() return not addon:usingColor() end,
    },
    factiondata = {
      name = L["Include opposite faction"],
      desc = L["Include profession data from opposite faction"],
      type = "toggle",
      order = 54,
      disabled = function() return not addon:usingColor() end,
    },
    realmdata = {
      name = L["Include cross realm"],
      desc = L["Include profession data from characters on other realms"],
      type = "toggle",
      order = 55,
      disabled = function() return not addon:usingColor() end,
    },
    ldbheader = {
      name = L["LDB/Minimap Tooltip Options"],
      type = "header",
      cmdHidden = true,
      order = 60,
    },
    ldbself = {
      name = L["Show My Professions"],
      desc = L["Show My Professions"],
      type = "toggle",
      order = 61,
    },
    ldbfavorite = {
      name = L["Show Favorites"],
      desc = L["Show Favorites"],
      type = "toggle",
      order = 62,
    },
    ldbeinstein = {
      name = L["Show All Recipes"],
      desc = L["Show All Recipes"],
      type = "toggle",
      order = 63,
    },
    minimap = {
      name = L["Minimap icon"],
      desc = L["Show minimap icon"],
      type = "toggle",
      order = 30,
      get = function(info) return not settings.minimap.hide end,
      set = function(info,val) 
                  settings.minimap.hide = not val
		  minimapIcon:Update()
            end
    },
   }}, -- general
  unhide = {
   type = "group",
   name = L["Unhide Entries"],
   args = {
     desc = {
       order = 10,
       type = "description",
       fontSize = "medium",
       cmdHidden = true, 
       dropdownHidden = true,
       name = L["unhide_desc"]
     },
     unhidesel = {
       order = 20,
       name = L["Unhide Selected"],
       type = "execute",
       cmdHidden = true, 
       dropdownHidden = true,
       disabled = function() for _,v in pairs(PV_unhide or {}) do if v then return false end end; return true end,
       func = function() 
         --myprint(PV_unhide)
	 for k,v in pairs(PV_unhide) do
	   if v then
	     settings.hide[k] = nil
	   end
	   PV_unhide[k] = nil
	 end
         addon:RefreshTooltips(); addon:RefreshWindow();
       end,
     },
     all = {
       order = 30,
       name = L["Unhide All"],
       type = "execute",
       func = function () settings.hide = {}; addon:RefreshTooltips(); addon:RefreshWindow(); end
     },
     hidelist = {
       order = 40,
       name = L["Currently Hidden Entries"]..":",
       type = "multiselect",
       cmdHidden = true, 
       dropdownHidden = true,
       values = function() 
          local t = {}; 
	  PV_unhide = PV_unhide or {} ; 
	  for k,_ in pairs(settings.hide) do 
	    local disp = k
	    local cname, pname = k:match("^(.+)/(.+)$")
	    if cname and pname then
	      cname = addon:coloredcname(cname,nil,true)
	      disp = cname.."/"..pname
	    end
	    t[k] = disp
	  end 
	  return t
       end,
       get = function(info,key) return PV_unhide[key] end,
       set = function(info,key,val) PV_unhide[key] = val end,
     },
  }}, -- unhide
  color = {
   type = "group",
   name = L["Color"],
   args = {
    ttnames = {
      name = L["Tooltip names"],
      desc = L["Color character names in tooltips"],
      type = "toggle",
      order = 20,
      set = function(info,val) settings.colorttnames = val; addon:RefreshTooltips() end,
      get = function(info) return settings.colorttnames end
    },
    winnames = {
      name = L["Window names"],
      desc = L["Color character names in window"],
      type = "toggle",
      order = 10,
      set = function(info,val) settings.colorwinnames = val; addon:RefreshWindow() end,
      get = function(info) return settings.colorwinnames end
    },
    charactercolor = {
      name = L["Character colors"],
      type = "group",
      inline = true,
      order = 100,
      get = function (info) 
              settings.charcolor = settings.charcolor or table_clone(defaults.profile.charcolor)
	      local r,g,b,a = unpack(settings.charcolor[info[#info]])
              return r/255.0, g/255.0, b/255.0, (a or 255)/255.0
	    end,
      set = function (info,r,g,b,a) 
              local chartype = info[#info]
	      --debug("Setting color for chartype: "..chartype)
              settings.charcolor = settings.charcolor or table_clone(defaults.profile.charcolor)
              settings.charcolor[chartype] = {r*255,g*255,b*255,a*255} 
              addon:updateColors()
	    end,
      args = {
        self =   { type = "color", order = 10, name = L["Self"] },
        system = { type = "color", order = 15, name = L["System"] },
        alt =    { type = "color", order = 20, name = L["Alts"] },
        other =  { type = "color", order = 30, name = L["Others"] },
        falt =   { type = "color", order = 40, name = L["Cross-faction"].." "..L["Alts"] },
        fother = { type = "color", order = 50, name = L["Cross-faction"].." "..L["Others"] },
      }
    },
    recipecolor = {
      name = L["Recipe colors"],
      type = "group",
      inline = true,
      order = 200,
      get = function (info)
              settings.recipecolor = settings.recipecolor or table_clone(defaults.profile.recipecolor)
              local r,g,b,a = unpack(settings.recipecolor[info[#info]])
              return r, g, b, (a or 1.0)
            end,
      set = function (info,r,g,b,a)
              local rtype = info[#info]
              --debug("Setting color for recipetype: "..rtype)
              settings.recipecolor = settings.recipecolor or table_clone(defaults.profile.recipecolor)
              settings.recipecolor[rtype] = {r,g,b,a}
              addon:RefreshTooltips()
            end,
      args = {
	learn_self    = { type = "color", order = 10, name = L["Learnable"].." "..L["Self"] },
	learn_alt     = { type = "color", order = 20, name = L["Learnable"].." "..L["Alts"] },
	learn_other   = { type = "color", order = 30, name = L["Learnable"].." "..L["Others"] },
	learn_falt    = { type = "color", order = 39, name = L["Learnable"].." "..L["Cross-faction"].." "..L["Alts"] },
	learn_fother  = { type = "color", order = 40, name = L["Learnable"].." "..L["Cross-faction"].." "..L["Others"] },
	skill_self    = { type = "color", order = 50, name = L["Skill too low"].." "..L["Self"] },
	skill_alt     = { type = "color", order = 60, name = L["Skill too low"].." "..L["Alts"] },
	skill_other   = { type = "color", order = 70, name = L["Skill too low"].." "..L["Others"] },
	skill_falt    = { type = "color", order = 79, name = L["Skill too low"].." "..L["Cross-faction"].." "..L["Alts"] },
	skill_fother  = { type = "color", order = 80, name = L["Skill too low"].." "..L["Cross-faction"].." "..L["Others"] },
	known_self    = { type = "color", order = 100, name = L["Known"].." "..L["Self"] },
	known_alt     = { type = "color", order = 110, name = L["Known"].." "..L["Alts"] },
	known_other   = { type = "color", order = 120, name = L["Known"].." "..L["Others"] },
	known_falt    = { type = "color", order = 129, name = L["Known"].." "..L["Cross-faction"].." "..L["Alts"] },
	known_fother  = { type = "color", order = 130, name = L["Known"].." "..L["Cross-faction"].." "..L["Others"] },
	unknown       = { type = "color", order = 200, name = L["Not Known"] },
	dunno         = { type = "color", order = 210, name = L["Not sure"] },
      }
    },
  }} -- colors
  }
} 
end

if enhanceColorPicker then
-- WTB HookScript on a texture >.<
-- ColorPickerFrame:HookScript("OnColorSelect") would be more elegant, 
-- but no way to unambiguously retrieve the rgb info
local csst = ColorSwatch.SetTexture
ColorSwatch.SetTexture = function(self,r,g,b,a)
  --myprint(r,g,b,a) 
  local pc = InterfaceOptionsFramePanelContainer
  if not pc then return end
  if r and g and b and pc:IsVisible() and pc.displayedPanel == colorFrame then
    csst(self,"Interface\\Icons\\inv_scroll_03")
    self:SetVertexColor(r,g,b, (a or 1))
  else
    self:SetVertexColor(1,1,1,1)
    csst(self, r,g,b,a) 
  end
end
end

local function charcolor(chartype)
  local r,g,b,a = unpack(settings.charcolor[chartype])
  local str = string.format("%02x%02x%02x",r,g,b)
  --print(str)
  return str
end

local function coloredcname(cname,typecolor,classcolor)
  local color, ctype
  local dbc = DB.chars[cname]
  if cname == einstein then
    color = charcolor("system")
    ctype = "system"
  elseif cname == charName then
    color = charcolor("self")
    ctype = "self"
  elseif dbc.data and dbc.data.faction ~= DBc.data.faction and dbc.data.alt then
    color = charcolor("falt")
    ctype = "falt"
  elseif dbc.data and dbc.data.faction ~= DBc.data.faction then
    color = charcolor("fother")
    ctype = "fother"
  elseif dbc.data and dbc.data.alt then
    color = charcolor("alt")
    ctype = "alt"
  else 
    color = charcolor("other")
    ctype = "other"
  end
  cname = select(4, addon:name_normalize(cname)) -- abbreviate server
  if not addon.classlist then
    addon.classlist = {}
    FillLocalizedClassList(addon.classlist)
    addon.classlist = addon:table_invert(addon.classlist)
  end
  local class = dbc.data and dbc.data.class
  class = class and addon.classlist[class]
  if classcolor and class and RAID_CLASS_COLORS[class] then
    return "\124c"..RAID_CLASS_COLORS[class].colorStr..cname.."\124r", ctype
  elseif typecolor then
    return "\124cff"..color..cname.."\124r", ctype
  else
    return cname, ctype
  end
end
function addon:coloredcname(...) return coloredcname(...) end

local function charicon(cname)
    local dbc = DB.chars[cname]
    if cname == einstein then
      return "Interface\\Icons\\inv_misc_book_07"
    elseif dbc and dbc.data and dbc.data.faction and dbc.data.faction == "Horde" then
      return "Interface\\BattlefieldFrame\\Battleground-Horde"
      --return "Interface\\TargetingFrame\\UI-PVP-Horde"
    elseif dbc and dbc.data and dbc.data.faction and dbc.data.faction == "Alliance" then
      return "Interface\\BattlefieldFrame\\Battleground-Alliance"
      --return "Interface\\TargetingFrame\\UI-PVP-Alliance"
    else 
      return "Interface\\GossipFrame\\ActiveQuestIcon"
    end
end

local function chardatastr(cname)
  local data = DB.chars[cname] and DB.chars[cname].data
  if not data then
    return nil
  end
  local text = ""
  for _,stat in ipairs({"level","faction","class"}) do
    local val = data[stat]
    if stat == "faction" and val then val = LFaction[val] end
    if val then
       text = text..val.." "
    end
  end
  if data.alt then
    text = text.." ("..L["alt"]..")"
  end
  return text
end

function addon:isHidden(cname,pname)
  cname = cname or "*"
  pname = pname or "*"
  return settings.hide[cname.."/"..pname] or 
         settings.hide["*/"..pname] or 
         settings.hide[cname.."/*"] 
end

function addon:RefreshChar()
  debug("RefreshChar")
  DB.chars[charName] = DB.chars[charName] or {}
  DBc = DB.chars[charName]
  DBc.data = DBc.data or {}
  DBc.data.name = charName
  DBc.data.faction = UnitFactionGroup("player")
  DBc.data.level = UnitLevel("player")
  DBc.data.class = UnitClass("player")
  DBc.data.scanned = DBc.data.scanned or false
  if DBc.data.alt == nil then
    DBc.data.alt = true
  end
end

function addon:RefreshConfig()
  debug("RefreshConfig")
  charName = addon:name_normalize(UnitName("player"))
  DB = self.db.global
  wipe(self.db.realm) -- remove old per-realm database
  DB.chars = DB.chars or {}
  DB.guid_cache = DB.guid_cache or {}

  settings = addon.db.profile
  addon.settings = settings
  settings.hide = settings.hide or {}
  settings.vermaj = settings.vermaj or DB_VERSION_MAJOR
  settings.vermin = settings.vermin or DB_VERSION_MINOR

  if settings.debug then
    PV = addon
  end

  -- ticket 13: this seems to help, dont ask me why. Fuck AceGUI.
  if settings.treestatus then
    settings.treestatus.scrollvalue = 0
  end

  addon:RefreshChar()
  addon:RefreshWindow()
  if minimapIcon.Update then minimapIcon:Update() end
end

local function resetSettings() 
  debug("resetSettings")
  local ishown = InterfaceOptionsFrame:IsShown()
  local wshown = addon.gui and true
  if wshown then
    addon:ToggleWindow()
  end
  if ishown then
    InterfaceOptionsFrame:Hide();
  end

  addon.db.profile = table_clone(defaults.profile)

  addon:RefreshConfig()
  addon:AddEinstein()
  if ishown then
    InterfaceOptionsFrame_OpenToCategory(optionsFrame)
  end
  if wshown then
    addon:ToggleWindow()
  end
end

function addon:updateColors()
  addon:RefreshWindow()
  addon:RefreshTooltips()
end

function addon:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("ProfessionsVaultDB", defaults)
  local options = myOptions()
  rcolortable = options.args.color.args.recipecolor.args
  LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, options, {L["professionsvault"], L["pv"]})
  optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName, nil, "general")
  optionsFrame.default = resetSettings
  colorFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, L["Color"], addonName,"color")
  colorFrame.default = function () 
     settings.charcolor = table_clone(defaults.profile.charcolor)
     settings.recipecolor = table_clone(defaults.profile.recipecolor)
     if InterfaceOptionsFrame:IsShown() then
       InterfaceOptionsFrame:Hide();
       InterfaceOptionsFrame_OpenToCategory(colorFrame)
     end
     addon:updateColors() end
  unhideFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, L["Unhide Entries"], addonName,"unhide")
  options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, L["Profiles"], addonName, "profiles")
  LibStub("AceEvent-3.0"):Embed(addon)
  LibStub("AceTimer-3.0"):Embed(addon) 
  settings = addon.db.profile

  debug("OnInitialize")

  addon:build_tables()

  addon:recipeClass() -- init caches
  addon:isRecipe(43017)

  self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
  self.db.RegisterCallback(self, "OnDatabaseReset", "RefreshConfig")
  self:RefreshConfig()
end

function addon:SetupVersion()
   local sv = 0
   svnrev["X-Build"] = tonumber((GetAddOnMetadata("ProfessionsVault", "X-Build") or ""):match("%d+"))
   svnrev["X-Revision"] = tonumber((GetAddOnMetadata("ProfessionsVault", "X-Revision") or ""):match("%d+"))
   for _,v in pairs(svnrev) do -- determine highest file revision
     if v and v > sv then
       sv = v
     end
   end
   ProfessionsVault.revision = sv

   svnrev["X-Curse-Packaged-Version"] = GetAddOnMetadata("ProfessionsVault", "X-Curse-Packaged-Version")
   svnrev["Version"] = GetAddOnMetadata("ProfessionsVault", "Version")
   ProfessionsVault.version = svnrev["X-Curse-Packaged-Version"] or svnrev["Version"] or "@"
   if string.find(ProfessionsVault.version, "@") then -- dev copy uses "@.project-version.@"
      ProfessionsVault.version = "r"..sv
   end
end
local function PV_ShowTooltip(self,...)
        if addon.settings.recipetooltips or
	   ((addon.settings.ahcolor or addon.settings.merchantcolor) and self == addon.scantt) then
                addon:ShowTooltip(self)
        end
end
local function PV_ShowItemRefTooltip(cleanlink, link, button, frame)
	if not link and cleanlink then -- ticket 50
	  link = addon:dirtylink(cleanlink)
          debug("PV_ShowItemRefTooltip: link="..link.." cleanlink="..cleanlink)
	end
	if not link then
	  return
	end
        if addon.settings.recipetooltips and
	   (string.find(link,"\124Hitem:",1,true) or string.find(link,"\124Henchant:",1,true)) then
                addon:ShowTooltip(ItemRefTooltip)
        end
	if string.find(link, "\124Htrade:",1,true) then -- opened a tradeskill UI link
	   addon.lastTSL = link
	   addon:update_guid_cache_fromlink(link)
	   debug("Set addon.lastTSL = "..(addon.lastTSL or "nil").." ("..addon:hash(addon.lastTSL)..")")
	   addon:TSLupdate()
	end
end
local function PV_AuctionScroll(...)
        if addon.settings.ahcolor then
	        addon:SetAuctionColors()
        end
	if AuctionFrame and settings.ahscan and not addon.ahscanbutton then
	  local f = CreateFrame("Button",addonName.."_ahscanbutton",AuctionFrame,"UIPanelButtonTemplate")
	  local h = BrowseSearchButton and select(2,BrowseSearchButton:GetSize())-3 or 19
	  local r = AuctionFrameCloseButton or AuctionFrame
	  f:SetText(L["Recipe Scan"])
	  f:SetSize(100,h)
	  f:SetScript("OnClick", function() addon:ScanAH() end)
	  f:SetScript("OnEnter", function(self) 
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
            GameTooltip:SetText(L["Scan for learnable recipes using ProfessionsVault"]);
            GameTooltip:Show()
	  end)
	  f:SetScript("OnLeave",function() GameTooltip:Hide() end)
	  f:SetPoint("TOPRIGHT",r,-130,-6)
	  f:Show()
	  addon.ahscanbutton = f
	elseif addon.ahscanbutton then
	  if settings.ahscan then
	    addon.ahscanbutton:Show()
	  else
	    addon.ahscanbutton:Hide()
	  end
	end
end

local function SetLDBProf(pname)
  if not pname then pname = addon.db.char.ldbprof end
  if pname == GetSpellInfo(PID_SMELT) then
     pname = GetSpellInfo(PID_MINE)
  end
  if pname and PVLDB and allProf[pname] and DBc[pname] then
    local pinfo = DBc[pname]
    local rank = pinfo.rank or "??"
    local rankmax = pinfo.rankmax or "??"
    local tex = "|T"..allProf[pname].icon..":0|t"
    PVLDB.text = " "..tex.." ("..rank.."/"..rankmax..")"
    addon.db.char.ldbprof = pname
  else
    addon.db.char.ldbprof = nil
    PVLDB.text = addonName
  end
end

local function GetLDBProf()
  local pname = addon.db.char.ldbprof
  if allProf[pname] and DBc[pname] and 
     (not allProf[pname].nocast or allProf[pname].spellid == PID_MINE) then
    return pname, DBc[pname].link
  end
end

-- ticket 64: workaround the fact that some combinations of addons break AceEvent ADDON_LOADED
local backupFrame = CreateFrame("Button", "ProfessionsVaultEventHiddenFrame", UIParent)
backupFrame:RegisterEvent("ADDON_LOADED")
backupFrame:SetScript("OnEvent", function(frame,...) addon:ADDON_LOADED(...) end)

function addon:ADDON_LOADED(evt, name)
        debug("ADDON_LOADED: "..(name or "nil"))
        if IsAddOnLoaded("Blizzard_AuctionUI") and not addon.auchook then
          hooksecurefunc("AuctionFrameBrowse_Update", PV_AuctionScroll)
	  addon.auchook = true
        end
        if IsAddOnLoaded("Auc-Advanced") and not addon.AuctioneerAdv then
                if AucAdvanced and AucAdvanced.Settings and AucAdvanced.Settings.GetSetting and 
		   AucAdvanced.Settings.GetSetting("util.compactui.activated") then
                        debug("Auctioneer Advanced CompactUI detected")
                        addon.AuctioneerAdv = true
                end
        end
        if GuildBankFrame_Update and not addon.gbhooked then
          hooksecurefunc("GuildBankFrame_Update", function(...) addon:GuildBankFrame_Update(...) end)
          addon.gbhooked = true
        end
        if Bagnon and Bagnon.ItemSlot and Bagnon.ItemSlot.UpdateSlotColor and not addon.bagnonhooked then
          hooksecurefunc(Bagnon.ItemSlot, "UpdateSlotColor", addon.bagnon_hook)
	  addon.bagnonhooked = true
        end
        if ArkInventory and not addon.arkinvhooked then
          if ArkInventory.SetItemButtonTexture then
            hooksecurefunc(ArkInventory, "SetItemButtonTexture", addon.arkinv_hook)
          end
          if ArkInventory.SetItemButtonDesaturate then
            hooksecurefunc(ArkInventory, "SetItemButtonDesaturate", addon.arkinv_hook)
          end
	  addon.arkinvhooked = true
        end
        if Baggins and Baggins.UpdateItemButton and not addon.bagginshooked then
          hooksecurefunc(Baggins, "UpdateItemButton", addon.baggins_hook)
	  addon.bagginshooked = true
        end
	if IsAddOnLoaded("OneBag3") then
	  addon.onebagaddon = true
	end
	if IsAddOnLoaded("Combuctor") and not addon.combuctorhooked then
	  local Combuctor = LibStub('AceAddon-3.0'):GetAddon('Combuctor',true)
	  if Combuctor and Combuctor.ItemSlot then
            hooksecurefunc(Combuctor.ItemSlot, "UpdateSlotColor", addon.combuctor_hook)
	    addon.combuctorhooked = true
	  end
	end
	if IsAddOnLoaded("ElvUI") and not addon.elvuihooked then
	  local E = ElvUI and ElvUI[1]
	  local B = E and E:GetModule('Bags')
	  if B and B.SlotUpdate then
            hooksecurefunc(B, "SlotUpdate", addon.elvui_hook)
	    addon.elvuihooked = true
	  end
	end
end

function addon:OnEnable()
  debug("OnEnable")

  self:SetupVersion()

  addon:AddEinstein()
  addon:CleanDatabase()

  self:RegisterEvent("TRADE_SKILL_SHOW")
  self:RegisterEvent("TRADE_SKILL_UPDATE")
  self:RegisterEvent("TRADE_SKILL_NAME_UPDATE")
  self:RegisterEvent("ADDON_LOADED")
  self:RegisterEvent("MERCHANT_UPDATE")
  self:RegisterEvent("MERCHANT_SHOW")
  self:RegisterEvent("MERCHANT_CLOSED")
  self:RegisterEvent("CHAT_MSG_SYSTEM")
  self:RegisterEvent("CHAT_MSG_SKILL")
  --self:RegisterEvent("BAG_UPDATE")

  local chatevents = {
    "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_GUILD_ACHIEVEMENT",
    "CHAT_MSG_CHANNEL", "CHAT_MSG_SAY", "CHAT_MSG_YELL", 
    "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", 
    "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_DND", "CHAT_MSG_AFK", "CHAT_MSG_EMOTE", "CHAT_MSG_TEXT_EMOTE",
  }
  for _,chatevent in pairs(chatevents) do
    self:RegisterEvent(chatevent, "CHAT_MSG_X")
  end

  addon:ADDON_LOADED() -- in case we are loaded late

  if true then
    local tthooks = {
	"SetAuctionItem", "SetAuctionSellItem", 
	"SetExistingSocketGem", "SetSocketGem", "SetGlyph", "SetSpellByID",
	"SetHyperlink", "SetAction",
	"SetBagItem", "SetGuildBankItem", "SetInventoryItem",
	"SetTradePlayerItem", "SetTradeSkillItem",
	"SetLootItem", "SetLootRollItem", 
	"SetMerchantItem", "SetBuybackItem", 
	"SetSendMailItem", "SetInboxItem", 	
    }
    for _,hook in pairs(tthooks) do
      hooksecurefunc(GameTooltip, hook, PV_ShowTooltip)
    end
    hooksecurefunc(addon.scantt, "SetHyperlink", PV_ShowTooltip)
    if AtlasLootTooltip and AtlasLootTooltip ~= GameTooltip then -- ticket 71: don't tweak GameTooltip
      hooksecurefunc(AtlasLootTooltip, "SetHyperlink", PV_ShowTooltip)
      if AtlasLootTooltip.HookScript then -- all this just to help it resize properly
        local resizedammit = function () 
	  AtlasLootTooltip:SetSize(AtlasLootTooltip:GetSize())
	  AtlasLootTooltip:Show()
	end
        AtlasLootTooltip:HookScript("OnTooltipSetItem", resizedammit)
        AtlasLootTooltip:HookScript("OnTooltipSetSpell", resizedammit)
        AtlasLootTooltip:HookScript("OnSizeChanged", resizedammit)
        AtlasLootTooltip:HookScript("OnUpdate", resizedammit)
      end
    end
    hooksecurefunc("SetItemRef", PV_ShowItemRefTooltip)
    hooksecurefunc("GetGuildMemberRecipes", function () addon.lastTSL = nil end)
    --]]
  else
    GameTooltip:HookScript("OnTooltipSetItem", PV_ShowTooltip)
    ItemRefTooltip:HookScript("OnTooltipSetItem", PV_ShowTooltip)
    if AtlasLootTooltip and AtlasLootTooltip.HookScript then
      AtlasLootTooltip:HookScript("OnTooltipSetItem", PV_ShowTooltip)
    end
  end

  if AtlasLoot and AtlasLoot.SetItemTable then
    hooksecurefunc(AtlasLoot,"SetItemTable",addon.AtlasLootUpdate)
  end
  if AtlasLoot and AtlasLoot.CompareFrame_UpdateItemListScrollFrame then
    hooksecurefunc(AtlasLoot,"CompareFrame_UpdateItemListScrollFrame",addon.AtlasLootUpdate)
  end


  if not DBc.data.scanned and  -- no professions registered on this toon
     not addon.badversion then -- don't pester if the addon is and deleting links every init
    addon:Scan()
  else
    addon:ScanSecondary() -- does not capture primary profs during static load because GetSpellLink is not yet functional
  end

  PVLDB = LDB:NewDataObject(addonName, {
        type = "data source",
        label = addonName,
        --icon = "Interface\\Icons\\spell_shadow_mindtwisting",
        --icon = "Interface\\Icons\\inv_misc_enggizmos_17",
        icon = "Interface\\Icons\\inv_scroll_03",
        OnClick = function(self, button)
                if button == "MiddleButton" then
			addon:Config()
                elseif button == "RightButton" then
			local pname, link = GetLDBProf()
			if pname then
		  	  addon:ActivateLink(charName, pname, link, true)
			end
                else
                        addon:ToggleWindow()
                end
        end
  })
  PVLDB.OnTooltipShow = function(tooltip)
	debug("LDB:OnTooltipShow "..(tooltip and tooltip == GameTooltip and "" or "not ").."GameTooltip")
	PVLDB.OnEnter(tooltip:GetOwner())
  end
  PVLDB.OnEnter = function(self)
        debug("PVLDB:OnEnter")
	addon:ScanSecondary()
	PVLDBTT = PVLDBTT or CreateFrame("GameTooltip", "PVLDBTT", UIParent, "GameTooltipTemplate")
	local tt = PVLDBTT
   	tt:SetOwner(self, "ANCHOR_NONE")
	--print(self:GetTop()..":"..self:GetBottom()..":"..self:GetLeft()..":"..self:GetRight())
	-- ticket73: compute an appropriate anchor given LDB location
	local left, bottom = self:GetBoundsRect() 
	local width = GetScreenWidth()
	local height = GetScreenHeight()
	if bottom > height/2 then -- top
	  if left < width/2 then -- left
	    tt:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")
	  else -- right
	    tt:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	  end
	else -- bottom
	  if left < width/2 then -- left
	     tt:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT")
	  else -- right
	     tt:SetPoint("BOTTOMLEFT", self, "TOPLEFT")
	  end
	end
	tt:ClearLines()
	addon:fillLDB(tt)
        tt:EnableMouse(true)
	tt:Show()
	--GameTooltip:SetScript("OnMouseDown",function(self,button) addon:LDBclick(self,button) end)
        -- must use a button for OnClick hardware event to CastSpellByName
        PVLDBButton = PVLDBButton or CreateFrame("Button", "PVLDBButton", tt)
        PVLDBButton:SetAllPoints(tt)
	PVLDBButton:SetScript("OnClick",function(self,btn) addon:LDBclick(tt,btn) end)
        PVLDBButton:RegisterForClicks("AnyDown")
        PVLDBButton:SetScript("OnLeave", function() tt:Hide() end)
  end
  PVLDB.OnLeave = function() 
        debug("PVLDB:OnLeave")
	if PVLDBTT and not PVLDBTT:IsMouseOver() then
	   PVLDBTT:Hide()
	end
  end

  settings.minimap = settings.minimap or {}
  minimapIcon:Register(addonName, PVLDB, settings.minimap)
  minimapIcon.Update = function()
    if settings.minimap.hide then
      minimapIcon:Hide(addonName)
    else
      minimapIcon:Show(addonName)
    end
  end
  minimapIcon:Update()
  SetLDBProf()

end

function addon:fillLDB(tooltip)
  local ttname = tooltip:GetName()
  tooltip:SetText(addonName.." "..ProfessionsVault.version)
  tooltip:AddLine("|cffff8040"..L["Left Click"].."|r "..L["to toggle the window"])
  tooltip:AddLine("|cffff8040"..L["Middle Click"].."|r "..L["for config"])
  local pname = GetLDBProf()
  if pname then
    tooltip:AddLine("|cffff8040"..L["Right Click"].."|r "..L["to open"].." "..pname)
  end
  addon.ldblines = addon.ldblines or {}
  wipe(addon.ldblines)
  if not DBc then return end
  if settings.ldbself then
    tooltip:AddLine(" ")
    tooltip:AddLine("|cffff8040"..L["My Professions"]..":|r")
    for _,pname in ipairs(allProfSorted) do
      local pinfo = DBc[pname]
      if pinfo then 
        local rank = pinfo.rank or "??"
        local rankmax = pinfo.rankmax or "??"
        local texstr = "|T"..allProf[pname].icon..":0|t"
	local hidden = ""
	if addon:isHidden(charName,pname) then
	  hidden = " ("..L["hidden"]..")"
	end
        tooltip:AddDoubleLine(texstr.." ["..pname.."]"..hidden,"("..rank.."/"..rankmax..")")
	addon.ldblines[tooltip:NumLines()] = charName.."\t"..pname.."\t"..(pinfo.link or "")
      end
    end
  end
  if settings.ldbfavorite then
    tooltip:AddLine(" ")
    tooltip:AddLine("|cffff8040"..L["Favorites"]..":|r")
    for _,pname in ipairs(allProfSorted) do
      for cname,cinfo in pairs(DB.chars) do
        local pinfo = cinfo[pname]
        if pinfo and pinfo.link and pinfo.favorite then
          local texstr = "|T"..allProf[pname].icon..":0|t"
          tooltip:AddDoubleLine(texstr.." ["..pname.."]",coloredcname(cname,nil,true))
	  addon.ldblines[tooltip:NumLines()] = cname.."\t"..pname.."\t"..pinfo.link
	end
      end
    end
  end
  if settings.ldbeinstein and false then
    tooltip:AddLine(" ")
    tooltip:AddLine("|cffff8040"..einstein..":|r")
    for _,pname in ipairs(allProfSorted) do
      local pinfo = DB.chars[einstein][pname]
      if (pinfo and pinfo.link) then
        local texstr = "|T"..allProf[pname].icon..":0|t"
        tooltip:AddDoubleLine(texstr.." ["..pname.."]"," ")
	addon.ldblines[tooltip:NumLines()] = einstein.."\t"..pname.."\t"..pinfo.link
      end
    end
  end
  
end
function addon:LDBclick(tt,button)
   local ttname = tt:GetName()
   debug("LDBclick "..ttname)
   if not addon.ldblines then return end
   local gotone = false
   for i, linedata in pairs(addon.ldblines) do
     local lline = getglobal(ttname .. "TextLeft"..i)
     if not lline then return end
     if lline:IsMouseOver(0,0,-500,500) and linedata then
         local cname, pname, link = strsplit("\t",linedata)
         debug("LDBclicked on "..cname.." "..pname.." "..link)
	 if #link == 0 then link = nil end
         addon:ActivateLink(cname, pname, link, true)
         gotone = true
     end   
   end
   if not gotone then
     PVLDB:OnClick(button)
   end
   --tt:Hide()
end
-- ----------------------------------------------------------------------------------
-- ticket 40: German client uses weird replacement strings
-- enUS/GB: Your skill in %s has increased to %d.
-- deDE: Eure Fertigkeit '%1$s' hat sich auf %2$d erhöht.
-- esES: Tu habilidad en %s ha subido a %d p.
-- frFR: Votre compétence en %s est maintenant de %d.
-- ruRU: %s ?????????? ?? %d.
local m_skillup = string.gsub(SKILL_RANK_UP,"%%%d*\$?[sd]","\(\.\*\)")
local m_patlearn = string.gsub(ERR_LEARN_RECIPE_S,"%%s","\(\.\*\)")
local m_proflearn = string.gsub(ERR_SKILL_GAINED_S,"%%s","\(\.\*\)")
local m_profunlearn = string.gsub(ERR_SPELL_UNLEARNED_S,"%%s","\(\.\*\)")
local m_profupgrade = string.gsub(ERR_LEARN_ABILITY_S,"%%s","\(\.\*\)")
local function processSystemMessage(msg)
  --myprint(msg) ; printlink(msg)
  local rescan = false
  local skillprof, skillrank = string.match(msg, m_skillup)
  local patlearn    = string.match(msg, m_patlearn)
  local proflearn   = string.match(msg, m_proflearn)
  local profunlearn = string.match(msg, m_profunlearn)
  local profupgrade = string.match(msg, m_profupgrade)
  if skillrank and allProf[skillprof] then
    skillrank = tonumber(skillrank)
    debug("Detected skill up: "..skillprof.." "..skillrank)
    rescan = skillprof
  elseif patlearn then
    debug("Detected pattern learn: "..patlearn)
    rescan = true
  elseif proflearn and allProf[proflearn] then
    debug("Detected profession learn: "..proflearn)
    rescan = proflearn
  elseif profunlearn or profupgrade then
    local spellid = string.match(profunlearn or profupgrade, "|Hspell:(%d+)|h")
    spellid = spellid and tonumber(spellid)
    local spellname = spellid and GetSpellInfo(spellid)
    if allProf[spellname] and DBc[spellname] then
      if profunlearn then
        debug("Detected profession unlearn: "..profunlearn)
        DBc[spellname] = nil
        SetLDBProf(nil)
        -- cannot rescan here because GetSpellLink still returns the prof
      elseif profupgrade then
        debug("Detected profession upgrade: "..spellname)
        rescan = spellname
      end
    end
  end
  if rescan then
    local gotone, _, _, _, pname = addon:ReScan()
    if gotone then
      if not allProf[rescan] then
        rescan = pname
      end
    else
      debug("Failed to detect profession change for: "..msg) -- ticket 86
      addon:ScheduleTimer(function() 
          local gotone, _, _, _, pname = addon:ReScan()
          if gotone then
	    SetLDBProf(pname)
	  else
	    debug("Delayed rescan failed for: "..msg)
	    if settings.autoscan then
              DBc.data.scanned = false
	      addon.scannote = L["If you have more patterns to learn, just ignore this window until you are done."].."\n"..
                L["You can avoid this prompt in the future by having your tradeskill window open while learning patterns."]
              addon:Scan()
	    end
	  end
      end, 1.5)
      return
    end
    if allProf[rescan] then 
       SetLDBProf(rescan) 
    end
  end
end

function addon:CHAT_MSG_SKILL(event, msg, ...)
  --myprint(event, msg, ...) ; printlink(msg)
  processSystemMessage(msg)
end
function addon:CHAT_MSG_SYSTEM(event, msg, ...)
  --myprint(event, msg, ...) ; printlink(msg)
  processSystemMessage(msg)
end
-- ----------------------------------------------------------------------------------
-- convert any form of character name and realm into fully-qualified and separated versions
local function name_normalize(cname, realm)
  if not cname then return nil end
  local thisRealm = GetRealmName():gsub("%s","")
  local ccname, crname = cname:match("^([^-]+)-([^-]+)$")
  if ccname and crname then -- fully-qualified cname
    crname = crname:gsub("%s","")
    return cname, ccname, crname, ((crname == thisRealm) and ccname or cname)
  end
  if not realm or #realm == 0 then realm = thisRealm end
  realm = realm:gsub("%s","")
  local fullname = cname.."-"..realm
  local shortname = fullname
  if realm == thisRealm then shortname = cname end
  return fullname, cname, realm, shortname
end
function addon:name_normalize(...) return name_normalize(...) end
local function guid_normalize(guid, hexprefix)
  if not guid then return nil end
  local res = string.gsub(guid, "^0x","")
  res = string.rep("0",16-#res)..res -- leading zeros get lost in some contexts
  if hexprefix then res = "0x"..res end
  return res
end
function addon:update_guid_cache(name, guid)
  if name and guid and UnitIsInMyGuild(name) then
    name = name_normalize(name)
    guid = guid_normalize(guid)
    local oldval = DB.guid_cache[name]
    local changed
    if not oldval then
      if debug then debug("Saving new guid "..name.." "..guid) end
      changed = true
    elseif oldval ~= guid then
      if debug then debug("Updating guid "..name.." "..oldval.." => "..guid) end
      changed = true
    end
    if changed then
      DB.guid_cache[name] = guid
      local isLinked, cname = IsTradeSkillLinked()
      if cname and name_normalize(cname) == name and GetTradeSkillLine() ~= "UNKNOWN" then -- just got the GUID for a guild trade
        addon:UpdateTrade(false)
      end
    end
  end
end
function addon:link_cnameguid(link)
   if not link then return end
   local guid = select(2,addon:link_parse(link))
   if not guid then return end
   local cname, realm = select(7,pcall(GetPlayerInfoByGUID,guid)) -- sometimes failed if not encountered by client
   return guid, name_normalize(cname, realm)
end
function addon:update_guid_cache_fromlink(link)
   local guid, cname = addon:link_cnameguid(link)
   if cname and guid then addon:update_guid_cache(cname, guid) end
end

function addon:CHAT_MSG_X(event, msg, sender, _,_,_,_,_,_,_,_, counter, guid)
  addon:update_guid_cache(sender, guid)
end

-- show the TradeSkillLinkButton when we can
function addon:TSLupdate() 
  if not TradeSkillLinkButton then return end
  if IsTradeSkillGuild() or nolinkProf[GetTradeSkillLine()] then 
    addon:SaveButton():Hide()
    TradeSkillLinkButton:Hide()
    return 
  end

  if addon.lastTSL then
    TradeSkillLinkButton:Show()
  end

  local linked, cname = IsTradeSkillLinked()
  cname = addon:name_normalize(cname)
  local spellid, guid = addon:link_parse(addon.lastTSL)

  if cname and cname ~= charName and addon.lastTSL and
     guid_normalize(guid) ~= guid_normalize(UnitGUID("player")) then
    addon:SaveButtonShow()
  end
end

-- wrap GetTradeSkillListLink to return our link for Blizzard_TradeSkillUI
local function wrap_GetTradeSkillListLink()
  if addon.lastTSL and TradeSkillLinkButton:IsVisible() and not nolinkProf[GetTradeSkillLine()] then 
    return addon.lastTSL
  else
    return GetTradeSkillListLink()
  end
end
local function TSLpreclick() 
  _G.GetTradeSkillListLink = wrap_GetTradeSkillListLink 
end
local function TSLpostclick() 
  _G.GetTradeSkillListLink = GetTradeSkillListLink 
end
local function TradeSkillLinkDropDown_LinkPost(self, chan)
  local link = wrap_GetTradeSkillListLink();
  if link then
    ChatFrame_OpenChat(chan.." "..link, DEFAULT_CHAT_FRAME);
  end
end

local function TSLNhide() 
  local pname, rank, rankmax = GetTradeSkillLine()
  local isLinked, name = IsTradeSkillLinked()
  if false and not IsTradeSkillGuild() then -- hide link name
     if TradeSkillLinkNameButton then
       TradeSkillLinkNameButton:Show()
       TradeSkillLinkNameButton:EnableMouse(false)
       if TradeSkillLinkNameButtonTitleText then
         TradeSkillLinkNameButtonTitleText:SetText("("..einstein..")")
	 TradeSkillLinkNameButton:SetWidth(TRADE_SKILL_LINKED_NAME_WIDTH or 120)
         TradeSkillLinkNameButtonTitleText:SetWidth(TRADE_SKILL_LINKED_NAME_WIDTH or 120)
	 TradeSkillLinkNameButtonTitleText:SetJustifyH("LEFT")
       end
     end
     if TradeSkillRankFrame and TradeSkillRankFrame:IsVisible() then
       TradeSkillRankFrame:Hide()
       debug(TradeSkillRankFrame:GetName()..":Hide()")
     end
     if TradeSkillFrameTitleText then
       TradeSkillFrameTitleText:SetText(pname)
     end
  else
    if TradeSkillLinkNameButton then
      TradeSkillLinkNameButton:EnableMouse(true)
    end
  end
end

-- fires when the name is updated late on a guild-opened trade skill ui
function addon:TRADE_SKILL_NAME_UPDATE()
  debug("TRADE_SKILL_NAME_UPDATE")
  addon:trade_skill_event()
end

function addon:TRADE_SKILL_UPDATE()
  -- this event fires very frequently, only update if save button status might have changed
  addon:TSLupdate()
end

local function rescan()
  addon:ReScan()
end

function addon:TRADE_SKILL_SHOW()
  debug("TRADE_SKILL_SHOW")
  addon:trade_skill_event()
  if not IsTradeSkillGuild() and not IsTradeSkillLinked() then -- self profession
    addon:ScheduleTimer(rescan, 1.5) -- make sure we see any patterns that were delayed loading
  end
end

function addon:trade_skill_event()
  addon.trade_skill_show = true
  addon:UpdateTrade()
  if TradeSkillLinkNameButton and not addon.tslnhook then
    --TradeSkillLinkNameButton:HookScript("OnUpdate", TSLNhide)
    addon.tslnhook = true
  end
  if TradeSkillRankFrame and not addon.tsrfhook then
    --TradeSkillRankFrame:HookScript("OnUpdate", TSLNhide)
    addon.tsrfhook = true
  end
  if TradeSkillFrame_SetSelection and TradeSkillLinkButton and not addon.tssshook then
    addon.tssshook = true
    hooksecurefunc("TradeSkillFrame_SetSelection", function() addon:TSLupdate() ; TSLNhide() end)
    TradeSkillLinkButton:HookScript("PreClick", TSLpreclick)
    TradeSkillLinkButton:HookScript("PostClick", TSLpostclick)
    _G.TradeSkillLinkDropDown_LinkPost = TradeSkillLinkDropDown_LinkPost
  end
  addon:TSLupdate()
  if UnitIsDead("player") and not TradeSkillFrame:IsVisible() 
     and not GnomeWorksFrame and not SkilletFrame then
    -- TradeSkillFrame refuses to open while dead and unreleased, which is retarded
    UIErrorsFrame:Clear()
    TradeSkillFrame:Show()
  end
end

function addon:SaveButton()
  local button = addon.savebutton
  if not button then
     button = CreateFrame("Button",addonName.."SaveButton",TradeSkillFrame,"UIPanelButtonTemplate")
     addon.savebutton = button
     button:SetText(L["Save"])
     if TradeSkillCancelButton then
        button:SetSize(TradeSkillCancelButton:GetSize())
     else
        button:SetSize(80,22)
     end
     button:SetMotionScriptsWhileDisabled(true)
     button:SetScript("OnMouseUp", function (self,btn,down) 
       debug("Save Button pushed")
       if (button:IsEnabled()) then
         addon:UpdateTrade(true) 
       elseif addon.savecname then
         ChatFrame_SendTell(addon.savecname)
       end
     end)
     button:SetScript("OnEnter", function (self) 
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
        if (button:IsEnabled()) then
          GameTooltip:SetText(L["Save this trade skill to ProfessionsVault"]);
	else
          GameTooltip:SetText(format(L["Send a whisper to %s to activate this button"],addon.savecname or ""));
	end
        GameTooltip:Show()
     end)
     button:SetScript("OnLeave", function (self) GameTooltip:Hide() end)
  end
  return button
end
function addon:SaveButtonShow()
      local button = addon:SaveButton()
      if Skillet and SkilletFrame then 
        button:SetParent(SkilletFrame)
	if SkilletPluginButton then
          button:SetPoint("TOPLEFT",SkilletPluginButton,"TOPRIGHT",1,0)
	  button:SetSize(SkilletPluginButton:GetSize())
        end 
      --[[ -- cant use this interface because skilet makes very narrow assumptions about how plugin buttons work
        local frame = Skillet:AddButtonToTradeskillWindow(button)
	Skillet:PluginButton_OnClick()
	button:SetScript("OnClick", function() end)
	]]
      elseif GnomeWorksFrame then
        button:SetParent(GnomeWorksFrame)
	button:SetPoint("BOTTOMLEFT",25,5)
      elseif MRTSkillFrame then
        button:SetParent(MRTSkillFrame)
	button:SetPoint("BOTTOMLEFT",165,4)
      else
        button:SetParent(TradeSkillFrame)
        button:SetPoint("BOTTOMLEFT",5,5)
      end
      button:Enable()
      button:Show()
      local lvl = (button:GetParent() and button:GetParent():GetFrameLevel()+1) or 1000
      button:SetFrameLevel(lvl)
end

function addon:UpdateTrade(force)
  addon:SaveButton():Hide()
  if IsTradeSkillGuild() then return end -- guild "view all" trade
  local pname, rank, rankmax = GetTradeSkillLine()
  local link = addon:normalize_link(GetTradeSkillListLink())
  local smelting
  if not link and nolinkProf[pname] then
    if (pname == GetSpellInfo(PID_MINE) or pname == GetSpellInfo(PID_SMELT)) then
      smelting = true
      if not addon.smeltwarning then
        chatMsg(format(L["Warning: Tradeskill %s has no link available to be used."]..
	               " "..L["This is a known Blizzard bug."],pname));
	addon.smeltwarning = true
      end
    else
      debug("UpdateTrade on non-mining nolinkProf")
      return
    end
  end
  local linked, cname = IsTradeSkillLinked()
  cname = addon:name_normalize(cname)
  local class, race  -- for linked only
  addon:update_guid_cache_fromlink(link)
  if not linked then
    cname = charName
    addon.lastTSL = nil
    debug("Clearing addon.lastTSL = nil")
    addon:TSLupdate()
    SetLDBProf(pname)
  elseif linked and not link then -- guild trade window
    debug("Guild Tradeskill: "..(cname or "NIL").." "..(pname or "NIL"))
    -- cname will occasionally arrive after the SHOW event
    if not pname or 
      (nolinkProf[pname] and not smelting) then
      force = false
    else
      if cname and cname == charName then -- disallow self-save
        force = false
      else
        addon:SaveButtonShow()
      end
      if not cname or not DB.guid_cache[cname] then
        addon:SaveButton():Disable()
	addon.savecname = cname
	force = false
      elseif not addon.lastTSL then
        addon.lastTSL = addon:normalize_link(addon:BuildGuildTradeLink())
	debug("Set addon.lastTSL = "..(addon.lastTSL or "nil").." ("..addon:hash(addon.lastTSL)..")")
	addon:TSLupdate()
      end
    end
    if force then
      link = addon.lastTSL
      if not link then 
        force = false
      else
        linked = true
        local guid = guid_normalize(DB.guid_cache[cname])
        if guid then
	  local _
          class,_,_,race,_,_ = GetPlayerInfoByGUID(guid)
        end
        race = race or UnitRace("player") -- fake it to get faction
      end
    end

    if not force then
      debug("Ignoring "..(cname or "NIL").."'s "..(pname or "NIL"));
      return
    end
  else -- linked trade window
    local spellid, guid, guidname, _
    -- GetTradeSkillListLink returns a bogus value for this case
    link = addon:normalize_link(addon.lastTSL, true)
    if link then
      spellid, guid = addon:link_parse(link)
    end
    if spellid and guid then 
      guid = guid_normalize(guid)
      class,_,_,race,_,guidname = GetPlayerInfoByGUID(guid)
      guidname = addon:name_normalize(guidname)
      local guidspell = GetSpellInfo(spellid)
      if guidname == charName or guidname ~= cname or guidspell ~= pname then force = false end
    else
      force = false 
    end
    if link and guidname and guidname ~= charName then
      addon:SaveButtonShow()
    end
    if not force then
      debug("Ignoring "..(cname or "NIL").."'s "..pname);
      return
    end
  end
  if (not pname or pname == "UNKNOWN") then
    return
  end
    if not allProf[pname] then
      chatMsg("ERROR: unrecognized profession: "..pname)
    end

    DB.chars[cname] = DB.chars[cname] or {}
    local dbc = DB.chars[cname]
    if linked then
      dbc.data = dbc.data or {}
      dbc.data.name = cname
      dbc.data.class = class
      dbc.data.faction = UnitFactionGroup(cname) -- may fail
      if not dbc.data.faction then
        if race == "Pandaren" then
	  dbc.data.faction = UnitFactionGroup("player") -- assume its the same as player
        else
          dbc.data.faction = race and ((allianceRace[race] and "Alliance") or "Horde")
        end
      end
      local level = UnitLevel(cname) -- may fail
      if level > 0 then
        dbc.data.level = level
      end
    end
  return addon:SaveLink(cname, pname, link, rank, rankmax, true)
end
function addon:SaveLink(cname, pname, link, rank, rankmax, doscan)
    local dbc = DB.chars[cname]

    local changestr = nil
    local diffstr = ""
    local rchange, schange, mchange = 0, 0, 0
    if not dbc[pname] then
      dbc[pname] = {}
      changestr = L["Saved %s's %s"]
      schange = rank
      mchange = rankmax
    else
      changestr = L["Updated %s's %s"]
      schange = rank - (dbc[pname].rank or 0)
      mchange = rankmax - (dbc[pname].rankmax or 0)
    end
    local scanpermitted = (not allProf[pname].nolink) or (allProf[pname].spellid == PID_MINE)
    if doscan and scanpermitted then 
      local cnt = addon:pinfo_skill_populate(dbc[pname])
      if cnt ~= 0 then
        diffstr = cnt.." "..L["recipes"]
      end
      rchange = cnt
    end
    if schange ~= 0 then
      diffstr = diffstr..((#diffstr > 0 and ", ") or "")..schange.." "..L["skill points"]
    end
    dbc[pname].link = link
    dbc[pname].rank = rank
    dbc[pname].rankmax = rankmax
    if doscan or not scanpermitted then
      dbc[pname].lastupdate = time()
    end
    local _, clientbuild,_,uiversion = GetBuildInfo()
    dbc[pname].clientbuild = (tonumber(clientbuild) or 0)
    dbc[pname].uiversion = (tonumber(uiversion) or 0)
    debug("Processed "..cname.."'s "..pname);
    if #diffstr > 0 then
      changestr = changestr.." ("..diffstr..")"
      if settings.updatemsg then
        chatMsg(format(changestr,cname,pname));
      end
      addon:RefreshWindow()
    end
    addon:RefreshTooltips()
    return rchange, schange, mchange, pname
end

function addon:pinfo_skill_count(pinfo)
  local list = pinfo.spellids
  if not list then return 0 end
  local count = 0
  for _ in pairs(list) do count = count + 1 end
  return count
end

-- accepts a spellid or list of spellids and returns true if pinfo contains any
function addon:pinfo_skill_known(pinfo, spellid)
  local list = pinfo.spellids
  if not list then return false end
  if type(spellid) == "table" then
    for _,id in ipairs(spellid) do
      if list[id] then return true end
    end
    return false
  else
    return list[spellid] and true
  end
end

-- returns true if pinfo is missing the specialization required to learn spellid
function addon:pinfo_missing_spec(pinfo, spellid)
  local list = pinfo.spellids
  if not list then return false end
  local spec
  if type(spellid) == "table" then
    for _,id in ipairs(spellid) do
      spec = vars.spec_spells[id]
      if spec then break end
    end
  else
    spec = vars.spec_spells[spellid]
  end
  if not spec then return false end -- no spec required for spellid
  for id, ss in pairs(vars.spec_spells) do
    if list[id] and ss == spec then
      return false -- have the required spec
    end
  end
  return true -- missing the required spec
end

function addon:pinfo_skill_populate(pinfo)
  local rchange = 0
  addon:expandAllTradeSkills()
  if GetNumTradeSkills() < 3 then
    debug("pinfo_skill_populate failed: "..table.concat({tostringall(GetTradeSkillInfo(1))},","))
    return 0
  end
  local list = pinfo.spellids or {}
  pinfo.spellids = list
  for id,_ in pairs(list) do
    list[id] = false
  end
  for i = 1,GetNumTradeSkills() do
    local sname, stype = GetTradeSkillInfo(i)
    if stype ~= "header" and stype ~= "subheader" then
      local link = GetTradeSkillRecipeLink(i)
      local id = link and link:match("\124Henchant:(%d+)\124")
      if not id then
        debug("Unrecognized trade skill: "..i.." "..tostring(sname)..tostring(stype)..tostring(link))
      else
        id = tonumber(id)
        if list[id] == nil then 
	  rchange = rchange + 1
	end
	list[id] = true
      end
    end
  end
  for id,_ in pairs(list) do
    if not list[id] then -- lost one
      debug("Suppressed Deletion of "..tostring(GetSpellLink(id)))
      if true then -- probably just missing due to update lag, don't actually delete it
        list[id] = true
      else
        rchange = rchange - 1
        list[id] = nil
      end
    end
  end
  return rchange
end

-- traversal function for character table
local cnext_sorted_names = {}
local function cnext(t,i)
   -- return them in reverse order
   if #cnext_sorted_names == 0 then 
     return nil
   else
      local n = cnext_sorted_names[#cnext_sorted_names]
      table.remove(cnext_sorted_names, #cnext_sorted_names)
      return n, t[n]
   end
end
local function cpairs(t)
  cnext_sorted_names = {}
  for n,_ in pairs(t) do
    table.insert(cnext_sorted_names, n)
  end
  table.sort(cnext_sorted_names, function (a,b) return b == charName or (a ~= charName and a > b) end)
  --myprint(cnext_sorted_names)
  return cnext, t, nil
end

function addon:Dump()
  for cname,dbc in cpairs(DB.chars) do
    local data = dbc.data or {}
    chatMsg("-=- "..cname.." "..(data.level or "").." "..
            ((data.faction and LFaction[data.faction]) or "")..
	    " "..(data.class or "").." -=-")
    for _,pname in ipairs(allProfSorted) do
      if (dbc[pname]) then
        local pinfo = dbc[pname]
        local rank = pinfo.rank or "??"
        local rankmax = pinfo.rankmax or "??"
	local link = pinfo.link or "["..pname.."]"
        chatMsg(" "..link.."   ("..rank.."/"..rankmax..")")
      end
    end
  end
end

local function OnClose(widget)
  debug("OnClose")
  widget.frame:SetFrameStrata(widget.acegui_strata)
  addon:clearEscapeHandler(widget)
  addon:decustomizeLayout(widget)
  if settings.locked then
    addon:unlockWidget(addon.gui)
  end
  AceGUI:Release(widget)
  addon.gui = nil
end

local function cleanlink(link)
  local res = string.match(link,"|H(trade:[^|]+)|h")
  if not res then
    res = link
  end
  debug("cleanlink("..link..") => ".. res)
  return res
end
function addon:cleanlink(link)
  return cleanlink(link)
end

function addon:dirtylink(cl)
  local ret = cleanlink(cl)
  ret = "\124cffffd000\124H"..ret.."\124h[Foo]\124h\124r"
  ret = addon:normalize_link(ret)
  return ret
end

function addon:ActivateLink(cname,pname,link,nodropdown)
  if cname == allexpand or pname == allexpand then return end
  debug("ActivateLink: "..cname.." "..(pname or ""))
  if GetMouseButtonClicked() == "RightButton" and not nodropdown then
     addon:ShowDropdown(cname, pname)
  else
  if pname == GetSpellInfo(PID_MINE) then
     pname = GetSpellInfo(PID_SMELT) 
  end
  if IsShiftKeyDown() then -- link to chat
    local activeEditBox = ChatEdit_GetActiveWindow();

    if cname and not pname then -- all we have is a toon name
      if cname == einstein then return end
      if activeEditBox then
        ChatEdit_InsertLink(cname)
      else
        ChatFrame_SendTell(cname)
      end
      return
    end

    if pname and (not link or nolinkProf[pname]) then
        --chatMsg(format(L["Warning: Tradeskill %s has no link available to be used."].." "..
	--               L["This is a known Blizzard bug."],pname));
        link = addon:spellLink(pname)
    end
    if link then 
       if activeEditBox then
          ChatEdit_InsertLink(link) 
       else
          ChatFrame_OpenChat(link, DEFAULT_CHAT_FRAME)
       end
    end
  else -- open tradeskill UI
    if not pname then
      return
    elseif cname == charName then
      SetLDBProf(pname)
      if not nocastProf[pname] then
        debug("CastSpellByName("..pname..")")
        CastSpellByName(pname)
      end
    else
      local name, rank, rankmax = GetTradeSkillLine()
      local linked, linkedName = IsTradeSkillLinked()
      linkedName = addon:name_normalize(linkedName)
      if linked and (linkedName == cname or (linkedName == charName and cname == einstein))
         and name and name == pname then -- already open so close it
        CloseTradeSkill()
      else
       if useguildhack and cname and pname and IsInGuild() then
         local barename, realm = select(2,addon:name_normalize(cname))
         local data = DB.chars[cname] and DB.chars[cname].data
	 local magic = allProf[pname].magic
	 if magic and data and 
	    data.faction == UnitFactionGroup("player") and
	    realm == GetRealmName():gsub("%s","") then
	    GetGuildMemberRecipes(barename, magic)
	 end
       end
       if nolinkProf[pname] then
        if not nocastProf[pname] then
          chatMsg(format(L["Warning: Tradeskill %s has no link available to be used."]..L["This is a known Blizzard bug."],pname));
        end
       else -- open it (undocumented API - sshhh)
	addon.lastTSL = link
	addon.trade_skill_show = false
        SetItemRef(cleanlink(link),link,"LeftButton",ChatFrame1)
	addon:ScheduleTimer(StubCheck, 3)
       end
      end
    end
  end
  if settings.autoclose and addon.gui then
    addon.gui:Hide()
  end
  end
end

function addon:ScanProfessions()
  local scantime = time()
  debug("ScanProfessions")
  CloseTradeSkill()
  addon:RefreshChar()
  local gotone = false
  for i=1,2 do -- two-pass to improve the chances of catching delayed-load patterns
   for p in pairs(allProf) do
    if (not allProf[p].nolink) or (p == GetSpellInfo(PID_SMELT)) then
      CastSpellByName(p) 
      CloseTradeSkill()
      if Skillet and Skillet.CancelAllTimers then -- Skillet window is opened on a delay
         Skillet:CancelAllTimers()
      end
      if DBc[p] and DBc[p].lastupdate >= scantime then
        gotone = true
      end
    end
   end
   addon:ScanSecondary()
  end
  CloseTradeSkill()
  if gotone then
    chatMsg(L["Profession Scan complete!"])
  else
    chatMsg(L["No professions detected! (try again later?)"])
  end
  DBc.data.scanned = true 
  addon:RefreshWindow()
end

function addon:ScanSecondary()
  debug("addon:ScanSecondary()")
  local gotr,gots,gotm,gotprof = 0,0,0,nil
  --local prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions()
  local myprofids = { GetProfessions() }
  for _,profid in pairs(myprofids) do
    local pname, texture, rank, rankmax, numSpells, spelloffset, skillLine, rankModifier = GetProfessionInfo(profid)
    debug(pname.." "..rank.."/"..rankmax.." "..rankModifier) 
    local pinfo = allProf[pname]
    local link
    if pinfo and not pinfo.nolink then -- tradeskill profession
      local _,rawlink = GetSpellLink(pname)
      link = addon:normalize_link(rawlink)
    elseif pinfo then -- non-tradeskill profession
      link = nil
    end
    if pinfo then
      local rchange, schange, mchange = addon:SaveLink(charName, pname, link, rank, rankmax, false)
      gotr = gotr + rchange 
      gots = gots + schange 
      gotm = gotm + mchange 
      if rchange > 0 or schange > 0 or mchange > 0 then
        gotprof = pname
      end
    end
  end
  addon:checkLearn()
  return gotr, gots, gotm, gotprof
end

function addon:ReScan()
  debug("addon:ReScan()")
  local rchange, schange, mchange, pname = addon:ScanSecondary()
  local rc, sc, mc, pn
  if GetTradeSkillLine() ~= "UNKNOWN" and 
     not IsTradeSkillGuild() and not IsTradeSkillLinked() then -- our skill window is open, try that
    rc, sc, mc, pn = addon:UpdateTrade()
  end
  rchange = (rchange or 0) + (rc or 0)
  schange = (schange or 0) + (sc or 0)
  mchange = (mchange or 0) + (mc or 0)
  pname = pname or pn
  local gotone = (rchange > 0) or (schange > 0) or (mchange > 0)
  return gotone, rchange, schange, mchange, pname
end

local function ProfTooltip(frame, cname, pname, pinfo)
   if not frame then
     debug("Missing frame on ProfTooltip")
     return
   end
   local ccname = coloredcname(cname,nil,true)
   addon.gui:SetStatusText(ccname.." / "..pname)
   if not settings.tooltips then 
     return
   end
   local linkprof = not nolinkProf[pname]
   --GameTooltip:SetOwner(frame, "ANCHOR_CURSOR"); 
   GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT"); 
   local caveat = ""
   if cname == einstein then
     local txt = pname
     if linkprof then
       txt = txt.." ("..einstein..")"
     end
     GameTooltip:SetText(txt); 
     caveat = "<= "
   else
     GameTooltip:SetText(ccname .." ".. pname.." ("..pinfo.rank.." / "..pinfo.rankmax..")"); 
   end
   if (linkprof and pinfo and pinfo.link) then
       local cnt = addon:pinfo_skill_count(pinfo)
       if cnt and cnt > 0 then
         GameTooltip:AddLine(caveat..cnt.." "..L["recipes"])
       end
   end
   local text =  chardatastr(cname)
   if #text then
     GameTooltip:AddLine(text)
   end
   if pinfo and pinfo.lastupdate then
     GameTooltip:AddLine("|cff00ff00"..L["Last Scan"]..": "..date(nil,pinfo.lastupdate).."|r")
   end
   if linkprof then
     GameTooltip:AddLine("|cffff8040"..L["Left Click"].."|r "..L["to open"])
     GameTooltip:AddLine("|cffff8040"..L["Shift Left Click"].."|r "..L["to link in chat"])
   end
   GameTooltip:AddLine("|cffff8040"..L["Right Click"].."|r "..L["for menu"])
   GameTooltip:Show() 
end

local function ProfIcon(cname,pname,pinfo,label,img)
  local icon = AceGUI:Create("Icon")
  if img and string.find(img,"BattlefieldFrame") then
    icon:SetImage(img or allProf[pname].icon, 0.2,0.8,0.2,0.8)
  else
    icon:SetImage(img or allProf[pname].icon)
  end
  icon.frame:RegisterForClicks("AnyDown") -- cheat to get right-clicks too
  local events = {
    ["OnClick"] = function(button) addon:ActivateLink(cname,pname,pinfo and pinfo.link) end,
    ["OnEnter"] = function(button) ProfTooltip(button.frame, cname, pname, pinfo) end,
    ["OnLeave"] = function(button) addon.gui:SetStatusText(""); GameTooltip:Hide() end,
    }
  for evt, hnd in pairs(events) do
    icon:SetCallback(evt, hnd)
  end
  if label then -- must use Icon or Button to get OnClick hardware event for CastSpellByName
    local grp = AceGUI:Create("SimpleGroup")
    --grp:SetFullWidth(true)
    grp:SetWidth(300)
    grp:SetLayout("Flow")
    grp:SetHeight(24)
    icon:SetImageSize(18,18)
    icon:SetHeight(24)
    icon:SetWidth(24)
    grp:AddChild(icon)
    local text = AceGUI:Create("Icon")
    text:SetImageSize(150,24)
    text:SetWidth(150)
    text:SetLabel(label)
    text.label:ClearAllPoints() -- hack
    text.label:SetPoint("BOTTOMLEFT") -- hack
    text.label:SetJustifyH("LEFT") -- hack
    text:SetHeight(24)
    --text.frame:GetHighlightTexture():SetAllPoints(text.label)
    text.frame:RegisterForClicks("AnyDown") -- cheat to get right-clicks too
    for evt, hnd in pairs(events) do
      text:SetCallback(evt, hnd)
    end
    grp:AddChild(text)
    return grp
  else
    icon:SetWidth(48)
    icon:SetHeight(48)
    icon:SetImageSize(36,36)
    return icon
  end
end

local function MakeButton(text, fn) 
  local button = AceGUI:Create("Button")
  button:SetText(text)
  --local len = 7.5*addon:displaylen(text)+40
  local len = button.frame:GetTextWidth() + 50
  button:SetWidth(len)
  button:SetCallback("OnClick",fn)
  return button
end

local function parsePath(path)
  local cname, pname = ("\001"):split(path)
  if settings.grpbyprof then
    return pname, cname
  else
    return cname, pname
  end
end

local function OnSelect(widget, event, value)
  if value == allexpand then
    local newval = not addon.tree.status.groups[allexpand]
    addon.tree.status.selected = nil
    if settings.treepath then
      activateontree = false
      addon.tree:SelectByPath((newval and unpack(settings.treepath)) or settings.treepath[1])
      activateontree = true
    end
    local grps = addon.tree.status.groups
    local tree = addon.tree.tree
    if grps and tree then
      for _,t in pairs(tree) do
        if t.value == allexpand then
	  t.icon = (newval and allexpandminus) or allexpandplus
	end
        grps[t.value] = newval
      end
      addon.tree:RefreshTree()
    end
    return
  end
  local cname, pname = parsePath(value)
  local pathtxt = strjoin(" / ",("\001"):split(value))
  local hidone = false
  settings.treepath = { ("\001"):split(value) }
  addon.gui:SetStatusText(pathtxt)
  debug("OnSelect: "..pathtxt)

    widget:ReleaseChildren()
    widget:SetLayout("List") 
    -- body for a character

    local scroller = AceGUI:Create("ScrollFrame")
    scroller:SetLayout("List")
    scroller:SetHeight(0) -- prevents a nasty graphical bug, dont ask me why
    scroller:SetFullHeight(true)
    scroller:SetFullWidth(true)

  if settings.grpbyprof then
    --local grp = AceGUI:Create("SimpleGroup")
    --grp:SetLayout("List")
    --grp:SetWidth(250)
    --grp:SetFullWidth(true)
    local label = AceGUI:Create("InteractiveLabel")
    label:SetFullWidth(true)
    --label:SetWidth(240)
    label:SetImage(allProf[pname].icon)
    label:SetImageSize(32,32)
    label:SetFontObject(headerfont)
    label:SetText(pname.."\n")
    if useeinstein then
      local einfo = DB.chars[einstein][pname]
      label:SetCallback("OnClick", function() addon:ActivateLink(einstein,pname,einfo and einfo.link) end)
      label:SetCallback("OnEnter", function(button) ProfTooltip(button.frame, einstein, pname, einfo) end)
      label:SetCallback("OnLeave", function(button) addon.gui:SetStatusText(""); GameTooltip:Hide() end)
    end
    label:SetHighlight(1,1,1,0.3)
    --grp:AddChild(label)
    --widget:AddChild(grp)
    widget:AddChild(label)
    local body = AceGUI:Create("SimpleGroup")
    body:SetLayout("List")
    body:SetFullWidth(true)
    for cname,dbc in cpairs(DB.chars) do
      local pinfo = dbc[pname]
      if (pinfo and cname ~= einstein) then
        if addon:isHidden(cname,pname) then hidone = true
	else
          local label = coloredcname(cname,settings.colorwinnames) ..
                  (cname == einstein and "" or " ("..pinfo.rank.." / "..pinfo.rankmax..")")
          body:AddChild(ProfIcon(cname,pname,pinfo,label,charicon(cname)))
	end
      end
    end
    scroller:AddChild(body)
  else -- grouped by character
    local dbc = DB.chars[cname]
    if not dbc then -- might have stale character data with a saved treepath
      debug("CreateWindow missing char, bailing out")
      return 
    end
    local label = AceGUI:Create("Label")
    label:SetFullWidth(true)
    label:SetFontObject(headerfont)
    if cname == einstein then
      label:SetText(einstein.."\n")
    else
      label:SetText(format(L["%s's Professions"],coloredcname(cname,nil,true)).."\n")
    end
    widget:AddChild(label)
    if cname == charName and (not dbc.data or not dbc.data.scanned) then
      widget:AddChild(MakeButton(L["Scan My Professions"], function () addon:ScanProfessions(); end))
      return
    end
    --[[
    local altcheck = AceGUI:Create("CheckBox")
    altcheck:SetValue(dbc.data.alt == true)
    altcheck:SetType("checkbox")
    altcheck:SetDescription(L["Is an alt"])
    altcheck:SetCallback("OnValueChanged", function (val) dbc.data.alt = val end)
    widget:AddChild(altcheck)]]
    for i=1,2 do
      local label = AceGUI:Create("Label")
      label:SetText(i==1 and L["Primary"]..":\n" or L["Secondary"]..":\n")
      label:SetFontObject(bodyfont)
      scroller:AddChild(label)
      local body = AceGUI:Create("SimpleGroup")
      body:SetLayout("Flow")
      body:SetFullWidth(true)
      --body:SetAutoAdjustHeight(true)
      for pname in pairs((i==1 and primaryProf) or (i==2 and secondaryProf)) do
        if (dbc[pname]) then
	 if addon:isHidden(cname,pname) then hidone = true
	 else
	  local pinfo = dbc[pname]
          body:AddChild(ProfIcon(cname,pname,pinfo))
	 end
	end
      end
      scroller:AddChild(body)
    end
  end
    widget:AddChild(scroller)
    if hidone then
      widget:AddChild(MakeButton(L["Unhide Entries"], function () addon:unHide(); end))
    end
end
----------------------------------------------------------------------------------
-- AceGUI hacks --

-- hack-around for the fact AceGUI:Frame is too stupid to resize its title area to fit the text
function addon:fixTitle() 
  local tit = nil
  for _,v in pairs({ addon.gui.frame:GetRegions() }) do 
     local w = v:GetWidth()
     if w > 90 and w < 110 then 
        v:SetWidth(200) 
	tit = v
	break;
     end 
  end
 if false then 
  -- adjust the drag handle - this part should work but doesnt
  for _,v in pairs({ addon.gui.frame:GetChildren() }) do 
     local  w = v:GetWidth()
     local  h = v:GetHeight()
     if w > 95 and w < 105 and h > 35 and h < 45 then 
        v:SetAllPoints(tit) 
        v:SetWidth(400) 
     end 
  end
 end
end 

-- hack-around for the fact AceGUI doesnt allow frame locking
function addon:lockWidget(widget) 
  widget.lockinfo = {}
  for _,v in pairs({ widget.frame:GetChildren() }) do 
     local md = v:GetScript("OnMouseDown")
     local mu = v:GetScript("OnMouseUp")
     if md and mu then
       table.insert(widget.lockinfo,{frame=v,OnMouseDown=md,OnMouseUp=mu})
       v:SetScript("OnMouseDown",function()end)
       v:SetScript("OnMouseUp",function()end)
     end
  end
end
function addon:unlockWidget(widget) 
  if widget.lockinfo then
    for _,li in pairs(widget.lockinfo) do 
      li.frame:SetScript("OnMouseDown",li.OnMouseDown)
      li.frame:SetScript("OnMouseUp",li.OnMouseUp)
    end
    widget.lockinfo = nil
  end
end

-- hack to hook the escape key for closing the window
function addon:setEscapeHandler(widget, fn)
  widget.origOnKeyDown = widget.frame:GetScript("OnKeyDown")
  widget.frame:SetScript("OnKeyDown", function(self,key) 
        if key == "ESCAPE" then 
	   fn()
	elseif widget.origOnKeyDown then
	   widget.origOnKeyDown(self,key)
	end 
     end)
  widget.frame:EnableKeyboard(true)
  widget.frame:SetPropagateKeyboardInput(true)
end
function addon:clearEscapeHandler(widget)
  widget.frame:SetScript("OnKeyDown", widget.origOnKeyDown)
  widget.frame:EnableKeyboard(false)
  widget.frame:SetPropagateKeyboardInput(false)
end
-- allow custom layout of children
function addon:customizeLayout(widget, fn, destructor)
  widget.origLayoutFinished = widget.LayoutFinished
  widget.customizationDestructor = destructor
  widget.LayoutFinished = function () if widget.origLayoutFinished then widget.origLayoutFinished() end ; fn(); end
end
function addon:decustomizeLayout(widget)
  if widget.LayoutFinished then
    widget.LayoutFinished = widget.origLayoutFinished
    widget.origLayoutFinished = nil
    if widget.customizationDestructor then
       widget.customizationDestructor()
       widget.customizationDestructor = nil
    end
  end
end
----------------------------------------------------------------------------------
function addon:MakeHeaderButton(img, imgH, clickfn)
  local button = AceGUI:Create("InteractiveLabel")

  button:SetImage(img)
  button:SetHighlight(imgH)
  button:SetImageSize(32,32)
  button:SetWidth(32)
  button:SetHeight(32)

  button:SetCallback("OnClick", clickfn)
  --button.frame:SetFrameStrata("MEDIUM")
  button.frame:SetParent(addon.gui.frame)
  button.frame:SetFrameLevel(1000)
  button.frame:Show()

  return button
end

local icon_close = "Interface\\Buttons\\UI-Panel-MinimizeButton-Up"
local icon_closeH = "Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight"
local icon_unlocked  = "Interface\\AddOns\\ProfessionsVault\\images\\LockButton-Unlocked"
local icon_locked  =   "Interface\\AddOns\\ProfessionsVault\\images\\LockButton-Locked"
function addon:ToggleLock(button)
  if settings.locked then
    debug("frame unlocked");
    settings.locked = false
    addon:unlockWidget(addon.gui)
    button:SetImage(icon_unlocked)
    button:SetHighlight(icon_closeH)
  else
    debug("frame locked");
    settings.locked = true
    addon:lockWidget(addon.gui)
    button:SetImage(icon_locked)
    button:SetHighlight(icon_closeH)
  end
end

function addon:CreateWindow()
  if addon.gui then
    return
  end
  addon:ScanSecondary()
  local f = AceGUI:Create("Frame")
  f.acegui_strata = f.frame:GetFrameStrata()
  f.frame:SetFrameStrata("MEDIUM")
  f.frame:Raise()
  f.content:SetFrameStrata("MEDIUM")
  f.content:Raise()
  addon.gui = f
  f:SetTitle(L["ProfessionsVault"].." "..ProfessionsVault.version)
  addon:fixTitle()
  f:SetCallback("OnClose", OnClose)
  f:SetLayout("Flow")
  f.frame:SetClampedToScreen(true)
  settings.pos = settings.pos or {}
  f:SetStatusTable(settings.pos)
  f:SetAutoAdjustHeight(true)

  --f:AddChild(MakeButton(L["Profession Pane"], function () ToggleSpellBook(BOOKTYPE_PROFESSION); end)) 
  local grp = AceGUI:Create("Dropdown")
  grp:SetMultiselect(false)
  grp:SetLabel(L["Group By"])
  grp:SetWidth(6*math.max(string.len(L["Character"]),string.len(L["Profession"]))+50)
  grp:SetList({
    [0] = L["Character"],
    [1] = L["Profession"],
  })
  grp:SetValue((settings.grpbyprof and 1) or 0)
  grp:SetCallback("OnValueChanged", function(w,evt,key) 
     settings.grpbyprof = (tostring(key) == "1"); 
     debug("settings.grpbyprof = "..key.." => "..((settings.grpbyprof and "true") or "false"))
     if settings.treepath then
       local a, b = unpack(settings.treepath)
       if a and b then
         settings.treepath = { b, a }
       else
         settings.treepath = nil
       end
     end
     addon:RefreshWindow() 
  end)
  f:AddChild(grp)
  f:AddChild(MakeButton(L["Scan My Professions"], function () addon:ScanProfessions(); end))
  f:AddChild(MakeButton(L["Config"], function () addon:Config(); end))
  f:AddChild(MakeButton(L["Scan Auctions"], function () addon:ScanAH(); end))

  local closeButton = addon:MakeHeaderButton(icon_close, icon_closeH,
                          function() addon:ToggleWindow() end)
  --f:AddChild(closeButton)
  local lockButton = addon:MakeHeaderButton(icon_unlocked, icon_closeH,
                          function(self) addon:ToggleLock(self) end)
  --f:AddChild(lockButton)
  addon:customizeLayout(f, function() 
     closeButton.frame:ClearAllPoints(); 
     closeButton:SetPoint("TOPRIGHT",f.frame,-5,-5)
     lockButton.frame:ClearAllPoints(); 
     lockButton:SetPoint("TOPRIGHT",closeButton.frame,"TOPLEFT",8,0)
  end, function() AceGUI:Release(closeButton); AceGUI:Release(lockButton) end)

  if settings.locked then
    settings.locked = false
    addon:ToggleLock(lockButton)
  end

  addon:setEscapeHandler(f, function() addon:ToggleWindow() end)

  local treedata = {}
  local expandicon = allexpandplus
  if settings.treestatus and settings.treestatus.groups then
    if settings.treestatus.groups[allexpand] then expandicon = allexpandminus end
  end
  table.insert(treedata, { value = allexpand, text = "\124cff"..charcolor("system")..ALL.."\124r",
                           visible = true, disabled = false, children = nil,
			   icon = expandicon })
 if settings.grpbyprof then -- group by profession
  for _,pname in ipairs(allProfSorted) do
   if not addon:isHidden(nil,pname) and allProf[pname].spellid ~= PID_SMELT then
    local pt = { value = pname, text = pname, visible = true, disabled = false,
                 icon = allProf[pname].icon,
                 children = {} }
    for cname,dbc in cpairs(DB.chars) do
      local pinfo = dbc[pname]
      if (cname ~= einstein and pinfo and not addon:isHidden(cname,pname)) then
        local img = charicon(cname)
	local coords
	if img and string.find(img,"BattlefieldFrame") then
	  coords = { 0.2,0.8,0.2,0.8 }
	end
        table.insert(pt.children, { value = cname, 
	         text = coloredcname(cname,settings.colorwinnames) .. 
		 (cname == einstein and "" or " ("..pinfo.rank.." / "..pinfo.rankmax..")"), 
	         visible = true, disabled = false,
                 icon = img, iconCoords = coords, children = nil })
      end
    end
    table.insert(treedata,pt)
   end
  end
 else -- group by character
  for cname,dbc in cpairs(DB.chars) do
    local img = charicon(cname)
    local coords
    if img and string.find(img,"BattlefieldFrame") then
       coords = { 0.2,0.8,0.2,0.8 }
    end
    local ct = { value = cname, text = coloredcname(cname,settings.colorwinnames), visible = true, disabled = false,
                 icon = img, iconCoords = coords, children = {} }
    for _,pname in ipairs(allProfSorted) do
      if (dbc[pname] and not addon:isHidden(cname,pname)) then
        local pinfo = dbc[pname]
        table.insert(ct.children, { value = pname, icon = allProf[pname].icon, visible = true,
                                      text = pname..
				      (cname == einstein and " ("..einstein..")" or
				      " ("..pinfo.rank.." / "..pinfo.rankmax..")") })
      end
    end
    if #ct.children > 0 or cname == charName then 
      table.insert(treedata, ct)
    end
  end
 end
  if false and settings.debug and myprint then
    myprint(treedata)
  end

  local tree = AceGUI:Create("TreeGroup")
  f:AddChild(tree)
  tree:SetAutoAdjustHeight(false)
  tree:SetFullWidth(true)
  tree:SetFullHeight(true)
  addon.tree = tree
  tree:SetTree(treedata)
  tree:SetCallback("OnGroupSelected", OnSelect)
  tree:SetCallback("OnClick", function (widget, event, path,...)
        local cname, pname = parsePath(path)
  	if activateontree then
	  if not cname then
	    if useeinstein then 
	      cname = einstein
	    else
	      return
	    end
	  end
	  if cname == allexpand or pname == allexpand then
	    pname = nil
	  end
  	  addon:ActivateLink(cname,pname,pname and DB.chars[cname][pname] and DB.chars[cname][pname].link)
  	end  
  end)
  tree:SetCallback("OnButtonEnter", function(button,event,path,frame) 
                   if path == allexpand then return end
                   local cname, pname = parsePath(path)
		   addon.gui:SetStatusText(cname)
		   if pname and cname then
                     ProfTooltip(frame, cname, pname, DB.chars[cname][pname]) 
		   elseif pname and settings.tooltips and useeinstein then -- group by prof header
                     ProfTooltip(frame, einstein, pname, DB.chars[einstein][pname]) 
		   elseif cname and settings.tooltips then -- group by char header
                     GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT");
                     GameTooltip:SetText(coloredcname(cname,nil,true));
                     local text =  chardatastr(cname)
                     if #text then
                       GameTooltip:AddLine(text)
                     end
                     GameTooltip:AddLine("|cffff8040"..L["Right Click"].."|r "..L["for menu"])
                     GameTooltip:Show()
		   end
		   end)
  tree:SetCallback("OnButtonLeave", function() GameTooltip:Hide() end)
  tree:EnableButtonTooltips(false)

  settings.treestatus = settings.treestatus or {}
  tree:SetStatusTable(settings.treestatus)
  if settings.treepath then
    activateontree = false
    tree:SelectByPath(unpack(settings.treepath))
    activateontree = true
  end
end

function addon:ToggleWindow()
  debug("ToggleWindow")

  if addon.gui then
    HideDropDownMenu(1)
    addon.gui:Hide()
  else
    addon:CreateWindow()
  end
end

-- refresh the contents of the window, optionally performing an action while hidden
function addon:RefreshWindow(actionfunc)
  local show
  if addon.gui then
    addon.gui:Hide()
    show = true
  end

  if actionfunc then
    actionfunc()
  end

  if show then
    addon:CreateWindow()
  end
end

function addon:Reset() 
  if addon.gui then
    addon:ToggleWindow()
  end
  StaticPopup_Show("PROFESSIONSVAULT_RESET")
end

local function ResetConfirmed()
  addon.db:ResetDB() -- triggers RefreshConfig
  addon:AddEinstein()
  chatMsg(L["Reset complete."]); 
end

StaticPopupDialogs["PROFESSIONSVAULT_RESET"] = {
  preferredIndex = 3, -- reduce the chance of UI taint
  text = L["Are you sure you want to reset the ProfessionsVault database and wipe all data?"],
  button1 = OKAY,
  button2 = CANCEL,
  OnAccept = ResetConfirmed,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  enterClicksFirstButton = false,
  showAlert = true,
}

function addon:Scan() 
  local text = L["Would you like to scan your professions into ProfessionsVault?"]
  if addon.scannote then
    text = text.."\n\n"..addon.scannote
    addon.scannote = nil
  end
  StaticPopupDialogs["PROFESSIONSVAULT_SCAN"].text = text
  StaticPopup_Show("PROFESSIONSVAULT_SCAN")
end

StaticPopupDialogs["PROFESSIONSVAULT_SCAN"] = {
  preferredIndex = 3, -- reduce the chance of UI taint
  text = "",
  button1 = OKAY,
  button2 = CANCEL,
  OnAccept = function () addon:ScanProfessions() end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  enterClicksFirstButton = false, -- doesnt trigger HW event >.<
}

function addon:Config() 
  if optionsFrame then
    if ( InterfaceOptionsFrame:IsShown() ) then
      InterfaceOptionsFrame:Hide();
    else
      InterfaceOptionsFrame_OpenToCategory(optionsFrame)
    end
  end
end

function addon:unHide()
  if unhideFrame then
      if ( InterfaceOptionsFrame:IsShown() ) then
        InterfaceOptionsFrame:Hide();
      end
      InterfaceOptionsFrame_OpenToCategory(unhideFrame)
  end
end
----------------------------------------------------------------------------
-- Testing code
----------------------------------------------------------------------------
function addon:spellLink(pname)
  local spellid = pname and allProf[pname] and allProf[pname].spellid
  if not spellid then return "" 
  else
    return "\124cff71d5ff\124Hspell:"..spellid.."\124h["..pname.."]\124h\124r"
  end
end

function addon:CleanDatabase() -- remove links that are dead due to a patch
  local clientversion, clientbuild = GetBuildInfo()
  clientbuild = tonumber(clientbuild) or 0
  local DB = self.db.global
  local oldclientbuild = DB.clientbuild or 13329 -- for old versions
  DB.clientversion = clientversion
  DB.clientbuild = clientbuild
  --print(oldclientbuild.." "..clientbuild)
  local removed = 0
  for pname,profinfo in pairs(allProf) do
    for cname,dbc in pairs(DB.chars) do
      local pinfo = dbc[pname]
      if (pinfo and cname ~= einstein) then
        local link = pinfo.link
	local oldclientbuild = pinfo.clientbuild or oldclientbuild
        if 
	  -- 5.4.0: all trade links reformatted
	  (oldclientbuild < link3build and clientbuild >= link3build)

	  then
          dbc[pname] = nil
	  removed = removed + 1
          if (dbc.data.scanned) then dbc.data.scanned = false end
	end
      end
    end
  end
  if removed > 0 then
    chatMsg(removed.." "..L["Outdated profession links have been removed."])
  end
end

function addon:AddEinstein() -- a toon that knows all the patterns
  if not useeinstein then 
    DB.chars[einstein] = nil
    return 
  end
  DB.chars[einstein] = {}
  local DBe = DB.chars[einstein]
  DBe.data = {}
  DBe.data.name = einstein
  --DBe.data.faction = UnitFactionGroup("player")
  --DBe.data.level = 1
  --DBe.data.class = UnitClass("player")
  DBe.data.scanned = true
  DBe.data.alt = false

  for _,pname in ipairs(allProfSorted) do
    if (allProf[pname].patlen > 1) then
      DBe[pname] = {
	rank = gamerankmax,
	rankmax = gamerankmax,
	-- not linkable with fake text, server bans it
	--link = addon:fakeLink(pname.." ("..einstein..")", nil, allProf[pname].spellid, 0, 0, allProf[pname].patlen)
	link = addon:fakeLink(pname, nil, nil, 0, 0, nil)
      }
    end
  end

end
----------------------------------------------------------------------------
-- Link manipulation
----------------------------------------------------------------------------
local function table_invert(t)
  local ret = {}
  for k,v in pairs(t) do
    if ret[v] then
      debug(format("Duplicate value %s in table_invert",v))
    end
    ret[v] = k
  end
  return ret
end
function addon:table_invert(...) return table_invert(...) end

-- conjunctions used in transmute names that need to be normalized away
local xmute_conjunctions = {}
local xmute_token = strtrim(string.lower(L["Transmute"]))
if locale == "enUS" then 
  xmute_conjunctions = { " to " }
elseif locale == "deDE" then 
  xmute_conjunctions = { " zu ", " in " }
elseif locale == "itIT" then 
  xmute_conjunctions = { " in " }
elseif locale == "esES" or locale == "esMX" then 
  xmute_conjunctions = { " a ", " en " }
elseif locale == "ptBR" then 
  xmute_conjunctions = { " em ", " a ", " de l\195\163 ", " de ", " da ", " do ", " des ", " das ", " dos ", " d'" }
elseif locale == "frFR" then 
  xmute_conjunctions = { " en ", " du ", " de la ", " de l'", " de l\226\128\153", " de ", " d'", " des " }
elseif locale == "ruRU" then 
  xmute_conjunctions = { " \208\178 " }
elseif locale == "koKR" then 
  xmute_conjunctions = { "\235\161\156", "\236\139\157" }
else 
  xmute_conjunctions = { }
end
local figurine_token = strtrim(string.lower(L["Figurine"]))

-- ticket 65: normalize asian punctuation characters
local function puncnormalize(str)
  str = str:gsub("\239\188\154",":")
  str = str:gsub("\239\188\136","(")
  str = str:gsub("\239\188\137",")")
  return str
end

local function normalize(spellname) -- normalize minor differences in spellnames
  if not spellname then return nil end
  spellname = string.lower(spellname)
  if string.find(spellname, xmute_token) then -- Transmute spelling is a mess
    spellname = string.gsub(spellname, xmute_token, "") 
    for _,conj in ipairs(xmute_conjunctions) do
      spellname = string.gsub(spellname, conj, " ")
    end
    spellname = xmute_token.." "..spellname
  end
  spellname = puncnormalize(spellname)
  spellname = string.gsub(spellname, "%p", " ") -- punctuation
  spellname = string.gsub(spellname, "\226\128\153", " ") -- ticket 82: funky quote not counted as punctuation for some reason
  spellname = string.gsub(spellname, "\226\128\147", " ") -- ditto for dash
  if locale == "frFR" then -- the item database translation to french is absolutely TERRIBLE
    -- damn abbreviations - lazy french translators should be dragged out and shot
    spellname = string.gsub(spellname, "enchantements?", "ench")
    spellname = string.gsub(spellname, "caract..ristiques", "caract")
    spellname = string.gsub(spellname, " caract ", " carac ")
    spellname = string.gsub(spellname, "sup..rieures?", "sup")
    spellname = string.gsub(spellname, "inf..rieures?", "inf")
    spellname = string.gsub(spellname, "intelligence", "intel")
    spellname = string.gsub(spellname, "restauration", "rest")
    spellname = string.gsub(spellname, "puissance", "puiss")
    spellname = string.gsub(spellname, "puissant", "puiss")
    spellname = string.gsub(spellname, "chanteante", "changeante")
    spellname = string.gsub(spellname, "(%w%w%w%w%w)s ", "%1 ") -- trailing s on long words
    -- and they cannot decide on conjunctions
    for _,conj in ipairs(xmute_conjunctions) do
      spellname = string.gsub(spellname, string.gsub(conj, "%p", " "), " ")
    end
    -- or accents
    spellname = string.gsub(spellname, "\197\147", "oe")
    spellname = string.gsub(spellname, "\195\169", "e")
    spellname = string.gsub(spellname, "\195\162", "a")
  elseif locale == "esES" or locale == "esMX" then
    spellname = string.gsub(spellname, " de ", " ") -- encantar arma (de) 2M
    spellname = string.gsub(spellname, " a la ", " ") -- 18291
    spellname = string.gsub(spellname, " de las ", " ") -- 21915
    spellname = string.gsub(spellname, " del ", " ") -- 41574
    spellname = string.gsub(spellname, " m..scara ", " marca ") -- item 66999 and friends
    spellname = string.gsub(spellname, "muerte", "muerto") -- item 13486 and friends
    spellname = string.gsub(spellname, "rpido grueso", "rpido pesado") -- item 15724 and friends
    spellname = string.gsub(spellname, "primigeni.(.+)primigeni.", "primigenio%1") -- item 22915 and friends
    spellname = string.gsub(spellname, "primigeni.", "primigenio") -- item 22915 and friends
  elseif locale == "ptBR" then
    -- normalize de/do/des/dos
    for _,conj in ipairs(xmute_conjunctions) do
      spellname = string.gsub(spellname, string.gsub(conj, "%p", " "), " ")
    end
    spellname = string.gsub(spellname, "\195\167", "c")
    spellname = string.gsub(spellname, "\195\163", "a")
    spellname = string.gsub(spellname, "\195\173", "i")
    spellname = string.gsub(spellname, "terr[ae]n.s?", "terrano") -- 7086 and friends
    spellname = string.gsub(spellname, "dragao preta", "dragao negro") -- 15759 and friends
    spellname = string.gsub(spellname, "primev.(.+)primev.", "primevo%1") -- item 22915 and friends
    spellname = string.gsub(spellname, " primev.", " primevo") -- item 22915 and friends
    spellname = string.gsub(spellname, " pelame ", " pele ") -- item 44559 and friends
    spellname = string.gsub(spellname, "(\195\180nix) vermelho ", "%1 rubro ") -- "onix rubro" spells use "onix vermelho"
    spellname = string.gsub(spellname, "(%w%w%w%w%w)s ", "%1 ") -- trailing s on long words
    spellname = string.gsub(spellname, "(%w%w%w%w)s$", "%1") -- trailing s on long words
  elseif locale == "itIT" then
    spellname = string.gsub(spellname, "incantamento%s+(incanta) ", "%1 ") -- enchant spells repeat name
    spellname = string.gsub(spellname, "incantamento ", "incanta ") -- always use incanta
  elseif locale == "zhCN" then
    spellname = string.gsub(spellname, "( \232\182\133)\229\188\186", "%1\231\186\167") -- "super" vs "superior" ambiguity in enchant names
    spellname = string.gsub(spellname, "(\233\157\180)\229\173\144 ", "\233\149\191%1 ") -- "boot" vs "boots" ambiguity in enchant names
    spellname = string.gsub(spellname, xmute_token.." ", "") -- remove xmute token which is often missing
    spellname = string.gsub(spellname, "\229\144\136\230\136\144", "") -- remove alternate xmute token
  end
  spellname = string.gsub(spellname, figurine_token, " ") -- old-world figurines drop the token TODO: need more for ruRU
  spellname = string.gsub(spellname, "\194\160", " ") -- non-breaking space
  spellname = string.gsub(spellname, "%s+", " ") -- extra space
  spellname = strtrim(spellname) -- extra space
  --myprint(spellname)
  --if string.find(spellname, xmute_token) then   print(spellname); print(string.byte(spellname,1,#spellname)) end
  return spellname
end
function addon:normalize(s) return normalize(s) end

function addon:hash(str) -- a dumbed-down crc32
  str = tostring(str)
  local count = string.len(str)
  local val = tonumber(count)
  for i = 1,count do
    local byte = tonumber(string.byte(str,i))
    val = bit.bxor(bit.lshift(val,8), bit.lshift(bit.bxor(bit.rshift(val,24), byte),i%3))
  end
  return tonumber(val)
end

function addon:build_tables() 
  local start = GetTime()

  addon.ttcache = addon.ttcache or {}
  addon.ttcachecnt = addon.ttcachecnt or 0

  if not addon.vercheck then
    addon.vercheck = true
    local md = vars.VersionInfo
    assert(md)
    local exp = { [0] = "Classic", [1] = "TBC", [2] = "WotLK", [3] = "Cata", [4] = "Mists" }
    debug("Loading PV_PatDB v"..md.DBversion.."-"..md.DBrevision.." for client "..
            exp[md.clientexpansion].." "..  md.clientversion)
    local clientexpansion = GetExpansionLevel()
    local clientversion, clientbuild = GetBuildInfo()
    clientbuild = tonumber(clientbuild) or 0
    if clientexpansion > md.clientexpansion
     --or clientbuild < tonumber(md.clientbuildmin) or clientbuild > tonumber(md.clientbuildmax)
     or clientversion ~= md.clientversion 
     then
      local msg = L["WARNING: This version of ProfessionsVault was compiled for a different version of WoW (%s) than you are running (%s). Some features may be broken. Please download an update from %s"]
      msg = format(msg, format("%s %s", exp[md.clientexpansion], md.clientversion),
                        format("%s %s-%d", exp[clientexpansion], clientversion, clientbuild),
                        addon_website)
      addon.badversion = true
      chatMsg(msg)
    end
  end

  debug(format("build_tables: %.3f s", GetTime()-start))
  collectgarbage("collect")
end 

function addon:link_parse(link)
  if not link then return nil end
  local guid, spellid, magic =
     link:match("\124Htrade:([^:]*):([^:]*):([^\124]*)\124h")
  guid = guid_normalize(guid)
  local text = link:match("\124h%[([^\124]+)%]\124h")
  return tonumber(spellid), guid, magic, text
end

function addon:link_build(spellorprof, guid, text, color)
  local profid, profname
  if tonumber(spellorprof) then -- accept prof via either spellid or spellname
    profid = tonumber(spellorprof)
    profname = GetSpellInfo(profid)
  else
    profname = spellorprof
  end
  if not profname then return nil end
  -- normalize spellid
  if not allProf[profname] then
    for k,v in pairs(allProf) do
      if k:lower() == profname:lower() then
        profname = k
        break
      end
      for _,a in ipairs(v.aliases) do
        if a:lower() == profname:lower() then
          profname = k
          break
        end
      end
    end
  end
  if not allProf[profname] then
     chatMsg("ERROR: Unrecognized profession "..profname.." ("..spellorprof.."-"..GetLocale().."). Please report this bug!")
     return 
  end
  profid = allProf[profname].spellid
  local magic = allProf[profname].magic or 0
  -- normalize other arguments
  text = text or profname
  text = strtrim(strtrim(text):gsub("^%[(.*)%]$","%1")) -- strip brackets and ws
  guid = guid or UnitGUID("player")
  guid = guid_normalize(guid)
  link = "\124Htrade:"..guid..":"..profid..":"..magic
  link = link.."\124h["..text.."]\124h"
  if color then -- colored link
     link = "\124cffffd000"..link.."\124r"
  end
  return link
end

-- normalize the profession clauses of a trade link, color output true/false/nil=same
function addon:normalize_link(link, color)
   if not link then return nil end

   local profid, guid, magic, text = addon:link_parse(link)
   if not profid then -- ticket 72, handle non-prof links
      return link
   end
   local newlink = addon:link_build(profid, guid, text,
                                    color or (color == nil and link:find("\124c")))

   if link ~= newlink then
     debug("normalize_link("..link..") => "..newlink)
     profid, guid, magic, text = addon:link_parse(newlink)
   end
   return newlink, text, profid
end


function addon:BuildGuildTradeLink()
  local pname, rank, rankmax = GetTradeSkillLine()
  local linked, cname = IsTradeSkillLinked()
  if not linked or not pname or not cname then return nil end
  cname = addon:name_normalize(cname)
  local profid = allProf[pname].spellid
  local guid = DB.guid_cache[cname]
  if not guid or not profid then return nil end

  return addon:link_build(profid, guid, pname, true)
end

-- tooltip scanning code

addon.scantt = CreateFrame("GameTooltip", "ProfessionsVault_Tooltip", UIParent, "GameTooltipTemplate")
addon.scantt:SetOwner(UIParent, "ANCHOR_NONE");

function addon:scanBegin(itemidorlink)
  addon.scantt:ClearLines()
  addon.scantt:SetOwner(UIParent, "ANCHOR_NONE");
  local itemid = tonumber(itemidorlink)
  if itemid then
    addon.scantt:SetItemByID(itemid)
  else
    addon.scantt:SetHyperlink(itemidorlink)
  end
  return addon.scantt:NumLines()
end
function addon:scanLink()
  local itemname, itemlink = addon.scantt:GetItem()
  return itemlink
end
function addon:scanLine(i)
  return getglobal(addon.scantt:GetName() .. "TextLeft"..i)
end
function addon:scanText(i)
  local line = addon:scanLine(i)
  local text = line and line:GetText()
  text = text or ""
  return text
end

function addon:recipeClass()
  if not addon._recipeClass then
    addon._recipeClass = select(6,GetItemInfo(43017))
  end
  return addon._recipeClass 
end

function addon:isRecipe(itemid)
  local class = select(6,GetItemInfo(itemid))
  return class and class == addon:recipeClass()
end

function addon:isEnchantScroll(itemid)
  if not addon._scrollClass then
    addon._scrollClass, addon._scrollSubClass = select(6,GetItemInfo(38872))
    addon._scrollExceptions = { -- items in the subclass that are not scrolls
      [19971]=1,[34836]=1,[38378]=1,[40776]=1,[41605]=1,[41606]=1,[43097]=1,[68796]=1,[82959]=1,[87583]=1,
    }
  end
  local name,link,quality,ilvl,_, class, subclass = GetItemInfo(itemid)
  if class == addon._scrollClass and subclass == addon._scrollSubClass and 
     name:lower():find((L["Enchant"]):lower()) and not addon._scrollExceptions[itemid] then
     return true
  else
     return false
  end
end

function addon:expandAllTradeSkills()
  -- expand all window settings
  if TradeSkillFilterBarExitButton then
    TradeSkillFilterBarExitButton:Click()
  end
  SetTradeSkillItemNameFilter("");
  TradeSkillOnlyShowMakeable(false);
  TradeSkillOnlyShowSkillUps(false);
  SetTradeSkillCategoryFilter(-1, 0);
  SetTradeSkillInvSlotFilter(-1, 1, 1);
  if TradeSkillFrame then
    TradeSkillFrame.filterTbl = {hasMaterials = false, hasSkillUp = false, subClassValue = -1, slotValue = -1 };
  end
  if TradeSkillUpdateFilterBar then
    TradeSkillUpdateFilterBar();
  end
  ExpandTradeSkillSubClass(0);
end

function addon:ScanJC()
  local jcdb = {}
  addon.db.global.JCDB = {} -- XXX
  if true then return end

  local pname = GetSpellInfo(PID_JC)
  local link = DB.chars[einstein][pname].link
  local gemClass = select(6,GetItemInfo(23077))
  SetItemRef(cleanlink(link),link,"LeftButton",ChatFrame1)
  jcdb.locale = locale

  addon:expandAllTradeSkills()

  for idx = 1,GetNumTradeSkills() do
    local skillname, skilltype = GetTradeSkillInfo(idx)
    if skillname and skilltype ~= "header" and GetTradeSkillNumReagents(idx) == 1 then
      local link = GetTradeSkillRecipeLink(idx)
      local reagentlink = GetTradeSkillReagentItemLink(idx, 1)
      if not reagentlink then -- GetTradeSkillReagentItemLink() broken in 5.2 PTR
        addon.scantt:ClearLines()
        addon.scantt:SetOwner(UIParent, "ANCHOR_NONE");
        addon.scantt:SetTradeSkillItem(idx, 1)
        reagentlink = select(2,addon.scantt:GetItem())
      end
      if reagentlink then
        local itemid = string.match(reagentlink, "\124Hitem:(%d+):")
        --local itemname = string.match(reagentlink, "\124h%[(.+)%]\124h")
        local itemname,_,_,_,_, class, subclass = GetItemInfo(itemid)
        -- print(link, reagentlink, itemid, itemname)
        if itemid and itemname and class == gemClass then
          jcdb[string.lower(itemname)] = tonumber(itemid)
        end
      end
    end
  end
  local count = 0
  for k,v in pairs(jcdb) do
    chatMsg(k.." "..v)
    count = count + 1
  end
  chatMsg("ScanJC detected "..count.." raw gems")
  if count < 57 then --cache failure
    chatMsg("Please run again!")
    addon.db.global.JCDB = nil
  else
    addon.db.global.JCDB = jcdb
  end
end

function addon:RefreshTooltips() -- reset the tooltip state
  debug("RefreshTooltips")
  addon.ttcache = {} -- clear tooltip cache
  addon.ttcachecnt = 0
  GameTooltip:Hide()
  ItemRefTooltip:Hide()
  if AtlasLootTooltip then AtlasLootTooltip:Hide() end
  if addon.settings.ahcolor then
    addon:SetAuctionColors()
  end
end

-- -----------------------------------------------------------------------------
local function frameupdate(frame)
  debug("Container frameupdate")
  local bagid = frame:GetID();
  if (settings.bagcolor and bagid >= 0 and bagid <= NUM_BAG_SLOTS) or
     (settings.bankcolor and (bagid == -1 or bagid > NUM_BAG_SLOTS)) then
    local name = frame:GetName();
    addon:BagUpdate(bagid, name)
  end
end
hooksecurefunc("ContainerFrame_Update", frameupdate)
hooksecurefunc("ContainerFrame_UpdateCooldowns", frameupdate)

hooksecurefunc("BankFrameItemButton_Update",
function (button)
  --debug("BankFrameItemButton_Update")
  if not button.isBag then
    local texture = _G[button:GetName().."IconTexture"];
    local itemid = GetContainerItemID(BANK_CONTAINER, button:GetID())
    itemid = settings.bankcolor and itemid
    addon:SlotColor(itemid, texture)
  end 
end)

function addon:BagUpdate(bagid, framename)
  local numslots = GetContainerNumSlots(bagid)
  for slot=1,numslots do
    local itemid = GetContainerItemID(bagid, slot)
    local textureid
    if addon.onebagaddon then -- OneBag3 reverts the texture IDs and uses them
      textureid = slot
    else -- default UI inverts textureids
      textureid = (numslots-slot+1)
    end
    local texture = _G[framename.."Item"..textureid.."IconTexture"]
    addon:SlotColor(itemid, texture)
  end
end

function addon:GuildBankFrame_Update(clear)
  if (settings.bankcolor or clear) and GuildBankFrame then
    local tab = GetCurrentGuildBankTab();
    for slot=1, MAX_GUILDBANK_SLOTS_PER_TAB do
       local itemlink = GetGuildBankItemLink(tab, slot)
       local itemid = itemlink and string.match(itemlink, "\124Hitem:(%d+):")
       itemid = itemid and tonumber(itemid)
       local index = mod(slot, NUM_SLOTS_PER_GUILDBANK_GROUP);
       if ( index == 0 ) then
          index = NUM_SLOTS_PER_GUILDBANK_GROUP;
       end
       local column = ceil((slot-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP);
       local texture = _G["GuildBankColumn"..column.."Button"..index.."IconTexture"];
       itemid = (not clear) and itemid
       addon:SlotColor(itemid, texture, true)
    end
  end
end

hooksecurefunc("InboxFrame_Update",
function (clear)
  debug("InboxFrame_Update")
  if (settings.mailcolor or clear) and InboxFrame then
    for i = 1, INBOXITEMS_TO_DISPLAY do
      local itemid = nil
      local button = _G["MailItem"..i.."Button"]
      local texture = _G[button:GetName().."Icon"]
      if button and button:IsVisible() and button.itemCount == 1 then
        local itemlink = GetInboxItemLink(button.index, 1)
        itemid = itemlink and string.match(itemlink, "\124Hitem:(%d+):")
        itemid = itemid and tonumber(itemid)
        --print(itemlink.." "..itemid)
      end
      itemid = (not clear) and itemid
      local reqlvl, class
      if itemid then reqlvl, class = (itemid and select(5,GetItemInfo(itemid))) end
      --if itemid then print(itemid.." "..(reqlvl or "nil").." "..(class or "nil")) end
      if reqlvl and class ~= addon:recipeClass() and reqlvl > UnitLevel("player") then
        texture:SetVertexColor(1,0,0)
      else
        addon:SlotColor(itemid, texture, true)
      end
    end
    local openmailid = InboxFrame.openMailID
    if openmailid and openmailid > 0 then
      for slotid = 1, ATTACHMENTS_MAX_RECEIVE do
        local itemlink = GetInboxItemLink(openmailid, slotid)
        local itemid = itemlink and string.match(itemlink, "\124Hitem:(%d+):")
        itemid = itemid and tonumber(itemid)
        local texture = _G["OpenMailAttachmentButton"..slotid.."IconTexture"]
        itemid = (not clear) and itemid
        addon:SlotColor(itemid, texture)
      end
    end
  end
end)


function addon:GetItemRtype(itemid)
  if not itemid then return nil end
  local _, itemlink, _, _, _, itemtype, _, _, _, _ = GetItemInfo(itemid)
  if itemtype == addon.recipeClass() then
     if not addon.ttcache[itemid] then
        debug("Slot Scanning : "..itemlink.." "..itemtype)
        addon.scantt:ClearLines()
        addon.scantt:SetOwner(UIParent, "ANCHOR_NONE");
        addon.scantt:SetHyperlink(itemlink)
     end
     return addon.ttcache[itemid] and addon.ttcache[itemid].rtype
  end
  return nil
end

-- third party bag addons can plugin by calling either function below

-- returns r,g,b color components appropriate for the itemid
function addon:GetSlotColor(itemid)
  local rtype = addon:GetItemRtype(itemid)
  if rtype then
    local color = settings.recipecolor[rtype]
    if color then
      local r,g,b = unpack(color)
      return r,g,b,true
    end
  end
  return 1,1,1,false
end
-- sets the VertexColor of the provided texture as appropriate for the itemid
function addon:SlotColor(itemid, texture, resetcolor)
  if not texture then return nil end
  local r,g,b,set = addon:GetSlotColor(itemid)
  if set then
     texture:SetVertexColor(r,g,b)
  elseif resetcolor then
     texture:SetVertexColor(1,1,1) -- reset shading
  end
end
-- -----------------------------------------------------------------------------
-- support for third-party bag addons

addon.bagnon_hook = function(itemslot) 
  local bank = itemslot.IsBankSlot and itemslot:IsBankSlot()
  if (bank and not settings.bankcolor) or
     (not bank and not settings.bagcolor) then return end
  local itemlink = itemslot.GetItem and itemslot:GetItem()
  local itemid = itemlink and string.match(itemlink, "\124Hitem:(%d+):")
  itemid = itemid and tonumber(itemid)
  if itemid and addon:isRecipe(itemid) then
    local r,g,b = addon:GetSlotColor(itemid)
    SetItemButtonTextureVertexColor(itemslot,r,g,b)
  end
end

addon.arkinv_hook = function(frame)
  local name = frame and frame.GetName and frame:GetName( )
  if not name then return end
  --if not name or not string.match(name, "ContainerBag%d+Item%d+$") then return end
  local item = ArkInventory.Frame_Item_GetDB and ArkInventory.Frame_Item_GetDB(frame)
  local loc_id = item.loc_id
  if not item or not loc_id then return end
  local bank = ArkInventory.Const and ArkInventory.Const.Location and 
               (loc_id == ArkInventory.Const.Location.Vault or 
                loc_id == ArkInventory.Const.Location.Bank)
  if (bank and not settings.bankcolor) or
     (not bank and not settings.bagcolor) then return end

  local itemlink = item.h
  local itemid = itemlink and string.match(itemlink, "\124Hitem:(%d+):")
  itemid = itemid and tonumber(itemid)
  local texture = _G[name.."IconTexture"]
  addon:SlotColor(itemid, texture, false)
end

addon.baggins_hook = function(self,bagframe,button,bag,slot) 
  if not bag or not slot or not button then return end
  local bank = (bag == -1) or (bag > NUM_BAG_SLOTS)
  if (bank and not settings.bankcolor) or
     (not bank and not settings.bagcolor) then return end
  local itemlink = GetContainerItemLink(bag, slot)
  local itemid = itemlink and string.match(itemlink, "\124Hitem:(%d+):")
  local texture = button.glow
  itemid = itemid and tonumber(itemid)
  if itemid and addon:isRecipe(itemid) then
    local r,g,b = addon:GetSlotColor(itemid)
    SetItemButtonTextureVertexColor(button,r,g,b)
  end
end

addon.combuctor_hook = function(itemslot) 
  local bank = itemslot.IsBank and itemslot:IsBank()
  if (bank and not settings.bankcolor) or
     (not bank and not settings.bagcolor) then return end
  local itemlink = itemslot.GetItem and itemslot:GetItem()
  local itemid = itemlink and string.match(itemlink, "\124Hitem:(%d+):")
  itemid = itemid and tonumber(itemid)
  if itemid and addon:isRecipe(itemid) then
    local r,g,b = addon:GetSlotColor(itemid)
    SetItemButtonTextureVertexColor(itemslot,r,g,b)
  end
end

addon.elvui_hook = function(self,itemslot) 
  local bagid = itemslot.bag or 0
  local slotid = itemslot.slot or 0
  local bank = (bagid == BANK_CONTAINER) or (bagid > NUM_BAG_SLOTS)
  if (bank and not settings.bankcolor) or
     (not bank and not settings.bagcolor) then return end
  local itemlink = GetContainerItemLink(bagid, slotid)
  local itemid = itemlink and string.match(itemlink, "\124Hitem:(%d+):")
  itemid = itemid and tonumber(itemid)
  if itemid and addon:isRecipe(itemid) then
    local r,g,b = addon:GetSlotColor(itemid)
    SetItemButtonTextureVertexColor(itemslot.frame,r,g,b)
  end
end

-- -----------------------------------------------------------------------------
function addon.AtlasLootUpdate() 
  for i=1,30 do -- loot page
    local item = _G["AtlasLootItem_"..i]
    local itemid = item and item.par and item.par.info and item.par.info[2]
    if item.Icon then -- color the page
      addon:SlotColor(itemid, item.Icon, true)
    end
    addon.alhooked = addon.alhooked or {}
    if not addon.alhooked[i] then -- hook mouse-over server queries
      local ib = AtlasLoot and AtlasLoot.ItemFrame and AtlasLoot.ItemFrame.ItemButtons and AtlasLoot.ItemFrame.ItemButtons[i]
      if ib and ib.Refresh then
        hooksecurefunc(ib,"Refresh",addon.AtlasLootUpdate)
        addon.alhooked[i] = true
      end
    end
  end
  for i=1,8 do -- compare frame (wishlist)
    local item = _G["AtlasLootCompareFrame_ScrollFrameItemFrame_Item"..i]
    local itemid = item and item.par and item.par.info and item.par.info[2]
    if item.Icon then 
      addon:SlotColor(itemid, item.Icon, true)
    end
  end
end
-- -----------------------------------------------------------------------------
StaticPopupDialogs["PROFESSIONSVAULT_SCANAH_ERROR"] = {
  preferredIndex = 3, -- reduce the chance of UI taint
  text = L["You must be at an auctioneer to scan the auction house for patterns."],
  button1 = OKAY,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  enterClicksFirstButton = false,
  showAlert = true,
}

function addon:ScanAH()
  if not AuctionFrame or not AuctionFrame:IsVisible() then 
    StaticPopup_Show("PROFESSIONSVAULT_SCANAH_ERROR")
    return
  end
  addon:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
  addon.AHlist = addon.AHlist or {}
  wipe(addon.AHlist)
  addon.AHPage = nil
  addon.AHPageLast = nil
  for idx, class in ipairs({GetAuctionItemClasses()}) do
    if class == addon:recipeClass() then addon.recipeClassIdx = idx end
  end
  chatMsg(L["Scanning the auction house for patterns.."])
  addon:QueryPage()
end

function addon:QueryPage(nodefer)
  local canQuery = CanSendAuctionQuery("list")
  if not canQuery or addon.AHPageLast ~= addon.AHPage then
     if not nodefer then addon:ScheduleTimer("QueryPage", 0.5) end
     return
  end
  QueryAuctionItems(nil,nil,nil,nil,addon.recipeClassIdx,nil,addon.AHPage,nil,nil,false)    
  addon.AHPage = (addon.AHPage or 0) + 1
end

local function goldStr(amt)
  amt = math.floor(amt/10000)*10000
  return GetMoneyString(amt)
end

function addon:AUCTION_ITEM_LIST_UPDATE()
  local numBatchAuctions, totalAuctions = GetNumAuctionItems("list")
  addon.AHlist = addon.AHlist or {}
  if addon.AHPageLast == addon.AHPage then return end
  addon.AHPageLast = addon.AHPage
  for itemidx = 1,numBatchAuctions do
    local itemlink = GetAuctionItemLink("list", itemidx)
    local itemid = itemlink and string.match(itemlink, "\124Hitem:(%d+):")
    itemid = itemid and tonumber(itemid)
    local rtype = addon:GetItemRtype(itemid)
    if rtype and (rtype:match("learn_self") or rtype:match("learn_alt") or rtype:match("learn_falt")) then
      local minbid, mininc, buyout, bidcur, highbidder = select(8,GetAuctionItemInfo("list", itemidx))
      local bid = math.max((minbid or 0),(bidcur or 0)+mininc)
      local e = addon.AHlist[itemid] or {}
      addon.AHlist[itemid] = e
      e.num = (e.num or 0) + 1
      e.link = itemlink
      e.subclass = select(7,GetItemInfo(itemid))
      e.rtype = rtype
      e.bid = math.min(bid, e.bid or 1e12)
      e.buyout = math.min(buyout, e.buyout or 1e12)
      e.highbidder = highbidder
    end
  end
  if numBatchAuctions == NUM_AUCTION_ITEMS_PER_PAGE then
    addon:QueryPage() -- next page
  else -- print results
    addon:CancelAllTimers() -- terminate any QueryPage timers
    addon:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
    local total = 0
    for _,subclass in ipairs({GetAuctionItemSubClasses(addon.recipeClassIdx)}) do
      local first = true
      for itemid, e in pairs(addon.AHlist) do
        if e.subclass == subclass then
          if first then
            chatMsg(subclass..":")
            first = false
          end
          local str = e.link.." "
          if e.num > 1 then
            str = str.."("..e.num..") "
          end
          str = str..goldStr(e.bid)
          if e.buyout and e.buyout > 0 then
            str = str.." / "..goldStr(e.buyout)
          end
	  if e.highbidder then
	    str = str.." ("..HIGH_BIDDER..")"
	  end
          chatMsg("  "..str)
          total = total + 1
        end
      end
    end
    chatMsg(total.." "..L["Results."])
  end
end
-- -----------------------------------------------------------------------------
function addon:MERCHANT_SHOW()
  addon:MerchantEvent("MERCHANT_SHOW")
end
function addon:MERCHANT_UPDATE()
  addon:MerchantEvent("MERCHANT_UPDATE")
end
function addon:MERCHANT_CLOSED()
  addon:MerchantEvent("MERCHANT_CLOSED")
end

function addon:MerchantEvent(context)
  local numitems = GetMerchantNumItems()
  debug("MerchantEvent ("..(context or "nil").."): numitems="..numitems)
  if not MerchantFrame then return end
  if not MerchantFrame:IsShown() then
    if useMerchantTimer and addon.merchantTimer then
      addon:CancelTimer(addon.merchantTimer, true)
      addon.merchantTimer = nil
    end
    return
  end
  if not addon.settings.merchantcolor then return end
  if useMerchantTimer and not addon.merchantTimer then
    addon.merchantTimer = addon:ScheduleRepeatingTimer("MerchantEvent", 1.0, "timer")
  end
  if not addon.merchantHooked and MerchantFrame_UpdateMerchantInfo and
     MerchantPrevPageButton and MerchantNextPageButton and MerchantFrameTab1 and MerchantItem1 then
    MerchantNextPageButton:HookScript("PostClick", function () addon:MerchantEvent("MerchantNextPageButton:PostClick") end)
    MerchantPrevPageButton:HookScript("PostClick", function () addon:MerchantEvent("MerchantPrevPageButton:PostClick") end)
    MerchantFrameTab1:HookScript("PostClick", function () addon:MerchantEvent("MerchantFrameTab1:PostClick") end)
    MerchantItem1:HookScript("OnShow", function () addon:MerchantEvent("MerchantItem1:OnShow") end)
    hooksecurefunc("MerchantFrame_UpdateMerchantInfo", function () addon:MerchantEvent("MerchantFrame_UpdateMerchantInfo") end)
    addon.merchantHooked = true
  end
  if MerchantFrame.selectedTab ~= 1 then return end -- buyback tab
  
  for i=1,MERCHANT_ITEMS_PER_PAGE do
    local index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i);
    if index > numitems then break end
    local itemButton = _G["MerchantItem"..i.."ItemButton"];
    local merchantButton = _G["MerchantItem"..i];
    if not itemButton or not merchantButton then break end
    local itemlink = GetMerchantItemLink(index)
    local itemid = itemlink and string.match(itemlink, "\124Hitem:(%d+):")
    itemid = itemid and tonumber(itemid)
    if itemid and addon:isRecipe(itemid) then
      local r,g,b = addon:GetSlotColor(itemid)
      SetItemButtonNameFrameVertexColor(merchantButton, r,g,b)
      SetItemButtonSlotVertexColor(merchantButton, r,g,b)
      SetItemButtonTextureVertexColor(itemButton, r,g,b)
      SetItemButtonNormalTextureVertexColor(itemButton, r,g,b)
    end
  end
end

function addon:SetAuctionColors()
  --debug("SetAuctionColors()")

  local pageoffset = 0
  if not addon.AuctioneerAdv then
    pageoffset = (BrowseScrollFrame and FauxScrollFrame_GetOffset(BrowseScrollFrame)) or 0
  end
  local pagesz, totalsz = GetNumAuctionItems("list")
  for i = 1, pagesz do
     local itemlink, itemidx, iconTexture
     if addon.AuctioneerAdv then
       local button = getglobal("BrowseButton"..i)
       if button and button:IsVisible() and button.id then
         itemidx = button.id
         iconTexture = button.Icon
         --iconTexture = getglobal("AppraiserIconButton"..i)
       end
     else
       itemidx = i+pageoffset
       iconTexture = getglobal("BrowseButton"..i.."ItemIconTexture")
     end

     if not itemidx then break end
     itemlink = GetAuctionItemLink("list", itemidx)
     if not iconTexture or not itemlink then break end

     local itemid = string.match(itemlink, "\124Hitem:(%d+):")
     itemid = itemid and tonumber(itemid) 
     local resetcolor = false
     if addon.AuctioneerAdv then -- auctioneer doesnt reset colors so we have to
       local usable = select(5,GetAuctionItemInfo("list",itemidx))
       if not usable then
         iconTexture:SetVertexColor(1,0,0)
       else
         resetcolor = true
       end
     end
     addon:SlotColor(itemid, iconTexture, resetcolor)
  end

end

-- -----------------------------------------------------------------------------
local minedata

function addon:MineSpells(min,max)
  local status = minedata.status
  for id = min, max do
    local spellname, rank, icon, powerCost, isFunnel, powerType, castingTime, minRange, maxRange = GetSpellInfo(id)
    if spellname and  -- valid spell id
       powerCost == 0 and not isFunnel and minRange == 0 and maxRange == 0 then -- possible tradeskill
       local link = "\124Henchant:"..id.."\124h[Spell:"..id.."]\124h"
       addon:scanBegin(link)
       local fullname = addon:scanText(1)
       if fullname then
         local pname, sname = fullname:match("^%s*([^:]+)%s*:%s*(.+)%s*$")
	 if pname and addon.profspecs[pname] then -- translate aliases, ignore spec restrictions
	    pname = addon.profspecs[pname]
	 end
	 if pname and sname and allProf[pname] and -- looks like a tradeskill spell
	    allProf[pname].spellid ~= PID_ARCH then -- ignore archaeology spells
	   local idx = pname..":"..normalize(sname)
	   local old = minedata.spelldb[idx]
	   if not old then
	     minedata.spelldb[idx] = id
	     minedata.spellcnt = minedata.spellcnt + 1
           elseif old == id then
	     -- perfect duplicate
	   else -- may be several spellids for one skill
	     local t = old
	     if type(t) ~= "table" then
	       t = { old }
	     end
	     local found 
	     for _,e in ipairs(t) do if e == id then found = true; break end end
	     if not found then
	       table.insert(t, id)
	       minedata.spellcnt = minedata.spellcnt + 1
	     end
	     minedata.spelldb[idx] = t
	   end
	 end
       end
    end
  end
end

local badItemPrefix = { 
  -- items with this first word in their name never teach a trade spell
  -- these are mostly deprecated class spell books
  ["Grimoire"] = true,
  ["Libram"] = true,
  ["Tome"] = true,
  ["Guide"] = true,
  ["Codex"] = true,
  ["Book"] = true,
  ["Handbook"] = true,
  ["Ancient"] = true, -- Ancient Tome
  ["Tablet"] = true, -- also ignores Tablet of Ren Yun, which doesnt scan properly anyhow
  ["Expert"] = true, -- FA/Cook skill books
  ["Master"] = true, -- FA/Cook skill books
}
local function recipeItemBlacklisted(id)
  if vars.DeadRecipes[id] then return true end
  local name = GetItemInfo(id)
  local prefix = name and name:match("^%s*([^%s%p]+)[%s%p]")
  if prefix and badItemPrefix[prefix] then 
     return true
  end
  if name:match("^Manual ") or -- Manual class spell, not to be confused with First Aid "Manual:"
     name:match(" Cookbook$")  -- Several bogus items
     then
     return true
  end
  return false
end

function addon:MineItems(min,max,cachemax)
  local status = minedata.status
  for id = min, cachemax do -- prefetch
      GetItemInfo(id)
      addon:scanBegin(id)
  end
  for id = min, max do
    if addon:isRecipe(id) and not recipeItemBlacklisted(id) then
      local link = (select(2,GetItemInfo(id)) or "item:"..id)
      local pname, plvl
      for i=2,addon:scanBegin(id) do
        local text = addon:scanText(i)
	pname, plvl = text:match("^%s*Requires%s*:?%s*(.+)%s*%((%d+)%)%s*$")
	if pname and plvl then 
          pname = strtrim(pname)
	  if allProf[pname] then
	    break
	  elseif addon.profspecs[pname] then -- translate aliases, ignore spec restrictions
	    pname = addon.profspecs[pname]
	    break
	  else -- false positive from reagent lists
	    pname = nil
	  end
	end
      end
      local fullname = addon:scanText(1)
      local prefix, sname = fullname:match("^%s*([^:]+)%s*:%s*(.+)%s*$")
      if pname == "Fishing" then
        -- ignore these 
      elseif not sname then
        if not vars.mine_exceptions_ItoS[id] then -- ignore errors for exceptions
          chatMsg("Failed to detect sname for item "..id.." "..link)
	  table.insert(status.errors,"sname: "..id.." "..link)
	end
      elseif not pname then
        if not vars.mine_exceptions_ItoS[id] then -- ignore errors for exceptions
          chatMsg("Failed to detect pname for item "..id.." "..link)
	  table.insert(status.errors,"pname: "..id.." "..link)
	end
      else
        local idx = pname..":"..normalize(sname)
	local match = minedata.spelldb[idx]
	if not match then
          if not vars.mine_exceptions_ItoS[id] then -- ignore errors for exceptions
            chatMsg("Failed to find matching spell for item "..id.." "..link..","..pname..","..sname)
	    table.insert(status.errors,"match: "..id.." "..link)
	  end
	else
	  local old = minedata.itemdb[id]
	  if type(match) == "table" then
	    table.sort(match)
	  end
	  if not old then
	    minedata.itemdb[id] = match
	    minedata.itemcnt = minedata.itemcnt + 1
	  else
	    local matchcnt = type(match) == "table" and #match or 1
	    local oldcnt = type(old) == "table" and #old or 1
	    if matchcnt > oldcnt then
	      minedata.itemdb[id] = match
	    end
	  end
	end
      end
    end
  end
end

local function MineSchedule()
  addon:DataMine(false, nil, nil, minedata.status)
end

function addon:DataMineClear()
  wipe(self.db.global.minedata or {})
  minedata = nil
  chatMsg("DataMine cleared.")
end

function addon:DataMine(reset, maxspell, maxitem, status)
  local pausetime = 0.25
  local spellstep = 500
  local itemstep = 100
  minedata = self.db.global.minedata or {}
  self.db.global.minedata = minedata
  if not addon.profspecs then
    addon.profspecs = {}
    for pname, pinfo in pairs(allProf) do
      if pinfo.aliases then
        for _, alias in ipairs(pinfo.aliases) do
	  addon.profspecs[alias] = pname
	end
      end
    end
  end
  if reset or not minedata.spelldb then
    chatMsg("Reset minedata")
    wipe(minedata)
    minedata.spelldb = {}
    minedata.itemdb = {}
    minedata.spellcnt = 0
    minedata.itemcnt = 0
  end
  local firstiter = false
  if not status then -- user initiated run
    firstiter = true
    status = minedata.status or {}
    if maxspell or maxitem then -- user reset
      wipe(status)
    end
  end
  minedata.status = status
  if not maxspell or maxspell < 1 then maxspell = 200000 end
  if not maxitem or  maxitem < 1 then  maxitem = 107000 end
  status.maxspell = status.maxspell or maxspell
  status.maxitem = status.maxitem or maxitem
  status.curspell = status.curspell or 0
  status.curitem = status.curitem or 0
  status.old_spellcnt = status.old_spellcnt or minedata.spellcnt
  status.old_itemcnt = status.old_itemcnt or minedata.itemcnt
  status.errors = status.errors or {}
  if firstiter and #status.errors > 0 then
    chatMsg("Errors detected so far:")
    for _,err in ipairs(status.errors) do
      chatMsg(err)
    end
  end
  if status.curspell < status.maxspell then
    if status.curspell == 0 then
       chatMsg("Starting spellid test 0 to "..status.maxspell.."...")
    elseif firstiter then
       chatMsg("Resuming spellid test "..status.curspell.." to "..status.maxspell.."...")
    end
    local min = status.curspell
    local max = math.min(min+spellstep-1, status.maxspell)
    chatMsg("Scanning spellid "..min)
    addon:MineSpells(min,max)
    status.curspell = max + 1
    addon:ScheduleTimer(MineSchedule, pausetime)
  elseif status.curitem < status.maxitem then
    if status.curitem == 0 then
       chatMsg("Starting itemid test 0 to "..status.maxitem.."...")
    elseif firstiter then
       chatMsg("Resuming itemid test "..status.curitem.." to "..status.maxitem.."...")
    end
    local min = status.curitem
    local max = math.min(min+itemstep-1, status.maxitem)
    local cachemax = math.min(min+2*itemstep, status.maxitem)
    chatMsg("Scanning itemid "..min)
    addon:MineItems(min,max,cachemax)
    status.curitem = max + 1
    addon:ScheduleTimer(MineSchedule, pausetime)
  else
    for _,err in ipairs(status.errors) do
      chatMsg(err) 
    end
    chatMsg(#status.errors.." errors.")
    chatMsg("Found "..minedata.spellcnt.." trade spells ("..(minedata.spellcnt-status.old_spellcnt).." new)")
    chatMsg("Found "..minedata.itemcnt.." trade items ("..(minedata.itemcnt-status.old_itemcnt).." new)")
    chatMsg("Generating ItoS")
    addon:MineOutput()
  end
end

function addon:MineOutput()
  local olddb = vars.ItoS
  local newdb = minedata.itemdb
  -- merge exceptions
  for k,v in pairs(vars.mine_exceptions_ItoS) do
    newdb[k] = v
  end
  -- compute id list and change stats
  local ids = {}
  local add,miss,same,change = 0,0,0,0
  for k, v in pairs(newdb) do
    table.insert(ids, k)
    local ov = olddb[k]
    if not ov then
      add = add + 1
    else
      local vs =  (type(v) == "table" and table.concat(v,",") or v)
      local ovs = (type(ov) == "table" and table.concat(ov,",") or ov)
      if vs == ovs then
        same = same + 1
      else
        change = change + 1
      end
    end
  end
  for k, v in pairs(olddb) do
    local nv = newdb[k]
    if not nv then
      miss = miss + 1
      newdb[k] = v
      table.insert(ids, k)
    end
  end
  table.sort(ids)
  local total = #ids
  chatMsg("Found "..total.." entries. "
          ..same.." same, "..add.." new, "..change.." changed, "..miss.." missing.")
  -- build output
  local output = ""
  for _,id in ipairs(ids) do
    local name = GetItemInfo(id) or "<unknown>"
    local v = newdb[id]
    local line = "["..id.."]="
    if type(v) == "table" then
      local tmp = ""
      for _,vv in ipairs(v) do
        tmp = tmp..(#tmp > 0 and "," or "")..vv
      end
      v = "{"..tmp.."}"
    end
    line = line..v..","
    line = line..string.rep(" ",16-#line).." -- "..name.."\n"
    output = output..line
  end
  local sz = #output/1024
  local checksum = addon:hash(output)
  chatMsg("Wrote "..math.floor(sz).." KB output. checksum="..checksum)
  local comment =   "\n-- entries  = "..total
                  .."\n-- checksum = "..checksum
                  .."\n-- version  = "..(GetBuildInfo())
                  .."\n-- build    = "..select(2,GetBuildInfo())
                  .."\n-- rev      = "..addon.revision
                  .."\n-- date     = "..date()
		  .."\n"
  minedata.output = comment..output
end
-- -----------------------------------------------------------------------------

-- test code to find recipe mismatches, must be run per-language
-- run with no arguments to start a new default run or resume an interrupted run
-- run with minval and maxval to start a run on a specified range
function addon:TestRecipes(minval, maxval, status)
  local step = 100 
  local pausetime = 0.25
  local firstiter = false
  if not status then -- user initiated run
    firstiter = true
    if not minval and not maxval then -- default
      local gstatus = self.db.global.testrecipes_status
      if gstatus and gstatus.curval < gstatus.maxval then -- resume
	 status = gstatus
         chatMsg("Resuming itemid scan "..status.minval.." to "..status.maxval.." at "..status.curval.."...")
	 if #status.errors > 0 then
	   chatMsg("Errors detected so far:")
           for _,err in ipairs(status.errors) do
             chatMsg(err)
	   end
	 end
      else -- new run
         minval = minval or 0
         maxval = maxval or 110000
      end
    end
  end
  if not status then -- user initiated new run
    if locale ~= "enUS" and L["Figurine"] == "Figurine" and L["Color"] == "Color" and L["Options"] == "Options" then
      chatMsg("locale.lua missing or incomplete")
      return
    end
    if not addon.db.global.JCDB or addon.db.global.JCDB.locale ~= locale then
      addon:ScanJC()
      if not addon.db.global.JCDB then return end
    end
      status = {
        minval = minval,
	curval = minval,
        maxval = maxval,
	count = {},
        start = GetTime(),
	elapsed = 0,
        errors = {},
      }
      self.db.global.testrecipes_status = status
      chatMsg("Starting itemid test "..minval.." to "..maxval.."...")
  end
  addon:RefreshTooltips()
  local start = GetTime()
  maxval = math.min(status.curval + step - 1, status.maxval)
  local cachemax = math.min(status.curval + 2*step, status.maxval)
  for itemid=status.curval, cachemax do -- load the cache
      local itemname = GetItemInfo(itemid)
  end
 if not firstiter then
  chatMsg("Testing "..status.curval.." ...")
  local count = {}
  for itemid=status.curval, maxval do
    local itemname, itemlink, _, _, _, itemtype, profName, _, _, _ = GetItemInfo(itemid)
    if itemname then
       count.item = (count.item or 0) + 1
       if itemtype == addon.recipeClass() then
            addon.ttrecipe = false
            count.recipe = (count.recipe or 0) + 1
            if not addon.ttcache[itemid] then
              addon.scantt:SetHyperlink(itemlink)
            end
            if addon.ttrecipe and (not addon.ttcache[itemid] or addon.ttcache[itemid].biterr) 
               and not vars.DeadRecipes[itemid] then
               table.insert(status.errors, itemid.." "..itemlink)
            end
       end
    end
  end
  status.curval = maxval+1
  for k,v in pairs(count) do
    status.count[k] = (status.count[k] or 0) + (count[k] or 0)
  end
  status.elapsed = status.elapsed + (GetTime() - start)
 end
  if not firstiter and maxval == status.maxval then
    local tally = ""
    for k,v in pairs(status.count) do
      if #tally > 0 then tally = tally..", " end
      tally = tally .. (status.count[k] or 0) .. " " .. k .."s"
    end
    chatMsg("Tested itemids "..status.minval.." to "..status.maxval.." ("..tally..") in "..
          format("%.3f",status.elapsed).."/"..
	  format("%.3f",(GetTime() - status.start)).." sec - "..#status.errors.." errors.")
    for _,err in ipairs(status.errors) do
      chatMsg(err) 
    end
  else
    addon:ScheduleTimer(function () addon:TestRecipes(nil, nil, status) end, pausetime)
  end
end

--display length of a string, without escape codes
local function displaylen(s)
  s = string.gsub(s,"\124c........","")
  s = string.gsub(s,"\124r","")
  return strlenutf8(s)
end
function addon:displaylen(...) return displaylen(...) end

function addon:ShowTooltip(tt)
  local itemid, spellid, spellname
  local ttname = tt:GetName()
  --debug("ShowTooltip")
  if not ttname then return end

  local itemtext, itemlink = tt:GetItem()
  if itemtext and itemlink then -- recipes and crafted items
    itemid = string.match(itemlink, "\124Hitem:(%d+):")
    itemid = itemid and tonumber(itemid)
  else -- recipe spells
    --string.match(itemlink, "\124Henchant:(%d+):")
    spellname, _, spellid = tt:GetSpell()
    if not spellname or not spellid then return end
    spellid = spellid and tonumber(spellid)
  end
  if not itemid and not spellid then return end
  local cacheid = itemid or spellid+1000000
  --debug("ShowTooltip cacheid="..cacheid)

  if addon.ttcache[cacheid] then -- read from cache
    --print("HIT:"..cacheid..":"..#addon.ttcache[cacheid])
    if #addon.ttcache[cacheid] > 0 then
      tt:AddLine(" ")
    end
    for _,l in ipairs(addon.ttcache[cacheid]) do
     local r,g,b = unpack(l.color)
     if ttwrapwidth == 0 then
      tt:AddLine(string.gsub(l.text,",",", "), r, g, b, true)
     else
      local txtc = { strsplit(",",l.text) }
      local t = ""
      for _,c in ipairs(txtc) do
        if displaylen(t) + displaylen(c) > ttwrapwidth then
          tt:AddLine(t..",", r, g, b)
          t = "           "..c
        elseif #t == 0 then
          t = c
        else
          t = t..", "..c
        end
      end -- for txtc
      if #t > 0 then
        tt:AddLine(t, r, g, b)
      end
     end 
    end -- for lines
    tt:Show()
    tt:Show()
  else -- build cache
    --print("MISS:"..cacheid)
    local profName, profLvl, profID
    local recipeClasses, recipeFaction
    if spellid then -- spell link
      local line = getglobal(ttname .. "TextLeft1")
      local text = (line and line:GetText()) or ""
      text = puncnormalize(text)
      profName = string.match(text, "^([^:]+): ")
      profID = allProf[profName] and allProf[profName].spellid
      profLvl = 0 -- TODO
    else -- item link
      if not addon:isRecipe(itemid) 
         or vars.DeadRecipes[itemid]
         --or recipeItemBlacklisted(itemid) -- only works in english
	 then return end -- screen out non-recipes
      if settings.debug then
        local line = getglobal(ttname .. "TextLeft1")
	local text = line:GetText()
	if string.find(text,"etriev") then
	  debug(text.." for "..itemlink)
	  return
	end
      end

      for i=2,tt:NumLines() do
        local line = getglobal(ttname .. "TextLeft"..i)
	local text = (line and line:GetText()) or ""
	text = puncnormalize(text)
        local pn, pl = string.match(text, strtrim(L["Requires"]).."%s*:?%s*(.+)%s*%((%d+)%)%s*$")
	if not pn then
          pn, pl = string.match(text, "(.+)%s+%((%d+)%)%s+"..strtrim(L["Requires"])) -- frFR
	end
	pn = pn and strtrim(pn)
        pl = pl and tonumber(pl)
        local pID = allProf[pn] and allProf[pn].spellid
	if pn and pl and pID then -- need LAST valid Requires line as of 5.1
	   profName, profLvl, profID = pn, pl, pID
           addon.ttrecipe = true
	end

	recipeClasses = recipeClasses or text:match(recipeMatchClass)
	local races = text:match(recipeMatchRace)
	if races and not recipeFaction then
	  local r,ru = UnitRace("player")
	  local f = UnitFactionGroup("player")
	  if ru == "Pandaren" then
	    if f == "Alliance" then
	      r = L["Human"]
	    else
	      r = L["Orc"]
	    end
	  end
	  if races:match(r) then
	    recipeFaction = f
	  else
	    recipeFaction = (f == "Alliance" and "Horde" or "Alliance")
	  end
	end
      end
      if profID == PID_FISH or profID == PID_FA then addon.ttrecipe = false ; return end -- ignore fishing/first aid books
      if profID == PID_INSC then recipeClasses = nil end -- ignore false positive classes on glyph techniques
    end -- item
    if not profName or not profID or not profLvl then return end
    debug(ttname..": "..profName.." ("..profLvl.."): "..(recipeClasses or "")..(recipeFaction or ""))
    local knownstr, learnstr, unknownstr, skillstr, dunnostr = "","","","",""

    if not vars.ItoS and not spellid then return end
    if itemid and not spellid then
      spellid = vars.ItoS[itemid]
    end
    if (not spellid and not (itemid and vars.DeadRecipes[itemid])) then 
      chatMsg(format(L["ERROR: Missing entry in pattern database: %s Please report this bug!"],
            format("%d %s: %s %s",tostring(itemid or spellid),profName,itemlink or itemtext or spellname or "?",GetLocale())))
    end
    --myprint("SPELLID LOOKUP:",itemid, spellid)

    local rtype = "unknown"
    local rval = rcolortable[rtype].order
    local thisRealm = GetRealmName():gsub("%s","")

    for cname,dbc in cpairs(DB.chars) do
      --print(cname)
      local isself = (cname == charName)
      local isalt = not isself and dbc.data and dbc.data.alt
      local isother = not isself and not isalt
      local difffaction = dbc.data and dbc.data.faction and dbc.data.faction ~= DBc.data.faction
      local diffrealm = not isself and select(3,name_normalize(cname)) ~= thisRealm
      local coloredname,ctype = coloredcname(cname, settings.colorttnames)
      if (dbc[profName] and cname ~= einstein and not addon:isHidden(cname,profName) and 
	  (not difffaction or settings.factiondata) and
	  (not diffrealm or settings.realmdata) and
	  ((isself and settings.selfdata) or
	   (isalt and settings.altdata) or
	   (isother and settings.otherdata))
         ) then
        local pinfo = dbc[profName]
        if (pinfo.rank < profLvl) then
           skillstr = skillstr..((#skillstr > 0 and ",") or "") .. coloredname .. " (" .. pinfo.rank .. ")"
           ctype = "skill_"..ctype
        else 
	   if (not spellid) then
             dunnostr = dunnostr..((#dunnostr > 0 and ",") or "") .. coloredname 
	     ctype = "dunno"
           elseif addon:pinfo_skill_known(pinfo, spellid) then
             knownstr = knownstr..((#knownstr > 0 and ",") or "") .. coloredname 
             ctype = "known_"..ctype
           elseif profLvl == 0 or
	     (recipeClasses and dbc.data.class and not recipeClasses:find(dbc.data.class)) or 
	     (recipeFaction and dbc.data.faction ~= recipeFaction) or
	     (addon:pinfo_missing_spec(pinfo, spellid))
	     then
             unknownstr = unknownstr..((#unknownstr > 0 and ",") or "") .. coloredname 
             ctype = "unknown"
           else
             learnstr = learnstr..((#learnstr > 0 and ",") or "") .. coloredname 
             ctype = "learn_"..ctype
           end
        end
	local nrval = rcolortable[ctype].order -- calculate recipe color priority
	if nrval < rval then
	  rtype = ctype
	  rval = nrval
	end
      end
    end
   
    if addon.ttcachecnt > maxcachesz then
      addon.ttcache = {}
      addon.ttcachecnt = 1
    else
      addon.ttcachecnt = addon.ttcachecnt + 1
    end
    addon.ttcache[cacheid] = {}
    if not spellid then
      addon.ttcache[cacheid].biterr = true
    end
    if #unknownstr > 0 then
      table.insert(addon.ttcache[cacheid], { text = L["Not Known"]..": "..unknownstr, color = settings.recipecolor["unknown"] })
    end
    if #learnstr > 0 then
      table.insert(addon.ttcache[cacheid], { text = L["Learnable"]..": "..learnstr, color = settings.recipecolor["learn_other"] })
    end
    if #skillstr > 0 then
      table.insert(addon.ttcache[cacheid], { text = L["Skill too low"]..": "..skillstr, color = settings.recipecolor["skill_other"] })
    end
    if #knownstr > 0 then
      table.insert(addon.ttcache[cacheid], { text = L["Known"]..": "..knownstr, color = settings.recipecolor["known_other"] })
    end
    if #dunnostr > 0 then
      table.insert(addon.ttcache[cacheid], { text = L["Not sure"]..": "..dunnostr, color = settings.recipecolor["dunno"] })
    end
    addon.ttcache[cacheid].rtype = rtype
    addon:ShowTooltip(tt)
  end
end

addon.DropDownMenu = CreateFrame("Frame", addonName.."_DropDownMenu")
addon.DropDownMenu.displayMode = "MENU"
addon.DropDownMenu.onHide = function(...)
        MenuParent = nil
        MenuItem = nil
end

function addon:ShowDropdown(cname, pname)
        addon.DropDownMenu.cname = cname
        addon.DropDownMenu.pname = pname
        GameTooltip:Hide()
        HideDropDownMenu(1)
        ToggleDropDownMenu(1, nil, addon.DropDownMenu, "cursor", 0, 0)
end

local menuinfo = {}
addon.DropDownMenu.initialize = function(self, level)
        local cname, pname = addon.DropDownMenu.cname, addon.DropDownMenu.pname
        if not level then return end
        wipe(menuinfo)
        if level == 1 then
                -- Create the title of the menu
                menuinfo.isTitle = 1
                menuinfo.text = coloredcname(cname,nil,true)..((pname and (" / "..pname)) or "")
                menuinfo.notCheckable = 1
                UIDropDownMenu_AddButton(menuinfo, level)

                menuinfo.isTitle      = nil
                menuinfo.notCheckable = nil

                menuinfo.text = L["Whisper this player"]
                menuinfo.disabled = (cname == einstein) or (cname == charName)
                menuinfo.arg1 = nil
                menuinfo.func = function(button, arg1)
                        ChatFrame_SendTell(cname)
                      end
                UIDropDownMenu_AddButton(menuinfo, level)

                menuinfo.text = L["Invite this player"]
                menuinfo.disabled = (cname == einstein) or (cname == charName)
                menuinfo.arg1 = nil
                menuinfo.func = function(button, arg1)
                        InviteUnit(cname)
                      end
                UIDropDownMenu_AddButton(menuinfo, level)

                menuinfo.text = L["Delete this entry"]
                menuinfo.disabled = (cname == einstein) or (cname == charName and pname and GetSpellLink(pname))
                menuinfo.arg1 = nil
                menuinfo.func = function(button, arg1)
		        local setselect
                        if pname then
                           DB.chars[cname][pname] = nil
			   setselect = function() settings.treepath = { settings.treepath[1] } end
                        else
                           DB.chars[cname] = nil
			   setselect = function() settings.treepath = nil end
                           addon:RefreshChar()
                        end
			addon:RefreshWindow(setselect)
			end
                UIDropDownMenu_AddButton(menuinfo, level)

                menuinfo.text = L["Hide this entry"]
                menuinfo.disabled = false
                menuinfo.arg1 = nil
                menuinfo.func = function(button, arg1)
		        local pat = "/"..(pname or "*")
			if not cname or (cname == einstein and settings.grpbyprof) then
			   pat = "*"..pat
			else
			   pat = cname..pat
			end
		        settings.hide[pat] = true
			debug("Hiding "..pat)
			addon:RefreshWindow(function() settings.treepath = { settings.treepath[1] } end)
			addon:RefreshTooltips()
			end
                UIDropDownMenu_AddButton(menuinfo, level)

		if (not pname or settings.grpbyprof) then
                  menuinfo.text = L["Is an alt"]
                  menuinfo.disabled = (cname == einstein)
                  menuinfo.arg1 = nil
                  menuinfo.checked = (DB.chars[cname].data.alt == true)
                  menuinfo.func = function(button, arg1, arg2, checked)
		        checked = not checked
		        debug("Set cname alt flag to: "..(checked and "true" or "false"))
                        DB.chars[cname].data.alt = (checked or nil)
			addon:RefreshWindow()
			addon:RefreshTooltips()
                      end
                  UIDropDownMenu_AddButton(menuinfo, level)
		end

		if pname and cname ~= einstein then
		  menuinfo.text = L["Favorite"]
		  menuinfo.disabled = nolinkProf[pname]
		  menuinfo.arg1 = nil
                  menuinfo.checked = DB.chars[cname][pname].favorite
                  menuinfo.func = function(button, arg1, arg2, checked)
		        checked = not checked
		        debug("Set favorite flag to: "..(checked and "true" or "false"))
                        DB.chars[cname][pname].favorite = (checked or nil)
			addon:RefreshWindow()
			addon:RefreshTooltips()
                      end
                  UIDropDownMenu_AddButton(menuinfo, level)
		end

                -- Close menu item
                menuinfo.disabled     = nil
                menuinfo.text         = CLOSE
                menuinfo.func         = function() CloseDropDownMenus() end
                menuinfo.checked      = nil
                menuinfo.notCheckable = 1
                UIDropDownMenu_AddButton(menuinfo, level)
        end
end
