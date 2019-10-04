class Movie < ActiveRecord::Base
    def self.all_ratings
        ['G','PG','PG-13','R']
    end

    def self.with_ratings_sorted(ratings, key)
        if key.nil?
            self.where(['rating in (?)', ratings])
        else
            self.where(['rating in (?)', ratings]).order(key)
        end
    end
end
