Title: Creating a Web Api with Aiohttp and Mongo
Date: 2019-06-17
Tags: python, asyncio, aiohttp, mongodb, docker, docker-compose

Here's a "hello world" python async web api using aiohttp, with mongodb as a
persistence layer. I've skipped lots of essential features (logging, error
handling, tests, endpoint security) - this is just to show how to get a minimal
working example.

If you want to follow along and run all of this you'll need docker,
docker-compose, python3.7 or later, pip and pipenv. I've only tested on ubuntu 18.04, but probably
everything will work as long as docker works.

You can get all of the code from github - note the tag which references code as
show below. I'll continue to work on this, so the current version will differ.


1. Create the directory structure and a package file.

        :::sh
        $ mkdir -p 2auth/app; cd 2auth; touch app/__init__.py


1. Install required packages in a virtual environment.

        :::sh
        $ pipenv --python=3.7 install aiohttp motor pydantic
 
1. Install some dev only dependencies.

        :::sh
        $ pipenv install aiohttp-devtools pytest --dev
   
1. Activate the virtual environment.

        :::sh
        $ pipenv shell


1. Make settings.py as follows. `pydantic.BaseSettings` allows validation of
   data and overriding settings via environment variables.
   
        :::python 
        from pydantic import BaseSettings

        class Settings(BaseSettings):
            db_name = 'hello'
            mongo_uri = 'mongodb://mongo'
 


1. Make models.py as follows. The purpose of this exercise is just to get
   everything working end to end, so the exact structure of the model(s) is not
   important. Again, we're using pydantic for the validation.

        :::python
        
        from pydantic import BaseModel


        class User(BaseModel):
            id: int
            name: str

            @staticmethod
            async def get_by_id(db, user_id):
                user = await db.users.find_one({'id': int(user_id)})

                #remove the mongo created id for simplicity
                del(user['_id'])
                return user

            @staticmethod
            async def create(db, data):
                # this validates the data before we insert into the db
                user = User(**data)
                await db.users.insert_one(data)
                return user.id

1. `mongo.py` creates a connection to a mongodb server and makes it available
    elsewhere by adding it to the aiohttp app. Motor has asyncio event loop
    integration for accessing mongodb.

        :::python
        from motor import motor_asyncio


        async def create_mongo(app):
            s = app['settings']
            db = motor_asyncio.AsyncIOMotorClient(s.mongo_uri)[s.db_name]
            app['mongo'] = db


        async def close_mongo(app):
            pass


        def setup(app):
            app.on_startup.append(create_mongo)
            app.on_cleanup.append(close_mongo)

1. `views.py` connects our model with the aiohttp web framework.
 
        :::python
        from aiohttp import web

        from models import User


        class UserView(web.View):

        async def get(self):
            user = await User.get_by_id(
            self.request.app['mongo'], self.request.query['id'])

            if user:
                return web.json_response(user)

            return web.HTTPNotFound(text=f'User with id: {user_id}')

        async def post(self):
            body = await self.request.json()
            user_id = await User.create(self.request.app['mongo'], body)
            return web.HTTPCreated(text=f'User: {user_id}')


1. `app.py` brings everything together and provides an entry point to the web
   application.


        :::python
        from aiohttp import web

        from settings import Settings
        from views import UserView
        import mongo
        def setup_routes(app):
            app.router.add_view('/users', UserView)

        def make_app():
            app = web.Application()
            app['settings'] = Settings()
            setup_routes(app)
            mongo.setup(app)
            return app

        def main():
            app = make_app()
            web.run_app(app)

        if __name__ == '__main__':
            main()


1. At this point we have a working web application, but no mongo database to
   connect it do. We can do this with docker compose, so we'll need a
   Dockerfile for the application. Change back to the project's root directory.
   
        :::sh
        $ cd ..
         
1. Create Dockerfile.

        :::docker
        FROM python:3.7.3-stretch AS prod

        WORKDIR /usr/src/app

        COPY Pipfile Pipfile.lock ./

        RUN pip install pipenv

        RUN pipenv install --deploy --system

        COPY app /usr/src/app

        CMD ["python", "./app.py"]

        FROM prod AS dev

        RUN pipenv install --dev --system

        CMD ["adev", "runserver", "--app-factory", "make_app", "app.py"]

    We have two stages: the first is the working web application; the second
    adds a development web server that auto-reloads on changes, which is handy
    for development (but should not be used in production for both efficiency
    and security reasons).

1. A Makefile saves a bit of typing:

        :::basemake
        GIT_SHA := $(shell git rev-parse --short HEAD)

        docker:
	        docker build . --target prod -t 2auth:latest

        docker-dev:
	        docker build . --target dev -t 2auth-dev:latest

        .PHONY: docker docker-dev

    We can now build the development image:
    
        :::sh
        $ make docker-dev
         
1. Now we're ready to bring the web app and a mongodb instance up using the
   following docker-compose.yml.
   
        :::yaml
        # just for local dev
        version: "3.7"

        x-mongo-env: &mongo-env
          ME_CONFIG_MONGODB_ADMINUSERNAME: root
          ME_CONFIG_MONGODB_ADMINUSERNAME: example

        services:

          2auth:
            image: 2auth-dev
            volumes:
              - ./app:/usr/src/app
            ports:
              - 8080:8000

          mongo: 
            image: mongo
            environment: *mongo-env

          mongo-express:
            image: mongo-express
            ports:
              - 8081:8081
            environment: *mongo-env

    We can bring everything up with docker-compose:
         
        :::sh
        docker-compose up -d
         
    Check that everything is running OK:

        :::sh
        $ docker-compose ps
        Name                       Command               State           Ports         
        ---------------------------------------------------------------------------------------
        2auth_2auth_1           adev runserver --app-facto ...   Up      0.0.0.0:8080->8000/tcp
        2auth_mongo-express_1   tini -- /docker-entrypoint ...   Up      0.0.0.0:8081->8081/tcp
        2auth_mongo_1           docker-entrypoint.sh mongod      Up      27017/tcp       

    
    If there's anything other than "Up" in the "State" column, then this will
    need to be fixed. `docker-compose logs` may help identify the problem.
    
    
1. Now we can create a new user:

        :::sh
        $ curl localhost:8080/users --data '{"id": 2, "name": "Alice"}'
        User: 2
        
    And query to get back the the user:
    
        :::sh
        $ curl -w "\n" 'localhost:8080/users?id=1'
        {"id": 1, "name": "Alice"}
