require "spec"
require "../src/merkle_tree_stream"

macro generate_equal_object(object)
  def equal_obj(this, other)
    {% for method in object.resolve.methods %}
      {% unless method.name.ends_with?("=") %}
        this.{{method.name}}.should eq(other.{{method.name}})
      {% end %}
    {% end %}
  end
end

generate_equal_object(MerkleTree::Node)
