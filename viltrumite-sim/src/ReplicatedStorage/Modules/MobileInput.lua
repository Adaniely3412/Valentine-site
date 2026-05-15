-- Shared BindableEvent bridge for mobile → controller communication.
-- MobileController fires these; CombatController and FlightController listen.
-- Both run as LocalScripts in the same VM, so require() returns the same table.

local MobileInput = {}

local function makeEvent(name)
	local be  = Instance.new("BindableEvent")
	be.Name   = name
	MobileInput[name] = be
end

makeEvent("M1")
makeEvent("Block")
makeEvent("SonicClap")
makeEvent("ViltrumiteRush")
makeEvent("EarthShatter")
makeEvent("ThoraxStrike")
makeEvent("SupremeOverdrive")
makeEvent("FlightToggle")
makeEvent("FlightSprint")   -- held state: Fire(true) = sprint on, Fire(false) = sprint off

return MobileInput
