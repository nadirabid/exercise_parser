package server

import (
	"crypto/ecdsa"
	"crypto/rsa"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"errors"
	"fmt"
	"strconv"
	"time"

	"github.com/lestrrat-go/jwx/jwa"
	"github.com/lestrrat-go/jwx/jws"
	"github.com/lestrrat-go/jwx/jwt"
	"github.com/spf13/viper"
)

type errorMessage struct {
	Error string
}

func newErrorMessage(m string) *errorMessage {
	return &errorMessage{
		Error: m,
	}
}

func parseRsaPrivateKeyForTokenGeneration(v *viper.Viper) (*rsa.PrivateKey, error) {
	key := v.GetString("auth.pem.keypair")

	block, _ := pem.Decode([]byte(key))
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

func generateAppleClientSecret(v *viper.Viper) (string, error) {
	p8 := v.GetString("auth.apple.key_p8")

	key, err := parseECDSAPrivateKeyFromStr([]byte(p8))
	if err != nil {
		return "", err
	}

	now := time.Unix(time.Now().Unix(), 0)

	t := jwt.New()

	t.Set(jwt.AudienceKey, "https://appleid.apple.com")
	t.Set(jwt.IssuedAtKey, now.Unix())
	t.Set(jwt.ExpirationKey, now.Add(time.Minute).Unix())
	t.Set(jwt.IssuerKey, "C3HW5VXXF5")
	t.Set(jwt.SubjectKey, "ryden.web")

	payload, err := signJWT(t, jwa.ES256, key, "PHK94N7Y9A")
	if err != nil {
		return "", err
	}

	return string(payload), nil
}

func getEmailFromJWT(t *jwt.Token) (string, error) {
	email, ok := t.Get("email")

	if !ok {
		return "", fmt.Errorf("email doesn't exist in jwt token")
	}

	return email.(string), nil
}
