#!/usr/bin/env bash
uvicorn AiCall.app:app --host 0.0.0.0 --port $PORT

