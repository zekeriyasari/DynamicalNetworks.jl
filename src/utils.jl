# This file includes utility functions 

export isirreducible, isdiffusive, isnondiffusive, initmat

"""
    $SIGNATURES 

Returns true if `mat` is an irreducible matrix. 
"""
isirreducible(mat::AbstractMatrix) = is_strongly_connected(SimpleDiGraph(mat))

"""
    $SIGNATURES

Returns true if `mat` is diffusively coupled matrix. 
"""
isdiffusive(mat::AbstractMatrix) = iszero(sum(mat, dims=2))

"""
    Returns true if `mat` is nonnegative diffusively coupled. 
"""
isnondiffusive(mat::AbstractMatrix) = mat[[idx for idx in 1 : length(mat) if idx ∉ diagind(mat)]] .≥ 0


# Helper functions for construction of initial connection matrices 

function initmat(cls::Cluster, method::UndirectedCluster, topology=complete_graph)
    n = length(cls.nodes) 
    l = length(cls.pinnednodes) 
    k = clusterindex(cls)
    Φ = BlockArray(zeros(n, n), k, k) 
    for i in 1 : l 
        setblock!(Φ, ondiagmat(topology, k[i]), i, i)
    end 
    for i in 1 : l - 1, j in i + 1 : l 
        bmat = offdiagmat(k[i], k[j])
        setblock!(Φ, bmat, i, j)
        setblock!(Φ, bmat', j, i)
    end 
    all(sum(Φ, dims=2) .== 0.) || error("Zero row sum property is not satisfied\nΦ:$(Φ)")
    Φ
end

function ondiagmat(topology=complete_graph, args...; kwargs...) 
    graph = topology(args...; kwargs...)
    is_strongly_connected(SimpleDiGraph(graph)) ||  error("Could not costruct irreducible matrix")
    mat = -collect(laplacian_matrix(graph))
    mat 
end 

function offdiagmat(nrows, ncols) 
    mat = rand(0.: 1., nrows, ncols) 
    idx = diagind(mat) 
    mat[idx] .= 0 
    mat[idx] -= sum(mat, dims=2)
    mat 
end 
