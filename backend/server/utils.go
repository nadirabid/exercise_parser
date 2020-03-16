package server

import (
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"errors"
)

type errorMessage struct {
	Error string
}

func newErrorMessage(m string) *errorMessage {
	return &errorMessage{
		Error: m,
	}
}

func ParseRsaPrivateKeyFromPemStr(privPEM string) (*rsa.PrivateKey, error) {
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
