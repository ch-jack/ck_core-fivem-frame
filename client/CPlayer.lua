CK.Player = nil

CK.NewPlayer = function()
	local self = {}
	
	self.SetObj = function(k, v)
		self[k] = v
	end

	self.GetObj = function(k)
		return self[k] or 0
	end

	self.PlayerId = PlayerId()
	self.PlayerPedId = PlayerPedId()
	self.ServerId = GetPlayerServerId(self.PlayerId)
	
	self.UpdatePedId = function()
		self.PlayerPedId = PlayerPedId()
	end

	self.PropertyChanged = function(data)
		for k,v in pairs(data) do
			self.SetObj(k, v)
		end
	end
	
	return self
end

CK.Player = CK.NewPlayer()