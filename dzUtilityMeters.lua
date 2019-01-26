--[[
	Prerequisites
	==================================
	Domoticz v3.8837 or later (dzVents version 2.4 or later)
	User Variable named UV_GasMeter type float, that holds value of the gas meter
    Dummy switches that match the variables beneath

	CHANGE LOG: See https://github.com/Geo-Ron/dzVents/commits/master/dzUtilityMeters.lua


]]--


 local scriptVersion = '1.2.29'
 local inspiredByUrl = 'https://www.domoticz.com/forum/viewtopic.php?f=14&t=1641'
 local inspiredByAuthor = 'pwhooftman'
 
---- Variables to match dummy switches withing Domoticz
 local GasMeterUserVariableName   = 'UV_GasMeter' -- User Variable type Float that holds the current meter reading
 local GasPulseSensorName         = 'Gasmeter_Sensor' -- Actual Gas Pulse Sensor
 local GasMeterName         	  = 'Gasmeter' -- Dummy Counter or Gas device 
 local UpdateType                 = 'Gas' -- Possible values: Gas or Counter type device
 local devicecorrectionfactor     = 1000
 
 
----- End Variables
 
 return {
	logging = {
		--level = domoticz.LOG_DEBUG, -- Uncomment to override the dzVents global logging setting
		marker = 'dzUtilityMeters v'..scriptVersion
	},
	on = {
		-- timer = {
			-- 'every minute'
		-- },
		devices = {
			GasPulseSensorName
		}
	},
	execute = function(domoticz, item)

    local CurrentGasMeterValue = domoticz.variables(GasMeterUserVariableName).value
	

        if (item.isDevice) then
            -- Run Only if a device has changed on the Domoticz side...
            -- Note that the OpenURL call is made AFTER the script has finished
            domoticz.log('Device '.. item.name ..' changed.', domoticz.LOG_DEBUG)
            --Run when device Changed
		    --domoticz.openURL(string.format('http://%s/happ_thermstat?action=setSetpoint&Setpoint=%s', ToonIP, device.SetPoint*100))
		    --item.dump()
		    if item.name == GasPulseSensorName and item.state == 'Open' then
		        --local NewToonSetPoint = domoticz.utils.round(item.setPoint, 2)
				local NewGasMeterValue = CurrentGasMeterValue + 0.01
    		    domoticz.log('Updating Gasmeter to '.. NewGasMeterValue, domoticz.LOG_DEBUG)
    		    --Update Variable in m3
    		    if UpdateType == 'Gas' then
    		        --Update Device in dm3
				    domoticz.devices(GasMeterName).updateGas(NewGasMeterValue*devicecorrectionfactor)
				else
				    --Update Total to m3
				    domoticz.devices(GasMeterName).updateCounter(NewGasMeterValue)
				end
				--Update UV
				domoticz.variables(GasMeterUserVariableName).set(NewGasMeterValue)
			else
			    domoticz.log('Not updating GasMeter. Pulse device state is '..item.state, domoticz.LOG_DEBUG)
			end
            
		end
	end
}
 
   
