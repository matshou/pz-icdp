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

function Inspect_CDBox(player, item)

    if not isItemValid(player, item) then
        return --no dupe anymore
	end

	local cd_box_item = item;
	local ICDPCDDiscBoxData = cd_box_item:getModData();
--	local num = ICDPCDDiscBoxData.disc_num;
	local disc_name = ICDPCDDiscBoxData.DiscName;

	InitDiscName(cd_box_item, disc_name);

	local num = ICDPCDDiscBoxData.disc_num;
	local album_title = ICDP_DISCS[num].album_title; --- название исполнителя и альбома
	local album_cover = ICDP_DISCS[num].album_cover; --- получаем название файла обложки диска
	local artist_name = ICDP_DISCS[num].artist_name or "???"; --получаем имя исполнителя
	local track_sum = ICDP_DISCS[num].track_sum; --- количество треков в диске

	if disc_name == "ICDPCDDisc1" then

	if not player:HasTrait("Deaf") then
		getPlayer():Say(getText("IGUI_No_Cover"));
	end
	return end

	CDBoxWindow.title = (artist_name .. " - " .. album_title);
	CDBoxWindow.album_cover = album_cover

	local CDBoxstring = "";

	for i = 1, track_sum, 1 do
		CDBoxstring = CDBoxstring .. ICDP_DISCS[num].track_names[i] .. "\n";
	end

	CDBoxWindow:setText(CDBoxstring);
	CDBoxWindow:setVisible(true);
end

--Проверяет предмет, по которому кликнули CDBox ли это?
local function checkInvItemCDBox(player, context, worldobjects, item)
    local name = item:getType();

    if not name then
        return
    end

	if string.find(name,"ICDPCDBox",1,true) ~= 1 then --- начало строки итема - не равно "ICDPCDBox"
        return
	end

	local option = context:addOption(getText("IGUI_ContextMenu_InspectCDBox"), player, Inspect_CDBox, item);
    if not isItemValid(player, item) then
        DisableOption(option, getText("IGUI_ContextMenu_Cant_Action"))
    end
 end

local invContextInspectCDBox = function(_player, context, worldobjects, test)
    local playerObj = getSpecificPlayer(_player);

    for i,k in pairs(worldobjects) do
		-- inventory item list
        if instanceof(k, "InventoryItem") then
            checkInvItemCDBox(playerObj, context, worldobjects, k);
			elseif not instanceof(k, "InventoryItem") and k.items and #k.items > 1 then
            checkInvItemCDBox(playerObj, context, worldobjects, k.items[1]);
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(invContextInspectCDBox);