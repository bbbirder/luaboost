--author:bbbirder

--table
 --i:表示适用于iv
 --k:表示适用于kv
 --a:表示适用于iv、kv
 	function table.merge(dst,src)
 		for k,v in pairs(src) do
 			dst[k] = v
 		end
 	end
	--a:设置值
	function table.set(t,k,v)
		t[k] = v
	end

	--i:把一条v值替换为其他多条v值，常用于数据转换
	--@param idx 目标索引
	--@param t2 源iv表
	function table.replace(t,idx,t2)
		table.remove(t,idx)
		for i,v in ipairs(t2) do
			table.insert(t,idx+i-1,v)
		end
	end

	--双向索引
	function table.bidir(vt)
		local tmp = {}-- dont read while write!!!
		for k,v in pairs(vt) do
			tmp[v] = k
		end
		for k,v in pairs(tmp) do
			vt[k] = v
		end
		return vt
	end

	function table.es6table(vt)
		local t = {}
		for k,v in pairs(vt) do
			print(k,v)
			t[v] = v
		end
		return t
	end
	--a:深层检索table
	--@param table 被检索表
	--@param ... k名序列，如：table.path(avatar,"avatar","equipments","weapon")
	function table.path(table,...)
		local args = {...}
		local obj = table
		for i,v in ipairs(args) do
			obj = obj[v]
			if not obj then return obj end
		end
		return obj
	end

	--i:截取table
	function table.subArray(t,start,len)
		local rt = {}
		for i=start,start+len-1 do
			rt[i-start+1] = t[i]
		end
		return rt
	end

	--a:获取第一个符合条件的v值
	function table.get(t,func)
		for k,v in pairs(t) do
			if func(v,k) then
				return v
			end
		end
	end

	--a:获取所有符合条件的v值
	function table.getall(t,func)
		local rt = {}
		for k,v in pairs(t) do
			if func(v,k) then
				rt[#rt+1] = v
			end
		end
		return rt
	end

	--i:追加多条v值，区别于insert
	function table.pushback(t,subt)
		for i,v in ipairs(subt) do
			t[#t+1] = v
		end
	end

	--kv表 去k 变为iv表
	function table.toArray(t)
		local index = 1
		local ret = {}
		for k,v in pairs(t) do
			ret[index] = v
			index = index + 1
		end
		return ret
	end

	function table.group(func)
		local t = {}
		for _,v in pairs(self) do
			local k = func(v,_)
			t[k] = t[k] or {}
			table.insert(t[k],v)
		end
		return t
	end

	function table.newSheet(headers)
		local function newRow(row)
			local ret = {}
			for i,v in pairs(headers) do
				ret[v] = row[i]
			end
			return ret
		end
		return newRow
	end

	function table.each2(t,func)
		local ret = {}
		for i=1,#t-1 do
			ret[i] = func(t[i],t[i+1])
		end
		return ret
	end

	function table.map(t, fn)
	    for k, v in pairs(t) do
	        t[k] = fn(v, k)
	    end
	    return t
	end

	function table.walk(t, fn)
	    for k,v in pairs(t) do
	        fn(v, k)
	    end
	    return t
	end

	function table.filter(t, fn)
		local ret = {}
	    for k, v in pairs(t) do
	        if fn(v, k) then ret[k] = v end
	    end
	    return ret
	end

--string
	string.split = string.split or function(inputstr, sep)
	        if sep == nil then
	                sep = "%s"
	        end
	        local t={} ; i=1
	        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
	                t[i] = str
	                i = i + 1
	        end
	        return t
	end
	function string.trim(str)
		if not str then return "" end
	    str = string.gsub(str, "^[ \t\n\r]+", "")
	    return string.gsub(str, "[ \t\n\r]+$", "")
	end

	function string.isMatch(str,rule)
		local i,j,s = string.find(str,rule)
		if s == str then
			return true
		end
		return false
	end

	--ignore this
		---------------------------------------
		function string.encode(s)
			_s,_ = string.gsub(s,":","&|")
			return _s
		end

		function string.decode(s)
			_s,_ = string.gsub(s,"&|",":")
			return _s
		end
		---------------------------------------

	function string.time(s)
		local _v = tonumber(s) or 0
		local _s = math.floor(s%60)
		local _m = math.floor((s/60)%60)
		local _h = math.floor((s/3600)%60)
		return string.format("%02d:%02d:%02d",_h,_m,_s)
	end

	function string.number(n)
		return n/1e3<100 and n
			or n/1e6<100 and math.floor(n/1e3) .. "k"
			or n/1e9<100 and math.floor(n/1e6) .. "m"
			or math.floor(n/1e9) .. "b"
	end

	function string.tocolor(s)
		local r = tonumber("0x"..string.sub(s,1,2)) or 0
		local g = tonumber("0x"..string.sub(s,3,4)) or 0
		local b = tonumber("0x"..string.sub(s,5,6)) or 0
		local a = tonumber("0x"..string.sub(s,7,8))
		return a and cc.c4b(r,g,b,a) or cc.c3b(r,g,b)
	end

--math
	--statistics
	function math.sum(t,f)
		local sum = 0
		for k,v in pairs(t) do
			sum = sum + (f and f(v) or v)
		end
		return sum
	end

	-- function math.minus(t)

	function math.xor(a,b)
		return not not a == not b
	end

	--io image:
	--       _____
	--  ____/
	function math.clamp(v,min,max)
		return math.min(max,math.max(v,min))
	end

	--io image:
	--   / / /
	--  / / /
	function math.cycle(v,min,max)
		return min + (v - min) % (max - min)
	end

	function math.sgn(v)
		if v > 0 then
			return 1
		elseif v < 0 then
			return -1
		end
		return 0
	end

	--t:from 0. to 1.
	function math.Lerp(a,b,t)
		return a + (b-a)*t
	end

--useless
	function filterEmoji(username)
	    local usernameRight = ""
	    local len = #username
	    local iLoop=1
	    local jLoop=1
	    local acrossEmoji = false
	    while true do
	        local first = string.format("%02X", string.byte(string.sub(username,iLoop,iLoop)))

	        local curbyte = string.byte(username, iLoop)
	        local byteCnt = 1
	        if curbyte>0 and curbyte<=127 then
	            byteCnt = 1
	        elseif curbyte>=192 and curbyte<223 then
	            byteCnt = 2
	        elseif curbyte>=224 and curbyte<239 then
	            byteCnt = 3
	        elseif curbyte>=240 and curbyte<=247 then
	            byteCnt = 4
	        end

	        if byteCnt ~= 4 then
	            usernameRight = usernameRight..string.sub(username,iLoop,iLoop+byteCnt-1)
	        end
	        iLoop = iLoop+byteCnt

	        if iLoop>len then break end
	    end

	    return usernameRight
	end

	function clsname(obj)
	    local t = type(obj)
	    local mt = nil
	    if t == "table" then
	        mt = getmetatable(obj)
	    elseif t == "userdata" then
	        mt = tolua.getpeer(obj)
	    else
	    	return t
	    end

		return mt.__cname
	end

	function randomString()
	    local str = ""
	    for i = 1,10,1 do
	        str = str .. string.char(math.random(65,90))
	    end
	    return str
	end

	--return days in a month
	function daysOf(m,y)
		return m==2 
		and	y and (y%400==0~=(y%100==0)~=(y%4==0) and 29 or 28)
		or	m%2 == 1 == (m<8) and 31 or 30
	end
	
	-- _runOnceTable = {}
	-- function runOnce__( func,... )
	-- 	local key = tostring(func)
	-- 	if _runOnceTable[key] == nil then
	-- 		_runOnceTable[key] = true
	-- 		func(...)
	-- 	end
	-- end

	-- function clearRunTimes( func )
	-- 	local key = tostring(func)
	-- 	_runOnceTable[key] = nil
	-- end

