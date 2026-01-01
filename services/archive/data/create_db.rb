#!/usr/bin/env ruby

require 'sqlite3'
require 'json'
require 'digest'

begin

  db = SQLite3::Database.new "lnm_archive.db"
  puts "Database file created."

  db.execute_batch <<-SQL
    CREATE TABLE IF NOT EXISTS topics (
      id TEXT PRIMARY KEY,
      title TEXT
    );
    CREATE TABLE IF NOT EXISTS posts (
      id TEXT PRIMARY KEY,
      topic_id INTEGER,
      place TEXT,
      position INTEGER,
      author TEXT,
      content BLOB,
      created_at INTEGER
    );
  SQL

  puts "Schema created."

  db.transaction do
    Dir.glob("./*.json") do |file|
      data = JSON.parse(File.read(file))

      if File.basename(file) == "lenouveaumonde_print.json"
        data.each do |place|
          place["posts"].each do |post|
            db.execute <<-SQL, [Digest::MD5.hexdigest(post["content"]), place["place"], post["_position"], post["author"], post["content"], post["date"]]
              INSERT INTO posts (id, place, position, author, content, created_at)
              VALUES (?, ?, ?, ?, ?, ?)
              ON CONFLICT(id) DO NOTHING
            SQL
          end
        end
      else
        if data.is_a?(Hash)

          if data["topic"]
            data["topic"].each do |_, topic|
              db.execute <<-SQL, [topic["_id"].to_s, topic["title"]]
                INSERT INTO topics (id, title)
                VALUES (?, ?)
                ON CONFLICT(id) DO NOTHING;
              SQL
            end
          end

          if data["post"]
            data["post"].each do |_, post|
              db.execute <<-SQL, [post["_id"].to_s, post["_topic_id"].to_s, post["_position"], post["author"], post["content"], post["date"]]
                INSERT INTO posts (id, topic_id, position, author, content, created_at)
                VALUES (?, ?, ?, ?, ?, ?)
                ON CONFLICT(id) DO NOTHING;
              SQL
            end
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
