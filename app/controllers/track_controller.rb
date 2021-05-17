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
      new_song = FFMPEG::Movie.new(url_for(t.song))
      options = { audio_channels: 1,
                  audio_sample_rate: new_song.audio_sample_rate }
      new_song.transcode(
        "tmp/downloads/#{uuid}/multiplayer_records/multiplayer_records_rp/assets/minecraft/sounds/records/#{t.parameterized_track_name}.ogg",
        options
      )

      File.open("tmp/downloads/#{uuid}/multiplayer_records/multiplayer_records_rp/assets/minecraft/textures/item/#{t.parameterized_track_name}.png", 'wb') do |file|
        file.write(t.texture.download)
      end
    end

    Track.create_files(uuid, @tracks)

    zipper = ZipFileGenerator.new("tmp/downloads/#{uuid}/multiplayer_records", "tmp/downloads/#{uuid}/multiplayer_records.zip")
    zipper.write

    puts "SENDING!!!!!!!!"
    send_file File.absolute_path("tmp/downloads/#{uuid}/multiplayer_records.zip"), 
              type: "application/zip",
              dispostion: "attachment",
              filename: "multiplayer_records.zip"
    puts "DONE SENDING!!!!!!!!"

    render json: { message: 'successfully converted', trackIds: params[:ids], uuid: uuid }, status: 200
  end

  private
  def track_params
    params.require(:track).permit(:name, :texture, :song)
  end

end
