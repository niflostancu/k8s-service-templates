# Kubernetes Scripts & Templates library

This repository contains my personal Kubernetes (k8s) scripts & Kustomize
templates for easing the installation and maintenance of self-hosted services.
It also demonstrates some (hopefully) good practices for maintaining a k8s
cluster's configuration management repository.

Overall features:

- [Kustomize](https://kustomize.io/)-based templates for various self-hosted
  services (for a personal cloud setting);
- [GNU Make](https://www.gnu.org/software/make/) scripts for easily installing
  / updating k8s-hosted applications;
- Utility scripts for checking & downloading the versions of containerized
  applications (e.g., from Github);
- Overall, a (opinionated) system for better organizing one's Kubernetes
  resources.
- Everything is well documented and designed to be fully customizable
  / extendable (via Makefile inheritance + kustomize overlays)!

## Requirements

- [`make`](https://www.gnu.org/software/make/),
  [`bash`](https://www.gnu.org/software/bash/), various core utilities;
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/) tool, of course!
- [`helm`](https://helm.sh/) (optional, only if you plan to use it with `kustomize`);
- [Docker](https://docker.com/) (optional, for building any custom images ofc :P)

This project assumes intermediate Kubernetes experience (+ make & bash).

## Usage

To get started, try out some of the bundled make scripts:

```sh
make services/cert-manager show
# looking good? apply it!
make services/cert-manager apply
```

There are two ways in which you could integrate the templates into your
workflow:

1. Forking / modifying in-place (faster but NOT recommended)

  If you wish to simply manage Kubernetes services with minimal configuration
  differences from the defaults, choose this options.

  **Hint:** only add configuration lines to the Makefile scripts for
  straightforward conflict merging!

  ```sh
  git clone https://github.com/niflostancu/k8s-service-templates.git
  # recommended: create your own branch
  git checkout -b personal
  # don't forget to rebase periodically (& solve conflicts)
  git rebase master
  # if you get bored of doing this, check variant #2 below ;)
  ```

  After cloning, simply edit the desired files (don't forget to create
  `config.local.mk`) and install your desired services.

  Check available services:
  ```sh
  ls -l services/
  ```

2. Using as library / submodule

  If you want to have better configurability / flexibility for your cluster
  services and you wish to also remain in sync with [this] base repository,
  using it as submodule in a new project is your best choice:
  
  ```sh
  # create your new project's repo
  mkdir my-k8s-services/ && cd my-k8s-services/
  git init
  git submodule add https://github.com/niflostancu/k8s-service-templates.git base/
  cp -f base/Makefile base/config.defaults.mk ./
  ```

  Initialize / configure your services:
  ```sh
  # check the base dir for the available services:
  ls -l base/services/
  # for each service you wish to include in your repo:
  mkdir -p "services/<service-name>"
  echo 'include $(base_dir)/services/<service-name>/rules.mk' > "services/<service-name>/rules.mk"
  ```

