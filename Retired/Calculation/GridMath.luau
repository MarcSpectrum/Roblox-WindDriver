local GridMath = {}

function GridMath.GetDistance(A, Z)
    A = string.split(A, ':') ;
    Z = string.split(Z, ':') ;
    local Aw, Al = A[1], A[2] ;
    local Zw, Zl = Z[1], Z[2] ;
    return math.abs(math.sqrt(((Zw - Aw)^2) + ((Zl - Al)^2))) ;
end

function GridMath.GetClose4Tiles(A)
    A = string.split(A, ':') ;
    local A1, A2 = A[1], A[2] ;
    return {
        ['Up'] = A1+1 .. ':' .. A2 ;
        ['Down'] = A1-1 .. ':' .. A2 ;
        ['Right'] = A1 .. ':' .. A2+1 ;
        ['Left'] = A1 .. ':' .. A2-1 ;
    }
end

function GridMath.PathFinding(A :string, Z :string, fltr :{})
    ------------ >> cleanup
    fltr = fltr or {} ;

    ------------ >> setup
    local rslt = {A} ;
    local rdd = {} ;
    rdd[A] = true ;
    
    ------------ >> running
    while true do
        local strt = rslt[#rslt] ;
        local strt_frnd = GridMath.GetClose4Tiles(strt) ;
        local nxt, nxt_dst ;
        for _, v in strt_frnd do
            if not fltr[v] then continue end
            if rdd[v] then continue end ;
            rdd[v] = true ;
            local dst_nw = GridMath.GetDistance(v, Z) ;
            if nxt_dst and dst_nw > nxt_dst then continue end ;
            nxt_dst = dst_nw ;
            nxt = v ;
        end
        if not nxt then break end ;
        table.insert(rslt, nxt) ;
        if nxt == Z then break end ;
        if #rdd >= #rslt then break end ;
    end
    if rslt[#rslt] ~= Z then rslt  = {} end ;

    return rslt
end

return GridMath