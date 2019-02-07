--[[
	Prerequisites
	==================================
	Domoticz v3.8837 or later (dzVents version 2.4 or later)
	NEEDS TO BE SPECIFIED
    Dummy switches that match the variables beneath
	CHANGE LOG: See https://github.com/Geo-Ron/dzVents/commits/master/dzPompVloerverwarming.lua
	THANKS AND CONFETTI FOR:
	- Myself
	
]] --

local scriptVersion = "1.0.01"

-- Start User Defineable Variables
local ToonBurnerName = "Toon BranderInfo" -- (Optional) Dummy Selector Device (it shows the current burner state)
local ToonBurnerCVLevel = 10 --Level of selector defined in ToonBurnerName for status Burner state Central Heating
local ToonBurnerPreHeatLevel = 30 --Level of selector defined in ToonBurnerName for status Burner state heating to reach start level of program
local PumpDeviceName = "Pomp_vloerverwarming" --Switch device that controls the pump
-- End User Defineable Variable

return {
    logging = {
        --level = domoticz.LOG_DEBUG, -- Uncomment to override the dzVents global logging setting
        marker = "dzPompVloerverwarmin_v" .. scriptVersion
    },
    on = {
        timer = {
            "Every hour"
        },
        devices = {
            ToonBurnerName
        }
    },
    execute = function(domoticz, item)
        if (item.isDevice) then
            -- Run Only if a device has changed on the Domoticz side...
            domoticz.log("Device " .. item.name .. " changed. Will change pump state accordingly", domoticz.LOG_DEBUG)
            if item.level == ToonBurnerCVLevel or item.level == ToonBurnerPreHeatLevel then
                domoticz.log("Toon informed the heating is burning.", domoticz.LOG_debug)
                domoticz.devices(PumpDeviceName).switchOn().checkFirst()
            else
                domoticz.log("Toon informed the heating is burning.", domoticz.LOG_debug)
                domoticz.devices(PumpDeviceName).switchOff().checkFirst()
            end
        elseif (item.isTimer) then
            domoticz.log("Rotating the pump to prevent it from getting stuck.", domoticz.LOG_debug)
            domoticz.devices(PumpDeviceName).switchOn().forSec(2).checkFirst()
        end
    end
}