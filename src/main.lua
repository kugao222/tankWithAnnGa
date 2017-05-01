
cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"

local function main()
	cc.FileUtils:getInstance():addSearchPath("src/src/")
	cc.FileUtils:getInstance():addSearchPath("src/")
	package.path = package.path..";./src/?.lua;"
	require("src/src/init")

	local gb = _G.gb
	local annClass = gb.annClass
	local ann = annClass:create(1, 6, 24, 11)

	local InputVectors= {
	  {1,0, 1,0, 1,0, 1,0, 1,0, 1,0, 1,0, 1,0, 1,0, 1,0, 1,0, 1,0},                      
	  {-1,0, -1,0, -1,0, -1,0, -1,0, -1,0, -1,0, -1,0, -1,0, -1,0, -1,0, -1,0},               
	  {0,1, 0,1, 0,1, 0,1, 0,1, 0,1, 0,1, 0,1, 0,1, 0,1, 0,1, 0,1},                            
	  {0,-1, 0,-1, 0,-1, 0,-1, 0,-1, 0,-1, 0,-1, 0,-1, 0,-1, 0,-1, 0,-1, 0,-1},                 
	  {1,0, 1,0, 1,0, 0,1, 0,1, 0,1, -1,0, -1,0, -1,0, 0,-1, 0,-1, 0,-1},                         
	  {-1,0, -1,0, -1,0, 0,1, 0,1, 0,1, 1,0, 1,0, 1,0, 0,-1, 0,-1, 0,-1},                          
	  {1,0, 1,0, 1,0, 1,0, 1,0, 1,0, 1,0, 1,0, 1,0, -0.45,0.9, -0.9, 0.45, -0.9,0.45},            
	  {-1,0, -1,0, -1,0, -1,0, -1,0, -1,0, -1,0, -1,0, -1,0, 0.45,0.9, 0.9, 0.45, 0.9,0.45},      
	  {-0.7,0.7, -0.7,0.7, -0.7,0.7, -0.7,0.7, -0.7,0.7, -0.7,0.7, -0.7,0.7, -0.7,0.7, -0.7,0.7, -0.7,0.7, -0.7,0.7, -0.7,0.7},
	  {0.7,0.7, 0.7,0.7, 0.7,0.7, 0.7,0.7, 0.7,0.7, 0.7,0.7, 0.7,0.7, 0.7,0.7, 0.7,0.7, 0.7,0.7, 0.7,0.7, 0.7,0.7},    
	  {1,0, 1,0, 1,0, 1,0, -0.72,0.69,-0.7,0.72,0.59,0.81, 1,0, 1,0, 1,0, 1,0, 1,0 },          
	}
	local OutputVectors= {}
	local patternsNum = #InputVectors
	for i=1,patternsNum do
		local t = {}
		for j=1,patternsNum do
			t[j] = 0
		end
		t[i] = 1
		OutputVectors[i] = t
	end
	ann:training(InputVectors,OutputVectors)
	--ann:stimulate({0.1,0,0.2,0.4})	
	-- cc.Director:getInstance():setClearColor(cc.c4f(0.2,0.2,0.23,0.1))
 --    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
