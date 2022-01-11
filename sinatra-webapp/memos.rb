# frozen_string_literal: true

require 'sinatra'
require 'cgi'
require_relative 'error_check'
require 'pg'

MEMO_ID_DIGIT = 10
TABLE_NAME = 'memos'
TITLE_COL = 'title'
ID_COL = 'memo_id'
BODY_COL = 'memo'
# MEMO_ID = "to_char(#{ID_COL}, 'FM0000000000')"

get '/' do
  @memo_titles = read_titles
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
    id_text = new_id
    add_memo(params)
    redirect to('/')
  else
    @memo_contents = params
    erb :new_memo
  end
end

delete %r{/memos/([0-9]{#{MEMO_ID_DIGIT}})} do |id_text|
  delete_memo(id_text)
  redirect to('/')
end

get %r{/memos/([0-9]{#{MEMO_ID_DIGIT}})} do |id_text|
  @memo_contents = read_memo_contents(id_text)
  erb :memo_contents
end

get %r{/memos/([0-9]{#{MEMO_ID_DIGIT}})/editor} do |id_text|
  @error_check = ErrorCheck.new
  @memo_contents = read_memo_contents(id_text)
  erb :editor
end

patch %r{/memos/([0-9]{#{MEMO_ID_DIGIT}})} do |id_text|
  @error_check = ErrorCheck.new(params)
  if @error_check.status
    update_memo(id_text, params)
    redirect to(memo_url(id_text))
  else
    @memo_contents = params
    @memo_contents[:memo_id] = id_text
    erb :editor
  end
end

def add_memo(params)
  conn = connect_db
  conn.exec(sql_insert(sanitizer(params[:title]), sanitizer(params[:body])))  # ここはシンボルをリテラルで入れないとescapeHTMLでエラーが出る
end

def sql_insert(title, body)
  "INSERT INTO #{TABLE_NAME} (#{TITLE_COL}, #{BODY_COL}) VALUES ('#{title}', '#{body}')"
end

def update_memo(id_text, params)
  conn = connect_db
  conn.exec(sql_update(sanitizer(params[:title]), sanitizer(params[:body]), id_text.to_i)) # 同上
end

def sql_update(title, body, id_integer)
  "UPDATE #{TABLE_NAME} SET #{TITLE_COL} = '#{title}', #{BODY_COL} = '#{body}' WHERE #{ID_COL} = #{id_integer}"
end

def sanitizer(text)
  CGI.escapeHTML(text).gsub('\r\n', '<br />')
end

def read_titles
  memos = []
  conn = connect_db
  conn.exec("SELECT #{MEMO_ID} as #{ID_COL}, #{TITLE_COL} FROM #{TABLE_NAME}") do |result|
    memos = result_into_array(result)
  end
  memos
end

def connect_db
  conn = PG.connect(dbname: 'postgres')
  conn.field_name_type = :symbol
  conn
end

def result_into_array(result)
  memos = []
  result.cmd_tuples.times do |i|
    memos << result[i]
  end
  memos
end

def read_memo_contents(id_text)
  contents = {}
  conn = connect_db
  conn.exec("SELECT #{MEMO_ID} as #{ID_COL}, #{TITLE_COL}, #{BODY_COL} as #{BODY_COL} FROM #{TABLE_NAME} WHERE #{ID_COL} = #{id_text.to_i}") do |result|
    contents = result[0]
  end
  contents
end

def delete_memo(id_text)
  conn = connect_db
  conn.exec("DELETE FROM #{TABLE_NAME} WHERE #{ID_COL} = #{id_text.to_i}")
end
