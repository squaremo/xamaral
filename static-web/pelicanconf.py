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

# Uncomment following line if you want document-relative URLs when developing
RELATIVE_URLS = True

FEED_ALL_ATOM = 'feeds/all.atom.xml'
CATEGORY_FEED_ATOM = 'feeds/{slug}.atom.xml'

DELETE_OUTPUT_DIRECTORY = True

# Following items are often useful when publishing

#DISQUS_SITENAME = ""
#GOOGLE_ANALYTICS = ""

PLUGIN_PATHS = ['./pelican-plugins']
PLUGINS = ['i18n_subsites']
JINJA_ENVIRONMENT = {'extensions': ['jinja2.ext.i18n']}

github_root = 'https://github.com/PaulRudin'
# GITHUB_URL = github_root

TWITTER_USERNAME = 'Paul_Rudin'
THEME = './pelican-themes/pelican-bootstrap3'
BOOTSTRAP_THEME = 'cyborg'

SOCIAL = (('Twitter', f'http://twitter.com/{TWITTER_USERNAME}'),
          ('LinkedIn', 'https://www.linkedin.com/in/paul-rudin-530ba240/'),
          ('GitHub', github_root),)
