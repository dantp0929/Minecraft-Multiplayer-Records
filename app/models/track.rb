# frozen_string_literal: true

class Track < ApplicationRecord
  include Rails.application.routes.url_helpers
  has_one_attached :song
  has_one_attached :texture

  # Makes folders for download
  def self.create_folders(uuid)
    FileUtils.mkdir_p("tmp/downloads/#{uuid}/multiplayer_records/multiplayer_records_rp/assets/minecraft/models/item")
    FileUtils.mkdir_p("tmp/downloads/#{uuid}/multiplayer_records/multiplayer_records_rp/assets/minecraft/sounds/records")
    FileUtils.mkdir_p("tmp/downloads/#{uuid}/multiplayer_records/multiplayer_records_rp/assets/minecraft/textures/item")

    FileUtils.mkdir_p("tmp/downloads/#{uuid}/multiplayer_records/multiplayer_records_dp/data/multiplayer_records_dp/functions/item")
    FileUtils.mkdir_p("tmp/downloads/#{uuid}/multiplayer_records/multiplayer_records_dp/data/minecraft/loot_tables/entities")
    FileUtils.mkdir_p("tmp/downloads/#{uuid}/multiplayer_records/multiplayer_records_dp/data/minecraft/tags/functions")
  end

  # Converts a track to a .ogg mono file.
  def convert(uuid)
    new_song = FFMPEG::Movie.new(url_for(song))
    options = { audio_channels: 1,
                audio_sample_rate: new_song.audio_sample_rate }
    new_song.transcode(
      "tmp/downloads/#{uuid}/multiplayer_records/multiplayer_records_rp/assets/minecraft/sounds/records/#{song.filename.base}.ogg", options
    )
  end

  # Creates neccessary files for the datapack to work
  def self.create_files(uuid); end
end
