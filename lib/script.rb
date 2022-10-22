
require 'mechanize'
require 'pry'

result = {
    movie_name: '',
    description: '',
    gender: '',
    age_classification: '',
    type: '',
    sessions: {
        day: '',
        session_time: '',
        message: ''
    }

}

agent = Mechanize.new

# GET home
home_page = agent.get 'https://www.cinemaxbeltrao.com.br/home.php'
File.write('log/home_page.html', home_page.body)

# Collect detail
html_page = Nokogiri::HTML home_page.body
movies = html_page.search('div[id="cycleMovies"] a')[3]
movie_url =  movies.attr('href')
movie_id = $1 if movies.attr('href') =~ /=(.*)/

#GET detail
movie_detail = agent.get "https://www.cinemaxbeltrao.com.br/detalhes.php?filme=#{movie_id}"
File.write('log/movie_detail.html', movie_detail.body)
movie_detail = Nokogiri::HTML movie_detail.body

# Collect data
result[:movie_name] = movie_detail.search('div[id="movieContent"] h1').text
result[:description] =  movie_detail.search('div[id="movieContent"] span').first.text
result[:gender] = movie_detail.search('div[class="genero"]').text

# Collect session days 
days = movie_detail.search('div[class="dias"] li').inject({}) do |hash, elem| 
    key =  elem.search('span').text
    value =  elem.search('input').attr('value').text

    hash[key] = value
    hash
end

# create params 
params = {
    'data'=> days['13'],
    'cartaz'=> movie_id
}

session = agent.post('https://www.cinemaxbeltrao.com.br/getSessao.php', params, {})
File.write('log/session.html', session.body)
session_page =  Nokogiri::HTML session.body

validation = session_page.search('h3[class="emptySessao"]').text

if validation.empty?
    result[:sessions][:day]  = session_page.search('div[class="x-180"]:has(i[class="fa fa-calendar"])').text
    result[:sessions][:session_time] =  session_page.search('div[class="x-150"]').collect{|el| el.text}
else
    result[:sessions][:message] = validation
end

File.write('log/result.json', result)