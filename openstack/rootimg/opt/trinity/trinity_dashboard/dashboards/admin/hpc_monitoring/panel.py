from django.utils.translation import ugettext_lazy as _

import horizon
from openstack_dashboard.dashboards.admin import dashboard


class Monitoring(horizon.Panel):
    name = _("Monitoring")
    slug = 'hpc_monitoring'


dashboard.Admin.register(Monitoring)
