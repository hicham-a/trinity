#!/usr/bin/env python
from distutils.core import setup

setup ( 
  name='Trinity-API',
  version='0.1.0',
  description='Trinity HPC server',
  url='http://www.clustervision.com',
  author='Abhishek Mukherjee',
  author_email='abhishek.mukherjee@clustervision.com',
  packages=['trinity_api'],
  package_dir={'trinity_api':'src'},
  scripts=['bin/trinity_api','bin/wrapper_trinity_api'],
  data_files=[
    ('/etc/init.d',['init/trinity_api']),
    ('/etc/trinity',['conf/trinity_api.conf'])
  ]
)
