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
