local M = {}

function M.post()
  local gl = require("galaxyline")
  local gls = gl.section
  local vcs = require("galaxyline.provider_vcs")

  gl.short_line_list = {
    "dapui_scopes",
    "dapui_stacks",
    "dapui_watches",
    "dapui_breakpoints",
    "LuaTree",
    "dbui",
    "term",
    "fugitive",
    "fugitiveblame",
    "NvimTree",
    "UltestSummary"
  }

  local colors = {
    bg = "#262626",
    normal = "#F8F8F8",
    grey = "#132434",
    grey1 = "#262626",
    grey2 = "#8B8B8B",
    grey3 = "#bdbdbd",
    grey4 = "#F8F8F8",
    violet = "#D484FF",
    blue = "#2f628e",
    cyan = "#00f1f5",
    green = "#A9FF68",
    green2 = "#2f7366",
    yellow = "#FFF59D",
    orange = "#F79000",
    red = "#F70067"
  }
  local function has_vcs_status()
    local branch = vcs.get_git_branch()
    if type(branch) == "string" and branch ~= "" then
      return true
    end
    for _, v in pairs({vcs.diff_add(), vcs.diff_modified(), vcs.diff_remove()}) do
      if v ~= nil then
        return true
      end
    end
    return false
  end

  local function has_file_type()
    local f_type = vim.bo.filetype
    if not f_type or f_type == "" then
      return false
    end
    return true
  end

  local buffer_not_empty = function()
    if vim.fn.empty(vim.fn.expand("%:t")) ~= 1 then
      return true
    end
    return false
  end

  local mode_color = {
    n = colors.green,
    i = colors.cyan,
    v = colors.violet,
    [""] = colors.cyan,
    V = colors.cyan,
    c = colors.red,
    no = colors.violet,
    s = colors.orange,
    S = colors.orange,
    [""] = colors.orange,
    ic = colors.yellow,
    cv = colors.red,
    ce = colors.red,
    ["!"] = colors.green,
    t = colors.green,
    ["r?"] = colors.red,
    ["r"] = colors.red,
    rm = colors.red,
    R = colors.yellow,
    Rv = colors.violet
  }

  local mode_alias = {
    n = "NORMAL",
    i = "INSERT",
    c = "COMMAND",
    V = "VISUAL",
    [""] = "VISUAL",
    v = "VISUAL",
    ["r?"] = ":CONFIRM",
    rm = "--MORE",
    R = "REPLACE",
    Rv = "VIRTUAL",
    s = "SELECT",
    S = "SELECT",
    ["r"] = "HIT-ENTER",
    [""] = "SELECT",
    t = "TERMINAL",
    ["!"] = "SHELL"
  }

  gls.left[1] = {
    ViMode = {
      provider = function()
        -- auto change color according the vim mode
        local vim_mode = vim.fn.mode()
        vim.api.nvim_command("hi GalaxyViMode guifg=" .. colors.bg .. " guibg=" .. mode_color[vim_mode])
        return "  " .. mode_alias[vim_mode] .. " "
      end,
      highlight = {colors.red, colors.bg, "bold"},
      event = "InsertEnter"
    }
  }

  local function file_readonly()
    if vim.bo.filetype == "help" then
      return ""
    end
    if vim.bo.readonly == true then
      return " "
    end
    return ""
  end
  local function long_filename()
    local file = vim.fn.expand("%")
    local result = file
    if vim.fn.empty(file) == 1 then
      return result
    end
    return "  " .. result .. " "
  end

  gls.left[2] = {
    LongFileName = {
      provider = long_filename,
      condition = buffer_not_empty,
      highlight = {colors.normal, colors.bg, "bold"}
    }
  }

  gls.left[3] = {
    FileIcon = {
      provider = "FileIcon",
      condition = buffer_not_empty,
      highlight = {require("galaxyline.provider_fileinfo").get_file_icon_color, colors.bg}
    }
  }

  gls.left[4] = {
    FileStatus = {
      provider = function()
        if string.len(file_readonly()) ~= 0 then
          return file_readonly()
        elseif vim.bo.modifiable then
          if vim.bo.modified then
            return " "
          end
        end
      end,
      highlight = {colors.cyan, colors.bg}
    }
  }

  gls.left[5] = {
    FileSize = {
      provider = "FileSize",
      condition = buffer_not_empty,
      highlight = {colors.normal, colors.bg}
    }
  }

  gls.left[6] = {
    FileBarrier = {
      provider = function()
        return " "
      end,
      highlight = {colors.bg, "none"}
    }
  }

  local checkwidth = function()
    local squeeze_width = vim.fn.winwidth(0) / 2
    if squeeze_width > 60 then
      return true
    end
    return false
  end

  gls.left[7] = {
    CustomGitBranch = {
      provider = function()
        local branch = vcs.get_git_branch()
        if branch == nil then
          return ""
        end
        return "  " .. branch
      end,
      condition = checkwidth,
      highlight = {colors.normal, "none", "bold"}
    }
  }

  gls.left[8] = {
    DiffAdd = {
      provider = "DiffAdd",
      condition = checkwidth,
      icon = " ",
      highlight = {colors.green, "none", "bold"}
    }
  }
  gls.left[9] = {
    DiffModified = {
      provider = "DiffModified",
      condition = checkwidth,
      icon = " ",
      highlight = {colors.yellow, "none", "bold"}
    }
  }
  gls.left[10] = {
    DiffRemove = {
      provider = "DiffRemove",
      condition = checkwidth,
      icon = " ",
      highlight = {colors.red, "none", "bold"}
    }
  }

  local spinner_frames = {"⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"}
  function lsp_status(status)
    local buf_messages = require("lsp-status").messages()
    if vim.tbl_isempty(buf_messages) then
      return ""
    end
    local msgs = {}
    for _, msg in ipairs(buf_messages) do
      local name = msg.name
      local client_name = "[" .. name .. "]"
      local contents = ""
      if msg.progress then
        contents = msg.title
        if msg.message then
          contents = contents .. " " .. msg.message
        end

        if msg.percentage then
          contents = contents .. " (" .. msg.percentage .. ")"
        end

        if msg.spinner then
          contents = spinner_frames[(msg.spinner % #spinner_frames) + 1] .. " " .. contents
        end
      elseif msg.status then
        contents = msg.content
        if msg.uri then
          local filename = vim.uri_to_fname(msg.uri)
          filename = vim.fn.fnamemodify(filename, ":~:.")
          local space = math.min(60, math.floor(0.6 * vim.fn.winwidth(0)))
          if #filename > space then
            filename = vim.fn.pathshorten(filename)
          end

          contents = "(" .. filename .. ") " .. contents
        end
      else
        contents = msg.content
      end

      table.insert(msgs, client_name .. " " .. contents)
    end
    status = ""
    for name, msg in pairs(msgs) do
      status = status .. " | " .. name .. ": " .. msg
    end
    return status
  end

  local function ultest_is_test_file()
    if vim.fn["exists"]("*ultest#is_test_file") == 1 then
      local success, res = pcall(vim.fn["ultest#is_test_file"]())
      if not success then
        return 0
      end
      return res == 1
    end
    return false
  end

  gls.right = {
    {
      CocStatus = {
        provider = lsp_status,
        highlight = {colors.cyan, "none"}
      }
    },
    {
      RightBarrier = {
        provider = function()
          return ""
        end,
        highlight = {colors.bg, "none"}
      }
    },
    {
      DiagnosticError = {
        provider = "DiagnosticError",
        icon = "   ",
        highlight = {colors.red, colors.bg}
      }
    },
    {
      DiagnosticWarn = {
        provider = "DiagnosticWarn",
        icon = "   ",
        highlight = {colors.yellow, colors.bg}
      }
    },
    {
      DiagnosticInfo = {
        provider = "DiagnosticInfo",
        icon = "   ",
        highlight = {colors.green, colors.bg}
      }
    },
    {
      DiagnosticHint = {
        provider = "DiagnosticHint",
        icon = "   ",
        highlight = {colors.cyan, colors.bg}
      }
    },
    {
      CurrentFunction = {
        provider = function ()
          local res = vim.b.lsp_current_function
          if res and #vim.trim(res) > 0 then
            return res.." "
          end
          return nil
        end,
        icon = "  ",
        highlight = {colors.violet, colors.bg}
      }
    },

    {
      UltestTests = {
        provider = function()
          return vim.fn["ultest#status"]().tests
        end,
        icon = "  ",
        condition = ultest_is_test_file,
        highlight = {colors.cyan, colors.bg}
      }
    },
    {
      UltestPassed = {
        provider = function()
          return vim.fn["ultest#status"]().passed
        end,
        icon = "  ● ",
        condition = ultest_is_test_file,
        highlight = {colors.green, colors.bg}
      }
    },
    {
      UltestFailed = {
        provider = function()
          return vim.fn["ultest#status"]().failed
        end,
        icon = "  ● ",
        condition = ultest_is_test_file,
        highlight = {colors.red, colors.bg}
      }
    },
    {
      UltestRunning = {
        provider = function()
          return vim.fn["ultest#status"]().running
        end,
        icon = "  ● ",
        condition = ultest_is_test_file,
        highlight = {colors.yellow, colors.bg}
      }
    },
    {
      FileFormat = {
        provider = "FileFormat",
        separator = " ",
        separator_highlight = {colors.fg, colors.bg, "bold"},
        highlight = {colors.fg, colors.bg, "bold"}
      }
    },
    {
      LineInfo = {
        provider = "LineColumn",
        separator = " ",
        separator_highlight = {colors.blue, colors.bg},
        highlight = {colors.fg, colors.bg}
      }
    },
    {
      PerCent = {
        provider = "LinePercent",
        separator = " ",
        separator_highlight = {colors.bg, colors.bg},
        highlight = {colors.cyan, colors.bg, "bold"}
      }
    }
  }

  gls.short_line_left[1] = {
    LongFileName = {
      provider = long_filename,
      separator = "  ",
      highlight = {colors.normal, colors.bg, "bold"}
    }
  }

  gls.short_line_right[1] = {
    BufferIcon = {
      provider = "BufferIcon",
      condition = has_file_type,
      separator_highlight = {colors.violet, colors.bg},
      highlight = {colors.fg, colors.violet}
    }
  }
end

return M
