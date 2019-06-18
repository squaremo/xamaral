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
