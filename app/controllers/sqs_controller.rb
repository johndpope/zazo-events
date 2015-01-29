class SqsController < ApplicationController
  def index
    puts params.inspect
    render text: "foo"
  end
  
  def heartbeat
    render text: "ok"
  end
end