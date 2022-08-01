package config

import (
	"github.com/stretchr/testify/assert"
	"log"
	"testing"
)

const testFile = "test_config.yaml"

func TestUnmarshal_ContainsRepos(t *testing.T) {
	deployment := UnmarshalFile(testFile)
	log.Printf("%v\n", deployment)
	assert.Equal(t, "Deployment", deployment.Kind)

	// custom labels
	labels := deployment.ObjectMeta.Labels
	assert.Contains(t, labels, "legacy")
	assert.Contains(t, labels, "cloud-public")
	assert.Contains(t, labels, "cloud-private")

	// custom annotations
	annotations := deployment.Spec.Template.Annotations
	assert.Contains(t, annotations, "legacy/hosts")
	assert.Contains(t, annotations, "legacy/type")
}

func ExampleConfiguration() {
	deployment := UnmarshalFile(testFile)
	log.Printf("%v\n", deployment)
}
