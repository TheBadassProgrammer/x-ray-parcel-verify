# 📦 X-Ray Parcel Verify — Production ML & DevOps Platform

[![Docker CI Pipeline](https://github.com/atharva635/x-ray-parcel-verify/actions/workflows/docker-ci.yml/badge.svg)](https://github.com/atharva635/x-ray-parcel-verify/actions/workflows/docker-ci.yml)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110+-009688.svg?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED.svg?logo=docker&logoColor=white)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/Python-3.10-3776AB.svg?logo=python&logoColor=white)](https://www.python.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

An enterprise-ready, containerized Computer Vision REST API designed to inspect and verify parcel contents from X-ray scans. It detects internal electronics components (microchips, circuit boards, camera modules, sensors) and infers genuine vs. fraudulent or mismatched items (iPhones, Apple Watches, iPads, Apple Pencils, AirPods, and professional cameras).

---

## 📑 Table of Contents

- [System Architecture](#-system-architecture)
- [Key Features](#-key-features)
- [Tech Stack](#-tech-stack)
- [Repository Structure](#-repository-structure)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Local Installation (Without Docker)](#local-installation-without-docker)
- [Docker & Containerization](#-docker--containerization)
  - [Build Docker Image](#1-build-docker-image)
  - [Run with Docker CLI](#2-run-with-docker-cli)
  - [Run with Docker Compose](#3-run-with-docker-compose)
- [API Documentation & Usage](#-api-documentation--usage)
  - [Endpoints](#endpoints)
  - [cURL Example](#curl-example)
  - [Python Example](#python-example)
  - [Sample Response](#sample-response)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Cloud Deployment (Render Guide)](#-cloud-deployment-render-guide)
- [Security & Production Hardening](#-security--production-hardening)
- [Troubleshooting](#-troubleshooting)

---

## 🏛️ System Architecture

```mermaid
flowchart TD
    Client["Client / Web UI / Inspector"] -->|POST /upload (X-Ray Image)| NGINX["API Gateway / Uvicorn Server"]
    NGINX --> Router["FastAPI Router"]
    
    subgraph Container ["Docker Container (/app)"]
        Router --> Sanitize["Input Validation & UUID Sanitization"]
        Sanitize --> Preprocess["Letterbox Resize & Tensor Normalization"]
        Preprocess --> Y7["YOLOv7 Model (24_july_detection.pt)<br/>26 Component Classes"]
        Y7 --> NMS["Non-Maximum Suppression (NMS)"]
        NMS --> BBox["Scale Bounding Boxes & Confidences"]
        BBox --> Rules["Heuristic Correlation Engine"]
        
        Rules --> CheckPhone{"mobile_phone Detected?"}
        CheckPhone -- Yes --> Y8["YOLOv8 Model (best.pt)<br/>iPhone Air Specific Features"]
        CheckPhone -- No --> Aggregate["Aggregate Verification Output"]
        Y8 --> Aggregate
        
        Aggregate --> Render["Visual Overlay & Text Banner"]
        Render --> Storage[("Persistent Volume<br/>static/my_results/")]
    end
    
    Storage --> Response["JSON Response + Annotated Image URL"]
    Response --> Client
```

---

## ✨ Key Features

- **Dual-Model Detection Pipeline:**
  - **YOLOv7:** Primary object detection detecting 26 distinct internal hardware components (`iphone_chip`, `watch_pcb`, `apple_tab_pcb`, `airpod_pcb`, etc.).
  - **YOLOv8:** Secondary specialized validator for iPhone Air architecture.
- **Rule-Based Heuristic Inference:** Automatically correlates detected components to determine genuine items vs. counterfeits or missing parts.
- **Bounding Box Visualization:** Draws colored bounding boxes, class labels, and confidence scores directly on the output image and returns normalized coordinates in the API payload.
- **Production-Ready Dockerization:**
  - Lightweight CPU-optimized base image (`python:3.10-slim`).
  - PyTorch CPU wheels to drastically reduce container image size from ~5GB to ~1.3GB.
  - Non-root user execution (`appuser:1000`) for container security.
- **Automated CI/CD:** GitHub Actions workflow validating Python syntax, Docker build, health check, and end-to-end inference smoke testing.
- **Production Safety:**
  - File upload size limiting (default 20MB).
  - Cryptographically secure UUID-based file naming to eliminate race conditions and path traversal attacks.
  - Background thread execution in FastAPI preventing CPU blocking on the async event loop.

---

## 🛠️ Tech Stack

| Component | Technology | Version | Purpose |
| :--- | :--- | :--- | :--- |
| **Framework** | FastAPI | `>=0.110.0` | High-performance asynchronous REST API |
| **ASGI Server** | Uvicorn | `>=0.28.0` | Production ASGI web server |
| **ML Framework** | PyTorch (CPU) | `>=2.0.0` | Model inference & tensor computing |
| **Detection Models** | YOLOv7 & YOLOv8 | Custom `.pt` | Object & component detection |
| **Image Processing** | OpenCV Headless | `>=4.8.0` | Preprocessing, letterboxing, bounding box drawing |
| **Container Engine** | Docker & Compose | Multi-stage | Isolated, reproducible deployment |
| **CI/CD** | GitHub Actions | v4 | Automated builds, linting, and smoke tests |

---

## 📁 Repository Structure

```text
x-ray-parcel-verify/
├── .github/
│   └── workflows/
│       └── docker-ci.yml          # GitHub Actions CI/CD automation workflow
├── static/
│   └── my_results/                # Generated verification results & output images
│       └── .gitkeep
├── .dockerignore                  # Docker build context exclusions
├── .gitignore                     # Git tracking exclusions
├── 24_july_detection.pt           # YOLOv7 trained model weights (tracked via LFS)
├── best.pt                        # YOLOv8 iPhone Air model weights
├── client_code.py                 # FastAPI application & ML inference pipeline
├── docker-compose.yml             # Docker Compose local orchestration config
├── Dockerfile                     # Production multi-stage Docker build recipe
├── requirements.txt               # Pinned Python production dependencies
└── README.md                      # Comprehensive project documentation
```

---

## 🚀 Getting Started

### Prerequisites

- Git & [Git LFS](https://git-lfs.com/) installed
- Python 3.10+ (if running without Docker)
- Docker Desktop or Docker Engine (recommended)

Clone the repository with Git LFS enabled to download model weights:

```bash
git clone https://github.com/atharva635/x-ray-parcel-verify.git
cd x-ray-parcel-verify
git lfs pull
```

---

### Local Installation (Without Docker)

1. **Clone YOLOv7 utilities** into the project directory:
   ```bash
   git clone --depth 1 https://github.com/WongKinYiu/yolov7.git yolov7
   ```

2. **Create and activate a virtual environment:**
   ```bash
   # Windows (PowerShell)
   python -m venv .venv
   .venv\Scripts\activate

   # Linux / macOS
   python3 -m venv .venv
   source .venv/bin/activate
   ```

3. **Install dependencies:**
   ```bash
   pip install --upgrade pip
   pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu
   pip install -r requirements.txt
   ```

4. **Start the server:**
   ```bash
   python client_code.py
   ```
   The API will be available at `http://127.0.0.1:8000`.

---

## 🐳 Docker & Containerization

Using Docker ensures the application runs consistently across any operating system without managing system-level PyTorch or YOLOv7 path dependencies.

### 1. Build Docker Image

```bash
docker build -t x-ray-parcel-verify:latest .
```

*Note: The Docker build installs CPU-optimized PyTorch and clones the official YOLOv7 repository into `/app/yolov7` inside the container.*

### 2. Run with Docker CLI

```bash
docker run -d \
  --name x-ray-verify \
  -p 8000:8000 \
  -v parcel_results:/app/static/my_results \
  --restart unless-stopped \
  x-ray-parcel-verify:latest
```

Verify that the container is healthy:

```bash
docker ps
curl http://localhost:8000/health
```

### 3. Run with Docker Compose

To spin up the service with persistent volumes and healthchecks in a single command:

```bash
docker compose up -d --build
```

To view logs or stop the service:

```bash
docker compose logs -f
docker compose down
```

---

## 📡 API Documentation & Usage

Interactive Swagger documentation is available at:
👉 **`http://localhost:8000/docs`**

### Endpoints

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/` | API status and links |
| `GET` | `/health` | Healthcheck and model readiness probe |
| `POST` | `/upload` | Upload X-ray image for component detection |
| `GET` | `/static/...` | Serves processed result images |

### cURL Example

```bash
curl -X POST "http://localhost:8000/upload" \
  -H "accept: application/json" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@sample_parcel.jpg"
```

### Python Example

```python
import requests

url = "http://localhost:8000/upload"
file_path = "sample_parcel.jpg"

with open(file_path, "rb") as image_file:
    response = requests.post(url, files={"file": image_file})

print(response.status_code)
print(response.json())
```

### Sample Response

```json
{
  "status": "success",
  "classification": "iPhone Detected, Apple Watch Detected",
  "results": [
    "iPhone Detected",
    "Apple Watch Detected"
  ],
  "detected_classes": [
    "iphone_camera",
    "iphone_chip",
    "mobile_phone",
    "watch",
    "watch_chip"
  ],
  "iphone_air_classes": [],
  "detections_count": 5,
  "detections": [
    {
      "class": "mobile_phone",
      "confidence": 0.9412,
      "box": [120, 85, 340, 510]
    },
    {
      "class": "iphone_chip",
      "confidence": 0.8845,
      "box": [180, 210, 260, 290]
    }
  ],
  "result_image": "http://localhost:8000/static/my_results/detection_2026-11-19_18-30-00_4f9a2e81d7c3.jpg"
}
```

---

## 🔄 CI/CD Pipeline

The repository includes a production-grade GitHub Actions CI workflow in `.github/workflows/docker-ci.yml`.

### Workflow Stages:
1. **Checkout & LFS Fetch:** Clones repo and verifies model weights (`24_july_detection.pt`, `best.pt`).
2. **Python Syntax Check:** Runs `py_compile` on `client_code.py`.
3. **Docker Buildx Cache:** Builds the container using GitHub Actions layer caching.
4. **Container Health Probe:** Launches the container and polls `/health` until models are loaded in memory.
5. **End-to-End Smoke Test:** Synthesizes an image and sends a live `POST /upload` request to ensure inference and response formatting work end-to-end.

---

## ☁️ Cloud Deployment (Render Guide)

[Render](https://render.com) is recommended for deploying the Docker container with minimal setup.

### Step-by-Step Render Deployment:

1. **Push your code to GitHub:**
   Ensure all changes and weights are pushed to your fork.

2. **Log in to Render Dashboard:**
   - Go to [dashboard.render.com](https://dashboard.render.com/).
   - Click **New +** → Select **Web Service**.

3. **Connect Your Repository:**
   - Select `atharva635/x-ray-parcel-verify`.
   - Choose branch: `feature/docker-devops-deployment` (or `main` after merging).

4. **Configure Service:**
   - **Name:** `x-ray-parcel-verify`
   - **Environment:** `Docker`
   - **Region:** Choose the region closest to you (e.g., Singapore, Frankfurt, Oregon).
   - **Plan:** Free or Starter (PyTorch + YOLOv7 requires ~450MB–600MB RAM at runtime).
   
5. **Set Environment Variables:**
   Under **Environment Variables**, add:
   - `PORT`: `8000`
   - `DEVICE`: `cpu`
   - `TORCH_THREADS`: `2` (limits CPU thread allocations to keep memory within Free Tier limits).

6. **Deploy:**
   - Click **Create Web Service**.
   - Render will build the `Dockerfile` automatically and spin up your live URL (e.g., `https://x-ray-parcel-verify.onrender.com`).
   - Access Swagger docs at `https://x-ray-parcel-verify.onrender.com/docs`.

---

## 🔒 Security & Production Hardening

- **Non-Root Execution:** Container runs under `appuser` (UID 1000) rather than root.
- **UUID File Storage:** User-provided filenames are discarded; each file receives a sanitized, collision-resistant UUID (`uuid4().hex`) preventing directory traversal attacks.
- **Memory Optimization:** Explicit `gc.collect()` and configurable `TORCH_THREADS=2` prevent Out-Of-Memory (OOM) crashes on constrained cloud instances.
- **Input Sanitization:** Enforces image MIME verification and maximum upload size limits (default 20MB).

---

## ❓ Troubleshooting

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| `ModuleNotFoundError: No module named 'models'` | YOLOv7 source code not in Python path | Set `YOLOV7_PATH=/app/yolov7` or clone YOLOv7 locally as shown in Getting Started. |
| `torch.cuda.OutOfMemoryError` or Container killed (OOM) | Memory exhausted during inference | Ensure `DEVICE=cpu` and `TORCH_THREADS=1` or `2` in environment variables. |
| Model weights missing or corrupt | Git LFS pointer instead of actual weights | Run `git lfs install && git lfs pull` to fetch binary weights. |
| Port 8000 already in use | Host port conflict | Change port mapping in docker command: `-p 8080:8000`. |

---

## 👨‍💻 Contributing

Contributions are welcome! Please follow these steps:
1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/docker-devops-deployment`).
3. Commit your Changes (`git commit -m 'feat: Add Docker and CI/CD workflow'`).
4. Push to the Branch (`git push origin feature/docker-devops-deployment`).
5. Open a Pull Request.

---


## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
