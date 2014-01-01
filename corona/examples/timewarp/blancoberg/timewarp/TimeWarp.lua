local actualTimeScale = 1
local actualTimeDiff = 1
local equations = Equations

TimeWarp = {}
TimeWarp.__index = TimeWarp
TimeWarp._tweens = {}						--		Table of active timers and tweens ( only used inside class )
TimeWarp.timeScale = 1						--		change this variable to slow down / speed up project
TimeWarp.frameRate = 60	
TimeWarp.timePerFrame = 1/60				-- 		Define frameRate of the project
TimeWarp.timeFactor = TimeWarp.timeScale	-- 		use this on enterFrame function that does +-*/ math on objects.
TimeWarp.timer = {}
TimeWarp.lastTime = system.getTimer()
TimeWarp.actualTimeScale = 1
TimeWarp.actualTimeDiff = 1

local _playing = 1

----------------------------------------------------------------------
-- Create a Tween of a desirable object .
-- 
-- time					time in milliseconds.
-- delay				delay in milliseconds.
-- obj				 	the displayObject that you want to tween.
-- onComplete			function to run when tween is complete.
-- onUpdate				function to run when tween is updated ( each frame ).
-- onStart				function to run when tween has started ( after delay is complete )

----------------------------------------------------------------------

local function table_insert(a,b,c)
	
	a[b] = c

end

function TimeWarp.to(obj,params) -- displayobject, object, --- > returns type:tween
	
	
	if(params.time == nil) then params.time = 500 end
	if(params.delay == nil) then params.delay = 0 end
	if(params.timer == nil) then params.timer = false end
	if(params.loop == nil) then params.loop = 1 end
	if(params.pause == nil) then params.pause = false end
	if(params.isPausable == nil) then params.isPausable = true end
	if(params.transition == nil) then params.transition = easing.linear end--"easeNone" end
	if(params.frameBased == nil) then params.frameBased = false end
	
	
	if(obj == TimeWarp) then
		params.isPausable = false
	end
	
	params.loop = params.loop -1
	local newParams = {}
	
	-- Removes settings variables -- 
	
	local startValues = {}
	for k,v in pairs(params) do 
		
		if( k ~= "frameBased" and k ~= "loop" and k ~= "onMiddle" and k ~= "time" and k~="delay" and k~= "transition" and k ~= "timer" and k ~= "onComplete" and k ~= "isPausable" and k ~= "onUpdate" and k ~= "onStart" and k ~= "pause" and k ~= "loop" and k ~= "currentTime") then
			newParams[k] = v
			startValues[k] = obj[k]
		end
	end
	params.startDelay = params.delay
	params.currentTime = 0
	params.obj = obj
	local newTween = {parameters=newParams,settings=params,startValues=startValues}
	newTween.startDelay = params.delay
	
	
	table_insert(TimeWarp._tweens,#TimeWarp._tweens+1,newTween)
	return newTween
end

----------------------------------------------------------------------
-- Check for duplicates of tween .
-- If exist then remove them and replace with the newest -- 

----------------------------------------------------------------------

function TimeWarp.cleanUpDoubles(tween)
	
	
	local tweens = TimeWarp._tweens
	
	
	for i= #tweens,1,-1 do
		
		
		local ctween = tweens[i]
		local settings = ctween.settings
		local parameters = ctween.parameters
		-- if object exist --
		
		if(tween.settings.obj == ctween.settings.obj and tween ~= ctween and settings.delay<=0) then
			
			
			-- loop through active variabels -- 
			for k,v in pairs(parameters) do
				
				for a,b in pairs(tween.parameters) do
					if(k == a) then
					
						-- exists --
						
						parameters[k] = nil
						
						
					end
				end
				
			end
				
			
		end
		
	end
	
end

----------------------------------------------------------------------
-- Calculate active tweens --
----------------------------------------------------------------------

function TimeWarp.update()
	
	local callbacks = {}
	
	TimeWarp.deltaTime = system.getTimer() - TimeWarp.lastTime
	TimeWarp.lastTime = system.getTimer()
	
	--if TimeWarp.deltaTime > 1000/TimeWarp.frameRate * 3  then TimeWarp.deltaTime = 1000/TimeWarp.frameRate * 3  end
	--if TimeWarp.deltaTime > 1000/60 * 3  then TimeWarp.deltaTime = 1000/60 * 3  end
	--TimeWarp.deltaTime = 1000/60
	
	local timeScale = TimeWarp.timeScale
	
	if(TimeWarp.freeze ~= true) then
	
		TimeWarp.timeFactor = TimeWarp.timeScale
		local time = system.getTimer()
		local tweens = TimeWarp._tweens
		local timeDiff =  TimeWarp.deltaTime--1000/60
		
		--actualTimeDiff  = math.min(2,TimeWarp.deltaTime/(1000/TimeWarp.frameRate))* _playing
		--actualTimeScale = math.min(2,timeScale * TimeWarp.deltaTime/(1000/TimeWarp.frameRate))  * _playing
		
		actualTimeDiff  = TimeWarp.deltaTime/(1000/TimeWarp.frameRate)* _playing
		actualTimeScale = timeScale * TimeWarp.deltaTime/(1000/TimeWarp.frameRate)  * _playing
		
		for i=#tweens,1,-1 do

			local tween = tweens[i]
			local settings = tween.settings
			local objectOfInterest = settings.obj
			local parameters = tween.parameters
			local startValues = tween.startValues
			local time = settings.time
			
			if settings.frameBased == true then
				timeDiff = 1000/TimeWarp.frameRate
			else
				timeDiff = TimeWarp.deltaTime
			end
			----------------------------------------------------------------------
			-- when tweens completes 
			----------------------------------------------------------------------

			if(settings.pause == false or settings.isPausable == false) then



				if settings.delay>0 then

					if objectOfInterest ~= TimeWarp and settings.isPausable == true then
						settings.delay = settings.delay - timeDiff * timeScale*_playing
					else
						settings.delay = settings.delay - timeDiff 
					end
					
					

					
					
					
					
				end

				----------------------------------------------------------------------
				-- when no delays exist 
				----------------------------------------------------------------------

				if(settings.delay <=0) then
					
					-- when animation is halfway --
					-------------------------------
					
					if settings.currentTime > time*0.5 and tween.halfWayThrough ~= true then
						
						
						tween.halfWayThrough = true
						if settings.onMiddle ~= nil then
							
							table_insert(callbacks,#callbacks+1,{callback=settings.onMiddle,object=objectOfInterest})
						end
						
					end
					
					if settings.delayComplete == nil  then
						settings.delayComplete = true
						
						
						if tween.custom ~= true then
							settings.currentTime = 0
							settings.currentTime = settings.currentTime  + math.abs(settings.delay)
							TimeWarp.cleanUpDoubles(tween)
							
						end
						
						
						if tween.custom ~= true then
							
							for k,v in pairs(startValues) do 

									startValues[k] = objectOfInterest[k]

							end
							
						end
						
						
						if settings.onStart ~= nil then
							
							table_insert(callbacks,#callbacks+1,{callback=settings.onStart,object=objectOfInterest})
							
						end
					end
					
					if objectOfInterest ~= TimeWarp and settings.isPausable == true then
						
						if tween.custom ~= true then
							settings.currentTime = settings.currentTime + timeDiff * timeScale* _playing
						end
						
					else
						
						if tween.custom ~= true then
							settings.currentTime = settings.currentTime + timeDiff 
						end
					end


					if(settings.currentTime>time ) then

						settings.currentTime = time

					end
					----------------------------------------------------------------------
					-- here is where the calculations is executed 
					-- loops through every variable that has been sent to the tween ex: x,y,alpha,rotation etc..
					----------------------------------------------------------------------

					for k,v in pairs(parameters) do 

						objectOfInterest[k] = settings.transition(settings.currentTime,time,startValues[k],parameters[k] - startValues[k])
					end

					----------------------------------------------------------------------
					-- end of calculations 
					----------------------------------------------------------------------
					
					if settings.onUpdate ~= nil then
						
						table_insert(callbacks,#callbacks+1,{callback=settings.onUpdate,object=objectOfInterest})
					end

					if(settings.currentTime>= time and tween.custom ~= true) then


							
							
							-- If tween is a timer 
							----------------------------------------------


								-- if timer is set to loop -- 
								local tempTween 
								
								if(settings.loop ~= 0) then

								
									settings.loop = settings.loop - 1
									settings.currentTime = 0
									
								else

									-- else remove tween from global table -- 
									tempTween = tweens[i]
									table.remove(tweens,i)
								end
								
								if tempTween ~= nil then
									
									if tempTween.settings.onComplete ~= nil then
									--	tempTween.settings.onComplete(tempTween.objectOfInterest)
										table_insert(callbacks,#callbacks+1,{callback=tempTween.settings.onComplete,object=objectOfInterest})

									end
									
								end
								

					end


				end



			end
		end
		
		
		for i=1,#callbacks,1 do
			callbacks[i].callback(callbacks[i].object)
		end
	end
	
	
end

----------------------------------------------------------------------
-- Replaces TimeWarp.performWithDelay --
----------------------------------------------------------------------

function TimeWarp.performWithDelay(time,func,loops,paus)
	--print("perform with delay",time,func,loops,paus)
	local timer = {}
	return TimeWarp.to(timer,{time=time,timer=true,isPausable=paus,onComplete=func,loop=loops})
end



function TimeWarp.getTimeScale()
	return actualTimeScale
end

function TimeWarp.getTimeDiff()
	return actualTimeDiff
end

----------------------------------------------------------------------
-- Pauses a specific tween or timer 								--
----------------------------------------------------------------------

function TimeWarp.pause(tween) -- type:tween
	tween.pause = true
end

----------------------------------------------------------------------
-- Resumes a specific tween or timer 								--
----------------------------------------------------------------------

function TimeWarp.resume(tween) -- type:tween
	tween.pause = false
end

----------------------------------------------------------------------
-- Removes a specific tween or params of a tween					--
-- obj 		- remove tweens that uses this object
----------------------------------------------------------------------

function TimeWarp.removeTweens(obj,params)

	
	for i=#TimeWarp._tweens,1,-1 do
		
		if(TimeWarp._tweens[i].settings.obj == obj) then
			if params == nil then
				table.remove(TimeWarp._tweens,i)
			else
				
				for k = 1,#params,1 do
					TimeWarp._tweens[i].parameters[params[k]] = nil
				end
				
			end
			
		end
		
	end
	
end

----------------------------------------------------------------------
-- Removes a specific tween or timer 								--
----------------------------------------------------------------------

function TimeWarp.cancel(tween) -- removes type:tween
	
	local tweens = TimeWarp._tweens
	--print("timewarp.cancel")
	for i=#tweens,1,-1 do
		
		if(tweens[i] == tween) then
			table.remove(tweens,i)
		--	print("found and removes")
		end
		
	end
	
end

----------------------------------------------------------------------
-- Pause all active tweens & timers --
-- can be used for instance to pause the whole game --
----------------------------------------------------------------------

function TimeWarp.pauseAll()

	for i=1,#TimeWarp._tweens,1 do
		TimeWarp._tweens[i].pause = true
	end
end

----------------------------------------------------------------------
-- Resume all active tweens & timers --
----------------------------------------------------------------------

function TimeWarp.resumeAll()
	
	for i=1,#TimeWarp._tweens,1 do
		TimeWarp._tweens[i].pause = false
	end
	
end



----------------------------------------------------------------------
-- Returns true if TimeWarp is active and playing
----------------------------------------------------------------------

function TimeWarp.isPlaying()
	return _playing==1
end


----------------------------------------------------------------------
-- Resumes TimeWarp and all its active tweens
----------------------------------------------------------------------

function TimeWarp.resume()
	-- resumes all tweens -- 
	_playing = 1
end

----------------------------------------------------------------------
-- Adds physics.setTimeScale(time:milliseconds)
----------------------------------------------------------------------

function TimeWarp.setTimeScale(time) -- 0<1 where 1 is normal 
	
	TimeWarp.timeScale = time
	
end

function TimeWarp.from(obj,params)
	
	local tween =  TimeWarp.to(obj,params)
	local obj = tween.settings.obj
	
	for k,j in pairs(tween.parameters) do
		
		local target = obj[k]
		local start = tween.parameters[k]
		tween.parameters[k] = target
		tween.startValues[k] = start
		
		
	end
	
	return tween

end

----------------------------------------------------------------------
-- Warps the time scale of all active tweens,timers and sounds
--
-- v = 1 = normal speed
----------------------------------------------------------------------

function TimeWarp.warpTo(v,time,d) -- v = 0<1, time in milliseconds

	TimeWarp.to(TimeWarp,{timeScale=v,delay=d,time=time,onUpdate=TimeWarp._updatePhysics})
	--physics.start()
end

function TimeWarp._updatePhysics()
	
	if physics ~= nil and SoundManager ~= nil then
		physics.setTimeStep((1/TimeWarp.frameRate) * TimeWarp.timeScale)
		SoundManager._updatePitch()
	end
	
end

function TimeWarp._warpComplete()
	
	if(TimeWarp.timeScale == 0) then
	
	end
end

----------------------------------------------------------------------
-- init and replaces all standard functions of transition and timer + adds setTimeScale to physics --
----------------------------------------------------------------------

function TimeWarp.overwrite()
	
	transition = TimeWarp
	timer = TimeWarp
	

end

function TimeWarp.init(fps)
	
	TimeWarp.frameRate = fps
	TimeWarp.timePerFrame = 1/fps
	
	if physics ~= nil then
		physics.setTimeScale = TimeWarp.setTimeScale
		physics.warpTo = TimeWarp.warpTo
	end
	
	Runtime:addEventListener("enterFrame",TimeWarp.update,"timeWarp")
end

function TimeWarp.debugPause(event)

	if event.phase == "ended" and event.y > display.contentHeight then
		
		if TimeWarp.timeScale == 1 then
			TimeWarp.timeScale = 0.1
		else
			TimeWarp.timeScale = 1
		end
		
	end
	
end

TimeWarp.init(display.fps)

