import os
import sys
import json
import urllib.parse
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

AMV_DIR = r"D:\AMVS"
WORKSPACE_DIR = r"d:\Projects\BinaHub"

class AMVMediaRequestHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Range, Content-Type')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        # 1. API: List AMVs
        if path == '/api/amvs/list':
            self.handle_api_amvs_list()
            return

        # 2. Serve AMV media files with HTTP Range support for smooth video streaming
        if path.startswith('/amvs/'):
            filename = urllib.parse.unquote(path[6:])
            filepath = os.path.join(AMV_DIR, filename)
            if os.path.isfile(filepath):
                self.serve_media_with_range(filepath)
                return
            else:
                self.send_error(404, f"File not found: {filename}")
                return

        # Default static file serving from BinaHub workspace
        super().do_GET()

    def handle_api_amvs_list(self):
        meta_file = os.path.join(WORKSPACE_DIR, 'thumbnails', 'amvs_meta.json')
        if os.path.isfile(meta_file):
            try:
                with open(meta_file, 'r', encoding='utf-8') as f:
                    meta_dict = json.load(f)
                    video_list = list(meta_dict.values())
                    data = json.dumps(video_list, ensure_ascii=False).encode('utf-8')
                    self.send_response(200)
                    self.send_header('Content-Type', 'application/json; charset=utf-8')
                    self.send_header('Content-Length', str(len(data)))
                    self.end_headers()
                    self.wfile.write(data)
                    return
            except Exception as e:
                print("Error reading amvs_meta.json:", e)

        video_list = []
        if os.path.isdir(AMV_DIR):
            exts = ('.mp4', '.mkv', '.webm', '.avi', '.mov', '.ts')
            files = [f for f in sorted(os.listdir(AMV_DIR)) if f.lower().endswith(exts)]
            for idx, fname in enumerate(files):
                full_path = os.path.join(AMV_DIR, fname)
                try:
                    stat = os.stat(full_path)
                    size_mb = stat.st_size / (1024 * 1024)
                    size_str = f"{size_mb:.1f} MB" if size_mb < 1024 else f"{(size_mb/1024):.2f} GB"
                    mtime = stat.st_mtime
                    import datetime
                    date_str = datetime.date.fromtimestamp(mtime).isoformat()
                except Exception:
                    size_str = "Unknown"
                    date_str = "2026-11-08"

                res = "1080p FHD"
                if "4k" in fname.lower() or "4_k" in fname.lower():
                    res = "4K UHD"
                elif size_mb > 30:
                    res = "1080p 60FPS"
                elif size_mb > 15:
                    res = "1080p"
                else:
                    res = "720p HD"

                codec = "MP4 / H.264"
                if fname.lower().endswith('.mkv'):
                    codec = "MKV / HEVC"
                elif fname.lower().endswith('.webm'):
                    codec = "WebM / VP9"

                video_list.append({
                    "id": f"amv_{idx+1}",
                    "title": fname,
                    "filename": fname,
                    "url": f"/amvs/{urllib.parse.quote(fname)}",
                    "thumbUrl": f"/thumbnails/amvs/{urllib.parse.quote(fname)}.jpg",
                    "size": size_str,
                    "bytes": stat.st_size if 'stat' in locals() else 0,
                    "res": res,
                    "codec": codec,
                    "date": date_str,
                    "totalTime": "03:45",
                    "totalSec": 225
                })

        data = json.dumps(video_list, ensure_ascii=False).encode('utf-8')
        self.send_response(200)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def serve_media_with_range(self, filepath):
        try:
            file_size = os.path.getsize(filepath)
            range_header = self.headers.get('Range')

            content_type = 'video/mp4'
            if filepath.lower().endswith('.mkv'):
                content_type = 'video/x-matroska'
            elif filepath.lower().endswith('.webm'):
                content_type = 'video/webm'

            if range_header:
                # Parse Range: bytes=start-end
                range_match = range_header.strip().replace('bytes=', '')
                parts = range_match.split('-')
                start = int(parts[0]) if parts[0] else 0
                end = int(parts[1]) if len(parts) > 1 and parts[1] else file_size - 1

                if start >= file_size:
                    self.send_error(416, "Requested Range Not Satisfiable")
                    return

                end = min(end, file_size - 1)
                length = end - start + 1

                self.send_response(206)
                self.send_header('Content-Type', content_type)
                self.send_header('Content-Range', f"bytes {start}-{end}/{file_size}")
                self.send_header('Content-Length', str(length))
                self.send_header('Accept-Ranges', 'bytes')
                self.end_headers()

                with open(filepath, 'rb') as f:
                    f.seek(start)
                    bytes_remaining = length
                    chunk_size = 64 * 1024
                    while bytes_remaining > 0:
                        to_read = min(chunk_size, bytes_remaining)
                        chunk = f.read(to_read)
                        if not chunk:
                            break
                        self.wfile.write(chunk)
                        bytes_remaining -= len(chunk)
            else:
                self.send_response(200)
                self.send_header('Content-Type', content_type)
                self.send_header('Content-Length', str(file_size))
                self.send_header('Accept-Ranges', 'bytes')
                self.end_headers()

                with open(filepath, 'rb') as f:
                    chunk_size = 64 * 1024
                    while True:
                        chunk = f.read(chunk_size)
                        if not chunk:
                            break
                        self.wfile.write(chunk)
        except (ConnectionResetError, BrokenPipeError):
            pass  # Normal when client seeks or closes stream
        except Exception as e:
            try:
                self.send_error(500, f"Streaming error: {e}")
            except Exception:
                pass

if __name__ == '__main__':
    os.chdir(WORKSPACE_DIR)
    server = ThreadingHTTPServer(('127.0.0.1', 8088), AMVMediaRequestHandler)
    print("AMV-Linked Threaded Media Server running on http://127.0.0.1:8088")
    server.serve_forever()
