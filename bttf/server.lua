hoverstate = {}

function hov(thePlayer)
	if isPedInVehicle(thePlayer,car)then
		if getPedOccupiedVehicleSeat(thePlayer)== 0 then
			local car = getPedOccupiedVehicle(thePlayer)
			local id = getElementModel(car)
			if id == 541 then
				setElementModel(car,488)
				triggerClientEvent("onWheelChange",car,true)
				local state = getVehicleEngineState(car)
				setVehicleEngineState(car,state)
				setTimer(function(car)
					if isElement(car) then
						hoverstate[car] = 1
					end
				end,2000,1,car)
				triggerClientEvent("onHover",car)
				local players = getElementsByType("player")
				for k,player in ipairs(players) do
					if getElementDimension(player) == getElementDimension(car) then
						triggerClientEvent(player,"onHoveron",root,car)
					end
				end 
			elseif id == 488 then
				triggerClientEvent("onWheelChange",car,false)
				setTimer(function(car)
					if isElement(car) then
						setElementModel(car,541)
						local state = getVehicleEngineState(car)
						setVehicleEngineState(car,state)
						hoverstate[car] = 0
					end
				end,2000,1,car)
				triggerClientEvent("onHover",car)
				local players = getElementsByType("player")
				for k,player in ipairs(players) do
					if getElementDimension(player) == getElementDimension(car) then
						triggerClientEvent(player,"onHoveroff",root,car)
					end
				end 
			end
		end
	end	
end

local function fVehicleBind(uPlayer)
if isElement(uPlayer)and getElementType(uPlayer)== 'player' then
bindKey(uPlayer,'c','down',hov)
return true
end
return false
end

local function fVehicleBindManager()
if eventName == 'onPlayerJoin' then
fVehicleBind(source)
else
for _,uPlayer in pairs(getElementsByType 'player')do
fVehicleBind(uPlayer)
end
end
end
addEventHandler('onResourceStart',resourceRoot,fVehicleBindManager)
addEventHandler('onPlayerJoin',root,fVehicleBindManager)

function doc(thePlayer)
if isPedInVehicle(thePlayer)then
local car = getPedOccupiedVehicle(thePlayer)
local id = getElementModel(car)
if isPedInVehicle(thePlayer,car)then
if id == 609 then
setElementModel(car,414)
else
local car = getPedOccupiedVehicle(thePlayer)
local id = getElementModel(car)
if isPedInVehicle(thePlayer,car)then
if id == 414 then
setElementModel(car,609)
end
end
end
end
end
end
addCommandHandler("t",doc)

addCommandHandler("x",function(player)
	local target = getPedTarget(player)
	if isElement(target) then
		local x,y,z = getElementPosition(player)
		local a,b,c = getElementPosition(target)
		
		attachElements(target,player,math.abs(a-x),math.abs(b-y),math.abs(c-z))
	end

end)

function carv(thePlayer,com,v1,v2)
if isPedInVehicle(thePlayer) then
if v1 and v2 then
setVehicleVariant(getPedOccupiedVehicle(thePlayer),v1,v2)
end
end
end
addCommandHandler("var",carv)

function doc1(player)
setElementModel(player,0)
setElementModel(player,300)
end
addCommandHandler("iamdoc1",doc1)

function doc2(player)
setElementModel(player,0)
setElementModel(player,301)
end
addCommandHandler("iamdoc2",doc2)

function marty1(player)
setElementModel(player,0)
setElementModel(player,302)
end
addCommandHandler("marty1",marty1)
addEvent("setmarty",true)
addEventHandler("setmarty",root,marty1)

function marty2(player)
setElementModel(player,0)
setElementModel(player,303)
end
addCommandHandler("marty2",marty2)

function setHandlingModel(vehicleid)
	setModelHandling(vehicleid, "mass", 1200)
	setModelHandling(vehicleid, "turnMass", 2500)
	setModelHandling(vehicleid, "dragCoeff", 2.5)
	setModelHandling(vehicleid, "centerOfMass", {0.0, -0.15, -0.2} )
	setModelHandling(vehicleid, "percentSubmerged", 70)
	setModelHandling(vehicleid, "tractionMultiplier", 0.8)
	setModelHandling(vehicleid, "tractionLoss", 0.84)
	setModelHandling(vehicleid, "tractionBias", 0.50)
	setModelHandling(vehicleid, "numberOfGears", 5)
	setModelHandling(vehicleid, "maxVelocity", 200)
	setModelHandling(vehicleid, "engineAcceleration", 9.5)
	setModelHandling(vehicleid, "engineInertia", 15)
	setModelHandling(vehicleid, "driveType", "rwd")
	setModelHandling(vehicleid, "engineType", "petrol")
	setModelHandling(vehicleid, "brakeDeceleration", 6)
	setModelHandling(vehicleid, "brakeBias", 0.55)
	setModelHandling(vehicleid, "ABS", false)
	setModelHandling(vehicleid, "steeringLock", 30)
	setModelHandling(vehicleid, "suspensionForceLevel", 1.5)
	setModelHandling(vehicleid, "suspensionDamping", 0.2)
	setModelHandling(vehicleid, "suspensionHighSpeedDamping", 5)
	setModelHandling(vehicleid, "suspensionUpperLimit", 0.25)
	setModelHandling(vehicleid, "suspensionLowerLimit", -0.1)
	setModelHandling(vehicleid, "suspensionFrontRearBias", 0.45)
	setModelHandling(vehicleid, "suspensionAntiDiveMultiplier", 0.3)
	setModelHandling(vehicleid, "seatOffsetDistance", 0.1)
	setModelHandling(vehicleid, "collisionDamageMultiplier", 0.50)
	setModelHandling(vehicleid, "modelFlags", 0xC0002004)
	setModelHandling(vehicleid, "handlingFlags", 0x204000)
	setModelHandling(vehicleid, "headLight", 1)
	setModelHandling(vehicleid, "tailLight", 1)
	setModelHandling(vehicleid, "animGroup", 0)
end

function setHandlingVehicle(vehicle)
	setVehicleHandling(vehicle, "mass", 1200)
	setVehicleHandling(vehicle, "turnMass", 2500)
	setVehicleHandling(vehicle, "dragCoeff", 2.5)
	setVehicleHandling(vehicle, "centerOfMass", {0.0, -0.15, -0.2} )
	setVehicleHandling(vehicle, "percentSubmerged", 70)
	setVehicleHandling(vehicle, "tractionMultiplier", 0.8)
	setVehicleHandling(vehicle, "tractionLoss", 0.84)
	setVehicleHandling(vehicle, "tractionBias", 0.50)
	setVehicleHandling(vehicle, "numberOfGears", 5)
	setVehicleHandling(vehicle, "maxVelocity", 200)
	setVehicleHandling(vehicle, "engineAcceleration", 9.5)
	setVehicleHandling(vehicle, "engineInertia", 15)
	setVehicleHandling(vehicle, "driveType", "rwd")
	setVehicleHandling(vehicle, "engineType", "petrol")
	setVehicleHandling(vehicle, "brakeDeceleration", 6)
	setVehicleHandling(vehicle, "brakeBias", 0.55)
	setVehicleHandling(vehicle, "ABS", false)
	setVehicleHandling(vehicle, "steeringLock", 30)
	setVehicleHandling(vehicle, "suspensionForceLevel", 1.5)
	setVehicleHandling(vehicle, "suspensionDamping", 0.2)
	setVehicleHandling(vehicle, "suspensionHighSpeedDamping", 5)
	setVehicleHandling(vehicle, "suspensionUpperLimit", 0.25)
	setVehicleHandling(vehicle, "suspensionLowerLimit", -0.1)
	setVehicleHandling(vehicle, "suspensionFrontRearBias", 0.45)
	setVehicleHandling(vehicle, "suspensionAntiDiveMultiplier", 0.3)
	setVehicleHandling(vehicle, "seatOffsetDistance", 0.1)
	setVehicleHandling(vehicle, "collisionDamageMultiplier", 0.50)
	setVehicleHandling(vehicle, "modelFlags", 0xC0002004)
	setVehicleHandling(vehicle, "handlingFlags", 0x204000)
	setVehicleHandling(vehicle, "headLight", 1)
	setVehicleHandling(vehicle, "tailLight", 1)
	setVehicleHandling(vehicle, "animGroup", 0)
end

addEventHandler("onElementModelChange", root,function()
	if getElementType(source) == "vehicle" then
		local id = getElementModel(source)
		if id == 541 or id == 451 or id == 415 or id == 467 then
			setTimer(function(source)
				if isElement(source) then
					setHandlingVehicle(source)
				end
			end,50,1,source)
		end
	end
end)

setHandlingModel(541)
setHandlingModel(451)
setHandlingModel(467)