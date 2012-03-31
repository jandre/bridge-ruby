require 'eventmachine'

module Bridge
  class Tcp < EventMachine::Connection #:nodoc: all
  
    def initialize connection
      @buffer = ''
      @len = 0
      @pos = 0
      @callback = nil
      @connection = connection
      start
    end
    
    def post_init
      @connection.onopen self
    end

    def receive_data data
      left = @len - @pos
      if data.length >= left
        @buffer << data.slice(0, left)
        @callback.call @buffer
        receive_data data.slice(left..-1) unless data.nil?
      else
        @buffer << data
        @pos = @pos + data.length
      end
    end
    
    def read len, &cb
      @buffer = ''
      @len = len
      @pos = 0
      @callback = cb
    end
    
    def start
      # Read header bytes
      read 4 do |data|
        # Read body bytes
        read data.unpack('N')[0] do |data|
          # Call message handler
          @connection.onmessage({:data => data}, self)
          # Await next message
          start
        end
      end
    end

    def send arg
      # Prepend length header to message
      send_data([arg.length].pack("N") + arg)
    end
    
    def unbind
      @connection.onclose
    end
    
  end  
end
