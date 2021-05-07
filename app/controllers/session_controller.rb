class SessionController < ApplicationController
    def index
        @session = Session.new
    end
end
