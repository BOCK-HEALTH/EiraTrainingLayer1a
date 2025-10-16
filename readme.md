# YouTube Channel Video Extractor - Local Development Guide

## Overview
This tool allows you to extract all video links from a given YouTube channel by providing its Channel ID. It consists of a Python backend (Flask API) and a modern HTML/JS frontend. The backend fetches video data using the YouTube Data API v3, and the frontend provides a user-friendly interface for input and results.

---

## Project Structure
```
local/
├── index.html              # Frontend UI
├── lambda_function.py      # Flask backend (API logic)
├── requirements.txt        # Python dependencies
├── youtube_video_links.py  # (Optional) Standalone video links API
└── readme.md               # This documentation
```

---

## Prerequisites
- Python 3.7+
- pip (Python package manager)
- A valid YouTube Data API v3 key ([Get one here](https://console.developers.google.com/))

---

## Setup Instructions

### 1. Clone the Repository
```bash
git clone <repo-url>
cd <repo-root>/local
```

### 2. Install Python Dependencies
```bash
pip install -r requirements.txt
# Or, if requirements.txt is missing:
pip install flask flask-cors urllib3
```

### 3. Set Your YouTube API Key
Export your API key as an environment variable:
```bash
export YOUTUBE_API_KEY=YOUR_VALID_API_KEY
```
Replace `YOUR_VALID_API_KEY` with your actual API key.

---

## Running the Backend (Flask API)

### Start the Flask Server
```bash
python lambda_function.py --flask
```
- The server will run at `http://127.0.0.1:5001`.
- The main API endpoint is: `POST /api/lambda`

### Test the API with curl
```bash
curl -X POST -H "Content-Type: application/json" -d '{"channelId": "<CHANNEL_ID>"}' http://127.0.0.1:5001/api/lambda
```
Replace `<CHANNEL_ID>` with a real YouTube channel ID.

---

## Running the Frontend (index.html)

### 1. Open `index.html` in your browser
- Double-click or right-click and open with your browser.
- Make sure the API URL in the script is set to `http://127.0.0.1:5001/api/lambda`.

### 2. Usage
- Enter a YouTube Channel ID (e.g., `UC_x5XG1OV2P6uZZ5FSM9Ttw`).
- Click "Extract Video Links".
- The tool will display all video links and allow you to download them as a `.txt` file.

---

## Troubleshooting

### CORS Errors
- Ensure you have `flask-cors` installed and CORS enabled in `lambda_function.py`.
- Restart the Flask server after installing new packages.

### API Key Errors
- Make sure your API key is valid and has YouTube Data API v3 enabled.
- Check for typos in the environment variable name.

### No Video Links Found
- Check the backend logs for error messages.
- Make sure the channel ID is correct and the channel has public videos.
- Inspect the browser Network tab for the actual backend response.

### Debugging
- The backend prints detailed debug logs for every request.
- Check the terminal running Flask for `[DEBUG]` and `[ERROR]` messages.

---

## Extending the Tool
- You can add more endpoints or logic in `lambda_function.py`.
- The frontend can be styled or extended as needed (uses Tailwind CSS for quick UI changes).

---

## Contact
For questions or issues, contact the project maintainer or open an issue in the repository.

---
