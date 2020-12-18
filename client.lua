local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil

local InAction = false
local isInShopMenu = false
local Test = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
    while true do

        Citizen.Wait(10)

        for i=1, #Config.BedList do
            local bedID   = Config.BedList[i]
            local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), bedID.objCoords.x, bedID.objCoords.y, bedID.objCoords.z, true)

            if distance < Config.MaxDistance and InAction == false and Test == false then
                --ESX.Game.Utils.DrawText3D({ x = bedID.objCoords.x, y = bedID.objCoords.y, z = bedID.objCoords.z + 1 }, bedID.text, 0.6)
                ESX.ShowHelpNotification("~INPUT_PICKUP~ pour vous soignez")
                if IsControlJustReleased(0, Keys['E']) then
                    OpenMenu()
                end
            end
        end
    end
end)

----- Menu
function OpenMenu()
    Test = true
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'actions_bads', {
		title    = ('Urgences'),
		align    = 'top-left',
		elements = {
			{label = ('Soins Rapides 30$'), value = 'actions_bads'},
		}
    }, 
    
    function(data, menu)
        
        if data.current.value == 'actions_bads' then
            ESX.UI.Menu.Open(
                'default', GetCurrentResourceName(), 'menu',
                {
                    title    = ('Confirmez'),
                    elements = {
                        {label = ('Oui'), value = 'yes',price = Config.price},
                        { label = ('Non'), value = 'no' }
                    }
                },
                function(data, menu)
                    if data.current.value == 'yes' then
                        local price = data.current.price               
                        ESX.TriggerServerCallback('pillbox:buy',function(bought)
                            for i=1, #Config.BedList do
                                local bedID   = Config.BedList[i]
                                local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), bedID.objCoords.x, bedID.objCoords.y, bedID.objCoords.z, true)
                                if distance < Config.MaxDistance and InAction == false then
                                    --ESX.Game.Utils.DrawText3D({ x = bedID.objCoords.x, y = bedID.objCoords.y, z = bedID.objCoords.z + 1 }, bedID.text, 0.6)
                                    if bought then
                                        bedActive(bedID.objCoords.x, bedID.objCoords.y, bedID.objCoords.z, bedID.heading, bedID)
                                        ESX.UI.Menu.CloseAll()
                                    else
                                        ESX.UI.Menu.CloseAll()
                                    end
                                end
                            end
                        end)
                    else
                        ESX.UI.Menu.CloseAll()
                    end
                end,function(data, menu)
                ESX.UI.Menu.CloseAll()
            end)
        else
            ESX.UI.Menu.CloseAll()
        end
    end,function(data, menu)
		ESX.UI.Menu.CloseAll()
    end)
    Test = false
end

function bedActive(x, y, z, heading)

    SetEntityCoords(GetPlayerPed(-1), x, y, z + 0.3)
    RequestAnimDict('missfbi5ig_0')
    while not HasAnimDictLoaded('missfbi5ig_0') do
        Citizen.Wait(0)
    end
    TaskPlayAnim(GetPlayerPed(-1), 'missfbi5ig_0' , 'lyinginpain_loop_steve' ,8.0, -8.0, -1, 1, 0, false, false, false )

    SetEntityHeading(GetPlayerPed(-1), heading + 180.0)

    InAction = true

	Citizen.CreateThread(function ()
	    Citizen.Wait(10)
	    local health = GetEntityHealth(PlayerPedId())

	    if (health < 200)  then
        TriggerEvent('esx:showNotification', '~g~Traitement en cours...');
        TriggerEvent('pogressBar:drawBar', 20000, 'Soins intensifs en cours...') 
        Citizen.Wait(20000)
		if InAction == true then
		    while InAction == true do
			Citizen.Wait(1000)
            SetEntityHealth(PlayerPedId(), 200)
            TriggerEvent('esx:showNotification', '~g~Vous pouvez vous levez');
		    end
		end

	    elseif (health == 200) then
		TriggerEvent('esx:showNotification', '~r~Vous avez pas besoin de soins'); 
	    end
	end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            local health = GetEntityHealth(PlayerPedId())
            if InAction == true then
                DrawSub('~g~X~w~ Pour vous levez')
                if IsControlJustReleased(0, Keys['X']) then
                    ClearPedTasks(GetPlayerPed(-1))
                    FreezeEntityPosition(GetPlayerPed(-1), false)
                    SetEntityCoords(GetPlayerPed(-1), x + 1.0, y, z)
                    SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) + 0)
                    InAction = false 
                end
            end
        end
    end)
end

--[[
Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1)
            if InAction then
                local playerPed = PlayerPedId()
                DisableControlAction(0, 24, true) -- Attack
                DisableControlAction(0, 257, true) -- Attack 2
                DisableControlAction(0, 25, true) -- Aim
                DisableControlAction(0, 263, true) -- Melee Attack 1
                DisableControlAction(0, Keys["W"], true) -- W
                DisableControlAction(0, Keys["A"], true) -- A
                DisableControlAction(0, 31, true) -- S (fault in Keys table!)
                DisableControlAction(0, 30, true) -- D (fault in Keys table!)
                DisableControlAction(0, Keys["R"], true) -- Reload
                DisableControlAction(0, Keys["SPACE"], true) -- Jump
                DisableControlAction(0, Keys["Q"], true) -- Cover
                DisableControlAction(0, Keys["TAB"], true) -- Select Weapon
                DisableControlAction(0, Keys["F"], true) -- Also 'enter'?
                DisableControlAction(0, Keys["F1"], true) -- Disable phone
                DisableControlAction(0, Keys["F2"], true) -- Inventory
                DisableControlAction(0, Keys["F3"], true) -- Animations
                DisableControlAction(0, Keys["F6"], true) -- Job
                DisableControlAction(0, Keys["V"], true) -- Disable changing view
                DisableControlAction(0, Keys["C"], true) -- Disable looking behind
                DisableControlAction(2, Keys["P"], true) -- Disable pause screen
                DisableControlAction(0, 59, true) -- Disable steering in vehicle
                DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
                DisableControlAction(0, 72, true) -- Disable reversing in vehicle
                DisableControlAction(2, Keys["LEFTCTRL"], true) -- Disable going stealth
                DisableControlAction(0, 47, true) -- Disable weapon
                DisableControlAction(0, 264, true) -- Disable melee
                DisableControlAction(0, 257, true) -- Disable melee
                DisableControlAction(0, 140, true) -- Disable melee
                DisableControlAction(0, 141, true) -- Disable melee
                DisableControlAction(0, 142, true) -- Disable melee
                DisableControlAction(0, 143, true) -- Disable melee
                DisableControlAction(0, 75, true) -- Disable exit vehicle
                DisableControlAction(27, 75, true) -- Disable exit vehicle
            end
        end
    end
)
]]--
-- แบบตัวหนังสือกลางจอ
--[[
function DrawSub(msg, time)
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(msg)
    DrawSubtitleTimed(time, 1)
end]]


function DrawSub(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

RegisterFontFile('font4thai') 

-------------------------------------------------------------------------------------------------------------------------
function Draw3DText(x,y,z,textInput,fontId,scaleX,scaleY)
         local px,py,pz=table.unpack(GetGameplayCamCoords())
         local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)    
         local scale = (1/dist)*20
         local fov = (1/GetGameplayCamFov())*100
         local scale = scale*fov 
         local fontId = RegisterFontId('font4thai')	
	     RegisterFontFile('font4thai') 	 
         SetTextScale(scaleX*scale, scaleY*scale)
         SetTextFont(fontId)
         SetTextProportional(1)
         SetTextColour(250, 250, 250, 255)		
         SetTextDropshadow(1, 1, 1, 1, 255)
         SetTextEdge(2, 0, 0, 0, 150)
         SetTextDropShadow()
         SetTextOutline()
         SetTextEntry("STRING")
         SetTextCentre(1)
         AddTextComponentString(textInput)
         SetDrawOrigin(x,y,z+2, 0)
         DrawText(0.0, 0.0)
         ClearDrawOrigin()
end