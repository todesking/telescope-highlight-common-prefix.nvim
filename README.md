# telescope-highlight-common-prefix.nvim

Dim common path prefixes between adjacent Telescope results so the unique tail stands out.

## Features

- Highlights shared path prefixes between neighbors in the results list
- Compare direction can be `prev` or `next`
- Custom `common_prefix` function supported
- Works with `TelescopeResumePost` via `on_resume`

## Requirements

- `nvim-telescope/telescope.nvim`

## Installation (lazy.nvim)

```lua
{
  "todesking/telescope-highlight-common-prefix.nvim",
}
```

## Setup

Run this as part of your Telescope configuration setup.

```lua
local telescope = require("telescope")
local hl = require("telescope_highlight_common_prefix")

local on_complete = hl.new_complete_handler({
})

telescope.setup({
  pickers = {
    find_files = {
      -- Add this to pickers where you want common-prefix highlighting.
      on_complete = { on_complete },
    },
  },
})

-- Keep highlights when using `telescope.builtin.resume()`.
local aug = vim.api.nvim_create_augroup("telescope-highlight-common-prefix", { clear = true })
vim.api.nvim_create_autocmd("User", {
  group = aug,
  pattern = "TelescopeResumePost",
  callback = hl.on_resume,
})
```

## Customizing

These keys are options passed to `new_complete_handler()`.

### compare

- `"prev"`: compare each entry to the previous visible entry
- `"next"`: compare each entry to the next visible entry

default: `"prev"`

### common_prefix

Override how the common prefix length is computed (return a byte length). The default checks path segments (split by `/`).

```lua
common_prefix = function(left, right)
  local max = math.min(#left, #right)
  local i = 1
  while i <= max and left:sub(i, i) == right:sub(i, i) do
    i = i + 1
  end
  return i - 1
end
```

## Notes

- Highlighting uses `TelescopeResultsComment`. Adjust that highlight group to change the dim color.
- Comparison uses `config.values.path_display` (and picker `opts.path_display` when set), so customize it via Telescope's `path_display` options.

## License

MIT
