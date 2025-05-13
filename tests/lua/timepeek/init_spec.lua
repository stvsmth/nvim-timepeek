describe('timepeek.setup', function()
    local timepeek
    local default_config_ref -- To store original default_config

    before_each(function()
        -- Reset the module to ensure a clean state for each test
        -- and to get a fresh copy of the config tables
        package.loaded['timepeek'] = nil
        timepeek = require('timepeek')
        -- Store a deep copy of the original default_config for comparison
        default_config_ref = vim.deepcopy(timepeek.default_config)
    end)

    it('should load default config if no options are provided', function()
        timepeek.setup()
        assert.are.same(default_config_ref, timepeek.config)
    end)

    it('should merge user options with default config', function()
        local user_opts = {
            window = {
                border = 'single',
            },
            formats = {
                utc = 'test_utc_format',
            },
        }
        timepeek.setup(user_opts)

        assert.are.equal('single', timepeek.config.window.border)
        assert.are.equal('test_utc_format', timepeek.config.formats.utc)
        -- Check that a field not in user_opts remains from default_config
        assert.are.equal(default_config_ref.formats.local_time, timepeek.config.formats.local_time)
        -- Check that a table not in user_opts remains from default_config
        assert.are.equal(default_config_ref.mappings.peek, timepeek.config.mappings.peek)
    end)

    it('should not set up keymaps if use_default_mappings is false', function()
        -- Mock vim.keymap.set
        local keymap_set_calls = {}
        local original_vim_keymap_set = vim.keymap.set
        vim.keymap.set = function(mode, lhs, rhs, opts)
            table.insert(keymap_set_calls, { mode = mode, lhs = lhs, rhs = rhs, opts = opts })
        end

        timepeek.setup({ use_default_mappings = false })
        assert.are.equal(0, #keymap_set_calls)

        -- Restore original vim.keymap.set
        vim.keymap.set = original_vim_keymap_set
    end)

    it('should set up default keymap if use_default_mappings is true and peek mapping exists', function()
        -- Mock vim.keymap.set
        local keymap_set_calls = {}
        local original_vim_keymap_set = vim.keymap.set
        vim.keymap.set = function(mode, lhs, rhs, opts)
            table.insert(keymap_set_calls, { mode = mode, lhs = lhs, rhs = rhs, opts = opts })
        end

        timepeek.setup({ use_default_mappings = true }) -- Relies on default_config.mappings.peek

        assert.are.equal(1, #keymap_set_calls)
        assert.are.equal('n', keymap_set_calls[1].mode)
        assert.are.equal(default_config_ref.mappings.peek, keymap_set_calls[1].lhs)
        assert.is_function(keymap_set_calls[1].rhs)

        -- Restore original vim.keymap.set
        vim.keymap.set = original_vim_keymap_set
    end)
end)

describe('timepeek.render_date', function()
    local timepeek
    local original_vim_fn_expand
    local original_vim_api_nvim_win_get_config
    local original_os_date
    local original_vim_api_nvim_create_buf
    local original_vim_api_nvim_buf_set_lines
    local original_vim_api_nvim_set_option_value
    local original_vim_api_nvim_buf_set_keymap
    local original_vim_api_nvim_open_win

    local mock_calls -- To store calls to mocked functions

    before_each(function()
        package.loaded['timepeek'] = nil
        timepeek = require('timepeek')
        timepeek.setup() -- Initialize with default config

        mock_calls = {
            expand_cword_return = '', -- Default return for vim.fn.expand('<cWORD>')
            nvim_win_get_config_return = { relative = '' }, -- Default for nvim_win_get_config
            nvim_create_buf = {},
            nvim_buf_set_lines = {},
            nvim_set_option_value = {},
            nvim_buf_set_keymap = {},
            nvim_open_win = {},
            os_date = {},
        }

        -- Store original functions
        original_vim_fn_expand = vim.fn.expand
        original_vim_api_nvim_win_get_config = vim.api.nvim_win_get_config
        original_os_date = os.date
        original_vim_api_nvim_create_buf = vim.api.nvim_create_buf
        original_vim_api_nvim_buf_set_lines = vim.api.nvim_buf_set_lines
        original_vim_api_nvim_set_option_value = vim.api.nvim_set_option_value
        original_vim_api_nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap
        original_vim_api_nvim_open_win = vim.api.nvim_open_win

        -- Mock functions
        vim.fn.expand = function(arg)
            if arg == '<cWORD>' then
                return mock_calls.expand_cword_return
            end
            return original_vim_fn_expand(arg) -- Call original for other args
        end

        vim.api.nvim_win_get_config = function(winid)
            -- Allow specific return value per test, or default
            return mock_calls.nvim_win_get_config_return
        end

        os.date = function(format, timestamp)
            table.insert(mock_calls.os_date, { format = format, timestamp = timestamp })
            if format == timepeek.config.formats.utc then
                return 'mock_utc_date'
            elseif format == timepeek.config.formats.local_time then
                return 'mock_local_date'
            end
            return original_os_date(format, timestamp) -- Call original for other formats
        end

        vim.api.nvim_create_buf = function(listed, scratch)
            local buf_id = 99 -- mock buffer id
            table.insert(mock_calls.nvim_create_buf, { listed = listed, scratch = scratch, returned_buf_id = buf_id })
            return buf_id
        end

        vim.api.nvim_buf_set_lines = function(buffer, start, end_, strict_indexing, replacement)
            table.insert(mock_calls.nvim_buf_set_lines, {
                buffer = buffer,
                start = start,
                end_ = end_,
                strict_indexing = strict_indexing,
                replacement = replacement,
            })
        end

        vim.api.nvim_set_option_value = function(name, value, opts)
            table.insert(mock_calls.nvim_set_option_value, { name = name, value = value, opts = opts })
        end

        vim.api.nvim_buf_set_keymap = function(buffer, mode, lhs, rhs, opts)
            table.insert(mock_calls.nvim_buf_set_keymap, {
                buffer = buffer,
                mode = mode,
                lhs = lhs,
                rhs = rhs,
                opts = opts,
            })
        end

        vim.api.nvim_open_win = function(buffer, enter, opts)
            table.insert(mock_calls.nvim_open_win, { buffer = buffer, enter = enter, opts = opts })
            return 1 -- mock window id
        end
    end)

    after_each(function()
        -- Restore original functions
        vim.fn.expand = original_vim_fn_expand
        vim.api.nvim_win_get_config = original_vim_api_nvim_win_get_config
        os.date = original_os_date
        vim.api.nvim_create_buf = original_vim_api_nvim_create_buf
        vim.api.nvim_buf_set_lines = original_vim_api_nvim_buf_set_lines
        vim.api.nvim_set_option_value = original_vim_api_nvim_set_option_value
        vim.api.nvim_buf_set_keymap = original_vim_api_nvim_buf_set_keymap
        vim.api.nvim_open_win = original_vim_api_nvim_open_win
    end)

    it('should display date window for a valid timestamp', function()
        mock_calls.expand_cword_return = '1098938400' -- Valid timestamp
        -- nvim_win_get_config_return defaults to { relative = '' }

        timepeek.render_date()

        assert.are.equal(1, #mock_calls.nvim_create_buf, 'nvim_create_buf should be called once')
        assert.are.equal(1, #mock_calls.nvim_open_win, 'nvim_open_win should be called once')

        assert.are.equal(2, #mock_calls.os_date, 'os.date should be called twice')
        assert.are.same(timepeek.config.formats.utc, mock_calls.os_date[1].format)
        assert.are.same(1098938400, mock_calls.os_date[1].timestamp)
        assert.are.same(timepeek.config.formats.local_time, mock_calls.os_date[2].format)
        assert.are.same(1098938400, mock_calls.os_date[2].timestamp)

        assert.are.equal(1, #mock_calls.nvim_buf_set_lines, 'nvim_buf_set_lines should be called once')
        local lines_set = mock_calls.nvim_buf_set_lines[1].replacement
        assert.are.same({ '  mock_utc_date  ', '  mock_local_date  ' }, lines_set)

        local open_win_opts = mock_calls.nvim_open_win[1].opts
        assert.are.equal(timepeek.config.window.border, open_win_opts.border)
        assert.are.equal(#'  mock_utc_date  ', open_win_opts.width)
        assert.are.equal(2, open_win_opts.height)

        -- Check keymaps for the new buffer
        assert.True(#mock_calls.nvim_buf_set_keymap >= 2, 'Should set at least CR and ESC keymaps')
        local cr_map_found = false
        local esc_map_found = false
        for _, map_call in ipairs(mock_calls.nvim_buf_set_keymap) do
            if map_call.buffer == mock_calls.nvim_create_buf[1].returned_buf_id then
                if map_call.lhs == '<CR>' then
                    cr_map_found = true
                end
                if map_call.lhs == '<ESC>' then
                    esc_map_found = true
                end
            end
        end
        assert.True(cr_map_found, '<CR> keymap should be set for the buffer')
        assert.True(esc_map_found, '<ESC> keymap should be set for the buffer')
    end)

    it('should not display date window if word under cursor is not a timestamp', function()
        mock_calls.expand_cword_return = 'not_a_timestamp'
        -- nvim_win_get_config_return defaults to { relative = '' }

        timepeek.render_date()

        assert.are.equal(0, #mock_calls.nvim_create_buf, 'nvim_create_buf should not be called')
        assert.are.equal(0, #mock_calls.nvim_open_win, 'nvim_open_win should not be called')
        assert.are.equal(0, #mock_calls.os_date, 'os.date should not be called')
    end)

    it('should not display date window if already inside a relative window', function()
        mock_calls.expand_cword_return = '1098938400' -- Valid timestamp
        mock_calls.nvim_win_get_config_return = { relative = 'cursor' } -- Simulate being in a relative window

        timepeek.render_date()

        assert.are.equal(0, #mock_calls.nvim_create_buf, 'nvim_create_buf should not be called')
        assert.are.equal(0, #mock_calls.nvim_open_win, 'nvim_open_win should not be called')
    end)

    it('should display date window for a valid millisecond timestamp', function()
        mock_calls.expand_cword_return = '1098938400000' -- Valid millisecond timestamp
        -- nvim_win_get_config_return defaults to { relative = '' }

        timepeek.render_date()

        assert.are.equal(1, #mock_calls.nvim_create_buf, 'nvim_create_buf should be called once')
        assert.are.equal(1, #mock_calls.nvim_open_win, 'nvim_open_win should be called once')

        assert.are.equal(2, #mock_calls.os_date, 'os.date should be called twice')
        -- Check that os.date was called with the timestamp in seconds
        assert.are.same(1098938400, mock_calls.os_date[1].timestamp)
        assert.are.same(1098938400, mock_calls.os_date[2].timestamp)

        local lines_set = mock_calls.nvim_buf_set_lines[1].replacement
        assert.are.same({ '  mock_utc_date  ', '  mock_local_date  ' }, lines_set)
    end)

    it('should not display date window for a timestamp that is too large (16+ digits)', function()
        mock_calls.expand_cword_return = '1000000000000000' -- 16-digit number
        -- nvim_win_get_config_return defaults to { relative = '' }

        timepeek.render_date()

        assert.are.equal(0, #mock_calls.os_date, 'os.date should not be called')
        assert.are.equal(0, #mock_calls.nvim_create_buf, 'nvim_create_buf should not be called')
        assert.are.equal(0, #mock_calls.nvim_open_win, 'nvim_open_win should not be called')
    end)
end)
