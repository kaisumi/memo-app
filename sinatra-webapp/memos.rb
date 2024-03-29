# frozen_string_literal: true

require 'sinatra'
require 'cgi'
require 'pg'
require_relative 'error_check'
require_relative 'constant_parameters'

CONN = PG.connect(dbname: DB_NAME)

get '/' do
  @memo_titles = sql_interaction(:read_titles)
  erb :index
end

get '/new-memo' do
  @memo_contents = { title: '', body: '' }
  @error_check = ErrorCheck.new
  erb :new_memo
end

post '/memos' do
  @error_check = ErrorCheck.new(params)
  if @error_check.status
    sql_interaction(:insert, params: params)
    redirect to('/')
  else
    @memo_contents = params
    erb :new_memo
  end
end

delete %r{/memos/([0-9]{#{MEMO_ID_DIGIT}})} do |id_text|
  sql_interaction(:delete, id_integer: id_text.to_i)
  redirect to('/')
end

get %r{/memos/([0-9]{#{MEMO_ID_DIGIT}})} do |id_text|
  @memo_contents = sql_interaction(:read_contents, id_integer: id_text.to_i)
  erb :memo_contents
end

get %r{/memos/([0-9]{#{MEMO_ID_DIGIT}})/editor} do |id_text|
  @error_check = ErrorCheck.new
  @memo_contents = sql_interaction(:read_contents, id_integer: id_text.to_i)
  erb :editor
end

patch %r{/memos/([0-9]{#{MEMO_ID_DIGIT}})} do |id_text|
  @error_check = ErrorCheck.new(params)
  if @error_check.status
    sql_interaction(:update, params: params, id_integer: id_text.to_i)
    redirect to(memo_url(id_text))
  else
    @memo_contents = params
    @memo_contents[:memo_id] = id_text
    erb :editor
  end
end

def sql_interaction(command, params: nil, id_integer: nil)
  sql_params = []
  sql_params << params['title'] << params['body'] unless params.nil?
  sql_params << id_integer unless id_integer.nil?
  sql_text = generate_sql(command)
  execute_sql(command, sql_text, sql_params)
end

def generate_sql(command)
  case command
  when :insert
    "INSERT INTO #{TABLE_NAME} (#{TITLE_COL}, #{BODY_COL}) VALUES ($1, $2)"
  when :update
    "UPDATE #{TABLE_NAME} SET #{TITLE_COL} = $1, #{BODY_COL} = $2 WHERE #{ID_COL} = $3"
  when :delete
    "DELETE FROM #{TABLE_NAME} WHERE #{ID_COL} = $1"
  when :read_titles
    "SELECT #{MEMO_ID} as #{ID_COL}, #{TITLE_COL} FROM #{TABLE_NAME}"
  when :read_contents
    "SELECT #{MEMO_ID} as #{ID_COL}, #{TITLE_COL}, #{BODY_COL} as #{BODY_COL} FROM #{TABLE_NAME} WHERE #{ID_COL} = $1"
  end
end

def execute_sql(command, sql_text, sql_params)
  contents = nil
  CONN.field_name_type = :symbol

  case command
  when :read_titles
    CONN.exec(sql_text) do |result|
      contents = result.to_a
    end
  when :read_contents
    CONN.exec_params(sql_text, sql_params) do |result|
      contents = result[0]
    end
  else
    CONN.exec_params(sql_text, sql_params)
  end
  contents
end

def memo_url(id_text)
  "/memos/#{id_text}"
end
