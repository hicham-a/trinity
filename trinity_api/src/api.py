import os
import shutil
from ConfigParser import SafeConfigParser
from bottle import Bottle,get,put,post,delete,run,request,response,abort
import json
import requests
from collections import defaultdict
import re
#from config import *

conf_file='/etc/trinity/trinity_api.conf'
config=SafeConfigParser()
config.read(conf_file)
trinity_host=config.get('trinity','trinity_host')
trinity_port=config.getint('trinity','trinity_port')
trinity_debug=config.getboolean('trinity','trinity_debug')

class TrinityAPI(object):
  def __init__(self,request):
    self.request=request
    self.has_authenticated=False
    self.config(conf_file)
    self.tenant=self.request.get_header('X-Tenant',default=None)
    self.token=self.request.get_header('X-Auth-Token',default=None)
    self.set_attrs_from_json()
    # This is a hack to allow for username/password based authentication for get requests during testing
    if (not (self.token or hasattr(self,'password'))) and self.request.auth:
      (self.username,self.password)=self.request.auth
    self.errors()
    self.query = {'userName':self.trinity_user, 'password':self.trinity_password, 'pretty':'1'}
    self.headers={"Content-Type":"application/json", "Accept":"application/json"} # setting this by hand for now
    self.authenticate()    

  def config(self,file):
    config=SafeConfigParser()
    config.read(file)
    for section in config.sections():
      for option in config.options(section):
        value=config.get(section,option)
        setattr(self,option,value)
    # special for the non-strings
    #self.trinity_port=config.getint('trinity','trinity_port')
    #self.trinity_debug=config.getboolean('trinity','trinity_debug')  

  # Get value for a given key from the JSON body of request  
  def set_attrs_from_json(self):
    body_dict=self.request.json
    if body_dict:
      for key in body_dict:
        setattr(self,key,body_dict[key])

  def errors(self):
    self.no_access='Access denied!'
    self.not_admin='Only admin has permission!'
    self.no_nodes='Not enough resources!'
    self.xcat_error='xCAT error'

  
 # Authenticate against Keystone. 
  def authenticate(self):
    if self.has_authenticated: 
      return
    if self.token:
      payload = { 
                  "auth": {
                    "tenantName": self.tenant,
                    "token": {
                      "id": self.token
                    }
                  }
                }
    else:
      payload = { 
                  "auth": {
                    "tenantName": self.tenant,
                    "passwordCredentials": {
                      "username": self.username,
                      "password": self.password
                    }
                  }
                }
  
    r = requests.post(self.keystone_host+'/tokens', data=json.dumps(payload), headers=self.headers)
    self.has_access = (r.status_code  == requests.codes.ok )
    if self.has_access: 
      self.has_authenticated=True
      body = r.json()
      # self.is_admin = body["access"]["metadata"]["is_admin"]
      # This is a hack to get around a bug in Keystone
      self.is_admin = (body['access']['user']['name'] == 'admin')
      self.token = body["access"]["token"]["id"]

  # xCAT API request
  def xcat(self,verb='GET',path='/',payload={}):
    methods={'GET': requests.get, 'POST': requests.post, 'PUT': requests.put, 'DELETE': requests.delete}
    r=methods[verb](self.xcat_host+path,verify=False,params=self.query,headers=self.headers,data=json.dumps(payload))
    try:
      return r.json()  
    except:
      return {}
####################################################
   
  def groups(self,name='groups',startkey=''):
    self.authenticate()
    status_ok=False
    groups=[]
    if self.has_access and self.is_admin:
      xcat_groups=self.xcat('GET','/groups')
      l=len(startkey)
      for group in xcat_groups:
        if group.startswith(startkey):
          groups.append(group[l:])  
      status_ok=True
    return {'statusOK':status_ok, name:groups}
   
  def nodes(self):
    self.authenticate()
    status_ok=False
    nodes=[]
    if self.has_access and self.is_admin:
      nodes=self.xcat('GET','/nodes')
      status_ok=True
    return {'statusOK':status_ok,'nodes':nodes}
  
  def node_info(self,node):
    self.authenticate()
    status_ok=False
    if self.has_access :
      xcat_node=self.xcat('GET','/nodes/'+node)
      info={'hardware': None, 'cluster': None}
      lhw=len(self.hw)
      lvc=len(self.vc)
      members=xcat_node[node]['groups'].strip()
      groups=[]
      if members: groups=[x.strip() for x in members.split(',')]
      for group in groups:
      # Assumes that the node is only a part of one hw and one vc 
        if group.startswith(self.hw): 
          info['hardware']=group[lhw:] 
        if group.startswith(self.vc): 
          info['cluster']=group[lvc:]
      status_ok=True
      info['statusOK']=status_ok
    return info
     
  def group_nodes(self,name,startkey=''):
    self.authenticate()
    status_ok=False
    nodes=[]
    group_name=startkey+name
    if self.has_access:
      xcat_nodes=self.xcat('GET','/groups/'+group_name+'/attrs/members')
      members=xcat_nodes[group_name]['members'].strip()
      nodes=[]
      # Hack because of unicode
      if members: nodes=[x.strip() for x in members.split(',')]
      status_ok=True
    return  {'statusOK':status_ok, 'nodes' : nodes}
  
  def cluster_nodes(self,cluster):
    self.authenticate()
    ret={}
    ret['statusOK']=False
    if not (self.is_admin or self.tenant==cluster):
      return ret
    nodes=self.group_nodes(startkey=self.vc,name=cluster)
    ret['statusOK']=nodes['statusOK']
    if not ret['statusOK']:
      return ret
    ret['hardware']=defaultdict(int)
    for node in nodes['nodes']:
      info=self.node_info(node)
      if info['statusOK']:
        ret['hardware'][info['hardware']]+=1
    return ret    

  # this is not DRY
  def cluster_details(self,cluster): 
    self.authenticate()
    ret={}
    ret['statusOK']=False
    if not (self.is_admin or self.tenant==cluster):
      return ret
    nodes=self.group_nodes(startkey=self.vc,name=cluster)
    ret['statusOK']=nodes['statusOK']
    if not ret['statusOK']:
      return ret
    ret['hardware']=defaultdict(list)
    for node in nodes['nodes']:
      info=self.node_info(node)
      if info['statusOK']:
        ret['hardware'][info['hardware']].append(node)
    return ret    

  def hardware_nodes(self,hardware):
    self.authenticate()
    ret={}
    ret['statusOK']=False
    if not (self.is_admin):
      return ret
    nodes=self.group_nodes(startkey=self.hw,name=hardware)
    ret['statusOK']=nodes['statusOK']
    if not ret['statusOK']:
      return ret
    ret['total']=len(nodes['nodes'])
    ret['allocated']=0
    ret['list_unallocated']=[]
    for node in nodes['nodes']:
      info=self.node_info(node)
      if info['cluster']:
        ret['allocated']+=1
      else:
        ret['list_unallocated'].append(node)
    ret['unallocated']=ret['total']-ret['allocated']
    return ret    

  def cluster_change_nodes(self,cluster,old_list,hw_dict):
    self.authenticate()
    ret={}
    ret['statusOK']=False
    xcat_cluster=self.vc+cluster
    if not(self.has_access and self.is_admin):
      return ret 
    node_list=old_list[:]
    subs_list=[]
    adds_list=[]
    for hardware in hw_dict:
      if hardware not in self.specs:
        for node in hw_dict[hardware]:
          node_list.remove(node)
          subs_list.append(node)
    for hardware in self.specs:
      d_nodes=self.specs[hardware]
      if hardware in hw_dict:
        e_nodes=hw_dict[hardware]
        if len(e_nodes) == d_nodes: 
          continue
        elif len(e_nodes) > d_nodes:
          sub_num=len(e_nodes)-d_nodes
          subs=e_nodes[-sub_num:]
          for node in subs:
            node_list.remove(node)
            subs_list.append(node)
        else:
          add_num=d_nodes-len(e_nodes)
          h_nodes=self.hardware_nodes(hardware)
          if add_num > h_nodes['unallocated']:
            ret['error']=self.no_nodes
            return ret
          else:
            for node in h_nodes['list_unallocated'][:add_num]:
              node_list.append(node)
              adds_list.append(node)
      else:
        h_nodes=self.hardware_nodes(hardware)
# Not DRY
        if d_nodes > h_nodes['unallocated']:
          ret['error']=self.no_nodes
          return ret
        else:
          for node in h_nodes['list_unallocated'][:d_nodes]:
            node_list.append(node)
            adds_list.append(node)
    if adds_list or subs_list:
      ret['change']=True
      if node_list:
        node_string=",".join(node_list)
        payload={'members': node_string}
        r=self.xcat(verb='PUT',path='/groups/'+xcat_cluster,payload=payload)
      else:
      # workaround for empty nodelist (deleting cluster)
      # Note: the group definition will still survive
        node_string=old_list[0]
        last_node=old_list[0]
        payload={'members': node_string}
        r=self.xcat(verb='PUT',path='/groups/'+xcat_cluster,payload=payload)
        r=self.xcat(verb='GET',path='/nodes/'+last_node+'/attrs/groups')
        node_groups=r[last_node]["groups"]
        node_groups_list=node_groups.strip().split(",")
        node_groups_list.remove(xcat_cluster)
        node_groups=",".join(node_groups_list)
        payload={"groups":node_groups}
        r=self.xcat(verb='PUT',path='/nodes/'+last_node,payload=payload)
        
#        r=self.xcat(verb='DELETE',path='/nodes/'+xcat_cluster)
        
      if hasattr(r,'status_code'):   
        if r.status_code == requests.codes.ok:
          ret['statusOK']=True
        else:
          ret['statusOK']=False
          ret['error']=self.xcat_error
      else:
        ret['statusOK']=True
    else:
      ret['statusOK']=True
      ret['change']=False
    ret['nodeList']= node_list   
    return ret
   
#  def cluster_update_containers(cluster,new_container_image):
#    self.authenticate()
#    ret={}
#    ret['statusOK']=False
#    if not(self.has_access and (self.is_admin or self.tenant == cluster)):
#      return ret
#    node_list=self.group_nodes(name=cluster, startkey=self.vc)
    
     

######################################################################### 

trinity = Bottle()

@trinity.get('/trinity/v<version:float>/')
def welcome(version=1):
#  req=TrinityAPI(request)
  return "Welcome to the Trinity API"

@trinity.get('/trinity/v<version:float>/version')
def version(version=1):
  fop=open('/trinity/version','r')
  lines=fop.readlines()
  fop.close()
  branch=lines[0].strip().split()[1]
  id=lines[1].strip().split()[0]
  id_branch = id + ' ('+branch+')'
  return {'versionID (releaseBranch)':id_branch }

@trinity.post('/trinity/v<version:float>/login')
def login(version=1):
  req=TrinityAPI(request)
  if req.has_access:
    response.status=200
    return {'token': req.token}
  else:
    response.status=401
    return

@trinity.get('/trinity/v<version:float>/clusters')
def list_clusters(version=1):
  req=TrinityAPI(request)
  return req.groups(name='clusters',startkey=req.vc)

@trinity.get('/trinity/v<version:float>/hardwares')
def list_hardwares(version=1):
  req=TrinityAPI(request)
  return req.groups(name='hardwares',startkey=req.hw)

@trinity.get('/trinity/v<version:float>/nodes')
def list_nodes(version=1):
  req=TrinityAPI(request)
  return req.nodes()

@trinity.get('/trinity/v<version:float>/nodes/<node>')
def show_node(node,version=1):
  req=TrinityAPI(request)
  # We do an authentication here because the object method is 
  # need by non-admin calls too
  req.authenticate()
  if req.is_admin:
    return req.node_info(node)
  else:
    return {'error':req.not_admin}

@trinity.get('/trinity/v<version:float>/clusters/<cluster>')
def show_cluster(cluster,version=1):
  req=TrinityAPI(request)
  return req.cluster_nodes(cluster)    

@trinity.get('/trinity/v<version:float>/hardwares/<hardware>')
def show_hardware(hardware,version=1):
  req=TrinityAPI(request)
  return req.hardware_nodes(hardware)

@trinity.get('/trinity/v<version:float>/clusters/<cluster>/hardware')
def show_hardware_details(cluster,version=1):
  req=TrinityAPI(request)
  return req.cluster_details(cluster)


# This is used for both create and modify
@trinity.put('/trinity/v<version:float>/clusters/<cluster>')
def modify_cluster(cluster,version=1):
  req=TrinityAPI(request)
  ret={}
  ret['statusOK']=False
  clusters=req.groups(name='clusters',startkey=req.vc)
  if not clusters['statusOK']:
    return ret
  if cluster in clusters['clusters']:
    ret=update_cluster(req,cluster)
    slurm_needs_update=False
    if ret['statusOK']:
      if ret['change']:
        slurm_needs_update=True
  else:
    ret=create_cluster(req,cluster)
    if ret['statusOK']:
      src_root=req.cluster_path
      dest_root=os.path.join(req.cluster_path,
                             req.clusters_dir,
                             cluster)
      excludes=[req.clusters_dir]
      copy_with_excludes(src_root,dest_root,excludes)
      slurm_needs_update=True 
  
  cont_list=[]
  if slurm_needs_update:
    for node in ret['nodeList']:
      cont=node.replace(req.node_pref,req.cont_pref)
      cont_list.append(cont) 
    cont_string=','.join(cont_list)
    slurm=os.path.join(req.cluster_path,
                       req.clusters_dir,
                       cluster,
                       req.slurm_node_file)
    part_string='PartitionName='+req.cont_part+' Nodes='+cont_string+' Default=Yes'
    changes={'NodeName':'NodeName='+cont_string,
             'PartitionName':part_string}
    replace_lines(slurm,changes)
#    conf_update(slurm,'NodeName',cont_string,sep='=')
#    conf_update(slurm,'PartitionName',req.cont_part+' Nodes='+cont_string+' Default=Yes',sep='=')
  return ret



# Helper functions

def create_cluster(req,cluster):
  old_list=[]
  hw_dict={}
  ret=req.cluster_change_nodes(cluster,old_list,hw_dict)
  return ret

def update_cluster(req,cluster):
  ret={}; ret['statusOK']=False
  r=req.group_nodes(name=cluster,startkey=req.vc) 
  if not r['statusOK']: return ret
  old_list=r['nodes']
  r=req.cluster_details(cluster)
  hw_dict=r['hardware']
  ret=req.cluster_change_nodes(cluster,old_list,hw_dict)
  return ret 

def copy_with_excludes(src_root,dest_root,excludes=[]):
  copy_list=os.listdir(src_root)
  for exclude in excludes:
    if exclude in copy_list:
      copy_list.remove(exclude)
  if not os.path.isdir(dest_root):
    os.makedirs(dest_root) 
  for file in copy_list:
    src=os.path.join(src_root,file)
    dest=os.path.join(dest_root,file)
    if os.path.isdir(src):
      if os.path.isdir(dest):
        shutil.rmtree(dest)
      shutil.copytree(src,dest)
    else:
      shutil.copy2(src,dest)

def replace_lines(conf_file,changes):
  fop=open(conf_file,'r')
  lines=fop.readlines()
  fop.close()
  new_lines=[]
  for line in lines:
    new_line=line.strip()
    for startkey in changes:
      if new_line.startswith(startkey):
        new_line=changes[startkey]
    new_lines.append(new_line) 
  new_conf_file="\n".join(new_lines)
  fop=open(conf_file,'w')
  fop.write(new_conf_file)
  fop.close()

def conf_update(conf_file,key,value,sep='='):
  fop=open(conf_file,'r')
  lines=fop.readlines()
  fop.close()
  new_lines=[]
  for line in lines:
    items=line.strip().split(sep,2)
    new_line=line.strip()
    line_key=items[0].strip()
    if len(items) == 2 and line_key==key: 
      new_line=key+sep+value
    new_lines.append(new_line) 
  new_conf_file="\n".join(new_lines)
  fop=open(conf_file,'w')
  fop.write(new_conf_file)
  fop.close()



if __name__=="__main__":
  trinity.run(host=trinity_host, port=trinity_port, debug=trinity_debug)
