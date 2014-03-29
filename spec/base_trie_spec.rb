require_relative "spec_helper"

describe Melisa::BaseTrie do
  let(:terms) { ['one', 'two', 'onetwo'] }
  let(:trie) { Melisa::BaseTrie.new(terms) }

  it "initializes" do
    trie
  end

  it "tests for inclusion" do
    trie.include?('one').should be_true
    trie.include?('three').should_not be_true
  end

  it "lists keys" do
    trie.keys.should =~ ['one', 'two', 'onetwo']
  end
end