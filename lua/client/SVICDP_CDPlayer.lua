-- Установка правильного веса ванильных предметов
ScriptManager.instance:getItem("Base.Battery"):DoParam("Weight = 0.05") --- ~ реальный вес 1 батарейки формата АА (для плеера их нужно 2 шт.) - поэтому вес плеера + вес 2-х батареек.

local icdp_reallastSec = nil
local icdp_realtime_counter
local lastMinute = nil
local counterX
local sound_sv = nil

if counterX == nil then
	counterX = 0
end

if icdp_realtime_counter == nil then icdp_realtime_counter = 0
end

Events.OnTick.Add(function()

	local datetime = os.date("!*t",os.time())
	local sec = (datetime.sec)
	local game_minute = getGameTime():getMinutes()

	if game_minute ~= lastGameMinute then --- таймер срабатывает раз в минуту игрового времени
		SpendingDelta()
		lastGameMinute = game_minute
	end

	if sec ~= icdp_reallastSec then
		icdp_realtime_counter = icdp_realtime_counter + 1
		icdp_reallastSec = sec

		if icdp_realtime_counter == 1 then --- таймер срабатывает раз в секунду...
			icdp_realtime_counter = 0

			CheckCDPlayerOn(item, player)
		end
	end
end)

function getPlayerCDPlayer(player)

	for i = 0, player:getInventory():getItems():size() - 1 do
		local item = player:getInventory():getItems():get(i);

		if item:getType() == "ICDPCDplayerOn" then
			return item;
		end
	end
	return nil;
end

function ResetVolumeLevels(modData)

	getCore():setOptionSoundVolume(modData.CurrentSoundVolume);
	getCore():setOptionMusicVolume(modData.CurrentMusicVolume);
	getCore():setOptionAmbientVolume(modData.CurrentAmbientVolume);
end

function SetVolumeLevels(sound, music, ambient)

	getSoundManager():setSoundVolume(sound);
	getSoundManager():setMusicVolume(music);
	getSoundManager():setAmbientVolume(ambient);
end

--- проверка наличия Включенного плеера и наличие заряда в плеере - воспроизводить содержимое диска, если заряда нет, то запустить функцию остановки плеера
function CheckCDPlayerOn(item, player) --- проверка наличия в инвентаре включенного плеера

	local cd_player
	local player = getSpecificPlayer(0)
	local counter_item = player:getInventory():FindAll("ICDPCDplayerOn"); --- получаем количество итемов в инвентаре и (true) в сумках

	local ICDPCharacterData = player:getModData();

	ICDPCharacterData.CurrentSoundVolume = getCore():getOptionSoundVolume();
	ICDPCharacterData.CurrentMusicVolume = getCore():getOptionMusicVolume();
	ICDPCharacterData.CurrentAmbientVolume = getCore():getOptionAmbientVolume();

	if counter_item:size() == 0 and sound_sv ~= nil then

		getSoundManager():StopSound(sound_sv);
		ResetVolumeLevels(ICDPCharacterData);

		if counter_item:size() == 0 and sound_sv == nil then
			ResetVolumeLevels(ICDPCharacterData);
			return
		end

	else

		for i = 0, player:getInventory():getItems():size() - 1 do
			local item = player:getInventory():getItems():get(i);

			if item:getType() == "ICDPCDplayerOn" and item:getUsedDelta() > 0.01 then --- если дельты плеера достаточно (есть заряд в батарейке)

				SetVolumeLevels(0.1, 0, 0.05);

				if item:hasModData() == false then
					player:getInventory():Remove(item);
					player:Say("Error - Item Removed");
				return end

				cd_player = item

				if sound_sv ~= nil then
					SongTime(item, player, cd_player); --- воспроизведение
				end

				elseif item:getType() == "ICDPCDplayerOn" and item:getUsedDelta() < 0.01  then --- если дельта плеера закончилась (кончилась батарейка)
					cd_player = item
					PowerOffCDPlayer(item, player, cd_player); --- выключить плеер

				break
			end
		end
	end
end

function StopSong(player)

	if sound_sv then
		getSoundManager():StopSound(sound_sv);
		sound_sv = nil;
		counterX = 0
	end
end

--- Воспроизведение ---
function StartPlaySong(player, cd_player)

	local ICDPCDplayerData = cd_player:getModData(); --получаем ссылку на таблицу плеера
	local disc_name = ICDPCDplayerData.DiscName; --получаем имя диска в плеере
	local disc_data = cd_player
	local vanila_music_volume = getCore():getOptionMusicVolume();

	InitDiscName(disc_data, disc_name) --- инициализация диска
	local num = ICDPCDplayerData.disc_num; --- таблица диска/диск типа в плеере
	local disc_name = ICDP_DISCS[num].disc_name or "???"; --получаем имя диска из таблицы дисков
	local artist_name = ICDP_DISCS[num].artist_name or "???"; --получаем имя исполнителя
	local track_sum = ICDP_DISCS[num].track_sum; --- количество треков в диске
	local album_title = ICDP_DISCS[num].album_title; --- название исполнителя и альбома
	local num_track = ICDPCDplayerData.NumTrack; --- номер текущего трека воспроизведения
	local entropy_disc = ICDPCDplayerData.EntropyDisc; --- изношенность диска
	local content_disc = ICDPCDplayerData.ContentDisc;
	local cdplayer_volume = ICDPCDplayerData.Volume;
	local disc_num = num
	local sound_song = ICDP_DISCS[disc_num].tracks[num_track][1] --получаем название текущего трека
	local sound = sound_song
	local gameSound = GameSounds.getSound(sound)
	local volume = gameSound:getUserVolume()
	gameSound:setUserVolume(cdplayer_volume)
	sound_sv = getSoundManager():PlaySound(sound_song,false,cdplayer_volume);
	counterX = 0

end

function SongTime(item, player, cd_player)

	local disc_data = cd_player
	local player = getSpecificPlayer(0)

	local ICDPCDplayerData = cd_player:getModData(); --получаем ссылку на таблицу плеера
	local disc_name = ICDPCDplayerData.DiscName; --получаем имя диска в плеере

	InitDiscName(disc_data, disc_name) --- инициализация диска
	local num = ICDPCDplayerData.disc_num; --- таблица диска/диск типа в плеере
	local disc_name = ICDP_DISCS[num].disc_name or "???"; --получаем имя диска из таблицы дисков
	local artist_name = ICDP_DISCS[num].artist_name or "???"; --получаем имя исполнителя
	local track_sum = ICDP_DISCS[num].track_sum; --- количество треков в диске
	local album_title = ICDP_DISCS[num].album_title; --- название исполнителя и альбома
	local num_track = ICDPCDplayerData.NumTrack; --- номер текущего трека воспроизведения
	local entropy_disc = ICDPCDplayerData.EntropyDisc; --- изношенность диска
	local content_disc = ICDPCDplayerData.ContentDisc;
	local cdplayer_volume = ICDPCDplayerData.Volume;
	local disc_num = num
	local length_sec = ICDP_DISCS[disc_num].tracks[num_track][2] --получаем длину текущего трека в секундах
	local sound_song = ICDP_DISCS[disc_num].tracks[num_track][1] --получаем название текущего трека
-- Управление текущей громкостью
	local sound = sound_song
	local gameSound = GameSounds.getSound(sound)
	local volume = gameSound:getUserVolume()
	gameSound:setUserVolume(cdplayer_volume)
------------------------------------------------
	counterX = counterX+1

	if counterX > length_sec+2 then
		counterX = 0
		StopSong(player)

		num_track = num_track+1

		if num_track > track_sum then
			num_track = 1
		end

		-- если персонаж не глухой...
		if not player:HasTrait("Deaf") then
			player:Say("Track-" .. tostring(num_track),1.0, 1.0, 0.0, UIFont.Dialogue, 30.0, "radio");
			ICDPCDplayerData.NumTrack = num_track;
			StartPlaySong(player, cd_player)
		end
	end
end

function SpendingDelta(items, player) --- Расход энергии ---
	local player = getSpecificPlayer(0)

	for i = 0, player:getInventory():getItems():size() - 1 do

		local item = player:getInventory():getItems():get(i);

		if item:getType() == "ICDPCDplayerOn" then
			--- ************ Расходуем дельту плеера при воспроизведении / 1 раз в минуту игрового времени *************
			item:setUsedDelta((item:getUsedDelta() - 0.002)); ---  8 часов воспроизведения

			-- Влияем на настроение, если персонаж не глухой
			if not player:HasTrait("Deaf") then
				--- определяем некущее настроение
				local temp_player_boredomlevel = player:getBodyDamage():getBoredomLevel();
				local temp_player_unhappynesslevel = player:getBodyDamage():getUnhappynessLevel();
				getPlayer():getBodyDamage():setBoredomLevel(temp_player_boredomlevel-1); --- уменьшаем грусть
				getPlayer():getBodyDamage():setUnhappynessLevel(temp_player_unhappynesslevel-1); --- уменьшаем несчастье
			end

			if item:getUsedDelta() < 0.035 then
				if not player:HasTrait("Deaf") then -- если персонаж не глухой выводим сообщение о низком заряде батареи
					player:Say(getText("IGUI_Battery_Low"), 1.0, 1.0, 0.0, UIFont.Dialogue, 30.0, "radio"); --- если дельта заканчивается выводим сообщение
				end
			end
			break
		end
	end
end

--- Выключение CD плеера при пустой батарейки ---
function PowerOffCDPlayer(item, player, cd_player)

    local player = getSpecificPlayer(0) --игрок
	local ICDPCDplayerData = cd_player:getModData(); --получаем ссылку на таблицу плеера
    local player = getSpecificPlayer(0) --игрок
	local track_position = ICDPCDplayerData.TrackPosition;
	local num_track = ICDPCDplayerData.NumTrack;
	local name_track = ICDPCDplayerData.NameTrack;
	local track_sum = ICDPCDplayerData.TrackSum;
	local disc_name = ICDPCDplayerData.DiscName;
	local artist_name = ICDPCDplayerData.ArtistName;
	local album_title = ICDPCDplayerData.AlbumTitle;
	local content_disc = ICDPCDplayerData.ContentDisc;
	local entropy_disc = ICDPCDplayerData.EntropyDisc;
	local cdplayer_volume = ICDPCDplayerData.Volume;

	for i = 0, player:getInventory():getItems():size() - 1 do

		local item = player:getInventory():getItems():get(i);

			if item:getType() == "ICDPCDplayerOn" then
				if not player:HasTrait("Deaf") then
					player:Say(getText("IGUI_Battery_Power_Off"), 1.0, 0.0, 0.0, UIFont.Dialogue, 30.0, "radio");
				end
				player:getInventory():Remove("ICDPCDplayerOn");
			break
		end
	end

	player:getInventory():AddItem("ICDP.ICDPCDplayerWithDisc");

	for i = 0, player:getInventory():getItems():size() - 1 do

		local item = player:getInventory():getItems():get(i);

		if item:getType() == "ICDPCDplayerWithDisc" then
			item:setUsedDelta(0);
			cd_player = item

			ResetVolumeLevels(player:getModData());

			local ICDPCDplayerData = cd_player:getModData(); --получаем ссылку на таблицу плеера
			ICDPCDplayerData.TrackPosition = 1;
			ICDPCDplayerData.NumTrack = num_track;
			ICDPCDplayerData.NameTrack = name_track;
			ICDPCDplayerData.Power = false
			ICDPCDplayerData.TrackSum = track_sum;
			ICDPCDplayerData.DiscName = disc_name;
			ICDPCDplayerData.ArtistName = artist_name;
			ICDPCDplayerData.AlbumTitle = album_title;
			ICDPCDplayerData.ContentDisc = content_disc;
			ICDPCDplayerData.EntropyDisc = entropy_disc;
			ICDPCDplayerData.Volume = 0.5;
		end
	end
	StopSong(player)
end

--- Принудительная остановка воспроизведения
function Stop_CD_Player(item, player, cd_player)
    local player = getSpecificPlayer(0) --игрок
	local cdplayer_delta

	for i = 0, player:getInventory():getItems():size() - 1 do

		local item = player:getInventory():getItems():get(i);

		if item:getType() == "ICDPCDplayerOn" then

			cdplayer_delta = item:getUsedDelta();
			player:getInventory():Remove("ICDPCDplayerOn");
			break
		end
	end

	player:getInventory():AddItem("ICDP.ICDPCDplayerWithDisc");

	for i = 0, player:getInventory():getItems():size() - 1 do

		local item = player:getInventory():getItems():get(i);

		if item:getType() == "ICDPCDplayerWithDisc" then
			item:setUsedDelta(cdplayer_delta);
			cd_player = item

			local ICDPCDplayerData = cd_player:getModData(); --получаем ссылку на таблицу плеера
			ICDPCDplayerData.TrackPosition = 1;
			ICDPCDplayerData.NumTrack = num_track;
			ICDPCDplayerData.NameTrack = name_track;
			ICDPCDplayerData.TrackSum = track_sum;
			ICDPCDplayerData.DiscName = disc_name;
			ICDPCDplayerData.EntropyDisc = entropy_disc;
			ICDPCDplayerData.ArtistName = artist_name;
			ICDPCDplayerData.AlbumTitle = album_title;
			ICDPCDplayerData.ContentDisc = content_disc;
			ICDPCDplayerData.Volume = cdplayer_volume;
		end
	end
	StopSong(player)
end

--[[
function printCurrentMusicTime(isoPlayer)

	local sound_position = getSoundManager():getMusicPosition()
    print(string.format("Current Music Time Elapsed (ms): %.2f", sound_position))

    local totalHours = sound_position / 1000 / 60 / 60
    local totalMinutes = sound_position / 1000 / 60
    local totalSeconds = sound_position / 1000
    print(string.format("Current Music Time Elapsed (hours): %.1f", totalHours))
    print(string.format("Current Music Time Elapsed (minutes): %.1f", totalMinutes))
    print(string.format("Current Music Time Elapsed (seconds): %.1f", totalSeconds))

    local totalHoursRounded = math.floor(sound_position / 1000 / 60 / 60)
    local totalMinutesRounded = math.floor(sound_position / 1000 / 60)
    local totalSecondsRounded = math.floor(sound_position / 1000)
    print(string.format("Current Music Time Elapsed (hoursRounded): %.1f", totalHoursRounded))
    print(string.format("Current Music Time Elapsed (minutesRounded): %.1f", totalMinutesRounded))
    print(string.format("Current Music Time Elapsed (secondsRounded): %.1f", totalSecondsRounded))

    local music_clock = millisecondsToClock(sound_position)
    print(string.format("Music Clock: %s", music_clock))

end

-- Returns a clock as a String in "hh:mm:ss" format.
function millisecondsToClock(ms)
    local sec = tonumber(ms)/1000

    if sec <= 0 then
        return "00:00:00";
		else

        local hours = string.format("%02.f", math.floor(sec/3600));
        local minutes = string.format("%02.f", math.floor(sec/60 - (hours*60)));
        local seconds = string.format("%02.f", math.floor(sec - hours*3600 - minutes*60));
        return string.format("%s:%s:%s", hours, minutes, seconds)
    end
end
--]]