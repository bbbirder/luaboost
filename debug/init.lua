local writeRootPath = cc.FileUtils:getInstance():getWritablePath() .. "/LuaDoctor"  
if not (cc.FileUtils:getInstance():isDirectoryExist(writeRootPath)) then         
    cc.FileUtils:getInstance():createDirectory(writeRootPath)    
end
local searchPaths = cc.FileUtils:getInstance():getSearchPaths() 
table.insert(searchPaths,1,writeRootPath .. '/')  
table.insert(searchPaths,2,writeRootPath .. '/res/')
table.insert(searchPaths,3,writeRootPath .. '/src/')
cc.FileUtils:getInstance():setSearchPaths(searchPaths)

import ".LogReport"