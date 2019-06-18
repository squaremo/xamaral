from datetime import datetime
from typing import List
from pydantic import BaseModel


class User(BaseModel):
    id: int
    name: str

    @staticmethod
    async def get_by_id(db, user_id):
        user = await db.users.find_one({'id': int(user_id)})

        #remove the mongo created id for simplicity for now
        del(user['_id'])
        return user

    @staticmethod
    async def create(db, data):
        # this validates the data before we insert into the db
        user = User(**data)
        await db.users.insert_one(data)
        return user.id
