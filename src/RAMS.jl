module RAMS
"""
RAMS Julia Library

"""

using HDF5
using Dates
using ProgressMeter
using Statistics

"""
    RAMSDates(flist)

Takes array of file paths and returns datetimes.

# Arguments
- `flist::Array{String,1}`: 1D array of string file paths 

# Returns
 - `dtarr::Array{DateTime,1}`: 1D array of datetimes
"""
function RAMSDates(flist::Array{String,1})

    dtregex = r"[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}"
    dtarr = DateTime[]
    for f in flist
        dtmatch = match(dtregex, f)
        if dtmatch === nothing
            throw(ErrorException("Filename did not match yyyy-mm-dd-hhmmss"))
        else
            year,month,day,time = split(dtmatch.match,'-')
            year = parse(Int, year)
            month = parse(Int, month)
            day = parse(Int, day)

            hour = parse(Int, time[1:2])
            minute = parse(Int, time[3:4])
            second = parse(Int, time[5:6])
            
            
            t = DateTime(Date(year, month, day), Time(hour, minute, second))
            push!(dtarr, t)
        
        end
    end
    return dtarr 
end
export RAMSDates

"""
    RAMSVar(flist, varname)

Function to read a variable from a list of RAMS data files.

# Arguments
- `flist::Array{String,1}`: 1D array of string file paths
- `varname::String`: Name of variable

# Returns
- `var::Array`: Output variable
"""
function RAMSVar(flist::Array{String,1}, varname::String; meandims=nothing)
    temp = h5read(flist[1], varname)
    nt = length(flist)
    dims = vcat(nt, [i for i in size(temp)])
    t = typeof(temp[1])
    var = zeros(t, dims...)

    @showprogress for (i,f) in enumerate(flist[1:end])
        selectdim(var,1,i) .= h5read(f, varname)
    end
    if meandims === nothing
        return var
    else
        return dropmean(var, meandims)
    end
end
export RAMSVar


"""
    dropmean(var, meandrop)
Function to drop dimensions used while taking a mean. 
Specify `meandrop` as a tuple of dimensions (e.g. `meandrop=(1,2)`)
"""
function dropmean(var, meandrop)
    return dropdims(mean(var, dims=meandrop), dims=meandrop)
end
export dropmean

end # module


"""
    vert_int_4d(array, ztn)
Vertically integrates a 4D array with dimensions `[time, x, y, z]`

#Returns:
- `var::Array`: Vertically integrated quantity with dimensions `[time, x, y]`
"""
function vert_int_4d(array, ztn)
    (nt, nx, ny, nz) = size(array)
    
    dims = (nt, nx, ny)
    
    t = typeof(array[1])
    var = zeros(t, dims)
    
    @showprogress for t in 1:nt
        for x in 1:nx
            for y in 1:ny
                s = 0.0
                for z in 2:nz
                    s  += ((array[t,x,y,z] + array[t,x,y,z-1]) / 2) * (ztn[z] - ztn[z-1])
                end
                var[t,x,y] = s
            end
        end
    end
    return array
end
export vert_int_4d


"""
    vert_int_2d(array, ztn)
Vertically integrates a 4D array with dimensions `[time, z]`

#Returns:
- `var::Array`: Vertically integrated quantity with dimensions `[time]``
"""
function vert_int_2d(array, ztn)
    (nt, nz) = size(array)
    
    dims = (nt,)

    t = typeof(array[1])
    var = zeros(t, dims)
    
    @showprogress for t in 1:nt
        s = 0.0
        for z in 2:nz
            s  += ((array[t,x,y,z] + array[t,x,y,z-1]) / 2) * (ztn[z] - ztn[z-1])
        end
        var[t] = s
    end
    return array
end
export vert_int_2d