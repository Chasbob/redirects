FROM python:3-alpine AS POETRY
ADD https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py /bin/get-poetry

ARG POETRY_HOME=/etc/poetry
ARG POETRY_VERSION=1.0.5
RUN python /bin/get-poetry

WORKDIR /poetry
COPY ./pyproject.toml ./poetry.lock ./
RUN /etc/poetry/bin/poetry export -f requirements.txt > requirements.txt

FROM tiangolo/uvicorn-gunicorn-fastapi:python3.8-alpine3.10 AS BUILD

WORKDIR /opt/redirects

COPY --from=poetry /poetry/requirements.txt .

RUN pip install -r /opt/redirects/requirements.txt

COPY . /opt/redirects

EXPOSE 80

ENV APP_MODULE=redirects:app
