-- https://github.com/ewd3v/luau_noyield

local function resultHandler<T...>(thread: thread, ok: boolean, ...: T...): T...
	if not ok then
		local message = (...)
		error(debug.traceback(thread, message), 3)
	end

	-- If a call ever yields it will immedietly resume it's "parent thread" (this thread), calling this function.
	-- In which case the thread state will be something else like "suspended" instead of "dead"
	if coroutine.status(thread) ~= "dead" then
		error(debug.traceback(thread, "Attempt to yield in a noyield call"), 2)
	end

	return ...
end

local function noyield<T...>(callback: (T...) -> (), ...: T...)
	local thread = coroutine.create(callback)

	return resultHandler(thread, coroutine.resume(thread, ...))
end

return noyield