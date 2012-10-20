local _, cClass = UnitClass("player")
if (cClass ~= "PRIEST") then return end

local Quartz3 = LibStub("AceAddon-3.0"):GetAddon("Quartz3")
if not Quartz3 then error("Quartz3 not found!"); return end

local QuartzProcs = Quartz3:GetModule("Procs")
if not QuartzProcs then return end

function QuartzProcs:returnProcList()
	local tmplist = {
		-- Surge of Light
		[string.lower(GetSpellInfo(65767))] = { color={0.93,0.98,0.51}, name=GetSpellInfo(65767), },
		-- Pain Suppression
		[string.lower(GetSpellInfo(33206))] = { color={0,0.5,1}, name=GetSpellInfo(33206), },
		-- Power Infusion
		[string.lower(GetSpellInfo(10060))] = { color={1,0.5,0}, name=GetSpellInfo(10060), },
		-- Borrowed Time
		[string.lower(GetSpellInfo(59889))] = { color={1,0.5,0}, name=GetSpellInfo(59889), },
		-- Serendipity
		[string.lower(GetSpellInfo(63735))] = { color={0,0,1}, maxc=3, name=GetSpellInfo(63735), },
		-- Inner Fire
		[string.lower(GetSpellInfo(588))] = { color={0.4,0.4,0}, name=GetSpellInfo(588), },

		
		-- Dispersion
		[string.lower(GetSpellInfo(47585))] = { color={1,0,0.5}, name=GetSpellInfo(47585), },
		-- Mind melt
		[string.lower(GetSpellInfo(87160))] = { color={1,0,0.5}, name=GetSpellInfo(87160), },
		-- Shadow Orb
		[string.lower(GetSpellInfo(77487))] = { color={1,0,0.5}, name=GetSpellInfo(77487), },
		--Evangelism
		[string.lower(GetSpellInfo(81661))] = { color={0.79,0.78,0.35}, name=GetSpellInfo(81661), },
		-- Dark Evangelism 201 199 89
		--[string.lower(GetSpellInfo(87118))] = { color={0.79,0.78,0.35}, name=GetSpellInfo(87118), },
		-- Archangel
		[string.lower(GetSpellInfo(81700))] = { color={0.93,0.98,0.51}, name=GetSpellInfo(81700), },
		-- Dark Archangel
		[string.lower(GetSpellInfo(87153))] = { color={1,0,0.5}, name=GetSpellInfo(87153), },
		-- Chakra: Prayer of Healing
		[string.lower(GetSpellInfo(81206))] = { color={0,1,0}, name=GetSpellInfo(81206), },
		-- Chakra: Renew
		--[string.lower(GetSpellInfo(81207))] = { color={0,1,0}, name=GetSpellInfo(81207), },
		-- Chakra: Heal
		--[string.lower(GetSpellInfo(81208))] = { color={0,1,0}, name=GetSpellInfo(81208), },
		-- Chakra: Smite
		--[string.lower(GetSpellInfo(81209))] = { color={0,1,0}, name=GetSpellInfo(81209), },
		-- Empowered Shadow
		--[string.lower(GetSpellInfo(95799))] = { color={1,0,0.5}, name=GetSpellInfo(95799), },
	}
	return tmplist
end