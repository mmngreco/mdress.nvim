M = {}

local function write_fenced_md (file_name, file_type, file_name_out)

    local file_content = io.open(file_name, 'r')
    local file_out = io.open(file_name_out, 'w')

    if file_content and file_out then
        file_content = file_content:read('*all')
        local out = '```' .. file_type .. '\n' .. file_content .. '\n```\n'
        file_out:write(out)
        file_out:close()
    end
end


local function serve_buff (bufname, origin_bufno)
    vim.api.nvim_command('edit ' .. bufname)
    vim.api.nvim_command('buffer ' .. bufname)
    vim.api.nvim_command('MarkdownPreview')
    -- back to origin buffer
    vim.api.nvim_command('buffer ' .. origin_bufno)
end


local function update_buff(bufname, origin_bufno)
    vim.api.nvim_command('buffer ' .. bufname)
    vim.api.nvim_command('edit! ' .. bufname)
    -- go to last line
    vim.api.nvim_command('norm G')

    -- back to origin buffer
    vim.api.nvim_command('buffer ' .. origin_bufno)
end


local function new_md_file(file_name)
    -- remove path and extension
    local fname = file_name:gsub('.*/', ''):gsub('%.%w+', '')
    local file_out = os.tmpname() .. '_' .. fname .. '_mdress.md'
    M[file_name] = file_out
    return file_out
end

function Mdress ()
    -- get buf number
    local origin_bufno = vim.api.nvim_get_current_buf()
    -- local origin_bufname = vim.api.nvim_buf_get_name(origin_bufno)

    local file_name = vim.fn.expand('%:p')
    local file_type = vim.bo.filetype
    local file_out = M[file_name]

    if not file_out then
        file_out = new_md_file(file_name)
        write_fenced_md(file_name, file_type, file_out)
        serve_buff(file_out, origin_bufno)
    else
        write_fenced_md(file_name, file_type, file_out)
        update_buff(file_out, origin_bufno)
    end

    -- create autocmd
    vim.api.nvim_create_autocmd(
        "BufWritePost",
        {
            group = vim.api.nvim_create_augroup('Mdress', {clear=true}),
            pattern = file_name,
            callback = Mdress,
        }
    )

end

vim.api.nvim_create_user_command('Mdress', Mdress, {})
