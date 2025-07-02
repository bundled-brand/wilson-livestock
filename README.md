# Wilson Livestock Static Site Server

This directory contains a static version of the Wilson Livestock website along with a Rack configuration to serve it locally.

## Starting the Server

To start the local development server:

```bash
# Start the Rack server (default port 9292)
rackup

# Or specify a different port
rackup -p 3000

# Or bind to all interfaces
rackup -o 0.0.0.0 -p 3000
```
