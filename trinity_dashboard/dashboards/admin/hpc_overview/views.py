from django.core.urlresolvers import reverse
from django.utils.translation import ugettext_lazy as _

from horizon import exceptions
from horizon import tables
from horizon.utils import memoized
from horizon import workflows

from openstack_dashboard.api import trinity
from  . import tables as overview_tables
from  . import workflows as overview_workflows


class IndexView(tables.DataTableView):
  table_class=overview_tables.OverviewTable
  template_name='admin/hpc_overview/index.html'

  def get_data(self):
    data=trinity.overview(self.request)
    return data

  def get_context_data(self, **kwargs):
    context = super(IndexView, self).get_context_data(**kwargs)
    hardwares_detail=trinity.hardwares_detail(self.request)
    hardwares={'hardwares':hardwares_detail}
    context.update(hardwares)
    return context

class CreateClusterView(workflows.WorkflowView):
  workflow_class = overview_workflows.CreateCluster

class UpdateClusterView(workflows.WorkflowView):
  workflow_class = overview_workflows.UpdateCluster

  def get_initial(self,**kwargs):
    cluster=self.kwargs['cluster']
    return {'cluster':cluster}
