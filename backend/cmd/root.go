package cmd

import (
	"bytes"
	"exercise_parser/server"
	"fmt"
	"io/ioutil"
	"os"
	"time"

	"github.com/lestrrat-go/jwx/jwa"
	"github.com/lestrrat-go/jwx/jwt"
	"github.com/spf13/cobra"
)

// rootCmd represents the root command
var rootCmd = &cobra.Command{
	Use: "root",
}

func keyTest(cmd *cobra.Command, args []string) error {
	v, err := configureViperFromCmd(cmd)
	if err != nil {
		return err
	}

	// create token
	now := time.Unix(time.Now().Unix(), 0)
	t := jwt.New()
	t.Set(jwt.AudienceKey, "ryden")
	t.Set(jwt.ExpirationKey, now.Add(7*24*time.Hour).Unix()) // a goddamn week
	t.Set(jwt.IssuedAtKey, now.Unix())
	t.Set(jwt.IssuerKey, "https://ryden.app")

	file := v.GetString("auth.file")
	fileBytes, err := ioutil.ReadFile(file)
	if err != nil {
		panic(fmt.Sprintf("Failed to open pem keypair file: %s", file))
	}

	key, err := server.ParseRsaPrivateKeyFromPemStr(string(fileBytes))

	// payload, err := t.Sign(jwa.RS256, key)
	payload := []byte("eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsicnlkZW4iXSwiZXhwIjoxNTg0OTI1NjY5LCJpYXQiOjE1ODQzMjA4NjksImlzcyI6Imh0dHBzOi8vcnlkZW4uYXBwIn0.IhGDrm26pBsC6TOh9eo0QSo22VvakTCbBB9CayqnhlAj6NQrjpFKtNtcvtW_OlJoxqSPSKchZt4lTVt2evXWje2OkllCxepgIcW6GMCUC_C0qD-9jIXeUSwFQtB4eiRDbtrfKLFZiBMpknfm0ePXKUBxlAk5x8cG4ItRFTSf6VgsLTuhgvXXeyPGbeU0Tlzeu1TKW7j8BxItQIIrvDCOLoWe4_xfHiKhLfY8inRy1O8uKbYeHDwVgAEkzE9aVkhtb-B6ZYhdCHdiT0PIs6iz5FQONG1Lxt_Z4SgbeMpfMwHwUwOihPt_qcGwyj9gZmMpUwJUrh-BnKQQdfPRnLyrcQ")

	_, err = jwt.Parse(
		bytes.NewReader(payload),
		jwt.WithVerify(jwa.RS256, &key.PublicKey),
	)

	if err != nil {
		return err
	}

	// verify token

	return nil
}

var testCmd = &cobra.Command{
	Use:  "key_test",
	RunE: keyTest,
}

func init() {
	rootCmd.PersistentFlags().String("conf", "dev", "The conf file name to use.")
	rootCmd.AddCommand(testCmd)
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
