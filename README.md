# telescope-highlight-common-prefix.nvim

Dim common path prefixes between adjacent Telescope results so the unique tail stands out.

<img width="892" height="399" alt="image" src="https://github.com/user-attachments/assets/bad3e195-39f3-475b-b6ad-a67a737502eb" />

## Features

- Highlights shared path prefixes between neighbors in the results list
- Compare direction can be `prev` or `next`

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
    -- options here
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

### `compare: "prev" | "next"`

- `"prev"`: compare each entry to the previous visible entry
- `"next"`: compare each entry to the next visible entry

default: `"prev"`

### `common_prefix: fun(string, string): integer`

Override how the common prefix length is computed (return a byte length). The default checks path segments (split by `/`).

## Notes

- Highlighting uses `TelescopeResultsComment`. Adjust that highlight group to change the dim color.
- Comparison uses `config.values.path_display` (and picker `opts.path_display` when set), so customize it via Telescope's `path_display` options.

## License

MIT
