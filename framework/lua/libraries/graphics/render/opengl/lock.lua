local render = ... or _G.render
local gl = desire("opengl")

local GL_ALREADY_SIGNALED = gl.e.GL_ALREADY_SIGNALED
local GL_CONDITION_SATISFIED = gl.e.GL_CONDITION_SATISFIED
local GL_WAIT_FAILED = gl.e.GL_WAIT_FAILED
local GL_SYNC_FLUSH_COMMANDS_BIT = gl.e.GL_SYNC_FLUSH_COMMANDS_BIT

local function range_overlaps(a, b)
	return a.start_offset < (b.start_offset + b.length) and b.start_offset < (a.start_offset + a.length)
end

local function wait(sync_obj)
	local wait_flags = 0
	local wait_duration = 0
	while true do
		local wait_ret = gl.ClientWaitSync(sync_obj, wait_flags, wait_duration)

		if wait_ret == GL_ALREADY_SIGNALED or wait_ret == GL_CONDITION_SATISFIED then
			return
		end

		if wait_ret == GL_WAIT_FAILED then
			error("uh oh")
		end

		wait_flags = GL_SYNC_FLUSH_COMMANDS_BIT
		wait_duration = 1000000000
	end
end

local buffer_locks = {}

function render.WaitForLockedRange(lock_begin_bytes, lock_length)
	local test_range = {
		start_offset = lock_begin_bytes,
		length = lock_length
	}

	local swap_locks = {}

	for i, buffer_lock in ipairs(buffer_locks) do
		if range_overlaps(test_range, buffer_lock.range) then
			wait(buffer_lock.sync_obj)
			gl.DeleteSync(buffer_lock.sync_obj)
		else
			table.insert(swap_locks, it)
		end
	end

	buffer_locks = swap_locks
end

function render.LockRange(lock_begin_bytes, lock_length)
	local buffer_lock = {
		range = {
			start_offset = lock_begin_bytes,
			length = lock_length,
		},
		sync_obj = gl.FenceSync("GL_SYNC_GPU_COMMANDS_COMPLETE", 0)
	}

	table.insert(buffer_locks, buffer_lock)
end