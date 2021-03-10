CK.Players = {}

CK.PlayerProperty = {}

CK.InitProperty = function(k,v)
	CK.PlayerProperty[k] = v
end

CK.InitProperty("money",0)-- 现金
CK.InitProperty("bank",0)-- 银行
CK.InitProperty("name","")-- steam名
CK.InitProperty("identifier","")-- steamid
CK.InitProperty("rolename","")-- 角色名
CK.InitProperty("group","user")-- 权限组
CK.InitProperty("onlinetime",{h=0,m=0})-- 在线时长
CK.InitProperty("plydata",{})-- 玩家数据

CK.NewPlayer = function(source)
	local self = {}
	local update = {}
	self.source = source
	self.LogOutNum = 0
	
	self.SetObj = function(k, v)
		if v ~= self[k] then
			self[k] = v
			if type(v) ~= "function" then
				update[k] = v
			end
		end
	end

	self.GetObj = function(k)
		return self[k]
	end
	
	self.SendData = function(...)
		SendData(self.source, ...)
	end
	
	self.PropertyChanged = function()
		if CK.GetTableNum(update) > 0 then
			SendData(self.source, "CK:PropertyChanged", update)
			update = {}
		end
	end
	
	for k,v in pairs(CK.PlayerProperty) do
		self.SetObj(k,v)
	end
	
	self.SetTempData = function(key,value,day)
		if day == nil then day = 1 end
		if not self.GetObj("plydata") then return end
		if not self.GetObj("plydata")[key] then self.GetObj("plydata")[key] = {} end
		if self.GetObj("plydata")[key].time ~= nil then
			if NumberOfDaysInterval(os.time(),self.GetObj("plydata")[key].time) >= self.GetObj("plydata")[key].day then
				self.GetObj("plydata")[key] = nil
				self.GetObj("plydata")[key] = {value = value,day = day,time = os.time()}
			else
				if self.GetObj("plydata")[key].value ~= value then
					self.GetObj("plydata")[key] = {value = value,day = self.GetObj("plydata")[key].day,time = self.GetObj("plydata")[key].time}
				end
			end
		else
			self.GetObj("plydata")[key] = {value = value,day = day,time = os.time()}
		end
	end

	self.GetTempData = function(key,day)
		if not self.GetObj("plydata") then return 0 end
		if not self.GetObj("plydata")[key] then return 0 end
		if self.GetObj("plydata")[key].time ~= nil then
			if NumberOfDaysInterval(os.time(),self.GetObj("plydata")[key].time,day) >= self.GetObj("plydata")[key].day then
				self.GetObj("plydata")[key] = nil
				return 0
			end
		end
		return self.GetObj("plydata")[key].value or 0
	end

	self.ClearTempData = function(key)
		if not self.GetObj("plydata") then return end
		if self.GetObj("plydata")[key] ~= nil then
			self.GetObj("plydata")[key] = nil
		end
	end

	self.GetTempDataTime = function(key,day)
		if not self.GetObj("plydata") then return 0 end
		if self.GetObj("plydata")[key] == nil then return 0 end
		if self.GetObj("plydata")[key].time ~= nil then
			return NumberOfDaysInterval(os.time(),self.GetObj("plydata")[key].time,day)
		end
	end
	
	self.Save = function()
		MySQL.Async.execute('UPDATE ck_core SET money = @money, bank = @bank, `group` = @group, onlinetime = @onlinetime, plydata = @plydata WHERE identifier = @identifier', {
			['@money']   	 = self.GetObj("money"),
			['@bank']  		 = self.GetObj("bank"),
			['@group']    	 = self.GetObj("group"),
			['@onlinetime']  = self.GetObj("onlinetime"),
			['@plydata']   	 = self.GetObj("plydata"),
			['@identifier']  = self.GetObj("identifier"),
		}, function(rowsChanged)
		end)
	end
	
	return self
end

CK.LoadPlayer = function(CPlayer, source, data)
	CPlayer.SetObj("name",GetPlayerName(source))
	CPlayer.SetObj("identifier",GetPlayerIdentifiers(source)[1])
	if data.money then CPlayer.SetObj("money",data.money) end
	if data.bank then CPlayer.SetObj("bank",data.bank) end
	if data.group then CPlayer.SetObj("group",data.group) end
	if data.onlinetime then CPlayer.SetObj("onlinetime",data.onlinetime) end
	if data.rolename then CPlayer.SetObj("rolename",data.rolename) end
	if data.plydata then CPlayer.SetObj("plydata",data.plydata) end
end


