CK.data = {}
CK.ServerCallbacks      = {}

CK.SetObj = function(key, value)
	CK.data[key] = value
end

CK.GetObj = function(key)
	if CK.data[key] == undef then
		print("Error, CK Get Null Obj:"..key)
	end
	return CK.data[key]
end

CK.RegisterServerCallback = function(name, cb)
	CK.ServerCallbacks[name] = cb
end

CK.TriggerServerCallback = function(CPlayer, name, requestId, cb, ...)
	if CK.ServerCallbacks[name] ~= nil then
		CK.ServerCallbacks[name](CPlayer, cb, ...)
	else
		print('ck_core: TriggerServerCallback => [' .. name .. '] 未注册')
	end
end

AddEventHandler('CK:triggerServerCallback', function(CPlayer, name, requestId, ...)
	CK.TriggerServerCallback(CPlayer, name, requestID, function(...)
		CPlayer.SendData('CK:serverCallback', requestId, ...)
	end, ...)
end)

CK.GetPlayers = function()
	local sources = {}

	for k,v in pairs(CK.Players) do
		table.insert(sources, k)
	end

	return sources
end

CK.GetPlayerFromId = function(source)
	return CK.Players[tonumber(source)]
end

CK.GetPlayerFromIdentifier = function(identifier)
	for k,v in pairs(CK.Players) do
		if v.identifier == identifier then
			return v
		end
	end
end

CK.Save = function()
	if CK.SaveDaily then
		CK.SaveServerSql()
		CK.SaveDaily = false
	end
	local OnlinePlayers = GetPlayers()
	for k,v in pairs(CK.Players) do -- k=source v=CPlayer
		local NotOnline = true
		for _,OP in pairs(OnlinePlayers) do -- OP=source
			if k == OP then
				v.Save()
				TriggerEvent('CK:SavePlayer', v)
				NotOnline = false
				break
			end
		end
		if NotOnline then
			v.LogOutNum = v.LogOutNum + 1
			if v.LogOutNum > 3 then
				CK.Players[k] = undef
			end
		end
	end
end

CK.CPlayerOnlineTime = function()
	local OnlinePlayers = GetPlayers()
	for k,v in pairs(CK.Players) do -- k=source v=CPlayer
		for _,OP in pairs(OnlinePlayers) do -- OP=source
			if tonumber(k) ==  tonumber(OP) then
				local OlTime = v.GetObj("onlinetime")
				OlTime.m = OlTime.m + 1
				if OlTime.m == 60 then
					OlTime.m = 0
					OlTime.h = OlTime.h + 1
				end
				v.SetObj("onlinetime", OlTime)
				break
			end
		end
	end
end

CK.GetTableNum = function(T)
	local Num = 0
	for _ in pairs(T) do
		Num = Num + 1
	end
	return Num
end

CK.Guid = function()
    local seed={'0','1','2','3','4','5','6','7','8','9'}
    local tb={}
    for i=1,32 do
        table.insert(tb,seed[math.random(1,#seed)])
    end
    local sid=table.concat(tb)
	local uid = string.format('%s%s',os.time(),string.sub(sid,9,16))
	if #uid > 16 then
		uid = string.sub(uid,1,16) 
	end
    return uid
end
