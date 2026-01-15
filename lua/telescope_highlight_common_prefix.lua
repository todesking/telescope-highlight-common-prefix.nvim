---@module "telescope_highlight_common_prefix"
---@brief [[
--- Re-highlights Telescope results to dim common path prefixes between neighbors.
--- Use `new_complete_handler()` in a picker `on_complete` callback and `on_resume` for `TelescopeResumePost`.
---@brief ]]

local config = require("telescope.config")
local utils = require("telescope.utils")

---@class TelescopeCommonPrefixHL
local M = {}
local common_prefix_ns = vim.api.nvim_create_namespace("telescope_highlight_common_prefix")

---@param a string
---@param b string
---@return integer
local function common_prefix_by_segment(a, b)
    local a_parts = vim.split(a, "/")
    local b_parts = vim.split(b, "/")
    local out = {}
    local max = math.min(#a_parts, #b_parts)
    for i = 1, max + 1 do
        if a_parts[i] ~= b_parts[i] then
            break
        end
        out[#out + 1] = a_parts[i]
    end
    return #table.concat(out, "/")
end

---@param picker Picker
---@param direction? "prev" | "next"
---@param common_prefix? fun(left: string, right: string): integer
local function apply_hl(picker, direction, common_prefix)
    if not (picker and picker.manager and vim.api.nvim_buf_is_valid(picker.results_bufnr)) then
        return
    end

    vim.api.nvim_buf_clear_namespace(picker.results_bufnr, common_prefix_ns, 0, -1)

    local common_prefix_fn = common_prefix or common_prefix_by_segment

    local function path_display_string(entry)
        local path = entry.value
        if type(path) ~= "string" then
            return ""
        end
        local display_opts =  { path_display = config.values.path_display }
        return utils.transform_path(display_opts, path)
    end

    local function highlight_common(entry, neighbor, row)
        if not neighbor or row < 0 then
            return
        end
        local left = path_display_string(entry)
        local right = path_display_string(neighbor)
        if type(left) ~= "string" or type(right) ~= "string" then
            return
        end
        local common_len = common_prefix_fn(left, right)
        if common_len == 0 then
            return
        end
        local common = left:sub(1, common_len)
        local display = entry:display()
        local hl_start, hl_end = display:find(common, 0, true)
        if not hl_start then
            return
        end

        local offset = #(config.values.entry_prefix or "")

        vim.hl.range(
            picker.results_bufnr,
            common_prefix_ns,
            "TelescopeResultsComment",
            { row, offset + hl_start - 1 },
            { row, offset + hl_end - 1 },
            { inclusive = true }
        )
    end

    local entries = {}
    local index = 0
    for entry in picker.manager:iter() do
        index = index + 1
        local row = picker:get_row(index)
        if row >= 0 then
            entries[#entries + 1] = { entry = entry, row = row }
        end
    end
    table.sort(entries, function(a, b)
        return a.row < b.row
    end)

    if direction == "next" then
        for i = 1, #entries do
            local current = entries[i]
            local neighbor = entries[i + 1]
            highlight_common(current.entry, neighbor and neighbor.entry or nil, current.row)
        end
    else
        local prev_entry
        for i = 1, #entries do
            local current = entries[i]
            highlight_common(current.entry, prev_entry, current.row)
            prev_entry = current.entry
        end
    end
end

---@param args { buf: integer }
function M.on_resume(args)
    local state = require("telescope.actions.state")
    local picker = state.get_current_picker(args.buf)
    if not picker then
        return
    end
    local saved = picker.cache_picker and picker.cache_picker.highlight_common_prefix
    if not (saved and saved.enabled) then
        return
    end
    apply_hl(picker, saved.compare or "prev", saved.common_prefix)
end

---@class TelescopeCommonPrefixOptions
---@field compare? "prev" | "next"
---@field common_prefix? fun(left: string, right: string): integer

---@param opts? TelescopeCommonPrefixOptions
---@return fun(picker: Picker)
function M.new_complete_handler(opts)
    opts = opts or {}
    local compare = opts.compare or "prev"
    local common_prefix = opts.common_prefix
    local function on_complete(picker)
        picker.cache_picker = picker.cache_picker or {}
        picker.cache_picker.highlight_common_prefix = {
            enabled = true,
            compare = compare,
            common_prefix = common_prefix,
        }
        apply_hl(picker, compare, common_prefix)
    end
    return on_complete
end

return M
