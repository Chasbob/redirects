import os
import base64
import csv
import logging

log = logging.getLogger(__name__)

LINKS = os.getenv("LINKS")
DEFAULT_REDIRECT = os.getenv("DEFAULT_REDIRECT")

links: dict = {}

def load():
    if LINKS:
        try:
            decoded = base64.decodebytes(str.encode(LINKS))
            for line in decoded.splitlines():
                (key, value) = line.decode("utf-8").split(',')
                links[key] = value
        except:
            with open(LINKS, 'r') as csv:
                for line in csv:
                    (key, value) = line.split(',')
                    links[key] = value

