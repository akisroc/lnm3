package db

import (
	"log"
	"time"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

func Connect(dsn string) *sqlx.DB {
	var db *sqlx.DB
	var err error

	for i := 0; i < 5; i++ {
		db, err = sqlx.Connect("postgres", dsn)
		if err == nil {
			return db
		}
		log.Printf("Waiting for DB... (%d/5", i+1)
		time.Sleep(4 * time.Second)
	}

	log.Fatal("Unable to connect to database:", err)
	return nil
}
