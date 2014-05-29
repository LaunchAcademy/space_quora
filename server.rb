require 'sinatra'

def find_questions
  [
    { "content" => "What is the meaning of life?" }
  ]
end

get '/questions' do
  @questions = find_questions
  erb :'questions/index.html'
end
