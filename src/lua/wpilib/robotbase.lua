local ffi = require("ffi")

function IsReal() 
    return ffi.C.IsReal()
end