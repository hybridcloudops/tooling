package file

import (
	"log"
	"os"
)

func CreateOutputDir(outputDir string) {
	err := os.MkdirAll(outputDir, 0755)
	if err != nil {
		log.Fatalf("Error creating output dir: %v", err)
	}
}

