package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type BattleRequest struct {
	Notation string `json:"notation" binding:"required"`
}

func main() {
	router := gin.Default()

	router.POST("/battles/solve", func(c *gin.Context) {
		var input BattleRequest

		if err := c.ShouldBindJSON(&input); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
	})

	router.Run(":8000")
}
