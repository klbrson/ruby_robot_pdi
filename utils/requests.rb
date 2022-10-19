
module Requests

	module ClassMethods
		def request(description, url, options = {}, &block)
			define_method("#{description}_request") do
				request = Request.new
				request.description = description
				request.params = instance_eval(&block) if block
				request.url = url
				request.options = options
				request
			end
		end

		def dynamic_request(description, url=nil, options = {}, &block)
			define_method("#{description}_request") do
				request = Request.new
				request.description = description
				result = instance_eval(&block) if block
				request.params = result.fetch(:params, {})
				request.url = result.fetch(:url, url)
				request.options = result.fetch(:options, options)
				request
			end
		end
	end

	class Request
		attr_accessor :description, :url, :params, :options
	end


	def self.included(receiver)
		receiver.extend         ClassMethods
	end
	
end
