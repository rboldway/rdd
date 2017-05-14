require 'spec_helper'

describe Rdd do

  # EXAMPLES
  # Activity for 1/1/2015 @ 3PM UTC   2015-01-01-15
  # Activity for 1/1/2015             2015-01-01-{0..23}
  # Activity for all of January 2015  2015-01-{01..30}-{0..23}
  # yyyy-mm-dd-{dd..dd}-{hh..hh}

  it 'create time segment over one hour during same day' do
    after =  Time.new(2017,5,5, 11,0,0, "+06:00")
    before = Time.new(2017,5,5, 11,30,0, "+06:00")
    time_segment = Rdd::TimeRange.new(after, before).composite
    expect(time_segment).to eq "2017-05-05-11"
  end

  it 'create time segment over several hours during same day' do
    after =  Time.new(2017,5,5, 11,0,0, "+06:00")
    before = Time.new(2017,5,5, 18,30,0, "+06:00")
    time_segment = Rdd::TimeRange.new(after, before).composite
    expect(time_segment).to eq "2017-05-05-{11..18}"
  end

  it 'create time segment over same day' do
    after =  Time.new(2017,5,5, 0,0,0, "+06:00")
    before = Time.new(2017,5,5, 0,0,0, "+06:00")
    time_segment = Rdd::TimeRange.new(after, before).composite
    expect(time_segment).to eq "2017-05-05-0"
  end

  it 'create time segment over several days' do
    after =  Time.new(2017,5,5, 0,0,0, "+06:00")
    before = Time.new(2017,5,7, 0,0,0, "+06:00")
    time_segment = Rdd::TimeRange.new(after, before).composite
    expect(time_segment).to eq "2017-05-{05..07}"
  end

  it 'create time segment over several days' do
    after =  Time.new(2017,5,5, 10,0,0, "+06:00")
    before = Time.new(2017,5,7, 11,0,0, "+06:00")
    time_segment = Rdd::TimeRange.new(after, before).composite
    expect(time_segment).to eq "2017-05-{05..07}"
  end


  it 'print search archive results' do
    top = 4
    after =  Time.new(2015,1,1, 12,0,0, "+06:00")
    before = Time.new(2015,1,1, 12,0,0, "+06:00")
    expect{Rdd::search_archive_over_time(after: after, before: before, top: top)}.to output(/points/).to_stdout
  end

  it 'normalize day with 1,2' do
    expect(Rdd.normalize_day(1,2)).to eq [1,2]
  end

  it 'normalize day with 7,nil' do
    expect(Rdd.normalize_day(7,nil)).to eq [7,7]
  end

  it 'normalize day with nil,7 which raises error' do
    expect{Rdd.normalize_day(nil,7)}.to raise_error RuntimeError, "missing after_day"
  end

  it 'normalize hour with 1,2' do
    expect(Rdd.normalize_hour(1,2)).to eq [1,2]
  end

  it 'normalize hour with 7,nil' do
    expect(Rdd.normalize_hour(7,nil)).to eq [7,7]
  end

  it 'normalize hour with nil,7 which raises error' do
    expect{Rdd.normalize_hour(nil,7)}.to raise_error RuntimeError, "missing after_hour"
  end

  it 'creates an array of 4 urls' do
    url = "http://data.githubarchive.org/2015-01-{01..02}-{0..1}.json.gz"
    array = Rdd.unpack_uri(url)
    expect(array.size).to eq 4
    expect(array.first).to eq "http://data.githubarchive.org/2015-01-01-0.json.gz"
  end

end

