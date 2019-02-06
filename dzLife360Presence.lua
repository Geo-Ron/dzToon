--[[
	Prerequisites
	==================================
    Domoticz v3.8837 or later (dzVents version 2.4 or later)
    Life360PresencePlugin
	NEEDS TO BE SPECIFIED
    Dummy switches that match the variables beneath
	CHANGE LOG: See https://github.com/Geo-Ron/dzVents/commits/master/dzLife360Presence.lua
	THANKS AND CONFETTI FOR:
	- Myself
	
]] --

local scriptVersion = "1.8.01"

local AroundMaximumMins = 15
local ModeSelector = "Automation"
local ModeSelectorLevelNormal = 10
local ModeSelectorLevelManual = 20
local ModeSelectorLevelVacation = 30
local ModeSelectorLevelAway = 40
local ModeSelectorLevelAround = 50

return {
    active = true,
    logging = {
        --level = domoticz.LOG_DEBUG, -- Uncomment to override the dzVents global logging setting
        marker = "dzLife360Parser_v" .. scriptVersion
    },
    on = {
        devices = {
            "Life360 * Presence",
            "Life360 * Distance"
        }
    },
    execute = function(domoticz, dummy)
        -- check all Life360 Presence Detection
        local someonePresent = false
        local someoneAround = false
        domoticz.devices().filter(
            function(device)
                return (string.match(device.name, "Life360 - .+ Presence") ~= nil)
            end
        ).forEach(
            function(presence)
                if (presence.state == "On") then
                    someonePresent = true
                    domoticz.log("Current at home detected: " .. presence.name, domoticz.LOG_DEBUG)
                end
            end
        )

        domoticz.devices().filter(
            function(device)
                return (string.match(device.name, "Life360 - .+ Distance") ~= nil)
            end
        ).forEach(
            function(presence)
                domoticz.log("Current value: " .. tostring(presence.state), domoticz.LOG_DEBUG)
                if (tonumber(presence.state) < AroundMaximumMins) then
                    someoneAround = true
                    domoticz.log("Current around detected: " .. presence.name, domoticz.LOG_DEBUG)
                end
            end
        )

        domoticz.log("someoneAround: " .. tostring(someoneAround), domoticz.LOG_DEBUG)
        domoticz.log("someonePresent: " .. tostring(someonePresent), domoticz.LOG_DEBUG)

        if (domoticz.devices(ModeSelectorSecond).level ~= ModeSelectorLevelManual) then
            if (someoneAround == true and someonePresent == false) then
                domoticz.log("Changing automation status to: " .. ModeSelectorLevelAround, domoticz.LOG_DEBUG)
                if (domoticz.devices(ModeSelector).level ~= ModeSelectorLevelAround) then
                    domoticz.log("Switchting automation to Away(Around)", domoticz.LOG_INFO)
                    domoticz.devices(ModeSelector).switchSelector(ModeSelectorLevelAround)
                end
            elseif (someoneAround == false and someonePresent == false) then
                domoticz.log("Changing automation status to: " .. ModeSelectorLevelAway, domoticz.LOG_DEBUG)
                if (domoticz.devices(ModeSelector).level ~= ModeSelectorLevelAway) then
                    domoticz.log("Switchting automation to Away", domoticz.LOG_INFO)
                    domoticz.devices(ModeSelector).switchSelector(ModeSelectorLevelAway)
                end
            elseif (someonePresent == true) then
                domoticz.log("Changing automation status to: " .. ModeSelectorLevelNormal, domoticz.LOG_DEBUG)
                if (domoticz.devices(ModeSelector).level ~= ModeSelectorLevelNormal) then
                    domoticz.log("Switchting automation to Normal", domoticz.LOG_INFO)
                    domoticz.devices(ModeSelector).switchSelector(ModeSelectorLevelNormal)
                end
            end
        end
    end
}
