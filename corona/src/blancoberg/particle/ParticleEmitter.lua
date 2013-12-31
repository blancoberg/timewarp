

ParticleEmitter = {}
ParticleEmitter.scale = 0.5
ParticleEmitter.__index = ParticleEmitter
ParticleEmitter._emitters = {}

--[[

{
	
	sensibleToMotion = 0 - 1, 					-	the motion of the emitter will effect the direction of the particles,
	force={from,to},   							-	Pixels per second in force
	direction = [0,40]  						-	Direction of force in degrees
	gravityX = 0,								-	X gravity
	gravityY = 9.8,								-	Y gravity
	particlesPerSecond = 30,					-	Amount of particles per second
	rotationSpeed = 4,							-	rotation speed of the particles
	randomness = [0.8,1],						-	randomness of the particle scale
	scale = 0.5,								-	scale of the particles
	lifetime = 1000								-	Lifetime of the particles
	blinks = true/false							-	If the particles should blink
	blinksPerSecond = 3							-	blink speed, if blinks is set to true
	parent = parentObject						-	parent wich the particles will be added to
	src= "images/star.png"						-	source of the particle-image
	width=30,									-	Width of the imageRect
	height=30,									-	Height of the imageRect
}

]]

function ParticleEmitter.new(data)
	
	
	local this = {}
	if data == nil then data = {} end
	this._data = data
	local random = math.random
	-------------------------------------------------------------
	--
	--  Creates emitter and its startvalues
	--
	-------------------------------------------------------------
	
	function this:create()
		
		
		this:createStandardValue(this._data,"sensibleToMotion",false)
		this:createStandardValue(this._data,"sensibleToAngle",true)
		this:createStandardValue(this._data,"force",{1300,1600})
		this:createStandardValue(this._data,"direction",{-10,10})
		this:createStandardValue(this._data,"gravityX",0)
		this:createStandardValue(this._data,"shape","circle")
		this:createStandardValue(this._data,"gravityY",8000)
		this:createStandardValue(this._data,"particlesPerSecond",30)
		this:createStandardValue(this._data,"rotationSpeed",{-20,20})
		this:createStandardValue(this._data,"randomness",{0.1,1})
		this:createStandardValue(this._data,"scale",{1,1})
		this:createStandardValue(this._data,"lifetime",nil)
		this:createStandardValue(this._data,"lifetimeTransition","easeNone")
		this:createStandardValue(this._data,"particleLifetime",500)
		this:createStandardValue(this._data,"blinks",false)
		this:createStandardValue(this._data,"blinksPerSecond",8)
		this:createStandardValue(this._data,"parent",nil)
		--this:createStandardValue(this._data,"src",0000)
		this:createStandardValue(this._data,"width",50)
		this:createStandardValue(this._data,"height",50)
		this:createStandardValue(this._data,"x",0)
		this:createStandardValue(this._data,"y",0)
		this:createStandardValue(this._data,"position",{0,0,0,0})
		this:createStandardValue(this._data,"delay",0)
		this:createStandardValue(this._data,"forceFieldRadius",0)
		
		this._data = data
		this.time = -this._data.delay/100
		this.timeWarp = TimeWarp
		this._particlesCreated = 0
		this._particle = {}
		this._speedX = 0
		this._speedY = 0
		this.x = this._data.x
		this.y = this._data.y
		this.rotation = 0
		this._lastX = this.x
		this._lastY = this.y
		this._life = 1
		
		if this._data.collision ~= nil then
			
			for i = 1 , #this._data.collision , 1 do
				
				local b = this._data.collision[1]
				
				this._data.collision[1] = b
			end
			
		end
		
		if this._data.lifetime ~= nil then
			
			TimeWarp.to(this,{_life=0,time=this._data.lifetime,isPausable = this._data.isPausable})
			
		end
		
		--if this._data.src ~= nil then
			table.insert(ParticleEmitter._emitters,1,this)
	--	else
			
	--		print("ParticleEmitter : You need to specify the directory to the particle image ( .src )")
			
	--	end
	end
	
	-------------------------------------------------------------
	--
	--  Creates standard values for the object
	--
	-------------------------------------------------------------
	
	function this:kill(time,delay)
	
		TimeWarp.to(this,{_life=0,time=time,delay=delay})
		
	end
	
	function this:removeSelf()
		
		for i = #this._particle,1,-1 do
			this._particle[i]:removeSelf()
		end
		
		ParticleEmitter.removeEmitter(this)
		
	end
	
	function this:createStandardValue(object,param,value)
		
		
		if object[param] == nil then
			object[param] = value
		end
		
	end
	
	-------------------------------------------------------------
	--
	--  update() is called on every frame and updates the particles
	--
	-------------------------------------------------------------
	
	function this:update()
		
		local timeScale = TimeWarp.getTimeScale()
		
		if this._data.isPausable == false then
			timeScale = 1
		end
		
		this.time = this.time + TimeWarp.timePerFrame * timeScale
		
		
		--local life = 1- (this.time / this._data.lifetime*1000)
		
		--if life <0 then life = 0 end
		local particlesPerFrame = 0
		
		while this._particlesCreated < this.time * this._data.particlesPerSecond*this._life do
		
			particlesPerFrame = particlesPerFrame + 1
			-- create new particle
			--print("new particle")
			local randomness = this._data.randomness[1] + (this._data.randomness[2]-this._data.randomness[1])*random()
			
			local newParticle 
			
			if this._data.src ~= nil then
				newParticle = display.newImageRect(this._data.src,this._data.width,this._data.height)
			else
				if this._data.shape ~= "circle" then
					newParticle = display.newRect(0,0,this._data.width,this._data.height)
				else
					newParticle = display.newCircle(0,0,this._data.width/2)
				end
				
				
				
				
			end
			
			if this._data.color ~= nil then
				newParticle:setFillColor(this._data.color[1],this._data.color[2],this._data.color[3])
			end
			
			newParticle.phase = random()
			newParticle.scale = this:getRandomFromArray(this._data.scale)
			
			--newParticle.xScale = this._data.scale * randomness
			--newParticle.yScale = newParticle.yScale
			newParticle.lifetime = this._data.particleLifetime
			newParticle.timePassed = 0
			newParticle.rotationSpeed = this:getRandomFromArray(this._data.rotationSpeed)
			newParticle.speed = {x=0,y=-this:getRandomFromArray(this._data.force)}
			--print("setting speed",newParticle.speed.x,newParticle.speed.y)
			local angle = (this._data.direction[1] + (this._data.direction[2]-this._data.direction[1])*random())/180 * math.pi
			
			
			if this._data.sensibleToMotion == true then
			
				newParticle.speed.x = newParticle.speed.x + this._speedX*20
				newParticle.speed.y = newParticle.speed.y + this._speedY*20
				
			end
			
			
			local x,y = this.x,this.y
			local newAngle = angle + this.rotation/180 * math.pi
			
			
			
			if this._data.objectOfInterest ~= nil then
				
				local parentx,parenty = 0,0
				
				
				
				local x2,y2 = this._data.objectOfInterest:localToContent(parentx,parenty)
				
				if this._data.parent ~= nil then
					
					
				 	x2,y2= this._data.parent:contentToLocal(x2,y2)--this._data.objectOfInterest.x,this._data.objectOfInterest.y
				end
				
				x2 = x2 + this._data.position[1] + (this._data.position[3]-this._data.position[1])*random()
				y2 = y2 + this._data.position[2] + (this._data.position[4]-this._data.position[2])*random()
				
				newAngle = angle 
				
				if this._data.sensibleToAngle == true then 
					
					newAngle = newAngle + this.rotation/180 * math.pi + this._data.objectOfInterest.rotation/180 * math.pi
					
				end
				
				local newCords = {x = this.x,y = this.y}
				ParticleEmitter.rotate(newCords,newAngle)
				x = x2 + newCords.x
				y = y2 + newCords.y
				
			else
			
				x = x + this._data.position[1] + (this._data.position[3]-this._data.position[1])*random()
				y = y + this._data.position[2] + (this._data.position[4]-this._data.position[2])*random()
			end
			
			
			
			if this._data.forceFieldRadius > 0 then
				
				local rnd = random()*math.pi*2
				if this._data.objectOfInterest == nil then
					x = this.x + this._data.forceFieldRadius*0.5 * math.sin(rnd)
					y = this.y + this._data.forceFieldRadius*0.5 * math.cos(rnd)
				else
					x = x + this._data.forceFieldRadius*0.5 * math.sin(rnd)
					y = y + this._data.forceFieldRadius*0.5 * math.cos(rnd)
				end
				
				ParticleEmitter.rotate(newParticle.speed ,-rnd)
			else
				ParticleEmitter.rotate(newParticle.speed ,newAngle)
			end
			
			newParticle.x = x
			newParticle.y = y
			newParticle._x = x
			newParticle._y = y
			
			this._particlesCreated = this._particlesCreated + 1
			
			if this._data.parent ~= nil then
				this._data.parent:insert(newParticle)
			end
			
			
			--table.insert(this._particle,1,newParticle)
			this._particle[#this._particle+1] = newParticle
		end
		
		--print("Particles per frame:",particlesPerFrame)
		
		for i = #this._particle,1,-1 do
			
			local particle = this._particle[i]
			particle.timePassed = particle.timePassed + this.timeWarp.timePerFrame * 1000 * timeScale
			
			
			--if this._particle[i].timePassed <0 then this._particle[i].timePassed = 0 end
			
			local newScale = particle.scale * (1 - particle.timePassed/particle.lifetime)
			
			if newScale>0 then
				if particle.collided ~= true then
					particle.xScale = newScale
				end
				
				particle.yScale = newScale
				
				
			end
			
			--if this._data.forceFieldRadius == 0 then
				if particle.collided ~= true then
					
					particle._y = particle._y + particle.speed.y*(this.timeWarp.timePerFrame) * timeScale
					particle._x = particle._x + particle.speed.x*(this.timeWarp.timePerFrame) * timeScale
					
					particle.y = particle._y
					particle.x = particle._x
					
				else
					--this._particle[i].isVisible = false
					particle.xScale = 1
				end
				
			--else
				--this._particle[i].x = 
			--end
			
			particle.speed.y = particle.speed.y + this._data.gravityY*(this.timeWarp.timePerFrame) * timeScale
			
			if this._data.blinks == true then
				particle.phase = particle.phase + (this.timeWarp.timePerFrame) * this._data.blinksPerSecond * timeScale
				particle.alpha = (particle.phase%1)
			end
			
			
			if particle.rotationSpeed ~= 0 and (this._data.shape ~= "circle" or this._data.src ~= nil) then
				particle.rotation = particle.rotation + particle.rotationSpeed * timeScale
			end
			
			--local particle = this._particle[i]
			if this._data.collision ~= nil then
				
				--local collided = false
				--local particle = this._particle[i]
				for k = 1 , #this._data.collision , 1 do
					
					local x,y = particle:localToContent(0,0)
					local collisionData = this._data.collision[k].contentBounds
					if x > collisionData.xMin and x < collisionData.xMax and y > collisionData.yMin and y < collisionData.yMax then
						
						if this._data.bounce ~= nil then
							particle.speed.y = -particle.speed.y*this._data.bounce
						else
							particle.collided = true
						end
						
						
					end
					
				end
				
			end
			
			if particle.timePassed>particle.lifetime then
			
				particle:removeSelf()
				table.remove(this._particle,i)
				
			end
			
		end
		
		this._speedX = 1*(this.x - this._lastX)--*this.timeWarp.frameRate
		this._speedY = 1*(this.y - this._lastY)--*this.timeWarp.frameRate
		
		this._lastX = this.x
		this._lastY = this.y
		
		this.time = this.time + this.timeWarp.timePerFrame * timeScale
		
		if this._life == 0 and #this._particle == 0 then
			
			ParticleEmitter.removeEmitter(this)
			
		end
	end
	
	-------------------------------------------------------------
	--
	--  Returns an random values in an arrayvalue
	--
	-------------------------------------------------------------
	
	function this:getRandomFromArray(array)
		--print("getRandomFromArray",array[1],array[2],array[2] - (array[2] - array[1])*math.random())
		return array[2] - (array[2] - array[1])*random()
	end
	
	-------------------------------------------------------------
	--
	--  Returns a random number from the "randomness"-parameter
	--
	-------------------------------------------------------------
	
	function this:getRandom()
		
		local random = this._data.randomness[1] + (this._data.randomness[2]-this._data.randomness[1])*random()
		return random
		
	end
	
	
	this:create()
	
	
	return setmetatable(this,ParticleEmitter)
	
end

-------------------------------------------------------------
--
--  Rotates a vector to a specific rotation
--
-------------------------------------------------------------

function ParticleEmitter.rotate(vector, angle)
	
	local cos_ang = math.cos(angle)
	local sin_ang = math.sin(angle)
	
	local new_x = (cos_ang * vector.x) - (sin_ang * vector.y)
	local new_y = (sin_ang * vector.x) + (cos_ang * vector.y)
	
	vector.x = new_x
	vector.y = new_y
	
end

-------------------------------------------------------------
--
--  Update all active emitters
--
-------------------------------------------------------------

function ParticleEmitter.removeEmitter(emitter)

	for i = #ParticleEmitter._emitters,1,-1 do
	
		if ParticleEmitter._emitters[i] == emitter then
			
			table.remove(ParticleEmitter._emitters,i)
			
		end
		
		
		
	end
	
end

function ParticleEmitter.update(event)
	
	for i = #ParticleEmitter._emitters,1,-1 do
	
		ParticleEmitter._emitters[i]:update()
		
	end
	
end

Runtime:addEventListener("enterFrame",ParticleEmitter.update)