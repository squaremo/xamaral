Title: Creating a Web Api with Aiohttp and Mongo
Date: 2019-06-17

Here's a "hello world" python async web api using aiohttp, with mongodb as a
persistence layer. I'm using this as the start of an authentication server,
hence the directory name. (Don't use this code unmodified as there's no
authentication - anyone with access to the endpoint can make modifications to
your data.)


1. Create the directory structure:

        :::sh
        $ mkdir -p 2auth/app; cd 2auth


1. Install required packages in a virtual environment.

        :::sh
        $ pipenv --python=3.7 install aiohttp motor pydantic
 
1. Install some dev dependencies.

        :::sh
        $ pipenv install aiohttp-devtools pytest --dev
   
1. Activate the virtual environment.

        :::sh
        $ pipenv shell


1. Make settings.py as follows.
   
        :::python 
          


1. Make models.py as follows. In this example I'm assuming a single User
   Model (taken from the pydantic docs).

        :::python
        from datetime import datetime
        from typing import List
        from pydantic import BaseModel

        class User(BaseModel):
            id: int
            name: 'Fred Blogs'
            signup_ts: datetime 
            friends: List[int] = []

1. Make mongo.py as follows.


1. Make app.py as follows.


        :::python
         
