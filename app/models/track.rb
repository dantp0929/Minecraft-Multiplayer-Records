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
    detectPlayTickMCFUNCTION = "execute as @a[scores={usedDisc=0}] run scoreboard players set @s heldDisc -1\n\
execute as @a[scores={usedDisc=0},nbt={Inventory:[{Slot:-106b,id:\"minecraft:music_disc_11\"}]}] store result score @s heldDisc run data get entity @s Inventory[{Slot:-106b}].tag.CustomModelData\n\
execute as @a[scores={usedDisc=0},nbt={SelectedItem:{id:\"minecraft:music_disc_11\"}}] store result score @s heldDisc run data get entity @s SelectedItem.tag.CustomModelData\n\
execute as @a[scores={usedDisc=2}] run function multiplayer_records_dp:disc_play\n\
execute as @a run scoreboard players add @s usedDisc 0\n\
execute as @a[scores={usedDisc=2..}] run scoreboard players set @s usedDisc 0\n\
scoreboard players add @a[scores={usedDisc=1}] usedDisc 1\n'"
    File.open('tmp/downloads/' + uuid + '/multiplayer_records/multiplayer_records_dp/data/multiplayer_records_dp/functions/detect_play_tick.mcfunction', 'w') do |file|
      file.write(detectPlayTickMCFUNCTION)
    end

    # Write disc_play.mcfunction
    discPlayMCFUNCTION = ""
    tracks.each do |track|
      discPlayMCFUNCTION += "execute as @s[scores={heldDisc=#{track.custom_model_id}}] run function multiplayer_records_dp:play_#{track.formatted_track_name}\n"
    end
    File.open('tmp/downloads/' + uuid + '/multiplayer_records/multiplayer_records_dp/data/multiplayer_records_dp/functions/detect_play_tick.mcfunction', 'w') do |file|
      file.write(discPlayMCFUNCTION)
    end

    # Write disc_stop_tick.mcfunction
    discStopTickMCFUNCTION = "execute as @e[type=item, nbt={Item:{id:\"minecraft:music_disc_11\"}}] at @s unless entity @s[tag=old] if block ~ ~-1 ~ minecraft:jukebox run function multiplayer_records_dp:disc_stop\n\
execute as @e[type=item, nbt={Item:{id:\"minecraft:music_disc_11\"}}] at @s unless entity @s[tag=old] if block ~ ~ ~ minecraft:jukebox run function multiplayer_records_dp:disc_stop\n\
execute as @e[type=item, nbt={Item:{id:\"minecraft:music_disc_11\"}}] at @s unless entity @s[tag=old] run tag @s add old\n"
    File.open('tmp/downloads/' + uuid + '/multiplayer_records/multiplayer_records_dp/data/multiplayer_records_dp/functions/detect_stop_tick.mcfunction', 'w') do |file|
      file.write(discStopTickMCFUNCTION)
    end

    # Write disc_stop.mcfunction
    discStopMCFUNCTION = ""
    tracks.each do |track|
      discStopMCFUNCTION = "execute as @s[nbt={Item:{tag:{CustomModelData:#{track.custom_model_id}}}}] at @s run stopsound @a[distance=..64] record minecraft:music_disc.#{track.formatted_track_name}\n"
    end
    File.open('tmp/downloads/' + uuid + '/multiplayer_records/multiplayer_records_dp/data/multiplayer_records_dp/functions/disc_stop.mcfunction', 'w') do |file|
      file.write(discStopMCFUNCTION)
    end

    # Write set_disc_track.mcfunction
    setDiscTrackMCFUNCTION = ""
    tracks.each do |track|
      setDiscTrackMCFUNCTION = "execute as @s[nbt={SelectedItem:{id:"minecraft:music_disc_11", tag:{CustomModelData:#{track.custom_model_id}}}}] run replaceitem entity @s weapon.mainhand minecraft:music_disc_11{CustomModelData:#{track.custom_model_id}, HideFlags:32, display:{Lore:[\"\\\"\\\\u00a77#{track.name}\\\"\"]}}\n"
    end
    File.open('tmp/downloads/' + uuid + '/multiplayer_records/multiplayer_records_dp/data/multiplayer_records_dp/functions/set_disc_track.mcfunction', 'w') do |file|
      file.write(setDiscTrackMCFUNCTION)
    end

    # Write play_*.mcfunction
    tracks.each do |track|
      playMCFUNCTION = "execute as @s at @s run title @a[distance=..64] actionbar {\"text\":\"Now Playing: #{track.name}\",\"color\":\"green\"}\n\
execute as @s at @s run stopsound @a[distance=..64] record minecraft:music_disc.11\n\
execute as @s at @s run playsound minecraft:music_disc.#{track.formatted_track_name} record @a[distance=..64] ~ ~ ~ 4 1\n"
      File.open("tmp/downloads/" + uuid + "/multiplayer_records/multiplayer_records_dp/data/multiplayer_records_dp/functions/play_#{track.formatted_track_name}.mcfunction", 'w') do |file|
        file.write(playMCFUNCTION)
      end
    end

    creeper = open(os.path.join(datapack_name, 'data', 'minecraft', 'loot_tables', 'entities', 'creeper.json'), 'w')

    creeper_mdentries = []
    creeper_mdentries.append({'type':'minecraft:tag', 
                              'weight':1, 
                              'name':'minecraft:creeper_drop_music_discs', 
                              'expand':True})

    for i, track in enumerate(track_list):
        i+=1
        
        creeper_mdentries.append({'type':'minecraft:item', 
                                  'weight':1, 
                                  'name':'minecraft:music_disc_11', 
                                  'functions':[{
                                    'function':'minecraft:set_nbt', 
                                    'tag':'{
                                      CustomModelData:%d, 
                                      HideFlags:32, 
                                      display:{
                                        Lore:[\"\\\"\\\\u00a77%s\\\"\"]
                                      }
                                    }' % (i, track.replace('"', ''))}]})
    
    creeper_normentries = [{'type':'minecraft:item',
                            'functions':[{
                              'function':'minecraft:set_count', 
                              'count':{
                                'min':0.0, 
                                'max':2.0, 
                                'type':'minecraft:uniform'
                              }
                            }, 
                            {
                              'function':'minecraft:looting_enchant', 
                              'count':{
                                'min':0.0, 
                                'max':1.0
                              }
                            }], 
                              'name':'minecraft:gunpowder'}]
    creeper.write(json.dumps({'type':'minecraft:entity', 
                              'pools':[{
                                'rolls':1,
                                'entries':creeper_normentries
                              }, 
                              {'rolls':1, 
                              'entries':creeper_mdentries, 
                              'conditions':[{
                                'condition':'minecraft:entity_properties', 
                                'predicate':{
                                  'type':'#minecraft:skeletons'
                                }, 
                                'entity':'killer'
                              }]
                              }]
                            }, 
                            indent=4))
    creeper.close()

    # Write creeper.json

  end

  def formatted_track_name
    formatted = name.gsub '-', ' '
    return formatted.parameterize(separator: '_') + ".png"
  end

  def custom_model_id
    return Digest::SHA1.hexdigest(name).to_i(16)
  end
end
