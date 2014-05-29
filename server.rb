require 'sinatra'
require 'pg'

def find_questions
  connection = PG.connect(dbname: 'space_quora')
  results = connection.exec('SELECT * FROM questions')
  connection.close

  results
end

get '/questions' do
  @questions = find_questions
  erb :'questions/index.html'
end
