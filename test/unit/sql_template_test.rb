require 'test_helper'

class SqlTemplateTest < ActiveSupport::TestCase
  test "resolver returns a template with the saved body" do
    resolver = SqlTemplate::Resolver.instance
    details = { formats: [:html], locale: [:en], handlers: [:erb] }
    
    assert resolver.find_all("index", "posts", false, details).empty?
    
    SqlTemplate.create(
      body: "<%= Hi from SqlTemplate %>",
      path: "posts/index",
      format: 'html',
      locale: 'en',
      handler: 'erb',
      partial: false
    )
    
    template = resolver.find_all("index", "posts", false, details).first
    assert_kind_of ActionView::Template, template
    
    assert_equal "<%= Hi from SqlTemplate %>", template.source
    assert_match /SqlTemplate - \d+ - "posts\/index"/, template.identifier
    assert_equal ActionView::Template::Handlers::ERB, template.handler.class
    assert_equal [:html], template.formats
    assert_equal 'posts/index', template.virtual_path
    
  end

  test "sql_template expires the cache on update" do
    s = SqlTemplate.create(
      body: "<%%= Hi from SqlTemplate %>",
      path: "posts/index",
      format: 'html',
      locale: 'en',
      handler: 'erb',
      partial: false
    )
  
    cache_key = Object.new
    resolver = SqlTemplate::Resolver.instance
    details = { formats: [:html], locale: [:en], handlers: [:erb] }
    
    t = resolver.find_all("index", "posts", false, details, cache_key).first
    assert_match /Hi from SqlTemplate/, t.source
    
    s.update_attributes(:body => 'New body from template')
    
    t = resolver.find_all("index", "posts", false, details, cache_key).first
    assert_match /New body from template/, t.source
  end

  # test "the truth" do
  #   assert true
  # end
end
