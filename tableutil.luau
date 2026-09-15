local types = require('./types')

local m = {}

function m.clone<T>(t: T): types.mut<T>
    return table.clone(t) :: types.mut<T>
end

function m.deepClone<T>(t: T): types.deep_mut<T>

end

return m