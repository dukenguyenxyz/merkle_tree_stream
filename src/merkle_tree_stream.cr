require "flat_tree"

module MerkleTree
  class Node
    # Offset into the flat-tree data structure
    property index : UInt64
    # Reference to this node's parent node
    property parent : UInt64
    # Hash of the data
    property hash : Bytes?
    # Total size of all its child nodes combined
    property size : UInt64
    # Data if it's a leaf node, otherwise empty bytes
    property data : Bytes = Bytes.empty

    def initialize(@index, @parent, @size, @data, @hash)
    end
  end

  class Stream
    # Pass data through a hash function
    getter leaf : Proc(Node, Array(Node)?, Bytes)
    # Pass hashes through a hash function
    getter parent : Proc(Node, Node, Bytes)
    getter roots : Array(Node) = [] of Node
    getter blocks : UInt64

    # Create a new MerkleTreeStream instance
    def initialize(@leaf, @parent, @roots = [] of Node)
      @blocks = if @roots.size > 0
                  1_u64 + FlatTree.right_span(@roots.last.index) / 2_u64
                else
                  0_u64
                end.to_u64

      @roots.size.times do |i|
        r = @roots[i]
        r.parent = FlatTree.parent(r.index) if r && !r.parent
      end

      self
    end

    # Pass a string buffer through the flat-tree hash functions, and write the result back out to "nodes"
    def next(data : Bytes, nodes : Array(Node) = [] of Node) : Array(Node)
      index : UInt64 = 2_u64 * @blocks
      @blocks += 1

      leaf_node = Node.new(
        index: index,
        parent: FlatTree.parent(index),
        hash: nil,
        size: data.size.to_u64,
        data: data,
      )

      leaf_node.hash = @leaf.call(leaf_node, @roots)

      @roots.push(leaf_node)
      nodes.push(leaf_node)

      while @roots.size > 1
        left = @roots[-2]
        right = @roots.last
        break if left.parent != right.parent
        @roots.pop
        new_node = Node.new(
          index: left.parent,
          parent: FlatTree.parent(left.parent),
          hash: @parent.call(left, right),
          size: left.size + right.size,
          data: Bytes.empty,
        )

        @roots[-1] = new_node

        nodes.push(new_node)
      end

      nodes
    end
  end
end
