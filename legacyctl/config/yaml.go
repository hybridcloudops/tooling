package config

import (
	"encoding/json"
	"gopkg.in/yaml.v2"
	"io/ioutil"
	appsv1 "k8s.io/api/apps/v1"
	v1 "k8s.io/api/core/v1"
	"log"
)

func UnmarshalString(yamlString string) *appsv1.Deployment {
	return Unmarshal([]byte(yamlString))
}

func UnmarshalFile(filePath string) *appsv1.Deployment {
	content, err := ioutil.ReadFile(filePath)
	if err != nil {
		log.Fatal(err)
	}
	return Unmarshal(content)
}

func UnmarshalFileJson(filePath string) []byte {
	content, err := ioutil.ReadFile(filePath)
	if err != nil {
		log.Fatal(err)
	}
	return ToJson(content)
}

func ToJson(yamlContent []byte) []byte {
	var body interface{}
	if err := yaml.Unmarshal(yamlContent, &body); err != nil {
		log.Fatalf("Error dencoding yaml: %v", err)
	}

	bytes, err := json.Marshal(convert(body))
	if err != nil {
		log.Fatalf("Error encoding json: %v", err)
	}
	return bytes
}

func Unmarshal(yamlContent []byte) *appsv1.Deployment {
	deployment := new(appsv1.Deployment)
	if err := json.Unmarshal(ToJson(yamlContent), &deployment); err != nil {
		log.Fatal(err)
	}
	return deployment
}

func JsonToDeployment(jsonContent []byte) *appsv1.Deployment {
	deployment := new(appsv1.Deployment)
	if err := json.Unmarshal(jsonContent, &deployment); err != nil {
		log.Fatalf("Error during unmarshal: %v", err)
	}
	return deployment
}

func JsonToDeployments(jsonContent []byte) {
	list := new(v1.List)
	if err := json.Unmarshal(jsonContent, &list); err != nil {
		log.Fatalf("Error during unmarshal: %v", err)
	}
	for _, c := range list.Items {
		deployment := JsonToDeployment(c.Raw)
		log.Println(deployment)
	}
}

func ForEachDeploymentInList(jsonContent []byte, deploymentHandler func([]byte)) {
	list := new(v1.List)
	if err := json.Unmarshal(jsonContent, &list); err != nil {
		log.Fatalf("Error during unmarshal: %v", err)
	}
	for _, c := range list.Items {
		deploymentHandler(c.Raw)
	}
}

// converts yaml to json
// see https://stackoverflow.com/questions/40737122/convert-yaml-to-json-without-struct
func convert(i interface{}) interface{} {
	switch x := i.(type) {
	case map[interface{}]interface{}:
		m2 := map[string]interface{}{}
		for k, v := range x {
			m2[k.(string)] = convert(v)
		}
		return m2
	case []interface{}:
		for i, v := range x {
			x[i] = convert(v)
		}
	}
	return i
}
