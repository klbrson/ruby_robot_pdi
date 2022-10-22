require_relative './../utils/requests'

module MovieRequests
	include Requests
	
	request(:home, 'https://www.cinemaxbeltrao.com.br/home.php') do
		{}
	end
	
	dynamic_request(:movie_detail) do 
		{
			url: "https://www.cinemaxbeltrao.com.br/detalhes.php?filme=#{@params.movie_id}",
			params: {}
		}
	end

	dynamic_request(:session) do
		{
			url: 'https://www.cinemaxbeltrao.com.br/getSessao.php',
			params: {
				'data'	 =>  @params.selected_day,
				'cartaz' => @params.movie_id
			}	
		}
	end
	
end