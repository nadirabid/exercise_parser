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

	payload, err := t.Sign(jwa.RS256, key)

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
