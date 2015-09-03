from django.core.urlresolvers import reverse
from django.utils.translation import ugettext_lazy as _

from horizon import exceptions
from horizon import tables
from horizon.utils import memoized
from horizon import workflows

from openstack_dashboard.api import trinity

from  . import tables as overview_tables
from  . import workflows as overview_workflows



#class IndexView(tables.DataTableView):
#  table_class=hardware_tables.HardwareTable
#  template_name='project/hpc_hardware/index.html'
#
#  def get_data(self):
#    return []

class IndexView(tables.MultiTableView):
  table_classes = (overview_tables.HardwareTable,
                   overview_tables.ConfigTable,)
  template_name = 'project/hpc_overview/index.html'

  def get_hpc_hardware_data(self):
    request=self.request
    data=trinity.cluster_hardware(request)
    return data

  def get_hpc_config_data(self):
    request=self.request
    data=trinity.cluster_config(request)
    return data

class EditView(workflows.WorkflowView):
  workflow_class = overview_workflows.EditCluster


