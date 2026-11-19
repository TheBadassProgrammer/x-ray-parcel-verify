# Project Contribution

## Contributor
Sahil

## Role
Backend Developer

## Project
X-Ray Parcel Verify

## Contribution
Added project contribution documentation.

This file is intended to document contributor
information without modifying application functionality.  
# Backend Documentation – X-Ray Parcel Verify

## 1. Introduction

X-Ray Parcel Verify is a computer vision-based platform designed to inspect and verify parcel contents using X-ray scanner images.

The backend is developed using Python and FastAPI. It provides REST API endpoints for image uploads, image processing, component detection, and parcel verification.

The primary objective of the backend is to identify internal electronic components and determine whether a parcel contains genuine, counterfeit, or uncertain electronic products.

## 2. Backend Architecture

The backend follows a modular architecture consisting of the following components:

- **API Gateway:** FastAPI handles incoming HTTP requests and routes them to the appropriate services.
- **Image Upload Handler:** Accepts uploaded X-ray images and validates incoming files.
- **Image Preprocessing:** Prepares uploaded images for computer vision analysis.
- **Detection Engine:** Uses YOLO-based models and lightweight image analysis to identify electronic components.
- **Verification Engine:** Applies anti-fraud heuristics to evaluate detected components.
- **Image Annotation:** Generates visual output with bounding boxes and confidence scores.
- **Result Handler:** Returns verification results in JSON format and provides access to annotated images.

## 3. Technologies Used

| Technology | Purpose |
|---|---|
| Python | Backend programming |
| FastAPI | REST API development |
| Uvicorn | ASGI server |
| YOLOv7 | Primary object detection |
| YOLOv8 | Specialized secondary validation |
| PyTorch | Deep learning inference |
| Pillow | Image processing and annotation |
| OpenCV | Image processing |
| Docker | Application containerization |
| GitHub Actions | CI/CD automation |

## 4. Backend Deployment Modes

The project supports two backend execution modes.

### 4.1 Cloud-Optimized Mode

- Implemented in `demo_app.py`.
- Designed for resource-constrained cloud environments.
- Uses lightweight image analysis and dynamic heuristics.
- Uses Pillow for image annotation.
- Designed to operate with a low memory footprint.

### 4.2 Full Deep Learning Mode

- Implemented in `client_code.py`.
- Uses PyTorch-based deep learning inference.
- Integrates YOLOv7 and a specialized YOLOv8 model.
- Performs detailed component detection and verification.
- Intended for systems with higher memory and computational resources.

## 5. REST API Endpoints

The backend exposes the following endpoints:

| HTTP Method | Endpoint | Description |
|---|---|---|
| GET | `/` | Serves the web-based inspection dashboard. |
| GET | `/health` | Checks backend health and model readiness. |
| GET | `/api/status` | Returns programmatic API status information. |
| POST | `/upload` | Accepts an X-ray image and performs component detection and verification. |
| GET | `/static/...` | Provides access to generated result images. |

## 6. Image Processing Workflow

The backend follows these processing steps:

1. Receives an X-ray image through the `/upload` endpoint.
2. Validates the uploaded file and checks its size and image format.
3. Performs image preprocessing and visual analysis.
4. Detects internal electronic components using the selected execution mode.
5. Applies verification heuristics to compare detected components against expected configurations.
6. Generates annotated images with bounding boxes and confidence scores.
7. Returns the classification results and generated image URL through a JSON response.

## 7. Anti-Fraud Verification Logic

The backend uses component-based verification instead of relying only on complete-image classification.

Examples of verification include:

- **iPhone Verification:** Checks for mobile phone chassis, Apple chip, camera, and charger components.
- **Apple Watch Verification:** Checks for watch components, chips, sensors, and PCB.
- **iPad Verification:** Checks for tablet components, Apple logo, PCB, and chip.
- **AirPods Verification:** Checks for internal acoustic components and PCBs.
- **Counterfeit Detection:** Identifies missing or mismatched internal components.

The verification engine uses detected component combinations to generate the final classification.

## 8. API Response Structure

The backend returns structured JSON responses containing information such as:

- `status`: Processing status.
- `classification`: Final verification result.
- `results`: Classification details.
- `detected_classes`: List of detected component classes.
- `detections_count`: Number of detected objects.
- `detections`: Object detection details, including class, confidence, and bounding box coordinates.
- `result_image`: URL of the generated annotated image.

## 9. Error Handling and Security

The backend includes the following security and reliability measures:

- Image MIME-type verification.
- Maximum upload size restriction of 20 MB.
- Sanitized and UUID-based filenames.
- Protection against filename-based path traversal.
- Automatic cleanup of older inspection results.
- Health-check endpoint for service monitoring.
- HTTPS-aware asset URL generation behind reverse proxies.

## 10. Docker and Deployment

The backend supports containerized deployment using Docker.

Important configuration files include:

- `Dockerfile`: Defines the Docker image build process.
- `docker-compose.yml`: Provides container orchestration.
- `requirements.txt`: Contains full backend and deep learning dependencies.
- `requirements-demo.txt`: Contains lightweight cloud-mode dependencies.

The application can be deployed locally or on supported cloud platforms such as Render.

## 11. CI/CD Integration

The project uses GitHub Actions for automated integration and deployment checks.

The CI pipeline includes:

- Repository checkout and Git LFS handling.
- Python syntax validation.
- Docker image building.
- Container health checks.
- API smoke testing.
- Image upload and response validation.

## 12. Conclusion

The backend of X-Ray Parcel Verify provides an API-driven computer vision system for automated parcel inspection and electronic component verification.

By combining FastAPI, deep learning models, image processing, anti-fraud heuristics, and Docker-based deployment, the system provides a flexible architecture that supports both lightweight cloud deployment and full deep learning execution.

This documentation describes the existing backend architecture and its major components.
