return {

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "vimdoc",
        "c",
        "cpp",
        "go",
        "html",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "sql",
        "regex",
        "tmux",
        "vim",
        "xml",
        "yaml",
        "go",
        "bicep",
        "terraform",
      },
      -- Disable terraform treesitter on fixture files
    },
  },
}
