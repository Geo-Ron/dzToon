--[[
	Prerequisits
	==================================
	Domoticz v3.8837 or later (dzVents version 2.4 or later)
	User Variable named UV_ToonIP type string, that holds the internal Toon IP
    Dummy switches that match the variables beneath

	CHANGE LOG: See https://github.com/Geo-Ron/dzVents/commits/master/dzToon.lua


]]--


 local scriptVersion = '2.2.05'
 local originalVersionUrl = 'https://www.domoticz.com/forum/viewtopic.php?f=34&t=11421'
 local originalAuthor = 'Maes'
 
---- Variables to match dummy switches withing Domoticz
 local ToonIPUserVariable               = 'UV_ToonIP' -- Specification of user variable that hold the Toon IP
 local ToonThermostatSensorName         = 'Toon Thermostaat' -- Sensor showing current setpoint
 local ToonTemperatureSensorName        = 'Toon Temperatuur' -- Sensor showing current room temperature
 local ToonScenesSensorName             = 'Toon Scenes' -- Sensor showing current program
     local ScenesManualLevel            = 50 -- Manual
     local ScenesComfortLevel           = 40 -- Comfort
     local ScenesHomeLevel              = 30 -- Home
     local ScenesSleepLevel             = 20 -- Sleep
     local ScenesAwayLevel              = 10 -- Away
     local ScenesVacationLevel          = 60 -- Vacation
 local ToonAutoProgramSensorName        = 'Toon Auto Programma' -- Sensor showing current auto program status
     local AutoProgramNoLevel           = 10 -- Auto Program Disabled
     local AutoProgramYesLevel          = 20 -- Auto Program Enabled
     local AutoProgramTempLevel         = 30 -- Auto Program Temporary Override
 local ToonProgramInformationSensorName = 'Toon Program Informatie' -- Sensor showing displaying program information status
 local ToonboilerInTempName             = 'BoilerInletTemp' -- Sensor inlet temperature
 local ToonboilerOutTempName            = 'BoilerOutletTemp' -- Sensor outlet temperature
 local ToonboilerPressure               = 'BoilerPressure' -- ToonboilerPressure
 local ToonModulation                   = 'Toon Modulatie' -- ToonboilerPressure
 local ToonBurnerName                   = 'Toon BranderInfo'
    local ToonBurnerOffLevel            = 0 --Burner state off
    local ToonBurnerCVLevel             = 10 --Burner state Central Heating
    local ToonBurnerHotWaterLevel       = 20 --Burner state Hot Water Tap
    local ToonBurnerPreHeatLevel        = 30 --Burner state heating to reach level of program
----- End Variables
    
 --local DomoticzIP = domoticz.variables('UV_DomoticzIP').value
 
 return {
	logging = {
		--level = domoticz.LOG_DEBUG, -- Uncomment to override the dzVents global logging setting
		marker = 'dzToonThermostat v'..scriptVersion
	},
	on = {
		timer = {
			'every minute'
		},
		devices = {
			ToonThermostatSensorName,
			ToonScenesSensorName,
			ToonAutoProgramSensorName
		}
	},
	execute = function(domoticz, item)

    local ToonIP = domoticz.variables(ToonIPUserVariable).value

        if (item.isDevice) then
            -- Run Only if a device has changed on the Domoticz side...
            -- Note that the OpenURL call is made AFTER the script has finished
            domoticz.log('Device '.. item.name ..' changed.', domoticz.LOG_DEBUG)
            --Run when device Changed
		    --domoticz.openURL(string.format('http://%s/happ_thermstat?action=setSetpoint&Setpoint=%s', ToonIP, device.SetPoint*100))
		    --item.dump()
		    if item.name == ToonThermostatSensorName then
		        local NewToonSetPoint = domoticz.utils.round(item.setPoint, 2)
    		    domoticz.log('Try to set Toon setpoint to '.. NewToonSetPoint*100, domoticz.LOG_DEBUG)
    			domoticz.openURL('http://'.. ToonIP ..'/happ_thermstat?action=setSetpoint&Setpoint='..NewToonSetPoint*100)
    			domoticz.log('Updating Toon thermostat sensor (from Domoticz to Toon) to new set point: '.. NewToonSetPoint*100)
    		elseif item.name == ToonScenesSensorName then 
    		    domoticz.log('Updating Toon Scene setting based on  '.. item.name, domoticz.LOG_DEBUG)
		        if item.level == 0 then 
		            domoticz.log('Toon Scene change to off.', domoticz.LOG_INFO)
		            domoticz.openURL('http://'.. ToonIP ..'/happ_thermstat?action=setSetpoint&Setpoint=69')
		        elseif item.level == ScenesManualLevel then 
		            domoticz.log('Toon Scene change to manual.', domoticz.LOG_INFO)
    		    elseif item.level == ScenesComfortLevel then 
    		        domoticz.log('Toon Scene change to Comfort.', domoticz.LOG_INFO)
    		        domoticz.openURL('http://'.. ToonIP ..'/happ_thermstat?action=changeSchemeState&state=2&temperatureState=0')
		        elseif item.level == ScenesHomeLevel then       
		            domoticz.log('Toon Scene change to Home.', domoticz.LOG_INFO)
		            domoticz.openURL('http://'.. ToonIP ..'/happ_thermstat?action=changeSchemeState&state=2&temperatureState=1')
	            elseif item.level == ScenesSleepLevel then      
	                domoticz.log('Toon Scene change to Sleep.', domoticz.LOG_INFO)
	                domoticz.openURL('http://'.. ToonIP ..'/happ_thermstat?action=changeSchemeState&state=2&temperatureState=2')
                elseif item.level == ScenesAwayLevel then       
                    domoticz.log('Toon Scene change to Away.', domoticz.LOG_INFO)
                    domoticz.openURL('http://'.. ToonIP ..'/happ_thermstat?action=changeSchemeState&state=2&temperatureState=3')
                elseif item.level == ScenesVacationLevel then 
                    domoticz.log('Toon Scene change to Vacation.', domoticz.LOG_INFO)
                end
            elseif item.name == ToonAutoProgramSensorName then 
                domoticz.log('Updating Toon Auto Program based on  '.. item.name..' level is '..item.level, domoticz.LOG_DEBUG)
                if item.level == 0 then
                    domoticz.log('Toon Auto Program state OFF should be disabled within Domoticz. This is not used.', domoticz.LOG_ERROR)
                elseif item.level == AutoProgramNoLevel then
                    domoticz.log('Toon Auto Program change to Disabled.', domoticz.LOG_INFO)
                    domoticz.openURL('http://'.. ToonIP ..'/happ_thermstat?action=changeSchemeState&state=0')
                elseif item.level == AutoProgramYesLevel then
                    domoticz.log('Toon Auto Program change to Enabled.', domoticz.LOG_INFO)
                    domoticz.openURL('http://'.. ToonIP ..'/happ_thermstat?action=changeSchemeState&state=1')
                elseif item.level == AutoProgramTempLevel then
                    domoticz.log('Toon Auto Program change to Temporary, but that has no function from this Point Of View. This change will be reverted.', domoticz.LOG_INFO)
                end
                    
            end
        end

        if (item.isTimer) then
            -- Main Program
            -- Run Every Minute
    
            -- Let us handle json
            -- local json = assert(loadfile "C:\\Program Files (x86)\\Domoticz\\scripts\\lua\\json.lua")()  -- For Windows
            -- local json = assert(loadfile "/home/maes/domoticz/scripts/lua/JSON.lua")()  -- For Linux
            -- json = assert(loadfile "/home/pi/domoticz/scripts/lua/JSON.lua")()  -- For Raspberry
            json = assert(loadfile "/usr/local/share/domoticz/scripts/lua/JSON.lua")()  -- For Raspberry
            
            ----------- Fetching Thermostat Info -----------------------
            local handle = assert(io.popen(string.format('curl http://%s/happ_thermstat?action=getThermostatInfo', ToonIP)))
                local ThermostatInfo = handle:read('*all')
            handle:close()
            
            local jsonThermostatInfo = json:decode(ThermostatInfo)
            ----
            ----------- Fetching Boiler Info -----------------------
            local handle = assert(io.popen(string.format('curl http://%s/boilerstatus/boilervalues.txt', ToonIP)))
            local BoilerInfo = handle:read('*all')
            handle:close()
    
            BoilerInfo = string.gsub(BoilerInfo, ",}", "}") -- JSON data from Toon contains a extra "," which should not be there.
            jsonBoilerInfo = json:decode(BoilerInfo)
            ----
            -- Quit with error if fetched information is nill
            if jsonThermostatInfo == nil or jsonBoilerInfo == nill then
                domoticz.log('No thermostat of boiler information fetched! Tried accessing at ip ' ..ToonIP, domoticz.LOG_ERROR) 
                return
            end
            ---
    
            -- Parsing Fetched Data
            local currentboilerInTemp = tonumber(jsonBoilerInfo.boilerInTemp)
            local currentboilerOutTemp = tonumber(jsonBoilerInfo.boilerOutTemp)
            local currentboilerPressure = domoticz.utils.round(tonumber(jsonBoilerInfo.boilerPressure), 1)
            local currentModulation = tonumber(jsonThermostatInfo.currentModulationLevel)
            local currentBurnerInfo = tonumber(jsonThermostatInfo.burnerInfo)
                -- Translate the toon burner info to selector for current burner info
            	if currentBurnerInfo == 0 or currentBurnerInfo == nil then currentBurnerInfo = ToonBurnerOffLevel -- uit
                elseif currentBurnerInfo == 1 then currentBurnerInfo = ToonBurnerCVLevel -- cv aan
                elseif currentBurnerInfo == 2 then currentBurnerInfo = ToonBurnerHotWaterLevel -- warmwater aan
                elseif currentBurnerInfo == 3 then currentBurnerInfo = ToonBurnerPreHeatLevel -- warmwater aan
                else domoticz.log('Device '.. ToonBurnerName ..'changed to unknown value '..tostring(currentBurnerInfo), domoticz.LOG_ERROR)
                end
            local currentSetpoint = domoticz.utils.round(tonumber(jsonThermostatInfo.currentSetpoint) / 100, 2)
            local currentTemperature = domoticz.utils.round(tonumber(jsonThermostatInfo.currentTemp) / 100, 1)
            local currentProgramState = tonumber(jsonThermostatInfo.programState)
                -- Translate the toon program atate to selector for current program state
                if currentProgramState == 0 then currentProgramState = AutoProgramNoLevel -- No
                elseif currentProgramState == 1 then currentProgramState = AutoProgramYesLevel -- Yes
                elseif currentProgramState == 2 then currentProgramState = AutoProgramTempLevel -- Temporary
                else domoticz.log('currentProgramState unknown: state is '.. currentProgramState, domoticz.LOG_ERROR)  
                end      
            local currentActiveState = tonumber(jsonThermostatInfo.activeState)
                -- Translate the toon scene info to selector for current scene state
                if currentActiveState == -1 then currentActiveState = ScenesManualLevel -- Manual
                elseif currentActiveState == 0 then currentActiveState = ScenesComfortLevel -- Comfort
                elseif currentActiveState == 1 then currentActiveState = ScenesHomeLevel -- Home
                elseif currentActiveState == 2 then currentActiveState = ScenesSleepLevel -- Sleep
                elseif currentActiveState == 3 then currentActiveState = ScenesAwayLevel -- Away
                elseif currentActiveState == 4 then currentActiveState = ScenesVacationLevel -- Vacation 
                else domoticz.log('currentActiveState unknown: state is '.. currentActiveState, domoticz.LOG_ERROR)
                end
            local currentNextTime = jsonThermostatInfo.nextTime
            local currentNextSetPoint = tonumber(jsonThermostatInfo.nextSetpoint) / 100
            local currentBoiletSetPoint = jsonThermostatInfo.currentInternalBoilerSetpoint
            ----
            ---- Printing Debug information
            domoticz.log('Fetched currentboilerInTemp value     ' ..currentboilerInTemp, domoticz.LOG_DEBUG)
            domoticz.log('Fetched currentboilerOutTemp value    ' ..currentboilerOutTemp, domoticz.LOG_DEBUG)
            domoticz.log('Fetched currentboilerPressure value   ' ..currentboilerPressure, domoticz.LOG_DEBUG)
            domoticz.log('Fetched currentBurnerInfo value       ' ..currentBurnerInfo, domoticz.LOG_DEBUG)
            domoticz.log('Fetched currentModulation value       ' ..currentModulation, domoticz.LOG_DEBUG)
            domoticz.log('Fetched currentSetpoint value         ' ..currentSetpoint, domoticz.LOG_DEBUG)
            domoticz.log('Fetched currentTemperature value      ' ..currentTemperature, domoticz.LOG_DEBUG)
            domoticz.log('Fetched currentProgramState value     ' ..currentProgramState, domoticz.LOG_DEBUG)
            domoticz.log('Fetched currentActiveState value      ' ..currentActiveState, domoticz.LOG_DEBUG)
            domoticz.log('Fetched currentNextTime value         ' ..currentNextTime, domoticz.LOG_DEBUG)
            domoticz.log('Fetched currentNextSetPoint value     ' ..currentNextSetPoint, domoticz.LOG_DEBUG)
            ----
            -- Start changing selectors if needed.
            -- Update the thermostat sensor to current setpoint
            if domoticz.utils.round(domoticz.devices(ToonThermostatSensorName).setPoint, 2) ~= currentSetpoint then
                domoticz.log('Updating Domoticz thermostat sensor (from Toon to Domoticz) to new set point: ' ..currentSetpoint)
                domoticz.devices(ToonThermostatSensorName).updateSetPoint(currentSetpoint).silent()
            end
            -- Update the temperature sensor to current room temperature
            if domoticz.utils.round(domoticz.devices(ToonTemperatureSensorName).temperature, 1) ~= currentTemperature then 
                domoticz.log('Updating the temperature sensor to new value: ' ..currentTemperature)
                domoticz.devices(ToonTemperatureSensorName).updateTemperature(currentTemperature).silent()
            end
            
            -- Update the toon scene selector sensor to current program state
            if domoticz.devices(ToonScenesSensorName).level ~= currentActiveState then  -- Update toon selector if it has changed
                domoticz.log('Updating Toon Scenes selector to: '..currentActiveState)
                domoticz.devices(ToonScenesSensorName).switchSelector(currentActiveState).silent()
            end
            -- Updates the toon auto program switch 
            if domoticz.devices(ToonAutoProgramSensorName).level ~= currentProgramState then -- Update toon auto program selector if it has changed
                domoticz.log('Updating Toon Auto Program selector to: '..currentProgramState)
                domoticz.devices(ToonAutoProgramSensorName).switchSelector(currentProgramState).silent()
            end
            -- Updates the toon program information text box
            if currentNextTime == 0 or currentNextSetPoint == 0 then
                ToonProgramInformationSensorValue = 'Op ' ..currentSetpoint.. '°'
            else
                ToonProgramInformationSensorValue = 'Om ' ..os.date('%H:%M', currentNextTime).. ' op ' ..currentNextSetPoint.. '°'
            end
            -- Update Toon Program Information
            if domoticz.devices(ToonProgramInformationSensorName).text ~= ToonProgramInformationSensorValue then
                domoticz.log('Updating Toon Program Information to: '..ToonProgramInformationSensorValue)
                domoticz.devices(ToonProgramInformationSensorName).updateText(ToonProgramInformationSensorValue)
            end
            -- Update toon burner selector if it has changed
            if domoticz.devices(ToonBurnerName).level ~= currentBurnerInfo then 
                domoticz.log('Updating Toon burner info to new level '..currentBurnerInfo)
                domoticz.devices(ToonBurnerName).switchSelector(currentBurnerInfo).silent()
            end
            -- Update ModulationInfo
            if domoticz.devices(ToonModulation).percentage ~= currentModulation then  
                domoticz.log('Updating modulation info to new value: '..currentModulation..'%')
                domoticz.devices(ToonModulation).updatePercentage(currentModulation).silent()
            end
            -- Update the boilerInTemp
            domoticz.log('boiler inlet temp: ' ..currentboilerInTemp, domoticz.LOG_DEBUG)
            if domoticz.devices(ToonboilerInTempName).temperature ~= currentboilerInTemp then  
                domoticz.log('Updating boiler inlet temp to new value: ' ..currentboilerInTemp, domoticz.LOG_INFO)
                domoticz.devices(ToonboilerInTempName).updateTemperature(currentboilerInTemp)
            end
            -- Update the boilerOutTemp
            domoticz.log('boiler outlet temp: ' ..currentboilerOutTemp, domoticz.LOG_DEBUG)
            if domoticz.devices(ToonboilerOutTempName).temperature ~= currentboilerOutTemp then 
                 domoticz.log('Updating boiler outlet temp to new value: ' ..currentboilerOutTemp, domoticz.LOG_INFO)
                 domoticz.devices(ToonboilerOutTempName).updateTemperature(currentboilerOutTemp)
            end
            -- Update the boilerPressure
            domoticz.log('boiler pressure: ' ..currentboilerPressure, domoticz.LOG_DEBUG)
            if domoticz.devices(ToonboilerPressure).pressure ~= currentboilerPressure then 
                domoticz.log('Updating boiler pressure to new value: ' ..currentboilerPressure, domoticz.LOG_INFO)
                domoticz.devices(ToonboilerPressure).updatePressure(currentboilerPressure)
            end
        end
            
	end
}
 
   
