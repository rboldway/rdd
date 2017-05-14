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

    def unpack_uri(url)
      host_re = /(?<host>http:\/\/[^\/]+)/
      year_re = /\/(?<year>\d{4})/
      month_re = /-(?<month>\d\d)/
      day_re = /-(?<after_day>\d\d)|-{(?<after_day>\d\d)\.\.(?<before_day>\d\d)}/
      hour_re = /-(?<after_hour>\d{1,2})|-{(?<after_hour>\d{1,2})\.\.(?<before_hour>\d{1,2})}/
      ext_re  = /(?<ext>.+)/
      pattern = Regexp.new("#{host_re}#{year_re}#{month_re}#{day_re}#{hour_re}#{ext_re}")
      time_elements = pattern.match(url)

      host = time_elements[:host]
      year = time_elements[:year]
      month = time_elements[:month]
      after_day = time_elements[:after_day]
      before_day = time_elements[:before_day]
      after_hour = time_elements[:after_hour]
      before_hour = time_elements[:before_hour]
      ext = time_elements[:ext]

      after_day, before_day = normalize_day(after_day, before_day)
      after_hour, before_hour = normalize_hour(after_hour, before_hour)
      uri = []
      (after_day..before_day).each do |day|
        (after_hour..before_hour).each do |hour|
          uri << "#{host}/#{year}-#{month}-#{"%02d" % day}-#{"%d" % hour}#{ext}"
        end
      end
      uri
    end

    def normalize_day(after_day, before_day)
      if after_day
        after_day = after_day.to_i
        if before_day
          before_day = before_day.to_i
        else
          before_day = after_day
        end
      else
        raise "missing after_day"
      end
      return after_day,before_day
    end


    def normalize_hour(after_hour, before_hour)
      if after_hour
        after_hour = after_hour.to_i
        if before_hour
          before_hour = before_hour.to_i
        else
          before_hour = after_hour
        end
      else
        raise "missing after_hour"
      end
      return after_hour,before_hour
    end

    # private

    def count_of_days(diff)
      count = 0
      while diff >= (60*60*24)
        diff -= (60*60*24)
        count += 1
      end
      return count
    end

    def expand_time_range(url)
      url.sub(/\/dddd-dd-{dd\.\.dd}/)
    end

    def search_archive(uri, top)
      events = (Rdd.private_methods - Object.private_methods).map(&:to_s)
      repositories = {}
      # start_time = Time.now
      byebug

      unpack_uri(uri).each do |url|
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
      end

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

