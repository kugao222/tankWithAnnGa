local MainScene = class("MainScene", cc.load("mvc").ViewBase)

local cc = _G.cc
local director = cc.Director:getInstance()
local s = director:getWinSize() -- 960*640
cc.FileUtils:getInstance():addSearchPath("src/annGa")
require("src/annGa/init")

--
function MainScene:onEnter()
	
end

return MainScene
