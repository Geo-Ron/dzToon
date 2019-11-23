local scriptVersion                 = '1.2.4'
local SwitchGroup          	        = 'Weklampjes'
local Selector                      = 'Wekkers_Weekend'
local ModeSelector                  = 'Automation'
local ModeSelectorSecond            = 'Automation Secundary'
local Endurance                     = 30

return {
    active = true,
	logging = {
		-- level = domoticz.LOG_DEBUG, -- Uncomment to override the dzVents global logging setting
		marker = 'Wekkers '..scriptVersion
	},
    on = {
        timer = {
            -- 'Every Minute',
            'at 6:45',
            'at 7:30',
            'at 7:45',
            'at 8:00'
            }
    },
    execute = function(domoticz)
        domoticz.log('Triggered Wekkers script', domoticz.LOG_DEBUG)
        
        local weekdag = os.date('*t').wday

        -- if (domoticz.time.day == 1 or domoticz.time.day == 7) then
        if (weekdag == 1 or weekdag == 7) then
            weekend = true
            domoticz.log('Is Weekday 1 of 7, so just Set weekend to ' .. tostring(weekend), domoticz.LOG_DEBUG)
        else
            weekend = false
            domoticz.log('Is NOT Weekday 1 of 7, so just Set weekend to ' .. tostring(weekend), domoticz.LOG_DEBUG)
        end
        
        local OperationMode           = domoticz.devices(ModeSelector).state
        local OperationSecondMode     = domoticz.devices(ModeSelectorSecond).state
        local TimeSelected            = domoticz.devices(Selector).state
        
        if (weekend or OperationSecondMode == 'Vakantie Kinderen' or OperationSecondMode == 'Vakantie Kinderen en Aanwezigheid Override') then
            Uitslapen = true
        else
            Uitslapen = false
        end

        -- for debugging only
        domoticz.log('Running Debug.', domoticz.LOG_DEBUG)
        domoticz.log('Operational Mode: '..OperationMode, domoticz.LOG_DEBUG)
        domoticz.log('TimeSelected: '..TimeSelected,domoticz.LOG_DEBUG)
        domoticz.log('Current Day: domoticz.time.day='.. domoticz.time.day, domoticz.LOG_DEBUG)
        domoticz.log('Weekdag: '..weekdag,domoticz.LOG_DEBUG)
        domoticz.log('Weekend: '..tostring(weekend),domoticz.LOG_DEBUG)
        domoticz.log('Lampjes State: '..domoticz.groups(SwitchGroup).state,domoticz.LOG_DEBUG)
        -- domoticz.log('Lampjes State: '..domoticz.groups(SwitchGroup).dump(),domoticz.LOG_DEBUG)
        if (domoticz.time.matchesRule('at 6:45') and OperationMode == 'Normaal' and not Uitslapen) then
            --normale operatie, geen weekend
            domoticz.log('Normal operation. Waking everyone.', domoticz.LOG_INFO)
            domoticz.groups(SwitchGroup).switchOn().forMin(Endurance)
        elseif (domoticz.time.matchesRule('at 7:30') and TimeSelected == '7h30' and OperationMode == 'Normaal' and Uitslapen) then
            -- normale operatie, wel weekend en selector op deze tijd
            domoticz.log('Weekend or Vacation. Waking everyone at set time.', domoticz.LOG_INFO)
            domoticz.groups(SwitchGroup).switchOn().forMin(Endurance)
        elseif (domoticz.time.matchesRule('at 7:45') and TimeSelected == '7h45' and OperationMode == 'Normaal' and Uitslapen) then
            -- normale operatie, wel weekend en selector op deze tijd
            domoticz.log('Weekend or Vacation. Waking everyone at set time.', domoticz.LOG_INFO)
            domoticz.groups(SwitchGroup).switchOn().forMin(Endurance)
        elseif (domoticz.time.matchesRule('at 8:00') and TimeSelected == '8h00' and OperationMode == 'Normaal' and Uitslapen) then
            -- normale operatie, wel weekend en selector op deze tijd
            domoticz.log('Weekend or Vacation. Waking everyone at set time.', domoticz.LOG_INFO)
            domoticz.groups(SwitchGroup).switchOn().forMin(Endurance)
        end
    end
}