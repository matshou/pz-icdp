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

function InsertDiscEmptyBoxNoName(item, player, disc_data, disc_name)

	local cdbox_full
	local cdbox_empty

	local ICDPCDDiscData = disc_data:getModData(); --таблица диска
	local disc_name = ICDPCDDiscData.DiscName;
	local track_sum = ICDPCDDiscData.TrackSum;
	local artist_name = ICDPCDDiscData.ArtistName;
	local album_title = ICDPCDDiscData.AlbumTitle;
	local album_cover = ICDPCDDiscData.AlbumCover;
	local content_disc = ICDPCDDiscData.ContentDisc;
	local entropy_disc = ICDPCDDiscData.EntropyDisc;

	for i = 0, player:getInventory():getItems():size() - 1 do
		local item = player:getInventory():getItems():get(i);

		if item:getType() == "ICDPCDBoxEmpty" and item:hasModData() == false then --- найти пустую коробку без таблицы / возможно после какого-нибудь бага/ошибки/спавна админом коробки ICDP с диском
			player:getInventory():Remove(item); --удаляем пустую коробку без таблицы
			player:getInventory():AddItem("ICDP.ICDPCDBoxFull"); -- добавляем новую коробку с диском
			break
		end
	end

	for i = 0, player:getInventory():getItems():size() - 1 do
		local item = player:getInventory():getItems():get(i);

		if item:getType() == "ICDPCDBoxFull" and item:hasModData() == false then -- находим новую коробку с диском без таблицы
			cdbox_full = item --сохраняем итем коробки с диском в переменной
		end
	end

	local ICDPCDDiscBoxData = cdbox_full:getModData(); --таблица коробки с диском
	ICDPCDDiscBoxData.DiscName = disc_name; -- записываем в поле таблицы коробки имя диска - который типа уже внутри коробки
	ICDPCDDiscBoxData.TrackSum = track_sum;
	ICDPCDDiscBoxData.ArtistName = artist_name;
	ICDPCDDiscBoxData.AlbumTitle = album_title;
	ICDPCDDiscBoxData.AlbumCover = album_cover;
	ICDPCDDiscBoxData.ContentDisc = content_disc;
	ICDPCDDiscBoxData.EntropyDisc = entropy_disc;
	ICDPCDDiscBoxData.Desc = false; -- наличие описания на коробке - /false --- потому что коробка из под поцарапанного диска, или просто невинна :)

	player:getInventory():Remove(disc_name) --- удаляем вставляемый диск из инвентаря
end


function InsertDiscEmptyBoxWithName(item, player, disc_data, disc_name) --- вставка диска в пустую коробку с именем и описанием

	local cdbox_empty = item;
	local cdbox_full

	local ICDPCDDiscBoxData = cdbox_empty:getModData(); --таблица коробки без диска
	local desc = ICDPCDDiscBoxData.Desc; -- копируем значение присутствия описания на коробке
	local disc_name = ICDPCDDiscBoxData.DiscName;
	local track_sum = ICDPCDDiscBoxData.TrackSum;
	local artist_name = ICDPCDDiscBoxData.ArtistName;
	local album_title = ICDPCDDiscBoxData.AlbumTitle;
	local album_cover = ICDPCDDiscBoxData.AlbumCover;
	local content_disc = ICDPCDDiscBoxData.ContentDisc;
	local entropy_disc = ICDPCDDiscBoxData.EntropyDisc;

	player:getInventory():Remove(cdbox_empty); --удаляем пустую коробку с таким-же именем диска
	player:getInventory():AddItem("ICDP.ICDPCDBoxFull"); -- добавляем новую коробку с диском

	for i = 0, player:getInventory():getItems():size() - 1 do

		local item = player:getInventory():getItems():get(i);

		if item:getType() == "ICDPCDBoxFull" and item:hasModData() == false then -- находим новую добавленную коробку без таблицы

			cdbox_full = item --сохраняем итем коробки с диском в переменной

			local ICDPCDDiscBoxData = cdbox_full:getModData(); --таблица коробки с диском
			ICDPCDDiscBoxData.DiscName = disc_name; -- записываем в поле таблицы имя диска
			ICDPCDDiscBoxData.TrackSum = track_sum;
			ICDPCDDiscBoxData.ArtistName = artist_name;
			ICDPCDDiscBoxData.AlbumTitle = album_title;
			ICDPCDDiscBoxData.AlbumCover = album_cover;
			ICDPCDDiscBoxData.ContentDisc = content_disc;
			ICDPCDDiscBoxData.EntropyDisc = entropy_disc;
			ICDPCDDiscBoxData.Desc = desc; -- наличие описания на коробке - true/false

			player:getInventory():Remove(disc_name) --- удаляем диск вставляемый диск из инвентаря
		end
	end
end

--- Вставить диск в пустую коробку  ---
function SearchEmptyBoxes(item, player, disc_data, disc_name)

	local player = getPlayer()

	local ICDPCDDiscBoxData = disc_data:getModData(); --таблица диска
	local disc_name = ICDPCDDiscBoxData.DiscName;

--- Поиск подходящей коробки с таким же названием диска
	for i = 0, player:getInventory():getItems():size() - 1 do

		local item = player:getInventory():getItems():get(i);

		if item:getType() == "ICDPCDBoxEmpty" and item:getModData().DiscName == disc_name then -- находим пустую коробку с таким-же названием диска

			InsertDiscEmptyBoxWithName(item, player, disc_data, disc_name)
		return end

		if item:getType() == "ICDPCDBoxEmpty" and item:hasModData() == false then -- находим пустую коробку без описания/содержания... чистую... от багов и т.д.
			InsertDiscEmptyBoxNoName(item, player, disc_data, disc_name)
		return end
	end
	--- если не один из вариантов не прокатил, персонаж говорит - "Нет подходящей коробки..."
	player:Say(getText"IGUI_No_suitable_CD_box"); --- нет подходящей коробки для диска
end

--Проверяем предмет, по которому кликнули ICDP ли это диск - для показа контекстного меню + проверка наличия пустых коробок
local function checkInvItemDiscAndBox(player, context, worldobjects, item)
    local disc_name = item:getType()
	local disc_data = item
	local check_emptybox

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

		local empty_cdbox = player:getInventory():getItems():get(i);

		if empty_cdbox:getType() == "ICDPCDBoxEmpty" then -- проверка наличия пустой коробки для диска
			check_emptybox = true
		end

	end

	if  check_emptybox ~= true then -- если нет пустой коробки, то не показывать меню
		return
	end

	local option = context:addOption(getText("IGUI_ContextMenu_Put_CD_in_CD-Box"), player, SearchEmptyBoxes, disc_name, disc_data, item);

    if not isItemValid(player, disc_name, item) then
        DisableOption(option, getText("IGUI_ContextMenu_Cant_Action"))
    end
end

--Добавляет пункт меню для ICDP Дисков
local invContextMenuDiscAndBox = function(_player, context, worldobjects, test)

    local playerObj = getSpecificPlayer(_player);

    for i,k in pairs(worldobjects) do
		-- inventory item list
        if instanceof(k, "InventoryItem") then
            checkInvItemDiscAndBox(playerObj, context, worldobjects, k);

			elseif not instanceof(k, "InventoryItem") and k.items and #k.items > 1 then
			checkInvItemDiscAndBox(playerObj, context, worldobjects, k.items[1]);
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(invContextMenuDiscAndBox); -- контекстное меню для ICDP дисков (положить диск в коробку)