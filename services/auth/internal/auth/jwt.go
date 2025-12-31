package auth

import (
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

var secretKey = []byte(os.Getenv("SECRET_KEY"))

type Claims struct {
	UserId string `json:"userId"`
	Email  string `json:"email"`
	jwt.RegisteredClaims
}

func GenerateToken(userId string, email string) (string, error) {
	claims := &Claims{
		UserId: userId,
		Email:  email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(secretKey)
}
