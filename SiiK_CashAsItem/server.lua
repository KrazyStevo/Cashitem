local QBCore = exports['qb-core']:GetCoreObject()

local syncing = {}

local function getCashItemCount(Player)
    if not Player then return 0 end
    local item = Player.Functions.GetItemByName(Config.CashItem)
    return item and item.amount or 0
end

local function setPlayerCash(Player, amount, reason)
    local src = Player.PlayerData.source
    local current = Player.PlayerData.money.cash or 0
    local delta = amount - current
    if delta == 0 then return end

    syncing[src] = true
    if delta > 0 then
        Player.Functions.AddMoney('cash', delta, reason or 'cashitem-sync')
    else
        Player.Functions.RemoveMoney('cash', math.abs(delta), reason or 'cashitem-sync')
    end
    syncing[src] = nil
end

local function setCashItem(Player, amount)
    local src = Player.PlayerData.source
    local current = getCashItemCount(Player)
    local delta = amount - current
    if delta == 0 then return end

    syncing[src] = true
    if delta > 0 then
        Player.Functions.AddItem(Config.CashItem, delta)
    else
        Player.Functions.RemoveItem(Config.CashItem, math.abs(delta))
    end
    syncing[src] = nil
end

AddEventHandler('QBCore:Server:OnPlayerLoaded', function(Player)
    if Config.ItemIsTruthOnLoad then
        setPlayerCash(Player, getCashItemCount(Player), 'cashitem-load')
    else
        setCashItem(Player, Player.PlayerData.money.cash or 0)
    end
end)

AddEventHandler('QBCore:Server:OnMoneyChange', function(src, moneyType)
    if moneyType ~= 'cash' then return end
    if syncing[src] then return end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    setCashItem(Player, Player.PlayerData.money.cash or 0)
end)

local function handleInventoryMove()
    local src = source
    SetTimeout(Config.ResyncDelayMs, function()
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            setPlayerCash(Player, getCashItemCount(Player), 'cashitem-inv-sync')
        end
    end)
end

for _, ev in ipairs(Config.InventoryMoveEvents) do
    RegisterNetEvent(ev, handleInventoryMove)
end

QBCore.Commands.Add('fixcashitem', 'Resync cash from item', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        setPlayerCash(Player, getCashItemCount(Player), 'cashitem-fix')
    end
end, 'user')
