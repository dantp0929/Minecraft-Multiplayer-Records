class Session < ApplicationRecord
    has_many_attached :sounds
    has_many_attached :textures
end
