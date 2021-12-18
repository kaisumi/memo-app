# frozen_string_literal: true

require 'sinatra'

get '/' do
  @memo_titles = read_titles
  erb :index
end

get '/new-memo' do
  erb :new_memo
end

post '/memos' do
  memo_id = ''
  id_text = ''
  File.open('./memo_latest_id.txt', 'r') do |file|
    memo_id = file.read.to_i + 1
    id_text = format_index(memo_id)
  end
  File.open('./memo_latest_id.txt', 'w') do |file|
    file.puts id_text
  end
  write_memo(memo_id, params)
  File.open('./titles.txt', 'a') do |file|
    file.puts "#{id_text}, #{params[:title]}"
  end
  redirect to('/')
end

delete %r{/memos/([0-9]{1,4})} do |memo_id|
  id_text = format_index(memo_id.to_i)
  File.delete("./memos/#{id_text}.txt")
  titles = []
  File.open('./titles.txt', 'r') do |file|
    file.read.lines do |line|
      titles << line if line.index(id_text).nil?
    end
  end
  File.open('./titles.txt', 'w') do |file|
    file.puts titles.join
  end
  redirect to('/')
end

get %r{/memos/([0-9]{1,4})} do |memo_id|
  @memo_contents = read_memo_contents(memo_id)
  erb :memo_contents
end

get %r{/editor/([0-9]{1,4})} do |memo_id|
  @memo_contents = read_memo_contents(memo_id)
  erb :editor
end

patch %r{/memos/([0-9]{1,4})} do |memo_id|
  id_text = format_index(memo_id.to_i)
  write_memo(memo_id, params)
  titles = []
  File.open('./titles.txt', 'r') do |file|
    file.read.lines do |line|
      titles << (line.index(id_text).nil? ? line : "#{id_text}, #{params[:title]}\n")
    end
  end
  File.open('./titles.txt', 'w') do |file|
    file.puts titles.join
  end
  redirect to("/memos/#{memo_id}")
end

def write_memo(memo_id, params)
  id_text = format_index(memo_id.to_i)
  File.open("./memos/#{id_text}.txt", 'w') do |file|
    file.puts "#{memo_id}\n#{params[:title]}\n#{params[:body]}"
  end
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

def read_memo_contents(memo_id)
  memo_id = format_index(memo_id.to_i)
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

def format_index(memo_id)
  format('%04d', memo_id.to_i)
end
