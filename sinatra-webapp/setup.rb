# frozen_string_literal: true

require 'pg'

# brew services start postgresql

# brew services stop postgresql (終了時)

conn = PG.connect(dbname: 'postgres')
conn.exec('CREATE DATABASE memoapp')
conn.exec('CREATE TABLE memos (memo_id SERIAL NOT NULL, title text, memo text, PRIMARY KEY (memo_id)) ')
