package cmd

import (
	"fmt"
	"os"

	"github.com/fatih/color"
	"github.com/spf13/cobra"
)

var warner = color.New(color.FgYellow)
var errer = color.New(color.FgRed)
var successer = color.New(color.FgGreen)

// rootCmd represents the root command
var rootCmd = &cobra.Command{
	Use: "root",
}

func init() {
	rootCmd.PersistentFlags().String("conf", "conf/dev.toml", "The conf file name to use.")
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
