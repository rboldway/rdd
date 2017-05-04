require "rdd/version"
require 'rdd/events'

require 'optparse'
require 'optparse/time'
require 'ostruct'

require 'open-uri'
require 'zlib'
require 'oj'

require 'byebug'

module Rdd

  def self.validate

=begin
  rdd [--after DATETIME] [--before DATETIME] [--top COUNT]

  rdd --after 2015-03-18T13:00:00Z
  rdd --after 2015-08-05T15:10:02-00:00
  rdd --after 2015-03-16
  rdd --top 500
  rdd --after 2015-01-01 --before 2015-01-08

  Options:
    [--after=AFTER]    # Date to start search at, ISO8601 or YYYY-MM-DD format
  # Default: 28 days ago
  [--before=BEFORE]  # ISO8601 Date to end search at, ISO8601 or YYYY-MM-DD format
  # Default: Now
  [--top=N]          # The number of repos to show
  # Default: 20
=end

    options = OpenStruct.new

    OptionParser.new do |opts|

      # Defaults
      options.before = Time.now
      options.after = options.before - (60 * 60 * 24 * 28)
      options.count = 20

      opts.banner = "Usage: #{File.basename($0,'.*')} [--after DATE] [--before DATE] [--top COUNT]"

      # Cast 'after' argument to a Time object.
      opts.on("--after [AFTER]", Time, "Start search") do |after|
        options.after = after
      end

      # Cast 'before' argument to a Time object.
      opts.on("--before [BEFORE]", Time, "End search") do |before|
        options.before = before
      end

      # Cast 'top' argument to a Integer object.
      opts.on("--top [COUNT]", Integer, "The number of repos to show") do |count|
        options.count = count
      end

      # No argument, shows at tail.  This will print an options summary.
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      if ARGV.empty?
        puts opts
        exit
      end

    end.parse!

  end

  def date_verify
    # parse date
    # validate date
    # determine archive
    # return archivegit
  end

  class << self

    public

    def search_archive(url)
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

      # sort descending into nested array
      repositories = repositories.sort_by {|_,value| -value[:count]}

      top = 12
      # guard top and truncate repositories if top is present
      if (top ||= nil)
        top = [top, repositories.size].min
        repositories = repositories[0..top-1]
      end

      repositories.each_with_index do |entry, i|
        puts "##{i+1}. #{entry[1][:name]} - #{entry[1][:count]} points"
      end
    end

  end

end
