require_relative './../utils/requests'

module MovieRequests
    include Requests

    request(:home, "https://www.cinemaxbeltrao.com.br/home.php") do
		{}
	end
end