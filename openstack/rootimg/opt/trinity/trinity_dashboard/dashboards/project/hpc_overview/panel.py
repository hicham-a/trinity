from django.utils.translation import ugettext_lazy as _

import horizon
from openstack_dashboard.dashboards.project import dashboard


class Overview(horizon.Panel):
    name = _("Overview")
    slug = 'hpc_overview'


dashboard.Project.register(Overview)
