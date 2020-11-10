require "ISUI/ISToolTip"
local function newToolTip()
    local toolTip = ISToolTip:new();
    toolTip:initialise();
    toolTip:setVisible(false);
    return toolTip;
end

local function DisableOption(option, text)
    option.notAvailable = true
    local tooltip = newToolTip();
    tooltip.description = text;
    option.toolTip = tooltip;
end

local function isItemValid(player, disc_name, item)
    return item:getContainer() == player:getInventory();
end

---Вставить ICDP диск в Vanilla плеер контекстным меню ---
function AltInsertICDPCDDiscIntoVanillaCDplayer(player, disc_name, disc_data, item)
	local cd_player_delta
    local cd_player

    for i = 0, player:getInventory():getItems():size() - 1 do
	local item = player:getInventory():getItems():get(i);
        if item:getType() == "CDplayer" then
		player:getInventory():Remove("CDplayer");
		break
		end
	end

	player:getInventory():AddItem("ICDP.ICDPCDplayerWithDisc"); --добавляем ICDP плеер с диском

	for i = 0, player:getInventory():getItems():size() - 1 do
	local item = player:getInventory():getItems():get(i);
		if item:getType() == "ICDPCDplayerWithDisc" then --находим ICDP плеер с диском
			item:setUsedDelta(0); --устанавливаем дельту...
			cd_player = item -- сохраняем полученный плеер в переменной
			break
		end
	end

	InitDiscName(disc_data, disc_name); --инициализируем диск --- ?????

	local ICDPCDDiscData = disc_data:getModData(); --таблица диска
	local num = ICDPCDDiscData.disc_num --- таблица диска ---???????

	local disc_name = ICDP_DISCS[num].disc_name or "???"; --получаем имя диска
	local artist_name = ICDP_DISCS[num].artist_name or "???"; --получаем имя исполнителя
	local track_sum = ICDP_DISCS[num].track_sum; --- количество треков в диске
	local album_title = ICDP_DISCS[num].album_title; --- название исполнителя и альбома
	local content_disc = ICDP_DISCS[num].content_disc
	local entropy_disc = ICDPCDDiscData.EntropyDisc; --- изношенность диска

	player:getInventory():Remove(disc_name); --- удаляем диск

	local ICDPCDplayerData = cd_player:getModData(); -- получаем таблицу созданного плеера
	ICDPCDplayerData.DiscName = disc_name; -- записываем в поле таблицы плеера имя диска
	ICDPCDplayerData.ArtistName = artist_name;
	ICDPCDplayerData.TrackSum = track_sum;
	ICDPCDplayerData.AlbumTitle = album_title;
	ICDPCDplayerData.ContentDisc = content_disc;
	ICDPCDplayerData.TrackPosition = 1; --записываем в таблицу плеера точку воспроизведения в песни
	ICDPCDplayerData.NumTrack = 1; --- номер стартового трека по умолчанию после установки диска в плеер
	ICDPCDplayerData.Power = false; -- записываем в плеер текущее наличие/отсутствие энергии
	ICDPCDplayerData.EntropyDisc = entropy_disc;
	ICDPCDplayerData.Volume = 0.5;

end

--- Вставить ICDP диск в ICDP CDPlayer ---
function AltInsertICDPCDDiscIntoICDPCDplayer(player, disc_name, disc_data, item)
	local cd_player_delta
    local cd_player
	local cdplayer_volume

	local ICDPCDDiscData = disc_data:getModData(); --таблица диска

	if ICDPCDDiscData.AlbumTitle == nil then
	player:getInventory():Remove(disc_name)
	player:Say("ANTI Cheat!!! CD removed")
	return end

	for i = 0, player:getInventory():getItems():size() - 1 do
		local item = player:getInventory():getItems():get(i);
		if item:getType() == "ICDPCDplayer" then -- находим ICDP CD плеер без диска
			cd_player_delta = item:getUsedDelta() --сохраняем дельту перед удалением ICDP плеера без диска
			cd_player = item -- сохраняем cd плеер
			local ICDPCDplayerData = cd_player:getModData(); --получаем ссылку на таблицу плеера
			cdplayer_volume = ICDPCDplayerData.Volume;
			player:getInventory():Remove("ICDPCDplayer") --удаляем ICDP плеер без диска
			break
		end
	end

	player:getInventory():AddItem("ICDP.ICDPCDplayerWithDisc"); -- добавляем ICDP плеер с диском

	for i = 0, player:getInventory():getItems():size() - 1 do
		local item = player:getInventory():getItems():get(i);
		if item:getType() == "ICDPCDplayerWithDisc" then -- находим ICDP плеер с диском
			item:setUsedDelta(cd_player_delta); -- устанавливаем дельту от удаленного плеера на вновь созданный...
			cd_player = item -- сохраняем полученный плеер в переменной
			break
		end
	end

	if cd_player_delta == 0 then power = false
		elseif cd_player_delta > 0 then power = true
	end

	InitDiscName(disc_data, disc_name); --инициализируем диск --- ?????

	local ICDPCDDiscData = disc_data:getModData(); --таблица диска
	local num = ICDPCDDiscData.disc_num --- таблица диска ---???????

	local disc_name = ICDP_DISCS[num].disc_name or "???"; --получаем имя диска
	local artist_name = ICDP_DISCS[num].artist_name or "???"; --получаем имя исполнителя
	local track_sum = ICDP_DISCS[num].track_sum; --- количество треков в диске
	local album_title = ICDP_DISCS[num].album_title; --- название исполнителя и альбома
	local content_disc = ICDP_DISCS[num].content_disc
	local entropy_disc = ICDPCDDiscData.EntropyDisc; --- изношенность диска

	player:getInventory():Remove(disc_name); --- удаляем вставляемый диск

	local ICDPCDplayerData = cd_player:getModData(); -- получаем таблицу созданного плеера
	ICDPCDplayerData.DiscName = disc_name; -- записываем в поле таблицы плеера имя диска
	ICDPCDplayerData.ArtistName = artist_name;
	ICDPCDplayerData.TrackSum = track_sum;
	ICDPCDplayerData.AlbumTitle = album_title;
	ICDPCDplayerData.ContentDisc = content_disc;
	ICDPCDplayerData.TrackPosition = 1; --записываем в таблицу плеера точку воспроизведения в песни
	ICDPCDplayerData.NumTrack = 1; --- номер стартового трека по умолчанию после установки диска в плеер
	ICDPCDplayerData.Power = power; -- записываем в плеер текущее наличие/отсутствие энергии
	ICDPCDplayerData.EntropyDisc = entropy_disc;
	ICDPCDplayerData.Volume = cdplayer_volume;
end

--Действие контекстного меню ICDP диска
function ContextMenuInsertICDPDisc(player, disc_name, disc_data, item)

    if not isItemValid(player, disc_name, item) then
        return --no dupe anymore
    end

	for i = 0, player:getInventory():getItems():size() - 1 do
		local item = player:getInventory():getItems():get(i);
		if item:getType() == "ICDPCDplayer" then
			AltInsertICDPCDDiscIntoICDPCDplayer(player, disc_name, disc_data, item) -- Вызов функции вставить диск для ICDP плеера
			break
		end
	end

	for i = 0, player:getInventory():getItems():size() - 1 do
		local item = player:getInventory():getItems():get(i);
		if item:getType() == "CDplayer" then
			AltInsertICDPCDDiscIntoVanillaCDplayer(player, disc_name, disc_data, item) -- Вызов функции вставить диск для Vanilla плеера
			break
		end
	end
end

--Проверяет предмет, по которому кликнули ICDP ли это диск?
local function checkInvItemICDPDisc(player, context, worldobjects, item)
    local disc_name = item:getType()
	local disc_data = item
	local check_cdplayer

    if not disc_name then
        return
    end

	if not isItemValid(player, disc_name, item) then
        return --no dupe anymore
    end

	if string.find(disc_name,"ICDPCDDisc",1,true) ~= 1 then --- начало строки итема - не равно "ICDPCDDisc" ***** СПАСИБО STAR за помощь! *****
        return
	end

   	for i = 0, player:getInventory():getItems():size() - 1 do
		local cd_player = player:getInventory():getItems():get(i);

		if cd_player:getType() == "ICDPCDplayer" or cd_player:getType() == "CDplayer" then -- проверка наличия CD плееров
			check_cdplayer = true
		end
	end

	for i = 0, player:getInventory():getItems():size() - 1 do
		local cd_player = player:getInventory():getItems():get(i);

		if cd_player:getType() == "ICDPCDplayerWithDisc" then -- если есть ICDP плеер с диском - то не показывать контекстное меню
			return
		end
	end

	if  check_cdplayer ~= true then -- если нет ICDP плеера, или Vanilla плеера без диска, то не показывать меню
		return
	end

	local option = context:addOption(getText("IGUI_ContextMenu_Insert_ICDP_Disc"), player, ContextMenuInsertICDPDisc, disc_name, disc_data, item);
    if not isItemValid(player, disc_name, item) then
        DisableOption(option, getText("IGUI_ContextMenu_Cant_Action"))
    end
end

--Добавляет пункт меню для ICDP Дисков
local invContextMenuICDPDisc = function(_player, context, worldobjects, test)
    local playerObj = getSpecificPlayer(_player);

    for i,k in pairs(worldobjects) do
    -- inventory item list
        if instanceof(k, "InventoryItem") then
            checkInvItemICDPDisc(playerObj, context, worldobjects, k);
        elseif not instanceof(k, "InventoryItem") and k.items and #k.items > 1 then
            checkInvItemICDPDisc(playerObj, context, worldobjects, k.items[1]);
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(invContextMenuICDPDisc); -- контекстное меню для ICDP дисков (вставить диск)