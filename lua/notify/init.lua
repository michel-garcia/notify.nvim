local Config = require("notify.config")
local Manager = require("notify.manager")

local M = {}

M.setup = function(opts)
    Config.setup(opts)
    if Config.opts.override then
        vim.notify = M.notify
    end
    Manager.init()
end

M.notify = function(msg, level, opts)
    Manager.notify(msg, level, opts)
end

return M
