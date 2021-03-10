
RegisterServerEvent('CK:C2S_SendData')
AddEventHandler('CK:C2S_SendData', function(...)
	local source = source
	if CK.GetPlayerFromId(source) == nil then return end
	local event, CPacketParser = AcceptData(...)
	TriggerEvent(event, CK.GetPlayerFromId(source), table.unpack(CPacketParser))
end)

CK.NotifyData = function(...)
	SendData(-1, ...)
end
