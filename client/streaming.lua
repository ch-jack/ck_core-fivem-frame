CK.Streaming = {}

local function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x , y)
end

function CK.Streaming.RequestModel(modelHash, cb)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		while not HasModelLoaded(modelHash) do
			drawTxt("~b~模型加载中,请稍后",0,1,0.5,0.5,0.25,255,255,255,255)
			Citizen.Wait(5)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function CK.Streaming.RequestStreamedTextureDict(textureDict, cb)
	if not HasStreamedTextureDictLoaded(textureDict) then
		RequestStreamedTextureDict(textureDict)

		while not HasStreamedTextureDictLoaded(textureDict) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function CK.Streaming.RequestPtfxAsset(assetName, cb)
	if not HasPtfxAssetLoaded(assetName) then
		RequestPtfxAsset(assetName)

		while not HasPtfxAssetLoaded(assetName) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function CK.Streaming.RequestNamedPtfxAsset(assetName, cb)
	if not HasNamedPtfxAssetLoaded(assetName) then
		RequestNamedPtfxAsset(assetName)

		while not HasNamedPtfxAssetLoaded(assetName) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function CK.Streaming.RequestAnimSet(animSet, cb)
	if not HasAnimSetLoaded(animSet) then
		RequestAnimSet(animSet)

		while not HasAnimSetLoaded(animSet) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function CK.Streaming.RequestAnimDict(animDict, cb)
	if not HasAnimDictLoaded(animDict) then
		RequestAnimDict(animDict)

		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function CK.Streaming.RequestWeaponAsset(weaponHash, cb)
	if not HasWeaponAssetLoaded(weaponHash) then
		RequestWeaponAsset(weaponHash)

		while not HasWeaponAssetLoaded(weaponHash) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function CK.Streaming.RequestClipSet(clipSet, cb)
	if not HasClipSetLoaded(clipSet) then
		RequestClipSet(clipSet)

		while not HasClipSetLoaded(clipSet) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end