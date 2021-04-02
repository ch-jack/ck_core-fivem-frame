local PropertyFuncCallBack = {}
local FirstLoad = false

local function freezePlayer(id, freeze)
    local player = id
    SetPlayerControl(player, not freeze, false)

    local ped = GetPlayerPed(player)
    if not freeze then
        SetEntityVisible(ped, true)

        if not IsPedInAnyVehicle(ped) then
            SetEntityCollision(ped, true)
        end

        FreezeEntityPosition(ped, false)
        --SetCharNeverTargetted(ped, false)
        SetPlayerInvincible(player, false)
    else
        SetEntityVisible(ped, false)

        SetEntityCollision(ped, false)
        FreezeEntityPosition(ped, true)
        --SetCharNeverTargetted(ped, true)
        SetPlayerInvincible(player, true)
        --RemovePtfxFromPed(ped)

        if not IsPedFatallyInjured(ped) then
            ClearPedTasksImmediately(ped)
        end
    end
end

Citizen.CreateThread(function()
	Citizen.Wait(1500)
	while true do
		Citizen.Wait(500)
		if NetworkIsSessionStarted() then
			TriggerServerEvent('CK:ClientLogin')
			return
		end
	end
end)

AddEventHandler('CK:PlayerLoad', function()
	local model = `mp_m_freemode_01`
	RequestModel(model)
	while not HasModelLoaded(model) do
		RequestModel(model)
		Wait(50)
	end

	freezePlayer(CK.Player.PlayerId,true)
	SetPlayerModel(CK.Player.PlayerId, model)
	SetModelAsNoLongerNeeded(model)
	
	RequestCollisionAtCoord(CKConfig.SpawnPoint.x, CKConfig.SpawnPoint.y, CKConfig.SpawnPoint.y)
	SetEntityCoordsNoOffset(PlayerPedId(), CKConfig.SpawnPoint.x, CKConfig.SpawnPoint.y, CKConfig.SpawnPoint.y, false, false, false, true)
	NetworkResurrectLocalPlayer(CKConfig.SpawnPoint.x, CKConfig.SpawnPoint.y, CKConfig.SpawnPoint.y, CKConfig.SpawnPoint.x, CKConfig.SpawnPoint.y, CKConfig.SpawnPoint.h, true, true, false)

	SetPedDefaultComponentVariation(PlayerPedId())
	-- while not HasCollisionLoadedAroundEntity(PlayerPedId()) do-- 很慢待优化
		-- Citizen.Wait(50)
	-- end

	ShutdownLoadingScreen()
	DoScreenFadeIn(500)
	while IsScreenFadingIn() do
		Citizen.Wait(50)
	end

	freezePlayer(CK.Player.PlayerId,false)
	ShutdownLoadingScreenNui()
	Wait(500)
	while not FirstLoad do
		Wait(50)
	end

	TriggerEvent('CK:HasPlayerLoad')
end)

AddEventHandler('CK:RegisterPropChange', function(key, func)
	PropertyFuncCallBack[key] = func
end)

AddEventHandler('CK:PropertyChanged', function(data)
	while CK.Player == nil do
		Wait(500)
	end
	CK.Player.PropertyChanged(data)
	for k in pairs(data) do
		if PropertyFuncCallBack[k] ~= undef then
			PropertyFuncCallBack[k]()
		end
	end
	if not FirstLoad then FirstLoad = true end
end)


