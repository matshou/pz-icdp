CDBoxWindow = ISCollapsableWindow:derive("CDBoxWindow");
CDBoxWindow.compassLines = {}

function CDBoxWindow:initialise()
	ISCollapsableWindow.initialise(self);
end

function CDBoxWindow:new(x, y, width, height)
	local o = {};
	o = ISCollapsableWindow:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	o.title = (getText("IGUI_CDBox_Window"));
	o.backgroundColor.a = 1
	--o.pin = false;
	--o:noBackground();
	return o;
end

local CDBoxWindowHeight = 275;

function CDBoxWindow:setText(newText)
	CDBoxWindow.HomeWindow.text = newText;
	CDBoxWindow.HomeWindow:paginate();
	
	local tempTexture = getTexture("media/textures/cd_cover/" .. CDBoxWindow.album_cover .. ".png")
	if (tempTexture) then self.Image:setImage(tempTexture) 
	else self.Image:setImage(getTexture("media/textures/cd_cover/no_cover.png")) end
end

function CDBoxWindow:createChildren()
	ISCollapsableWindow.createChildren(self);
	
	self.Image = ISButton:new(10, 25, 240, 240, " ", nil, nil);
	self.Image:setImage(getTexture("media/textures/cd_cover/no_cover.png"))
	self.Image:setVisible(true);
	self.Image:setEnable(true);
	--self.Image:addToUIManager();
	self:addChild(self.Image)
	
	self.HomeWindow = ISRichTextPanel:new(250, 20, 340, 240);
	self.HomeWindow:initialise();
	self.HomeWindow.autosetheight = false
	self.HomeWindow.marginRight = 17
	self.HomeWindow.clip = true
	self.HomeWindow.backgroundColor.a = 1
	--self.HomeWindow:ignoreHeightChange() -- CDBoxWindow.HomeWindow:setHeight(100)
	self.HomeWindow:addScrollBars()
	self:addChild(self.HomeWindow)
end

function CDBoxWindowCreate()
	CDBoxWindow = CDBoxWindow:new(20, 520, 610, CDBoxWindowHeight) -- x, y, width, height
	CDBoxWindow:addToUIManager();
	CDBoxWindow:setVisible(false);
	--CDBoxWindow.pin = false;
	CDBoxWindow.resizable = false;
end

Events.OnGameStart.Add(CDBoxWindowCreate);