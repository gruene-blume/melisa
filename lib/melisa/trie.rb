require "melisa/base_config_flags"
require "melisa/search"

module Melisa
  ImmutableError = Class.new(StandardError)

  class Trie
    include Enumerable

    attr_reader :trie

    # Initialize a BaseTrie.
    # @keys    An array of UTF-8 strings
    # @weights An array of corresponding weights
    # @opts
    #   :binary      Boolean, true for a binary Trie, false for text
    #   :num_tries   An integer from 1 to 127 representing the depth of recursive Tries
    #   :cache_size  One of [:tiny, :small, :normal, :large, :huge]
    #   :order       One of [:label, :weight]
    def initialize(keys=[], weights=[], opts={})
      @trie = Marisa::Trie.new
      @keyset = Marisa::Keyset.new
      @options = opts
      @built = false

      add_many(keys, weights)
    end

    def build
      @trie.build(@keyset, config_flags(@options)) unless @built
      @built = true
    end

    def add(key, weight=nil)
      raise ImmutableError, "Can't add #{key}, Trie already built" if @built
      self.tap { push(key, weight) }
    end
    alias :<< :add

    def add_many(keys, weights)
      for key, weight in keys.zip(weights)
        push(key, weight)
      end
    end

    def search(prefix)
      build unless @built
      Search.new(self, prefix)
    end

    def each(&block)
      build unless @built
      search('').each(&block)
    end

    def size
      build unless @built
      @trie.num_keys()
    end

    def keys
      build unless @built
      search('').keys
    end

    def has_keys?
      build unless @built
      search('').has_keys?
    end

    def include?(key)
      build unless @built
      a = Marisa::Agent.new
      a.set_query(key)
      @trie.lookup(a)
    end

    def read(file_handle)
      self.tap { @trie.read(file_handle.fileno); @built = true }
    end

    def write(file_handle)
      self.tap { @trie.write(file_handle.fileno) }
    end

    def load(path)
      self.tap { File.open(path, "r") { |file| read(file) } }
    end

    def save(path)
      self.tap { File.open(path, "w") { |file| write(file) } }
    end

  protected
    include BaseConfigFlags

    def push(key, weight)
      if weight
        @keyset.push_back(key, weight)
      else
        @keyset.push_back(key)
      end
    end
  end
end