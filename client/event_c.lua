
RegisterNetEvent('CK:S2C_SendData')
AddEventHandler('CK:S2C_SendData', function(...)
	local event, CPacketParser = AcceptData(...)
	TriggerEvent(event, table.unpack(CPacketParser))
end)

CK.SendData = function(...)
	SendData(...)
end