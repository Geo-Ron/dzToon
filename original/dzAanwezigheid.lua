local scriptVersion                 = '1.0.0'


return {
	logging = {
		-- level = domoticz.LOG_DEBUG, -- Uncomment to override the dzVents global logging setting
		marker = 'Aanwezigheid '..scriptVersion
	},
	on = {
		devices = {
			'*_GSM_Aanwezig'
		}
	},
	execute = function(domoticz)
		domoticz.log('GSM aanwezigheid is veranderd', domoticz.LOG_INFO)
		if (domoticz.devices('Automation').level == 50 or domoticz.devices('Automation').level == 20) then
		    domoticz.log('Systeem staat handmatig of aanwezigheid override. Ik doe NIKS!', domoticz.LOG_INFO)
		elseif (domoticz.devices('$Ron_GSM_Aanwezig').state == 'On' or domoticz.devices('$Bianca_GSM_Aanwezig').state == 'On') then
		    domoticz.devices('IemandThuis').switchOn().checkFirst()
		    domoticz.devices('Automation').switchSelector(10).checkFirst()
		    domoticz.log('IemandThuis', domoticz.LOG_INFO)
		elseif (domoticz.devices('$Ron_GSM_Aanwezig').state == 'Off' and domoticz.devices('$Bianca_GSM_Aanwezig').state == 'Off') then
		    domoticz.devices('IemandThuis').switchOff().checkFirst()
		    if (domoticz.devices('Automation').level ~= 30) then
		        domoticz.devices('Automation').switchSelector(40).checkFirst()
		    else
		        domoticz.log('Automation staat in Vakantie modus. Geen actie ondernemen.', domoticz.LOG_INFO)
		    end
		    domoticz.log('NIET IemandThuis', domoticz.LOG_INFO)
		end
	end
}
