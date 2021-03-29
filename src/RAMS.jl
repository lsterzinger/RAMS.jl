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


"""
    vert_int_4d(var, ztn; notime=false)
Vertically integrate `var` along `z` axis with heights specified in `ztn`. 
Assumes that `var` has dimensions `[t, x, y, z]`

Specify `notime=true` to allow for `var`s with no `t` dimension (will also be 
omitted from `int_var`)

# Returns:
- `int_var::Array`: Integrated array with dimensions `[t,x,y]`
"""
function vert_int_4d(var, ztn; notime=false)
    if notime == false
        (nt, nx, ny, nz) = size(var)
        int_var = zeros(typeof(var[1]), (nt, nx, ny))

        @showprogress for t=1:nt
            for x=1:nx, y=1:ny
                s = 0.0
                for z in 2:nz
                    s += ((var[t,x,y,z] + var[t,x,y,z-1])/2) * (ztn[z] - ztn[z-1])
                end
                int_var[t,x,y] = s
        
            end
        end
        return int_var
    else
        (nx, ny, nz) = size(var)
        int_var = zeros(typeof(var[1]), (nx, ny))

        for x=1:nx, y=1:ny
            s = 0.0
            for z in 2:nz
                s += ((var[x,y,z] + var[x,y,z-1])/2) * (ztn[z] - ztn[z-1])
            end
            int_var[x,y] = s
    
        end
        return int_var
    end
end
export vert_int_4d


"""
    list_files(dir)
List all RAMS data files (`*.h5`) in `dir`.
"""
function list_files(dir)
    flist = readdir(dir)
	outlist = String[]
    for f in flist
    	m = match(r"^.*\.h5$", f)
        if !isnothing(m)
        	push!(outlist, m.match)
		end
	end
    return outlist
end
export list_files
end # module
