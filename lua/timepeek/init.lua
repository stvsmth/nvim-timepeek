local M = {}

-- {{{
-- Function to display the date from a timestamp in a floating window
function M.render_date()
    -- Get the word under the cursor
    local word = vim.fn.expand('<cword>')

    -- We may get a negative number; the cursor may be under the '-' of a negative timestamp
    -- or it may be the first character of a timestamp with the cursor in the word. Also be
    -- sure that we don't have trailing characters.
    local full_word = vim.fn.expand('<cWORD>')
    if full_word:sub(1, 1) == '-' then
        word = '-' .. word
    end

    -- Check if the word is a valid timestamp
    local timestamp = tonumber(word)
    if timestamp == nil then
        -- vim.notify("The current word is not a valid timestamp.", vim.log.levels.ERROR)
        return
    end

    -- check to see if we're working with milliseconds (check absolute value)
    if math.abs(timestamp) > 1000000000000 and math.abs(timestamp) < 9999999999999 then
        timestamp = timestamp / 1000
    elseif math.abs(timestamp) > 9999999999999 then
        -- vim.notify("The current word is not a valid timestamp.", vim.log.levels.ERROR)
        return
    end

    -- Convert the timestamp to a human-readable dates, top is UTC, bottom is local
    local date_str_utc = '  ' .. os.date("!%Y-%m-%d %H:%M:%S UTC", timestamp) .. '  '
    local date_str_loc = '  ' .. os.date("%Y-%m-%d %H:%M:%S %Z", timestamp) .. '  '

    -- Create a new buffer for the floating window
    -- ... Create a scratch buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { date_str_utc, date_str_loc })
    vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })

    -- ... escape and return will close
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', ':close<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, 'n', '<ESC>', ':close<CR>', { noremap = true, silent = true })

    -- ... window options, next to the cursor
    local opts = {
        style = "minimal",
        relative = "cursor",
        width = #date_str_utc,
        height = 2,
        row = 1,
        col = 0,
        border = 'rounded',
    }
    -- Set the buffer to be non-modifiable and display
    vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
    vim.api.nvim_open_win(buf, true, opts)
end

-- }}}
return M
