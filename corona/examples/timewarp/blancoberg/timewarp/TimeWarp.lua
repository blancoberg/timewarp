--require("blancoberg.Equations")

local actualTimeScale = 1
local actualTimeDiff = 1
local equations = Equations

TimeWarp = {}
TimeWarp.__index = TimeWarp
TimeWarp._tweens = {}												--		Table of active timers and tweens ( only used inside class )
TimeWarp.timeScale = 1						--		change this variable to slow down / speed up project
TimeWarp.frameRate = 60	
TimeWarp.timePerFrame = 1/60											-- 		Define frameRate of the project
TimeWarp.timeFactor = TimeWarp.timeScale							-- 	use this on enterFrame function that does +-*/ math on objects.
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

local _strings = 
{
	frameBased = 0,
	onMiddle = 1,
	time = 2,
	delay = 3,
	transition = 4,
	timer = 5,
	onComplete = 6,
	isPausable = 7,
	onUpdate = 8,
	onStart = 9,
	pause = 10,
	loop = 11,
	currentTime = 12
}

--[[

faster way to compare strings

]]

local function _compareStrings(str1,str2)

	return _strings[str1] == _strings[str2]
	

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
		
		--if( _compareStrings(k,"frameBased") ~= true and _compareStrings(k,"onMiddle") ~= true and _compareStrings(k,"time") ~= true and _compareStrings(k,"delay") ~= true and _compareStrings(k,"transition") ~= true and _compareStrings(k,"timer")~= true and _compareStrings(k,"onComplete")~=true and k ~= "isPausable" and k ~= "onUpdate" and k ~= "onStart" and k ~= "pause" and k ~= "loop" and k ~= "currentTime") then
		if( k ~= "frameBased" and k ~= "onMiddle" and k ~= "time" and k~="delay" and k~= "transition" and k ~= "timer" and k ~= "onComplete" and k ~= "isPausable" and k ~= "onUpdate" and k ~= "onStart" and k ~= "pause" and k ~= "loop" and k ~= "currentTime") then
			newParams[k] = v
			startValues[k] = obj[k]
		end
	end
	
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
	
	--print("TimeWarp.cleanDoubles",obj,params,tween2)
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
						--print("clean tween parameter",k)
						
						parameters[k] = nil
						--parameters[k] = nil
						
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

--	if TimeWarp.deltaTime > 1000/60 * 3  then TimeWarp.deltaTime = 1000/60 * 3  end
	--
	
	--TimeWarp.deltaTime = 1000/60
	local timeScale = TimeWarp.timeScale
	
	if(TimeWarp.freeze ~= true) then
	
		TimeWarp.timeFactor = TimeWarp.timeScale
		--print("timewarp.update")
		local time = system.getTimer()
		local tweens = TimeWarp._tweens
		local timeDiff =  TimeWarp.deltaTime--1000/60
		
		--actualTimeDiff  = math.min(2,TimeWarp.deltaTime/(1000/TimeWarp.frameRate))* _playing
		--actualTimeScale = math.min(2,timeScale * TimeWarp.deltaTime/(1000/TimeWarp.frameRate))  * _playing
		
		
		actualTimeDiff  = TimeWarp.deltaTime/(1000/TimeWarp.frameRate)* _playing
		actualTimeScale = timeScale * TimeWarp.deltaTime/(1000/TimeWarp.frameRate)  * _playing
		
		
		--print("getTimeScale()",actualTimeScale)
		
		--print("DeltaTime",TimeWarp.deltaTime)
		--print("PROCENT SPEED",TimeWarp.deltaTime/(1000/60))
		--TimeWarp.frameRate
	--	local timeDiff = 1000/60
		--if TimeWarp.deltaTime > (1000/60)*2 then
		--	TimeWarp.deltaTime = (1000/60)*2
		--end
		
		
		--local timeFrame = 1000/60
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
					
					--settings.delay = 4000
					-- create new startValues--

					
					
					
					
				end

				----------------------------------------------------------------------
				-- when no delays exist 
				----------------------------------------------------------------------

				if(settings.delay <=0) then
					
					-- when animation is halfway --
					-------------------------------
					
					if settings.currentTime > time*0.5 and tween.halfWayThrough ~= true then
						
						--print("halfWay")
						tween.halfWayThrough = true
						if settings.onMiddle ~= nil then
							--settings.onMiddle(tweens[i].obj)
							table_insert(callbacks,#callbacks+1,{callback=settings.onMiddle,object=objectOfInterest})
						end
						
					end
					
					if settings.delayComplete == nil  then
						settings.delayComplete = true
						
						
						if tween.custom ~= true then
							settings.currentTime = 0
							settings.currentTime = settings.currentTime  + math.abs(settings.delay)
							TimeWarp.cleanUpDoubles(tween)
							--TimeWarp.cleanUpDoubles(objectOfInterest,settings,tweens[i])
						end
						
						
						if tween.custom ~= true then
							
							for k,v in pairs(startValues) do 

									startValues[k] = objectOfInterest[k]

							end
							
						end
						
						
						if settings.onStart ~= nil then
							--settings.onStart(objectOfInterest)
							--print("onStart")
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


					--local procent = settings.currentTime/(time+settings.delay)		-- procent complete of tweens
					
					
					for k,v in pairs(parameters) do 

						--* @param t		Current time (in frames or seconds).
						--* @param b		Starting value.
					 	--* @param c		Change needed in value.
						--* @param d		Expected easing duration (in frames or seconds).
						--print("tween ",k,startValues[k])
						--print ("parameter ",k,parameters[k],"startvalues",k,startValues[k])
						
						--local t = settings.currentTime
						--local b = startValues[k]
						--local c = parameters[k] - startValues[k]
						--local d = time
						
						--local 
						--local procent = (t)/d
						--if procent >= 1 then
						--if k == "scale" then
							--print("tween procent",procent,k,"time")
						--end
							
						--end
						
						
						--objectOfInterest[k] = equations[settings.transition](settings.currentTime,startValues[k],parameters[k] - startValues[k],time)
						
						--time -- duration , start , difference
						objectOfInterest[k] = settings.transition(settings.currentTime,time,startValues[k],parameters[k] - startValues[k])
						
						
						--print(settings.transition)
						--objectOfInterest[k] = equations.easeNone(settings.currentTime,startValues[k],parameters[k] - startValues[k],time)
					--	print("tween ", k)
					end

					----------------------------------------------------------------------
					-- end of calculations 
					----------------------------------------------------------------------
					--print("onUpdate",settings.onUpdate)
					if settings.onUpdate ~= nil then
						--print("onUpdate")
						--settings.onUpdate(objectOfInterest)
						table_insert(callbacks,#callbacks+1,{callback=settings.onUpdate,object=objectOfInterest})
					end

					if(settings.currentTime>= time and tween.custom ~= true) then


							
							
							-- If tween is a timer 
							----------------------------------------------


								-- if timer is set to loop -- 
								local tempTween 
								
								if(settings.loop ~= 0) then

									--print("timer loop")
									settings.loop = settings.loop - 1
									settings.currentTime = 0
									--print("timer loop")
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
		--optimizer:endReg("timeWarp",#TimeWarp._tweens)
		
		
		for i=1,#callbacks,1 do
			callbacks[i].callback(callbacks[i].object)
		end
	end
	
	
	
	--print("TimeWarps",#TimeWarp._tweens)
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

	--print("remove tweens",obj,#TimeWarp._tweens)
	for i=#TimeWarp._tweens,1,-1 do
		
		--print("  tween",TimeWarp._tweens[i].settings.obj)
		if(TimeWarp._tweens[i].settings.obj == obj) then
			if params == nil then
				table.remove(TimeWarp._tweens,i)
			else
				
				for k = 1,#params,1 do
					TimeWarp._tweens[i].parameters[params[k]] = nil
				end
				
			end
			
			--print("tween removed",i)
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
	--TimeWarp._updatePhysics()
	--physics.setTimeStep((1/TimeWarp.frameRate) * TimeWarp.timeScale)
	--SoundManager._updatePitch()
	if(time == 0) then
		--physics.pause()
	else
		--physics.start()
	end
	
end

----------------------------------------------------------------------
-- Warps the time scale of all active tweens,timers and sounds
--
-- v = 1 = normal speed
----------------------------------------------------------------------

function TimeWarp.warpTo(v,time,d) -- v = 0<1, time in milliseconds

	TimeWarp.to(TimeWarp,{timeScale=v,delay=d,time=time,onUpdate=TimeWarp._updatePhysics,onComplete=TimeWarp._warpComplete})
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
	
		--physics.pause()
	end
end


----------------------------------------------------
-- Completely freezes all timers and transitions ---
-- without causing any effects ---------------------
----------------------------------------------------

function TimeWarp.setFreeze(v)
	TimeWarp.freeze = v
	if(v == true) then
		TimeWarp.timeScale = 0
		TimeWarp.timeFactor = 0
		--physics.pause()
	else
		TimeWarp.timeScale = 1
		TimeWarp.timeFactor = 1
		--physics.start()
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
	--transition.to = TimeWarp.to
	--transition.cancel = TimeWarp.cancel
	--transition.pause = TimeWarp.pause
	--transition.resume = TimeWarp.resume
	--TimeWarp.performWithDelay = TimeWarp.performWithDelay
	--timer.cancel = TimeWarp.cancel
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
--Runtime:addEventListener("touch",TimeWarp.debugPause)

  --physics.setTimeStep(1/50000)
	--physics.setTimeScale(0.5)
--TimeWarp.to(platform,{time=1000,delay=0,timer=true,loop = true})
