local LOC_KEY = {
	ICDPCDplayerOn = "IGUI_CD_Player_On",
	ICDPCDplayerWithDisc = "IGUI_CD_Player_With_Disc",
	ICDPCDplayer = "IGUI_ICDP_CD_Player_Off",
}

local TYPE_COLOR = {
	ICDPCDplayerOn = {1,.6,.2},
	ICDPCDplayerWithDisc = {.4,.7,1},
	ICDPCDplayer = {.7,.7,.7},
	RED_UNKNOWN = {1,.4,.4}, --???
}

local cache_render_item = nil
local cache_render_text = nil
local cache_render_type = nil
local disc_name
local artist_name
local num_track
local track_sum
local power

local old_render = ISToolTipInv.render
function ISToolTipInv:render()

	if self.item ~= cache_render_item then
		cache_render_item = self.item
		cache_render_text = nil
		if self.item and self.item:getType() then
			if self.item:getType() == "ICDPCDplayerOn" or self.item:getType() == "ICDPCDplayerWithDisc" or self.item:getType() == "ICDPCDplayer" then
				local device_name = self.item:getType();
				
				if device_name and self.item:hasModData() == false then
					getPlayer():getInventory():Remove(device_name)
					getPlayer():Say("Item Removed - ANTI Cheat!!!")
				return end
				
				if device_name == "ICDPCDplayer" then
					
					local ICDPCDplayerData = self.item:getModData()
					local power = ICDPCDplayerData.Power

					if power == true then
						artist_name = (getText("IGUI_No_CD"));
						num_track = "-";
						track_sum = "-/--";
					end
					
					if power == false then
						artist_name = "-----";
						num_track = "-";
						track_sum = "-/--";
					end
					
				end
				
				if device_name ~= "ICDPCDplayer" then

					local ICDPCDplayerData = self.item:getModData()
				
					disc_name = ICDPCDplayerData.DiscName; --получаем имя диска в плеере
					local disc_data = self.item

					InitDiscName(disc_data, disc_name); --инициализируем таблицу дисков
				
					local num = ICDPCDplayerData.disc_num;
					track_sum = ("/" .. tostring(ICDP_DISCS[num].track_sum));
					artist_name = ICDPCDplayerData.ArtistName --получаем имя исполнителя
					num_track = ICDPCDplayerData.NumTrack
					power = ICDPCDplayerData.Power
				
					if artist_name == nil or artist_name == "error" then
						artist_name = (getText("IGUI_Unknown"))
					end
				
					if power == false and device_name == "ICDPCDplayerWithDisc" then
						artist_name = "-----";
						num_track = "-";
						track_sum = "-/--";
					end
				end
				
					if device_name then
						cache_render_type = device_name
						local localization = device_name
						local key = LOC_KEY[device_name]
						
						if key then
							local trans = getText(key)
							if trans ~= key then --translation exists!
								localization = trans
							end
						end
					
						cache_render_text = (getText("IGUI_Loaded") .. tostring(artist_name)) -- getText("IGUI_") .. localization
						cache_render_text2 = (getText("IGUI_Track") .. tostring(num_track) .. (track_sum))
					end
			end
		end
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
			self.tooltip:DrawText(UIFont.Small, cache_render_text, 5, save_th-5, col[1], col[2], col[3], 1); --- save_th (высота надписи)
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