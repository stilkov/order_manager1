class ControllerTestSupport < ActionController::TestCase
  def assert_allows(verbs)
    if allow = @response.header['Allow']
      assert_not_nil allow, "Allow header should be set"
      verbs.each { |verb| assert allow.split(',').map { |v| v.strip }.include?(verb), "#{verb} should be allowed; Allow header is #{allow}" }
    end
  end
  
  def assert_xml(xml, ns)
    yield XpathContext.new(self, xml, ns)
  end
  
  class XpathContext
    def initialize(controller, string, ns)
      @controller = controller
      @doc = XML::Parser.string(string).parse
      @ns = ns
    end

    def assert_node_not_nil(path)
      node = @doc.find(path, @ns)
      @controller.assert_not_nil(node)
    end

    def assert_content_not_nil(path)
      node = @doc.find_first(path, @ns)
      @controller.assert_not_nil(node.content)
    end

    def assert_content_equal(expected, path)
      node = @doc.find_first(path, @ns)
      @controller.assert_equal(expected, node.content)
    end

  end
end