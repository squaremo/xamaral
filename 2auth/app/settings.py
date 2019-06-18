from pydantic import BaseSettings


class Settings(BaseSettings):
    db_name = 'hello'
    mongo_uri = 'mongodb://mongo'
