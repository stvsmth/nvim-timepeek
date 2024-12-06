vim.api.nvim_set_keymap(
  "n",
  "<Leader>tt",
  [[<Cmd>lua require('timepeek').render_date()<CR>]],
  { noremap = true, silent = true }
)

