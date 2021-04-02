CK.Players = {}

CK.PlayerProperty = {} -- 玩家所有属性
CK.PlayerOnlyServerData = {} -- 仅存在服务器属性
CK.PlayerAutoSaveData = {} -- 自动保存数据库属性

local _type <const> = type
local function type(v)
	if _type(v) == "table" then
		for k in pairs(v) do
			if k == "__cfx_functionReference" then
				return "function"
			end
		end
	end
	return _type(v)
end

CK.CPInitProperty = function(k, v, onlyServer, autoSave)
	if onlyServer == nil then onlyServer = 0 end
	if autoSave == nil then autoSave = 0 end
	CK.PlayerProperty[k] = v
	if type(v) == "function" then
		for _,CPlayer in pairs(CK.Players) do
			CPlayer.SetObj(k,v)
		end
	else
		if onlyServer == 1 then CK.PlayerOnlyServerData[k] = 1 end
		if autoSave == 1 then CK.PlayerAutoSaveData[k] = 1 end
		for _,CPlayer in pairs(CK.Players) do
			if not CPlayer.HasObj(k) then
				CPlayer.SetObj(k,v)
				if onlyServer == 0 then
					CPlayer.SomePropertyChanged(k)
				end
			end
		end
	end
end

CK.CPInitProperty("money", 0)-- 现金
CK.CPInitProperty("bank", 0)-- 银行
CK.CPInitProperty("name", "", 1)-- steam名
CK.CPInitProperty("identifier", "")-- steamid
CK.CPInitProperty("rolename", "")-- 角色名
CK.CPInitProperty("group", "user")-- 权限组
CK.CPInitProperty("onlinetime", {h=0,m=0})-- 在线时长
CK.CPInitProperty("plytempdata", {}, 1)-- 玩家临时数据

CK.NewPlayer = function(source)
	local self = {}
	local update = {}
	self.source = source
	self.LogOutNum = 0
	
	self.SetObj = function(k, v)
		if v == nil then
			print("^1Error CPlayer SetObj nil:"..k.."^0")
			return
		end
		if v ~= self[k] then
			self[k] = v
			if type(v) ~= "function" then
				if CK.PlayerOnlyServerData[k] == undef then
					update[k] = v
				end
			end
		end
	end

	self.GetObj = function(k)
		if self[k] == undef then
			print("^1Error CPlayer GetObj nil:"..k.."^0")
		end
		return self[k]
	end
	
	self.HasObj = function(k)
		if self[k] == undef then
			return false
		end
		return true
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
	
	self.SomePropertyChanged = function(...)
		local args = {...}
		local TempUpdate = {}
		local _send = false
		for _,key in pairs(args) do -- key
			if update[key] ~= undef then
				TempUpdate[key] = update[key]
				update[key] = undef
				_send = true
			end
		end
		if _send then
			SendData(self.source, "CK:PropertyChanged", TempUpdate)
		end
	end
	
	for k,v in pairs(CK.PlayerProperty) do
		self.SetObj(k,v)
	end
	
	self.SetTempData = function(key,value,day)
		if day == undef then day = 1 end
		if self.GetObj("plytempdata") == undef then return end
		if self.GetObj("plytempdata")[key] == undef then self.GetObj("plytempdata")[key] = {} end
		if self.GetObj("plytempdata")[key].time ~= undef then
			if NumberOfDaysInterval(os.time(),self.GetObj("plytempdata")[key].time) >= self.GetObj("plytempdata")[key].day then
				self.GetObj("plytempdata")[key] = undef
				self.GetObj("plytempdata")[key] = {value = value,day = day,time = os.time()}
			else
				if self.GetObj("plytempdata")[key].value ~= value then
					self.GetObj("plytempdata")[key] = {value = value,day = self.GetObj("plytempdata")[key].day,time = self.GetObj("plytempdata")[key].time}
				end
			end
		else
			self.GetObj("plytempdata")[key] = {value = value,day = day,time = os.time()}
		end
	end

	self.GetTempData = function(key,day)
		if self.GetObj("plytempdata") == undef then return 0 end
		if self.GetObj("plytempdata")[key] == undef then return 0 end
		if self.GetObj("plytempdata")[key].time ~= undef then
			if NumberOfDaysInterval(os.time(),self.GetObj("plytempdata")[key].time,day) >= self.GetObj("plytempdata")[key].day then
				self.GetObj("plytempdata")[key] = undef
				return 0
			end
		end
		return self.GetObj("plytempdata")[key].value or 0
	end

	self.ClearTempData = function(key)
		if self.GetObj("plytempdata") == undef then return end
		if self.GetObj("plytempdata")[key] ~= undef then
			self.GetObj("plytempdata")[key] = undef
		end
	end

	self.GetTempDataTime = function(key,day)
		if self.GetObj("plytempdata") == undef then return 0 end
		if self.GetObj("plytempdata")[key] == undef then return 0 end
		if self.GetObj("plytempdata")[key].time ~= undef then
			return NumberOfDaysInterval(os.time(),self.GetObj("plytempdata")[key].time,day)
		end
	end
	
	self.Save = function()
		local autoSaveData = {}
		for k in pairs(CK.PlayerAutoSaveData) do
			autoSaveData[k] = self.GetObj(k)
		end
		MySQL.Async.execute('UPDATE ck_core SET money = @money, bank = @bank, `group` = @group, onlinetime = @onlinetime, plydata = @plydata, plytempdata = @plytempdata WHERE identifier = @identifier', {
			['@money']   	 = self.GetObj("money"),
			['@bank']  		 = self.GetObj("bank"),
			['@group']    	 = self.GetObj("group"),
			['@onlinetime']  = self.GetObj("onlinetime"),
			['@plydata']   	 = autoSaveData,
			['@plytempdata'] = self.GetObj("plytempdata"),
			['@identifier']  = self.GetObj("identifier"),
		}, function(rowsChanged)
		end)
	end
	
	return self
end

CK.LoadPlayer = function(CPlayer, source, data)
	CPlayer.SetObj("name",string.gsub(GetPlayerName(source), "%^%d", ""))
	CPlayer.SetObj("identifier",GetPlayerIdentifiers(source)[1])
	if not data then return end
	if data.money then CPlayer.SetObj("money",data.money) end
	if data.bank then CPlayer.SetObj("bank",data.bank) end
	if data.group then CPlayer.SetObj("group",data.group) end
	if data.onlinetime then CPlayer.SetObj("onlinetime",data.onlinetime) end
	if data.rolename then CPlayer.SetObj("rolename",data.rolename) end
	if data.plytempdata then CPlayer.SetObj("plytempdata",data.plytempdata) end
	if data.plydata then
		for k,v in pairs(data.plydata) do
			CPlayer.SetObj(k,v)
		end
	end
end


