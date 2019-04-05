addEvent("onTraveled",true)
boostc1 = {}
boostc2 = {}
Timer = {}
Traveltime = {}
mph = {}
marker = {}

function Lights(player,key,state)
	if getPedOccupiedVehicleSeat(player) == 0 then
		local car = getPedOccupiedVehicle(player)
		if getVehicleOverrideLights(car) ~= 2 then
			setVehicleOverrideLights(car,2)
		else
			setVehicleOverrideLights(car,1)
		end
	end
end

function Engine(thePlayer,key,state)
	if(getPedOccupiedVehicleSeat(thePlayer) == 0) then
		local car = getPedOccupiedVehicle(thePlayer)
		if isTimeMachine(car) then
			local state = not getVehicleEngineState(car)
			setVehicleEngineState(car,state)
			local players = getVehicleOccupants(car)
			for k,player in pairs(players) do
				triggerClientEvent(player,"onEngineState",car,state) 
			end
		end
	end
end

function boost(thePlayer,key,state)
	local car = getPedOccupiedVehicle(thePlayer)
	if not getPedOccupiedVehicleSeat(thePlayer) == 0 then return end
	if isTimeMachine(car) == "BTTF2_Fly" then
		if state == "down" then
			if hoverstate[car] == 1 then
				setVehicleColor(car,200,200,200,255,200,30)
				if key == "space" then
					setElementData(car,"boosted",1)
				elseif key == "rctrl" then
					setElementData(car,"boosted",2)
				end
				
				local x,y,z = getElementPosition(car)
				boostc1[car] = createMarker(x,y,z,"corona",0.4,255,160,20,255)
				boostc2[car] = createMarker(x,y,z,"corona",0.4,255,160,20,255)
				local dimen = getElementDimension(car)
				setElementDimension(boostc1[car],dimen)
				setElementDimension(boostc2[car],dimen)
				attachElements(boostc1[car],car,-0.42,-2.3,0.4)
				attachElements(boostc2[car],car,0.39,-2.3,0.4)
				
				local players = getVehicleOccupants(car)
				for k,player in pairs(players) do
					triggerClientEvent(player,"onBoost",car,true) 
				end
			end
		else
			setElementData(car,"boosted",false)
			setVehicleColor(car,200,200,200,67,64,64)
			local players = getElementsByType("player")
			local players = getVehicleOccupants(car)
			for k,player in pairs(players) do
				triggerClientEvent(player,"onBoost",car,false) 
			end
			if isElement(boostc1[car]) then
				destroyElement(boostc1[car])
				destroyElement(boostc2[car])
			end
		end
	end
end



function fVehicleBind(uPlayer)
	if isElement(uPlayer) then
		bindKey(uPlayer,'space','both',boost)
		bindKey(uPlayer,'rctrl','both',boost)
		bindKey(uPlayer,'1','down',spawndel1)
		bindKey(uPlayer,'2','down',spawndel2)
		bindKey(uPlayer,'3','down',spawndel3)
		bindKey(uPlayer,'4','down',spawndel4)
		bindKey(uPlayer,"l","down",Lights)
		bindKey(uPlayer,"o","down",Engine)
	end
end

local function fVehicleBindManager()
	if eventName == 'onPlayerJoin' then
		fVehicleBind(source)
	else
		for _,player in pairs(getElementsByType("player")) do
			fVehicleBind(player)
		end
	end
end
addEventHandler('onResourceStart',resourceRoot,fVehicleBindManager)
addEventHandler('onPlayerJoin',root,fVehicleBindManager)

addEvent("keyPadEnter_s",true)
addEventHandler("keyPadEnter_s",root,function(car,number)
	local players = getVehicleOccupants(car)
	local retValue
	if type(number) == "number" then
		for k,player in pairs(players) do
			if player ~= client then
				triggerClientEvent(player,"keyPadEnter_c",player,car,number)
			end
		end
	elseif number == "state" then
		if getPedOccupiedVehicleSeat(source) == 0 then
			retValue = keyPadState(car)
		end
	elseif number == "enter" then
		retValue = keyPadEnterKey(car)
	end
	if retValue then
		for k,player in pairs(players) do
			triggerClientEvent(player,"keyPadEnter_c",player,car,retValue)
		end
	end
end)

function keyPadEnterKey(car)
	if getElementData(car,"trt") == 1 then
		local yearTable = getElementData(car,"keyPad") or {}
		local year = tonumber(table.concat(yearTable) or "")
		local yearDimen = BttfYearDimen[year]
		if yearDimen then
			Traveltime[car] = yearDimen
			setElementData(car,"year",year)
			return "enter"
		else
			setElementData(car,"keyPad",{})
			return "error"
		end
	end
end

function wheel(thePlayer,command,newFLeft,newRLeft,newFRight,newRRight)
	if isPedInVehicle(thePlayer) then
	local car = getPedOccupiedVehicle(thePlayer)
	local id = getElementModel(car)
		setVehicleWheelStates(car,newFLeft,newRLeft,newFRight,newRRight )
	end
end
addCommandHandler("state",wheel)

function keyPadState(car)
	if isElement(car) then
		if getElementData(car,"trt") == 1 then
			setElementData(car,"trt",0)
			if isTimer(Timer[car]) then
				killTimer(Timer[car])
			end
			if isElement(marker[car]) then
				destroyElement(marker[car])
			end
			triggerClientEvent("onTravelEffect",root,car,false)
			return "off"
		else
			setElementData(car,"keyPad",{})
			setElementData(car,"trt",1)
			if not Traveltime[car] then
				local dimen = getElementDimension(car)
				local year = table.find(BttfYearDimen,dimen)
				setElementData(car,"year",year)
				if dimen <= 3 then
					Traveltime[car] = dimen
				else
					Traveltime[car] = 2
				end
			end
			return "on"
		end
	end
end

cars = {}

function TimeTravel()
	setTimer(function()
		for xk,car in ipairs(getElementsByType("vehicle")) do
			if isTimeMachine(car) then
				if getElementData(car,"trt") == 1 and not getElementData(car,"trtsystem") then
					local sx,sy,sz = getElementVelocity (car)
					local mph = math.floor(((sx^2 + sy^2 + sz^2)^(0.5))*111.847)
					for k,v in ipairs(getElementsByType("player")) do
						if getElementDimension(v) ~= getElementDimension(car) then	
							triggerClientEvent(v,"onTravelEffect",root,car,false)
						end
					end
					if mph >= 80 then
						if isElement(marker[car]) then
							local size = (mph-75)*0.1
							setMarkerSize(marker[car],size)
						end
						if not getElementData(car,"travelsound") then
							setElementData(car,"travelsound",1)
							for ik,v in ipairs(getElementsByType("player")) do
								if getElementDimension(v) == getElementDimension(car) then
									triggerClientEvent(v,"onTravelEffect",root,car,true)
								end
							end
							if getElementData(car,"mrf") == 1 then
								marker[car] = createMarker(0,0 ,-20,"corona")
								setElementDimension(marker[car],getElementDimension(car))
								if getTimeMachineType(isTimeMachine(car)) == 2 then
									setMarkerColor(marker[car],255,75,75,255)
								else
									setMarkerColor(marker[car],0,90,230,255)
								end
								setMarkerSize(marker[car],0.7)
								attachElements(marker[car],car,0,4,0)
							end
						end
						if mph >= 88 then
							local theplayer = getVehicleOccupant(car,0)
							if theplayer then
								if getElementData(theplayer,"rcmode") == 1 then
									BTTF_SetPlayerRC(theplayer,false)
									setElementData(theplayer,"rccar",false)
								end
							end
							setBTTFTravel(car)
						end
					end
					if mph < 80 then
						if isElement(marker[car]) then
							destroyElement(marker[car])
						end
						setElementData(car,"travelsound",false)
						triggerClientEvent("onTravelEffect",root,car,false)
					end
				end
			end
		end
	end,50,0)
end
TimeTravel()

function setBTTFTravel(car)
	if getElementData(car,"mrf") == 1 then
		triggerClientEvent("onTravelEffect",root,car,false)
		for k,v in ipairs(getElementsByType("player")) do
			if isPedInVehicle(v) and getPedOccupiedVehicle(v) == car then
				fadeCamera(v,false,0.001,255,255,255)
				setTimer(fadeCamera,50,1,v,true,0.5)
				setElementDimension(v,Traveltime[car])
				setElementDimension(car,Traveltime[car])
				setTimer(function()
					setElementData(car,"emptystate",false)
					local players = getVehicleOccupants(car)
					for k,player in pairs(players) do
						triggerClientEvent(player,"emptyd",car,car) 
					end
				end,1000,1)
				triggerClientEvent(v,"ontravel",root)
			elseif getElementDimension(v) == getElementDimension(car) then
				triggerClientEvent(v,"ontravelc",root,car)
			end
		end
		triggerEvent("onTraveled",car,car,Traveltime[car])
		createWheelFire(car)
		createCoolSmoke(car)
		setTimer(setElementData,15000,1,car,"ven",true)
		setTimer(setElementData,21000,1,car,"ven",false)
		setElementData(car,"oyear",getElementDimension(car))
		setElementDimension(car,Traveltime[car])
		for k,v in ipairs(getElementsByType("player")) do
			if getElementDimension(v) == Traveltime[car] then
				triggerClientEvent(v,"letExplode",root,car)
			end
		end
		setElementData(car,"trtsystem",1)
		setTimer(function()
			setElementData(car,"trtsystem",false)
		end,3000,1)
		setElementData(car,"mrf",0)
		setElementData(car,"travelsound",false)
		destroyElement(marker[car])
		setTimer(function()
			triggerClientEvent("onTravelEffect",root,car,false)
		end,1000,1)
	end
end

function createCoolSmoke(car)
	if isElement(car) then
		setElementData(car,"coolSmoke",true)
		if isTimer(getElementData(car,"coolSmokeTimer")) then
			killTimer(getElementData(car,"coolSmokeTimer"))
		end
		setElementData(car,"coolSmokeTimer",setTimer(setElementData,250000,1,car,"coolSmoke",false))
	end
end

addEvent("onBTTFAddMrFusion",true)
addEventHandler("onBTTFAddMrFusion",root,function(car)
	if isElement(car) then
		if getElementData(car,"mrf") ~= 1 then
			setElementData(car,"mrf",1)
			setVehicleDoorOpenRatio(car,1,1,300)
			local dimen = getElementDimension(source)
			triggerClientEvent("onmrfusion",root,car,dimen) 
			setTimer(function(car)
				setElementData(car,"emptystate",true)
				setElementData(car,"pemptystate",true)
			end,1000,1,car)
			setTimer(function()
				setVehicleDoorOpenRatio(car,1,0,200)
			end,2600,1)
		end
	end
end)

function createWheelFire(car)
	local dimension = getElementDimension(car)
	local wheelfirel = {}
	local wheelfirer = {}
	for i=1,20 do
		local objs = createObject(3524,0,0,0)
		wheelfirel[i] = objs
		setElementDimension(objs,dimension)
		attachElements(objs,car,1,i+1,-0.4)
		detachElements(objs)
		setElementCollisionsEnabled(objs,false)
		setObjectScale(objs,0)
		local objs = createObject(3524,0,0,0)
		wheelfirer[i] = objs
		setElementDimension(objs,dimension)
		attachElements(objs,car,-1,i+1,-0.4)
		detachElements(objs)
		setElementCollisionsEnabled(objs,false)
		setObjectScale(objs,0)
	end
	setTimer(function(wfl,wfr)
		for i=1,#wfl do
			if isElement(wfl[i]) then
				destroyElement(wfl[i])
			end
			if isElement(wfr[i]) then
				destroyElement(wfr[i])
			end
		end
	end,20000,1,wheelfirel,wheelfirer)
end

function spawndel1(thePlayer)
	if not isPedInVehicle(thePlayer) then
		local x,y,z = getElementPosition(thePlayer)
		local rx,ry,rz = getElementRotation(thePlayer)
		local del = createVehicle(451,x,y,z) 
		local dimen = getElementDimension(thePlayer)
		setElementDimension(del,dimen)
		setElementRotation(del,rx,ry,rz)
		warpPedIntoVehicle(thePlayer,del,0)
		setVehicleEngineState(del,true)
		setVehicleDamageProof(del,true)
		setVehicleColor(del,200,200,200,67,64,64)
		setVehicleOverrideLights(del,1)
	end
end

function spawndel2(thePlayer)
	if not isPedInVehicle(thePlayer) then
		local x,y,z = getElementPosition(thePlayer)
		local rx,ry,rz = getElementRotation(thePlayer)
		local del = createVehicle(541,x,y,z) 
		local dimen = getElementDimension(thePlayer)
		setElementDimension(del,dimen)
		setElementRotation(del,rx,ry,rz)
		warpPedIntoVehicle(thePlayer,del,0)
		setVehicleEngineState(del,true)
		setVehicleDamageProof(del,true)
		setVehicleColor(del,200,200,200,67,64,64)
		setVehicleOverrideLights(del,1)
	end
end

function spawndel3(thePlayer)
	if not isPedInVehicle(thePlayer) then
		local x,y,z = getElementPosition(thePlayer)
		local rx,ry,rz = getElementRotation(thePlayer)
		local del = createVehicle(467,x,y,z) 
		local dimen = getElementDimension(thePlayer)
		setElementDimension(del,dimen)
		setElementRotation(del,rx,ry,rz)
		warpPedIntoVehicle(thePlayer,del,0)
		setVehicleEngineState(del,true)
		setVehicleDamageProof(del,true)
		setVehicleColor(del,200,200,200,67,64,64)
		setVehicleOverrideLights(del,1)
	end
end

function spawndel4(thePlayer)
	if not isPedInVehicle(thePlayer) then
		local x,y,z = getElementPosition(thePlayer)
		local rx,ry,rz = getElementRotation(thePlayer)
		local del = createVehicle(415,x,y,z) 
		local dimen = getElementDimension(thePlayer)
		setElementDimension(del,dimen)
		setElementRotation(del,rx,ry,rz)
		warpPedIntoVehicle(thePlayer,del,0)
		setVehicleEngineState(del,true)
		setVehicleDamageProof(del,true)
		setVehicleColor(del,200,200,200,67,64,64)
		setVehicleOverrideLights(del,1)
	end
end

local scoresRoot = getResourceRootElement(getThisResource())
local scoreColumns = {"Year"}
local isColumnActive = {}

function setScoreData (element,column,data)
	if isColumnActive[column] then
		setElementData(element,column,data)
	end
end

at = {}
local function resetScores (element)
	at[element] = setTimer(function()
		if isElement(element) then
			local years = getElementDimension(element)
			if years == 0 then
				setScoreData(element,"Year","1885")
			elseif years == 1 then
				setScoreData(element,"Year","1955")
			elseif years == 2 then
				setScoreData(element,"Year","1985")
			elseif years == 3 then
				setScoreData(element,"Year","2015")
			else
				setScoreData(element,"Year","----")
			end
		else
			killTimer(at[element])
		end
	end,50,0)
end

function updateActiveColumns ()
	for i,column in ipairs(scoreColumns) do
		if get(column) then
			isColumnActive[column] = true
			exports.scoreboard:addScoreboardColumn(column)
		elseif isColumnActive[column] then
			isColumnActive[column] = false
			exports.scoreboard:removeScoreboardColumn(column)
		end
	end
end

addEventHandler("onResourceStart",scoresRoot,function ()
	updateActiveColumns()
	for i,player in ipairs(getElementsByType("player")) do
		resetScores(player)
	end
end)

addEventHandler("onResourceStop",scoresRoot,function ()
	for i,column in ipairs(scoreColumns) do
		if isColumnActive[column] then
			exports.scoreboard:removeScoreboardColumn(column)
		end
	end
end)

addEventHandler("onPlayerJoin",root,function ()
	resetScores(source)
end)