class TracksCleanupJob < ApplicationJob
  queue_as :default

  def perform(ids, uuid)
    tracks = Track.where(id: ids)
    tracks.each do |track|
      track.song.purge_later
      track.texture.purge_later
      track.destroy
    end

    FileUtils.rm_rf("tmp/downloads/#{uuid}")
  end
end
