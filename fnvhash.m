function [h, stat] = fnvhash(obj)

    sz = sizeof(obj);
    if sz == -1
        h = 0;
        stat = -1;
        return;
    else
        h = fnvhash_mex(obj,sz);
        stat = 0;
    end
    