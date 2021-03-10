
-- 公开版 beta v0.1
function AcceptData(...)
	local args = {...}
	local event = args[1]
	table.remove(args, 1)

	return event, args
end

if IsDuplicityVersion() then -- 服务器
	function SendData(source, ...)
		TriggerClientEvent('CK:S2C_SendData', source, ...)
	end
else-- 客户端
	function SendData(...)
		TriggerServerEvent('CK:C2S_SendData', ...)
	end
end

