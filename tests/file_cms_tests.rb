# This variable is used by a lot of sinatra behind the scenes stuff
ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require 'rack/test'
require 'redcarpet'
require "fileutils"

require_relative '../file_cms'

class AppTest < Minitest::Test
  
  # this assumes there will be an `app` method as defined below
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def create_document(name, content = "")
    File.open(File.join(data_path, name), "w") do |file|
      file.write(content)
    end
  end

  def test_index
    create_document "about.md"
    create_document "changes.txt"

    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, "about.md"
    assert_includes last_response.body, "changes.txt"
  end

  def test_text_file
    create_document "about.txt", "Gerp Herp"

    get '/files/about.txt'
    assert_equal 200, last_response.status
    assert_equal 'text/plain', last_response['Content-Type']
    assert_includes last_response.body, "Gerp Herp"
  end

  def test_no_file
    get '/files/anything.txt'
    assert_equal 302, last_response.status
    get last_response["Location"] # gets the redirect
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'does not exist'
    get '/'
    assert_equal 200, last_response.status
    refute_includes last_response.body, 'does not exist'
  end

  def test_markdown_file
    create_document "about.md", "# Herp Gerp"

    get '/files/about.md'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    file = File.read("#{data_path}/about.md")
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})
    file = markdown.render(file)
    assert_includes last_response.body, "<h1>Herp Gerp</h1>"
  end

  def test_edit_file
    create_document "about.txt", "Goop Hoop"
    get '/files/about.txt/edit'
    assert_equal 200, last_response.status
    assert_includes last_response.body, "Goop Hoop"
  end

  def test_write_to_file
    create_document "about.txt", "Shmeep Creep"
    post '/files/about.txt', edit_text: 'Lorem Ipsum'
    assert_equal 302, last_response.status
    get last_response["Location"] # gets the redirect
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'updated successfully'
    get '/files/about.txt'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Lorem Ipsum'
  end

  def test_create_new
    get '/new'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Add a new document:'
  end

  def test_new_doc_created
    post '/new', doc_name: 'pork.txt'
    assert_equal 302, last_response.status
    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'pork.txt'
    file = File.read("#{data_path}/pork.txt")
    refute_nil file
  end

  def test_create_new_document_without_filename
    post "/new", doc_name: ""
    assert_equal 422, last_response.status
    assert_includes last_response.body, "A name is required"
  end

  def test_create_new_doc_without_extension
    post '/new', doc_name: "pork"
    assert_equal 422, last_response.status
    assert_includes last_response.body, "File must have a valid extension"
  end

  def test_delete_file
    create_document "about.md"
    post '/delete?file=about.md'
    assert_equal 302, last_response.status
    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_includes last_response.body, "successfully deleted"
    refute_includes last_response.body, 'href="about.md"'
    get '/files/about.md'
    assert_equal 302, last_response.status
  end
end
