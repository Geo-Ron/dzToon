local scriptVersion         = '1.0.05'
local SwitchGroup          	= 'Lampen Woonkamer'
local LuxVar                = 'UV_LuxThreshold'
local LuxDev                = 'Lux'

return {
    active = true,
	logging = {
		 -- level = domoticz.LOG_DEBUG, -- Uncomment to override the dzVents global logging setting
		marker = 'SwitchLights '..scriptVersion
	},
    on = {
        timer = {
            -- 'Every 5 minutes between 06:00 and 11:00',
            -- 'Every 15 minutes between 11:00 and 15:00',
            -- 'Every 5 minutes between 15:00 and 23:00',
            'at 06:30 on mon,tue,wed,thu,fri',
            -- 'at 07:15 on mon,tue,wed,thu,fri',
            'at 07:00 on sat,sun',
            'at 23:30 on mon,tue,wed,thu',
            'at 01:00 on sat,sun,mon'
            },
        devices = {
            LuxDev
            }
    },
    execute = function(domoticz)
        if ((domoticz.time.matchesRule('at 23:30 on mon,tue,wed,thu') or domoticz.time.matchesRule('at 01:00 on sat,sun,mon')) and domoticz.groups(SwitchGroup).state ~='Off') then
            --switch switchgroup switchOff
            domoticz.log('Bedtime, switch lights off '..SwitchGroup, domoticz.LOG_INFO)
            domoticz.groups(SwitchGroup).switchOff()
        else
            -- level 20 is HANDMATIG
            if (domoticz.devices('Automation').level ~= 20) then
                domoticz.log('Domoticz automation normal', domoticz.LOG_INFO)
                --check lux and switch off or on if exceeds variable
                if (domoticz.devices(LuxDev).lux > domoticz.variables(LuxVar).value  and domoticz.groups(SwitchGroup).state ~= 'Off' and domoticz.groups(SwitchGroup).lastUpdate.minutesAgo > 60) then
                    domoticz.log('It is light enough and will switch '..SwitchGroup..' off. Light value is '..domoticz.devices(LuxDev).lux, domoticz.LOG_INFO)
                    domoticz.groups(SwitchGroup).switchOff()
                elseif (domoticz.devices(LuxDev).lux < domoticz.variables(LuxVar).value and domoticz.groups(SwitchGroup).lastUpdate.minutesAgo > 60 and domoticz.groups(SwitchGroup).state == 'Off') then
                    domoticz.log('It is too dark and will switch '..SwitchGroup..' on. Light value is '..domoticz.devices(LuxDev).lux, domoticz.LOG_INFO)
                    domoticz.groups(SwitchGroup).switchOn()
                end
            else
              domoticz.log('Domoticz automation set to MANUAL', domoticz.LOG_INFO)
            end
            
        end
    end
}
