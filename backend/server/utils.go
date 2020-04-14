package server

import (
	"crypto/ecdsa"
	"crypto/rsa"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"errors"
	"strconv"
	"time"

	"github.com/lestrrat-go/jwx/jwa"
	"github.com/lestrrat-go/jwx/jws"
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

func parseECDSAPrivateKeyFromStr(keyBytes []byte) (*ecdsa.PrivateKey, error) {
	block, _ := pem.Decode(keyBytes)
	if block == nil {
		return nil, errors.New("failed to parse pem block containing the key")
	}

	priv, err := x509.ParsePKCS8PrivateKey(block.Bytes)
	if err != nil {
		return nil, err
	}

	return priv.(*ecdsa.PrivateKey), err
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
	t.Set(jwt.SubjectKey, "1") // TODO: this id will change based on seeding data - get a more stable ID

	return t
}

func getWithDefault(value string, defaultValue string) string {
	if value == "" {
		return defaultValue
	}

	return value
}

// we use this instead of jwt.Token.Sign because we wan't to set the Key ID (kid) in the JWT header
func signJWT(t *jwt.Token, method jwa.SignatureAlgorithm, key interface{}, keyID string) ([]byte, error) {
	buf, err := json.Marshal(t)
	if err != nil {
		return nil, err
	}

	var hdr jws.StandardHeaders
	if keyID != "" {
		hdr.Set(`kid`, keyID)
	}

	if hdr.Set(`alg`, method.String()) != nil {
		return nil, err
	}
	if hdr.Set(`typ`, `JWT`) != nil {
		return nil, err
	}
	sign, err := jws.Sign(buf, method, key, jws.WithHeaders(&hdr))
	if err != nil {
		return nil, err
	}

	return sign, nil
}
