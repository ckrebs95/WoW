local mod	= DBM:NewMod("Galdarah", "DBM-Party-WotLK", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 7 $"):sub(12, -3))
mod:SetCreatureID(29306)
mod:SetModelID(27061)
--mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEvents(
)
