class RecordController < ApplicationController
    def index
        @records = Record.all
    end
end
