local crypt = require "skynet.crypt"
local skynet = require "skynet"
local LoginCmd require("login_cmd")

local LoginServer = {
    host = "127.0.0.1",
    port = 8001,
    multilogin = false,
    name = "login_master",
}

function LoginServer.auth_handler(token)
    -- token: base64(user)@base64(server):base64(password)
    local user, server, password = token:match("([^@]+)@([^:]+):(.+)")
    user = crypt.base64decode(user)
    server = crypt.base64decode(server)
    password = crypt.base64decode(password)
    skynet.error(string.format("%s@%s:%s", user, server, password))
    assert(password == "password", "Invalid password")
    return server, user
end

local subid = 0
function LoginServer.login_handler(server, uid, secret)
    skynet.error(string.format("%s@%s login, secret: %s", uid, server, crypt.hexencode(secret)))
    subid = subid + 1 --分配唯一的subid
    return subid
end

function LoginServer.command_handler(command, ...)
    local f = assert(LoginCmd[command])
    return f(...)
end

return LoginServer
