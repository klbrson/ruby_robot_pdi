require 'mechanize'
require 'pry'

module InitMechanize
    
    module_function

	def init_mechanize(options = {})
        @utils_mechanize_options = options
        
        @mechanize = Mechanize.new do |a|
            a.user_agent_alias = ['Windows Mozilla', 'Windows IE 9', 'Windows IE 10', 'Windows IE 11', 'Windows Firefox', 'Mac Firefox', 'Linux Firefox'].sample
            a.verify_mode = OpenSSL::SSL::VERIFY_NONE
            a.redirect_ok = :all
        end
    end

    def post(request)
		init_mechanize
		@request = request
		page = @mechanize.post(request.url, request.params, request.options)
		debug_log(request, page) rescue nil
		page
	end

	def get(request)
		init_mechanize
		@request = request
		page = @mechanize.get(request.url, request.params, nil, request.options)
		debug_log(request, page) rescue nil
		page
	end

	def debug_log(request, page)
		filename = "log/#{ Time.now.to_i }-#{request.description}"
		( File.open("#{filename}.json", 'w') << {url: request.url, params: request.params, options: request.options} ).close_write
		page.save("#{filename}.html")
	end

    
end

