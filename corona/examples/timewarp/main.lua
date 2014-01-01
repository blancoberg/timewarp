require "blancoberg.timewarp.TimeWarp"
TimeWarp.overwrite()

local bg = display.newImage("bg.png")
bg.width = display.contentWidth
bg.height = display.contentHeight
bg.x = bg.width/2
bg.y = bg.height/2



for a=1,70,1 do
	
	local testObject = display.newImage("bouncy.png")
	testObject.x = display.contentWidth * math.random()
	testObject.y = -testObject.height - math.random()* display.contentHeight
	testObject.xScale = a/70
	testObject.yScale = a/70
	
	
	TimeWarp.to(testObject,
		{
			loop=-1, -- -1 = inifinity
			time=1500 + 1000 * (1-testObject.xScale),
			delay=4000 * math.random(),
			rotation = 2000 * math.random(),
			y=display.contentHeight+50,
			transition=easing.linear
		})
		
		
end

local btn = display.newImage("button.png")
btn.x = math.round(display.contentWidth/2)
btn.y = math.round(display.contentHeight/2)

function eventTouch(e)

	-- warp to slow motion on touch -- 
	if e.phase == "began" then
		TimeWarp.warpTo(0.07,300,0)
		TimeWarp.to(btn,{time=200,alpha=0,isPausable=false})
	end
	
	-- warp to regular speed on release -- 
	if e.phase == "ended" then
		TimeWarp.warpTo(1,200,200)
		TimeWarp.to(btn,{time=200,alpha=1,delay=200,isPausable=false})
	end

end

Runtime:addEventListener("touch",eventTouch)



