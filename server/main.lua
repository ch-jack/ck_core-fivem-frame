
RegisterServerEvent('CK:ClientLogin')
AddEventHandler('CK:ClientLogin', function()
	local source = source
	local identifier = GetPlayerIdentifiers(source)[1]
	local CPlayer = CK.GetPlayerFromIdentifier(identifier)
	if CPlayer then
		table.remove(CK.Players, CPlayer.source)
		CK.Players[source] = CPlayer
		CPlayer.source = source
		CPlayer.SetObj("name",GetPlayerName(source))
		CPlayer.SendData("CK:PlayerLoad")
		CPlayer.PropertyChanged()
		CPlayer.LogOutNum = 0
		TriggerEvent('CK:HasPlayerLoad', CPlayer)
	else
		MySQL.Async.fetchAll('SELECT rolename,money,bank,`group`,onlinetime FROM ck_core WHERE identifier = @identifier', {
			['@identifier'] = identifier
		}, function(data)
			data = tabelstringtotable(data)
			CPlayer = CK.NewPlayer(source)
			if #data == 1 then
				CK.LoadPlayer(CPlayer, source, data)
			else
				CK.LoadPlayer(CPlayer, source, {rolename = GetRandomName()})
				MySQL.Async.execute('INSERT INTO ck_core(`identifier`, `name`, `rolename`, `ip`, `createtime`, `logintime`) VALUES (@identifier, @name, @rolename, @ip, NOW(), NOW());', {identifier = CPlayer.identifier, name = CPlayer.name, rolename = CPlayer.rolename, ip = GetPlayerEP(source)}, function(e)	end)
			end
			CK.Players[source] = CPlayer
			CPlayer.SendData("CK:PlayerLoad")
			CPlayer.PropertyChanged()
			TriggerEvent('CK:HasPlayerLoad', CPlayer)
		end)
	end
end)

Citizen.CreateThread(function()
	while MySQL == nil do
		Citizen.Wait(500)
	end

	MySQL.Async.fetchScalar("SELECT id FROM ck_server WHERE id = @id", { ['@id'] = CKConfig.ServerId}, function (data)
		if data == CKConfig.ServerId then
			CK.LoadServerDate()
		else
			MySQL.Async.execute('INSERT INTO ck_server(id) VALUES (@id)', {
				['@id'] = CKConfig.ServerId,
			}, function()
			end)
		end
	end)
end)

AddEventHandler('EveryTenMinutes', function()
	CK.Save()
end)

AddEventHandler("playerDropped", function(reason)
	local source = source
	local CPlayer = CK.GetPlayerFromId(source)
	if CPlayer then
		CPlayer.Save()
	end
end)

AddEventHandler('ServerStop', function()
	CK.SaveServerSql()
	Citizen.CreateThread(function()
		Wait(2500)
		print("^2"..GetCurrentResourceName().." Is Save Can Stop!")
	end)
end)
	