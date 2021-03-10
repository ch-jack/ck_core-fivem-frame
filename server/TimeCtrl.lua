
local day = os.date("%Y-%m-%d")

function EveryHour()
	SetTimeout(60000*(tonumber(62-(os.date("%M")))), function()
		print("EveryHour : "..os.date("%Y-%m-%d %H:%M:%S"))
		TriggerEvent("EveryHour", tonumber(os.date("%H")))
		local now = os.date("%Y-%m-%d")
		if day ~= now then 
			day = now 
			TriggerEvent("NewDay", tonumber(os.date("%d")))
		end
		EveryHour()
	end)
end

EveryHour()

function EveryTenMinutes()
	SetTimeout(1000*60*10, function()
		TriggerEvent("EveryTenMinutes")
		EveryTenMinutes()
	end)
end

EveryTenMinutes()

function EveryMinutes()
	SetTimeout(1000*60, function()
		TriggerEvent("EveryMinutes")
		EveryMinutes()
	end)
end

EveryMinutes()

AddEventHandler('NewDay', function()
	local weekdouble = tonumber(os.date("%w",os.time()))
	-- if weekdouble == 6 or weekdouble == 0 then
	-- 	TriggerClientEvent('setweek',-1,1)
	-- else
	-- 	TriggerClientEvent('setweek',-1,0)
	-- end
end)

function GetDayKeyByUnixTime(unixTime,hour,minu)
    if hour == nil then hour = 0 end
    local retStr = os.date("%Y-%m-%d %H:%M:%S",unixTime)
    local time = unixTime
    local data = os.date("*t",time)
    --dump(data)
    --(hour)4点前按前一天算
    if data.hour < hour then
        time = time - 24*60*60        
    end
    local data2 = os.date("*t",time)
    --dump(data2)
	if minu == nil then
		data2.hour = 0
		data2.min = 0
		data2.sec = 0
	end
    local time2 = os.time(data2)
    local dayKey = os.date("%Y%m%d",time2)
    local timeBase = time2
    --天数key，日期格式字符串，天数key 0点的时间戳
    return dayKey,retStr,timeBase
end

function NumberOfDaysInterval(unixTime1,unixTime2,minu,dayFlagHour)
    local key1,str1,time1 = GetDayKeyByUnixTime(unixTime1,dayFlagHour,minu)
    local key2,str2,time2 = GetDayKeyByUnixTime(unixTime2,dayFlagHour,minu)
    local sub = math.abs(time2 - time1)/(24*60*60)
    return sub
end

