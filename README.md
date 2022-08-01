# HybridCloudOps tooling

Author: Simon Anliker

Tooling implementation for hybrid cloud deployments as outlined by the thesis.

> Note: the open sourced version has been merged together from different repositories and some references have not been updated yet. In case you come across this and really want to run the experiment yourself, let me know (e.g raise an issue) and I can help updating the references.

## Content
```
.
├── artifactory         (local artifact repository)
├── cli                 (cli to set up env required for experiments)
├── deployer            (component that runs deployments)
├── env                 (descriptors for deploying env and apps)
├── legacyctl           (component with daemon and client supporting deployments to legacy infrastructure) 
└── scripts             (scripts used to compile thesis submission content)
```
