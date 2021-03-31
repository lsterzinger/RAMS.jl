# Index

Welcome to RAMS.jl

## Installation
As of right now, RAMS.jl is not listed in the Julia repository. Instead, RAMS can be installed via:

```julia
using Pkg
Pkg.add(url="git@github.com:lsterzinger/RAMS.jl.git")
```
## Source
Source code can be found at [https://github.com/lsterzinger/RAMS.jl](https://github.com/lsterzinger/RAMS.jl)
# Getting started

## Listing RAMS files
[`list_files(dir)`](@ref) lists the files in `dir`:
```julia
using RAMS

list_files("./output/control/")
```

```
289-element Array{String,1}:
 "./output/control/control-A-2017-05-12-030000-g1.h5"
 "./output/control/control-A-2017-05-12-030500-g1.h5"
 "./output/control/control-A-2017-05-12-031000-g1.h5"
 "./output/control/control-A-2017-05-12-031500-g1.h5"
 "./output/control/control-A-2017-05-12-032000-g1.h5"
 "./output/control/control-A-2017-05-12-032500-g1.h5"
 "./output/control/control-A-2017-05-12-033000-g1.h5"
 "./output/control/control-A-2017-05-12-033500-g1.h5"
 "./output/control/control-A-2017-05-12-034000-g1.h5"
 "./output/control/control-A-2017-05-12-034500-g1.h5"
 ⋮
 "./output/control/control-A-2017-05-13-021500-g1.h5"
 "./output/control/control-A-2017-05-13-022000-g1.h5"
 "./output/control/control-A-2017-05-13-022500-g1.h5"
 "./output/control/control-A-2017-05-13-023000-g1.h5"
 "./output/control/control-A-2017-05-13-023500-g1.h5"
 "./output/control/control-A-2017-05-13-024000-g1.h5"
 "./output/control/control-A-2017-05-13-024500-g1.h5"
 "./output/control/control-A-2017-05-13-025000-g1.h5"
 "./output/control/control-A-2017-05-13-025500-g1.h5"
 "./output/control/control-A-2017-05-13-030000-g1.h5"

```

## Converting filenames to DateTime objects
One of the frustrating things with RAMS output is that there is no `time` variable in the output. [`RAMSDates(flist)`](@ref) allows you to convert the datetimes embedded in the filename into julia DateTime objects:

```julia
using RAMS

flist = list_files("./output/control/")
time = RAMSDates(flist)
```

```
289-element Array{Dates.DateTime,1}:
 2017-05-12T03:00:00
 2017-05-12T03:05:00
 2017-05-12T03:10:00
 2017-05-12T03:15:00
 2017-05-12T03:20:00
 2017-05-12T03:25:00
 2017-05-12T03:30:00
 2017-05-12T03:35:00
 2017-05-12T03:40:00
 2017-05-12T03:45:00
 ⋮
 2017-05-13T02:15:00
 2017-05-13T02:20:00
 2017-05-13T02:25:00
 2017-05-13T02:30:00
 2017-05-13T02:35:00
 2017-05-13T02:40:00
 2017-05-13T02:45:00
 2017-05-13T02:50:00
 2017-05-13T02:55:00
 2017-05-13T03:00:00
```

## Reading in a variable
Reading a variable can be accomplished with `RAMSVar(flist, "varname")`. For example:
```julia
using RAMS

flist = list_files("./output/control/")
rcp = RAMSVar(flist, "RCP")
```

## Dropping "empty" dimensions
In Julia, when using `Statistics.mean(dims=x)` to compute a mean along a dimension, the dimension in question still exists but has size `1`. This does not work with plotting packages such as `Plots.jl`. `RAMS.jl` includes [`dropmean(A, dims)`](@ref) to take a mean along a dimension.

For example:
```@example 1
# Create a random 5x5x10 array
x = randn((5,5,10))

using Statistics
x = mean(x, dims=(1,2))
size(x)
```

vs 

```@example 1
x = randn((5,5,10))

using RAMS
x = dropmean(x, (1,2))
size(x)
```