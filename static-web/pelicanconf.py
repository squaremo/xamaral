#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = 'Paul Rudin'
SITENAME = 'Xamaral'
SITEURL = 'https://xamaral.com'

PATH = 'content'

TIMEZONE = 'Europe/London'

DEFAULT_LANG = 'en'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Blogroll
LINKS = ()


DEFAULT_PAGINATION = 10

DELETE_OUTPUT_DIRECTORY = True

# Uncomment following line if you want document-relative URLs when developing
RELATIVE_URLS = True

# Following items are often useful when publishing

# DISQUS_SITENAME = ""
# GOOGLE_ANALYTICS = ""

PLUGIN_PATHS = ['./pelican-plugins']
PLUGINS = ['i18n_subsites', 'tag_cloud']
JINJA_ENVIRONMENT = {'extensions': ['jinja2.ext.i18n']}

GITHUB_USER = None
GITHUB_SKIP_FORK = True


TWITTER_USERNAME = 'Paul_Rudin'


THEME = './pelican-themes/pelican-bootstrap3'


SOCIAL = (('Twitter', f'http://twitter.com/{TWITTER_USERNAME}'),
          ('LinkedIn', 'https://www.linkedin.com/in/paul-rudin-530ba240/'),
          ('GitHub', 'https://github.com/PaulRudin/'),)


DISPLAY_TAGS_ON_SIDEBAR = True
DISPLAY_TAGS_INLINE = True


ADDTHIS_PROFILE = 'a-5d0a217704939ce7'
ADDTHIS_FACEBOOK_LIKE = False
ADDTHIS_GOOGLE_PLUSONE = False
