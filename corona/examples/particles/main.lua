require "blancoberg.timewarp.TimeWarp"


local bg = display.newImage("bg.png")
bg.width = display.contentWidth
bg.height = display.contentHeight
bg.x = bg.width/2
bg.y = bg.height/2

local btn = display.newImage("button.png")
btn.x = math.round(display.contentWidth/2)
btn.y = math.round(display.contentHeight/2)

for a=1,70,1 do
	
	local testObject = display.newImage("bouncy.png")
	testObject.x = display.contentWidth * math.random()
	testObject.y = -testObject.height
	testObject.xScale = a/70
	testObject.yScale = a/70
	TimeWarp.to(testObject,
		{
			time=1500 + 1000 * (1-testObject.xScale),
			delay=4000 * math.random(),
			rotation = 2000 * math.random(),
			y=display.contentHeight,
			transition=easing.linear
		})
		
		
end

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



