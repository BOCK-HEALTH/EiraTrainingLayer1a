"""
lambda_function.py - Refactored for local testing and Lambda compatibility
"""
import json
import os
import urllib3
try:
    from flask import Flask, request, jsonify
    from flask_cors import CORS
except ImportError:
    Flask = None
    request = None
    jsonify = None
    CORS = None

# Initialize the HTTP client
http = urllib3.PoolManager()

def lambda_handler(event, context):
    """
    Main handler function for the Lambda execution.
    """
    # Your secret API key is stored as an environment variable
    API_KEY = os.environ.get('YOUTUBE_API_KEY')

    # Get the channelId from the POST request body
    try:
        body = json.loads(event.get('body', '{}'))
        channel_id = body.get('channelId')
    except (json.JSONDecodeError, AttributeError):
        return create_response(400, {"error": "Invalid request body. Channel ID is missing."})

    if not channel_id:
        return create_response(400, {"error": "Channel ID is required."})

    try:
        # --- Step 1: Get Channel Info (Playlist ID and Title) ---
        channel_info_url = f"https://www.googleapis.com/youtube/v3/channels?part=snippet,contentDetails&id={channel_id}&key={API_KEY}"
        r = http.request('GET', channel_info_url)
        channel_info_data = json.loads(r.data.decode('utf-8'))
        print("[DEBUG] Channel info response:", channel_info_data)

        if 'error' in channel_info_data or not channel_info_data.get('items'):
            error_message = channel_info_data.get('error', {}).get('message', 'Could not find a channel with that ID.')
            print(f"[ERROR] Channel info error: {error_message}")
            return create_response(404, {"error": error_message})

        channel_item = channel_info_data['items'][0]
        uploads_playlist_id = channel_item['contentDetails']['relatedPlaylists']['uploads']
        channel_title = channel_item['snippet']['title']

        # --- Step 2: Fetch all video links from the playlist ---
        all_video_links = []
        next_page_token = None

        while True:
            playlist_url = f"https://www.googleapis.com/youtube/v3/playlistItems?part=contentDetails&playlistId={uploads_playlist_id}&maxResults=50&key={API_KEY}"
            if next_page_token:
                playlist_url += f"&pageToken={next_page_token}"

            r = http.request('GET', playlist_url)
            playlist_data = json.loads(r.data.decode('utf-8'))
            print("[DEBUG] Playlist data response:", playlist_data)

            if 'error' in playlist_data:
                print(f"[ERROR] Playlist data error: {playlist_data['error']['message']}")
                raise Exception(f"YouTube API error: {playlist_data['error']['message']}")

            for item in playlist_data.get('items', []):
                video_id = item['contentDetails']['videoId']
                all_video_links.append(f"https://www.youtube.com/watch?v={video_id}")

            next_page_token = playlist_data.get('nextPageToken')
            if not next_page_token:
                break

        # --- Step 3: Send the successful result back to the frontend ---
        print(f"[DEBUG] Returning {len(all_video_links)} video links for channel '{channel_title}'")
        return create_response(200, {
            "channelTitle": channel_title,
            "videoCount": len(all_video_links),
            "links": all_video_links
        })

    except Exception as e:
        print(f"[EXCEPTION] An error occurred: {e}")
        return create_response(500, {"error": str(e)})

def create_response(status_code, body):
    """
    Helper function to format the response for API Gateway.
    """
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",  # Allow requests from any origin
            "Access-Control-Allow-Headers": "Content-Type"
        },
        "body": json.dumps(body)
    }


app = Flask(__name__) if Flask else None
if app and CORS:
    CORS(app)

if app:
    @app.route('/api/lambda', methods=['POST'])
    def lambda_api():
        event = {"body": json.dumps(request.get_json(force=True))}
        result = lambda_handler(event, None)
        return jsonify(result)

def main():
    # Simple CLI for local testing
    import sys
    if len(sys.argv) > 1:
        event = {"body": json.dumps({"channelId": sys.argv[1]})}
    else:
        event = {"body": json.dumps({"channelId": "YOUR_CHANNEL_ID_HERE"})}
    result = lambda_handler(event, None)
    print(json.dumps(result, indent=2))

if __name__ == '__main__':
    import sys
    if app and '--flask' in sys.argv:
        app.run(debug=True, port=5001)
    else:
        main()