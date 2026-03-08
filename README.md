# DevOps Intern Final Assessment

[![CI](https://github.com/ssgamingop/devops-intern-final/actions/workflows/ci.yml/badge.svg)](https://github.com/ssgamingop/devops-intern-final/actions/workflows/ci.yml)

Name: Somyajeet  
Date: March 8, 2026

This repository builds a small end-to-end DevOps workflow using Git, Linux scripting, Docker, GitHub Actions, Nomad, and Grafana Loki. Each step produces output that is reused in the next stage.

Repository: `https://github.com/ssgamingop/devops-intern-final`

## Project Structure

```text
.
├── .github/workflows/ci.yml
├── Dockerfile
├── hello.py
├── monitoring/
│   ├── docker-compose.yml
│   ├── loki-config.yml
│   ├── loki_setup.txt
│   └── promtail-config.yml
├── nomad/hello.nomad
├── README.md
└── scripts/
    ├── publish_local_image.sh
    └── sysinfo.sh
```

## 1. Git & GitHub Setup

- Public repository name: `devops-intern-final`
- Initial application file: `hello.py`
- Project documentation: `README.md`

Run the sample Python script:

```bash
python3 hello.py
```

Expected output:

```text
Hello, DevOps!
```

## 2. Linux & Scripting Basics

The Linux script lives at `scripts/sysinfo.sh` and prints:

- current user
- current date
- disk usage

Run it:

```bash
./scripts/sysinfo.sh
```

## 3. Docker Basics

Build the image:

```bash
docker build -t devops-intern-final:latest .
```

Run the container once:

```bash
docker run --rm devops-intern-final:latest
```

Expected output:

```text
Hello, DevOps!
```

Optional service mode for Nomad and Loki:

```bash
docker run --rm -e SERVICE_MODE=true -e LOG_INTERVAL_SECONDS=15 devops-intern-final:latest
```

In service mode, the container prints the greeting once and then emits heartbeat log lines every 15 seconds.

## 4. CI/CD with GitHub Actions

The workflow is defined in `.github/workflows/ci.yml`.

It runs automatically on:

- every `push`
- manual `workflow_dispatch`

The workflow checks out the repository, installs Python 3.12, and runs:

```bash
python hello.py
```

After pushing this repository to GitHub, the badge at the top of this README will show the workflow status.

## 5. Job Deployment with Nomad

The Nomad job specification is stored at `nomad/hello.nomad`.

For this local setup, Nomad pulls the image from a small local registry running on `localhost:5001`.

Publish the image for Nomad:

```bash
./scripts/publish_local_image.sh
```

Run the Nomad job:

```bash
nomad job run nomad/hello.nomad
```

Check allocation status:

```bash
nomad job status hello-devops
```

Follow the application logs from the active allocation:

```bash
nomad alloc logs <allocation-id>
```

The Nomad job enables `SERVICE_MODE=true` so the container stays alive and continues writing logs. In this repository, the job pulls `localhost:5001/devops-intern-final:latest` and uses `cpu = 10`, `memory = 128`.

## 6. Monitoring with Grafana Loki

Supporting files:

- `monitoring/loki-config.yml`
- `monitoring/promtail-config.yml`
- `monitoring/docker-compose.yml`
- `monitoring/loki_setup.txt`

Start Loki and Promtail:

```bash
docker compose -f monitoring/docker-compose.yml up -d
```

Start the application container in service mode:

```bash
docker run -d --name hello-devops -e SERVICE_MODE=true -e LOG_INTERVAL_SECONDS=10 devops-intern-final:latest
```

Forward the container logs into `monitoring/hello.log` so Promtail can ship them to Loki:

```bash
docker logs -f hello-devops 2>&1 | tee monitoring/hello.log
```

If you want to reuse the Nomad allocation instead of a standalone container, you can forward Nomad logs with:

```bash
nomad alloc logs -f <allocation-id> | tee monitoring/hello.log
```

Query Loki from the terminal:

```bash
curl -G -s "http://localhost:3100/loki/api/v1/query_range" \
  --data-urlencode 'query={job="hello-devops"}'
```

Detailed setup notes are included in `monitoring/loki_setup.txt`.

## Verification

Verified locally on March 8, 2026:

```bash
python3 hello.py
./scripts/sysinfo.sh
docker build -t devops-intern-final:latest .
docker run --rm devops-intern-final:latest
./scripts/publish_local_image.sh
nomad job run nomad/hello.nomad
nomad alloc logs <allocation-id>
docker compose -f monitoring/docker-compose.yml up -d
docker run -d --name hello-devops -e SERVICE_MODE=true -e LOG_INTERVAL_SECONDS=10 devops-intern-final:latest
docker logs -f hello-devops 2>&1 | tee monitoring/hello.log
curl -G -s "http://localhost:3100/loki/api/v1/query_range" \
  --data-urlencode 'query={job="hello-devops"}'
```

GitHub Actions does not run locally; it runs on GitHub on every push to the public repository above.
