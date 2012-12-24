##############################################################################
#
# Basic graph type definitions and constructors
#
##############################################################################

# TODO: Debate data structures. Use sets?
# TODO: Add a Multigraph type
# TODO: Enforce integrity constraints during construction
#       * Min vertex ID = 1
#       * Max vertex ID = length(vertices)

type UndirectedGraph
    vertices::Vector{Vertex}
    edges::Vector{UndirectedEdge}
end

type DirectedGraph
    vertices::Vector{Vertex}
    edges::Vector{DirectedEdge}
end
typealias Digraph DirectedGraph
typealias Graph Union(UndirectedGraph, DirectedGraph)

function DirectedGraph(vertex_names::Vector{UTF8String}, numeric_edges::Matrix{Int})
    n_vertices = length(vertex_names)
    n_edges = size(numeric_edges, 1)

    vertices = Array(Vertex, n_vertices)
    for i in 1:n_vertices
        vertices[i] = Vertex(i, vertex_names[i])
    end

    edges = Array(DirectedEdge, n_edges)
    for i in 1:n_edges
        edges[i] = DirectedEdge(vertices[numeric_edges[i, 1]],
                                vertices[numeric_edges[i, 2]],
                                utf8(""),
                                1.0)
    end

    return DirectedGraph(vertices, edges)
end

function DirectedGraph{T <: String}(edges::Matrix{T})
    default_max_vertices = 1_000
    vertex_names = Array(UTF8String, default_max_vertices)
    vertex_ids = Dict{UTF8String, Int}()

    next_vertex_id = 1
    numeric_edges = Array(Int, size(edges))

    for i in 1:size(edges, 1)
        if length(vertex_names) - 1 <= next_vertex_id
            grow(vertex_names, 2 * length(vertex_names))
        end

        out_vertex_name, in_vertex_name = edges[i, 1], edges[i, 2]

        out_vertex_id = get(vertex_ids, out_vertex_name, 0)
        if out_vertex_id == 0
            out_vertex_id = next_vertex_id
            vertex_ids[out_vertex_name] = out_vertex_id
            vertex_names[out_vertex_id] = out_vertex_name
            next_vertex_id += 1
        end

        in_vertex_id = get(vertex_ids, in_vertex_name, 0)
        if in_vertex_id == 0
            in_vertex_id = next_vertex_id
            vertex_ids[in_vertex_name] = in_vertex_id
            vertex_names[in_vertex_id] = in_vertex_name
            next_vertex_id += 1
        end

        numeric_edges[i, 1], numeric_edges[i, 2] = out_vertex_id, in_vertex_id
    end

    return DirectedGraph(vertex_names[1:(next_vertex_id - 1)], numeric_edges)
end

##############################################################################
#
# Basic properties of a graph
#
##############################################################################

vertices(g::Graph) = g.vertices
edges(g::Graph) = g.edges
order(g::Graph) = length(vertices(g))
size(g::Graph) = length(edges(g))
