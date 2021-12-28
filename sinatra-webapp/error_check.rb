# frozen_string_literal: true

NO_TITLE_ERROR = '<font color="red">タイトルが空欄です</font>'

class ErrorCheck < Object
  attr_reader :message, :status

  def initialize(*args)
    if args.empty? || !args.first[:title].empty?
      @message = ''
      @status = true
    else
      @message = NO_TITLE_ERROR
      @status = false
    end
  end
end
