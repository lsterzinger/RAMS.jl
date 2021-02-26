module RAMS
using NCDatasets
using Dates
using ProgressMeter

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

function RAMSVar(flist::Array{String,1}, varname::String)
    @showprogress for (i,f) in enumerate(flist)
        ds = Dataset(f)
        if i == 1 
            global nd = ndims(ds[varname]) 
            global var = ds[varname][:]
        else
            var = cat(var, ds[varname][:], dims=(nd+1))
        end
    end
    return var
end
export RAMSVar

end # module
