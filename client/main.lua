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
	
	RequestCollisionAtCoord(159.543, -989.248, 30.0919)
	SetEntityCoordsNoOffset(CK.Player.PlayerPedId, 159.543, -989.248, 30.0919, false, false, false, true)
	NetworkResurrectLocalPlayer(159.543, -989.248, 30.0919, 100.0, true, true, false)

	CK.Player.UpdatePedId()
	SetPedDefaultComponentVariation(CK.Player.PlayerPedId)
	-- while not HasCollisionLoadedAroundEntity(CK.Player.PlayerPedId) do-- 很慢待优化
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

AddEventHandler('CK:PropertyChanged', function(data)
	while CK.Player == nil do
		Wait(500)
	end
	CK.Player.PropertyChanged(data)
	TriggerEvent('CK:HasPlayerHasLoad')
	if not FirstLoad then FirstLoad = true end
end)
