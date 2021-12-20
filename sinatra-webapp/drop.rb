# frozen_string_literal: true

require 'pg'
conn = PG.connect(dbname: 'postgres')
conn.exec('DROP DATABASE memoapp')
conn.exec('DROP TABLE memos')
