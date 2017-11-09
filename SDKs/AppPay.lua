--author:bbbirder
--@Dependencies: paying sdk
AppPay = {}

function AppPay:doPay(token_id,amount)
	print("AppPay","doPay")

	local _clsname = switch(device.platform){
		["android"] = "org/cocos2dx/lua/AppActivity",
		["ios"] = "RootViewController"
	}

	LuaBridge[_clsname]:DoPay(1,tostring(token_id),amount)
end
