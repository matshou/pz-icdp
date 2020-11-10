
function ICDPKeysUp(keynum)

	local player = getSpecificPlayer(0);

	if player == nil then
		return
	end

	if player:getInventory():FindAll("ICDPCDplayerOn") ~= 0 then

		if keynum == 201 then -- PageUp

			local cd_player = getPlayerCDPlayer(player);
			local ICDPCDplayerData = cd_player:getModData();

			cdplayer_volume = getCDPlayerVolume(ICDPCDplayerData);
			cdplayer_volume = math.min(tonumber(string.format("%.1f", cdplayer_volume + 0.1)), 1);

			ICDPCDplayerData.Volume = cdplayer_volume;

		elseif keynum == 209 then -- PageDown

			local cd_player = getPlayerCDPlayer(player);
			local ICDPCDplayerData = cd_player:getModData();

			cdplayer_volume = getCDPlayerVolume(ICDPCDplayerData);
			cdplayer_volume = math.max(tonumber(string.format("%.1f", cdplayer_volume - 0.1)), 0);

			ICDPCDplayerData.Volume = cdplayer_volume;
		end
	end
end

Events.OnKeyPressed.Add(ICDPKeysUp);