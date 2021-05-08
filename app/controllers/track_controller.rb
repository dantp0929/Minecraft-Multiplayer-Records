class TrackController < ApplicationController
    def index
        @track = Track.new
    end

    def create
        @track = Track.new(track_params)

        if @track.save
            render json: { message: "success", trackId: @track.id }, status: 200
        else
            render json: { error: @track.errors.full_messages.join(", ") }, status: 400
        end
    end

    def edit
        @track = Track.new(track_params)

        if @track.update
            
        else
            render :edit
        end
    end

    def destroy
        @track = Track.find(params[:id])

        @track.song.purge_later
        @track.texture.purge_later
        
        @track.destroy
    end

    def download
        puts params[:ids]
        @tracks = Track.find(params[:ids])

        @tracks.each do |t|
            puts t.song.filename
        end
        # Do downloading stuff
    end

    private
    def track_params
        params.require(:track).permit(:name, :texture, :song)
    end
end
