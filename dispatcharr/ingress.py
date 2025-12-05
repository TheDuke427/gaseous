#!/usr/bin/env python3
"""
Home Assistant Ingress Proxy for Dispatcharr
Handles X-Ingress-Path header and rewrites URLs for HA ingress
"""

import os
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler
import urllib.request
import urllib.error

BACKEND_PORT = 8000
INGRESS_PORT = 9500

class IngressProxyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.proxy_request()
    
    def do_POST(self):
        self.proxy_request()
    
    def do_PUT(self):
        self.proxy_request()
    
    def do_DELETE(self):
        self.proxy_request()
    
    def do_PATCH(self):
        self.proxy_request()
    
    def proxy_request(self):
        # Get ingress path from header
        ingress_path = self.headers.get('X-Ingress-Path', '')
        
        # Build backend URL
        backend_url = f'http://localhost:{BACKEND_PORT}{self.path}'
        
        # Read request body
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length) if content_length > 0 else None
        
        # Create request
        req = urllib.request.Request(backend_url, data=body, method=self.command)
        
        # Copy headers
        for key, value in self.headers.items():
            if key.lower() not in ['host', 'content-length']:
                req.add_header(key, value)
        
        try:
            # Make request to backend
            with urllib.request.urlopen(req, timeout=30) as response:
                # Send response
                self.send_response(response.status)
                
                # Copy response headers
                for key, value in response.headers.items():
                    if key.lower() not in ['transfer-encoding', 'connection']:
                        self.send_header(key, value)
                
                self.end_headers()
                
                # Send response body
                self.wfile.write(response.read())
        
        except urllib.error.HTTPError as e:
            self.send_response(e.code)
            self.end_headers()
            self.wfile.write(e.read())
        
        except Exception as e:
            self.send_response(502)
            self.end_headers()
            self.wfile.write(f'Bad Gateway: {str(e)}'.encode())
    
    def log_message(self, format, *args):
        # Suppress default logging
        pass

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', INGRESS_PORT), IngressProxyHandler)
    print(f'Ingress proxy listening on port {INGRESS_PORT}')
    server.serve_forever()
