require "./spec_helper"
require "digest/sha256"

describe MerkleTree do
  leaf = Proc(MerkleTree::Node, Array(MerkleTree::Node)?, Bytes).new do |node, roots|
    Digest::SHA256.digest(node.data)
  end

  parent = Proc(MerkleTree::Node, MerkleTree::Node, Bytes).new do |left, right|
    Digest::SHA256.digest do |ctx|
      ctx.update left.data
      ctx.update right.data
    end
  end

  it "should hash" do
    merkle = MerkleTree::Generator.new(leaf, parent)
    nodes = [] of MerkleTree::Node
    merkle.next("a".to_slice, nodes)
    merkle.next("b".to_slice, nodes)

    nodes.size.should eq(3)

    equal_obj(nodes[0],
      MerkleTree::Node.new(
        index: 0_u64, parent: 1_u64, hash: Digest::SHA256.digest("a".to_slice), size: 1_u64, data: "a".to_slice
      )
    )
    equal_obj(nodes[1],
      MerkleTree::Node.new(
        index: 2_u64, parent: 1_u64, hash: Digest::SHA256.digest("b".to_slice), size: 1_u64, data: "b".to_slice
      )
    )

    hashed = Digest::SHA256.digest do |ctx|
      ctx.update "a".to_slice
      ctx.update "b".to_slice
    end

    equal_obj(nodes[2],
      MerkleTree::Node.new(
        index: 1_u64, parent: 3_u64, hash: hashed, size: 2_u64, data: Bytes.empty
      )
    )
  end

  it "should write single root" do
    merkle = MerkleTree::Generator.new(leaf, parent)
    merkle.next("a".to_slice)
    merkle.next("b".to_slice)
    merkle.next("c".to_slice)
    merkle.next("d".to_slice)

    merkle.roots.size.should eq(1)
  end

  it "should write multiple roots" do
    merkle = MerkleTree::Generator.new(leaf, parent)

    merkle.next("a".to_slice)
    merkle.next("b".to_slice)
    merkle.next("c".to_slice)

    merkle.roots.size.should be > 1
  end
end
