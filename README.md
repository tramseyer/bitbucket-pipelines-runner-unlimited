# Lifting bitbucket pipelines runner limitations
The scripts and services in this repository are intended for lifting the resource limitations imposed on self-hosted Bitbucket Pipelines Linux Docker runners.
## Details
As of 2024, Bitbucket Cloud infrastructure runners have a [configurable](https://support.atlassian.com/bitbucket-cloud/docs/step-options/#Size) CPU count and memory amount via the `size` option, whereas **self-hosted Linux Docker runners are fixed to [4 CPU's](https://jira.atlassian.com/browse/BCLOUD-21403)**:
| `size` | Bitbucket Cloud | Self-hosted | Lifted |
| - | - | - | - |
| `1x` | 4 vCPU, 4 GB | 4 CPU, 4 GB | ∞ CPU, 1 TB * |
| `2x` | 4 vCPU, 8 GB | **4** CPU, 8 GB | ∞ CPU, 1 TB * |
| `4x` | 8 vCPU, 16 GB | **4** CPU, 16 GB | ∞ CPU, 1 TB * |
| `8x` | 16 vCPU, 32 GB | **4** CPU, 32 GB | ∞ CPU, 1 TB * |

\* Limited by the capabilities of the host.
## Cost example
With 1000 Build minutes on Bitbucket Cloud infrastructure being sold for $10 and multiplied with `size`, this can lead to huge costs. Consider the following cost example assuming one runner being busy for one month runtime:
| [Hetzner Cloud](https://www.hetzner.com/cloud/) self-hosted | Bitbucket Cloud infrastructure |
| - | - |
| ~$5 (*CX22*) | **$432** (`1x`) |
| ~$10 (*CX32*) | **$864** (`2x`) |
| ~$20 (*CX42*) | **$1728** (`4x`) |
| ~$40 (*CX52*) | **$3456** (`8x`) |
# Setup
## crictl as container runtime (e. g. using [hetzner-k3s](https://github.com/vitobotta/hetzner-k3s) and [runners-autoscaler](https://bitbucket.org/bitbucketpipelines/runners-autoscaler))
`hetzner-k3s_cluster_config.yaml`
```yml
...
  post_create_commands:
  - git clone https://github.com/tramseyer/bitbucket-pipelines-runner-unlimited.git
  - cd bitbucket-pipelines-runner-unlimited
  - ./setup.sh crictl
...
```
## docker as container runtime (e. g. using a dedicated [Linux Docker runner](https://support.atlassian.com/bitbucket-cloud/docs/set-up-and-use-runners-for-linux/))
```sh
git@github.com:tramseyer/bitbucket-pipelines-runner-unlimited.git
cd bitbucket-pipelines-runner-unlimited
./setup.sh docker
```
## kubernetes (e. g. using [Docker-based runner on Kubernetes](https://support.atlassian.com/bitbucket-cloud/docs/deploying-the-docker-based-runner-on-kubernetes/) or [Autoscaler for Runners on Kubernetes](https://support.atlassian.com/bitbucket-cloud/docs/autoscaler-for-runners-on-kubernetes/))
`kustomize/base/cm-job-template.yaml` / `config/runners-autoscaler-cm-job.template.yaml`
```yml
...
                - name: runner
                  ...
                - name: docker
                  ...
                - name: docker-cpu-quota
                  image: docker:cli
                  command: ["/bin/sh", "-c", "wget -qO- https://raw.githubusercontent.com/tramseyer/bitbucket-pipelines-runner-unlimited/master/docker-cpu-quota.sh | sh"]
                  volumeMounts:
                    - name: var-run
                      mountPath: /var/run
                - name: docker-memory-limit
                  image: docker:cli
                  command: ["/bin/sh", "-c", "wget -qO- https://raw.githubusercontent.com/tramseyer/bitbucket-pipelines-runner-unlimited/master/docker-memory-limit.sh | sh"]
                  volumeMounts:
                    - name: var-run
                      mountPath: /var/run
...
```
# Monitoring of services
## on kubernetes node
```sh
systemctl status --no-pager crictl-{cpu-quota,memory-limit}
```
## on dedicated Linux Docker runner
```sh
systemctl status --no-pager docker-{cpu-quota,memory-limit}
```
# Remarks
* **NVIDIA GPUs:** If you hit `Failed to initialize NVML: Unknown Error`, see [issue #2](https://github.com/tramseyer/bitbucket-pipelines-runner-unlimited/issues/2) for causes and workarounds.

# Links
* [Bitbucket Cloud / BCLOUD-21403: Allow configuring CPU limits for runners](https://jira.atlassian.com/browse/BCLOUD-21403)
* [Bitbucket Cloud / BCLOUD-21645: Ability to use all the available memory on the host by Self hosted runners](https://jira.atlassian.com/browse/BCLOUD-21645)
* [Atlassian Community: How to use more CPU cores of host for bitbucket runner?](https://community.atlassian.com/t5/Bitbucket-Pipelines-Runners/How-to-use-more-CPU-cores-of-host-for-bitbucket-runner/qaq-p/1825300)
* [Atlassian Community: Number of CPUs available in BB pipelines](https://community.atlassian.com/t5/Bitbucket-questions/Number-of-CPUs-available-in-BB-pipelines/qaq-p/972594)
* [LinkedIn: Number of CPUs available in BB pipelines](https://www.linkedin.com/posts/logmaster_number-of-cpus-available-in-bb-pipelines-activity-7116544179366768640-qexR)
