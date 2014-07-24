#!/bin/bash

echo "Compiling coffee script files..."
sudo coffee --join js/app.js --compile coffee/main.coffee

#./scripts/compress.sh
#./scripts/docco.sh

echo "Done."