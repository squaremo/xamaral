FROM thomasweise/texlive AS tex

ARG GIT_SHA
ENV GIT_SHA=$GIT_SHA


COPY . /app

WORKDIR /app

RUN make tex/cv.pdf

FROM python:3.7.3-stretch AS py

COPY --from=tex /app /app

WORKDIR /app

RUN pip install pipenv

RUN pipenv install --deploy --system

RUN make html

FROM nginx:1.17.0

COPY --from=tex /app/output /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf



