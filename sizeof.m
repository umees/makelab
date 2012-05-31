function sz = sizeof(d)

szel = sizeofclass(class(d));
if szel < 0
    sz = -1;
    return;
end

sz = numel(d)*szel;