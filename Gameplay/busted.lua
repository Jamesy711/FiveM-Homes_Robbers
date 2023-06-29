RegisterNetEvent("burglary:finished")

CreateThread(function()
	while true do
		Wait(0)
		
		if onMission then
			local door = doors[lastDoor].coords
			
			-- Time up
			if TimeToSeconds(GetClockTime()) > TimeToSeconds(5, 30, 0) then
				-- Still in the house
				if GetCurrentHouse() then
					-- We'll get em next time
					ShowMPMessage("~r~Burglary failed", "You didn't leave the house before daylight.", 3500)
					TriggerServerEvent("burglary:ended", true, true, lastDoor, GetStreet(door.x, door.y, door.z))
				else
					-- player made it before time
					TriggerServerEvent("burglary:ended", false)
				end
				
				ForceEndMission()
			end
	
			if CanPedHearPlayer(PlayerId(), peds[1]) then
				ShowMPMessage("~r~Burglary failed", "You woke up a resident.", 3500)
				TriggerServerEvent("burglary:ended", true, true, lastDoor, GetStreet(door.x, door.y, door.z))
				
				ClearPedTasks(peds[1])
				PlayPain(peds[1], 7, 0)
				
				-- Resident aggresive
				if HasPedGotWeapon(peds[1], GetHashKey("WEAPON_PISTOL"), false) then
					SetCurrentPedWeapon(peds[1], GetHashKey("WEAPON_PISTOL"), true)
					
					TaskShootAtEntity(peds[1], PlayerPedId(), -1, 2685983626)
				end
				
				ForceEndMission()
			end
			
			if IsPedCuffed(PlayerPedId()) then
				ShowMPMessage("~r~Burglary failed", "You got arrested.", 3500)
				TriggerServerEvent("burglary:ended", true, false)
				
				ForceEndMission()
			end
			
			--Mission if player is dead
            if IsPedDeadOrDying(PlayerPedId()) then
				TriggerServerEvent("burglary:ended", true, false)
				
				ForceEndMission()
			end
		end
	end
end)

function ForceEndMission()
	if isHolding then
		DetachEntity(holdingProp)
	end
	
	-- lot of cleanup
	isHolding = false
	holdingProp = nil
	
	stolenItems = {}
	currentItem = {}
	
	-- reset anim
	ClearPedTasks(PlayerPedId())
	SetPedCanSwitchWeapon(PlayerPedId(), not isHolding)
	
	onMission = false
	SetVehicleAsNoLongerNeeded(NetToVeh(currentVan))
	
	RemoveBlips()
	RemovePickups()
end

AddEventHandler("burglary:finished", function(sum)
	ShowMPMessage("~g~Burglary successful", "You sold all your items for a value of $" .. sum, 9000)
end)