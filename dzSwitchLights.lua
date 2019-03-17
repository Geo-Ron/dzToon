local scriptVersion         = '2.1.01'
local SwitchGroup          	= 'Lampen Woonkamer'
local LuxVar                = 'UV_LuxThreshold'
local LuxDev                = 'Lux'
local ModeSelector          = "Automation" --Check if automation is not manual
local ModeSelectorLevelManual = 20

return {
    active = true,
	logging = {
		 -- level = domoticz.LOG_DEBUG, -- Uncomment to override the dzVents global logging setting
		marker = 'dzSwitchLights '..scriptVersion
	},
    on = {
        timer = {
            -- 'Every 5 minutes between 06:00 and 11:00',
            -- 'Every 15 minutes between 11:00 and 15:00',
            -- 'Every 5 minutes between 15:00 and 23:00',
            'at 06:00 on mon,tue,wed,thu,fri',
            -- 'at 07:15 on mon,tue,wed,thu,fri',
            'at 07:00 on sat,sun',
            'at 23:00 on mon,tue,wed,thu',
            'at 00:30 on sat,sun,mon'
            },
        devices = {
            LuxDev
            }
    },
    execute = function(domoticz, item)

        --Precheck if automation os manual overriden
        if (domoticz.devices(ModeSelector).level == ModeSelectorLevelManual) then
            domoticz.log('Domoticz automation set to MANUAL override.', domoticz.LOG_DEBUG)
        else
        --No manual override, so can continue    
        
            --Trigger is time based
            if (item.isTimer) then
                --Check if time to go to  bed
                if (item.trigger == 'at 23:00 on mon,tue,wed,thu' or item.trigger == 'at 00:30 on sat,sun,mon') then
                    domoticz.log('Bedtime, switch lights off triggered by'..item.trigger .. ' within the hour', domoticz.LOG_INFO)
                    --Switchoff random delay within the hour
                    domoticz.groups(SwitchGroup).switchOff().withinHour(1)
                    domoticz.groups(SwitchGroup).switchOff().afterMin(65) --double check to be sure
                    domoticz.groups(SwitchGroup).switchOff().afterMin(66) --double check to be sure
                
                --Wake up time is coming
                else
                    domoticz.groups(SwitchGroup).switchOn().withinMin(30)
                    domoticz.groups(SwitchGroup).switchOn().afterMin(31) --double check to be sure
                    domoticz.groups(SwitchGroup).switchOn().afterMin(32) --double check to be sure
            
                end
            --Trigger is not time based, so it is Luxdev based
            else

                --check lux and switch off or on if exceeds variable

                --If a lot of light and group is NOT off and last change more than an hour ago
                if (domoticz.devices(LuxDev).lux > domoticz.variables(LuxVar).value  and domoticz.groups(SwitchGroup).state ~= 'Off' and domoticz.groups(SwitchGroup).lastUpdate.minutesAgo > 60) then
                    domoticz.log('It is light enough and will switch '..SwitchGroup..' off. Light value is '..domoticz.devices(LuxDev).lux, domoticz.LOG_INFO)
                    domoticz.groups(SwitchGroup).switchOff()

                --If less light and group is off and last change more than an hour ago
                elseif (domoticz.devices(LuxDev).lux < domoticz.variables(LuxVar).value and domoticz.groups(SwitchGroup).state == 'Off' and domoticz.groups(SwitchGroup).lastUpdate.minutesAgo > 60) then
                    domoticz.log('It is too dark and will switch '..SwitchGroup..' on. Light value is '..domoticz.devices(LuxDev).lux, domoticz.LOG_INFO)
                    domoticz.groups(SwitchGroup).switchOn()
                end

            end

        end
    
    
        -- if (item.isTimer and (item.trigger = 'at 23:00 on mon,tue,wed,thu' or item.trigger = 'at 00:30 on sat,sun,mon'))
        -- --if ((domoticz.time.matchesRule('at 23:30 on mon,tue,wed,thu') or domoticz.time.matchesRule('at 01:00 on sat,sun,mon')) and domoticz.groups(SwitchGroup).state ~='Off') then
        --     --switch switchgroup switchOff
        --     if (domoticz.devices(ModeSelector).level ~= ModeSelectorLevelManual) then
        --         domoticz.log('Bedtime, switch lights off triggered by'..item.trigger .. ' within the hour', domoticz.LOG_INFO)
        --         domoticz.groups(SwitchGroup).switchOff().withinHour(1)
        --     else
        --         domoticz.log('Domoticz automation set to MANUAL. Otherwise would have turned off the lights.', domoticz.LOG_INFO)
        --       end
        -- else
        --     -- level 20 is HANDMATIG
        --     if (domoticz.devices(ModeSelector).level ~= ModeSelectorLevelManual) then
        --         domoticz.log('Domoticz automation normal', domoticz.LOG_INFO)
        --         --check lux and switch off or on if exceeds variable
        --         if (domoticz.devices(LuxDev).lux > domoticz.variables(LuxVar).value  and domoticz.groups(SwitchGroup).state ~= 'Off' and domoticz.groups(SwitchGroup).lastUpdate.minutesAgo > 60) then
        --             domoticz.log('It is light enough and will switch '..SwitchGroup..' off. Light value is '..domoticz.devices(LuxDev).lux, domoticz.LOG_INFO)
        --             domoticz.groups(SwitchGroup).switchOff()
        --         elseif (domoticz.devices(LuxDev).lux < domoticz.variables(LuxVar).value and domoticz.groups(SwitchGroup).lastUpdate.minutesAgo > 60 and domoticz.groups(SwitchGroup).state == 'Off') then
        --             domoticz.log('It is too dark and will switch '..SwitchGroup..' on. Light value is '..domoticz.devices(LuxDev).lux, domoticz.LOG_INFO)
        --             domoticz.groups(SwitchGroup).switchOn()
        --         end
        --     else
        --       domoticz.log('Domoticz automation set to MANUAL. Otherwise would have checked to turn on.', domoticz.LOG_INFO)
        --     end
            
        -- end
    end
}
