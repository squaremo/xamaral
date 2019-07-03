FROM python:3.7.3-stretch AS prod

RUN mkdir /var/lib/isso

WORKDIR /usr/src/app

COPY Pipfile Pipfile.lock ./

RUN pip install pipenv

RUN pipenv install --deploy --system

COPY isso.cfg ./

CMD ["isso", "-c", "./isso.cfg", "run"]
