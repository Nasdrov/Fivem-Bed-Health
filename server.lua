ESX = nil
local playersHealing = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterServerCallback('pillbox:buy', function(source, cb, vehicleProps, type)
    local xPlayer = ESX.GetPlayerFromId(source)
    local price = 100
    
	if(xPlayer.getMoney() >= price) then
        xPlayer.removeMoney(price)
        cb(true)
	else
        TriggerClientEvent('esx:showNotification', source, ("Not enough ~r~Money"))
        cb(false)
	end
end)