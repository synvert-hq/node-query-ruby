# frozen_string_literal: true

module NodeQuery::Compiler
  # Selector used to match nodes, it combines by node type and/or attribute list, plus index or has expression.
  class Selector
    # Initialize a Selector.
    # @param goto_scope [String] goto scope
    # @param relationship [String] the relationship between the selectors, it can be descendant <code>nil</code>, child <code>></code>, next sibling <code>+</code> or subsequent sibing <code>~</code>.
    # @param rest [NodeQuery::Compiler::Selector] the rest selector
    # @param basic_selector [NodeQuery::Compiler::BasicSelector] the simple selector
    # @param position [String] the position of the node
    # @param attribute_list [NodeQuery::Compiler::AttributeList] the attribute list
    # @param pseudo_class [String] the pseudo class, can be <code>has</code> or <code>not_has</code>
    # @param pseudo_selector [NodeQuery::Compiler::Expression] the pseudo selector
    # @param adapter [NodeQuery::Adapter]
    def initialize(
      goto_scope: nil,
      relationship: nil,
      rest: nil,
      basic_selector: nil,
      position: nil,
      pseudo_class: nil,
      pseudo_selector: nil,
      adapter:
    )
      @goto_scope = goto_scope
      @relationship = relationship
      @rest = rest
      @basic_selector = basic_selector
      @position = position
      @pseudo_class = pseudo_class
      @pseudo_selector = pseudo_selector
      @adapter = adapter
    end

    # Check if node matches the selector.
    # @param node [Node] the node
    # @param base_node [Node] the base node for evaluated node
    def match?(node, base_node, operator = "=")
      if node.is_a?(::Array)
        case operator
        when "not_includes"
          return node.none? { |child_node| match?(child_node, base_node) }
        when "includes"
          return node.any? { |child_node| match?(child_node, base_node) }
        else
          return false
        end
      end
      @adapter.is_node?(node) && (!@basic_selector || (operator == "!=" ? !@basic_selector.match?(
        node,
        base_node
      ) : @basic_selector.match?(node, base_node))) && match_pseudo_class?(node)
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
    # @option options [boolean] :stop_at_first_match if stop at first match, default is false
    # @option options [boolean] :recursive if recursively query child nodes, default is true
    # @return [Array<Node>] matching nodes.
    def query_nodes(node, options = {})
      options = { including_self: true, stop_at_first_match: false, recursive: true }.merge(options)
      return find_nodes_by_relationship(node) if @relationship

      if node.is_a?(::Array)
        return node.flat_map { |child_node| query_nodes(child_node) }
      end

      return find_nodes_by_goto_scope(node) if @goto_scope

      if options[:including_self] && !options[:recursive]
        return match?(node, node) ? [node] : []
      end

      nodes = []
      if options[:including_self] && match?(node, node)
        nodes << node
        return nodes if options[:stop_at_first_match]
      end
      if @basic_selector
        if options[:recursive]
          NodeQuery::Helper.handle_recursive_child(node, @adapter) do |child_node|
            if match?(child_node, child_node)
              nodes << child_node
              break if options[:stop_at_first_match]
            end
          end
        else
          @adapter.get_children(node).each do |child_node|
            if match?(child_node, child_node)
              nodes << child_node
              break if options[:stop_at_first_match]
            end
          end
        end
      end
      filter_by_position(nodes)
    end

    def to_s
      result = []
      result << "#{@goto_scope} " if @goto_scope
      result << "#{@relationship} " if @relationship
      result << @rest.to_s if @rest
      result << @basic_selector.to_s if @basic_selector
      result << ":#{@position}" if @position
      result << ":#{@pseudo_class}(#{@pseudo_selector})" if @pseudo_class
      result.join('')
    end

    protected

    # Filter nodes by position.
    # @param nodes [Array<Node>] nodes to filter
    # @return [Array<Node>|Node] first node or last node or nodes
    def filter_by_position(nodes)
      return nodes unless @position
      return nodes if nodes.empty?

      case @position
      when 'first-child'
        [nodes.first]
      when 'last-child'
        [nodes.last]
      else
        nodes
      end
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
            nodes << child_node if @rest.match?(child_node, child_node)
          end
        else
          @adapter.get_children(node).each do |child_node|
            if child_node.is_a?(Array) # SyntaxTree may return an array in child node.
              child_node.each do |child_child_node|
                nodes << child_child_node if @rest.match?(child_child_node, child_child_node)
              end
            elsif @adapter.is_node?(child_node) && :begin == @adapter.get_node_type(child_node)
              @adapter.get_children(child_node).each do |child_child_node|
                nodes << child_child_node if @rest.match?(child_child_node, child_child_node)
              end
            elsif @rest.match?(child_node, child_node)
              nodes << child_node
            end
          end
        end
      when '+'
        next_sibling = @adapter.get_siblings(node).first
        nodes << next_sibling if @rest.match?(next_sibling, next_sibling)
      when '~'
        @adapter.get_siblings(node).each do |sibling_node|
          nodes << sibling_node if @rest.match?(sibling_node, sibling_node)
        end
      end
      @rest.filter_by_position(nodes)
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
