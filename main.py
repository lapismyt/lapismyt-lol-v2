import uvicorn
from loguru import logger
from fastapi import FastAPI, Request
from fastapi.responses import FileResponse, HTMLResponse, Response
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from datetime import datetime

app = FastAPI()

app.mount('/static', StaticFiles(directory='static'), name='static')

templates = Jinja2Templates(directory='templates')


def current_year() -> int:
    return int(datetime.now().year)


@app.get('/favicon.ico', response_class=FileResponse)
async def favicon(request: Request) -> Response:
    return FileResponse(path='static/images/favicon.ico')


@app.get('/', response_class=HTMLResponse)
async def read_item(request: Request) -> Response:
    return templates.TemplateResponse(
        name='index.html', context={'request': request, 'current_year': current_year()}
    )

if __name__ == '__main__':
    uvicorn.run('main:app', host='0.0.0.0', port=8000, reload=True)