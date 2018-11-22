package cmd

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

func configureViperFromCmd(cmd *cobra.Command) (*viper.Viper, error) {
	confFile, err := cmd.Flags().GetString("conf")
	if err != nil {
		return nil, err
	}

	v := viper.New()
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
