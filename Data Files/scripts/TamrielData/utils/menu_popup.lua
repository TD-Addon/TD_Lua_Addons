local core = require('openmw.core')

if core.API_REVISION < 39 then
    return
end

local async = require('openmw.async')
local I = require('openmw.interfaces')
local ui = require('openmw.ui')
local util = require('openmw.util')

local function spacer(padding)
    if type(padding) == 'number' then
        padding = util.vector2(padding, padding)
    end
    return {
        props = {
            size = padding
        }
    }
end

local function popup(title, message)
    local omwl10n = core.l10n('Interface')
    local padding = util.vector2(5, 5)
    local width = util.vector2(380, 0)
    local element
    local function close()
        element:destroy()
    end
    element = ui.create({
        type = ui.TYPE.Image,
        layer = 'Popup',
        props = {
            relativeSize = util.vector2(1.0, 1.0),
            anchor = util.vector2(0.5, 0.5),
            relativePosition = util.vector2(0.5, 0.5)
        },
        content = ui.content({
            {
                type = ui.TYPE.Image,
                props = {
                    relativeSize = util.vector2(1.0, 1.0),
                    resource = ui.texture({ path = 'white' }),
                    alpha = 0.0,
                }
            },
            {
                template = I.MWUI.templates.boxTransparentThick,
                props = {
                    anchor = util.vector2(0.5, 0.5),
                    relativePosition = util.vector2(0.5, 0.5)
                },
                content = ui.content({
                    {
                        type = ui.TYPE.Container,
                        props = {
                            relativePosition = util.vector2(1, 1),
                            size = width + padding * 2,
                        },
                        content = ui.content({
                            {
                                type = ui.TYPE.Flex,
                                props = {
                                    position = padding
                                },
                                content = ui.content({
                                    {
                                        template = I.MWUI.templates.textParagraph,
                                        props = {
                                            size = width,
                                            text = title,
                                            textAlignH = ui.ALIGNMENT.Center,
                                            textColor = I.MWUI.templates.textHeader.props.textColor
                                        }
                                    },
                                    {
                                        template = I.MWUI.templates.textParagraph,
                                        props = {
                                            size = width,
                                            text = message
                                        }
                                    },
                                    spacer(padding),
                                    {
                                        type = ui.TYPE.Flex,
                                        props = {
                                            size = width,
                                            align = ui.ALIGNMENT.Center,
                                            arrange = ui.ALIGNMENT.Center,
                                        },
                                        content = ui.content({
                                            {
                                                template = I.MWUI.templates.box,
                                                events = {
                                                    mouseClick = async:callback(close),
                                                    focusGain = async:callback(function(e, thisObject)
                                                        thisObject.content[1].content[1].content.okButtonTextWidget.props.textColor =
                                                            I.MWUI.templates.textHeader.props.textColor
                                                        if element ~= nil then
                                                            element:update()
                                                        end
                                                    end),
                                                    focusLoss = async:callback(function(e, thisObject)
                                                        thisObject.content[1].content[1].content.okButtonTextWidget.props.textColor =
                                                            I.MWUI.templates.textNormal.props.textColor
                                                        if element ~= nil then
                                                            element:update()
                                                        end
                                                    end),
                                                },
                                                content = ui.content({
                                                    {
                                                        template = I.MWUI.templates.padding,
                                                        content = ui.content({
                                                            {
                                                                type = ui.TYPE.Flex,
                                                                props = {
                                                                    horizontal = true,
                                                                    arrange = ui.ALIGNMENT.Center,
                                                                },
                                                                content = ui.content({
                                                                    spacer(16),
                                                                    {
                                                                        name = "okButtonTextWidget",
                                                                        template = I.MWUI.templates.textNormal,
                                                                        props = {
                                                                            text = omwl10n('OK'),
                                                                        },
                                                                    },
                                                                    spacer(16)
                                                                })
                                                            }
                                                        }),
                                                    },
                                                }),
                                            }
                                        })
                                    },
                                    spacer(padding)
                                })
                            }
                        })
                    }
                })
            },
        })
    })
    return element
end

return {
    popup = popup
}