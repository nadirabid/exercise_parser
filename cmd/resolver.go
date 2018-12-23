package cmd

import (
	"errors"
	"exercise_parser/models"
	"exercise_parser/server"
	"exercise_parser/utils"
	"strings"

	"github.com/spf13/cobra"
)

func resolve(cmd *cobra.Command, args []string) error {
	if len(args) == 0 {
		return errors.New("must specify at least one word argument")
	}

	v, err := configureViperFromCmd(cmd)
	if err != nil {
		return err
	}

	db, err := models.NewDatabase(v)
	if err != nil {
		return err
	}

	results, err := server.ResolveHelper(db, strings.Join(args, " "))
	if err != nil {
		return err
	}

	limit, err := cmd.Flags().GetInt("limit")
	if err != nil {
		return nil
	}

	for i, r := range results {
		if limit != 0 && i >= limit {
			break
		}

		utils.PrettyPrint(r)
	}

	return nil
}

var resolveCmd = &cobra.Command{
	Use:   "resolve",
	Short: "show closest matches",
	RunE:  resolve,
}

func init() {
	rootCmd.AddCommand(resolveCmd)

	resolveCmd.Flags().Int("limit", 0, "max number of results to show. displayed in descending order.")
}
