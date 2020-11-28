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

local scriptVersion = "1.3.14"

-- Start User Defineable Variables
local ToonBurnerName = nil -- (Optional) Dummy Selector Device (it shows the current burner state)
local ToonBurnerCVLevel = 10 --Level of selector defined in ToonBurnerName for status Burner state Central Heating
local ToonBurnerPreHeatLevel = 30 --Level of selector defined in ToonBurnerName for status Burner state heating to reach start level of program
local ToonModulatieDevice = "Toon Modulatie"
local PumpDeviceName = "Pomp_vloerverwarming" --Switch device that controls the pump
-- End User Defineable Variable

return {
    logging = {
        --level = domoticz.LOG_DEBUG, -- Uncomment to override the dzVents global logging setting
        marker = "dzPompVloerverwarming_v" .. scriptVersion
    },
    on = {
        timer = {
            "every other hour at daytime"
        },
        devices = {
            --ToonBurnerName
            ToonModulatieDevice
        }
    },
    execute = function(domoticz, item)
        if (item.isDevice) then
            -- Run Only if a device has changed on the Domoticz side...
            domoticz.log("Device " .. item.name .. " changed. Will change pump state accordingly", domoticz.LOG_DEBUG)

            --if item.level == ToonBurnerCVLevel or item.level == ToonBurnerPreHeatLevel then
            if item.percentage > 10 then
                domoticz.log("Toon informed the heating is burning.", domoticz.LOG_INFO)
                if domoticz.devices(PumpDeviceName).state == 'Off' then
                    domoticz.devices(PumpDeviceName).cancelQueuedCommands()
                    domoticz.devices(PumpDeviceName).switchOn()
                    domoticz.devices(PumpDeviceName).switchOn().afterSec(20) --Switch does not always honour the RFXCom command
                    domoticz.devices(PumpDeviceName).switchOn().afterSec(40) --Switch does not always honour the RFXCom command
                end
            else
                domoticz.log("Toon informed the heating is not burning anymore.", domoticz.LOG_INFO)
                if domoticz.devices(PumpDeviceName).state == 'On' then
                    domoticz.devices(PumpDeviceName).cancelQueuedCommands()
                    domoticz.devices(PumpDeviceName).switchOff().afterMin(15)
                    domoticz.devices(PumpDeviceName).switchOff().afterMin(16) --Switch does not always honour the RFXCom command
                    domoticz.devices(PumpDeviceName).switchOff().afterMin(17) --Switch does not always honour the RFXCom command
                end
            end
        elseif (item.isTimer) then
            if (domoticz.devices(PumpDeviceName).lastUpdate.hoursAgo > 23) then
                domoticz.log("Rotating the pump for ~5 minutes to prevent it from getting stuck or rust.",domoticz.LOG_INFO)
                --domoticz.devices(PumpDeviceName).switchOn().forSec(30).checkFirst()
                domoticz.devices(PumpDeviceName).cancelQueuedCommands()
                domoticz.devices(PumpDeviceName).switchOn()
                domoticz.devices(PumpDeviceName).switchOn().afterSec(30) --Switch does not always honour the RFXCom command
                domoticz.devices(PumpDeviceName).switchOn().afterMin(1) --Switch does not always honour the RFXCom command
                domoticz.devices(PumpDeviceName).switchOff().afterMin(6)
                domoticz.devices(PumpDeviceName).switchOff().afterMin(7) --Switch does not always honour the RFXCom command
                domoticz.devices(PumpDeviceName).switchOff().afterMin(8) --Switch does not always honour the RFXCom command
            end
        end
    end
}
