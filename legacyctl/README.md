# legacyctl

kubectl equivalent for legacy deployments

## Content
```
.               (legacyctl codebase)
├── config      (commons for configs)
├── file        (commons for file handling)
├── kubectl     (kubectl wrapper for manifest parsing)
├── legacyctl   (command line interface)
└── legacyctld  (daemon/server)
```

## Usage

In the first console start the server:
```
cd legacyctld && go build && ./legacyctld 
```

In another console run the client:
```
cd legacyctl && go build
```

Apply (start) the legacy process
```
./legacyctl -f . apply
./legacyctl -f ../../bsc-env/apps/ apply
```

Delete (stop) the legacy process
```
./legacyctl -f . delete
./legacyctl -f ../../bsc-env/apps/ delete
```