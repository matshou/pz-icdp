local LOC_KEY = {
	ICDPCDDisc = "ICDPCDDisc",
}

local TYPE_COLOR = {
	ICDPCDDisc = {0.933, 0.933, 0.745}, --- Исходный цвет.. 	{1,.6,.2},
}

local cache_render_item = nil
local cache_render_text = nil
local cache_render_type = nil
local album_title

local old_render = ISToolTipInv.render
function ISToolTipInv:render()

	if self.item ~= cache_render_item then
		cache_render_item = self.item
		cache_render_text = nil

		if self.item and self.item:getType() then
			local disc_name = self.item:getType()

			if string.find(disc_name,"ICDPCDDisc",1,true) == 1 then --- начало строки итема - не равно "ICDPCDDisc" ***** СПАСИБО STAR за помощь! *****
				local disc_name = "ICDPCDDisc";

				local ICDPCDDiscData = self.item:getModData() -- получаем таблицу предмета
				album_title = ICDPCDDiscData.AlbumTitle; --название альбома

				if disc_name then
					cache_render_type = disc_name
					local localization = disc_name
					local key = LOC_KEY[disc_name]

					if key then

						local trans = getText(key)

						if trans ~= key then --translation exists!
							localization = trans
						end

					end

					cache_render_text = tostring(album_title) -- getText("IGUI_") .. localization
				end
			end

		else return end
	end

	if not cache_render_text then --small item (or error?)
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
		num = num + 19 --- высота окна tooltip
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