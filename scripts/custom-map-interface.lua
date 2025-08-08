local I = require('openmw.interfaces')
local input = require('openmw.input')
local async = require('openmw.async')
local ui = require('openmw.ui')
local util = require('openmw.util')
local storage = require('openmw.storage')

local vec2 = util.vector2

input.registerTrigger {
    key = 'toggleMap',
    l10n = 'CustomMapInterface',
}

local function makePathSetting(index, default)
	indexStr = tostring(index)
	return {
		key = 'path' .. indexStr,
		renderer = 'textLine',
		name = 'Path to Map ' .. indexStr,
		description = 'The path to the texture for map ' .. indexStr,
		default = default,
	}
end

I.Settings.registerPage {
    key = 'CustomMapInterfacePage',
    l10n = 'CustomMapInterface',
    name = 'Custom Map Interface',
    description = 'Custom Map Interface adds an interface to view custom maps.',
}

I.Settings.registerGroup {
    key = 'SettingsPlayerCustomMapInterface',
    page = 'CustomMapInterfacePage',
    l10n = 'CustomMapInterface',
    name = 'Settings',
    description = 'Settings for Custom Map Interface',
    permanentStorage = true,
    settings = {
		{
            key = 'toggleMap',
            renderer = 'inputBinding',
            name = 'Toggle Map',
            description = 'This is the control that opens and closes the map',
            default = "M",
			argument = {key = 'toggleMap', type = 'trigger'},
        },
        {
            key = 'zoomSpeed',
            renderer = 'number',
            name = 'Zoom Speed',
            description = 'This is the speed that the map zooms in and out at. Minimum: 1, Maximum: 100',
			default = 30,
            argument = {integer = true, min = 1, max = 100},
        },
		{
            key = 'invertScroll',
            renderer = 'checkbox',
            name = 'Invert Zoom Scroll',
            description = 'This inverts the scroll direction when using the mouse scroll wheel to zoom. By default scrolling up zooms in.',
            default = false,
        },
		{
            key = 'relativeZoom',
            renderer = 'checkbox',
            name = 'Mouse Relative Zoom',
            description = 'This makes the zoom center around the mouse cursor. This may not work well with touch inputs.',
            default = false,
        },
		{
            key = 'moveSpeed',
            renderer = 'number',
            name = 'Map Move Speed',
            description = 'This is the speed in pixels that the map will move at when using the movement keys. Minimum: 1, Maximum: 500',
            default = 10,
			argument = {integer = true, min = 1, max = 500},
        },
		makePathSetting(1, ''),
		makePathSetting(2, ''),
		makePathSetting(3, ''),
		makePathSetting(4, ''),
		makePathSetting(5, ''),
		makePathSetting(6, ''),
		makePathSetting(7, ''),
		makePathSetting(8, ''),
		makePathSetting(9, ''),
    },
}

local settingsSection = storage.playerSection('SettingsPlayerCustomMapInterface')

local mousePosition = vec2(0, 0)
local mouseOffset = vec2(0, 0)
local screenSize = ui.screenSize()
local imageDimension = math.min(screenSize.x, screenSize.y) * 0.9
local imageSize = vec2(imageDimension, imageDimension)
local center = screenSize / 2

local currentMapIndex = 1
local mapIsVisible = false

local settings
local invertScroll
local images = {}
local positions
local sizes
local paths

local function init()
	for i, image in pairs(images) do
		image:destroy()
	end
	
	settings = settingsSection:asTable()
	invertScroll = settings.invertScroll and -1 or 1
	
	images = {}
	positions = {}
	sizes = {}
	paths = {}
	
	for i = 1, 9 do
		local path = settings['path' .. tostring(i)]
		if not path or path == "" then goto continue end
		paths[i] = path
		positions[i] = center
		sizes[i] = imageSize

		local image
		image = ui.create {
			layer = "Windows",
			type = ui.TYPE.Image,
			props = {
				visible = false,
				size = imageSize,
				anchor = vec2(0.5, 0.5),
				position = center,
				resource = ui.texture {
					path = path,
				},
			},
			events = {
				mousePress = async:callback(function(mouseEvent)
					if not mouseEvent then return end
					mousePosition = mouseEvent.position
				end),
				mouseMove = async:callback(function(mouseEvent)
					mouseOffset = mouseEvent.offset
					if not mouseEvent.button then return end
					local change = mouseEvent.position - mousePosition
					mousePosition = mouseEvent.position
					image.layout.props.position = image.layout.props.position + change
					image:update()
					positions[i] = image.layout.props.position
				end),
			},
		}
		images[i] = image
		::continue::
	end
end

init()

settingsSection:subscribe(async:callback(init))

local function setVisibility(image, visible)
	image.layout.props.visible = visible
	image:update()
end

local function toggleMap()
	local mode = I.UI.getMode()
	if mode and mode ~= "Interface" then return end
	mapIsVisible = not mapIsVisible
	setVisibility(images[currentMapIndex], mapIsVisible)
	if mapIsVisible then
		I.UI.setMode("Interface", {windows = {}})
	else
		I.UI.setMode()
	end
end

input.registerTriggerHandler('toggleMap', async:callback(toggleMap))

local function switchMap(index)
	if not mapIsVisible or images[index] == nil then return end
	setVisibility(images[currentMapIndex], false)
	currentMapIndex = index
	setVisibility(images[currentMapIndex], true)
end

for i = 1, 9 do
	strI = tostring(i)
	input.registerTriggerHandler('QuickKey' .. strI, async:callback(function() switchMap(i) end))
end

local function zoomMap(zoomDirection)	
	if not mapIsVisible then return end
	local zoomFactor =  math.pow(2, zoomDirection * settings.zoomSpeed * invertScroll * 0.001)
	if settings.relativeZoom then
		positions[currentMapIndex] = positions[currentMapIndex] - (mouseOffset - sizes[currentMapIndex] / 2) * (zoomFactor - 1)
	end
	sizes[currentMapIndex] = sizes[currentMapIndex] * zoomFactor
	local map = images[currentMapIndex]
	map.layout.props.position = positions[currentMapIndex]
	map.layout.props.size = sizes[currentMapIndex]
	map:update()
end

input.registerActionHandler('Zoom3rdPerson', async:callback(function(zoomDirection) zoomMap(zoomDirection) end))

return {
	engineHandlers = {
		onSave = function()
			return {
				currentMapIndex = currentMapIndex,
				positions = positions,
				sizes = sizes,
			}
		end,
		
		onLoad = function(data)
			if not data then return end
			currentMapIndex = data.currentMapIndex
			positions = data.positions
			sizes = data.sizes
			for i, image in ipairs(images) do
				image.layout.props.size = sizes[i]
				image.layout.props.position = positions[i]
				image:update()
			end
		end,
		
		onFrame = function()
			if not mapIsVisible then return end
			local vertical = input.getRangeActionValue('MoveBackward') - input.getRangeActionValue('MoveForward')
			local horizontal = input.getRangeActionValue('MoveRight') - input.getRangeActionValue('MoveLeft')
			positions[currentMapIndex] = positions[currentMapIndex] + vec2(horizontal, vertical) * settings.moveSpeed
			local map = images[currentMapIndex]
			map.layout.props.position = positions[currentMapIndex]
			map:update()
		end,
	},
	
	eventHandlers = {
		UiModeChanged = function(data)
			if data.oldMode ~= "Interface" then return end
			mapIsVisible = false
			setVisibility(images[currentMapIndex], false)
		end,
	},
}
