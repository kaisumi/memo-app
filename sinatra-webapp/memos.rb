# frozen_string_literal: true

require 'sinatra'
require 'cgi'

NO_TITLE_ERROR = '<font color="red">タイトルが空欄です</font>'
MEMO_ID_DIGIT = 10
STORAGE = 'memos'
LATEST_ID = './memo_latest_id.txt'

get '/' do
  @memo_titles = read_titles
  erb :index
end

get '/new-memo' do
  @memo_contents = { title: '', body: '' }
  erb :new_memo
end

post '/memos' do
  @title_blank = false
  if params[:title].empty?
    @title_blank = true
    @memo_contents = params
    @message = NO_TITLE_ERROR
    erb :new_memo
  else
    @message = ''
    id_text = new_id
    write_memo(id_text, params)
    redirect to('/')
  end
end

delete %r{/memos/([0-9]{10})} do |id_text|
  delete_memo(id_text)
  redirect to('/')
end

get %r{/memos/([0-9]{10})} do |id_text|
  @memo_contents = read_memo_contents(id_text)
  erb :memo_contents
end

get %r{/memos/([0-9]{10})/editor} do |id_text|
  @memo_contents = read_memo_contents(id_text)
  erb :editor
end

patch %r{/memos/([0-9]{10})} do |id_text|
  @title_blank = false
  if params[:title].empty?
    @title_blank = true
    @memo_contents = params
    @memo_contents[:memo_id] = id_text
    @message = NO_TITLE_ERROR
    erb :editor
  else
    @message = ''
    write_memo(id_text, params)
    redirect to("/#{STORAGE}/#{id_text}")
  end
end

def write_memo(id_text, params)
  Dir.mkdir(STORAGE) unless Dir.exist?(STORAGE)
  File.open("./#{STORAGE}/#{id_text}.txt", 'w') do |file|
    file.puts "#{id_text}\n#{params[:title]}\n#{params[:body]}"
  end
end

def new_id
  id_text = ''
  File.open(LATEST_ID, 'r') do |file|
    id_text = format("%0#{MEMO_ID_DIGIT}d", file.read.to_i + 1)
  end
  File.open(LATEST_ID, 'w') do |file|
    file.puts id_text
  end
  id_text
end

def read_titles
  id_text = ''
  memo_titles = []
  File.open(LATEST_ID, 'r') do |file|
    id_text = file.read.delete("\n")
  end
  unless id_text.to_i.zero?
    1.upto(id_text.to_i) do |id_integer|
      memo_id = format("%0#{MEMO_ID_DIGIT}d", id_integer)
      filename = "./#{STORAGE}/#{memo_id}.txt"
      if File.exist?(filename)
        contents = read_memo_contents(memo_id)
        memo_titles << { memo_id: contents[:memo_id], title: contents[:title] }
      end
    end
  end
  memo_titles
end

def read_memo_contents(memo_id)
  contents = {}
  filename = "./#{STORAGE}/#{memo_id}.txt"
  File.open(filename, 'r') do |file|
    body = ''
    file.read.split("\n").each_with_index do |content, i|
      case i
      when 0 then contents.store(:memo_id, content)
      when 1 then contents.store(:title, content)
      else
        body += "#{content}\n"
      end
      contents.store(:body, body)
    end
  end
  contents
end

def delete_memo(id_text)
  File.delete("./#{STORAGE}/#{id_text}.txt")
end
