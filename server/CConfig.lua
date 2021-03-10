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
