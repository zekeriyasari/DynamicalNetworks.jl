using Documenter, DynamicalNetworks

DocMeta.setdocmeta!(DynamicalNetworks, :DocTestSetup, :(using DynamicalNetworks); recursive=true)

makedocs(;
    modules=[DynamicalNetworks],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "Notes" => "notes/networks.md",
    ],
    repo="https://github.com/zekeriyasari/DynamicalNetworks.jl/blob/{commit}{path}#L{line}",
    sitename="DynamicalNetworks.jl",
    authors="Zekeriya SARI",
)

deploydocs(;
    repo="github.com/zekeriyasari/DynamicalNetworks.jl",
)
