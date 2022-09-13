# frozen_string_literal: true

module NodeQuery::Compiler
  # Selector used to match nodes, it combines by node type and/or attribute list, plus index or has expression.
  class Selector
    # Initialize a Selector.
    # @param goto_scope [String] goto scope
    # @param relationship [String] the relationship between the selectors, it can be descendant <code>nil</code>, child <code>></code>, next sibling <code>+</code> or subsequent sibing <code>~</code>.
    # @param rest [NodeQuery::Compiler::Selector] the rest selector
    # @param basic_selector [NodeQuery::Compiler::BasicSelector] the simple selector
    # @param attribute_list [NodeQuery::Compiler::AttributeList] the attribute list
    # @param pseudo_class [String] the pseudo class, can be <code>has</code> or <code>not_has</code>
    # @param pseudo_selector [NodeQuery::Compiler::Expression] the pseudo selector
    def initialize(goto_scope: nil, relationship: nil, rest: nil, basic_selector: nil, pseudo_class: nil, pseudo_selector: nil)
      @goto_scope = goto_scope
      @relationship = relationship
      @rest = rest
      @basic_selector = basic_selector
      @pseudo_class = pseudo_class
      @pseudo_selector = pseudo_selector
    end

    # Check if node matches the selector.
    # @param node [Parser::AST::Node] the node
    def match?(node)
      NodeQuery.adapter.is_node?(node) && (!@basic_selector || @basic_selector.match?(node)) && match_pseudo_class?(node)
    end

    # Query nodes by the selector.
    # * If relationship is nil, it will match in all recursive child nodes and return matching nodes.
    # * If relationship is decendant, it will match in all recursive child nodes.
    # * If relationship is child, it will match in direct child nodes.
    # * If relationship is next sibling, it try to match next sibling node.
    # * If relationship is subsequent sibling, it will match in all sibling nodes.
    # @param node [Node] node to match
    # @param options [Hash] if query the current node
    # @option options [boolean] :including_self if query the current node, default is ture
    # @option options [boolean] :stop_on_match if stop on first match, default is false
    # @option options [boolean] :recursive if stop on first match, default is true
    # @return [Array<Node>] matching nodes.
    def query_nodes(node, options = {})
      options = { including_self: true, stop_on_match: false, recursive: true }.merge(options)
      return find_nodes_by_relationship(node) if @relationship

      if node.is_a?(::Array)
        return node.flat_map { |child_node| query_nodes(child_node) }
      end

      return find_nodes_by_goto_scope(node) if @goto_scope

      nodes = []
      if options[:including_self] && match?(node)
        nodes << node
        return matching_nodes if options[:stop_on_match]
      end
      if @basic_selector
        if options[:recursive]
          NodeQuery::Helper.handle_recursive_child(node) do |child_node|
            if match?(child_node)
              nodes << child_node
              break if options[:stop_on_match]
            end
          end
        else
          NodeQuery.adapter.get_children(node).each do |child_node|
            if match?(child_node)
              nodes << child_node
              break if options[:stop_on_match]
            end
          end
        end
      end
      nodes
    end

    def to_s
      result = []
      result << "#{@goto_scope} " if @goto_scope
      result << "#{@relationship} " if @relationship
      result << @rest.to_s if @rest
      result << @basic_selector.to_s if @basic_selector
      result << ":#{@pseudo_class}(#{@pseudo_selector})" if @pseudo_class
      result.join('')
    end

    private

    # Find nodes by @goto_scope
    # @param node [Node] node to match
    # @return [Array<Node>] matching nodes
    def find_nodes_by_goto_scope(node)
      @goto_scope.split('.').each { |scope| node = node.send(scope) }
      @rest.query_nodes(node)
    end

    # Find nodes by @relationship
    # @param node [Node] node to match
    # @return [Array<Node>] matching nodes
    def find_nodes_by_relationship(node)
      nodes = []
      case @relationship
      when '>'
        if node.is_a?(::Array)
          node.each do |child_node|
            nodes << child_node if @rest.match?(child_node)
          end
        else
          node.children.each do |child_node|
            if NodeQuery.adapter.is_node?(child_node) && :begin == NodeQuery.adapter.get_node_type(child_node)
              child_node.children.each do |child_child_node|
                nodes << child_child_node if @rest.match?(child_child_node)
              end
            elsif @rest.match?(child_node)
              nodes << child_node
            end
          end
        end
      when '+'
        next_sibling = node.siblings.first
        nodes << next_sibling if @rest.match?(next_sibling)
      when '~'
        node.siblings.each do |sibling_node|
          nodes << sibling_node if @rest.match?(sibling_node)
        end
      end
      nodes
    end

    # Check if it matches pseudo class.
    # @param node [Node] node to match
    # @return [Boolean]
    def match_pseudo_class?(node)
      case @pseudo_class
      when 'has'
        !@pseudo_selector.query_nodes(node).empty?
      when 'not_has'
        @pseudo_selector.query_nodes(node).empty?
      else
        true
      end
    end
  end
end
