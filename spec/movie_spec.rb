require 'spec_helper'
require "movie"
require 'pry'

describe Movie do
    it "should be valid status" do
        params = {
            day: 18
        }
        Movie.initialize(params)
    end
end