--author:bbbirder
local functional = {}







--@Ability:
-- Y组合子, 用于实现匿名递归
--@Example:
-- local sum = Y(function(f) return function(i)
--     return i>0 and i+f(i-1) or 0
-- end end)
-- sum(10) --55
function functional.Y(f)
    return (function(f)
        return function(f2)
            return function(i)
                return f(function(...)
                    return f2(f2)(...)
                end)(i)
            end
        end
    end)(f) ((function(f)
        return function(f2)
            return function(i)
                return f(function(...)
                    return f2(f2)(...)
                end)(i)
            end
        end
    end)(f))
end




--@Ability:
-- 类似std::functional中的bind
-- 占位符‘_x’表示第x个参数,它是用时自动创建的。_0到_3因为常用所以提前手动创建了，用到_5的时候，bind会自动创建占位符_5，不需要操心。
-- _0等价于‘...’，为所有参数占位
--@Example:
-- local f = bind(print,_1,":my",_1,"is",_2,"!")
-- f("name","leo")
-- f("age",18)
--@What's More:
-- _0 means all params.
local _placeholder = {}
function functional.bind(func,...)
    local _argsSuper = {...}
    local _argcnt = select("#",...)
    return function(...)
        local _argsOut = {}
        local _argsInner = {...}
        -- for i,v in pairs(_argsSuper) do
        for i=1,_argcnt do
            local v = _argsSuper[i]
            local iph = _placeholder[v]
            if iph==0 then
                local _argcntInner = select("#",...)
                _argcnt = i + _argcntInner - 1
                for j=1,_argcntInner do
                    _argsOut[i+j-1] = _argsInner[j]
                end
                break
            end
            if iph then
                _argsOut[i] = _argsInner[iph]
            else
                _argsOut[i] = v
            end
        end
        return func(unpack(_argsOut,1,_argcnt))
    end
end

--make placeholders valid
setmetatable(functional,{
    __index = function(t,k)
        if k:sub(1,1)~="_" then return end
        local i = tonumber(k:sub(2))
        if i then
            rawset(t,k,{})
            _placeholder[t[k]] = i
        end
        return rawget(t,k)
    end
});

--preinstall useful placeholders...
(function()end){
    functional._0,
    functional._1,
    functional._2,
    functional._3
    -- and more ...
}









--用于解开多层嵌套调用的函数，抽象成一个加工流程
--@Ability:
-- linearization nesting calling,just as 
--    "DoSomethingA(DoSomethingB(DoSomethingC(...)))"
-- which can be changed to this form:
--    "procedure{
--        DoSomethingA,
--        DoSomethingB,
--        DoSomethingC,
--    }(...)".
--@Example:
-- local function addkv(t,k,v) --add a kv-pair into a table
--     t[k] = v
--     return t
-- end
-- local proc = procedure{
--     bind(addkv,_1,"name","leo"),
--     bind(addkv,_1,"age",18),
--     bind(addkv,_1,"role","warrior"),
-- }
-- dump(proc{
--     type = "player"
-- })
function functional.procedure(_funclist)
    return function(...)
        local ret = ...
        local uparg = {select(2,...)}
        for k,func in ipairs(_funclist) do
            ret = func(ret,unpack(uparg))
        end
        return ret
    end
end








--创建一个生命周期内只能被调用一次的函数
function functional.runOnce(func,...)
    local count = 0 --record call count
    local args = {...}
    local function innerfunc()
        if count == 0 then
            count = count + 1
            return func(unpack(args))
        end
    end
    return innerfunc
end











--工具类小函数，用于精简代码，有奇效

--空函数，用于占位
--例如：
--local func = print or n_n
--func() --不用担心报错
function functional.n_n()
    
end

--返回参数
--可以省略小括号，美化代码
--例如：
--  print(({name="leo"}).name)  --括号多了可读性差
--  print(p_p{name="leo"}.name) --省去括号
--  print(("age is %d"):format(18))
--  print(p_p"age is "%d":format(18))
function functional.p_p(...)
    return ...
end

--返回生成参数的表达式，可以用来嵌入到“与或非”的逻辑链（参数会被当场执行，但布尔化的返回值总是真）
--return 1 and x_x(print("true==!!1")) and "good" -- 不会在中间断掉，最终打印并返回good
function functional.x_x(...)
    local args = {...}
    return function()
        return unpack(args)
    end
end

--返回函数，用于DRY
-- (f_f) (print) (
--      1)      (2)     (3)
--     "name"  "is"    ("leo","zy")
--     "age"   "is"    ("18","years old")
function functional.f_f(f)
    local function innerfunc(...)
        f(...)
        return innerfunc
    end
    return innerfunc
end

--返回调用者，用于DRY
-- (o_o)(Stream)
--     :WriteByte(0)
--     :WriteChar(10)
--     :WriteString("name")
--     :WriteBool(false)
function functional.o_o(self)
    return setmetatable({__ref = self},{
        __index = function(t,k)
            return function(...)
                if(not self[k]) then error("owner table dont have field:"..k) end
                self[k](self,select(2,...))
                return t
            end
        end,
    })
end


--short function alias,if you think this form better
functional.retnil = functional.n_n--nil             
functional.retpar = functional.p_p--params          
functional.retexp = functional.x_x--expression      
functional.retfun = functional.f_f--function        
functional.retot  = functional.o_o--owner table     

--Deprecated.用prefix中的script
        --返回string对应函数
        --不可访问外部变量，如有需要请使用script
        -- (s_s) "return arg[1]+arg[2]" (123,100) --223
        function functional.s_s(s)
            return loadstring("return function(...)\n"..
                "local arg = {...}\n"..
                s.."\nend")()
        end

        function functional.S_S(s)
            return functional.s_s("return "..s)
        end

        functional.retscr = functional.s_s--normal script   
        functional.retss  = functional.S_S--short script    






return functional