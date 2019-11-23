--[[
	Prerequisites
	==================================
	Domoticz v3.8837 or later (dzVents version 2.4 or later)
	User Variable named UV_GasMeter type float, that holds value of the gas meter
    Dummy switches that match the variables beneath

	CHANGE LOG: See https://github.com/Geo-Ron/dzVents/commits/master/dzUtilityMeters.lua


]] --

local scriptVersion = "1.4.11"
local inspiredByUrl = "https://www.domoticz.com/forum/viewtopic.php?f=14&t=1641"
local inspiredByAuthor = "pwhooftman"

---- Variables to match dummy switches withing Domoticz
local GasMeterUserVariableName = "UV_GasMeter" -- User Variable type Float that holds the current meter reading
local GasPulseSensorName = "Gasmeter_Sensor" -- Actual Gas Pulse Sensor
local GasMeterName = "Gasmeter" -- Dummy Counter or Gas device
local GasUpdateType = "Gas" -- Possible values: Gas or Counter type device
local Gasdevicecorrectionfactor = 1000

local WaterMeterUserVariableName = "UV_WaterMeter" -- User Variable type Float that holds the current meter reading
local WaterPulseSensorName = "Watermeter_Sensor" -- Actual Gas Pulse Sensor
local WaterMeterName = "Watermeter" -- Dummy Counter or Gas device
local WaterUpdateType = "Counter" -- Possible values: Waterflow or Counter type device
local Waterdevicecorrectionfactor = 1000

----- End Variables

return {
	logging = {
		level = domoticz.LOG_DEBUG, -- Uncomment to override the dzVents global logging setting
		marker = "dzUtilityMeters v" .. scriptVersion
	},
	on = {
		-- timer = {
		-- 'every minute'
		-- },
		devices = {
			GasPulseSensorName,
			WaterPulseSensorName
		}
	},
	execute = function(domoticz, item)
		local CurrentGasMeterValue = domoticz.variables(GasMeterUserVariableName).value
		local CurrentWaterMeterValue = domoticz.variables(WaterMeterUserVariableName).value

		if (item.isDevice) then
			-- Run Only if a device has changed on the Domoticz side...
			-- Note that the OpenURL call is made AFTER the script has finished
			domoticz.log("Device " .. item.name .. " changed.", domoticz.LOG_DEBUG)
			--Run when device Changed
			--domoticz.openURL(string.format('http://%s/happ_thermstat?action=setSetpoint&Setpoint=%s', ToonIP, device.SetPoint*100))
			--item.dump()
			if item.name == GasPulseSensorName and (item.state == "Open" or item.state == "Off") then
				--local NewToonSetPoint = domoticz.utils.round(item.setPoint, 2)
				local NewGasMeterValue = CurrentGasMeterValue + 0.01
				domoticz.log("Updating Gasmeter to " .. NewGasMeterValue, domoticz.LOG_DEBUG)
				--Update Variable in m3
				if GasUpdateType == "Gas" then
					--domoticz.log("Updating Gasmeter with new value:" , domoticz.LOG_INFO)
					--Update Device in dm3
					domoticz.devices(GasMeterName).updateGas(NewGasMeterValue * Gasdevicecorrectionfactor)
				else
					--Update Total to m3
					domoticz.devices(GasMeterName).updateCounter(NewGasMeterValue * Gasdevicecorrectionfactor)
				end
				--Update UV
				domoticz.variables(GasMeterUserVariableName).set(NewGasMeterValue)
			else
				--domoticz.log('Not updating GasMeter. Pulse device state is '..item.state, domoticz.LOG_DEBUG)
			end

			--if item.name == WaterPulseSensorName and (item.state == "Open" or item.state == "Off") then
			if item.name == WaterPulseSensorName then
				--local NewToonSetPoint = domoticz.utils.round(item.setPoint, 2)
				local NewWaterMeterValue = CurrentWaterMeterValue + 0.00025 --0,5l
				domoticz.log("Updating Watermeter to " .. NewWaterMeterValue, domoticz.LOG_DEBUG)
				--Update Variable in m3
				if WaterUpdateType == "Waterflow" then
					--Update Device in l
					domoticz.devices(WaterMeterName).updateWaterflow(NewWaterMeterValue * Waterdevicecorrectionfactor)
				else
					--Update Total to m3
					domoticz.devices(WaterMeterName).updateCounter(NewWaterMeterValue  * Waterdevicecorrectionfactor)
				end
				--Update UV
				domoticz.variables(WaterMeterUserVariableName).set(NewWaterMeterValue)
			else
				--domoticz.log('Not updating WaterMeter. Pulse device state is '..item.state, domoticz.LOG_DEBUG)
			end
		end
	end
}
