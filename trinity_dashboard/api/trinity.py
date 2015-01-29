#import the trinity-python-client
from trinity_client import client as trinity_client 
from openstack_dashboard.api import keystone
#from trinityclient import test as trinity_client

# Should probably use APIDictWrapper from base.

#class ListHardware(object):
#  def __init__(self,request,cluster):
#    attrs=trinityclient(request).clusters.list_hwattrs(cluster)
#    self.type=cluster
#    self.members=[x.strip() for x in attrs['hw-'+cluster]['members'].split(',')]
#    self.amount=len(self.members)
#
#class ListClusters(object):
#  def __init__(self,request,cluster):
#    attrs=trinityclient(request).clusters.list_vcattrs(cluster)
#    self.name=cluster
#    self.members=[x.strip() for x in attrs['vc-'+cluster]['members'].split(',')]
#    self.nodes=len(self.members)
#
#class CreateCluster(object):
#  def __init__(self,request,cluster,nodes):
#    self.cluster=cluster
#    self.nodes=nodes
#    create=trinityclient(request).clusters.allocate(cluster,nodes)
#    if 'success' in create:
#      self.success = True
#    else:
#      self.success = False
#
def trinityclient(request):
  c = trinity_client.Client(username=request.user.username,
                            token=request.user.token.id,
                            tenant=request.user.tenant_name)
  return c


class DictToObject(object):
  def __init__(self,keys,dict,default_keys=[],default_value=None):
    if default_keys:
      for key in default_keys:
        setattr(self,key,dict[key])
    for key in keys:
      if key in dict:
        value=dict[key]
      else:
        value=default_value
      setattr(self,key,value)

def overview(request):
  excluded_tenants=['admin','service']
  c=trinityclient(request)
  hardwares_list=c.hardwares_list()
  clusters_list=c.clusters_list()
  tenants_list,more=keystone.tenant_list(request)
  clusters_detail=c.clusters_detail()
  for tenant in tenants_list:
    if tenant.name not in clusters_list and tenant.name not in excluded_tenants:
      clusters_detail.append({'cluster':tenant.name})
  data=[]
  for cluster in clusters_detail:
    datum=DictToObject(hardwares_list,cluster,default_keys=['cluster'],default_value=0)
    data.append(datum)
  return data  
  
def hardwares_list(request):
  c=trinityclient(request)
  data=c.hardwares_list()
  return data

def clusters_list(request):
  c=trinityclient(request)
  data=c.clusters_list()
  return data
   
def hardwares_detail(request):
  c=trinityclient(request)
  data=c.hardwares_detail()
  return data  

def cluster_hardware(request,cluster=None):
  c=trinityclient(request)
  if not cluster:
    cluster=request.user.tenant_name
  clusters_list=c.clusters_list()
  if cluster not in clusters_list:
    hardwares=[]  
  else:
    hardwares=c.cluster_hardware(cluster)
  data=[]
  for hardware in hardwares:
    datum=type('ClusterHardware',(object,),hardware)
    data.append(datum)
  return data  
 
def cluster_modify(request,data):
  c=trinityclient(request)
  cluster=data['name']
# The cluster keyword is required because it was passed while initializing
# the data
  unused_keys=['cluster','name','login','description']
#  unused_keys=['name','login','description']
  specs={}
  for key,value in data.items():
    if key not in unused_keys:
      specs[key] = value
  modify=c.cluster_modify(cluster,specs)
  return modify['statusOK']
 
def cluster_config(request):
  c=trinityclient(request)
  cluster=request.user.tenant_name
  config=c.cluster_config(cluster)
  data=[]
  for option in config:
    datum=type('ClusterConfig', (object,),option)
    data.append(datum)
  return data 

def load_per_proc(request):
  c=trinityclient(request)
  load=c.load_per_proc()
  return load

def cpu_usage(request):
  c=trinityclient(request)
  usage=c.cpu_usage()
  return usage

def disk_usage(request):
  c=trinityclient(request)
  usage=c.disk_usage()
  return usage

def byte_transfer(request):
  c=trinityclient(request)
  rate=c.byte_transfer()
  return rate

 
   


 
#def list_hardware(request):
#  list_all=trinityclient(request).clusters.list()
#  hardware_list=list_all["hardware"]
#  hardwares=[]
#  for hardware in hardware_list:
#    h_type=ListHardware(request,hardware)
#    hardwares.append(h_type)  
#  return hardwares
#
#def list_clusters(request):
#  list_all=trinityclient(request).clusters.list()
#  cluster_list=list_all["virtual clusters"]
#  clusters=[]
#  for cluster in cluster_list:
#    c_type=ListClusters(request,cluster)
#    clusters.append(c_type)  
#  return clusters
#
#
#def create_cluster(request,cluster,nodes):
#  c = CreateCluster(request,cluster,nodes)
#  return c 
#  
#
#
#def list_hardwares(request):
#  hardwares=['FatNodes','GPU','Generic']
#  return hardwares
#
#def list_overview(request):
#  overview=[{'cluster':'Physics', 'FatNodes': 128,'GPU':32,'Generic': 256}, {'cluster':'Math', 'FatNodes': 64, 'Generic': 512}, {'cluster':'Free Nodes', 'FatNodes': 64, 'Generic': 1024, 'GPU': 128 }]
#  return overview
