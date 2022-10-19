require 'mechanize'
require 'pry'

module InitMechanize
    
    module_function

    def init_mechanize(options = {})
        @utils_mechanize_options = options
        @logs = []
        @debug = false
        @list_time = []
        @mechanize = Mechanize.new do |a|
            a.user_agent_alias = ['Windows Mozilla', 'Windows IE 9', 'Windows IE 10', 'Windows IE 11', 'Windows Firefox', 'Mac Firefox', 'Linux Firefox'].sample
            a.verify_mode = OpenSSL::SSL::VERIFY_NONE
            a.redirect_ok = :all
        end
    end

    def post(request)
		init_mechanize
		@request = request
		# check_limits
		page = @mechanize.post(request.url, request.params, request.options)
		# enqueue_log(request, 'POST', page) rescue nil
		# debug_log(request, page)
		page
	end

	def get(request)
		init_mechanize
		@request = request
		page = @mechanize.get(request.url, request.params, nil, request.options)
		# enqueue_log(request, 'GET', page)  rescue nil
		# debug_log(request, page)
		page
	end

    
end

