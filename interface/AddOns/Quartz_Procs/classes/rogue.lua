local _, cClass = UnitClass("player")
if (cClass ~= "ROGUE") then return end

local Quartz3 = LibStub("AceAddon-3.0"):GetAddon("Quartz3")
if not Quartz3 then error("Quartz3 not found!"); return end

local QuartzProcs = Quartz3:GetModule("Procs")
if not QuartzProcs then return end

function QuartzProcs:returnProcList()
	local tmplist = {
		-- Vendetta
		[string.lower(GetSpellInfo(79140))] = { color={1,0,0}, name=GetSpellInfo(79140), },
		-- Sprint
		[string.lower(GetSpellInfo(2983))] = { color={0,1,0}, name=GetSpellInfo(2983), },
		-- Adrenline Rush
		[string.lower(GetSpellInfo(13750))] = { color={0.7,0.1,0.1}, name=GetSpellInfo(13750), },
		-- Blade Flurry
		[string.lower(GetSpellInfo(13877))] = { color={1,0.5,0}, name=GetSpellInfo(13877), },
		-- Cloak of Shadows
		[string.lower(GetSpellInfo(31224))] = { color={1,0,0.5}, name=GetSpellInfo(31224), },
		-- Evasion
		[string.lower(GetSpellInfo(5277))] = { color={0.93,0.98,0.51}, name=GetSpellInfo(5277), },
		-- Vanish
		[string.lower(GetSpellInfo(1856))] = { color={0.28,0.24,0.55}, name=GetSpellInfo(1856), },
		-- Killing Spree
		[string.lower(GetSpellInfo(51690))] = { color={0.7,0.1,0.1}, name=GetSpellInfo(51690), },
		-- Slice and Dice
		[string.lower(GetSpellInfo(5171))]  = { color={1,0.5,0}, name=GetSpellInfo(5171), },
		-- Shadow Dance
		[string.lower(GetSpellInfo(51713))] = { color={0.7,0.1,0.1}, name=GetSpellInfo(51713), },
		-- Feint (aoe reduction buff)
		[string.lower(GetSpellInfo(1966))] = { color={0.4,0.4,1}, name=GetSpellInfo(1966), },
		-- Envenom
		[string.lower(GetSpellInfo(32645))] = { color={0,1,0}, name=GetSpellInfo(32645), },
	}
	return tmplist
end
