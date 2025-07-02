#!/usr/bin/env ruby

require 'rack'

# Simple Rack application to serve static files from wilson-livestock-static theme
class StaticApp
  def initialize
    @file_server = Rack::Files.new(File.dirname(__FILE__))
  end

  def call(env)
    original_path = env['PATH_INFO']

    # Handle root path - serve index.html
    if original_path == '/' || original_path == ''
      env['PATH_INFO'] = '/index.html'
    elsif !original_path.include?('.') # No file extension, check for HTML file
      # Check if corresponding HTML file exists
      html_file_path = File.join(File.dirname(__FILE__), "#{original_path}.html")
      if File.exist?(html_file_path)
        env['PATH_INFO'] = "#{original_path}.html"
      end
    end

    # Let Rack::Files handle the request
    status, headers, body = @file_server.call(env)

    # If file not found, try to serve index.html for SPA-like behavior
    if status == 404 && !original_path.include?('.')
      env['PATH_INFO'] = '/index.html'
      status, headers, body = @file_server.call(env)
    end

    [status, headers, body]
  end
end

# Use Rack::Static for better performance with static assets
use Rack::Static,
  urls: ['/images', '/css', '/js', '/assets'],
  root: File.dirname(__FILE__),
  index: 'index.html'

# Enable logging
use Rack::CommonLogger

# Add some basic headers for better browser compatibility
use Rack::Deflater

# Custom middleware to add CORS headers for development
class CORSMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    # Add CORS headers (lowercase for Rack 3.x compliance)
    headers['access-control-allow-origin'] = '*'
    headers['access-control-allow-methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    headers['access-control-allow-headers'] = 'Content-Type, Authorization'

    [status, headers, body]
  end
end

use CORSMiddleware

# Run the main application
run StaticApp.new
