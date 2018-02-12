local scriptVersion                 = '1.6.38'


return {
	logging = {
		--level = domoticz.LOG_DEBUG, -- Uncomment to override the dzVents global logging setting
		marker = 'Automation '..scriptVersion
	},
	on = {
        timer = {
            --'Every minute',
            'Every 15 minutes between 08:00 and 22:00'
            },
		devices = {
			'Automation',
			'Toon Scenes'
		}
	},
	execute = function(domoticz,device)

    local ModeSelector                  = 'Automation'
    local ModeSelectorSecond            = 'Automation Secundary'	    
    local OperationMode           = domoticz.devices(ModeSelector).state
    local OperationSecondMode     = domoticz.devices(ModeSelectorSecond).state	
	domoticz.log('Change'..device.name..' level:'..device.level, domoticz.LOG_DEBUG)
	
	    if (device.isTimer) then
            if (domoticz.devices('Toon Scenes').level == 60 and domoticz.devices('Automation').level ~= 30) then
                -- Systeem status Vakantie. Wordt opgelegd door Toon
                --Echter pakt dit script NIET de device change op die door het Toon-Timer script gedaan wordt.
    			domoticz.log('Thermostat notified Domoticz of vacation mode.', domoticz.LOG_INFO)
    			domoticz.devices(ModeSelector).switchSelector(30).silent()
    			domoticz.devices(ModeSelectorSecond).switchSelector(10)
            elseif (domoticz.devices('Toon Scenes').level ~= 60 and domoticz.devices('Automation').level == 30) then
                -- Systeem status Vakantie. Wordt opgelegd door Toon
                --Echter pakt dit script NIET de device change op die door het Toon-Timer script gedaan wordt.
                domoticz.log('Thermostat notified Domoticz of disabled vacation mode. Changing automation to normal', domoticz.LOG_INFO)
			    domoticz.devices(ModeSelector).switchSelector(10)
			    domoticz.devices(ModeSelectorSecond).switchSelector(10)
            end
	    elseif (device.name == 'Automation' and device.level == 10) then
		-- Systeem status Normaal of iedereen is weer terug
			
			-- Thermostaat op auto programma zetten
			domoticz.log('Changing thermostat program to Auto.', domoticz.LOG_INFO)
			domoticz.devices('Toon Auto Programma').switchSelector(20)
			time = os.date("*t")
			if (time.hour < 18) then
				domoticz.log('Voor 18u. Keukenradio aan.', domoticz.LOG_INFO)
				domoticz.devices('Radio Keuken').switchOn().CheckFirst()
			end
		
		elseif (device.name == 'Automation' and device.level == 20) then
		-- Systeem status handmatig
			domoticz.log('Systeem staat op handmatig. Ik doe NIKS!', domoticz.LOG_DEBUG)
		elseif (device.name == 'Automation' and device.level == 30 and domoticz.devices('Toon Scenes').level ~= 60) then
		-- Systeem status Vakantie
			-- Automation met de hand op vakantie gezet. Dit kan niet. wordt terug gezet naar normaal.
			domoticz.log('Domoticz set to vacation mode. This is not possible. Needs to be done through thermostat.', domoticz.LOG_ERROR)
			domoticz.log('Domoticz switch '..device.name..' will be reverted to level '..tostring(device.lastlevel)..'.', domoticz.LOG_ERROR)
			if device.lastlevel == nil then
			    device.switchSelector(10)
			else
			    device.switchSelector(device.lastlevel).silent()
			end
		elseif (device.name == 'Automation' and device.level == 40 and OperationSecondMode ~= 'Aanwezigheid Override' and OperationSecondMode ~= 'Vakantie Kinderen en Aanwezigheid Override') then
		-- Systeem status Weg
			domoticz.log('Iedereen is zojuist vertrokken.', domoticz.LOG_DEBUG)
			
			--Verwarming handmatig op 16 graden zetten
			domoticz.log('Changing thermostat program to temporary and temp to 17.5 degrees.', domoticz.LOG_INFO)
			domoticz.devices('Toon Auto Programma').switchSelector(30)
			domoticz.devices('Toon Thermostaat').updateSetPoint(17.5)
			time = os.date("*t")
			if (time.hour < 18) then
				domoticz.log('Voor 18u. Keukenradio uit.', domoticz.LOG_INFO)
				domoticz.devices('Radio Keuken').switchOff().CheckFirst()
			end		

		elseif (device.name == 'Toon Scenes' and device.level == 60) then
		-- Systeem status Vakantie. Wordt opgelegd door Toon
			domoticz.log('Thermostat notified Domoticz of vacation mode.', domoticz.LOG_INFO)
			domoticz.devices(ModeSelector).switchSelector(30).silent()
			domoticz.devices(ModeSelectorSecond).switchSelector(10)
		
		elseif (device.name == 'Toon Scenes' and device.level ~= 60 and domoticz.devices(ModeSelector).level == 30) then
		-- Systeem status WAS Vakantie. Wordt opgelegd door Toon
			domoticz.log('Thermostat notified Domoticz of disabled vacation mode. Changing automation to normal', domoticz.LOG_INFO)
			domoticz.devices(ModeSelector).switchSelector(10)
			domoticz.devices(ModeSelectorSecond).switchSelector(10)
		
		end
	
		
		
	end
}
