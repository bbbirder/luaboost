-- author: bbbirder
--getset-supported-class,deprecated,use metatable.lua instead.

function access(remoteTable)
    local assistTable = {remote = remoteTable}
    assistTable.rawset = function(k,v)
        remoteTable[k] = v
    end
    assistTable.rawget = function(k)
        return remoteTable[k]
    end
    assistTable.localization = function(t)
        for k,v in pairs(t) do
        	rawset(assistTable,k,v)
        end
    end  
    setmetatable(assistTable,{
        __index = function(t,k)
            if type(remoteTable[k]) == "table" and remoteTable[k].get then
                return remoteTable[k].get(remoteTable,k)
            else
                return remoteTable[k]-- or getmetatable(assistTable) and getmetatable(assistTable)[k]
            end
        end,
        __newindex = function(t,k,v)
            if type(remoteTable[k]) == "table" and remoteTable[k].set then
                remoteTable[k].set(remoteTable,k,v)
            else
                remoteTable[k] = v
            end
        end
    })
    return assistTable
end

--factory of access
function Accessor(t)
	local function innerFunc()
		local assistTable = access(clone(t))
		assistTable.localization {
			getter = getmetatable(assistTable).__index,
			setter = getmetatable(assistTable).__newindex
		}
		return assistTable
	end
	return innerFunc
end

function class(clsname,super)
	local cls = {__name = clsname,ctor = function() end}
	local superType = type(super)
	if superType == "table" then
		cls.super = super
		cls.__create = function(...)
			if super.new then
				return super.new(...)
			else
				return {}
			end
		end
		setmetatable(cls,{__index = super})
	elseif superType == "function" then
		cls.__create = function(...)
			local inst = super(...)
			if inst.class then
				cls.super = inst.class
				setmetatable(cls,{__index = cls.super})
			end
			return inst
		end
	elseif super == nil then
		cls.__create = function()
			return {}
		end
	else
		error("bad class type:"..superType)
	end

	cls.new = function(...)
		local instance = cls.__create(...)
		rawset(instance,"class",cls)
		local mt = getmetatable(instance) or {}
		mt.__index = function(t,k)
			return cls[k] or rawget(t,"getter") and rawget(t,"getter")(t,k)
		end
		setmetatable(instance,mt)
		instance:ctor(...)
		return instance
	end

	return cls
end
