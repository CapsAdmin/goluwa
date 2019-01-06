local translate = {
    includes = "-I",
    defines = "-D",
    warnings = "-W",
    optimization = "-O",
    flags = "-f",
    debug = "-g",
}

function gcc(data)
    local cmd = {"gcc"}
    for name, option in pairs(translate) do
        if data[name] then
            if type(data[name]) == "string" then
                data[name] = {data[name]}
            end

            for k,v in pairs(data[name]) do
                if name == "defines" then
                    if v == true then
                        table.insert(cmd, option .. k)
                    elseif v == false then
                        table.insert(cmd, "-U" .. k)
                    else
                        table.insert(cmd, option .. "'" .. k .. "=" .. v .. "'")
                    end
                else
                    table.insert(cmd, option .. v)
                end
            end
        end
    end

    local gcc = table.concat(cmd, " ")
    local cmds = {}

    local output_files = {}

    for _, path in ipairs(data.files) do
        local output_path = vfs.RemoveExtensionFromPath(path) .. ".o"
        table.insert(output_files, output_path)
        table.insert(cmds, gcc .. " -c -o " .. output_path .. " " .. path)
    end

    vfs.PushWorkingDirectory(R(data.directory))
        for _, cmd in ipairs(cmds) do
            if not os.execute(cmd) then
                break
            end
        end

        os.execute("gcc " .. table.concat(output_files, " ") .. " -O -shared -fpic -o " .. data.output_library)
    vfs.PopWorkingDirectory()

    local path = data.directory .. "/" .. data.output_library

    print(package.loadlib(path, data.luaopen))
    table.print(utility.GetLikelyLibraryDependencies(path))
end

gcc({
    directory = e.TEMP_FOLDER .. "/ffibuild/luasocket/src",
    includes = "/usr/include/lua5.1",
    defines = {
        LUASOCKET_NODEBUG = true,
        LUASOCKET_API = "__attribute__((visibility(\"default\")))",
        UNIX_API = "__attribute__((visibility(\"default\")))",
        MIME_API = "__attribute__((visibility(\"default\")))",
    },
    warnings = {"all", "shadow", "extra", "implicit"},
    optimization = "2",
    flags = {"pic", "visibility=hidden"},
    debug = "gdb",
    files = {
        "luasocket.c",
        "timeout.c",
        "buffer.c",
        "io.c",
        "auxiliar.c",
        "options.c",
        "inet.c",
        "except.c",
        "select.c",
        "tcp.c",
        "udp.c",

        "usocket.c", -- if linux then
    },
    output_library = "socket.so",
    luaopen = "luaopen_socket_core",
})
