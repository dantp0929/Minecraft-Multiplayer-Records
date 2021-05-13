# frozen_string_literal: true

class TrackController < ApplicationController
  def index
    @track = Track.new
  end

  def create
    @track = Track.new(track_params)

    if @track.save
      render json: { message: 'successfully created', trackId: @track.id }, status: 200
    else
      render json: { error: @track.errors.full_messages.join(', ') }, status: 400
    end
  end

  def update
    @track = Track.find(params[:id])

    if @track.update(track_params)
      render json: { message: 'successfully updated', trackId: @track.id }, status: 200
    else
      render json: { error: @track.errors.full_messages.join(', ') }, status: 400
    end
  end

  def destroy
    @track = Track.find(params[:id])

    @track.song.purge_later
    @track.texture.purge_later

    if @track.destroy
      render json: { message: 'successfully deleted' }, status: 200
    else
      render json: { error: @track.errors.full_messages.join(', ') }, status: 400
    end
  end

  def download
    uuid = SecureRandom.uuid
    Track.create_folders(uuid)

    @tracks = []
    params[:ids].each do |id|
      @tracks.append(Track.find(id))
    end

		# Converts each track into a .ogg mono file.
    @tracks.each do |t|
      if (t)
        new_song = FFMPEG::Movie.new(url_for(t.song))
        options = { audio_channels: 1,
                    audio_sample_rate: new_song.audio_sample_rate }
        new_song.transcode(
          "tmp/downloads/#{uuid}/multiplayer_records/multiplayer_records_rp/assets/minecraft/sounds/records/#{t.song.filename.base}.ogg",
          options
        )

        File.open("tmp/downloads/#{uuid}/multiplayer_records/multiplayer_records_rp/assets/minecraft/textures/item/#{t.formatted_track_name}", 'wb') do |file|
          file.write(t.texture.download)
        end
      end
    end

    render json: { message: 'successfully converted', trackIds: params[:ids], uuid: uuid }, status: 200
    # Do downloading stuff
  end

  private

  def track_params
    params.require(:track).permit(:name, :texture, :song)
  end
end
