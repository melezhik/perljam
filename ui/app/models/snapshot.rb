class Snapshot < ActiveRecord::Base

    belongs_to :build

    validates :indexed_url, presence: true

    def local_path
        "sources/#{id}"
    end

    def url
        if scm_type == 'svn'
            schema + '://' +  ( indexed_url  || 'NULL' )
        elsif scm_type == 'git'
            indexed_url.split(' ').first
        end
    end

    def main?
        is_distribution_url == true        
    end

end
