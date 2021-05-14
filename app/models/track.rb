class Track < ApplicationRecord
  include Rails.application.routes.url_helpers
  has_one_attached :song
  has_one_attached :texture

  # Makes folders for download
  def self.create_folders(uuid)
    FileUtils.mkdir_p('tmp/downloads/' + uuid + '/multiplayer_records/multiplayer_records_rp/assets/minecraft/models/item')
    FileUtils.mkdir_p('tmp/downloads/' + uuid + '/multiplayer_records/multiplayer_records_rp/assets/minecraft/sounds/records')
    FileUtils.mkdir_p('tmp/downloads/' + uuid + '/multiplayer_records/multiplayer_records_rp/assets/minecraft/textures/item')

    FileUtils.mkdir_p('tmp/downloads/' + uuid + '/multiplayer_records/multiplayer_records_dp/data/multiplayer_records_dp/functions/item')
    FileUtils.mkdir_p('tmp/downloads/' + uuid + '/multiplayer_records/multiplayer_records_dp/data/minecraft/loot_tables/entities')
    FileUtils.mkdir_p('tmp/downloads/' + uuid + '/multiplayer_records/multiplayer_records_dp/data/minecraft/tags/functions')
  end

  # Creates neccessary files for the datapack
  def self.create_files(uuid, tracks) 
    # Write pack.mcmeta
    packMCMETA = {
      'pack' => {
        'pack_format' => 4,
        'description' => "Datapack with #{tracks.length} custom songs."
      }
    }
    File.open('tmp/downloads/' + uuid + '/multiplayer_records/multiplayer_records_dp/pack.mcmeta', 'w') do |file|
      file.write(JSON.pretty_generate(packMCMETA))
    end

    # Write load.json
    loadJSON = {
      'values' => ['multiplayer_records_dp:setup_load']
    }
    File.open('tmp/downloads/' + uuid + '/multiplayer_records/multiplayer_records_dp/data/minecraft/tags/functions/load.json', 'w') do |file|
      file.write(JSON.pretty_generate(loadJSON))
    end

    # Write tick.json
    tickJSON = {
      'values' => ['multiplayer_records_dp:detect_play_tick',
                    'multiplayer_records_dp:detect_stop_tick']
    }
    File.open('tmp/downloads/' + uuid + '/multiplayer_records/multiplayer_records_dp/data/minecraft/tags/functions/tick.json', 'w') do |file|
      file.write(JSON.pretty_generate(tickJSON))
    end

    # Write setup_load.mcfunction
    setupLoadMCFUNCTION = "scoreboard objectives add usedDisc minecraft.used:minecraft.music_disc_11\n\
scoreboard objectives add heldDisc dummy\n\
tellraw @a {\"text\": Multiplayer Records v1.0 by adnaP\", \"color\": \"yellow\"}\n"
    File.open('tmp/downloads/' + uuid + '/multiplayer_records/multiplayer_records_dp/data/multiplayer_records_dp/functions/setup_load.mcfunction', 'w') do |file|
      file.write(setupLoadMCFUNCTION)
    end

    # Write detect_play_tick.mcfunction
    detectPlayTickMCFUNCTION = ""

	end

  def formatted_track_name
    formatted = name.gsub '-', ' '
    return formatted.parameterize(separator: '_') + ".png"
  end
end
