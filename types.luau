--!strict

-- Simple documents do not hold sessions or state.
-- Example usage: a group or "clan" of players.

export type function immut(t: type): type
	assert(t:is("table"), "t must be table")
	local t2 = types.newtable()
	for k, v in t:properties() do
		t2:setreadproperty(k, v.read)
	end
	return t2
end

export type function deep_immut(t: type): type
	assert(t:is("table"), "t must be table")
	local t2 = types.newtable()
	for k, v in t:properties() do
		local value = v.read
		if value and value:is("table") then
			value = deep_immut(value)
		end
		t2:setreadproperty(k, value)
	end
	return t2
end

export type function deep_mut(t: type): type
	assert(t:is("table"), "t must be table")
	local t2 = types.newtable()
	for k, v in t:properties() do
		local value = v.read
		if value and value:is("table") then
			value = deep_mut(value)
		end
		t2:setproperty(k, value)
	end
	return t2
end

export type function mut(t: type): type
	assert(t:is("table"), "t must be table")
	local t2 = types.newtable()
	for k, v in t:properties() do
		t2:setproperty(k, v.read)
	end
	return t2
end

type test = deep_mut<{
	read field1: string,
	read tab1: {
		read inner1: string,
		tab2: {
			read inner2: number,
			inner3: number
		}
	}
}>

type test2 = deep_immut<{
	read field1: string,
	read tab1: {
		read inner1: string,
		tab2: {
			read inner2: number,
			inner3: number
		}
	}
}>

type t1 = immut<{
	hello: string,
}>

type t2 = mut<t1>

-- type of a static api for getting simpledocument objcts
export type GetSimpleDocument<T> = ({
	key: string,
	dataStore: DataStoreInterface,
	migrationList: MigrationList<T>,
}) -> SimpleDocument<T>

export type SimpleDocument<T> = {
	-- Private
	_key: string,
	_data_store: DataStoreInterface,
	_migrations: MigrationList<T>,
	-- Public
	read readAsync: () -> Result<T?, RobloxAPIError | BackwardsCompatibilityError | CorruptionError>,
	-- updateAsync will always migrate before passing data
	read updateAsync: (transform: (T?) -> T) -> Result<T?, RobloxAPIError | BackwardsCompatibilityError | CorruptionError>,
}

export type DocState = "Live" | "Releasing"

-- Increasingly in favour of keeping session locking state local. Update it
-- instantly, then call a save. That way any saves that occur during the yield
-- won't overwrite the lock.

export type Document<T> = {
	-- Private
	read _key: string,
	read _data_store: DataStoreInterface,
	read _session_id: string,
	-- instead of both is_locked and an expiry, why not just set session_expiry to 0?
	_session_expiry: number,
	read _migrations: MigrationList<T>,
	read _default: T,
	_state: DocState,
	_data: T,
	-- Public
	read getState: () -> DocState,
	read savedSignal: never,
	read releasedSignal: never,
	read read: () -> deep_immut<T>,
	read update: ((mut<deep_immut<T>>) -> T) -> (), -- clone top level by default
	read saveAsync: () -> WriteResult<nil>, -- if releasing, just wait for the release
	-- and return the release result. we could probably also deduce if releasing by
	-- if the local expiry time is set to 0.
	read releaseAsync: () -> WriteResult<nil>,
	read releaseToMemoryAsync: () -> WriteResult<nil> -- For fast teleportation.
	-- Don't force the user to use DataStore as a backup, but they can easily manually
	-- implement DataStore as a backup.
}

export type DocumentStore<T> = {
	read _key: string,
	read _dataStore: DataStoreInterface,
	read _migrationList: MigrationList<T>,
	read _openingKeys: { string },
	read claimAsync: (key: string, stealAfterSeconds: number?) -> ClaimResult<Document<T>>,
	read claimFromMemoryAsync: (key: string) -> Result<Document<T>, "BackwardsCompatibilityError" | "RobloxAPIError" | "NotInMemoryStore">
}

export type Ok<T> = {
	ok: true,
	data: T,
}
export type Fail<Reason> = {
	ok: false,
	reason: Reason,
}
export type Result<T, Reason> = Ok<T> | Fail<Reason>
export type RobloxAPIError = "RobloxAPIError"
export type SessionNotOwned = "SessionNotOwned"
export type Locked = "Locked" -- Session not owned and locked are different!
export type CheckError = "CheckError"
export type BackwardsCompatibilityError = "BackwardsCompatibilityError"
export type CorruptionError = "CorruptionError"
export type NotInMemoryStore = "NotInMemoryStore"

export type MigrationList<T> = {
	legacy: {(data: any) -> (any, boolean)}?,
	latest: (data: {}) -> (T, boolean)
}

export type ClaimResult<T> = Result<T, RobloxAPIError | BackwardsCompatibilityError | Locked>
export type WriteResult<T> = Result<T, RobloxAPIError | SessionNotOwned | CorruptionError>
export type ReadResult<T> = Result<T, RobloxAPIError | CorruptionError | BackwardsCompatibilityError>

export type DataStoreInterface = {
	UpdateAsync: (
		DataStoreInterface,
		key: string,
		(any, DataStoreKeyInfo) -> (any, { number }?, any?)
	) -> (any, DataStoreKeyInfo),
	GetAsync: (DataStoreInterface, key: string, options: DataStoreGetOptions) -> (any, DataStoreKeyInfo),
	RemoveAsync: (DataStoreInterface, key: string) -> (any, DataStoreKeyInfo),
}

export type HookEvent = "Open" | "Close" | "Update" | "Read"

return nil
