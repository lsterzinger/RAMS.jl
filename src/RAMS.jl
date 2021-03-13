module RAMS
"""
RAMS Julia Library

"""

using NCDatasets
using Dates
using ProgressMeter
using Statistics

"""
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
Function to read a variable from a list of RAMS data files.

# Arguments
- `flist::Array{String,1}`: 1D array of string file paths
- `varname::String`: Name of variable
- `dim_mean::Tuple`:(Optional) Dimenions to take mean over

# Returns
- `var::Array`: Output variable
"""
function RAMSVar(flist::Array{String,1}, varname::String; dim_mean=nothing)
    @showprogress for (i,f) in enumerate(flist)
        ds = Dataset(f)
        if i == 1 
            global nd = ndims(ds[varname]) 
            if dim_mean == nothing
                global var = ds[varname][:]
            else
                global var = dropdims(mean(ds[varname][:], dims=dim_mean); dims=dim_mean)
            end
        else
            if dim_mean === nothing
                var = cat(var, ds[varname][:], dims=(nd+1))
            else
                var = cat(var, dropdims(mean(ds[varname][:], dims=dim_mean); dims=dim_mean), dims=(nd+1))
            end
        end
    end
    return var
end
export RAMSVar

end # module
