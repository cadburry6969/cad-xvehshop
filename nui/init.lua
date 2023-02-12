-- MENU UI
function openMenu(data)
    if not data then return end
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'OPEN_MENU',
        data = data
    })
end

function closeMenu()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'CLOSE_MENU'
    })
end

RegisterNUICallback('menuPressed', function(data)
    PlaySoundFrontend(-1, 'Highlight_Cancel','DLC_HEIST_PLANNING_BOARD_SOUNDS', 1)
    SetNuiFocus(false, false)
    if data.serverevent then
        TriggerServerEvent(data.serverevent, data.args)
    elseif data.event then
        TriggerEvent(data.event, data.args)
    elseif data.command then
        ExecuteCommand(data.command)
    end
end)

RegisterNUICallback('closeMenu', function()
    SetNuiFocus(false, false)
end, false)

-- TEXT UI
function showText(button, message)
    SendNUIMessage({
        action = 'OPEN_TEXTUI',
        button = button,
        text = message
    })
end

function hideText()
    SendNUIMessage({
        action = 'CLOSE_TEXTUI',
    })
end