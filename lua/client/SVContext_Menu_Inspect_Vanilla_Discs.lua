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

local function isItemValid(player, item)
    return item:getContainer() == player:getInventory();
end

--Заменить при осмотре - диск на диск из мода
function Inspect_Vanilla_CD(player, item)
	local disc_name
	local disc_box_data
    local CDDiscNum = ZombRand(total_number_discs) + 1;

    if not isItemValid(player, item) then
        return --no dupe anymore
    end

	local inv = player:getInventory()
	inv:Remove(item); --удаляем осматриваемый диск

	inv:AddItem("ICDP.ICDPCDBoxFull"); --добавляем новый диск в коробке в инвентарь

		for i = 0, player:getInventory():getItems():size() - 1 do
			local item = player:getInventory():getItems():get(i);
			if item:getType() == "ICDPCDBoxFull" and item:hasModData() == false then -- находим добавленный диск в коробке / hasModData() - возвращает true/false наличие таблицы - Спасибо star!!!!!
				disc_box_data = item --сохраняем итем в переменной
			end
		end

		disc_name = ("ICDPCDDisc" .. tostring(CDDiscNum)); --присваиваем имя новому диску из случайно выбранного количества дисков [CDDiscNum] в моде.

		--- Создание таблицы коробки с диском внутри ---
		local disc_data = disc_box_data;
		InitDiscName(disc_data, disc_name); --инициализируем диск

		local ICDPCDDiscBoxData = disc_data:getModData(); -- получаем таблицу коробки с диском
		local num = ICDPCDDiscBoxData.disc_num; -- номер диска в коробке

		ICDPCDDiscBoxData.DiscName = ICDP_DISCS[num].disc_name; -- имя диска (item) в коробке
		ICDPCDDiscBoxData.ArtistName = ICDP_DISCS[num].artist_name; -- Название исполнителя
		ICDPCDDiscBoxData.AlbumTitle = ICDP_DISCS[num].album_title; -- название альбома
		ICDPCDDiscBoxData.AlbumCover = ICDP_DISCS[num].album_cover; -- обложка коробки компакт-диска
		ICDPCDDiscBoxData.ContentDisc = ICDP_DISCS[num].content_disc; -- стиль/направление содержимого/музыки на диске
		ICDPCDDiscBoxData.TrackSum = ICDP_DISCS[num].track_sum; -- количество треков на диске в коробке
		ICDPCDDiscBoxData.EntropyDisc = 0; -- изношенность диска в коробке
		ICDPCDDiscBoxData.Desc = true -- присутствие описания на коробке /да
end

--Проверяет предмет, по которому кликнули диск-ли это?
local function checkInvItem(player, context, worldobjects, item)
    local name = item:getType();

    if not name then
        return
    end

	if name ~= "Disc" and name ~= "HCCDcasefull" then
		return
	end

	local option = context:addOption(getText("IGUI_ContextMenu_CD"), player, Inspect_Vanilla_CD, item);
    if not isItemValid(player, item) then
        DisableOption(option, getText("IGUI_ContextMenu_Cant_Action"))
    end
end

--Добавляет пункт меню для Ванильных Дисков
local invContextMenu1 = function(_player, context, worldobjects, test)
    local playerObj = getSpecificPlayer(_player);

    for i,k in pairs(worldobjects) do
		-- inventory item list
        if instanceof(k, "InventoryItem") then
            checkInvItem(playerObj, context, worldobjects, k);
			elseif not instanceof(k, "InventoryItem") and k.items and #k.items > 1 then
            checkInvItem(playerObj, context, worldobjects, k.items[1]);
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(invContextMenu1); -- контекстное меню для ванильных дисков