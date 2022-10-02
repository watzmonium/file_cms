# server basics

  `socket` library
    TCPServer class
      methods:
        `.accept` - creates a new socket object and a new addrinfo object, waits for connection?
        
    Socket class
      methods:
        `.gets` - read line from socket
        `.close` - closes connection

    `WEBrick` gem
      - web server gem
      - working with it can be difficult
      - use the `rack` library to make it easier
        rack is a generic interface to developers connect to web servers
        works with other servers besides WEBrick

    API - a collection of programs that allows a program to access other components of an OS

# application servers

  - Web servers
    receive client http requests
  - Application servers
    interface with web server to deconstruct http into application-friendly info
    run a ruby program with that info
    return to web server in an http-friendly way
  - Rack
    it is an specification (architecture?)
    makes the API between webserver and framwork consistent
    it feeds to the framework the `env` hash with the request info
    it needs returned to it an array of:
      1) status message (responds to `to_i`)
      2) headers (hash string k/v pairs)
      3) body (html) MUST RESPOND TO EACH
    need a rackup file (config.ru) any name will work but config is standard
      THE RACK APP WE USE IN RU MUST BE A RUBY OBJECT THAT RESPONDS TO `call(env)`
        this must return the same 3 things shown above
      rack file should have a comment, require relative, and `run` Class.new

    bundle exec rackup config.ru -p ####

# View Templates

  - View templates
    code related to what we want to display
    allows us to do pre-processing and output html

  - ERB (embedded ruby)
    popular ruby templating library
    mixes ruby into html
    steps to use:
      1) require 'erb'
      2) create a template object with a string agrument, formatted correctly
        <%= %>
          evaluate ruby code and include return value in HTML
        <% %>
          evalutes but does not include in HTML. could be used for method definition
      3) invoke instance method `.result`

# Sinatra

  - Sinatra is a rack-based web development framework
    it makes a lot of the tedious parts of web development easier
    at it's core, it's some ruby code connecting to a TCP server, handling requests, and sending back HTTP compliant messages
    
  - Layouts
    in views, a layout.erb file (can also be called whatever.erb) can be used to wrap a page
    if a page has a default content, a layout can `yield` to an erb file specified
    if a layout isnt specified, layout.erb is used by default
    a layout is specified i.e.
      `erb :index, layout :somepage`
    
  - not_found
  - redirect

  # setting sessions
    use the `configure` key word and type
      enable :sessions
      set :session_secret, 'secret'

# Creating a project

  1) Gemfile with dependencies
  2) config.ru with  run Class.new in it
  3) program rb file
  4) dependent rb files
  5) erb files for html boilerplate
  6) if using heroku: need a Procfile
  7) initialize app name and push to heroku

# Getting it straight

  - Your program needs to receive and send properly formatted HTML reqs
  - Rack does this for you, if you work with it the right way
    - Rack requires a 'rackup' `ru` file that calls your app that will feed it the array it wants
    - `ru` is needed to run rack, otherwise how does it know how to run?!
  - Sinatra even takes away the challenge of formatting, giving you easy ways to field reqs
  - tilt proves a bunch of template engines
    - erubis is the one we use because it's included with ruby
    - slim is more popular since it's more of just regular ruby

# Deploying to heroku

  - heroku apps:create app_name
  - git push heroku main (git push heroku local-branch-name:main if on a branch)
  - heroku stack:set heroku-22 if incompatible

  # Jquery

    - The most popular JS library
    - How to get started:
      1) download jquery
      2) add the file to your project directory
      3) add <script src="./jquery/jquery.js"></script> to html
      4) in your html:
        <script>
          $(documents).ready(fuction() {

            CODE GOES HERE!

          });
        </script>
        This says wait for the whole doc to load before using js
        also you can just write (function(){})

    - jquery gives you a library of commands to use

    # writing jquery commands

      - $('selector').message1().message2(); i.e. $('#panel1').hide();
      - $('#thing').css({
          color: 'red', 
          fontWeight: 'bold',
          display: 'none'
        });

        $('#id').html('new name');

        $('#btn1').on('click', function() {
          $('#panel1').toggle();
        });

        $('#btn1').on('mouseover', function() {
          $('#panel1 .panel-body').html('my new content');
        });

        $('button[id=panel1]') < finds the thing and returns the html!

          - target all classes of that thing
        $('.panel-button').on('click', function(){
          var panelId = $(this).attr('data-panelid');
          alert(panelId);
        });

# AJAX

  - real name is XHR (xml http request)