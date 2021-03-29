using Documenter, RAMS

makedocs(
    sitename="RAMS.jl",
    pages = [
        "Index" => "index.md",
        "API Reference" => "apiref.md"
    ]
)

deploydocs(
    repo="github.com/lsterzinger/RAMS.jl.git"
)