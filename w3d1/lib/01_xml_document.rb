class XmlDocument
  def initialize(indent = false)
    @indent = indent
    @depth = 0
  end

  def method_missing(name, *attrs, &blk)
    name = name.to_s
    attrs = attrs[0] || {}
    render_tag(name, attrs, &blk)
  end

  private

  def indent
    @depth += 1 if @indent
  end

  def unindent
    @depth -= 1 if @indent
  end

  def render_tag(name, attrs, &blk)
    xml = ""
    if block_given?
      xml << opening_tag(name, attrs)
      indent
      xml << blk.call
      unindent
      xml << closing_tag(name)
    else
      xml << standalone_tag(name, attrs)
    end
  end

  def tab
    "  " * @depth
  end

  def new_line
    @indent ? "\n" : ""
  end

  def created_tag(name, attrs)
    ([name] + attrs_str(attrs)).join(" ")
  end

  def attrs_str(attrs)
    attrs.map { |key, val| %Q(#{key}="#{val}") }
  end

  def opening_tag(name, attrs)
    %Q(#{tab}<#{created_tag(name, attrs)}>#{new_line})
  end

  def closing_tag(name)
    %Q(#{tab}</#{name}>#{new_line})
  end

  def standalone_tag(name, attrs)
    %Q(#{tab}<#{created_tag(name, attrs)}/>#{new_line})
  end
end
