class Track < ApplicationRecord
    has_one_attached :song
    has_one_attached :texture
end
