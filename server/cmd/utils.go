package cmd

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

func configureViperFromCmd(cmd *cobra.Command) (*viper.Viper, error) {
	confFile, err := cmd.Flags().GetString("conf")
	if err != nil {
		return nil, err
	}

	v := viper.New()

	v.BindEnv("psql.user", "RDS_USERNAME")
	v.BindEnv("psql.password", "RDS_PASSWORD")
	v.BindEnv("psql.name", "RDS_DB_NAME")
	v.BindEnv("psql.host", "RDS_HOSTNAME")
	v.BindEnv("psql.port", "RDS_PORT")
	v.BindEnv("psql.ssl_mode", "RDS_SSL_MODE")

	// TODO: calvin trick
	v.BindEnv("psql.max_connections", "RDS_MAX_CONNECTIONS")
	v.BindEnv("psql.max_idle_connections", "RDS_MAX_IDLE_CONNECTIONS")
	v.BindEnv("psql.max_connection_lifetime", "RDS_MAX_CONNECTION_LIFETIME")

	v.BindEnv("auth.pem_file_path", "AUTH_PEM_FILE_PATH")

	v.SetConfigType("toml")
	v.SetConfigFile(fmt.Sprintf("conf/%s.toml", confFile))

	if err := v.ReadInConfig(); err != nil {
		return nil, err
	}

	return v, nil
}

func pathToFileURL(path string) string {
	if !filepath.IsAbs(path) {
		var err error
		path, err = filepath.Abs(path)
		if err != nil {
			return ""
		}
	}
	return fmt.Sprintf("file://%s", filepath.ToSlash(path))
}

func isDirectory(name string) (bool, error) {
	info, err := os.Stat(name)
	if err != nil {
		return false, err
	}

	return info.IsDir(), nil
}

func sanitizeRelatedName(s string) string {
	s = strings.ToLower(s)
	s = strings.Replace(s, "-", " ", -1)
	s = strings.Trim(s, " ")
	return s
}

func removeStopWords(s string, stopWords []string) string {
	result := []string{""}
	tokens := strings.Split(s, " ")

	for _, t := range tokens {
		isStopWord := false
		for _, w := range stopWords {
			if t == w {
				isStopWord = true
				break
			}
		}

		if !isStopWord {
			result = append(result, t)
		}
	}

	return strings.Join(result, " ")
}
