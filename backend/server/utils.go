package server

import (
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"errors"
	"strconv"
	"time"

	"github.com/lestrrat-go/jwx/jwt"
)

type errorMessage struct {
	Error string
}

func newErrorMessage(m string) *errorMessage {
	return &errorMessage{
		Error: m,
	}
}

func parseRsaPrivateKeyFromPemStr(privPEM string) (*rsa.PrivateKey, error) {
	block, _ := pem.Decode([]byte(privPEM))
	if block == nil {
		return nil, errors.New("failed to parse PEM block containing the key")
	}

	priv, err := x509.ParsePKCS1PrivateKey(block.Bytes)
	if err != nil {
		return nil, err
	}

	return priv, nil
}

func getUserIDFromContext(ctx *Context) uint {
	sub, ok := ctx.jwt.Get(jwt.SubjectKey)
	if !ok {
		panic("SubjectKey of jwt must exist!")
	}

	userID, err := strconv.ParseUint(sub.(string), 10, 32)
	if err != nil {
		panic("Couldn't parse userId as uint!")
	}

	return uint(userID)
}

func generateFakeUserJWT() *jwt.Token {
	now := time.Unix(time.Now().Unix(), 0)

	t := jwt.New()

	// standard claims
	t.Set(jwt.AudienceKey, "ryden")
	t.Set(jwt.ExpirationKey, now.Add(time.Hour*24).Unix())
	t.Set(jwt.IssuedAtKey, now.Unix())
	t.Set(jwt.IssuerKey, "https://ryden.app")
	t.Set(jwt.SubjectKey, "test.user")

	return t
}

func getWithDefault(value string, defaultValue string) string {
	if value == "" {
		return defaultValue
	}

	return value
}
