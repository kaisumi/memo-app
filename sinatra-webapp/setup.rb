# frozen_string_literal: true

require 'pg'
require_relative 'constant_parameters'

# brew services start postgresql

# brew services stop postgresql (終了時)

conn_original = PG.connect(dbname: ORIGINAL_DB_NAME)
conn_original.exec("CREATE DATABASE #{DB_NAME}")
conn = PG.connect(dbname: DB_NAME)
conn.exec("CREATE TABLE #{TABLE_NAME} (#{ID_COL} SERIAL NOT NULL, #{TITLE_COL} text, #{BODY_COL} text, PRIMARY KEY (#{ID_COL})) ")
