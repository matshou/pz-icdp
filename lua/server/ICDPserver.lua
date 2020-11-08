ICDP = {}
ICDP.version = "1.14";
ICDP.author = "Nebula";
ICDP.modName = "iCDPlayersSV";

ICDP.OnClientCommand = function(module, command, player, args)
	if not isServer() then return end
	if module ~= "iCDPlayersSV" then return end; 
	
 	if command == "Say" then       
			player:Say(args.saythis);
	end
	
end
	
Events.OnClientCommand.Add(ICDP.OnClientCommand);
