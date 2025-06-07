from http.server import HTTPServer, BaseHTTPRequestHandler
from prometheus_client import start_http_server, Counter

REQUESTS = Counter('http_requests_total', 'Total HTTP requests')

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        REQUESTS.inc()
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Hello, Prometheus is watching!")

if __name__ == "__main__":
    start_http_server(8080)  # Expose metrics here
    server = HTTPServer(('0.0.0.0', 8001), SimpleHandler)  # Your web app
    server.serve_forever()
