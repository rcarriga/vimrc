local M = {}

function M.pre()
  require "format".setup {
    ["*"] = {
      {cmd = {"sed -i 's/[ \t]*$//'"}} -- remove trailing whitespace
    },
    zsh = {cmd = {"shfmt -i 2 -w"}},
    bash = {cmd = {"shfmt -i 2 -w"}},
    sh = {cmd = {"shfmt -i 2 -w"}},
    lua = {
      {
        cmd = {
          function(file)
            return string.format("luafmt -l %s -w replace -i 2 %s", 120, file)
          end
        }
      }
    },
    go = {
      {
        cmd = {"gofumpt -w", "goimports -w"},
        tempfile_postfix = ".tmp"
      }
    },
    javascript = {
      {cmd = {"prettier -w", "./node_modules/.bin/eslint --fix"}}
    },
    json = {
      {cmd = {"prettier -w"}}
    },
    yaml = {
      {cmd = {"prettier -w"}}
    },
    typescript = {
      {cmd = {"prettier -w", "./node_modules/.bin/eslint --fix"}}
    },
    markdown = {
      {cmd = {"prettier -w"}},
      {
        cmd = {"black"},
        start_pattern = "^```python$",
        end_pattern = "^```$",
        target = "current"
      }
    },
    python = {
      {cmd = {"./scripts/style"}},
      {cmd = {"./scripts/code-style -w"}},
      {cmd = {"black"}}
    }
  }
end

return M