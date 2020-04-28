package server

import (
	"crypto/ecdsa"
	"crypto/rsa"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"errors"
	"exercise_parser/models"
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
	// reason for storing it as base64 is because elasticbeanstalk is a bitch about injecting
	// variables with multilines through its environment variables
	base64key := v.GetString("auth.pem.base64_keypair")
	key, err := base64.StdEncoding.DecodeString(base64key)

	if err != nil {
		return nil, err
	}
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

func generateFakeUserJWT(fakeUser models.User) *jwt.Token {
	now := time.Unix(time.Now().Unix(), 0)

	t := jwt.New()

	// standard claims
	t.Set(jwt.AudienceKey, "ryden")
	t.Set(jwt.ExpirationKey, now.Add(time.Hour*24).Unix())
	t.Set(jwt.IssuedAtKey, now.Unix())
	t.Set(jwt.IssuerKey, "https://ryden.app")
	t.Set(jwt.SubjectKey, fmt.Sprint(fakeUser.ID))

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
	base64p8 := v.GetString("auth.apple.base64_key_p8")
	p8, err := base64.StdEncoding.DecodeString(base64p8)

	key, err := parseECDSAPrivateKeyFromStr([]byte(p8))
	if err != nil {
		return "", err
	}

	now := time.Unix(time.Now().Unix(), 0)

	t := jwt.New()

	t.Set(jwt.AudienceKey, "https://appleid.apple.com")
	t.Set(jwt.IssuedAtKey, now.Unix())
	t.Set(jwt.ExpirationKey, now.Add(time.Minute).Unix())
	t.Set(jwt.IssuerKey, v.GetString("auth.apple.team_id"))
	t.Set(jwt.SubjectKey, v.GetString("auth.apple.client_id"))

	payload, err := signJWT(t, jwa.ES256, key, v.GetString("auth.apple.key_id"))
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
