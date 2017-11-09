--coding...
metatable = metatable or {}
local bind = functional.bind
local function accessIndex(t,k)
	local ret = nil
	local mt = getmetatable(t)
	-- print("indexing",k)
	-- dump(mt)
	mt.__index_list = mt.__index_list or {}
	for _,v in pairs(mt.__index_list) do
		local typ = type(v)
		if typ=="table" then
			ret = v[k]
		elseif typ=="function" then
			ret = v(t,k)
		end
		-- print("--indexing",k,tmp)
		if ret~=nil then break end
	end
	return ret
end

local function accessNewIndex(t,k,v)
	local mt = getmetatable(t)
	for _k,_v in pairs(mt.__newindex_list) do
		_v(t,k,v)
	end
end

--多层成员查找
function metatable.push_index(t,k,f)
	if type(t)=="userdata" then
		local peer = tolua.getpeer(t)
		if not peer then
			peer = {}
			tolua.setpeer(t,peer)
		end
		t = peer
	end
	local mt = getmetatable(t)
	if not mt then
		mt = {}
		setmetatable(t,mt)
	end
	if mt.__index~=accessIndex then
		mt.__index_list = {mt.__index}
		mt.__index = accessIndex
	end
	if k==nil then
		table.insert(mt.__index_list,f)
	else
		mt.__index_list[k] = f
	end
end

--多层成员插入
function metatable.push_newindex(t,k,f)
	if type(t)=="userdata" then
		local peer = tolua.getpeer(t)
		if not peer then
			peer = {}
			tolua.setpeer(t,peer)
		end
		t = peer
	end
	local mt = getmetatable(t)
	if not mt then
		mt = {}
		setmetatable(t,mt)
	end
	if mt.__newindex~=accessNewIndex then
		mt.__newindex_list = {mt.__newindex}
		mt.__newindex = accessNewIndex
	end
	if k==nil then
		table.insert(mt.__newindex_list,f)
	else
		mt.__newindex_list[k] = f
	end
end

--插入读写器
function metatable.getset(t,k,getter,setter)
	metatable.push_index(t,nil,function(t,_k)
		if k==_k then return getter(t,k) end
	end)
	metatable.push_newindex(t,nil,bind(setter,_1,_3))
	return t
end






