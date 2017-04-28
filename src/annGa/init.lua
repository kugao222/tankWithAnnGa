--print("-------src init ")
package.path = package.path..";./src/?.lua;"
--print(package.path)

-- 全局变量
local gb = {}; _G.gb = gb

--
require("functions") -- class/ dump/ 等
-- defines
gb.define = require("define")
gb.util = require("util")

--
gb.annClass = require("ann")
gb.populationClass = require("population")

