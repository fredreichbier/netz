from flup.client.scgi_app import SCGIApp
from wsgiref.simple_server import make_server

application = SCGIApp(connect=('127.0.0.1', 4001))
httpd = make_server('', 8008, application)
print 'Serving HTTP on port 8008 ...'
httpd.serve_forever()

