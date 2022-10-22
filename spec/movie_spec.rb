require 'spec_helper'
require "movie"
require 'pry'

describe Movie do
	it "should be valid status" do
		params = OpenStruct.new(day: 28)
		movie = Movie.new(params)
		 
		expect(movie.result.status).to eql('OK')
	end
end