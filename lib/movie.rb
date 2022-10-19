
require 'pry'
require 'step_machine'
require 'movie_requests'
require_relative './../utils/init_mechanize'

include StepMachine
include MovieRequests
include InitMechanize

module Movie
    
    module_function

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
        end


    end
end

