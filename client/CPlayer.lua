CK.Player = nil

CK.NewPlayer = function()
	local self = {}
	
	self.SetObj = function(k, v)
		self[k] = v
	end

	self.GetObj = function(k)
		if self[k] == undef then
			print("^1Error CPlayer Get Null Obj:"..k.."^0")
		end
		return self[k]
	end
	
	self.PlayerId = PlayerId()
	self.Name = GetPlayerName(self.PlayerId)
	self.ServerId = GetPlayerServerId(self.PlayerId)

	self.PropertyChanged = function(data)
		for k,v in pairs(data) do
			self.SetObj(k, v)
		end
	end
	
	return self
end

CK.Player = CK.NewPlayer()