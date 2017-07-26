require 'webrick'

system("export CONSUMER_KEY=#{ENV['CONSUMER_KEY']}")

srv = WEBrick::HTTPServer.new({
  :DocumentRoot => './',
  :BindAddress => '127.0.0.1',
  :Port => 8000,
  :CGIInterpreter => `which ruby`.strip!,
  :Logger => WEBrick::Log::new(STDOUT, WEBrick::Log::DEBUG),
})

srv.mount('/', WEBrick::HTTPServlet::CGIHandler, 'request.rb')
srv.mount('/authorize', WEBrick::HTTPServlet::CGIHandler, 'authorize.rb')

trap("INT"){ srv.shutdown }
srv.start

