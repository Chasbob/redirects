#!/bin/sh

poetry run uvicorn redirects:app \
    --host 0.0.0.0 \
    --port 80 \
    --use-colors \
    $(test "$DEBUG" && echo "--reload")
