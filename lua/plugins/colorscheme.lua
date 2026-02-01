return {
  {
    "doums/darcula",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("darcula")

      -- Python-specific treesitter highlight overrides (PyCharm Darcula style)
      local py_hl = {
        -- Keywords (if, def, class, return, import, etc.)
        ["@keyword.python"] = { fg = "#CC7832" },
        ["@keyword.function.python"] = { fg = "#CC7832" },
        ["@keyword.return.python"] = { fg = "#CC7832" },
        ["@keyword.import.python"] = { fg = "#CC7832" },
        ["@keyword.conditional.python"] = { fg = "#CC7832" },
        ["@keyword.repeat.python"] = { fg = "#CC7832" },
        ["@keyword.exception.python"] = { fg = "#CC7832" },
        ["@keyword.operator.python"] = { fg = "#CC7832" },
        ["@include.python"] = { fg = "#CC7832" },
        ["@exception.python"] = { fg = "#CC7832" },
        ["@conditional.python"] = { fg = "#CC7832" },
        ["@repeat.python"] = { fg = "#CC7832" },

        -- Strings
        ["@string.python"] = { fg = "#6A8759" },
        ["@string.escape.python"] = { fg = "#CC7832" },

        -- Docstrings
        ["@string.documentation.python"] = { fg = "#629755", italic = true },

        -- Numbers
        ["@number.python"] = { fg = "#6897BB" },
        ["@number.float.python"] = { fg = "#6897BB" },
        ["@float.python"] = { fg = "#6897BB" },

        -- Comments
        ["@comment.python"] = { fg = "#808080", italic = true },

        -- Function definition names
        ["@function.python"] = { fg = "#FFC66D" },

        -- Function calls
        ["@function.call.python"] = { fg = "#A9B7C6" },
        ["@function.method.call.python"] = { fg = "#A9B7C6" },
        ["@method.call.python"] = { fg = "#A9B7C6" },

        -- Built-in functions (print, len, range, etc.)
        ["@function.builtin.python"] = { fg = "#8888C6" },

        -- Decorators
        ["@attribute.python"] = { fg = "#BBB529" },

        -- self / cls
        ["@variable.builtin.python"] = { fg = "#94558D", italic = true },

        -- True / False / None
        ["@boolean.python"] = { fg = "#CC7832" },
        ["@constant.builtin.python"] = { fg = "#CC7832" },

        -- Types / type hints
        ["@type.python"] = { fg = "#A9B7C6" },
        ["@type.builtin.python"] = { fg = "#A9B7C6" },

        -- Variables / parameters
        ["@variable.python"] = { fg = "#A9B7C6" },
        ["@variable.parameter.python"] = { fg = "#A9B7C6" },
        ["@parameter.python"] = { fg = "#A9B7C6" },

        -- Operators
        ["@operator.python"] = { fg = "#A9B7C6" },
      }

      for group, opts in pairs(py_hl) do
        vim.api.nvim_set_hl(0, group, opts)
      end
    end,
  },
}
