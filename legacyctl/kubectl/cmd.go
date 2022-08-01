package kubectl

import (
	"bytes"
	"log"
	"os/exec"
	"strings"
)

// runs kubectl apply in dry run for legacy apps to get
// the json representation of all the descriptors
func GetLegacyDescriptorsAsJson(path string) string {
	return kubectl("apply", "-f", path, "-R", "-l", "cloud-legacy=supported", "-o", "json", "--dry-run=true")
}

func kubectl(arg ...string) string {
	cmd := exec.Command("kubectl", arg...)
	var outb, errb bytes.Buffer
	cmd.Stdout = &outb
	cmd.Stderr = &errb
	if err := cmd.Run(); err != nil {
		log.Fatalf("Error starting process: %v\n Stderr: %s", err, errb.String())
	}
	return strings.Trim(outb.String(), "\n")
}
