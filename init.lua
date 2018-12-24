--author:bbbirder

--cocos-lua开发框架，功能包括：
--	lua语法和函数库、cocos简化和扩充、第三方模块等

__SUPPORT_VERSION__ = "1.2"

--DONT MODIFY THE FOLLOWING ORDER UNLESS YOU KNOW WHAT YOU ARE DOING.
import ".config"
import ".base.init"
import ".CocosEx.init"
import ".device.init"
import ".network.init"
import ".SDKs.init"

if DEBUG_ENABLED then
	import ".debug.init"
end



-- end of the file

--end2
