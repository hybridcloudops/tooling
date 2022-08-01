package main

import (
	"fmt"
	"github.com/anliksim/bsc-legacyctl/config"
	"github.com/anliksim/bsc-legacyctl/file"
	"github.com/gorilla/mux"
	"github.com/justinas/alice"
	"io"
	"io/ioutil"
	appsv1 "k8s.io/api/apps/v1"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"time"
)

var processes = make(map[string]LegacyProcess)

type LegacyProcess struct {
	Pid     string
	Version string
}

func (e LegacyProcess) String() string {
	return fmt.Sprintf("{pid: %s, version: %s}", e.Pid, e.Version)
}

func main() {
	errorChain := alice.New(loggerHandler, recoverHandler)
	r := mux.NewRouter()
	http.Handle("/", errorChain.Then(r))
	r.HandleFunc("/", handleMain)
	r.HandleFunc("/health", handleHealth)
	r.HandleFunc("/processes", handleProcesses).Methods("GET")
	r.HandleFunc("/processes", handleStart).Methods("POST")
	r.HandleFunc("/processes/{name}", handleProcess).Methods("GET")
	r.HandleFunc("/processes/{name}", handleStop).Methods("DELETE")
	r.HandleFunc("/pids", handlePids)
	r.HandleFunc("/pids/{pid}", handlePid).Methods("GET")
	r.HandleFunc("/pids/{pid}", handlePKill).Methods("DELETE")
	log.Printf("Starting server at localhost:3556")
	if err := http.ListenAndServe(":3556", nil); err != nil {
		log.Fatalf("Error starting legacyctld: %v", err)
	}
}

func handleMain(w http.ResponseWriter, r *http.Request) {
	if _, err := io.WriteString(w, "legacyctld running"); err != nil {
		log.Fatalf("Error on /: %v", err)
	}
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	if _, err := io.WriteString(w, "ok"); err != nil {
		log.Fatalf("Error on /: %v", err)
	}
}

func handleProcesses(w http.ResponseWriter, r *http.Request) {
	log.Print("Requesting running processes")
	if _, err := io.WriteString(w, processesToString(processes)); err != nil {
		log.Fatalf("Error on processes: %v", err)
	}
}

func handleProcess(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	name := vars["name"]
	log.Printf("Request for process %s", name)
	info := map[string]string{
		"name":    name,
		"pid":     processes[name].Pid,
		"version": processes[name].Version,
	}
	if _, err := io.WriteString(w, mapToString(info)); err != nil {
		log.Fatalf("Error on processes: %v", err)
	}
}

func handleStart(w http.ResponseWriter, r *http.Request) {
	log.Printf("Request for new process")
	//runProcess()
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Fatalf("Error reading body: %v", err)
	}
	deployment := config.JsonToDeployment(body)
	name := deployment.Name
	version := deployment.Spec.Template.Annotations["legacy/v"]

	lproc, ok := processes[name]
	if ok {
		log.Printf("Current proccess for %s: %s", name, lproc)
		if strings.EqualFold(version, lproc.Version) {
			if _, err := io.WriteString(w, name+" unchanged"); err != nil {
				log.Fatalf("Error rendering: %v", err)
			}
			return
		} else {
			stopProcess(name)
		}
	}

	log.Printf("Starting new process for %s", name)
	pid := strconv.Itoa(runProcess(deployment))
	processes[name] = LegacyProcess{
		Pid:     pid,
		Version: version,
	}
	if _, err := io.WriteString(w, name+" configured"); err != nil {
		log.Fatalf("Error rendering pids: %v", err)
	}
}

func handleStop(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	name := vars["name"]
	stopProcess(name)
	if _, err := io.WriteString(w, name+" stopped"); err != nil {
		log.Fatalf("Error rendering: %v", err)
	}
}

func stopProcess(name string) {
	pid := processes[name].Pid
	if pid != "" {
		log.Printf("Stopping process %s with PID %s", name, pid)
		killWithDescendants(pid)
		delete(processes, name)
	} else {
		log.Printf("Proccess with name %s does not exist", name)
	}
}

func handlePids(w http.ResponseWriter, r *http.Request) {
	log.Print("Start attempt")
	if _, err := io.WriteString(w, mapValues(processes)); err != nil {
		log.Fatalf("Error rendering pids: %v", err)
	}
}

func handlePid(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	pid := vars["pid"]
	log.Printf("Request for process %s", pid)
	name := "none"
	for key, value := range processes {
		if strings.EqualFold(value.Pid, pid) {
			name = key
		}
	}
	if _, err := io.WriteString(w, name); err != nil {
		log.Fatalf("Error rendering: %v", err)
	}
}

func handlePKill(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	pid := vars["pid"]
	log.Printf("Request to terminate process %s", pid)
	killWithDescendants(pid)
	log.Printf("Process %s terminated", pid)
}

func loggerHandler(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf(">> %s %s", r.Method, r.URL.Path)
		start := time.Now()
		h.ServeHTTP(w, r)
		log.Printf("<< %s %s %v", r.Method, r.URL.Path, time.Since(start))
	})
}

func recoverHandler(next http.Handler) http.Handler {
	fn := func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if err := recover(); err != nil {
				log.Printf("panic: %+v", err)
				http.Error(w, http.StatusText(500), 500)
			}
		}()
		next.ServeHTTP(w, r)
	}
	return http.HandlerFunc(fn)
}

const outputDir = "out"

func killWithDescendants(parentPid string) {
	cmd := exec.Command("pkill", "-P", parentPid)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		log.Fatalf("Error killing process: %v", err)
	}
}

func runProcess(deployment *appsv1.Deployment) int {

	log.Printf("Labels: %s", deployment.ObjectMeta.Labels)
	log.Printf("Annotations: %s", deployment.Spec.Template.Annotations)

	imageRegistry := deployment.Spec.Template.Annotations["imageregistry"]
	imageType := deployment.Spec.Template.Annotations["legacy/type"]
	log.Printf("Using registry: %s", imageRegistry)
	image := deployment.Spec.Template.Spec.Containers[0].Image

	file.CreateOutputDir(outputDir)

	imageName := strings.Replace(image, ":", "-", 1)
	imageUrl := imageName + "." + imageType
	loadUrl := imageRegistry + "/" + imageUrl
	outUrl := outputDir + "/" + imageUrl
	log.Printf("Loading from %s to %s", loadUrl, outUrl)
	if err := file.DownloadFile(outUrl, loadUrl); err != nil {
		log.Fatalf("Error downloading artifact: %v", err)
	}

	binaryDir := outputDir + "/" + imageName
	if err := file.Unzip(outUrl, binaryDir); err != nil {
		log.Fatalf("Error extracting artifact: %v", err)
	}

	cmd := exec.Command("/bin/sh", binaryDir+"/run.sh", binaryDir)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Start(); err != nil {
		log.Fatalf("Error starting process: %v", err)
	}
	process := cmd.Process
	pid := process.Pid
	log.Printf("Started process with PID: %d", pid)
	return pid
}

func processesToString(m map[string]LegacyProcess) string {
	var str strings.Builder
	dl := "="
	for key, value := range m {
		str.WriteString(key)
		str.WriteString(dl)
		str.WriteString(value.String())
		str.WriteRune('\n')
	}
	return str.String()
}

func mapToString(m map[string]string) string {
	var str strings.Builder
	dl := "="
	for key, value := range m {
		str.WriteString(key)
		str.WriteString(dl)
		str.WriteString(value)
		str.WriteRune('\n')
	}
	return str.String()
}

func mapValues(m map[string]LegacyProcess) string {
	var str strings.Builder
	for _, value := range m {
		str.WriteString(value.String())
		str.WriteRune('\n')
	}
	return str.String()
}
