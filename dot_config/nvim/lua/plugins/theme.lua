return {
  {
    "ellisonleao/gruvbox.nvim",
    opts = {
      transparent_mode = true, -- Теперь Gruvbox знает, что нужно убрать фон
      -- Здесь же вы можете указать другие дефолтные опции, если нужно:
      italic = {
        strings = true,
        comments = true,
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
