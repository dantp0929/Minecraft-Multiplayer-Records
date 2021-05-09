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
        
        if @track.destroy
            render json: { message: "successfully deleted" }, status: 200
        else
            render json: { error: @track.errors.full_messages.join(", ") }, status: 400
        end
        
    end

    def download
        uuid = SecureRandom.uuid

        # Make folders for download
        FileUtils.mkdir_p("tmp/downloads/"+uuid+"/multiplayer_records/multiplayer_records_rp/assets/minecraft/models/item")
        FileUtils.mkdir_p("tmp/downloads/"+uuid+"/multiplayer_records/multiplayer_records_rp/assets/minecraft/sounds/records")
        FileUtils.mkdir_p("tmp/downloads/"+uuid+"/multiplayer_records/multiplayer_records_rp/assets/minecraft/textures/item")

        FileUtils.mkdir_p("tmp/downloads/"+uuid+"/multiplayer_records/multiplayer_records_dp/data/multiplayer_records_dp/functions/item")
        FileUtils.mkdir_p("tmp/downloads/"+uuid+"/multiplayer_records/multiplayer_records_dp/data/minecraft/loot_tables/entities")
        FileUtils.mkdir_p("tmp/downloads/"+uuid+"/multiplayer_records/multiplayer_records_dp/data/minecraft/tags/functions")

        @tracks = Track.find(params[:ids])
        @tracks.each do |t|
            song = FFMPEG::Movie.new(url_for(t.song))

            options = { :audio_channels => 1, 
                        :audio_sample_rate => song.audio_sample_rate }
            song.transcode("tmp/downloads/"+uuid+"/multiplayer_records/multiplayer_records_rp/assets/minecraft/sounds/records/"+t.song.filename.base+".ogg", options) { |progress| puts progress }
        end
        render json: { message: "successfully converted", trackIds: params[:ids], uuid: uuid }, status: 200
        # Do downloading stuff
    end

    private
    def track_params
        params.require(:track).permit(:name, :texture, :song)
    end
end
