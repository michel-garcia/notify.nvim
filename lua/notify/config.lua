local M = {}

M.opts = {
    border = nil,
    hl_groups = {
        [vim.log.levels.ERROR] = "DiagnosticError",
        [vim.log.levels.WARN] = "DiagnosticWarn",
        [vim.log.levels.INFO] = "DiagnosticInfo",
        [vim.log.levels.DEBUG] = "DiagnosticHint",
        [vim.log.levels.TRACE] = "DiagnosticOk",
    },
    max = 4,
    override = true,
    placement = "bottom-right",
    spacing = 1,
    timeout = 3000,
    width = 64,
    zindex = 999,
}

M.setup = function(opts)
    M.opts = vim.tbl_deep_extend("force", M.opts, opts)
    vim.validate("border", M.opts.border, function(value)
        if type(value) == "table" then
            return true
        end
        local valid = {
            "bold",
            "double",
            "none",
            "rounded",
            "shadow",
            "single",
            "solid",
        }
        return vim.tbl_contains(valid, value)
    end, true)
    vim.validate("hl_groups", M.opts.hl_groups, "table")
    vim.validate("max", M.opts.max, "number")
    vim.validate("override", M.opts.override, "boolean")
    vim.validate("placement", M.opts.placement, function(value)
        local valid = {
            "top-left",
            "bottom-left",
            "bottom-center",
            "bottom-right",
            "top-right",
            "top-center",
        }
        return vim.tbl_contains(valid, value)
    end)
    vim.validate("spacing", M.opts.spacing, "number")
    vim.validate("timeout", M.opts.timeout, "number")
    vim.validate("width", M.opts.width, "number")
    vim.validate("zindex", M.opts.zindex, "number")
end

return M
