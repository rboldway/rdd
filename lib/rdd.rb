require "rdd/version"
require 'rdd/events'
require 'rdd/time_range'

require 'open-uri'
require 'zlib'
require 'oj'

require 'byebug'

module Rdd

  class << self

    public

    def search_archive_over_time(after: Time.now, before: (Time.now-(60*60*24*28)), top: 20)
      time_segment = TimeRange.new(after,before).composite
      search_archive(url_base(time_segment), top)
    end

    # private

    def search_archive(url, top)
      events = (Rdd.private_methods - Object.private_methods).map(&:to_s)
      repositories = {}
      # start_time = Time.now
      open(url) do |gz|
        Zlib::GzipReader.new(gz).each_line do |line|
          begin
            event = Oj.load(line)
            if events.include?(event["type"])
              current = Rdd.send(event["type"], event)
              if current
                if (repo = repositories[current[:repo][:id]])
                  repo[:count] += current[:points]
                else
                  repo = {current[:repo][:id]=>{name: current[:repo][:name], count: current[:points]}}
                  repositories.merge!(repo)
                end
              end
            end
          rescue Exception => e
            # logging
            raise e
          end
        end
      end
      # puts Time.now - start_time

      # sort descending into array
      repositories = repositories.sort_by {|_,value| -value[:count]}

     [top, repositories.size].min.times do |i|
       entry = repositories.shift
       puts "##{i+1}. #{entry[1][:name]} - #{entry[1][:count]} points"
     end

  end

    def url_base(time_segment)
      "http://data.githubarchive.org/#{time_segment}.json.gz"
    end

  end

end

