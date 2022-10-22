
require 'pry'
require 'active_support'
require 'step_machine'
require 'movie_requests'
require_relative './../utils/init_mechanize'


class Movie
    attr_accessor :result

    include StepMachine
    include MovieRequests
    include InitMechanize

    def initialize(params)
        @params = params
        @result = OpenStruct.new
        define_steps
        run_steps
        
    end

    def define_steps
        step(:first) do 
		    p "Meu primeiro STEP com parametro #{@params[:day]}"
            @result.status = 'OK'
        end

        step(:home) do
            get home_request
        end.success do |step|
            page = Nokogiri::HTML step.result.body
            
            movies = page.search('div[id="cycleMovies"] a').first
            @params.movie_id = $1 if movies.attr('href') =~ /=(.*)/
        end

        step(:movie_detail) do 
            get movie_detail_request
        end.success do |step|
            page = Nokogiri::HTML step.result.body
            
            @result[:movie_name] = page.search('div[id="movieContent"] h1').text
            @result[:description] =  page.search('div[id="movieContent"] span').first.text
            @result[:gender] = page.search('div[class="genero"]').text

            days = page.search('div[class="dias"] li').inject({}) do |hash, elem| 
                key =  elem.search('span').text
                value =  elem.search('input').attr('value').text
            
                hash[key] = value
                hash
            end
            @params.selected_day = days[@params.day.to_s]
        end

        step(:session) do 
            post session_request
        end.validate do |step|
            page = Nokogiri::HTML step.result.body
            message = page.search('h3[class="emptySessao"]').text
            step.errors << message if message.present?
        end.success do |step|
            page = Nokogiri::HTML step.result.body

            result[:sessions] = page.search('div[class="ro"]').inject({}) do |mem, elem|
                key = elem.search('div[class="x-150"]').text
                value = elem.search('div[class="x-180"]').last.text
                mem[key] = value
                mem
            end
        end
 
        on_step_failure do |f|
            if f.step.exception
                @result.status = 'EXCEPTION'
                @result.message = f.step.exception
                @result.last_step =  f.step.name
            elsif f.step.errors.present?
                @result.status = 'FAILURE'
                @result.message = f.step.errors
            end
        end
        

    end
    
end

