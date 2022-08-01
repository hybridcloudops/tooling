package main

import (
	"bytes"
	"flag"
	"fmt"
	"github.com/anliksim/bsc-legacyctl/config"
	"github.com/anliksim/bsc-legacyctl/kubectl"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
)

func main() {

	manifestPathPtr := flag.String("f", ".", "Path to manifest dir")
	flag.Parse()

	args := flag.Args()
	log.Printf("Args: %s", args)

	switch args[0] {
	case "apply":
		jsonString := kubectl.GetLegacyDescriptorsAsJson(*manifestPathPtr)
		// multiple Deployments are returned as part of kind List by kubectl
		if strings.Contains(jsonString, "List") {
			config.ForEachDeploymentInList([]byte(jsonString), func(payload []byte) {
				runDeployment(payload)
			})
		} else {
			runDeployment([]byte(jsonString))
		}
	case "delete":
		jsonString := kubectl.GetLegacyDescriptorsAsJson(*manifestPathPtr)
		// multiple Deployments are returned as part of kind List by kubectl
		if strings.Contains(jsonString, "List") {
			config.ForEachDeploymentInList([]byte(jsonString), func(payload []byte) {
				runStop(payload)
			})
		} else {
			runStop([]byte(jsonString))
		}
	default:
		fmt.Println("Missing argument")
	}
}

func runStop(payload []byte) {
	deployment := config.JsonToDeployment(payload)
	name := deployment.Name
	host := deployment.Spec.Template.Annotations["legacy/host"]
	deleteProcess(host, name)
}

func runDeployment(payload []byte) {
	deployment := config.JsonToDeployment(payload)
	name := deployment.Name
	host := deployment.Spec.Template.Annotations["legacy/host"]
	log.Printf("Running deployment for %s on host %s", name, host)
	postProcesses(host, payload)
}

func postProcesses(host string, payload []byte) {
	call(func() (response *http.Response, e error) {
		return http.Post(serverUrl(host, "processes"), "application/json", bytes.NewBuffer(payload))
	}, func(body []byte) {
		fmt.Printf("%s\n", body)
	})
}

func deleteProcess(host string, name string) {
	call(func() (response *http.Response, e error) {
		req, err := http.NewRequest(http.MethodDelete, serverUrl(host, fmt.Sprintf("processes/%s", name)), nil)
		if err != nil {
			log.Fatalf("Error on delete: %v", err)
		}
		return http.DefaultClient.Do(req)
	}, func(body []byte) {
		fmt.Printf("%s\n", body)
	})
}

func call(httpCall func() (*http.Response, error), callback func([]byte)) {
	resp, err := httpCall()
	if err != nil {
		log.Fatalf("Error on get: %v", err)
	}
	handle(resp, callback)
}

func handle(resp *http.Response, callback func([]byte)) {
	if resp != nil {
		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			log.Fatalf("Error parsing response: %v", err)
		}
		callback(body)
	}
}

func serverUrl(host string, path string) string {
	return fmt.Sprintf("%s/%s", host, path)
}
