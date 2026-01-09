local Notification = require("notify.notification")
local Config = require("notify.config")

local M = {}

M.active = {}

M.init = function()
    local group = vim.api.nvim_create_augroup("Notify", {
        clear = true,
    })
    vim.api.nvim_create_autocmd("WinClosed", {
        callback = function(args)
            local active = vim.tbl_filter(function(notif)
                return notif.win ~= tonumber(args.match)
            end, M.active)
            if #active ~= #M.active then
                vim.schedule(M.layout)
            end
            M.active = active
        end,
        group = group,
    })
end

M.notify = function(msg, level, opts)
    if #msg == 0 then
        return
    end
    if opts and opts.id then
        for _, notif in ipairs(M.active) do
            if notif.id == opts.id and notif:is_valid() then
                notif:update(msg, level, opts)
                return
            end
        end
    end
    local notif = Notification(msg, level, opts)
    table.insert(M.active, notif)
    if #M.active > Config.opts.max then
        local oldest = M.active[1] or nil
        if oldest and oldest ~= notif then
            notif:close()
            table.remove(M.active, 1)
        end
    end
    M.layout()
end

M.layout = function()
    local offset = Config.opts.spacing
    if string.find(Config.opts.placement, "bottom") then
        offset = offset + vim.o.cmdheight
        if vim.o.laststatus > 0 then
            offset = offset + 1
        end
    end
    for _, notif in ipairs(M.active) do
        if notif:is_valid() then
            notif:set_pos(offset)
            offset = offset + notif:get_height() + Config.opts.spacing
        end
    end
    vim.cmd("redraw")
end

return M
