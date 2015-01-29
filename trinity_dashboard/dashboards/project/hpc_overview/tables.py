from django.utils.translation import ugettext_lazy as _

from horizon import tables

#class HardwareTable(tables.DataTable):
#    type=tables.Column("type", verbose_name=_("Type"))
#    amount=tables.Column("amount",verbose_name=_("Amount"))
#
#    class Meta:
#        name = "hpc_hardware"
#        verbose_name = _("Overview of the HPC hardware ")
#


class HardwareTable(tables.DataTable):
  type = tables.Column('type', verbose_name=_("Node Type"))
  amount = tables.Column('amount', verbose_name=_("Amount"))

  def get_object_id(self,obj):
    return obj.type
    
  class Meta:
    name = "hpc_hardware"
    verbose_name = _("Overview of the HPC hardware ")


class EditAction(tables.LinkAction):
  name = "edit"
  verbose_name = _("Edit HPC configuration")
  url = "horizon:project:hpc_overview:edit"
  classes = ("btn-launch", "ajax-modal")

class ConfigTable(tables.DataTable):
  param = tables.Column('param',verbose_name=_(" "))
  value = tables.Column('value',verbose_name=_(" "))

  def get_object_id(self,obj):
    return obj.param

  class Meta:
    name = "hpc_config"
    verbose_name = _("Current HPC configuration")
    table_actions=(EditAction,)
    multi_select = False



