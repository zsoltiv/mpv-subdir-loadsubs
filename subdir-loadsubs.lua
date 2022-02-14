local mp = require 'mp'
local utils = require 'mp.utils'

local function get_sub_dirs()
    local sub_dirs_str = mp.get_property('sub-file-paths')
    local cwd = utils.getcwd()
    local paths = {}

    for path in string.gmatch(sub_dirs_str, "([^,]+)") do
        --table.insert(paths, utils.join_path(cwd, path))
        table.insert(paths, path)
    end

    return paths
end

local function is_sub_file(filepath)
    -- https://codereview.stackexchange.com/a/90231
    local extension = filepath:match("^.+(%..+)$")
    if extension ~= nil then
        return extension == '.ass' or extension == '.srt'
    end
end

local function load_subs_from_dir(dirpath)
    local contents = utils.readdir(dirpath)
    if contents ~= nil then
        for _, v in pairs(contents) do
            local filepath = utils.join_path(dirpath, v)
            -- load subtitle files recursively
            local stats = utils.file_info(filepath)
            if stats.is_dir then
                load_subs_from_dir(filepath)
            elseif stats.is_file and is_sub_file(filepath) then
                print(filepath)
                local ret, err = mp.commandv('sub-add', filepath)
                if ret == nil then print(err) end
            end
        end
    end
end

local function load_sub_files_from_subdirs()
    local paths = get_sub_dirs()
    for _, v in pairs(paths) do
        load_subs_from_dir(v)
    end
end

mp.add_hook('on_preloaded', 50, load_sub_files_from_subdirs)
