return {
  {
    "lukas-reineke/headlines.nvim",
    event = "VeryLazy",
    ft = function()
      return {}
    end,
    opts = function(_, opts)
      opts.markdown = {
        fat_headline_lower_string = "▔",
      }
      return opts
    end,
  },
}
