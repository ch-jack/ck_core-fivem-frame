local Keys <const> = {
	"F4","F5","F6","F7","F9","F10",
}

Citizen.CreateThread(function()
	for _,v in pairs(Keys) do
		RegisterKeyMapping('CK:Key'..v, v, 'keyboard', v)

		RegisterCommand('CK:Key'..v, function()
			TriggerEvent('CK:Key'..v)
		end, false)
	end
end)