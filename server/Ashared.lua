CK = {}

local function GetCoreObject()
	return CK
end

AddEventHandler('CK:GetCoreObject', function(cb)
	cb(GetCoreObject())
end)

local Perfect_World = [[^2 
 _____   _   _         _____   _____   _____    _____        _____   _____   _____       ___  
/  ___| | | / /       /  ___| /  _  \ |  _  \  | ____|      |  _  \ | ____| |_   _|     /   | 
| |     | |/ /        | |     | | | | | |_| |  | |__        | |_| | | |__     | |      / /| | 
| |     | |\ \        | |     | | | | |  _  /  |  __|       |  _  { |  __|    | |     / / | | 
| |___  | | \ \       | |___  | |_| | | | \ \  | |___       | |_| | | |___    | |    / /  | | 
\_____| |_|  \_\ ____ \_____| \_____/ |_|  \_\ |_____| ____ |_____/ |_____|   |_|   /_/   |_| 

^0
]]

Citizen.CreateThread(function()
	print(Perfect_World)
end)
