# Crawler

Context: PDI, Segfy

<aside>
💡 Uma breve demonstração da maneira que fazemos as automações do Hfy

</aside>

### Script

### 1 - Criar  e acessar um container no docker

```ruby
docker container run -d --name rubycrawler -it -v $PWD:/home/app ruby:3.0
docker container exec -it rubycrawler bash
```

### **2 - Criar um arquivo chamado `script.rb` para iniciara as automações**

### **3 - Criar um arquivo para alocarmos a instalação das gems, chamado `Gemfile`**

```ruby
source 'https://rubygems.org'
gem 'mechanize'

# Comando
	bundle install
-> Vai gerar Gemfile.lock

```

Após adicionar a gem desejada precisa  rodar o comando para `bundle install` para instalar, o comando vai criar um aquivo chamado `Gemfile.lock` que irá ficar salvo as gem instalada e suas dependências.

### 4 - **Vamos fazer nossa primeira request**

```ruby
#declarar o uso
require 'mechanize'

#Instanciar o mechanize
agent = Mechanize.new

#GET
home_page = agent.get 'https://www.cinemaxbeltrao.com.br/home.php'

#Comando para salvar o retorno em HTML
File.write('log/home_page.html', home_page.body)
```

para debugar é preciso instalar a gem `pry` e colocar na que deseja fazer o breakpoint o comando `binding.pry`

> -- Utilizar o `Nokogiri` pra fazer o parse do retorno para HTML
-- Utilizar a função `search` do QuerySelector para pegar propriedades do HTML
> 

```ruby
#Exemplo
movies = html_page.search('div[id="cycleMovies"] a')[3]
movie_url =  movies.attr('href')
movie_id = $1 if movies.attr('href') =~ /=(.*)/

```

### 5 - **Fazer request e coletar os detalhes do filme**

```ruby
#Detail
movie_detail = agent.get "https://www.cinemaxbeltrao.com.br/#{movie_url}"
movie_detail = agent.get "https://www.cinemaxbeltrao.com.br/detalhes.php?filme=#{movie_id}"
File.write('log/movie_detail.html', movie_detail.body)
movie_detail = Nokogiri::HTML movie_detail.body
```

### 6 - **Criar um retorno padrão e coletar os dados**

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

### 7 - **Coletar os dias e criar os parâmetros para trazer as sessões**

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

### 8 - **Primeiro Post**

```ruby
session = agent.post('https://www.cinemaxbeltrao.com.br/getSessao.php', params, {})
File.write('log/session.html', session.body)
session_page =  Nokogiri::HTML session.body
```

### 9 - Retorno

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

### 1 - **Criar uma classe, instalar a gem `step_machine`**

```ruby
classMovie
    module_function
    
    def initialize
        p 'é noiz'
    end
end

Movie.new
```

### 2 - **Instanciar o step_machine**

```ruby
require 'pry'
require 'step_machine'
include StepMachine

class Movie
    
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

Movie.new
```

### 3 - **Instalar a gem rspec**

```ruby
#Gemfile
gem 'rspec'
#rodar
rspec --init
```

Podemos criar um arquivo de teste para nossa classe

```ruby
	require 'spec_helper'
	require "movie"
	
	describe Movie do
	    it "should be valid status" do
	        Movie.new
	    end
	end

#Criar params no teste
 params = OpenStruct.new(day: 18)
  Movie.new(params)

#Expect
expect(movie.result.status).to eql('OK')
```

> #Para enfeitar a visualização dos teste, incluior essas linhas no arquivo `.spec`
--color
--format documentation
--format progress
> 

### 4 -**Criar a classe requests e fazer as importações**

```ruby
module MovieRequests
end

#Module Movie
require 'movie_requests'
include MovieRequests
```

### 5 - **Importar os aquivos Utils**

```ruby
#MovieRequest
	require_relative './../utils/requests'
	include Requests

#Movie
	require_relative './../utils/init_mechanize'
	include InitMechanize
```

[init_mechanize.rb](Crawler%20684649e537aa4b08b75bc08a706762b5/init_mechanize.rb)

[requests.rb](Crawler%20684649e537aa4b08b75bc08a706762b5/requests.rb)

Os arquivos assim, são classes criados pelo Dev da Segfy com o intuito de facilitar a organização do código das automações.

### 6 - **Criar a primeira request**

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

    Coletar os dados necessário para a próxima request.

```ruby
end.success do |step|
    page = Nokogiri::HTML step.result.body

    movies = page.search('div[id="cycleMovies"] a')[3]
    @params.movie_id = $1 if movies.attr('href') =~ /=(.*)/
end
```

### 7 - Dynamic request

```ruby
#movie
step(:movie_detail) do 
    get movie_detail_request
end

#MovieRequests
dynamic_request(:movie_detail) do 
		{
			url: "https://www.cinemaxbeltrao.com.br/detalhes.php?filme=#{@params.movie_id}",
			params: {}
		}
end
```

Vamos coletar as informações para o filme e o parâmetro para a próxima request.

```ruby
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
    @params.selected_day = days[@params.day]
end
```

### 8 - Post

Vamos fazer um post para obter os horários do filme para um determinado dia.

```ruby
#MovieRequest
dynamic_request(:session) do
	{
		url: 'https://www.cinemaxbeltrao.com.br/getSessao.php',
		params: {
			'data'	 =>  @params.selected_day,
			'cartaz' => @params.movie_id
		}	
	}
end

#Movie
step(:session) do 
    post session_request
end.success do |step|
    page = Nokogiri::HTML step.result.body

    result[:sessions] = page.search('div[class="ro"]').inject({}) do |mem, elem|
        key = elem.search('div[class="x-150"]').text
        value = elem.search('div[class="x-180"]').last.text
        mem[key] = value
        mem
    end
end
```

### 8 - Validações

Caso queira interromper o fluxo e devolver uma mensagem de validação, a gem possui um método chamado `on_step_failure`

```ruby
#No step
end.validate do |step|
      page = Nokogiri::HTML step.result.body
      message = page.search('h3[class="emptySessao"]').text
      step.errors << message if message.present?
  end

#Método que trata as validações
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
```