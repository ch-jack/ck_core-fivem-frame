CK.data = {}
CK.ClientCfg = {}
CK.Game = {}

CK.CurrentRequestId = 0
CK.ServerCallbacks = {}

CK.SetObj = function(key, value)
	CK.data[key] = value
end

CK.GetObj = function(key)
	if CK.data[key] == undef then
		print("^1Error CK Get Null Obj:"..key.."^0")
	end
	return CK.data[key]
end

local ClientKvpKey <const> = "ck_core_client_cfg"
CK.ClientCfg = json.decode(GetResourceKvpString(ClientKvpKey))

CK.SaveCfg = function(key,value)
	CK.ClientCfg[key] = value
	SetResourceKvp(ClientKvpKey,json.encode(CK.ClientCfg))
end

CK.GetCfg = function(key)
	return CK.ClientCfg[key] ~= undef and CK.ClientCfg[key] or 0
end

CK.CleanCfg = function()
	CK.ClientCfg = {}
	SetResourceKvp(ClientKvpKey,json.encode({}))
end

CK.TriggerServerCallback = function(name, cb, ...)
	CK.ServerCallbacks[CK.CurrentRequestId] = cb

	CK.SendData('CK:triggerServerCallback', name, CK.CurrentRequestId, ...)

	if CK.CurrentRequestId < 65535 then
		CK.CurrentRequestId = CK.CurrentRequestId + 1
	else
		CK.CurrentRequestId = 0
	end
end

AddEventHandler('CK:serverCallback', function(requestId, ...)
	CK.ServerCallbacks[requestId](...)
	CK.ServerCallbacks[requestId] = undef
end)

--------------------------------------------Client Game Function--------------------------------------------

CK.ShowNotification = function(msg, flash, saveToBrief, hudColorIndex)
	if saveToBrief == nil then saveToBrief = true end
	AddTextEntry('Notification', msg)
	BeginTextCommandThefeedPost('Notification')
	if hudColorIndex then ThefeedNextPostBackgroundColor(hudColorIndex) end
	EndTextCommandThefeedPostTicker(flash or false, saveToBrief)
end

CK.ShowAdvancedNotification = function(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
	if saveToBrief == nil then saveToBrief = true end
	AddTextEntry('AdvancedNotification', msg)
	BeginTextCommandThefeedPost('AdvancedNotification')
	if hudColorIndex then ThefeedNextPostBackgroundColor(hudColorIndex) end
	EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, iconType, sender, subject)
	EndTextCommandThefeedPostTicker(flash or false, saveToBrief)
end
	
CK.ShowHelpNotification = function(msg, thisFrame, beep, duration)
	AddTextEntry('HelpNotification', msg)

	if thisFrame then
		DisplayHelpTextThisFrame('HelpNotification', false)
	else
		if beep == nil then beep = true end
		BeginTextCommandDisplayHelp('HelpNotification')
		EndTextCommandDisplayHelp(0, false, beep, duration or -1)
	end
end

CK.Game.GetPedMugshot = function(ped)
	if DoesEntityExist(ped) then
		local mugshot

		if transparent then
			mugshot = RegisterPedheadshotTransparent(ped)
		else
			mugshot = RegisterPedheadshot(ped)
		end

		while not IsPedheadshotReady(mugshot) do
			Citizen.Wait(0)
		end

		return mugshot, GetPedheadshotTxdString(mugshot)
	else
		return
	end
end

CK.Game.Teleport = function(entity, coords, cb)
	if DoesEntityExist(entity) then
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)
		local timeout = 0

		-- we can get stuck here if any of the axies are "invalid"
		while not HasCollisionLoadedAroundEntity(entity) and timeout < 2000 do
			Citizen.Wait(0)
			timeout = timeout + 1
		end

		SetEntityCoords(entity, coords.x, coords.y, coords.z, false, false, false, false)

		if type(coords) == 'table' and coords.heading then
			SetEntityHeading(entity, coords.heading)
		end
	end

	if cb then
		cb()
	end
end

CK.Game.SpawnObject = function(model, coords, locals, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))
	Citizen.CreateThread(function()
		CK.Streaming.RequestModel(model)
		local obj = CreateObject(model, coords.x, coords.y, coords.z, locals == nil and true or false, false, true)
		SetModelAsNoLongerNeeded(model)
		
		if cb ~= nil then
			cb(obj)
		end
	end)
end

CK.Game.DeleteVehicle = function(vehicle)
	SetEntityAsMissionEntity(vehicle, false, true)
	DeleteVehicle(vehicle)
end

CK.Game.DeleteObject = function(object)
	SetEntityAsMissionEntity(object, false, true)
	DeleteObject(object)
end

CK.Game.SpawnVehicle = function(modelName, coords, heading, locals, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	Citizen.CreateThread(function()
		CK.Streaming.RequestModel(model)

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, locals == nil and true or false, false)
		local networkId = NetworkGetNetworkIdFromEntity(vehicle)
		local timeout = 0

		SetNetworkIdCanMigrate(networkId, true)
		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetVehRadioStation(vehicle, 'OFF')
		SetModelAsNoLongerNeeded(model)
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)

		-- we can get stuck here if any of the axies are "invalid"
		while not HasCollisionLoadedAroundEntity(vehicle) and timeout < 2000 do
			Citizen.Wait(0)
			timeout = timeout + 1
		end

		if cb ~= nil then
			cb(vehicle)
		end
	end)
end

CK.Game.GetObjects = function()
	local objects = {}

	for object in EnumerateObjects() do
		table.insert(objects, object)
	end

	return objects
end

CK.Game.GetPeds = function(onlyOtherPeds)
	local peds, myPed = {}, PlayerPedId()

	for ped in EnumeratePeds() do
		if ((onlyOtherPeds and ped ~= myPed) or not onlyOtherPeds) then
			table.insert(peds, ped)
		end
	end

	return peds
end

CK.Game.GetVehicles = function()
	local vehicles = {}

	for vehicle in EnumerateVehicles() do
		table.insert(vehicles, vehicle)
	end

	return vehicles
end

CK.Game.GetPlayers = function(onlyOtherPlayers, returnKeyValue, returnPeds)
	local players, myPlayer = {}, PlayerId()

	for k,player in ipairs(GetActivePlayers()) do
		local ped = GetPlayerPed(player)

		if DoesEntityExist(ped) and ((onlyOtherPlayers and player ~= myPlayer) or not onlyOtherPlayers) then
			if returnKeyValue then
				players[player] = ped
			else
				table.insert(players, returnPeds and ped or player)
			end
		end
	end

	return players
end

CK.Game.GetClosestObject = function(coords, modelFilter) return CK.Game.GetClosestEntity(CK.Game.GetObjects(), false, coords, modelFilter) end
CK.Game.GetClosestPed = function(coords, modelFilter) return CK.Game.GetClosestEntity(CK.Game.GetPeds(true), false, coords, modelFilter) end
CK.Game.GetClosestPlayer = function(coords) return CK.Game.GetClosestEntity(CK.Game.GetPlayers(true, true), true, coords, nil) end
CK.Game.GetClosestVehicle = function(coords, modelFilter) return CK.Game.GetClosestEntity(CK.Game.GetVehicles(), false, coords, modelFilter) end
CK.Game.GetPlayersInArea = function(coords, maxDistance) return EnumerateEntitiesWithinDistance(CK.Game.GetPlayers(true, true), true, coords, maxDistance) end
CK.Game.GetVehiclesInArea = function(coords, maxDistance) return EnumerateEntitiesWithinDistance(CK.Game.GetVehicles(), false, coords, maxDistance) end
CK.Game.IsSpawnPointClear = function(coords, maxDistance) return #CK.Game.GetVehiclesInArea(coords, maxDistance) == 0 end

CK.Game.GetClosestEntity = function(entities, isPlayerEntities, coords, modelFilter)
	local closestEntity, closestEntityDistance, filteredEntities = -1, -1, nil

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end

	if modelFilter then
		filteredEntities = {}

		for k,entity in pairs(entities) do
			if modelFilter[GetEntityModel(entity)] then
				table.insert(filteredEntities, entity)
			end
		end
	end

	for k,entity in pairs(filteredEntities or entities) do
		local distance = #(coords - GetEntityCoords(entity))

		if closestEntityDistance == -1 or distance < closestEntityDistance then
			closestEntity, closestEntityDistance = isPlayerEntities and k or entity, distance
		end
	end

	return closestEntity, closestEntityDistance
end

CK.Game.GetVehicleProperties = function(vehicle)
	local color1, color2               = GetVehicleColours(vehicle)
	local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
	
	local Burst = GetVehicleTyresCanBurst(vehicle)
	
	local extras = {}
	for id=0, 30 do
		if DoesExtraExist(vehicle, id) then
			local state = IsVehicleExtraTurnedOn(vehicle, id) == 1
			extras[tostring(id)] = state
		end
	end
	
	return {
		
		model            = GetEntityModel(vehicle),
		
		plate            = GetVehicleNumberPlateText(vehicle),
		plateIndex       = GetVehicleNumberPlateTextIndex(vehicle),

		bodyHealth        = math.floor(GetVehicleBodyHealth(vehicle)),
		engineHealth      = math.floor(GetVehicleEngineHealth(vehicle)),

		fuelLevel         = math.floor(GetVehicleFuelLevel(vehicle)),
		dirtLevel         = math.floor(GetVehicleDirtLevel(vehicle)),
		color1           = color1,
		color2           = color2,

		pearlescentColor = pearlescentColor,
		wheelColor       = wheelColor,
		
		wheels           = GetVehicleWheelType(vehicle),
		windowTint       = GetVehicleWindowTint(vehicle),
		
		neonEnabled      = {
			IsVehicleNeonLightEnabled(vehicle, 0),
			IsVehicleNeonLightEnabled(vehicle, 1),
			IsVehicleNeonLightEnabled(vehicle, 2),
			IsVehicleNeonLightEnabled(vehicle, 3),
		},

		extras           = extras,

		neonColor        = table.pack(GetVehicleNeonLightsColour(vehicle)),
		tyreSmokeColor   = table.pack(GetVehicleTyreSmokeColor(vehicle)),
		
		modSpoilers      = GetVehicleMod(vehicle, 0),
		modFrontBumper   = GetVehicleMod(vehicle, 1),
		modRearBumper    = GetVehicleMod(vehicle, 2),
		modSideSkirt     = GetVehicleMod(vehicle, 3),
		modExhaust       = GetVehicleMod(vehicle, 4),
		modFrame         = GetVehicleMod(vehicle, 5),
		modGrille        = GetVehicleMod(vehicle, 6),
		modHood          = GetVehicleMod(vehicle, 7),
		modFender        = GetVehicleMod(vehicle, 8),
		modRightFender   = GetVehicleMod(vehicle, 9),
		modRoof          = GetVehicleMod(vehicle, 10),

		modEngine        = GetVehicleMod(vehicle, 11),
		modBrakes        = GetVehicleMod(vehicle, 12),
		modTransmission  = GetVehicleMod(vehicle, 13),
		modHorns         = GetVehicleMod(vehicle, 14),
		modSuspension    = GetVehicleMod(vehicle, 15),
		modArmor         = GetVehicleMod(vehicle, 16),

		modTurbo         = IsToggleModOn(vehicle,  18),
		modSmokeEnabled  = IsToggleModOn(vehicle,  20),
		modXenon         = IsToggleModOn(vehicle,  22),
		HeadlightColor   = GetVehicleXenonLightsColour(vehicle),

		modFrontWheels   = GetVehicleMod(vehicle, 23),
		modBackWheels    = GetVehicleMod(vehicle, 24),

		modPlateHolder   	= GetVehicleMod(vehicle, 25),
		modVanityPlate   	= GetVehicleMod(vehicle, 26),
		modTrimA    		= GetVehicleMod(vehicle, 27),
		modOrnaments    	= GetVehicleMod(vehicle, 28),
		modDashboard    	= GetVehicleMod(vehicle, 29),
		modDial    			= GetVehicleMod(vehicle, 30),
		modDoorSpeaker    	= GetVehicleMod(vehicle, 31),
		modSeats    		= GetVehicleMod(vehicle, 32),
		modSteeringWheel    = GetVehicleMod(vehicle, 33),
		modShifterLeavers   = GetVehicleMod(vehicle, 34),
		modAPlate    		= GetVehicleMod(vehicle, 35),
		modSpeakers    		= GetVehicleMod(vehicle, 36),
		modTrunk    		= GetVehicleMod(vehicle, 37),
		modHydrolic    		= GetVehicleMod(vehicle, 38),
		modEngineBlock    	= GetVehicleMod(vehicle, 39),
		modAirFilter    	= GetVehicleMod(vehicle, 40),
		modStruts    		= GetVehicleMod(vehicle, 41),
		modArchCover    	= GetVehicleMod(vehicle, 42),
		modAerials    		= GetVehicleMod(vehicle, 43),
		modTrimB    		= GetVehicleMod(vehicle, 44),
		modTank    			= GetVehicleMod(vehicle, 45),
		modWindows    		= GetVehicleMod(vehicle, 46),
		modLiverys    		= GetVehicleMod(vehicle, 48),
		modLivery    		= GetVehicleLivery(vehicle),
		
		CustomWheels = GetVehicleModVariation(vehicle, 23),
	
		Burst = Burst,
	}
end

CK.Game.SetVehicleProperties = function(vehicle, props)
	SetVehicleModKit(vehicle,  0)

	if props.plate ~= nil then
		SetVehicleNumberPlateText(vehicle, props.plate)
	end

	if props.plateIndex ~= nil then
		SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
	end

	if props.bodyHealth ~= nil then
		SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
	end

	if props.engineHealth ~= nil then
		SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
	end

	if props.fuelLevel ~= nil then
		SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
	end

	if props.dirtLevel ~= nil then
		SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
	end
	
	if props.color2 ~= nil then
		local color1, color2 = GetVehicleColours(vehicle)
		SetVehicleColours(vehicle, color1, props.color2)
	end

	if props.color1 ~= nil then
		local color1, color2 = GetVehicleColours(vehicle)
		SetVehicleColours(vehicle, props.color1, color2)
	end

	if props.pearlescentColor ~= nil then
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleExtraColours(vehicle,  props.pearlescentColor,  wheelColor)
	end

	if props.wheelColor ~= nil then
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleExtraColours(vehicle,  pearlescentColor,  props.wheelColor)
	end

	if props.wheels ~= nil then
		SetVehicleWheelType(vehicle,  props.wheels)
	end

	if props.windowTint ~= nil then
		SetVehicleWindowTint(vehicle,  props.windowTint)
	end

	if props.neonEnabled ~= nil then
		SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
		SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
		SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
		SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
	end
	
	if props.extras ~= nil then
		for id,enabled in pairs(props.extras) do
			if enabled then
				SetVehicleExtra(vehicle, tonumber(id), 0)
			else
				SetVehicleExtra(vehicle, tonumber(id), 1)
			end
		end
	end
	
	if props.neonColor ~= nil then
		SetVehicleNeonLightsColour(vehicle,  props.neonColor[1], props.neonColor[2], props.neonColor[3])
	end

	if props.modSmokeEnabled ~= nil then	
		ToggleVehicleMod(vehicle, 20, true)
	end

	if props.tyreSmokeColor ~= nil then
		SetVehicleTyreSmokeColor(vehicle,  props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
	end
	
	if props.modSpoilers ~= nil then
		SetVehicleMod(vehicle, 0, props.modSpoilers, false)
	end

	if props.modFrontBumper ~= nil then
		SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
	end

	if props.modRearBumper ~= nil then
		SetVehicleMod(vehicle, 2, props.modRearBumper, false)
	end

	if props.modSideSkirt ~= nil then
		SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
	end

	if props.modExhaust ~= nil then
		SetVehicleMod(vehicle, 4, props.modExhaust, false)
	end

	if props.modFrame ~= nil then
		SetVehicleMod(vehicle, 5, props.modFrame, false)
	end

	if props.modGrille ~= nil then
		SetVehicleMod(vehicle, 6, props.modGrille, false)
	end

	if props.modHood ~= nil then
		SetVehicleMod(vehicle, 7, props.modHood, false)
	end

	if props.modFender ~= nil then
		SetVehicleMod(vehicle, 8, props.modFender, false)
	end

	if props.modRightFender ~= nil then
		SetVehicleMod(vehicle, 9, props.modRightFender, false)
	end

	if props.modRoof ~= nil then
		SetVehicleMod(vehicle, 10, props.modRoof, false)
	end

	if props.modEngine ~= nil then
		SetVehicleMod(vehicle, 11, props.modEngine, false)
	end

	if props.modBrakes ~= nil then
		SetVehicleMod(vehicle, 12, props.modBrakes, false)
	end

	if props.modTransmission ~= nil then
		SetVehicleMod(vehicle, 13, props.modTransmission, false)
	end

	if props.modHorns ~= nil then
		SetVehicleMod(vehicle, 14, props.modHorns, false)
	end

	if props.modSuspension ~= nil then
		SetVehicleMod(vehicle, 15, props.modSuspension, false)
	end

	if props.modArmor ~= nil then
		SetVehicleMod(vehicle, 16, props.modArmor, false)
	end

	if props.modTurbo ~= nil then
		ToggleVehicleMod(vehicle,  18, props.modTurbo)
	end

	if props.modXenon ~= nil then
		ToggleVehicleMod(vehicle,  22, props.modXenon)
		if props.modXenon and props.HeadlightColor ~= nil then
			SetVehicleXenonLightsColour(vehicle, props.HeadlightColor)
		end
	end

	if props.modFrontWheels ~= nil then
		SetVehicleMod(vehicle, 23, props.modFrontWheels, false)
	end

	if props.modBackWheels ~= nil then
		SetVehicleMod(vehicle, 24, props.modBackWheels, false)
	end

	if props.modPlateHolder ~= nil then
		SetVehicleMod(vehicle, 25, props.modPlateHolder , false)
	end

	if props.modVanityPlate ~= nil then
		SetVehicleMod(vehicle, 26, props.modVanityPlate , false)
	end

	if props.modTrimA ~= nil then
		SetVehicleMod(vehicle, 27, props.modTrimA , false)
	end

	if props.modOrnaments ~= nil then
		SetVehicleMod(vehicle, 28, props.modOrnaments , false)
	end

	if props.modDashboard ~= nil then
		SetVehicleMod(vehicle, 29, props.modDashboard , false)
	end

	if props.modDial ~= nil then
		SetVehicleMod(vehicle, 30, props.modDial , false)
	end

	if props.modDoorSpeaker ~= nil then
		SetVehicleMod(vehicle, 31, props.modDoorSpeaker , false)
	end

	if props.modSeats ~= nil then
		SetVehicleMod(vehicle, 32, props.modSeats , false)
	end

	if props.modSteeringWheel ~= nil then
		SetVehicleMod(vehicle, 33, props.modSteeringWheel , false)
	end

	if props.modShifterLeavers ~= nil then
		SetVehicleMod(vehicle, 34, props.modShifterLeavers , false)
	end

	if props.modAPlate ~= nil then
		SetVehicleMod(vehicle, 35, props.modAPlate , false)
	end

	if props.modSpeakers ~= nil then
		SetVehicleMod(vehicle, 36, props.modSpeakers , false)
	end

	if props.modTrunk ~= nil then
		SetVehicleMod(vehicle, 37, props.modTrunk , false)
	end

	if props.modHydrolic ~= nil then
		SetVehicleMod(vehicle, 38, props.modHydrolic , false)
	end

	if props.modEngineBlock ~= nil then
		SetVehicleMod(vehicle, 39, props.modEngineBlock , false)
	end

	if props.modAirFilter ~= nil then
		SetVehicleMod(vehicle, 40, props.modAirFilter , false)
	end

	if props.modStruts ~= nil then
		SetVehicleMod(vehicle, 41, props.modStruts , false)
	end

	if props.modArchCover ~= nil then
		SetVehicleMod(vehicle, 42, props.modArchCover , false)
	end

	if props.modAerials ~= nil then
		SetVehicleMod(vehicle, 43, props.modAerials , false)
	end

	if props.modTrimB ~= nil then
		SetVehicleMod(vehicle, 44, props.modTrimB , false)
	end

	if props.modTank ~= nil then
		SetVehicleMod(vehicle, 45, props.modTank , false)
	end

	if props.modWindows ~= nil then
		SetVehicleMod(vehicle, 46, props.modWindows , false)
	end
	
	if props.modLiverys ~= nil then
		SetVehicleMod(vehicle, 48, props.modLiverys, false)
	end
	
	if props.modLivery ~= nil then
		SetVehicleLivery(vehicle, props.modLivery)
	end
	
	if props.CustomWheels ~= nil then
		if props.CustomWheels then
			SetVehicleMod(vehicle, 23, GetVehicleMod(vehicle, 23), not GetVehicleModVariation(vehicle, 23))
		end
	end

	if props.Burst ~= nil then SetVehicleTyresCanBurst(vehicle,props.Burst) end
end

CK.Game.DrawText3D = function(coords, text, size)
	coords = vector3(coords.x, coords.y, coords.z)

	local camCoords = GetGameplayCamCoords()
	local distance = #(coords - camCoords)

	if not size then size = 1 end
	
	local scale = (size / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	scale = scale * fov

	SetTextScale(0.0 * scale, 0.55 * scale)
	SetTextFont(0)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)

	SetDrawOrigin(coords, 0)
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(0.0, 0.0)
	ClearDrawOrigin()
end

AddEventHandler('CK:showNotification', function(msg, flash, saveToBrief, hudColorIndex)
	CK.ShowNotification(msg, flash, saveToBrief, hudColorIndex)
end)

AddEventHandler('CK:showAdvancedNotification', function(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
	CK.ShowAdvancedNotification(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
end)

AddEventHandler('CK:showHelpNotification', function(msg, thisFrame, beep, duration)
	CK.ShowHelpNotification(msg, thisFrame, beep, duration)
end)
