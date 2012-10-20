local _, cClass = UnitClass("player")
if (cClass ~= "WARLOCK") then return end

local Quartz3 = LibStub("AceAddon-3.0"):GetAddon("Quartz3")
if not Quartz3 then error("Quartz3 not found!"); return end

local QuartzProcs = Quartz3:GetModule("Procs")
if not QuartzProcs then return end

function QuartzProcs:returnProcList()
	local tmplist = {
		-- Pyroclasm
		--[string.lower(GetSpellInfo(18093))] = { color={1,0,0}, name=GetSpellInfo(18093), },
		-- Empowered Imp
		--[string.lower(GetSpellInfo(47283))] = { color={0.93,0.98,0.51}, name=GetSpellInfo(47283), },
		-- Backdraft
		[string.lower(GetSpellInfo(117828))] = { color={1,0,0.5}, name=GetSpellInfo(117828), },
		-- Lifetap (glyph)
		--[string.lower(GetSpellInfo(63321))] = { color={0,0.5,1}, name=GetSpellInfo(63321), },
		-- Metamorphisis
		--[string.lower(GetSpellInfo(47241))] = { color={0.55,0,0.8}, name=GetSpellInfo(47241), },
		-- Immolation Aura
		--[string.lower(GetSpellInfo(50589))] = { color={1,0.5,0}, name=GetSpellInfo(50589), },
		-- Decimation
		[string.lower(GetSpellInfo(108869))] = { color={0.8,0.2,0}, name=GetSpellInfo(108869), },
		-- Voidwalker Sacrifice
		[string.lower(GetSpellInfo(7812))] = { color={0,0.5,1}, name=GetSpellInfo(7812), },
		-- Molten Core
		[string.lower(GetSpellInfo(122351))] = { color={1,0,0.5}, name=GetSpellInfo(122351), },
		-- Eradication
		--[string.lower(GetSpellInfo(64371))] = { color={0.93,0.98,0.51}, name=GetSpellInfo(64371), },
		-- Shadow Trance
		[string.lower(GetSpellInfo(17941))] = { color={1,0,0.5}, name=GetSpellInfo(17941), },
		-- Backlash
		[string.lower(GetSpellInfo(34936))] = { color={1,0.5,0}, name=GetSpellInfo(34936), },
		-- Improved Soulfire
		--[string.lower(GetSpellInfo(85383))] = { color={0.93,0.98,0.51}, name=GetSpellInfo(85383), },
	}
	return tmplist
end
