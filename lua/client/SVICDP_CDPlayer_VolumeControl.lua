
function ICDPKeysUp(keynum)

	local player = getSpecificPlayer(0);
	local cd_player
	local counter_item = player:getInventory():FindAll("ICDPCDplayerOn");

	if counter_item:size() ~= 0 and keynum == 201 then -- PageUp

		for i = 0, player:getInventory():getItems():size() - 1 do
			local item = player:getInventory():getItems():get(i);

			if item:getType() == "ICDPCDplayerOn" then
				cd_player = item;
				break
			end
		end

		local ICDPCDplayerData = cd_player:getModData();
		cdplayer_volume = ICDPCDplayerData.Volume;

		cdplayer_volume = tonumber(string.format("%.1f", cdplayer_volume + 0.1));

		if cdplayer_volume >= 1 then cdplayer_volume = 1.0
		end

		local ICDPCDplayerData = cd_player:getModData();
		ICDPCDplayerData.Volume = cdplayer_volume;
	end

	if counter_item:size() ~= 0 and keynum == 209 then -- PageDown

		for i = 0, player:getInventory():getItems():size() - 1 do
			local item = player:getInventory():getItems():get(i);

			if item:getType() == "ICDPCDplayerOn" then
				cd_player = item;
				break
			end
		end

		local ICDPCDplayerData = cd_player:getModData();
		cdplayer_volume = ICDPCDplayerData.Volume;

		cdplayer_volume = tonumber(string.format("%.1f", cdplayer_volume - 0.1));

		if cdplayer_volume <= 0 then cdplayer_volume = 0.0
		end

		local ICDPCDplayerData = cd_player:getModData();
		ICDPCDplayerData.Volume = cdplayer_volume;
	end
end

Events.OnKeyPressed.Add(ICDPKeysUp);