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
