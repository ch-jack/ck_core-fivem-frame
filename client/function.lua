CK.data = {}
CK.ClientKey = "ck_core_client_cfg"
CK.ClientCfg = {}

CK.CurrentRequestId = 0
CK.ServerCallbacks = {}

CK.SetObj = function(key, value)
	CK.data[key] = value
end

CK.GetObj = function(key)
	return CK.data[key]
end

CK.ClientCfg = json.decode(GetResourceKvpString(CK.ClientKey))

CK.SaveCfg = function(key,value)
	clientcfg[key] = value
	SetResourceKvp(CK.ClientKey,json.encode(clientcfg))
end

CK.GetCfg = function(key)
	return clientcfg[key] or 0
end

CK.CleanCfg = function()
	SetResourceKvp(CK.ClientKey,json.encode({}))
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
	CK.ServerCallbacks[requestId] = nil
end)

CK.ShowNotification = function(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName(msg)
	DrawNotification(false, true)
	PlaySoundFrontend(-1, "Click", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
	PlaySoundFrontend(-1, "TENNIS_MATCH_POINT", "HUD_AWARDS", 1)
end

AddEventHandler('CK:ShowNotification', function(msg)
	CK.ShowNotification(msg)
end)