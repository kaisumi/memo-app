# frozen_string_literal: true

require 'sinatra'
require 'cgi'

get '/' do
  @memo_titles = read_titles
  erb :index
end

get '/new-memo' do
  erb :new_memo
end

post '/memos' do
  id_text = new_id
  write_memo(id_text, params)
  write_titles(id_text, params)
  redirect to('/')
end

delete %r{/memos/([0-9]{4})} do |id_text|
  delete_memo(id_text)
  delete_title(id_text)
  redirect to('/')
end

get %r{/memos/([0-9]{4})} do |id_text|
  @memo_contents = read_memo_contents(id_text)
  erb :memo_contents
end

get %r{/editor/([0-9]{4})} do |id_text|
  @memo_contents = read_memo_contents(id_text)
  erb :editor
end

patch %r{/memos/([0-9]{4})} do |id_text|
  write_memo(id_text, params)
  update_title(id_text, params)
  redirect to("/memos/#{id_text}")
end

def write_memo(id_text, params)
  File.open("./memos/#{id_text}.txt", 'w') do |file|
    file.puts "#{id_text}\n#{CGI.escapeHTML(params[:title])}\n#{CGI.escapeHTML(params[:body])}"
  end
end

def new_id
  id_text = ''
  File.open('./memo_latest_id.txt', 'r') do |file|
    id_text = format('%04d', file.read.to_i + 1)
  end
  File.open('./memo_latest_id.txt', 'w') do |file|
    file.puts id_text
  end
  id_text
end

def read_titles
  memos = []
  contents = {}
  File.open('./titles.txt', 'r') do |file|
    file.read.split("\n").each do |memo|
      next if memo.empty?

      memo.split(', ').each_with_index do |content, i|
        case i
        when 0 then contents.store(:memo_id, content)
        when 1 then contents.store(:title, content)
        end
      end
      memos << contents
      contents = {}
    end
  end
  memos
end

def write_titles(id_text, params)
  File.open('./titles.txt', 'a') do |file|
    file.puts "#{id_text}, #{params[:title]}"
  end
end

def read_memo_contents(memo_id)
  contents = {}
  File.open("./memos/#{memo_id}.txt", 'r') do |file|
    body = ''
    file.read.split("\n").each_with_index do |content, i|
      case i
      when 0 then contents.store(:index, content)
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
  File.delete("./memos/#{id_text}.txt")
end

def delete_title(id_text)
  titles = []
  File.open('./titles.txt', 'r') do |file|
    file.read.lines do |line|
      titles << line if line.index(id_text).nil?
    end
  end
  File.open('./titles.txt', 'w') do |file|
    file.puts titles.join
  end
end

def update_title(id_text, params)
  titles = []
  File.open('./titles.txt', 'r') do |file|
    file.read.lines do |line|
      titles << (line.index(id_text).nil? ? line : "#{id_text}, #{CGI.escapeHTML(params[:title])}\n")
    end
  end
  File.open('./titles.txt', 'w') do |file|
    file.puts titles.join
  end
end
