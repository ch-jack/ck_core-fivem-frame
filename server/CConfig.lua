CKConfig = {}
CKConfig.ServerId = 0
CKConfig.Debug = 0

if IsDuplicityVersion() then --服务器
	CKConfig.ServerId = GetConvarInt("ServeID", 0)
	SetConvarReplicated("ServeID", tostring(CKConfig.ServerId))
	
	CKConfig.Debug = GetConvarInt("Debug", 0)
	SetConvarReplicated("Debug", tostring(CKConfig.Debug))
else
	CKConfig.ServerId = GetConvarInt("ServeID", 0)
	CKConfig.Debug = GetConvarInt("Debug", 0)
end

---------------------------配置项---------------------------

CKConfig.ServerName = ""
CKConfig.SpawnPoint = {x = 159.543,y = -989.248, z = 30.0919, h = 100.0}
CKConfig.AutoRevive = false