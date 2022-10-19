# Crawler

Context: PDI, Segfy

<aside>
💡 Uma breve demonstração da maneira que fazemos as automações do Hfy

</aside>

### Script

- **Criar  e acessar um container no docker**

```ruby
docker container run -d --name rubycrawler -it -v $PWD:/home/app ruby:3.0
docker container exec -it rubycrawler bash
```

- **Criar um arquivo chamado `script.rb` para iniciara as automações**
- **Criar um arquivo para alocarmos a instalação das gems, chamdo Gemfile**

```ruby
source 'https://rubygems.org'
gem 'mechanize'

# Comando
	bundle install
-> Vai gerar Gemfile.lock

```

- **Vamos fazer nossa primeira request**

```ruby
#declarar o uso
require 'mechanize'

#Instanciar o mechanize
agent = Mechanize.new

#Fazer um debug com pry
gem 'pry'
binding.pry

#Coletar a URL para abri a próxima pagina
-- Explicar e utiliar o Nokogiri
-- Explicar o Search
-- Selecionar o primeiro filme e coletar a url

	 movies = html_page.search('div[id="cycleMovies"] a')[3]
   movie_url =  movies.attr('href')

```

- **Fazer request e coletar os detalhes do filme**

```ruby
#Detail
movie_detail = agent.get "https://www.cinemaxbeltrao.com.br/#{movie_url}"
File.write('log/movie_detail.html', movie_detail.body)
movie_detail = Nokogiri::HTML movie_detail.body
```

- **Criar um retorno padrão e coletar os dados**

```ruby
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

result[:movie_name] = movie_detail.search('div[id="movieContent"] h1').text
result[:description] =  movie_detail.search('div[id="movieContent"] span').first.text
result[:gender] = movie_detail.search('div[class="genero"]').text
```

- **Coletar os dias e criar os parâmetros para trazer as sessões**

```ruby
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
    'cartaz'=> '73'
}
```

- **Primeiro Post**

```ruby
session = agent.post('https://www.cinemaxbeltrao.com.br/getSessao.php', params, {})
File.write('log/session.html', session.body)
session_page =  Nokogiri::HTML session.body
```

- Retorno

```ruby
validation = session_page.search('h3[class="emptySessao"]').text

if validation.empty?
    result[:sessions][:day]  = session_page.search('div[class="x-180"]:has(i[class="fa fa-calendar"])').text
    result[:sessions][:session_time] =  session_page.search('div[class="x-150"]').collect{|el| el.text}
else
    result[:sessions][:message] = validation
end
```

### Step_machine

- **Criar um module, instalar a gem `step_machine`**

```ruby
module Movie
    module_function
    
    def initialize
        p 'é noiz'
    end
end

Movie.initialize
```

- **Instanciar o step_machine**

```ruby
require 'pry'
require 'step_machine'
include StepMachine

module Movie
    
    module_function

    def initialize
        define_steps
        run_steps
    end

    def define_steps
        step(:first) do 
					p 'meu primeiro STEP'
        end
    end
end

Movie.initialize
```

- **Instalar a gem rspec**

```ruby
#Gemfile
gem 'rspec'
#rodar
rspec --init

#Criar o teste para o module
	require 'spec_helper'
	require "movie"
	
	describe Movie do
	    it "should be valid status" do
	        Movie.initialize
	    end
	end

#no arquivo .spec
--color
--format documentation
--format progress

#Criar params no teste
	describe Movie do
	    it "should be valid status" do
	        params = {
	            day: 18
	        }
	        Movie.initialize(params)
	    end
	end
```

- **Criar a classe requests e fazer as importações**

```ruby
require_relative './../utils/requests'

module MovieRequests
end

#Module Movie
require 'movie_requests'
include MovieRequests
```

- **Importar os aquivos Utils**

```ruby
#MovieRequest
	require_relative './../utils/requests'
	include Requests

#Movie
	require_relative './../utils/init_mechanize'
	include InitMechanize
```

- **Criar a primeira request**

```ruby
# MovieRequests
request(:home, "https://www.cinemaxbeltrao.com.br/home.php") do
		{}
end

#Movie
step(:home) do
    get home_request
end
```

### Docs

```ruby
#*OpenSSL*
agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE

#Rspec
gem 'rspec'
rspec --init #Para criar a pasta

```

Projeto do Tonin

[`https://github.com/Reveilleau/BuscaCep/tree/main/BuscaCep`](https://github.com/Reveilleau/BuscaCep/tree/main/BuscaCep)