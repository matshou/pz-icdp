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

local function isItemValid(player, cd_player, item)
    return item:getContainer() == player:getInventory();
end

--- Переключить на следующий трек контекстным меню ---
function NextTrack(player, cd_player, item)
	local player = getPlayer()
    local cd_player --плеер
	local num_track
	local track_sum

	for i = 0, player:getInventory():getItems():size() - 1 do
		local item = player:getInventory():getItems():get(i);
		if item:getType() == "ICDPCDplayerOn" then -- находим включенный плеер
			cd_player = item --сохраняем итем
			break -- прерываем цикл, т.к. уже нашли нужный итем
		end
	end

	local ICDPCDplayerData = cd_player:getModData(); --получаем ссылку на таблицу плеера
	local disc_name = ICDPCDplayerData.DiscName; --получаем имя диска в плеере
	local disc_data = cd_player

	InitDiscName(disc_data, disc_name) --- инициализация диска
	local num = ICDPCDplayerData.disc_num --- таблица диска/диск типа в плеере

	local track_sum = ICDP_DISCS[num].track_sum; --- количество треков в диске

	local num_track = ICDPCDplayerData.NumTrack; --- номер текущего трека воспроизведения
	local disc_num = num

	StopSong(player)

	num_track = num_track+1

	if num_track > track_sum then
		num_track = 1
	end

	if not player:HasTrait("Deaf") then
		player:Say("Track-" .. tostring(num_track), 1.0, 1.0, 1.0, UIFont.Dialogue, 30.0, "radio");
	end

	ICDPCDplayerData.NumTrack = num_track; --- номер стартового трека по умолчанию после установки диска в плеер
	StartPlaySong(player, cd_player)
end

--- Переключить на предыдущий трек контекстным меню ---
function PreviousTrack(player, cd_player, item)
	local player = getPlayer()
    local cd_player --плеер
	local num_track
	local track_sum

	for i = 0, player:getInventory():getItems():size() - 1 do
		local item = player:getInventory():getItems():get(i);
		if item:getType() == "ICDPCDplayerOn" then -- находим включенный плеер
			cd_player = item --сохраняем итем
			break -- прерываем цикл, т.к. уже нашли нужный итем
		end
	end

	local ICDPCDplayerData = cd_player:getModData(); --получаем ссылку на таблицу плеера
	local disc_name = ICDPCDplayerData.DiscName; --получаем имя диска в плеере
	local disc_data = cd_player

	InitDiscName(disc_data, disc_name) --- инициализация диска
	local num = ICDPCDplayerData.disc_num --- таблица диска/диск типа в плеере
	local track_sum = ICDP_DISCS[num].track_sum; --- количество треков в диске
	local num_track = ICDPCDplayerData.NumTrack; --- номер текущего трека воспроизведения
	local disc_num = num

	StopSong(player)
	num_track = num_track-1

	if num_track == 0  then num_track = track_sum
	end

	if not player:HasTrait("Deaf") then
		player:Say("Track-" .. tostring(num_track), 1.0, 1.0, 1.0, UIFont.Dialogue, 30.0, "radio");
	end

	ICDPCDplayerData.NumTrack = num_track;
	StartPlaySong(player, cd_player)
end

--Действие контекстного меню плеера / переключить на следующий трек
function MenuNextTrack(player, cd_player, item)
	local cd_player
	local player = getPlayer()

    if not isItemValid(player, cd_player, item) then
        return --no dupe anymore
    end

	cd_player = tostring(item:getType()) --получаем имя устройства

	for i = 0, player:getInventory():getItems():size() - 1 do
		local item = player:getInventory():getItems():get(i);
		if item:getType() == "ICDPCDplayerOn" then
			NextTrack(player, cd_player, item) -- Вызов функции для включения следующего трека
			break
		end
	end
end

--Действие контекстного меню плеера / переключить на предыдущий трек
function MenuPreviousTrack(player, cd_player, item)
	local cd_player
	local player = getPlayer()

    if not isItemValid(player, cd_player, item) then
        return --no dupe anymore
    end

	cd_player = tostring(item:getType()) --получаем имя устройства

	for i = 0, player:getInventory():getItems():size() - 1 do
		local item = player:getInventory():getItems():get(i);
		if item:getType() == "ICDPCDplayerOn" then
			PreviousTrack(player, cd_player, item) -- Вызов функции для включения следующего трека
			break
		end
	end
end

--Проверяет предмет, по которому кликнули включенный-ли это плеер? Для меню предыдущего трека
local function checkInvItemICDPplayerOnForPrevious(player, context, worldobjects, item)
    local cd_player = item:getType();
	local check_cdplayer

    if not cd_player then
		return
    end

	if not isItemValid(player, cd_player, item) then
		return -- no dupe anymore
    end

    if cd_player ~= "ICDPCDplayerOn" then return -- если это не включенный плеер то прервать выполнение функции
    end

	for i = 0, player:getInventory():getItems():size() - 1 do
		local cd_player = player:getInventory():getItems():get(i);
		if cd_player:getType() == "ICDPCDplayerOn" then -- находим включенный плеер в инвентаре
			check_cdplayer = true
		end
	end

	if  check_cdplayer ~= true then return -- если нет включенного плеера,  то не показывать меню
	end

--- Показ контекстно меню на предмете...
	local option = context:addOption(getText("IGUI_ContextMenu_Previous_Track"), player, PreviousTrack, cd_player, item); --- надпись меню
    if not isItemValid(player, cd_player, item) then
        DisableOption(option, getText("IGUI_ContextMenu_Cant_Action")) --- надпись о невозможности выполнить (не походят условия)
    end
end

--Проверяет предмет, по которому кликнули включенный-ли это плеер? Для меню следующего трека
local function checkInvItemICDPplayerOnForNextTrack(player, context, worldobjects, item)
    local cd_player = item:getType();
	local check_cdplayer

    if not cd_player then
		return
    end

	if not isItemValid(player, cd_player, item) then
		return -- no dupe anymore
    end

    if cd_player ~= "ICDPCDplayerOn" then
		return -- если это не включенный плеер то прервать выполнение функции
    end

	for i = 0, player:getInventory():getItems():size() - 1 do
		local cd_player = player:getInventory():getItems():get(i);
		if cd_player:getType() == "ICDPCDplayerOn" then -- находим включенный плеер в инвентаре
			check_cdplayer = true
		end
	end

	if  check_cdplayer ~= true then
		return -- если нет включенного плеера,  то не показывать меню
	end

--- Показ контекстно меню на предмете...
	local option = context:addOption(getText("IGUI_ContextMenu_Next_Track"), player, MenuNextTrack, cd_player, item); --- надпись меню
    if not isItemValid(player, cd_player, item) then
        DisableOption(option, getText("IGUI_ContextMenu_Cant_Action")) --- надпись о невозможности выполнить (не походят условия)
    end
end

--Добавляет пункт меню для следующего трека
local invContextMenuMenuNextTrack = function(_player, context, worldobjects, test)
    local playerObj = getSpecificPlayer(_player);

    for i,k in pairs(worldobjects) do
		-- inventory item list
        if instanceof(k, "InventoryItem") then
            checkInvItemICDPplayerOnForNextTrack(playerObj, context, worldobjects, k);
			elseif not instanceof(k, "InventoryItem") and k.items and #k.items > 1 then
            checkInvItemICDPplayerOnForNextTrack(playerObj, context, worldobjects, k.items[1]);
        end
    end
end

--Добавляет пункт меню для предыдущего трека
local invContextMenuMenuPreviousTrack = function(_player, context, worldobjects, test)
    local playerObj = getSpecificPlayer(_player);

    for i,k in pairs(worldobjects) do
		-- inventory item list
        if instanceof(k, "InventoryItem") then
            checkInvItemICDPplayerOnForPrevious(playerObj, context, worldobjects, k);          -- проверка нужного итема для меню
			elseif not instanceof(k, "InventoryItem") and k.items and #k.items > 1 then
            checkInvItemICDPplayerOnForPrevious(playerObj, context, worldobjects, k.items[1]); -- проверка нужного итема для меню
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(invContextMenuMenuNextTrack); -- контекстное меню для включенного плеера (переключить на следующий трек)
Events.OnFillInventoryObjectContextMenu.Add(invContextMenuMenuPreviousTrack); -- контекстное меню для включенного плеера (переключить на  предыдущий трек)