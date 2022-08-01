# Artifactory

Simple local artifact registry for testing purposes. The artifactory is used to server binaries of legacy applications.

## Content
```
.               (artifact repository codebase)
└── repository  (binaries to serve)
```

## Prerequisite

Requires python version >= 3

Use `which python3` to check for availability
```
$ which python3
/usr/bin/python3
```

## Usage

Serve artifacts in `repository` on `http://localhost:3555/`
```
./artifactory.sh start
```
Stop the server
```
./artifactory.sh stop
```

### Set port

Run the server on a different port
```
./artifactory.sh start 3001
```

Requires to also provide the port on stop
```
./artifactory.sh stop 3001
```
