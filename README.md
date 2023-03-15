Kong Plugin with [MockServer](https://mock-server.com)
======================================================

This is an example plugin (a modified version of the [kong-plugin](https://github.com/Kong/kong-plugin) template) that uses pongo + MockServer to perform integration testing.

The following files have been added/modified:

`.pongo/pongorc` - added mockserver so pongo will start the container

`.pongo/mockserver.yml` - the mockserver docker-compose config, which mounts init.json

`.pongo/init.json` - this gets loaded when mockserver starts, and creates the expectations for our mock service
