# frozen_string_literal: true

MEMO_ID_DIGIT = 10
ORIGINAL_DB_NAME = 'postgres'
DB_NAME = 'memoapp'
TABLE_NAME = 'memos'
ID_COL = 'memo_id'
TITLE_COL = 'title'
BODY_COL = 'body'
MEMO_ID = "to_char(#{ID_COL}, 'FM0000000000')"
