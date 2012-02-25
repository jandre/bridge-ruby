module Bridge
  # Wrapper for callbacks passed in as arguments.
  class CallbackRef < Ref
    def initialize fun
      @fun = fun
      path = ['client', lambda {
                Core::client_id
              }, fun.hash.to_s(36),
              'callback']
      super(path)
    end

    def callback *args
      @fun.call *args
    end

    def call *args
    end
  end
end
