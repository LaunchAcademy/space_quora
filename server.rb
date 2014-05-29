require 'sinatra'
require 'pg'

def save_question(content)
  sql = "INSERT INTO questions (content, created_at) " +
    "VALUES ($1, NOW())"

  connection = PG.connect(dbname: 'space_quora')
  connection.exec_params(sql, [content])
  connection.close
end

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

post '/questions' do
  save_question(params["content"])
  redirect '/questions'
end
