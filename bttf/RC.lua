local function fVehicleBind( uPlayer )
	if isElement( uPlayer ) and getElementType( uPlayer ) == 'player' then
	bindKey(uPlayer, 'r','down', startrc)
	bindKey(uPlayer, 'enter_exit','down', startrc)
		return true
	end
	return false
end

local function fVehicleBindManager( )
	if eventName == 'onPlayerJoin' then
		fVehicleBind( source )
	else
		for _, uPlayer in pairs( getElementsByType 'player' ) do
			fVehicleBind( uPlayer )
		end
	end
end
addEventHandler( 'onResourceStart', resourceRoot, fVehicleBindManager )
addEventHandler( 'onPlayerJoin', root, fVehicleBindManager )

function startrc(player,key)
	local car = getElementData(player,"rccar")
	if not isElement(car) then return end
	if key == "r" then
		if getElementData(car,"rcmode") ~= 1 then
			setElementData(car,"rcmode",1)
			setElementData(player,"rcmode",1)
			if isPedInVehicle(player) then
				removePedFromVehicle(player)
			end
			warpPedIntoVehicle(player,car)
			setElementAlpha(player,0)
			local x,y,z = getElementPosition(player)
			local rx,ry,rz = getElementRotation(player)
			local rcped = createPed(getElementModel(player),x,y,z,rz)
			setElementDimension(rcped,getElementDimension(player))
			setElementHealth(rcped,getElementHealth(player))
			setElementData(player,"rcped",rcped)
		end
	end
	if key == "enter_exit" then
		if getElementData(player,"rcmode") == 1 then
			setElementData(car,"rcmode",0)
			setElementData(player,"rcmode",0)
			setElementAlpha(player,255)
			removePedFromVehicle(player)
			local myrcped = getElementData(player,"rcped")
			if isElement(myrcped) then
				local x,y,z = getElementPosition(myrcped)
				local rx,ry,rz = getElementRotation(myrcped)
				destroyElement(myrcped)
				setElementPosition(player,x,y,z)
				setElementRotation(player,rx,ry,rz)
			end
			setPedAnimation(player)
		end
	end
end

function rcar(thePlayer)
	if getPedOccupiedVehicleSeat ( thePlayer ) == 0 and getElementType(thePlayer) == "player" then
		local car = getPedOccupiedVehicle ( thePlayer )
		local id = getElementModel ( car )
		if id == 541 or id == 488 or id == 466 or id == 467 or id == 415 then
			if getElementData(thePlayer,"rcmode") ~= 1 then
				setElementData(thePlayer,"rccar",car)
				setElementData(car,"rcmode",0)
			end
		end
	end
end
addEventHandler("onVehicleEnter",getRootElement(),rcar)

function noFuckOut(player)
if getElementData(player,"rcmode") == 1 then
cancelEvent()
end
end
addEventHandler("onVehicleStartExit",root,noFuckOut)

addEventHandler("onResourceStop",getResourceRootElement(getThisResource()),function()
for k,player in ipairs(getElementsByType("player")) do
	setElementData(player,"rcmode",0)
	setElementData(player,"rccar",false)
end
end)

function BTTF_SetPlayerRC(player,bool)
	local car = getElementData(player,"rccar")
	if not isElement(car) then return false end
	if getElementData(car,"rcmode") ~= 1 and bool == true then
		setElementData(car,"rcmode",1)
		setElementData(player,"rcmode",1)
		if isPedInVehicle(player) then
			removePedFromVehicle(player)
		end
		warpPedIntoVehicle(player,car)
		setElementAlpha(player,0)
		local x,y,z = getElementPosition(player)
		local rx,ry,rz = getElementRotation(player)
		local rcped = createPed(getElementModel(player),x,y,z,rz)
		setElementDimension(rcped,getElementDimension(player))
		setElementHealth(rcped,getElementHealth(player))
		setElementData(player,"rcped",rcped)
	else
		setElementData(car,"rcmode",0)
		setElementData(player,"rcmode",0)
		setElementAlpha(player,255)
		removePedFromVehicle(player)
		local myrcped = getElementData(player,"rcped")
		if isElement(myrcped) then
			local x,y,z = getElementPosition(myrcped)
			local rx,ry,rz = getElementRotation(myrcped)
			setElementHealth(player,getElementHealth(myrcped))
			destroyElement(myrcped)
			setElementPosition(player,x,y,z)
			setElementRotation(player,rx,ry,rz)
		end
		setPedAnimation(player)
	end
end

addEventHandler("onPlayerWasted",root,function()
	if getElementData(source,"rcmode") == 1 then
		BTTF_SetPlayerRC(source,false)
	end
end)