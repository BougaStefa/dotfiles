vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt.conceallevel = 2
  end,
})

local options = {
  workspaces = {
    {
      name = "personal",
      path = "~/obsidian-vault",
    },
  },

  daily_notes = {
    folder = "Calendar/Journals/Daily/",
    template = "Daily Note Template.md",
  },

  mappings = {
    ["gf"] = {
      action = function()
        return require("obsidian").util.gf_passthrough()
      end,
      opts = { noremap = false, expr = true, buffer = true },
    },
    ["<leader>ch"] = {
      action = function()
        return require("obsidian").util.toggle_checkbox()
      end,
      opts = { buffer = true },
    },
    ["<cr>"] = {
      action = function()
        return require("obsidian").util.smart_action()
      end,
      opts = { buffer = true, expr = true },
    },
  },
  notes_subdir = "+",
  new_notes_location = "notes_subdir",

  ---@param title string
  ---@return string
  note_id_func = function(title)
    return title
  end,

  ---@param spec { id: string, dir: obsidian.Path, title: string|? }
  ---@return string|obsidian.Path
  note_path_func = function(spec)
    local path = spec.dir / tostring(spec.title)
    return path:with_suffix ".md"
  end,

  disable_frontmatter = false,

  ---@return table
  note_frontmatter_func = function(note)
    if note.title then
      note:add_alias(note.title)
    end

    local out = { aliases = note.aliases, tags = note.tags }

    if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
      for k, v in pairs(note.metadata) do
        out[k] = v
      end
    end

    return out
  end,

  templates = {
    folder = "Atlas/Utilities/Templates/",
    date_format = "%Y-%m-%d",
    time_format = "%H:%M",
    substitutions = {},
  },

  ---@param url string
  follow_url_func = function(url)
    vim.fn.jobstart { "xdg-open", url } -- linux
    -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
    -- vim.ui.open(url) -- need Neovim 0.10.0+
  end,

  attachments = {
    img_folder = "Atlas/Utilities/Images/",
  },
}

return options
