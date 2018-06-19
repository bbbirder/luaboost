--author:bbbirder

--table
 --i:表示适用于iv
 --k:表示适用于kv
 --a:表示适用于iv、kv
 	function table.exists(t,tar)
 		for k,v in pairs(t) do
 			if tar==v then return true end
 		end
 	end
 	function table.maxn(t)
        if type(t)~="table" then return 0 end
 		local n = 0
 		for k,v in pairs(t) do
 			n = n+1
 		end
 		return n
 	end
 	function table.keys(t)
 		local ret = {}
 		for k,v in pairs(t) do
 			table.insert(ret,k)
 		end
 		table.sort(ret)
 		return ret
 	end
 	function table.vals(t)
 		local ret = {}
 		for k,v in pairs(t) do
 			table.insert(ret,v)
 		end
 		table.sort(ret)
 		return ret
 	end
 	function table.merge(dst,src)
 		for k,v in pairs(src) do
 			dst[k] = v
 		end
 	end
	--a:设置值
	function table.newindex(t,k,v)
		t[k] = v
	end

    function table.index(t,k,default)
        return t[k] or default
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

	function table.group(self,func)
		local t = {}
		for _,v in pairs(self) do
			local k = func(v,_)
			t[k] = t[k] or {}
			table.insert(t[k],v)
		end
		return t
	end

	function table.newSheet(headers)
		local function newRow(rows)
			local ret = {}
			for _,row in ipairs(rows) do
				local _ret = {}
				for i,v in ipairs(headers) do
					_ret[v] = row[i]
				end
				table.insert(ret,_ret)
			end
			return ret
		end
		return newRow
	end

	function table.each2(t,func)
        if #t<2 then return false end 
		for i=1,#t-1 do
			if not func(t[i],t[i+1]) then
				return false
			end
		end
		return true
	end

	function table.map(t, fn)
		local ret = {}
	    for k, v in pairs(t) do
	        ret[k] = fn(v, k)
	    end
	    return ret
	end

	function table.walk(t, fn)
	    for k,v in pairs(t) do
	        fn(v, k)
	    end
	    return t
	end

    function table.filter(t, fn)
        local ret = {}
        for k, v in ipairs(t) do
            if fn(v, k) then table.insert(ret,v) end
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
	--like python [2:] [3:] [2,-2]
	--like javasript String.slice
	--but it starts from 1(-1) at two sides
	function string.slice(s,f,t)
		f = f or 0
		t = t or #s
		if f<0 then f = #s+f+1 end
		if t<0 then t = #s+t+1 end
		return s:sub(f,t)
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

	function string.endWith(str,s)
		if #s>#str then return false end
		return str:sub(#str-~-#s)==s
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


	function string.toChinese(n)
		local n = tostring(n)
		assert(not n:match("e"),"out value")
		local sint= n:gsub("%..*","")
		local len = #sint
		assert(len<=8,"number too big")
		local units = {
			"s","b","q","w",
		}
		for i=len-1,1,-1 do
			sint = sint:slice(1,i)..(units[(len-i-1)%4+1] or "?")..sint:slice(i+1)
		end
		return (
			(
				sint:gsub("0%w","0")
					:gsub("0+","0")
					:gsub("01s","0s")
					:gsub("^1s","s")
					:gsub("%-b1s","-bs")
					:gsub("(%d%w%dw)0$","%1")
					:gsub("(%d%w%d)%w0$","%1")
					:gsub("(.)0$","%1")
				..(n:match("%.%d+") or "")
			)
			:gsub("%d",{
				["0"] = "零",
				["1"] = "一",
				["2"] = "二",
				["3"] = "三",
				["4"] = "四",
				["5"] = "五",
				["6"] = "六",
				["7"] = "七",
				["8"] = "八",
				["9"] = "九",
			})
			:gsub("%-%w","负")
			:gsub("%w",{
				["s"] = "十",
				["b"] = "百",
				["q"] = "千",
				["w"] = "万",
			})
			:gsub("%.","点")
		)
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

	-- return: -1,0,1
	function math.sgn(v)
		v = v // 1 | 0
		return (-v>>63)-(v>>63)
	end

	--t:from 0. to 1.
	function math.Lerp(a,b,t)
		return a + (b-a)*t
	end

	--fast log2, arg should equals (0x1p?)，最低位1的位数
	local _euler_map = { [0] = 
		0x00,	0x01,	0x30,	0x02,	0x39,	0x31,	0x1c,	0x03,	
		0x3d,	0x3a,	0x32,	0x2a,	0x26,	0x1d,	0x11,	0x04,	
		0x3e,	0x37,	0x3b,	0x24,	0x35,	0x33,	0x2b,	0x16,	
		0x2d,	0x27,	0x21,	0x1e,	0x18,	0x12,	0x0c,	0x05,	
		0x3f,	0x2f,	0x38,	0x1b,	0x3c,	0x29,	0x25,	0x10,	
		0x36,	0x23,	0x34,	0x15,	0x2c,	0x20,	0x17,	0x0b,	
		0x2e,	0x1a,	0x28,	0x0f,	0x22,	0x14,	0x1f,	0x0a,	
		0x19,	0x0e,	0x13,	0x09,	0x0d,	0x08,	0x07,	0x06,	
	}
	function math.log2(n)--n = 0x1p?
		return _euler_map[0x03f79d71b4cb0a89*(n&-n) >> 58] --0~63
	end

	--fast log2,arg should equals (0x1p?)，最高位1的位数，结果为整数，可以作为牛顿迭代法的估计值
	-- 最快的方法只能在有指针的语言下实现，对应C代码：
	--[[
		//int_num is in float type, but should be an integer.
		inline int h_log2(float int_num) {
			return (*(__int32*)&int_num) + 0x800000 << 2 >> 25;
		}
		//eg:printf("%d\n",h_log2(45687)); printf("%d\n",1<<h_log2(4687));
	]]
	-- 
	-- 为避免编译器不同实现，使用汇编指令:(x86 only)
	--[[
		int __stdcall h_log2(float int_num) {
			__asm {
				mov eax, int_num
				lea eax,[eax*4+0x2000000]
				shr eax,25
			}
		}
	]]
	-- 使用swig导出后可以在lua中使用.
	-- 替代方案：
	function math.highest1(n)
		n = n | n>>1
		n = n | n>>2
		n = n | n>>4
		n = n | n>>8
		n = n | n>>16
		n = n | n>>32
		n = n>>1
		return n+1
	end
	function math.h_log2(n)
		n = math.highest1(n)
		return _euler_map[0x03f79d71b4cb0a89*n >> 58]
	end
	-- print(math.h_log2(6564))
	
	function math.cnt1(bits)
		local cnt = 0
		while bits~=0 do
			bits = bits & ~-bits
			cnt = cnt + 1
		end
		return cnt
	end
	function math.each1bit(bits)
		return function()
			local b = bits&-bits
			bits = bits&~-bits
			if b~=0 then return b end
		end
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

	--return days count in a month
	function daysOf(m,y)
		y = y or 1990
		return m==2 
		and	--Feb
			29 - (
				-(y%4)>>63 ~
				-(y%100)>>63 ~
				-(y%400)>>63
			)
		or	--Not Feb
			30+(m%2 ~ m>>3)
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

