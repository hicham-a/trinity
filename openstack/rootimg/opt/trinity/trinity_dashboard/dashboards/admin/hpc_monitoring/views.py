import json

from django.views.generic import TemplateView
from django.core.urlresolvers import reverse
from django.utils.translation import ugettext_lazy as _

from horizon import exceptions
from horizon import tables
from horizon.utils import memoized
from horizon import workflows

from openstack_dashboard.api import trinity
from  . import tables as monitoring_tables

class IndexView(TemplateView):
  template_name='admin/hpc_monitoring/index.html'
  def get_context_data(self, **kwargs):
    context = super(IndexView, self).get_context_data(**kwargs)
    request=self.request
    mon_info=trinity.monitoring_info(request)
    context.update(mon_info) 
    return context

