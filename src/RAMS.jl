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
function RAMSVar(flist::Array{String,1}, varname::String)
    temp = h5read(flist[1], varname)
    nt = length(flist)
    dims = vcat(nt, [i for i in size(temp)])
    t = typeof(temp[1])
    var = zeros(t, dims...)

    @showprogress for (i,f) in enumerate(flist[2:end])
        selectdim(var,1,1) .= h5read(f, varname)
    end
    return var
end
export RAMSVar

end # module
