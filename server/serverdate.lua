
CK.ServerDate = {}
CK.SaveDaily = false

CK.SetServerDate = function(key,value,day)
	if day == undef then day = 1 end
	if CK.ServerDate[key] == undef then CK.ServerDate[key] = {} end
	if CK.ServerDate[key].time ~= undef then
		if NumberOfDaysInterval(os.time(),CK.ServerDate[key].time) >= CK.ServerDate[key].day then
			CK.ServerDate[key] = undef
			CK.ServerDate[key] = {value = value,day = day,time = os.time()}
			SaveDaily = true
			return false
		else
			if CK.ServerDate[key].value ~= value then
				CK.ServerDate[key] = {value = value,day = CK.ServerDate[key].day,time = CK.ServerDate[key].time}
				SaveDaily = true
				return true
			end
		end
	else
		CK.ServerDate[key] = {value = value,day = day,time = os.time()}
		SaveDaily = true
		return true
	end
	return false
end

CK.GetServerDate = function(key)
	if CK.ServerDate[key] == undef then 
		return 0
	else
		if NumberOfDaysInterval(os.time(),CK.ServerDate[key].time) >= CK.ServerDate[key].day then
			CK.ServerDate[key] = undef
			SaveDaily = true
			return 0
		end
		return CK.ServerDate[key].value or 0
	end
end

CK.ClearServerDate = function()
	for k,v in pairs(CK.ServerDate) do
		if NumberOfDaysInterval(os.time(),v.time) >= v.day then
			CK.ServerDate[k] = nil
			SaveDaily = true
		end
	end
end

CK.SaveServerSql = function()
	MySQL.Async.execute('UPDATE ck_server SET ServerDate = @ServerDate WHERE id = @id', {
		['@id'] = CKConfig.ServerId,
		['@ServerDate'] = CK.ServerDate
		}, function(rowsChanged)
		if rowsChanged == 1 then end
	end)
end

CK.LoadServerDate = function()
	SetTimeout(5000, function()
		MySQL.Async.fetchScalar("SELECT ServerDate FROM ck_server WHERE id = @id", { ['@id'] = CKConfig.ServerId}, function (unite)
			if unite then CK.ServerDate = json.decode(unite) or {} end
			CK.ClearServerDate()
		end)
	end)
end
