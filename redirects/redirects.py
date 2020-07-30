from fastapi import FastAPI
from starlette.responses import PlainTextResponse, RedirectResponse
from redirects.data import links, DEFAULT_REDIRECT
import logging

log = logging.getLogger(__name__)

app = FastAPI()

@app.get("/")
def list_all():
    return links

@app.get("/{key}")
def get_by_key(key: str):
    try:
        log.warn(f"key={key}, links={links}")
        log.warn(f"links[key]={links[key]}")
        return RedirectResponse(url=str(links[key]))
    except:
        return RedirectResponse(url=DEFAULT_REDIRECT)

def main():
    pass
