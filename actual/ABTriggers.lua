
commandArray = {}

    remote = '$AB A'
        if (devicechanged[remote]) then
            print(remote..' changed to '..devicechanged[remote])
            commandArray[#commandArray + 1] = {['Group:Lampen Woonkamer'] = devicechanged[remote] }
        end
    remote = '$AB 2A'
        if (devicechanged[remote]) then
            print(remote..' changed to '..devicechanged[remote])
            commandArray[#commandArray + 1] = {['Group:Lampen Woonkamer'] = devicechanged[remote] }
        end
    remote = '$AB 2B'
        if (devicechanged[remote]) then
            print(remote..' changed to '..devicechanged[remote])
            commandArray[#commandArray + 1] = {['Radio Keuken'] = devicechanged[remote] }
        end
    remote = '$AB D'
        if (devicechanged[remote]) then
            print(remote..' changed to '..devicechanged[remote])
            commandArray[#commandArray + 1] = {['Scene:Bedtijd'] = 'On' }
        end
    remote = '$AB 2D'
        if (devicechanged[remote]) then
            print(remote..' changed to '..devicechanged[remote])
            commandArray[#commandArray + 1] = {['Scene:Bedtijd'] = 'On' }
        end
    -- if (devicechanged['$AB 2B'] == 'Off') then
    -- commandArray[#commandArray + 1] = {['Radio Keuken'] = 'Off' }
    -- end

return commandArray

