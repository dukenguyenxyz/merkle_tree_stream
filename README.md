# merkle_tree_stream

[![Build Status](https://travis-ci.com/dukeraphaelng/merkle_tree_stream.svg?branch=master)](https://travis-ci.com/dukeraphaelng/merkle_tree_stream) [![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://dukeraphaelng.github.io/merkle_tree_stream/) [![GitHub release (latest by date)](https://img.shields.io/github/v/release/dukeraphaelng/merkle_tree_stream)](https://img.shields.io/github/v/release/dukeraphaelng/merkle_tree_stream?style=flat-square)

A stream that generates a merkle tree based on the incoming data. Port of [mafintosh/merkle-tree-stream](https://github.com/mafintosh/merkle-tree-stream)

- [Documentation](https://dukeraphaelng.github.io/merkle_tree_stream/)

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     merkle_tree_stream:
       github: dukeraphaelng/merkle_tree_stream
   ```

2. Run `shards install`

## Usage

Merkle Tree Stream is a stateful algorithm class that takes data in, hashes it, and computes as many parent hashes as it can through [dukeraphaelng/flat_tree](https://github.com/dukeraphaelng/flat_tree) - this is done through the `.next` method, which keeps track of three properties:
- `blocks`: an index to keep track of how far along in the sequence we are.
- `nodes`: a vector of hashes
- `roots`: the current roots.

You can read more about Merkle Tree Stream [here](https://datprotocol.github.io/book/ch02-02-merkle-tree-stream.html)

```crystal
require "merkle_tree_stream"

leaf = Proc(MerkleTree::Node, Array(MerkleTree::Node)?, Bytes).new do |node, roots|
  Digest::SHA256.digest(node.data)
end

parent = Proc(MerkleTree::Node, MerkleTree::Node, Bytes).new do |left, right|
  Digest::SHA256.digest do |ctx|
    ctx.update left.data
    ctx.update right.data
  end
end

merkle = MerkleTree::Stream.new(leaf, parent)
nodes = [] of MerkleTree::Node
merkle.next("a".to_slice, nodes)
merkle.next("b".to_slice, nodes)
puts {nodes: nodes}

# => [
  #<MerkleTree::Node:0x107ebfe10 
    @index=0, 
    @parent=1, 
    @hash=Bytes[202, 151, 129, 18, 202, 27, 189, 202, 250, 194, 49, 179, 154, 35, 220, 77, 167, 134, 239, 248, 20, 124, 78, 114, 185, 128, 119, 133, 175, 238, 72, 187], 
    @size=1, 
    @data=Bytes[97]
  >,
  #<MerkleTree::Node:0x107ebfdc0 
    @index=2, 
    @parent=1, 
    @hash=Bytes[62, 35, 232, 22, 0, 57, 89, 74, 51, 137, 79, 101, 100, 225, 177, 52, 139, 189, 122, 0, 136, 212, 44, 74, 203, 115, 238, 174, 213, 156, 0, 157], 
    @size=1, 
    @data=Bytes[98]
  >, 
  #<MerkleTree::Node:0x107ebfd70 
    @index=1, 
    @parent=3, 
    @hash=Bytes[251, 142, 32, 252, 46, 76, 63, 36, 140, 96, 195, 155, 214, 82, 243, 193, 52, 114, 152, 187, 151, 123, 139, 77, 89, 3, 184, 80, 85, 98, 6, 3], 
    @size=2, 
    @data=Bytes[]
  >
]
```

`MerkleTree::Node` Instance Variables:
- `index`: tree node index, even numbers are data nodes
- `parent`: tree node's parent node's index
- `hash`: tree node's hash
- `size`: tree node's data size
- `data`: tree node's raw data

## Contributing

1. Fork it (<https://github.com/dukeraphaelng/merkle_tree_stream/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Duke Nguyen](https://github.com/dukeraphaelng) - creator and maintainer

## License

- [MIT](LICENSE)