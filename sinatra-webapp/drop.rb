# frozen_string_literal: true

require 'pg'
require_relative 'constant_parameters'
conn = PG.connect(dbname: ORIGINAL_DB_NAME)
conn.exec("DROP TABLE #{TABLE_NAME}")
conn.exec("DROP DATABASE #{DB_NAME}")
