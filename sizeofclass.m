function sz = sizeofclass(typestr)

switch typestr
    case {'double', 'int64', 'uint64'}
        sz = 8;
    case {'single', 'int32', 'uint32', 'char'}
        sz = 4;
    case {'int16', 'uint16'}
        sz = 2;
    case {'int8', 'uint8'}
        sz = 1;
    otherwise
        sz = -1;
end