local FirstName = {"test"}
local LastName = {"test"}

function GetRandomName()
	return FirstName[math.random(#FirstName)] .. LastName[math.random(#LastName)]
end