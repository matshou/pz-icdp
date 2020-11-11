local LOC_KEY = {
	ICDPCDBoxFull = "CD-Box Full",
	ICDPCDBoxEmpty = "CD-Box Empty",
}

local TYPE_COLOR = {
	ICDPCDBoxFull = {.4,.7,1}, --- Исходный цвет.. 	{1,.6,.2},
	ICDPCDBoxEmpty = {.4,.7,1},
}

local cache_render_item = nil
local cache_render_text = nil
local cache_render_type = nil
local artist_name
local album_title
local desc

local old_render = ISToolTipInv.render
function ISToolTipInv:render()
	if self.item ~= cache_render_item then
		cache_render_item = self.item
		cache_render_text = nil
		if self.item and self.item:getType() then
			if self.item:getType() == "ICDPCDBoxFull" or self.item:getType() == "ICDPCDBoxEmpty" then
				local cdbox_name = self.item:getType();

					if self.item:hasModData() == false then return end

					local ICDPCDDiscBoxData = self.item:getModData() -- получаем таблицу предмета
					desc = ICDPCDDiscBoxData.Desc; -- наличие описания/содержания коробки

					if cdbox_name == "ICDPCDBoxEmpty" or cdbox_name == "ICDPCDBoxFull" and desc == true then
						artist_name = ICDPCDDiscBoxData.ArtistName;
						album_title = ICDPCDDiscBoxData.AlbumTitle;

						elseif desc == false and cdbox_name == "ICDPCDBoxFull" then
							artist_name = (getText("IGUI_There_is_a_CD_inside"));
							album_title = (getText("IGUI_CD-box_no_description"));
						end

						if cdbox_name then
							cache_render_type = cdbox_name
							local localization = cdbox_name
							local key = LOC_KEY[cdbox_name]

							if key then
							local trans = getText(key)

							if trans ~= key then --translation exists!
							localization = trans
						end
					end

					cache_render_text = tostring(artist_name) -- getText("IGUI_") .. localization
					cache_render_text2 = tostring(album_title)
				end
			end
		end
	end

	if not cache_render_text or not cache_render_text2 then --small item (or error?)
		return old_render(self)
	end

	-- Ninja double injection in injection!
	local stage = 1
	local save_th = 0
	local old_setHeight = self.setHeight
	self.setHeight = function(self, num, ...)
	if stage == 1 then
		stage = 2
		save_th = num
		num = num + 29 --- высота окна tooltip
		else
			stage = -1 --error
		end
		return old_setHeight(self, num, ...)
	end

	local old_drawRectBorder = self.drawRectBorder
	self.drawRectBorder = function(self, ...)
	if stage == 2 then
		local col; -- {r,g,b}
		if cache_render_type then
		local col = TYPE_COLOR[cache_render_type] or TYPE_COLOR.RED_UNKNOWN;

		self.tooltip:DrawText(UIFont.Small, cache_render_text, 5, save_th-5, col[1], col[2], col[3], 1); --- save_th (высота надписи относительно окна тултип)
		self.tooltip:DrawText(UIFont.Small, cache_render_text2, 5, save_th+10, col[1], col[2], col[3], 1);
	end

	stage = 3

	else
		stage = -1 --error
	end
		return old_drawRectBorder(self, ...)
	end

	old_render(self)
	self.setHeight = old_setHeight
	self.drawRectBorder = old_drawRectBorder
end