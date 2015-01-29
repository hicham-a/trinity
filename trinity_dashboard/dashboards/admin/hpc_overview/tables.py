from django.utils.translation import ugettext_lazy as _
# should really use collections.OrderedDict
from django.utils.datastructures import SortedDict
from horizon import tables
from openstack_dashboard.api import trinity

class RowClass(object):
  def __init__(self,dict):
    for key in dict:
      setattr(self,key,dict[key])


class CreateCluster(tables.LinkAction):
  name = "create"
  verbose_name = _("Create New Cluster")
  url = "horizon:admin:hpc_overview:create"
  classes = ("btn-launch", "ajax-modal",)

class UpdateCluster(tables.LinkAction):
  name = "update"
  verbose_name = _("Edit Cluster")
  url = "horizon:admin:hpc_overview:update"
  classes = ("ajax-modal", "btn-edit")



def get_type(datum):
  return datum.type

def get_amount(datum):
  return datum.amount

class OverviewTable(tables.DataTable):
#  The first argument in the Column instance creator (the 'transform')
#  is either an attribute of a single item of the iterable 'data' (--> the 
# return value of get_data from the views module) or it can be  the return
# value of a callable.

# This ugly hack is needed because the get_columns method does not seem
# to work as expected and the columns for some reason cannot be assigned
# to dict keys.
#  request=self.request
#  hardwares=api.list_hardwares(request)
#  for hardware in hardwares:
#    column='col_'+hardware
#    exec '%s = tables.Column("%s",verbose_name=_("%s"))' %(column, hardware,hardware)


  def get_columns(self):
    request=self.request
    hardwares=trinity.hardwares_list(self.request)
    columns_unsorted=[]
    cluster=tables.Column('cluster', verbose_name=_(' '))
    cluster.table=self
    columns_unsorted.append(('cluster',cluster))
    for hardware in hardwares:
      key=hardware
      value=tables.Column(hardware, verbose_name=_(hardware), summation='sum')
      value.table=self
      columns_unsorted.append((key,value))
    for key, value in self.columns.items():
      columns_unsorted.append((key,value))
    self.columns=SortedDict(columns_unsorted)
    return self.columns.values() 
 
  def get_object_id(self,datum):
    return datum.cluster

#  def get_row_actions(self,datum):
#    if datum.cluster=="Free Nodes":
#      return []
#    else:
#      return self._meta.row_actions

  class Meta:
    name = "hpc_overview"
    verbose_name = _("Cluster Allocation Overview ")
    row_actions = (UpdateCluster,)
#    table_actions = (CreateCluster,)
    multi_select  = False
