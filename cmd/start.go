package cmd

import (
	"exercise_parser/server"

	"github.com/spf13/cobra"
)

func start(cmd *cobra.Command, args []string) error {
	v, err := configureViperFromCmd(cmd)
	if err != nil {
		return err
	}

	return server.New(v)
}

// startCmd represents the start command
var startCmd = &cobra.Command{
	Use:   "start",
	Short: "Start the server",
	RunE:  start,
}

func init() {
	rootCmd.AddCommand(startCmd)
}
