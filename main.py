import uvicorn
from loguru import logger
from fastapi import FastAPI, Request
from fastapi.responses import FileResponse, HTMLResponse, Response
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://lapis.uno",
        "http://lapis.uno",
        "http://localhost:8000",
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type", "Authorization"],
)

app.mount('/static', StaticFiles(directory='static'), name='static')

templates = Jinja2Templates(directory='templates')

def current_year() -> int:
    return int(datetime.now().year)


@app.get('/favicon.ico', response_class=FileResponse)
async def favicon(request: Request) -> Response:
    return FileResponse(path='static/images/favicon.ico')


@app.get('/robots.txt', response_class=FileResponse)
async def robots(request: Request) -> Response:
    return FileResponse(path='static/robots.txt', media_type='text/plain')


@app.get('/sitemap.xml', response_class=FileResponse)
async def sitemap(request: Request) -> Response:
    return FileResponse(path='static/sitemap.xml', media_type='application/xml')


@app.get('/', response_class=HTMLResponse)
async def index(request: Request) -> Response:
    return templates.TemplateResponse(
        name='index.html', context={'request': request, 'current_year': current_year()}
    )

@app.get('/jetton-vanity-deployer', response_class=HTMLResponse)
async def vanity_deployer(request: Request) -> Response:
    return templates.TemplateResponse(
        name='jetton-vanity-deployer.html', context={'request': request}
    )

if __name__ == '__main__':
    uvicorn.run('main:app', host='0.0.0.0', port=8000, reload=True)
