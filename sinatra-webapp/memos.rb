# frozen_string_literal: true

require 'sinatra'
require 'cgi'
require_relative 'error_check'

MEMO_ID_DIGIT = 10
STORAGE = 'memos'
LATEST_ID = './memo_latest_id.txt'

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
    write_memo(id_text, params)
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
    write_memo(id_text, params)
    redirect to(memo_url(id_text))
  else
    @memo_contents = params
    @memo_contents[:memo_id] = id_text
    erb :editor
  end
end

def write_memo(id_text, params)
  File.open(memo_path(id_text), 'w') do |file|
    file.puts "#{id_text}\n#{params[:title]}\n#{params[:body]}"
  end
end

def new_id
  id_text = ''
  File.open(LATEST_ID, 'r') do |file|
    id_text = id_integer_to_text(file.read.to_i + 1)
  end
  File.open(LATEST_ID, 'w') do |file|
    file.puts id_text
  end
  id_text
end

def read_titles
  # memo_titles =
  read_filenames.map do |memo_id|
    contents = read_memo_contents(memo_id)
    { memo_id: contents[:memo_id], title: contents[:title] }
  end
end

def read_memo_contents(memo_id)
  contents = {}
  File.open(memo_path(memo_id), 'r') do |file|
    lines = file.read.split("\n")
    contents = { memo_id: lines.shift, title: lines.shift, body: lines.join("\n") }
  end
  contents
end

def delete_memo(id_text)
  File.delete(memo_path(id_text))
end

def memo_url(id_text)
  "/#{STORAGE}/#{id_text}"
end

def memo_path(id_text)
  ".#{memo_url(id_text)}.txt"
end

def id_integer_to_text(id_integer)
  format("%0#{MEMO_ID_DIGIT}d", id_integer)
end

def initialize
  Dir.mkdir(STORAGE) unless Dir.exist?(STORAGE)
end

def read_filenames
  filenames = []
  Dir.glob('*.txt', base: STORAGE) do |filename|
    filenames << filename.delete('.txt')
  end
  filenames
end
