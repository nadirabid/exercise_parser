package server

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	language "cloud.google.com/go/language/apiv1"
	"github.com/disiqueira/gotree"
	languagepb "google.golang.org/genproto/googleapis/cloud/language/v1"
)

type errorMessage struct {
	Error string
}

func newErrorMessage(m string) *errorMessage {
	return &errorMessage{
		Error: m,
	}
}

func prettyPrint(v interface{}) (err error) {
	b, err := json.MarshalIndent(v, "", "  ")
	if err != nil {
		fmt.Printf("prettyPrint: %v\n", err)
	}

	fmt.Println(string(b))

	return
}

func treePrint(tokens []*languagepb.Token) {
	var root gotree.Tree
	nodes := make([]gotree.Tree, len(tokens), len(tokens))
	hasDependencies := make([]bool, len(tokens), len(tokens))

	for i, t := range tokens {
		nodes[i] = gotree.New(t.Lemma)
	}

	for i, t := range tokens {
		if t.DependencyEdge.GetHeadTokenIndex() != int32(i) {
			nodes[t.DependencyEdge.HeadTokenIndex].AddTree(nodes[i])
			hasDependencies[i] = true
		} else {
			root = nodes[i]
		}
	}

	fmt.Println(root.Print())
}

// https://cloud.google.com/natural-language/#nl_demo_section
// https://cloud.google.com/natural-language/docs/reference/rest/v1/Token

func analyzeSyntax(text string) (*languagepb.AnnotateTextResponse, error) {
	ctx := context.Background()
	client, err := language.NewClient(ctx)
	if err != nil {
		log.Fatal(err)
	}

	return client.AnnotateText(ctx, &languagepb.AnnotateTextRequest{
		Document: &languagepb.Document{
			Source: &languagepb.Document_Content{
				Content: text,
			},
			Type: languagepb.Document_PLAIN_TEXT,
		},
		Features: &languagepb.AnnotateTextRequest_Features{
			ExtractSyntax: true,
		},
		EncodingType: languagepb.EncodingType_UTF8,
	})
}
