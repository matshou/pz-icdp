----------------------------------- Immerisive CD PLAYERS -----------------------------------

--- Проверка наличия заряда в ICDP CD Player
function recipe_Insert_Battery_Into_ICDP_CD_Player_TestIsValid(sourceItem, result)
	if sourceItem:getType() == "ICDPCDplayer" then
		return sourceItem:getUsedDelta() == 0; -- Разрешите вставлять аккумулятор только в том случае, если в плеере нет заряда.
	end
	return true -- the battery
end

--- Проверка наличия заряда в ICDP CD Player с диском
function recipe_Insert_Battery_Into_ICDP_CD_Player_WithDiscTestIsValid(sourceItem, result)
	if sourceItem:getType() == "ICDPCDplayerWithDisc" then
		return sourceItem:getUsedDelta() == 0; -- Разрешите вставлять аккумулятор только в том случае, если в плеере нет заряда.
	end
	return true -- the battery
end

-- Проверка наличия заряда больше нуля в ICDP CD Player чтобы разрешить извлечение аккумулятора
function recipe_ICDPCDPlayerBatteryRemoval_TestIsValid(sourceItem)
	return sourceItem:getUsedDelta() > 0;
end

--- Проверка наличия заряда больше нуля в ICDP CD Player On чтобы разрешить извлечение аккумулятора
function recipe_ICDPCDPlayerOn_BatteryRemoval_TestIsValid(sourceItem, result)
	return sourceItem:getUsedDelta() > 0;
end

--- Проверка наличия заряда больше нуля в CD Player чтобы разрешить проигрывание
function recipe_Play_CD_Player_TestIsValid(sourceItem, result)
	return sourceItem:getUsedDelta() > 0;
end

--*********************************************** 	OnCreate	*************************************************--
--- Извлечение аккумулятора из ICDP CD Player без диска
function recipe_ICDPCDPlayerBatteryRemoval_OnCreate(items, result, player)
	local cd_player

	for i=0, items:size()-1 do
		-- Изменить дельту аккумулятора [result] в соответствии с зарядом плеера
		if items:get(i):getType() == "ICDPCDplayer" then
			result:setUsedDelta(items:get(i):getUsedDelta());
		end
	end
	player:getInventory():AddItem("Base.CDplayer");  --добавляем в инвентарь обычный Ванильный проигрыватель
end

--- Извлечение аккумулятора из ICDP CDPlayer с диском
function recipe_ICDPCDPlayerWithDiscBatteryRemoval_OnCreate(items, result, player)
	local player = getSpecificPlayer(0);
	local cd_player

	for i=0, items:size()-1 do
		-- Сохранить дельту аккумулятора [result] в соответствии с зарядом плеера
		if items:get(i):getType() == "ICDPCDplayerWithDisc" then
			result:setUsedDelta(items:get(i):getUsedDelta());
			items:get(i):setUsedDelta(0); --- убрать заряд плеера до нуля
            cd_player = items:get(i) --сохраняем ссылку на плеер
		end
	end

	local ICDPCDplayerData = cd_player:getModData(); --получаем ссылку на таблицу плеера
	ICDPCDplayerData.Power = false;
end

--- Вставить аккумулятор в ванильный CD Player
function recipe_Insert_Battery_Into_Vanilla_CD_Player(items, result, player)
	local player = getSpecificPlayer(0);
	local cd_player

	for i=0, items:size()-1 do
	-- найти аккумулятор и установить заряд плеера с диском на уровень аккумулятора
	if items:get(i):getType() == "Battery" then
		result:setUsedDelta(items:get(i):getUsedDelta());
		break --выходим из цикла, т.к. результат получен
	end
  end

	local ICDPCDplayerData = result:getModData(); --получаем таблицу плеера
	ICDPCDplayerData.Power = true;
end


--- Вставить аккумулятор в ICDP CD Player с диском
function recipe_Insert_Battery_Into_ICDP_CD_Player_WithDisc(items, result, player)
    local player = getSpecificPlayer(0);
	local cd_player
	local disc_data
	local disc_name
	local track_sum
	local artist_name
	local album_title
	local content_disc
	local entropy_disc
	local desc_box

    for i=0, items:size()-1 do
		-- найти ICDP плеер с диском
        if items:get(i):getType() == "ICDPCDplayerWithDisc" then
            cd_player = items:get(i) --сохраняем ссылку на плеер
			break --выходим из цикла, т.к. ссылка уже получена
         end
    end

    if not cd_player then
        return --если каким-то чудом всё еще нет ссылки, то выходим из функции, но это симптом бага в другом месте
    end

	local ICDPCDplayerData = cd_player:getModData(); --получаем ссылку на таблицу плеера
	disc_name = ICDPCDplayerData.DiscName;
	track_sum = ICDPCDplayerData.TrackSum;
	artist_name = ICDPCDplayerData.ArtistName;
	album_title = ICDPCDplayerData.AlbumTitle;
	content_disc = ICDPCDplayerData.ContentDisc;
	entropy_disc = ICDPCDplayerData.EntropyDisc;

	cd_player = result

	local ICDPCDplayerData = cd_player:getModData(); --получаем ссылку на таблицу плеера
	ICDPCDplayerData.DiscName = disc_name; --получаем имя диска в плеере
	ICDPCDplayerData.TrackSum = track_sum;
	ICDPCDplayerData.ArtistName = artist_name;
	ICDPCDplayerData.AlbumTitle = album_title;
	ICDPCDplayerData.ContentDisc = content_disc;
	ICDPCDplayerData.TrackPosition = 0; --устанавливаем позицию воспроизведения
	ICDPCDplayerData.NumTrack = 1; --- номер стартового трека по умолчанию после установки диска в плеер
	ICDPCDplayerData.Power = true;
	ICDPCDplayerData.EntropyDisc = entropy_disc;
	ICDPCDplayerData.Volume = 0.5;

	for i=0, items:size()-1 do
		-- найти аккумулятор и установить заряд плеера с диском на уровень аккумулятора
		if items:get(i):getType() == "Battery" then
			result:setUsedDelta(items:get(i):getUsedDelta());
		end
	end
end

--- Вставить аккумулятор в ICDP CD Player
function recipe_Insert_Battery_Into_ICDP_CD_Player(items, result, player)

	for i=0, items:size()-1 do
		-- найти аккумулятор и установить заряд плеера с диском на уровень аккумулятора
		if items:get(i):getType() == "Battery" then
			result:setUsedDelta(items:get(i):getUsedDelta());
		end

		cd_player = result
		local ICDPCDplayerData = cd_player:getModData(); --получаем ссылку на таблицу плеера после установки батарейки
		ICDPCDplayerData.ArtistName = getText("IGUI_No_CD"); --записываем в таблицу вновь созданного плеера значение - "Нет CD диска"
		ICDPCDplayerData.Power = true;
		ICDPCDplayerData.Volume = 0.5; -- установка половины громкости при вставке батарейки... по умочанию
	end
end

--- Извлечь CD из ICDP CD Плеера
function recipe_Remove_CD_From_ICDP_CDPlayer(items, result, player)
    local player = getSpecificPlayer(0);
	local cd_player
	local disc_data
	local power

    if not player then
        return --если нет игрока, то выходим из функции
    end

    for i=0, items:size()-1 do
		-- найти ICDP плеер с диском и установить уровень заряда в [result] - как у исходного
        if items:get(i):getType() == "ICDPCDplayerWithDisc" then

			cd_player = items:get(i) --сохраняем ссылку на удаляемый плеер
			result:setUsedDelta(items:get(i):getUsedDelta()); --устанавливаем дельту на ICDP плеер без диска [result]

			if items:get(i):getUsedDelta() == 0 then
				power = false

				elseif items:get(i):getUsedDelta() > 0 then
				power = true
			end

			break --выходим из цикла, т.к. ссылка уже получена
        end
	end

	local ICDPCDplayerData = cd_player:getModData(); --получаем ссылку на таблицу плеера
	local disc_name = ICDPCDplayerData.DiscName; --получаем имя диска в плеере
	local track_sum = ICDPCDplayerData.TrackSum; --- количество треков в диске
	local artist_name = ICDPCDplayerData.ArtistName; --получаем имя исполнителя
	local album_title = ICDPCDplayerData.AlbumTitle; --- название исполнителя и альбома
	local content_disc = ICDPCDplayerData.ContentDisc
	local entropy_disc = ICDPCDplayerData.EntropyDisc;
	local cdplayer_volume = ICDPCDplayerData.Volume;

	local ICDPCDplayerData = result:getModData(); --получаем таблицу вновь созданного плеера без диска
	ICDPCDplayerData.Power = power;

	if disc_name ~= nil then player:getInventory():AddItem("ICDP." .. (disc_name));  --добавляем в инвентарь диск с именем взятым из таблицы удаленного плеера

	elseif ICDPCDplayerData.DiscName == nil then player:getInventory():AddItem("ICDP.ICDPCDDisc" .. (1)); -- если имя диска отсутствует то добавляем поцарапанный ICDCDDisc1
	end

	for i = 0, player:getInventory():getItems():size() - 1 do
		local item = player:getInventory():getItems():get(i);
		if item:getType() == disc_name then -- находим добавленный диск
			disc_data = item --сохраняем итем диска в переменной
			break
		end
	end

	local ICDPCDDiscData = disc_data:getModData(); --таблица диска
	ICDPCDDiscData.DiscName = disc_name;
	ICDPCDDiscData.TrackSum = track_sum;
	ICDPCDDiscData.ArtistName = artist_name;
	ICDPCDDiscData.AlbumTitle = album_title;
	ICDPCDDiscData.ContentDisc = content_disc;
	ICDPCDDiscData.EntropyDisc = entropy_disc
	ICDPCDplayerData.Volume = cdplayer_volume;
 end

function recipe_Remove_CD_from_box(items, result, player) -- [result] = CD-BoxEmpty
	local disc_box_data
	local disc_data

    for i=0, items:size()-1 do
		-- найти ICDPCDBoxFull
        if items:get(i):getType() == "ICDPCDBoxFull" then
			disc_box_data = items:get(i) --сохраняем ссылку на удаляемую коробку с диском
			break --выходим из цикла, т.к. ссылка уже получена
        end
	end

	local ICDPCDDiscBoxData = disc_box_data:getModData(); --таблица удаляемой коробки с диском
	local disc_name = ICDPCDDiscBoxData.DiscName;
	local track_sum = ICDPCDDiscBoxData.TrackSum;
	local artist_name = ICDPCDDiscBoxData.ArtistName;
	local album_title = ICDPCDDiscBoxData.AlbumTitle;
	local content_disc = ICDPCDDiscBoxData.ContentDisc;
	local entropy_disc = ICDPCDDiscBoxData.EntropyDisc;
	local desc = ICDPCDDiscBoxData.Desc; -- наличие описания на коробке

	if desc == true then -- у диска есть описание и записываем [result] пустой коробке таблицу/описание содержимого...

		local ICDPCDDiscBoxData = result:getModData(); --таблица пустой коробки из под диска [result]
		ICDPCDDiscBoxData.DiscName = disc_name;
		ICDPCDDiscBoxData.TrackSum = track_sum;
		ICDPCDDiscBoxData.ArtistName = artist_name;
		ICDPCDDiscBoxData.AlbumTitle = album_title;
		ICDPCDDiscBoxData.ContentDisc = content_disc;
		ICDPCDDiscBoxData.Desc = desc;  -- наличие описания на коробке

		else -- пустая коробка от диска будет чистой, без описания... девственна :)
	end

	if disc_name ~= nil then
		getPlayer():getInventory():AddItem("ICDP." .. (disc_name)) --- добавляем диск
		elseif disc_name == nil and not isDebugEnabled() then
			player:Say("ANTI Cheat!!!")
		return
	end

	for i = 0, player:getInventory():getItems():size() - 1 do
		local item = player:getInventory():getItems():get(i);
		if item:getType() == disc_name and item:hasModData() == false then -- находим добавленный (новый) диск c нужным именем диска, без таблицы/ hasModData() - возвращает true/false наличие таблицы
			disc_data = item --сохраняем итем диска в переменной
			break
		end
	end

	local ICDPCDDiscData = disc_data:getModData();

	ICDPCDDiscData.DiscName = disc_name; -- имя диска (item)
	ICDPCDDiscData.ArtistName = artist_name; -- Название исполнителя
	ICDPCDDiscData.AlbumTitle = album_title; -- название альбома
	ICDPCDDiscData.ContentDisc = content_disc; -- стиль/направление содержимого/музыки на диске
	ICDPCDDiscData.TrackSum = track_sum; -- количество треков на диске
	ICDPCDDiscData.EntropyDisc = entropy_disc; -- изношенность диска
end

-- ВОСПРОИЗВЕДЕНИЕ и ОСТАНОВКА ---
function recipe_Play_CD_Player(items, result, player)
	local player = getSpecificPlayer(0); --игрок
	local cd_player

    for i=0, items:size()-1 do
		-- найти ICDP плеер с диском
        if items:get(i):getType() == "ICDPCDplayerWithDisc" then
			result:setUsedDelta(items:get(i):getUsedDelta()); --- Установка заряда на плеер
			cd_player = items:get(i) --сохраняем ссылку на плеер
			break
		end
	end

	local ICDPCDplayerData = cd_player:getModData(); --получаем ссылку на таблицу плеера
	local disc_name = ICDPCDplayerData.DiscName; --получаем имя диска в плеере
	local track_sum = ICDPCDplayerData.TrackSum; --- количество треков в диске
	local artist_name = ICDPCDplayerData.ArtistName; --получаем имя исполнителя
	local album_title = ICDPCDplayerData.AlbumTitle; --- название исполнителя и альбома
	local track_position = ICDPCDplayerData.TrackPosition; --получаем позицию воспроизведения песни
	local name_track = ICDPCDplayerData.NameTrack; --- трек с диска - пример: "TrackSong2"
	local num_track = ICDPCDplayerData.NumTrack; --- номер трека - !!! число !!!
	local content_disc = ICDPCDplayerData.ContentDisc
	local entropy_disc = ICDPCDplayerData.EntropyDisc;
	local cdplayer_volume = ICDPCDplayerData.Volume;

	if not cd_player then
		return --если каким-то чудом всё еще нет ссылки, то выходим из функции, но это симптом бага в другом месте
	end

	cd_player = result

	local ICDPCharacterData = player:getModData()
	ICDPCharacterData.CurrentSoundVolume = getCore():getOptionSoundVolume();
	ICDPCharacterData.CurrentMusicVolume = getCore():getOptionMusicVolume();
	ICDPCharacterData.CurrentAmbientVolume = getCore():getOptionAmbientVolume();

	local ICDPCDplayerData = cd_player:getModData(); --получаем ссылку на таблицу плеера
	ICDPCDplayerData.DiscName = disc_name; --получаем имя диска в плеере
	ICDPCDplayerData.ArtistName = artist_name; --получаем имя исполнителя
	ICDPCDplayerData.TrackPosition = track_position; --получаем позицию воспроизведения песни
	ICDPCDplayerData.TrackSum = track_sum; --- количество треков в диске
	ICDPCDplayerData.AlbumTitle = album_title; --- название исполнителя и альбома
	ICDPCDplayerData.NameTrack = name_track; --- трек с диска - пример: "TrackSong2"
	ICDPCDplayerData.NumTrack = num_track; --- номер трека - !!! число !!!
	ICDPCDplayerData.ContentDisc = content_disc;
	ICDPCDplayerData.EntropyDisc = entropy_disc;
	ICDPCDplayerData.Volume = cdplayer_volume;

	StartPlaySong(player, cd_player)

	if disc_name == nil then
		disc_name = "ICDPCDDisc1"; -- если в таблице нет имени диска то добавляем в нее поцарапанный Disc1
	end
end

function recipe_Stop_CD_Player(items, result)
	local player = getSpecificPlayer(0); --игрок
	local cd_player

	StopSong(player)

    for i=0, items:size()-1 do
		-- найти включенный ICDP плеер
        if items:get(i):getType() == "ICDPCDplayerOn" then
            cd_player = items:get(i); --сохраняем ссылку на плеер
			result:setUsedDelta(items:get(i):getUsedDelta()); --- Установка заряда аккумулятора после выключения плеера
			break
        end
    end

	if not cd_player then
		print("!!!ERROR - IN RECIPE!!!")
        return --если каким-то чудом всё еще нет ссылки, то выходим из функции, но это симптом бага в другом месте
	end

	ResetVolumeLevels(player:getModData());

	local ICDPCDplayerData = cd_player:getModData(); --получаем ссылку на таблицу плеера
	local disc_name = ICDPCDplayerData.DiscName; --получаем имя диска в плеере
	local artist_name = ICDPCDplayerData.ArtistName; --получаем имя исполнителя
	local track_position = ICDPCDplayerData.TrackPosition; --получаем позицию воспроизведения песни
	local track_sum = ICDPCDplayerData.TrackSum; --- количество треков в диске
	local album_title = ICDPCDplayerData.AlbumTitle; --- название исполнителя и альбома
	local num_track = ICDPCDplayerData.NumTrack; --- номер трека - !!! число !!!
	local content_disc = ICDPCDplayerData.ContentDisc;
	local entropy_disc = ICDPCDplayerData.EntropyDisc;
	local cdplayer_volume = ICDPCDplayerData.Volume;

	local ICDPCDplayerData = result:getModData(); --получаем ссылку на таблицу плеера
	ICDPCDplayerData.DiscName = disc_name; --получаем имя диска в плеере
	ICDPCDplayerData.ArtistName = artist_name; --получаем имя исполнителя
	ICDPCDplayerData.TrackPosition = track_position; --получаем позицию воспроизведения песни
	ICDPCDplayerData.TrackSum = track_sum; --- количество треков в диске
	ICDPCDplayerData.AlbumTitle = album_title; --- название исполнителя и альбома
	ICDPCDplayerData.NumTrack = num_track; --- номер трека - !!! число !!!
	ICDPCDplayerData.ContentDisc = content_disc;
	ICDPCDplayerData.EntropyDisc = entropy_disc;
	ICDPCDplayerData.Volume = cdplayer_volume;
end