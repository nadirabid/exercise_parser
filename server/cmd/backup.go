package cmd

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"github.com/spf13/cobra"
)

type RelatedNameBackup struct {
	DictionaryName string   `json:"dictionary_name"`
	RelatedNames   []string `json:"related_names"`
}

func backupRelatedNames(cmd *cobra.Command, args []string) error {
	if err := dumpRelatedNames(cmd, args); err != nil {
		return err
	}

	v, err := configureViperFromCmd(cmd)
	if err != nil {
		return err
	}

	region := v.GetString("backup.s3.region")
	bucket := v.GetString("backup.s3.bucket")
	baseKey := v.GetString("backup.s3.related_names_key_name")
	relatedNamesSourceDir := v.GetString("resources.dir.related_names")

	sess, err := session.NewSession(
		&aws.Config{
			Region: aws.String(region),
		},
	)

	if err != nil {
		return err
	}

	uploader := s3manager.NewUploader(sess)

	files, err := ioutil.ReadDir(relatedNamesSourceDir)
	if err != nil {
		return err
	}

	for _, f := range files {
		file, err := os.Open(filepath.Join(relatedNamesSourceDir, f.Name()))
		if err != nil {
			return err
		}

		_, err = uploader.Upload(&s3manager.UploadInput{
			Bucket: aws.String(bucket),                                  // Bucket to be used
			Key:    aws.String(fmt.Sprintf("%s/%s", baseKey, f.Name())), // Name of the file to be saved
			Body:   file,                                                // File
		})

		if err != nil {
			return err
		}
	}

	return nil
}

var backupRelatedNamesCmd = &cobra.Command{
	Use:   "related_names",
	Short: "Backup related names to S3 bucket",
	RunE:  backupRelatedNames,
}

var backupCmd = &cobra.Command{
	Use:   "backup",
	Short: "Commands for backing up resources",
}

func init() {
	rootCmd.AddCommand(backupCmd)

	backupCmd.AddCommand(backupRelatedNamesCmd)
}
