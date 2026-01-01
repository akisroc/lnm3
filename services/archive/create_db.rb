#!/usr/bin/env ruby

require 'sqlite3'
require 'json'

begin

  db = SQLite3::Database.new "lnm_archive.db"
  puts "Database file created."

  db.execute_batch <<-SQL
    CREATE TABLE IF NOT EXISTS topics (
      id INTEGER PRIMARY KEY,
      title TEXT
    );
    CREATE TABLE IF NOT EXISTS posts (
      id INTEGER PRIMARY KEY,
      topic_id INTEGER,
      position INTEGER,
      author TEXT,
      content BLOB,
      created_at INTEGER
    );
  SQL

  puts "Schema created."

  db.transaction do
    Dir.glob("./data/*.json") do |file|
      data = JSON.parse(File.read(file))

      if data.is_a?(Hash)

        if data["topic"]
          data["topic"].each do |_, topic|
            db.execute <<-SQL, [topic["_id"], topic["title"]]
              INSERT INTO topics (id, title)
              VALUES (?, ?)
              ON CONFLICT(id) DO NOTHING;
            SQL
          end
        end

        if data["post"]
          data["post"].each do |_, post|
            db.execute <<-SQL, [post["_id"], post["_topic_id"], post["_position"], post["author"], post["content"], post["date"]]
              INSERT INTO posts (id, topic_id, position, author, content, created_at)
              VALUES (?, ?, ?, ?, ?, ?)
              ON CONFLICT(id) DO NOTHING;
            SQL
          end
        end

      end
    end
  end

  puts "Data inserted."

rescue Exception => e
  puts "Error: #{e}"
  puts e.backtrace

ensure
  db.close if db
end
