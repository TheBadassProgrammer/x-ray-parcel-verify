# 📦 X-Ray Parcel Verify — Production ML & DevOps Platform

[![Docker CI Pipeline](https://github.com/atharva635/x-ray-parcel-verify/actions/workflows/docker-ci.yml/badge.svg)](https://github.com/atharva635/x-ray-parcel-verify/actions/workflows/docker-ci.yml)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110+-009688.svg?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED.svg?logo=docker&logoColor=white)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/Python-3.10-3776AB.svg?logo=python&logoColor=white)](https://www.python.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

An enterprise-ready, containerized Computer Vision platform and REST API designed to inspect and verify parcel contents from security X-ray scanner images. It analyzes internal microelectronics (silicon chips, battery coils, camera sensor modules, and circuit boards) to detect counterfeit, mismatched, or tampered consumer electronics before delivery.

---

## 📑 Table of Contents

- [Executive Summary](#-executive-summary)
- [System Architecture](#-system-architecture)
- [Interactive Web UI Terminal](#-interactive-web-ui-terminal)
- [Anti-Fraud Heuristics Engine](#-anti-fraud-heuristics-engine)
- [Dual Deployment Modes](#-dual-deployment-modes)
- [Tech Stack](#-tech-stack)
- [Repository Structure](#-repository-structure)
- [Quick Start Guide](#-quick-start-guide)
  - [Prerequisites](#prerequisites)
  - [Run with Docker (Recommended)](#1-run-with-docker-recommended)
  - [Run with Docker Compose](#2-run-with-docker-compose)
  - [Run Locally (Without Docker)](#3-run-locally-without-docker)
- [API Documentation & Usage](#-api-documentation--usage)
  - [Endpoints](#endpoints)
  - [cURL Request Example](#curl-request-example)
  - [Python Request Example](#python-request-example)
  - [Sample JSON Response](#sample-json-response)
- [CI/CD Pipeline (GitHub Actions)](#-cicd-pipeline-github-actions)
- [Cloud Deployment Guide (Render)](#-cloud-deployment-guide-render)
- [Production & Security Hardening](#-production--security-hardening)
- [Troubleshooting & FAQ](#-troubleshooting--faq)

---

## 🎯 Executive Summary

E-commerce supply chains and customs border inspection facilities face significant counterfeit parcel fraud. A fraudulent package often looks identical from the outside (a sealed phone box with a plastic dummy or unrelated item inside). 

**X-Ray Parcel Verify** solves this by peering inside packages using non-destructive X-ray computer vision:
1. Scans internal components at the hardware level (`iphone_chip`, `iphone_camera`, `iphone_charger`, `watch_sensor`, `apple_tab_pcb`, `airpod_pcb`).
2. Applies anti-fraud heuristics to evaluate whether the detected micro-components match genuine factory configurations.
3. Automatically categorizes parcels into **Genuine Device (`iPhone Detected`)**, **Counterfeit / Fraud Mismatch (`Not an iPhone`)**, or **Non-Electronics (`Uncertain ITEM`)**.
4. Produces real-time visual output with localized bounding boxes, confidence scores, and verification badges.

---

## 🏛️ System Architecture

```mermaid
flowchart TD
    Client["Client / Web UI / Inspector"] -->|POST /upload (X-Ray Scan)| Uvicorn["FastAPI ASGI Gateway (Port 8000/10000)"]
    
    subgraph Container ["Docker Containerized Environment"]
        Uvicorn --> Route{"Service Router"}
        
        Route -->|GET /| Dashboard["Cyber Terminal Web UI (static/index.html)"]
        Route -->|GET /health| Health["Health & Model Readiness Probe"]
        Route -->|GET /docs| Swagger["Interactive Swagger OpenAPI"]
        
        Route -->|POST /upload| Ingest["Sanitization & Size Check (Max 20MB)"]
        Ingest --> Processing["Preprocessing & Visual Geometry Analysis"]
        
        Processing --> Engine{"Inference Pipeline"}
        
        Engine -->|Deep Learning Mode| Y7["YOLOv7 26-Class Detector (71M Params)"]
        Y7 --> Y8["YOLOv8 Specialized Secondary Validator"]
        
        Engine -->|Cloud-Optimized Mode| Light["Dynamic Heuristics & Pillow Visual Annotator"]
        
        Y8 --> Rules["Heuristic Correlation Engine"]
        Light --> Rules
        
        Rules --> Annotate["Render Bounding Boxes & Color-Coded Header"]
        Annotate --> Storage[("Persistent Volume<br/>static/my_results/")]
    end
    
    Storage --> Response["JSON Payload + Rendered Image URL"]
    Response --> Client
```

---

## 💻 Interactive Web UI Terminal

The service includes a built-in, responsive dark-mode **Airport & Customs Security Terminal UI** served directly at root `/`:

* **Drag-and-Drop Dropzone:** Fast drag-and-drop support for any parcel scan (JPG, PNG, WEBP).
* **Live System Health Monitor:** Dynamic pulse indicator displaying engine status (`Online (CPU)`).
* **Real-Time Scanning Animation:** Visual laser scanning sweep during AI analysis.
* **Annotated Image Viewer:** Side-by-side inspection screen displaying predicted bounding boxes and component tags.
* **Verdict Cards:**
  - 🟢 **Emerald Green Shield (`Genuine Device`):** Verified internal microprocessors and optics present.
  - 🔴 **Red Alert Shield (`Verification Alert`):** Missing required microchips, dummy device, or component mismatch.
  - ⚪ **Neutral Shield (`Uncertain ITEM`):** No recognizable consumer electronic components segmented.
* **Component Breakdown Bars:** Animated percentage progress meters for every identified hardware piece.
* **JSON Payload Accordion:** Raw developer payload inspectable directly from the UI.

---

## 🧠 Anti-Fraud Heuristics Engine

Unlike simple classification models that classify an entire image into a single label, this system performs **multi-component relational validation**:

| Target Category | Required Internal Component Signatures | Verification Logic & Output |
| :--- | :--- | :--- |
| **iPhone (Genuine)** | `mobile_phone` + `iphone_chip` + `iphone_camera` + `iphone_charger` | $\ge 3$ components present $\rightarrow$ **`iPhone Detected`** |
| **Counterfeit Phone** | `mobile_phone` (chassis only, Apple silicon/optics missing) | Phone body present without Apple chips $\rightarrow$ **`Not an iPhone` (Fraud Alert)** |
| **Apple Watch** | `watch`, `watch_chip`, `watch_sensor`, `watch_pcb` | Genuine chips verified $\rightarrow$ **`Apple Watch Detected`** |
| **iPad / iPad Mini** | `tablet`, `apple_logo`, `apple_tab_pcb`, `apple_tab_chip` | PCB & chassis detected $\rightarrow$ **`iPad Detected`** |
| **AirPods** | `buds`, `buds_pcb`, `airpod_pcb`, `bus_dot` | Internal acoustic PCBs detected $\rightarrow$ **`Apple Airpods Detected`** |
| **Cameras** | `camera`, `shutter`, `lens_shutter`, `green_grip` | Shutter & lens optics detected $\rightarrow$ **`Nikon / Sony Camera Detected`** |
| **Non-Electronics** | Laptop, hoodie, clothing, documents, empty box | No micro-components detected $\rightarrow$ **`Uncertain ITEM`** |

---

## ⚙️ Dual Deployment Modes

To accommodate both high-performance GPU/CPU servers and zero-cost free cloud platforms, the repository supports two interchangeable execution modes:

### 1. Cloud-Optimized Mode (`demo_app.py`) — Default on Free Cloud Containers
* **Purpose:** Tailored specifically for cloud free tiers (e.g., Render 512MB RAM ceiling).
* **RAM Footprint:** **Under 45 MB RAM** (less than 10% of Render's free tier).
* **Engine:** Dynamic aspect-ratio analysis, internal circuit density variance analysis, and instant Pillow-based bounding box visualization.
* **Speed:** Sub-50ms execution per upload with zero Out-Of-Memory (OOM) risk.

### 2. Full Deep Learning Mode (`client_code.py` / `app.py`) — For Local & 16GB Environments
* **Purpose:** Production deep neural network evaluation using real PyTorch tensor graphs.
* **RAM Footprint:** ~650MB–1.2GB during full 640x640 forward passes.
* **Engine:** YOLOv7 (71 Million Parameters, 26 component classes) + YOLOv8 specialized iPhone Air model.
* **Platforms:** Local Docker Desktop, GPU workstations, or 16GB free instances on Hugging Face Spaces (`app.py`).

---

## 🛠️ Tech Stack

| Component | Technology | Version | Purpose |
| :--- | :--- | :--- | :--- |
| **Framework** | FastAPI | `>=0.110.0` | Asynchronous REST API server |
| **ASGI Server** | Uvicorn | `>=0.28.0` | Production ASGI web server |
| **Image Processing** | Pillow & OpenCV | `>=10.0` | Dynamic bounding box drawing & image codecs |
| **Deep Learning** | PyTorch & Ultralytics | `>=2.0.0` | Neural network graph execution |
| **Frontend UI** | HTML5, TailwindCSS, Lucide | CDN-based | Cyber security inspection terminal |
| **Container Engine** | Docker & Compose | Debian Bookworm | Isolated, reproducible container execution |
| **CI/CD** | GitHub Actions | v4 | Automated build, linting, and smoke tests |

---

## 📁 Repository Structure

```text
x-ray-parcel-verify/
├── .github/
│   └── workflows/
│       └── docker-ci.yml          # GitHub Actions CI/CD automation pipeline
├── static/
│   ├── index.html                 # Cyber terminal Web UI dashboard
│   ├── sample_result.jpg          # Permanent annotated fallback asset
│   └── my_results/                # Temporary inspection outputs & .gitkeep
├── 24_july_detection.pt           # YOLOv7 trained model weights (tracked via LFS)
├── best.pt                        # YOLOv8 iPhone Air model weights
├── app.py                         # Gradio 16GB Hugging Face entrypoint
├── client_code.py                 # Full deep learning PyTorch FastAPI backend
├── demo_app.py                    # Cloud-optimized lightweight FastAPI service (<45MB RAM)
├── Dockerfile                     # Production multi-stage Docker build recipe
├── docker-compose.yml             # Docker Compose orchestration config
├── requirements.txt               # Full PyTorch & YOLO production dependencies
├── requirements-demo.txt          # Cloud-optimized lightweight dependencies
├── .dockerignore                  # Docker build context exclusions
├── .gitignore                     # Git tracking exclusions
└── README.md                      # Comprehensive project documentation
```

---

## 🚀 Quick Start Guide

### Prerequisites

- Git & [Git LFS](https://git-lfs.com/)
- Docker Desktop (for containerized execution)
- Python 3.10+ (if running without Docker)

```bash
# Clone the repository
git clone https://github.com/atharva635/x-ray-parcel-verify.git
cd x-ray-parcel-verify
git lfs pull
```

---

### 1. Run with Docker (Recommended)

Build and launch the container with a single command:

```bash
# Build the Docker image
docker build -t x-ray-parcel-verify:latest .

# Run the container
docker run -d \
  --name x-ray-verify \
  -p 10000:10000 \
  --restart unless-stopped \
  x-ray-parcel-verify:latest
```

* Open the Web UI: **`http://localhost:10000`**
* Interactive Swagger Docs: **`http://localhost:10000/docs`**
* Healthcheck: **`http://localhost:10000/health`**

---

### 2. Run with Docker Compose

```bash
docker compose up -d --build
```

To view logs or shut down:
```bash
docker compose logs -f
docker compose down
```

---

### 3. Run Locally (Without Docker)

```bash
# Create and activate virtual environment
python -m venv .venv

# Windows (PowerShell)
.venv\Scripts\activate
# Linux / macOS
source .venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements-demo.txt

# Start the application
python demo_app.py
```

---

## 📡 API Documentation & Usage

Interactive Swagger documentation is available at **`/docs`**.

### Endpoints

| HTTP Method | Route | Description |
| :--- | :--- | :--- |
| `GET` | `/` | Serves the interactive Web UI inspection terminal |
| `GET` | `/health` | System health and model readiness probe |
| `GET` | `/api/status` | Programmatic API status details |
| `POST` | `/upload` | Upload X-ray image for component detection & classification |
| `GET` | `/static/...` | Serves generated result images with bounding boxes |

---

### cURL Request Example

```bash
curl -X POST "http://localhost:10000/upload" \
  -H "accept: application/json" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@sample_parcel.jpg"
```

---

### Python Request Example

```python
import requests

url = "http://localhost:10000/upload"
file_path = "sample_parcel.jpg"

with open(file_path, "rb") as img:
    response = requests.post(url, files={"file": img})

data = response.json()
print("Status Code:", response.status_code)
print("Classification:", data.get("classification"))
print("Detected Components:", data.get("detected_classes"))
print("Result Image URL:", data.get("result_image"))
```

---

### Sample JSON Response

```json
{
  "status": "success",
  "classification": "iPhone Detected",
  "results": [
    "iPhone Detected"
  ],
  "detected_classes": [
    "iphone_camera",
    "iphone_charger",
    "iphone_chip",
    "mobile_phone"
  ],
  "iphone_air_classes": [
    "camera_air"
  ],
  "detections_count": 4,
  "detections": [
    {
      "class": "mobile_phone",
      "confidence": 0.9787,
      "box": [77, 243, 243, 452]
    },
    {
      "class": "iphone_charger",
      "confidence": 0.9340,
      "box": [120, 291, 192, 382]
    },
    {
      "class": "iphone_chip",
      "confidence": 0.8145,
      "box": [203, 389, 224, 409]
    },
    {
      "class": "iphone_camera",
      "confidence": 0.7835,
      "box": [151, 386, 201, 442]
    }
  ],
  "result_image": "http://localhost:10000/static/my_results/detection_2026-11-19_20-00-00_a1b2c3d4e5.jpg"
}
```

---

## 🔄 CI/CD Pipeline (GitHub Actions)

Located in `.github/workflows/docker-ci.yml`, the automated pipeline triggers on pushes to `main`, `feature/**`, and pull requests:

1. **Checkout & LFS Fetch:** Clones repo and verifies integrity of weights files.
2. **Syntax Validation:** Runs bytecode compilation `py_compile` on backend services.
3. **Docker Buildx Cache:** Builds the container using GitHub Actions layer caching.
4. **Container Health Probe:** Launches the container and polls `/health` until active.
5. **End-to-End Smoke Test:** Synthesizes an image and sends a live `POST /upload` request to ensure inference, status codes, and JSON response formatting work end-to-end.

---

## ☁️ Cloud Deployment Guide (Render)

Deploy on [Render](https://render.com) in 3 simple steps:

1. **Connect Repository:**
   - Go to [dashboard.render.com](https://dashboard.render.com/) → **New +** → **Web Service**.
   - Select your fork: `atharva635/x-ray-parcel-verify`.
   - Branch: `feature/docker-devops-deployment`.

2. **Configure Service:**
   - **Environment:** `Docker`
   - **Instance Type:** `Free (512 MB RAM)`
   - **Dockerfile Path:** `./Dockerfile`

3. **Deploy:**
   - Click **Create Web Service**.
   - Render will build the lightweight image in ~15 seconds and provide your live URL (e.g. `https://x-ray-parcel-verify.onrender.com`).

---

## 🔒 Production & Security Hardening

- **Memory Safety:** Sub-50MB RAM profile prevents kernel Out-Of-Memory (OOM) kills on memory-constrained cloud tiers.
- **UUID File Storage:** User-provided filenames are discarded; each file receives a sanitized, collision-resistant UUID (`uuid4().hex`) preventing path traversal attacks.
- **Reverse Proxy Header Handling:** Automatically inspects `x-forwarded-proto` to serve HTTPS asset links behind SSL load balancers.
- **Automated Storage Housekeeping:** Automatically purges older inspection results when capacity limits are approached to prevent disk exhaustion.
- **Input Sanitization:** Enforces image MIME verification and maximum upload size limits (20MB).

---

## ❓ Troubleshooting & FAQ

| Problem | Root Cause | Solution |
| :--- | :--- | :--- |
| `Out of memory (used over 512Mi)` on Render | Full PyTorch 71M parameter model requires >1GB RAM | Use the default cloud-optimized `demo_app.py` or deploy the PyTorch model on Hugging Face Spaces (16GB RAM). |
| Result image shows broken icon | HTTP asset requested on an HTTPS page (Mixed Content) | Fixed in v2.0: Backend dynamically inspects `x-forwarded-proto` and outputs matching HTTPS URLs. |
| Model weights missing | Git LFS pointer pulled instead of binary weights | Run `git lfs install && git lfs pull`. |
| Port already in use locally | Port 10000 or 8000 bound by another process | Map to a different host port: `docker run -p 10001:10000 ...`. |

---

## 👨‍💻 Contributing & Pull Requests

Contributions are welcome! Please follow these steps:
1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/docker-devops-deployment`).
3. Commit your Changes (`git commit -m 'feat: Add Docker and CI/CD workflow'`).
4. Push to the Branch (`git push origin feature/docker-devops-deployment`).
5. Open a Pull Request against upstream `main`.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
