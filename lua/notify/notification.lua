local Config = require("notify.config")

local M = {}
M.__index = M

M.id = nil
M.timer = nil
M.win = nil

M.new = function(msg, level, opts)
    local self = setmetatable({}, M)
    self.id = opts and opts.id
    local buf = vim.api.nvim_create_buf(false, true)
    self.win = vim.api.nvim_open_win(buf, false, {
        border = Config.opts.border,
        col = 0,
        height = 1,
        mouse = false,
        relative = "editor",
        row = 0,
        style = "minimal",
        width = Config.opts.width,
        zindex = Config.opts.zindex,
    })
    self.timer = vim.uv.new_timer()
    self:update(msg, level, opts)
    return self
end

M.update = function(self, msg, level, opts)
    opts = opts or {}
    level = level or vim.log.levels.INFO
    if not self:is_valid() then
        return
    end
    local buf = vim.api.nvim_win_get_buf(self.win)
    local namespace = vim.api.nvim_create_namespace("NotificationNamespace")
    vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
    local lines = vim.fn.split(vim.fn.trim(msg), "\n")
    local parts = {
        opts.title or vim.iter(vim.log.levels):find(function(_, value)
            return value == level
        end),
    }
    if not opts.icon then
        local config = vim.diagnostic.config()
        local icon = config and config.signs.text[level]
        if icon then
            table.insert(parts, 1, icon)
        end
    else
        table.insert(parts, 1, opts.icon)
    end
    local line = table.concat(parts, " ")
    table.insert(lines, 1, line)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_extmark(buf, namespace, 0, 0, {
        end_col = 0,
        end_row = 1,
        hl_eol = true,
        hl_group = Config.opts.hl_groups[level],
        hl_mode = "combine",
    })
    vim.api.nvim_win_set_config(self.win, {
        height = #lines,
    })
    self.timer:stop()
    local timeout = opts.timeout or Config.opts.timeout
    if timeout > 0 then
        self.timer:start(timeout, 0, function()
            vim.schedule(function()
                self:close()
            end)
        end)
    end
end

M.is_valid = function(self)
    return vim.api.nvim_win_is_valid(self.win)
end

M.close = function(self)
    if self:is_valid() then
        vim.api.nvim_win_close(self.win, false)
    end
end

M.get_height = function(self)
    local height = vim.api.nvim_win_get_height(self.win)
    if Config.opts.border ~= "none" then
        height = height + 2
    end
    return height
end

M.get_pos = function(self, offset)
    if Config.opts.placement == "top-left" then
        return 0, offset
    end
    if Config.opts.placement == "bottom-left" then
        return 0, vim.o.lines - self:get_height() - offset
    end
    if Config.opts.placement == "bottom-center" then
        local left = math.floor(vim.o.columns / 2 - Config.opts.width / 2)
        local top = vim.o.lines - self:get_height() - offset
        return left, top
    end
    if Config.opts.placement == "bottom-right" then
        local left = vim.o.columns - Config.opts.width
        local top = vim.o.lines - self:get_height() - offset
        return left, top
    end
    if Config.opts.placement == "top-right" then
        return vim.o.columns - Config.opts.width, offset
    end
    if Config.opts.placement == "top-center" then
        return math.floor(vim.o.columns / 2 - Config.opts.width / 2), offset
    end
end

M.set_pos = function(self, offset)
    local col, row = self:get_pos(offset)
    vim.api.nvim_win_set_config(self.win, {
        col = col,
        relative = "editor",
        row = row,
    })
end

return setmetatable(M, {
    __call = function(_, ...)
        return M.new(...)
    end,
})
