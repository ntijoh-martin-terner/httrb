require_relative 'spec_helper'
require_relative '../lib/request'

describe 'request' do
    describe 'get-index.request' do
        before do
            @request = Request.new(File.read('./spec/example_requests/get-index.request.txt'))
        end

        it 'parses the http method' do
            _(@request.method).must_equal "GET"
        end

        it 'parses the resource' do
            _(@request.resource).must_equal "/"
        end
        it 'parses the headers' do
            _(@request.headers["Host"]).must_equal "developer.mozilla.org"
            _(@request.headers["Accept-Language"]).must_equal "fr"
        end
    end
    describe 'get-examples.request' do

        before do
            @request = Request.new(File.read('./spec/example_requests/get-examples.request.txt'))
        end
    
        it 'parses the http method' do
            _(@request.method).must_equal "GET"
        end

        it 'parses the version' do
            _(@request.version).must_equal "HTTP/1.1"
        end

        it 'parses the resource' do
            _(@request.resource).must_equal "/examples"
        end
        it 'parses the headers' do
            _(@request.headers["Host"]).must_equal "example.com"
            _(@request.headers["User-Agent"]).must_equal "ExampleBrowser/1.0"
            _(@request.headers["Accept-Encoding"]).must_equal "gzip, deflate"
            _(@request.headers["Accept"]).must_equal "*/*"
        end
    end
    describe 'get-fruits-with-filter.request' do
        before do
            @request = Request.new(File.read('./spec/example_requests/get-fruits-with-filter.request.txt'))
        end
        
        it 'parses the http method' do
            _(@request.method).must_equal "GET"
        end

        it 'parses the resource' do
            _(@request.resource).must_equal "/fruits?type=bananas&minrating=4"
        end
        it 'parses the params' do
            _(@request.params["type"]).must_equal "bananas"
            _(@request.params["minrating"]).must_equal "4"
        end
        it 'parses the headers' do
            _(@request.headers["Host"]).must_equal "fruits.com"
            _(@request.headers["Accept-Encoding"]).must_equal "gzip, deflate"
            _(@request.headers["Accept"]).must_equal "*/*"
        end
    end
    describe 'post-login.request' do
        before do
            @request = Request.new(File.read('./spec/example_requests/post-login.request.txt'))
        end
    
        it 'parses the http method' do
            _(@request.method).must_equal "POST"
        end

        it 'parses the resource' do
            _(@request.resource).must_equal "/login"
        end

        it 'parses the version' do
            _(@request.version).must_equal "HTTP/1.1"
        end

        it 'parses the headers' do
            _(@request.headers["Host"]).must_equal "foo.example"
            _(@request.headers["Content-Type"]).must_equal "application/x-www-form-urlencoded"
            _(@request.headers["Content-Length"]).must_equal "39"
        end

        it 'parses the params' do
            @request = Request.new(File.read('./spec/example_requests/post-login.request.txt'))
            _(@request.params["username"]).must_equal "grillkorv"
            _(@request.params["password"]).must_equal "verys3cret!"
        end
    end
end

describe "http_server" do 
  
end