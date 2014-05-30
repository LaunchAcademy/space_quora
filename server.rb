require 'sinatra'
require 'pg'
require 'pry'

use Rack::Session::Cookie, secret: ENV['SECRET_TOKEN']

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

def create_user(username, password)
  connection = PG.connect(dbname: 'space_quora')
  query = "INSERT INTO users (username, password, created_at) VALUES ($1, $2, NOW())"
  connection.exec_params(query, [username, password])
end

def validate_user(username, password)
  connection = PG.connect(dbname: 'space_quora')
  query = "SELECT id FROM users WHERE username LIKE $1 AND password LIKE $2"
  result = connection.exec_params(query, [username, password]).to_a
  if result.empty?
    return nil
  else
    result.first["id"]
  end
end

def username_exists?(username)
  connection = PG.connect(dbname: 'space_quora')
  query = 'SELECT username FROM users where username LIKE $1'
  result = connection.exec_params(query, [username]).to_a

  if result.empty?
    false
  else
    true
  end
end

def authorized?
  if session[:user_id] == nil
    false
  else
    true
  end
end

get '/login' do
  erb:'auth/login.html'
end

post '/login' do
  username = params["username"]
  password = params["password"]
  user_id = validate_user(username, password)
  session[:user_id] = user_id

  redirect '/questions'
end

get '/logout' do
  session.clear
  redirect '/login'
end

get '/signup' do
  erb:'auth/signup.html'
end

post '/signup' do
  username = params["username"]
  password = params["password"]
  if username_exists?(username)
   redirect '/signup'
  end
  create_user(username, password)
  redirect '/questions'
end

get '/questions' do
  #redirect them to login if unauthorized
  unless authorized?
    redirect '/login'
  end
  @questions = find_questions
  erb :'questions/index.html'
end

post '/questions' do
  save_question(params["content"])
  redirect '/questions'
end
