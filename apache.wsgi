import os
activate_this = os.path.join('/usr/lib/ckan/bin/activate_this.py')
execfile(activate_this, dict(__file__=activate_this))

from paste.deploy import loadapp
import newrelic.agent
newrelic.agent.initialize('/project/newrelic.ini')

config_filepath = '/project/development.ini'
from paste.script.util.logging_config import fileConfig
fileConfig(config_filepath)
application = loadapp('config:%s' % config_filepath)
