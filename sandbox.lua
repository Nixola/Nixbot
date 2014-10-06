local iOpen, iPopen = io.open, io.popen

function string.safify(string)

	local f = iOpen('/tmp/pattern', 'w')

	f:write(string)

	f:close()

	f = iPopen([[sed -r "s/(.)\+(\1\+)+/\1\1+/g" /tmp/pattern]], 'r')

	local l = f:read '*l'

	f:close()

	return l

end

os = {time = os.time, clock = os.clock, date = os.date, difftime = os.difftime}
package.loaded.os = os
io = {write = io.write}
package.loaded.io = io
package.loaded._G = _G
package.loadlib = nil
--debug = {getmetatable = debug.getmetatable}
debug = {}
package.loaded.debug = {}
require = nil
dofile = nil
loadfile = nil
loadstring = nil
load = nil
package.loaders = {}
jit = {arch = jit.arch, version = jit.version, os = jit.os, version_num = jit.version_num}
