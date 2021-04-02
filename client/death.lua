AddEventHandler("gameEventTriggered", function(name, args)
	if name == "CEventNetworkEntityDamage" then
		local playerPed = args[1]
		if playerPed == PlayerPedId() then
			local player = CK.Player.PlayerId
			if NetworkIsPlayerActive(player) then
				if IsPedFatallyInjured(playerPed) then
				
					SetNuiFocus(false)
					SetNuiFocus(false, false)
			
					local killer, killerWeapon = NetworkGetEntityKillerOfPlayer(player)
					local killerServerId = NetworkGetPlayerIndexFromPed(killer)
			
					if killer ~= playerPed and killerServerId ~= nil and NetworkIsPlayerActive(killerServerId) then
						PlayerKilledByPlayer(GetPlayerServerId(killerServerId), killerServerId, killerWeapon)
					else
						PlayerKilled()
					end
					
					if CKConfig.AutoRevive then
						SetEntityCoordsNoOffset(playerPed, CKConfig.SpawnPoint.x, CKConfig.SpawnPoint.y, CKConfig.SpawnPoint.y, false, false, false, true)
						NetworkResurrectLocalPlayer(CKConfig.SpawnPoint.x, CKConfig.SpawnPoint.y, CKConfig.SpawnPoint.y, CKConfig.SpawnPoint.x, CKConfig.SpawnPoint.y, CKConfig.SpawnPoint.h, true, false)
						SetPlayerInvincible(playerPed, false)
						ClearPedBloodDamage(playerPed)
					end
					
				end
			end
		end
	end
end)

function PlayerKilledByPlayer(killerServerId, killerClientId, killerWeapon)
	local victimCoords = GetEntityCoords(PlayerPedId())
	local killerCoords = GetEntityCoords(GetPlayerPed(killerClientId))
	local distance     = GetDistanceBetweenCoords(victimCoords, killerCoords, true)

	local data = {
		victimCoords = { x = victimCoords.x, y = victimCoords.y, z = victimCoords.z },
		killerCoords = { x = killerCoords.x, y = killerCoords.y, z = killerCoords.z },

		killedByPlayer = true,
		deathCause     = killerWeapon,
		distance       = distance,

		killerServerId = killerServerId,
		killerClientId = killerClientId
	}

	TriggerEvent('CK:PlyerDeath', data)
	CK.SendData("CK:PlyerDeath", data)
end

function PlayerKilled()
	local playerPed = PlayerPedId()
	local victimCoords = GetEntityCoords(playerPed)

	local data = {
		victimCoords = { x = victimCoords.x, y = victimCoords.y, z = victimCoords.z },

		killedByPlayer = false,
		deathCause     = GetPedCauseOfDeath(playerPed)
	}

	TriggerEvent('CK:PlyerDeath', data)
	CK.SendData("CK:PlyerDeath", data)
end