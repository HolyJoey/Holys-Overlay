-- Made by holyjoey.
-- Credits to:
-- Murten#0001: His code as a base (https://github.com/Murten101/stand-lua_imGUI)
-- Sapphire#6031: Memory pools
-- SoulReaper#2005: Helped me with some examples + my autism

util.require_natives(1663599433)
UI = {}

--folders
local info_root = menu.list(menu.my_root(), 'Info Overlay', {}, '')
local info_toggles = menu.list(info_root, 'Info Overlay Toggles', {}, '')
local info_pos = menu.list(info_root, 'Info Overlay Position', {}, '')
local player_overlay = menu.list(menu.my_root(), 'Players Overlay', {}, '')
local player_pos = menu.list(player_overlay, 'Players Overlay Position', {}, '')
local overlay_colour = menu.list(menu.my_root(), 'Overlay Colour', {}, '')

local infoTitle = SOCIALCLUB.SC_ACCOUNT_INFO_GET_NICKNAME()

UI.new = function()
    -- PRIVATE VARIABLES
    local self = {}

    background_colour = {
        ["r"] = 0.1,
        ["g"] = 0.1,
        ["b"] = 0.1,
        ["a"] = 1
    }

    --gray colour for the header
    gray_colour = {
        ["r"] = 0.2,
        ["g"] = 0.2,
        ["b"] = 0.2,
        ["a"] = 1
    }

    -- text colour
    text_colour = {
        ["r"] = 1.0,
        ["g"] = 1.0,
        ["b"] = 1.0,
        ["a"] = 1.0
    }

    local highlight_colour = {r=1,g=0,b=0,a=1}
    menu.rainbow(
        menu.colour(overlay_colour, "Overlay Colour", {"overlaycolour"}, "", highlight_colour, true, function(val)
            highlight_colour = val
        end)
    )

    local plain_text_size = 0.5
    local subhead_text_size = 0.6

    local horizontal_temp_width = 0
    local horizontal_temp_height = 0

    local cursor_mode = false

    local temp_container = {}

    local temp_x, temp_y = 0,0

    local current_window = {}

    local windows = {}

    local tab_containers = {}

    local function get_aspect_ratio()
        local screen_x, screen_y = directx.get_client_size()

        return screen_x / screen_y
    end

    local function UI_update()
        cursor_pos = {x = PAD.GET_DISABLED_CONTROL_NORMAL(2, 239), y = PAD.GET_DISABLED_CONTROL_NORMAL(2, 240)}
        directx.draw_texture(cursor_texture, 0.004, 0.004, 0.5, 0, cursor_pos.x, cursor_pos.y, 0, text_colour)
        return cursor_mode
    end

    -- get an if an area is overlapping with the center of the screen
    local function get_overlap_with_rect(width, height, rect_x, rect_y, cursor_pos)
        if rect_x <= cursor_pos.x and rect_x + width >= cursor_pos.x then
            if rect_y <= cursor_pos.y and rect_y + height >= cursor_pos.y then
                return true
            end
        else
            return false
        end
    end

    local function draw_collapse_button(x_pos, y_pos, size, dir)
        size = size or 1
        local button_size = {x = 0.005 * dir, y = 0.005}
        local aspect_ratio = get_aspect_ratio()
        if aspect_ratio >= 1 then
            button_size.y = button_size.y * aspect_ratio
        else
            button_size.x = button_size.x * aspect_ratio
        end
        local half_size = {x = button_size.x * 0.5, y = button_size.y * 0.5}
        if cursor_mode then
            if get_overlap_with_rect(button_size.x + 0.01, button_size.y + 0.01,x_pos - button_size.x * 0.5 - 0.005, y_pos - button_size.y * 0.5 - 0.005, cursor_pos) then
                directx.draw_triangle(x_pos + half_size.x * size, y_pos, x_pos - half_size.x * size, y_pos  + half_size.y * size, x_pos - half_size.x * size, y_pos - half_size.y * size, highlight_colour)
                return PAD.IS_CONTROL_JUST_PRESSED(2, 18)
           end
        end
        directx.draw_triangle(x_pos + half_size.x * size, y_pos, x_pos - half_size.x * size, y_pos  + half_size.y * size, x_pos - half_size.x * size, y_pos - half_size.y * size, text_colour) 
    end

    local function draw_tabs(tab_count)
        local aspect_ratio = get_aspect_ratio()

        if not current_window.tabs_collapsed then
            local button_size = {x = 0.06, y = 0.015}
            if aspect_ratio >= 1 then
                button_size.y = button_size.y * aspect_ratio
            else
                button_size.x = button_size.x * aspect_ratio
            end
            local drawpos = {x = current_window.x - button_size.x - 0.005, y = current_window.y - 0.004}
            directx.draw_rect(drawpos.x, drawpos.y, button_size.x, current_window.height + 0.008, background_colour)
            directx.draw_rect(drawpos.x, drawpos.y, button_size.x, button_size.y - 0.002, gray_colour)
            if draw_collapse_button(drawpos.x + 0.0075, drawpos.y + button_size.y *0.5, 1.25, 1) then
                current_window.tabs_collapsed = true
            end
            directx.draw_text(drawpos.x + button_size.x * 0.5,current_window.y + button_size.y * 0.5 - 0.004, "tabs", ALIGN_CENTRE, 0.5, text_colour)
                for i = 1, tab_count, 1 do
                    local button_drawpos = {x = drawpos.x, y = drawpos.y + (i) * button_size.y}
                    if cursor_mode then
                        if get_overlap_with_rect( button_size.x, button_size.y, button_drawpos.x, button_drawpos.y, cursor_pos) then
                            directx.draw_rect(button_drawpos.x, button_drawpos.y, button_size.x, button_size.y, highlight_colour)
                            if PAD.IS_CONTROL_JUST_PRESSED(2, 18) then
                                current_window.current_tab = i
                            end
                        else
                            directx.draw_rect(button_drawpos.x, button_drawpos.y, button_size.x, button_size.y, gray_colour)
                        end 
                    else
                        directx.draw_rect(button_drawpos.x, button_drawpos.y, button_size.x, button_size.y, gray_colour)
                    end
                    directx.draw_texture(tabs[i].data.icon, button_size.x * 0.1, button_size.x * 0.1, -0.1, 0.5, button_drawpos.x, button_drawpos.y + button_size.y * 0.5, 0, text_colour)
                    directx.draw_text(button_drawpos.x + (button_size.x * 0.1) * 2, button_drawpos.y + button_size.y * 0.5, tabs[i].data.title, ALIGN_CENTRE_LEFT, 0.5, text_colour, false)
                end
            else
                local button_size = {x = 0.015, y = 0.015}
                if aspect_ratio >= 1 then
                    button_size.y = button_size.y * aspect_ratio
                else
                    button_size.x = button_size.x * aspect_ratio
                end
                local drawpos = {x = current_window.x - button_size.x - 0.005, y = current_window.y - 0.004}
                directx.draw_rect(drawpos.x, drawpos.y, button_size.x, current_window.height + 0.008, background_colour)
                directx.draw_rect(drawpos.x, drawpos.y, button_size.x, button_size.y - 0.002, gray_colour)
                if draw_collapse_button(drawpos.x + 0.0075, drawpos.y + button_size.y * 0.5, 1.25, -1) then
                    current_window.tabs_collapsed = false
                end
                    for i = 1, tab_count, 1 do
                        local button_drawpos = {x = drawpos.x, y = drawpos.y + (i) * button_size.y}
                        if cursor_mode then
                            if get_overlap_with_rect( button_size.x, button_size.y, button_drawpos.x, button_drawpos.y, cursor_pos) then
                                directx.draw_rect(button_drawpos.x, button_drawpos.y, button_size.x, button_size.y, highlight_colour)
                                if PAD.IS_CONTROL_JUST_PRESSED(2, 18) then
                                    current_window.current_tab = i
                                end
                            else
                                directx.draw_rect(button_drawpos.x, button_drawpos.y, button_size.x, button_size.y, gray_colour)
                            end 
                        else
                            directx.draw_rect(button_drawpos.x, button_drawpos.y, button_size.x, button_size.y, gray_colour)
                        end
                        directx.draw_texture(tabs[i].data.icon, button_size.x * 0.4, button_size.x * 0.4, -0.1, 0.5, button_drawpos.x, button_drawpos.y + button_size.y * 0.5, 0, text_colour)
                    end
        end


    end

    local function add_with_and_height(width, height, horizontal)
        if not horizontal then
            if width > current_window.width then
                current_window.width = width
            end
            current_window.height = current_window.height + height
        else
            horizontal_temp_width = horizontal_temp_width + width
            if height > horizontal_temp_height then
                horizontal_temp_height = height
            end
        end
    end

    local function draw_container(container)
        for index, data in pairs(container) do
            local type = next(data)
            type(data[type])
        end
    end

    local function draw_text(data)
        if not current_window.horizontal then
            directx.draw_text(temp_x, temp_y, data.text, ALIGN_TOP_LEFT, 0.5, data.colour or text_colour, false)
            temp_y = temp_y + data.height
        else
            directx.draw_text(temp_x, temp_y, data.text, ALIGN_TOP_LEFT, 0.5, data.colour or text_colour, false)
            temp_x = temp_x + data.width
        end
    end

    local function draw_label(data)
        if not current_window.horizontal then
            directx.draw_text(temp_x, temp_y, data.name, ALIGN_TOP_LEFT, 0.5, data.colour or text_colour, false)
            temp_x = temp_x + current_window.width
            directx.draw_text(
                temp_x,
                temp_y,
                data.value,
                ALIGN_TOP_RIGHT,
                0.5,
                data.highlight_colour or highlight_colour,
                false
            )
            temp_x = temp_x - current_window.width
            temp_y = temp_y + data.height
        else
            directx.draw_text(temp_x, temp_y, data.name, ALIGN_TOP_LEFT, 0.5, data.colour or text_colour, false)
            temp_x = temp_x + data.name_width
            directx.draw_text(
                temp_x,
                temp_y,
                data.value,
                ALIGN_TOP_LEFT,
                0.5,
                data.highlight_colour or highlight_colour,
                false
            )
            temp_x = temp_x + data.value_width
        end
    end

    local function draw_div(data)
        if not current_window.horizontal then
            temp_y = temp_y + 0.01
            directx.draw_line(
                temp_x,
                temp_y,
                temp_x + current_window.width,
                temp_y,
                data.highlight_colour or highlight_colour,
                data.highlight_colour or highlight_colour
            )
            temp_y = temp_y + 0.01
        else
            temp_x = temp_x + 0.005
            directx.draw_line(
                temp_x,
                temp_y,
                temp_x,
                temp_y + 0.02,
                data.highlight_colour or highlight_colour,
                data.highlight_colour or highlight_colour
            )
            temp_x = temp_x + 0.005
        end
    end

    local function enable_horizontal(data)
        current_window.horizontal = true
        draw_container(data)
    end

    local function disable_horizontal(data)
        current_window.horizontal = false
        temp_x = temp_x - data.width
        temp_y = temp_y + data.height
    end

    local function draw_subhead(data)
        if not current_window.horizontal then
            directx.draw_text(
                temp_x + current_window.width * 0.5,
                temp_y,
                data.text,
                ALIGN_TOP_CENTRE,
                0.55,
                data.colour or highlight_colour,
                false
            )
            local x, y = directx.get_text_size(data.text, 0.55)
            temp_y = temp_y + y + 0.003
        else
            directx.draw_text(
                temp_x,
                temp_y,
                data.text,
                ALIGN_TOP_LEFT,
                0.55,
                data.colour or highlight_colour,
                false
            )
            temp_x = temp_x + directx.get_text_size(data.text, 0.55)
        end
    end

    local function draw_button(data)
        directx.draw_rect(temp_x, temp_y, data.width, data.height - 0.005, data.colour or highlight_colour)
        directx.draw_text(temp_x - data.padding, temp_y, data.text, ALIGN_TOP_LEFT, 0.5, text_colour)
        if not current_window.horizontal then
            temp_y = temp_y + data.height
        else
            temp_x = temp_x + data.width + (data.padding * 3)
        end
    end

    local function draw_toggle(data)
        directx.draw_rect(temp_x, temp_y, data.button_size.x, data.button_size.y, gray_colour)
        if data.state then
            directx.draw_texture(checkmark_texture, 0.005, 0.005, 0, 0, temp_x, temp_y, 0, text_colour)
        end
        temp_x = temp_x + data.button_size.x
        directx.draw_text(temp_x, temp_y, data.text, ALIGN_TOP_LEFT, 0.5, data.colour)
        if not current_window.horizontal then
            temp_y = temp_y + data.button_size.y + data.padding
            temp_x = temp_x - data.button_size.x
        else
            temp_x = temp_x + data.width + data.padding
        end
    end

    -- SETTERS
    self.set_background_colour = function(r, g, b)
        background_colour = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = 1}
    end
    self.set_highlight_colour = function(r, g, b)
        highlight_colour = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = 1}
    end
    self.set_text_colour = function(r, g, b)
        text_colour = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = 1}
    end
    -- OTHER METHODS

    --enable or disable the cursor
    self.toggle_cursor_mode = function(state)
        if state == nil then
            cursor_mode = not cursor_mode
        else
            cursor_mode = state
        end
        PAD._SET_CURSOR_LOCATION(0.5, 0.5)
        util.create_tick_handler(UI_update)
        if cursor_mode then
            menu.trigger_commands("disablelookud on")
            menu.trigger_commands("disablelooklr on")
            menu.trigger_commands("disableattack on")
            menu.trigger_commands("disableattack2 on")
        else
            menu.trigger_commands("disablelookud off")
            menu.trigger_commands("disablelooklr off")
            menu.trigger_commands("disableattack off")
            menu.trigger_commands("disableattack2 off")
        end
    end

    self.start_tab_container = function (title, x_pos, y_pos, tabs, id)
        local sizex, sizey = directx.get_text_size(title, 0.6)
        local hash = util.joaat(id)
        if tab_containers[hash] ~= nil then
            current_window = tab_containers[hash]
            current_window.open_containers = {}
            current_window.elements = {}
            current_window.active_container = {}
            current_window.horizontal = false
            current_window.height = sizey + 0.02
            temp_y = current_window.y
            temp_x = current_window.x
        else
            current_window ={
                x = x_pos,
                y = y_pos,
                width = sizex + 0.02,
                height = sizey + 0.02,
                largest_height = 0,
                title = title,
                horizontal = false,
                open_containers = {},
                elements = {},
                active_container = {},
                is_being_dragged = false,
                tabs_collapsed = false,
                id = hash,
                current_tab = 1
            }
            tab_containers[hash] = current_window
        end
        current_window.active_container = current_window.elements
        tabs[current_window.current_tab].content()

        self.finish_tab_container()
    end

    self.finish_tab_container = function ()
        --determine if we use calculated height or largest height
        if current_window.height < current_window.largest_height then
            current_window.height = current_window.largest_height
        else
            current_window.largest_height = current_window.height
        end
        --calculate width + tabs
        local tab_width = current_window.tabs_collapsed == true and 0.016 or 0.061
        -- draw border
        directx.draw_rect(
            temp_x - 0.005 - tab_width,
            temp_y - 0.005 - 0.03,
            current_window.width + tab_width + 0.01,
            current_window.height + 0.04,
            highlight_colour
        )
        --draw tabs
        draw_tabs(#tabs)
        -- draw background
        directx.draw_rect(
            temp_x - 0.004,
            temp_y - 0.004,
            current_window.width + 0.008,
            current_window.height + 0.008,
            background_colour
        )
        --draw title bar
        directx.draw_rect(temp_x - tab_width - 0.004, temp_y - 0.004 - 0.03, current_window.width + tab_width + 0.008, 0.03, gray_colour)

        directx.draw_text(
            temp_x + current_window.width  * 0.5,
            temp_y - 0.03,
            current_window.title,
            ALIGN_TOP_CENTRE,
            .6,
            text_colour,
            false
        )

        if cursor_mode then
            if get_overlap_with_rect(current_window.width + tab_width + 0.008, 0.03, temp_x - tab_width - 0.004, temp_y - 0.004 - 0.03, cursor_pos) then
                if PAD.IS_CONTROL_JUST_PRESSED(2, 18) then
                    current_window.is_being_dragged = true
                end
            end
            if PAD.IS_CONTROL_JUST_RELEASED(2, 18) then
                current_window.is_being_dragged = false
            end

            if current_window.is_being_dragged then
                current_window.x = cursor_pos.x - (current_window.width - tab_width) * 0.5
                current_window.y = cursor_pos.y + 0.004 + 0.015
            end
        end

        temp_y = temp_y + 0.03

        draw_container(current_window.elements)

        temp_container = {}
        current_window = {}
    end
    --start a new window
    self.begin = function(title, x_pos, y_pos, Id)
        local sizex, sizey = directx.get_text_size(title, 0.6)
        local hash = util.joaat(Id or title)
            if windows[hash] ~= nil then
                current_window = windows[hash]
                current_window.x = x_pos
                current_window.y = y_pos
                current_window.open_containers = {}
                current_window.elements = {}
                current_window.active_container = {}
                current_window.horizontal = false
                current_window.width = sizex + 0.02
                current_window.height = sizey + 0.02
                current_window.tabs = {}
                temp_y = current_window.y
                temp_x = current_window.x
                --current_window.title = infoTitle
            else
                current_window = {
                    x = x_pos,
                    y = y_pos,
                    width = sizex + 0.02,
                    height = sizey + 0.02,
                    title = title,
                    horizontal = false,
                    open_containers = {},
                    elements = {},
                    active_container = {},
                    is_being_dragged = false,
                    id = hash
                }
                windows[hash] = current_window
            end
        current_window.active_container = current_window.elements
    end

    --start a new window 2. Needed a second one or else the player overlay would get fucked over by changing the title of info overlay
    self.begin2 = function(title, x_pos, y_pos, Id)
        local sizex, sizey = directx.get_text_size(title, 0.6)
        local hash = util.joaat(Id or title)
            if windows[hash] ~= nil then
                current_window = windows[hash]
                current_window.x = x_pos
                current_window.y = y_pos
                current_window.open_containers = {}
                current_window.elements = {}
                current_window.active_container = {}
                current_window.horizontal = false
                current_window.width = sizex + 0.02
                current_window.height = sizey + 0.02
                current_window.tabs = {}
                temp_y = current_window.y
                temp_x = current_window.x
                current_window.title = infoTitle
            else
                current_window = {
                    x = x_pos,
                    y = y_pos,
                    width = sizex + 0.02,
                    height = sizey + 0.02,
                    title = title,
                    horizontal = false,
                    open_containers = {},
                    elements = {},
                    active_container = {},
                    is_being_dragged = false,
                    id = hash
                }
                windows[hash] = current_window
            end
        current_window.active_container = current_window.elements
    end

    --add a text element to the current window
    self.text = function(text, colour)
        text = tostring(text)
        local width, height = directx.get_text_size(text, plain_text_size)
        add_with_and_height(width, height, current_window.horizontal)
        current_window.active_container[#current_window.active_container + 1] = {
            [draw_text] = {text = text, width = width, height = height, colour = colour}
        }
    end

    --add a subhead to the current window
    self.subhead = function(text, colour)
        text = tostring(text)
        local width, height = directx.get_text_size(text, subhead_text_size)
        add_with_and_height(width, height, current_window.horizontal)
        current_window.active_container[#current_window.active_container + 1] = {
            [draw_subhead] = {text = text, width = width, height = height, colour = colour}
        }
    end

    --add a divider to the current window
    self.divider = function(colour)
        current_window.active_container[#current_window.active_container + 1] = {[draw_div] = {colour = colour}}
        add_with_and_height(0.01, 0.02, current_window.horizontal)
    end

    --add a label to the current window (usefull for displaying variables and there value)
    self.label = function(name, value, colour, label_highlight_colour)
        name = tostring(name)
        value = tostring(value)
        local name_x, name_y = directx.get_text_size(name, plain_text_size)
        local value_x = directx.get_text_size(value, plain_text_size)
        local total_x = value_x + name_x
        add_with_and_height(total_x, name_y, current_window.horizontal)
        current_window.active_container[#current_window.active_container + 1] = {
            [draw_label] = {
                name = name,
                value = value,
                name_width = name_x,
                value_width = value_x,
                height = name_y,
                colour = colour,
                highlight_colour = label_highlight_colour
            }
        }
    end

    --adds a button to the current window
    self.button = function(name, colour, button_highlight_colour)
        name = tostring(name)
        local name_width, name_height = directx.get_text_size(name, plain_text_size)
        local padding = 0.001
        name_width, name_height = name_width + padding, name_height + 0.005 + padding
        local clicked = false
        if cursor_mode then
            if
                get_overlap_with_rect(
                    name_width,
                    name_height - (padding * 4),
                    horizontal_temp_width + temp_x,
                    current_window.height + temp_y - name_height * 0.5 + padding * 2,
                    cursor_pos
                )
             then
                colour =
                    button_highlight_colour or
                    {
                        ["r"] = 0.5,
                        ["g"] = 0.0,
                        ["b"] = 0.5,
                        ["a"] = 1
                    }
                if PAD.IS_CONTROL_JUST_PRESSED(2, 18) then
                    clicked = true
                end
            end
        end
        current_window.active_container[#current_window.active_container + 1] = {
            [draw_button] = {
                text = name,
                width = name_width,
                height = name_height,
                colour = colour or highlight_colour,
                padding = padding
            }
        }
        add_with_and_height(name_width + (padding * 3), name_height, current_window.horizontal)
        return clicked
    end

    --adds a toggle to the current menu
    self.toggle = function(name, state, colour, optional_function)
        state = state or false
        colour = colour or text_colour
        name = tostring(name)
        local name_width, name_height = directx.get_text_size(name, plain_text_size)

        local button_size = {x = 0.010, y = 0.010}
        local aspect_ratio = get_aspect_ratio()
        if aspect_ratio >= 1 then
            button_size.y = button_size.y * aspect_ratio
        else
            button_size.x = button_size.x * aspect_ratio
        end

        local padding = 0.005

        if cursor_mode then
            if
                get_overlap_with_rect(
                    button_size.x,
                    button_size.y,
                    horizontal_temp_width + temp_x,
                    current_window.height + temp_y - button_size.y * 0.5,
                    cursor_pos
                )
             then
                if PAD.IS_CONTROL_JUST_PRESSED(2, 18) then
                    state = not state
                    if optional_function ~= nil then
                        optional_function(state)
                    end
                end
            end
        end
        current_window.active_container[#current_window.active_container + 1] = {
            [draw_toggle] = {
                text = name,
                width = name_width,
                height = name_height,
                colour = colour,
                button_size = button_size,
                padding = padding,
                state = state
            }
        }
        add_with_and_height(name_width + button_size.x + padding, button_size.y + padding, current_window.horizontal)
        return state
    end

    --start drawing elements in the horizontal direction
    self.start_horizontal = function()
        if horizontal_temp_width ~= 0 then
            error("new horizontal started without closing previous horizontal", 2)
        end
        current_window.open_containers[#current_window.open_containers + 1] = current_window.active_container
        temp_container = {[enable_horizontal] = {}}
        current_window.active_container = temp_container[enable_horizontal]
        current_window.horizontal = true
    end

    --return to drawing in the diagonal direction
    self.end_horizontal = function()
        current_window.active_container[#current_window.active_container + 1] = {
            [disable_horizontal] = {width = horizontal_temp_width, height = horizontal_temp_height}
        }
        current_window.horizontal = false
        add_with_and_height(horizontal_temp_width, horizontal_temp_height, current_window.horizontal)
        local parent = current_window.open_containers[#current_window.open_containers]
        parent[#parent + 1] = temp_container
        current_window.active_container = parent
        horizontal_temp_width, horizontal_temp_height = 0, 0
    end

    --finish and draw the window
    self.finish = function()
        directx.draw_rect(
            temp_x - 0.005,
            temp_y - 0.005,
            current_window.width + 0.01,
            current_window.height + 0.01,
            highlight_colour
        )
        directx.draw_rect(
            temp_x - 0.004,
            temp_y - 0.004,
            current_window.width + 0.008,
            current_window.height + 0.008,
            background_colour
        )
        directx.draw_rect(temp_x - 0.004, temp_y - 0.004, current_window.width + 0.008, 0.03, gray_colour)

        directx.draw_text(
            temp_x + current_window.width * 0.5,
            temp_y,
            current_window.title,
            ALIGN_TOP_CENTRE,
            .6,
            text_colour,
            false
        )

        if cursor_mode then
            if get_overlap_with_rect(current_window.width + 0.008, 0.03, temp_x, temp_y, cursor_pos) then
                if PAD.IS_CONTROL_JUST_PRESSED(2, 18) then
                    current_window.is_being_dragged = true
                end
            end
            if PAD.IS_CONTROL_JUST_RELEASED(2, 18) then
                current_window.is_being_dragged = false
            end

            if current_window.is_being_dragged then
                current_window.x = cursor_pos.x - current_window.width * 0.5
                current_window.y = cursor_pos.y - 0.03 * 0.5
            end
        end

        temp_y = temp_y + 0.03

        draw_container(current_window.elements)

        temp_container = {}
        current_window = {}
    end

    return self
end

-- Start here with what is seen in game

myUI = UI.new()

local fps = 0
local timespendinsession = 0
util.create_thread(function()
    while true do
        fps = math.ceil(1/SYSTEM.TIMESTEP())
        util.yield(500)
    end
end)



local regionDetect = {
    [0]  = {kick = false, lang = "English"},
    [1]  = {kick = false, lang = "French"},
    [2]  = {kick = false, lang = "German"},
    [3]  = {kick = false, lang = "Italian"},
    [4]  = {kick = false, lang = "Spanish"},
    [5]  = {kick = false, lang = "Brazilian"},
    [6]  = {kick = false, lang = "Polish"},
    [7]  = {kick = false, lang = "Russian"},
    [8]  = {kick = false, lang = "Korean"},
    [9]  = {kick = false, lang = "Chinese Traditional"},
    [10] = {kick = false, lang = "Japanese"},
    [11] = {kick = false, lang = "Mexican"},
    [12] = {kick = false, lang = "Chinese Simplified"},
}

-- default position
local x2 = 0 --posX
local y2 = 0 --posY

menu.slider(player_pos, "Move X", {"xcoord2"}, "Move the players overlay x coordinates.", -100, 100, 0, 1, function(datax2) --after help text : 0 is min, 100 is max, 50 is default and 1 is step
    x2=datax2/100 -- put the value at 0.xx (ex : 50/100 = 0.5 default position)
end)
menu.slider(player_pos, "Move Y", {"ycoord2"}, "Move the players overlay y coordinates.", -100, 100, 0, 1, function(datay2) --after help text : 0 is min, 100 is max, 50 is default and 1 is step
    y2=datay2/100 -- put the value at 0.xx (ex : 50/100 = 0.5 default position)
end)

menu.toggle(player_overlay, "Players Overlay", {"PlayerOverlay"}, "A nice player overlay",
    function(state)
        UItoggle = state
        while UItoggle do
            local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
            myUI.begin("      Players      ", x2 + 0.02, y2 + 0.02, "kpjbgkzjsdbg")
            local player_table = players.list()
            for i, pid in pairs(player_table) do
                myUI.label(players.get_name(pid),"")
            end
            myUI.finish()
            myUI.begin("Rank", x2 + 0.115, y2 + 0.02, "kpj2bdg2kzjsdbg")
            local player_table = players.list()
            for i, pid in pairs(player_table) do
                myUI.label(players.get_rank(pid),"")
            end
            myUI.finish()
            myUI.begin("Modder", x2 + 0.165, y2 + 0.02, "kpj2bdgd2kzjsdbg")
            local player_table = players.list()
            for i, pid in pairs(player_table) do
                if players.is_marked_as_modder(pid) then
                    myUI.label("Modder","")
                else
                    myUI.label("No","")
                end
            end
            myUI.finish()
            myUI.begin("Attacker", x2 + 0.231, y2 + 0.02, "kpjbdg2kzjsdbg")
            local player_table = players.list()
            for i, pid in pairs(player_table) do
                if players.is_marked_as_attacker(pid) then
                    myUI.label("Attacker","")
                    else
                    myUI.label("No","")
                    end
            end
            myUI.finish()
            myUI.begin(" Language ", x2 + 0.299, y2 + 0.02, "kpjbdgkzjsdbg")
            local player_table = players.list()
            for i, pid in pairs(player_table) do
               myUI.label(regionDetect[players.get_language(pid)].lang,"")
            end
            myUI.finish()
            myUI.begin("Input", x2 + 0.378, y2 + 0.02, "kpj2bdgd2hkzjsdbg")
            local player_table = players.list()
            for i, pid in pairs(player_table) do
            if players.is_using_controller(pid) then
				myUI.label("Controller","")
				else
                myUI.label("KBM","")
				end
            end
            myUI.finish()
            myUI.begin("         Boss        ", x2 + 0.431, y2 + 0.02, "kpfj3bdgd2hkzsdbg")
            local player_table = players.list()
            for i, pid in pairs(player_table) do
                if players.get_boss(pid) == -1 then
				myUI.label("N/A","")
				else
				myUI.label((players.get_name(players.get_boss(pid))),"")
				end
            end
            myUI.finish()
            myUI.begin("Vehicle", x2 + 0.528, y2 + 0.02, "kpfj2bdgd2hkzsdbg")
            local player_table = players.list()
            for i, pid in pairs(player_table) do
				playerinfo1 = players.get_vehicle_model(pid)
				if players.get_vehicle_model(pid) == 0 then
				myUI.label("N/A","")
				else
				myUI.label(util.get_label_text(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(players.get_vehicle_model(pid))),"")
				end
            end
            myUI.finish()

            --
            util.yield()
        end
    end)

-- Info Window

local function SessionType()
		if util.is_session_started() then
            if NETWORK.NETWORK_SESSION_IS_PRIVATE() then
                return "Invite Only"
            elseif NETWORK.NETWORK_SESSION_IS_CLOSED_CREW() then
                return "Crew Only"
        	elseif NETWORK.NETWORK_SESSION_IS_CLOSED_FRIENDS() then
            	return "Friends Only"
            elseif NETWORK.NETWORK_SESSION_IS_SOLO() then
            	return "Solo"
            else
    		return "Public"
            end
    	end
    return "Singleplayer"
end

--memory paths
local replayInterface = memory.read_long(memory.rip(memory.scan("48 8D 0D ? ? ? ? 48 8B D7 E8 ? ? ? ? 48 8D 0D ? ? ? ? 8A D8 E8 ? ? ? ? 84 DB 75 13 48 8D 0D") + 3))
local pedInterface = memory.read_long(replayInterface + 0x0018)
local vehInterface = memory.read_long(replayInterface + 0x0010)
local objectInterface = memory.read_long(replayInterface + 0x0028)
local pickupInterface = memory.read_long(replayInterface + 0x0020)

--locals
local session_type_toggle = false
local session_host_toggle = false
local session_script_host_toggle = false
local players_toggle = false
local time_toggle = false
local fps_toggle = false
local peds_toggle = false
local vehicles_toggle = false
local objects_toggle = false
local pickups_toggle = false
local white_colour = {r = 1.0, g = 1.0, b = 1.0, a = 1.0}

--toggles
menu.toggle(info_toggles, "Session Type Toggle", {"SessionTypeToggle"}, "", function(on)
    session_type_toggle = on
    util.yield()
end)
menu.toggle(info_toggles, "Session Host Toggle", {"SessionHostToggle"}, "", function(on)
    session_host_toggle = on
    util.yield()
end)
menu.toggle(info_toggles, "Session Script Host Toggle", {"SessionScriptHostToggle"}, "", function(on)
    session_script_host_toggle = on
    util.yield()
end)
menu.toggle(info_toggles, "Players Toggle", {"PlayersToggle"}, "", function(on)
    players_toggle = on
    util.yield()
end)
menu.toggle(info_toggles, "Modders Toggle", {"ModdersToggle"}, "", function(on)
    modders_toggle = on
    util.yield()
end)
menu.toggle(info_toggles, "Friends Toggle", {"FriendsToggle"}, "", function(on)
    friends_toggle = on
    util.yield()
end)
menu.toggle(info_toggles, "Strangers Toggle", {"StrangersToggle"}, "", function(on)
    stranger_toggle = on
    util.yield()
end)
menu.toggle(info_toggles, "Time Toggle", {"TimeToggle"}, "", function(on)
    time_toggle = on
    util.yield()
end)
menu.toggle(info_toggles, "FPS Toggle", {"FPSToggle"}, "", function(on)
    fps_toggle = on
    util.yield()
end)
menu.toggle(info_toggles, "Peds Toggle", {"PedsToggle"}, "", function(on)
    peds_toggle = on
    util.yield()
end)
menu.toggle(info_toggles, "Vehicles Toggle", {"VehiclesToggle"}, "", function(on)
    vehicles_toggle = on
    util.yield()
end)
menu.toggle(info_toggles, "Objects Toggle", {"ObjectsToggle"}, "", function(on)
    objects_toggle = on
    util.yield()
end)
menu.toggle(info_toggles, "Pickups Toggle", {"PickupsToggle"}, "", function(on)
    pickups_toggle = on
    util.yield()
end)
menu.toggle(info_toggles, "Empty Toggle", {"EmptyToggle"}, "A toggle to create some empty space where a session code can be put as an example.", function(on)
    empty_toggle = on
    util.yield()
end)

-- default position
local x = 0.17 --posX
local y = 0.67 --posY

menu.slider(info_pos, "Move X", {"xcoord"}, "Move the info overlay x coordinates.", -100, 100, 17, 1, function(datax) --after help text : 0 is min, 100 is max, 50 is default and 1 is step
    x=datax/100 -- put the value at 0.xx (ex : 50/100 = 0.5 default position)
end)
menu.slider(info_pos, "Move Y", {"ycoord"}, "Move the info overlay y coordinates.", -100, 100, 67, 1, function(datay) --after help text : 0 is min, 100 is max, 50 is default and 1 is step
    y=datay/100 -- put the value at 0.xx (ex : 50/100 = 0.5 default position)
end)

menu.text_input(info_root, "Change Title", { "ChangeTitle" }, "Allows you the text on top of the info overlay.", function(fuck)
    infoTitle = fuck
end)

menu.toggle(info_root, "Info Overlay", {"InfoOverlay"}, "Info overlay in a cute box", function(state)
    UItoggle2 = state
    while UItoggle2 do
        --start the gui
        myUI.begin2(infoTitle, x, y, "asdfghjkl")

        --count players in the session
        local playercount = 0
        for i, pid in pairs(players.list(true, true, true)) do
            playercount = playercount + 1
        end

        --count modders in the session
        local moddercount = 0
        for i, pid in pairs(players.list(true, true, true)) do
            if players.is_marked_as_modder(pid) then
                moddercount = moddercount + 1
            end
        end

        --count friends in the session
        local friendcount = 0
        for i, pid in pairs(players.list(false, true, false)) do
            friendcount = friendcount + 1
        end

        --count strangers in the session
        local strangercount = 0
        for i, pid in pairs(players.list(false, false, true)) do
            strangercount = strangercount + 1
        end

        --session type toggle
        if session_type_toggle then
            myUI.label("Session Type: ", SessionType(), white_colour)
        end

        --session host row
        if session_host_toggle then
            myUI.label("Host: ", players.get_name(players.get_host()), white_colour)
        end

        --script host row
        if session_script_host_toggle then
            myUI.label("Script Host: ", players.get_name(players.get_script_host()), white_colour)
        end

        --player count row
        if players_toggle then
            myUI.label("Players: ", playercount, white_colour)
        end

        --modder count row
        if modders_toggle then
            myUI.label("Modders: ", moddercount, white_colour)
        end

        --friend count row
        if friends_toggle then
            myUI.label("Friends: ", friendcount, white_colour)
        end

        --stranger count row
        if stranger_toggle then
            myUI.label("Strangers: ", strangercount, white_colour)
        end

        --time row
        if time_toggle then
            myUI.label("Time: ", os.date("%X"), white_colour)
        end

        --fps overlay row
        if fps_toggle then
            myUI.label("FPS: ", fps, white_colour)
        end

        --ped pool count row
        if peds_toggle then
            myUI.label("Peds: ", memory.read_int(pedInterface + 0x0110).."/"..memory.read_int(pedInterface + 0x0108), white_colour)
        end

        --vehicle count row
        if vehicles_toggle then
            myUI.label("Vehicles: ", memory.read_int(vehInterface + 0x0190).."/"..memory.read_int(vehInterface + 0x0188), white_colour)
        end

        --oject count row
        if objects_toggle then
            myUI.label("Objects: ", memory.read_int(objectInterface + 0x0168).."/"..memory.read_int(objectInterface + 0x0160), white_colour)
        end

        --pickup count row
        if pickups_toggle then
            myUI.label("Pickups: ", memory.read_int(pickupInterface + 0x0110).."/"..memory.read_int(pickupInterface + 0x0108), white_colour)
        end

         --empty row
         if empty_toggle then
            myUI.label("", "", white_colour)
        end
        --finish/complete the gui
        myUI.finish()
        util.yield()
    end
end)

--keep script running
util.keep_running()
