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
trinity_server=config.get('trinity','trinity_server')

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
    self.is_admin=False
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
    if self.has_access: # and self.is_admin:
      xcat_groups=self.xcat('GET','/groups')
      l=len(startkey)
      for group in xcat_groups:
        if group.startswith(startkey):
          groups.append(group[l:])  
      status_ok=True
    return {'statusOK':status_ok, name:groups}
  
  def detailed_overview(self):
    xcat_groups=self.xcat('GET','/groups')
    hc_list=[]
    for group in xcat_groups:
      if group.startswith(self.hw): hc_list.append(group)
      if group.startswith(self.vc): hc_list.append(group)
    hc_string=",".join(hc_list)
    xcat_overview=self.xcat('GET','/groups/'+hc_string+'/attrs/members')
    hc_overview={'hardware':{},'cluster':{}}
    lhw=len(self.hw)
    lvc=len(self.vc)
    for hc in xcat_overview:
      if hc.startswith(self.hw): 
        hardware=hc[lhw:]
        members=xcat_overview[hc]['members'].strip()
        node_list=[]
        if members: node_list=[x.strip() for x in members.split(',')]
        hc_overview['hardware'][hardware]=node_list
      if hc.startswith(self.vc): 
        cluster=hc[lvc:]
        members=xcat_overview[hc]['members'].strip()
        node_list=[]
        if members: node_list=[x.strip() for x in members.split(',')]
        hc_overview['cluster'][cluster]=node_list
    self.overview=hc_overview
    return hc_overview

 
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
   
  def nodes_info(self, node_list):
    node_string=",".join(node_list)
    xcat_nodes=self.xcat('GET','/nodes/'+node_string)
#    info={'hardware': None, 'cluster': None}
    lhw=len(self.hw)
    lvc=len(self.vc)
    info_dict={}
    for node,info in xcat_nodes.items():
      info_dict[node]={'hardware':None,'cluster':None}
      members=info['groups'].strip()
      groups=[]
      if members: groups=[x.strip() for x in members.split(',')]
      for group in groups:
      # Assumes that the node is only a part of one hw and one vc 
        if group.startswith(self.hw): 
          info_dict[node]['hardware']=group[lhw:] 
        if group.startswith(self.vc): 
          info_dict[node]['cluster']=group[lvc:]
    return info_dict
     
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
    ret['statusOK']=True
    if not (self.is_admin or self.tenant==cluster):
      return ret
    ret['hardware']=  {} 
    hc_overview=self.detailed_overview()
    all_nodes=set(hc_overview['cluster'][cluster])
    for hardware in hc_overview['hardware']:
      overlap=len(all_nodes.intersection(set(hc_overview['hardware'][hardware])))
      ret['hardware'][hardware]=overlap
    return ret    

  # this is not DRY
  def cluster_details(self,cluster): 
    self.authenticate()
    ret={}
    ret['statusOK']=True
    if not (self.is_admin or self.tenant==cluster):
      return ret
    ret['hardware']={}
    hc_overview=self.detailed_overview()
    all_nodes=set(hc_overview['cluster'][cluster])
    for hardware in hc_overview['hardware']:
      overlap=list(all_nodes.intersection(set(hc_overview['hardware'][hardware])))
      ret['hardware'][hardware]=overlap
 
    return ret    

  def hardware_nodes(self,hardware):
    self.authenticate()
    ret={}
    ret['statusOK']=True
    if not (self.is_admin):
      return ret
    hc_overview=self.detailed_overview()
    c_nodes=set()
    for cluster in hc_overview['cluster']:
      c_nodes=c_nodes.union(set(hc_overview['cluster'][cluster]))
    ret['total']=len(hc_overview['hardware'][hardware])
    ret['list_unallocated']=list(set(hc_overview['hardware'][hardware])-c_nodes)
    ret['unallocated']=len(ret['list_unallocated'])  
    ret['allocated']=ret['total']-ret['unallocated']   

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

@trinity.get('/trinity/v<version:float>/overview')
def total_overview(version=1):
  req=TrinityAPI(request)
  if not req.is_admin:
    ret={'error':req.not_admin}
    return ret
  return req.detailed_overview()
 

@trinity.get('/trinity/v<version:float>/overview/hardwares')
def hardware_overview(version=1):
  req=TrinityAPI(request)
  if not req.is_admin:
    ret={'error':req.not_admin}
    return ret
  hc_overview=req.detailed_overview()
  c_nodes=set()
  for cluster in hc_overview['cluster']:
    c_nodes=c_nodes.union(set(hc_overview['cluster'][cluster]))
  
  h_overview={}
  for hardware in hc_overview['hardware']: 
    h_overview[hardware]={} 
    h_overview[hardware]['total']=len(hc_overview['hardware'][hardware])
    h_overview[hardware]['list_unallocated']=list(set(hc_overview['hardware'][hardware])-c_nodes)
    h_overview[hardware]['unallocated']=len(h_overview[hardware]['list_unallocated'])  
    h_overview[hardware]['allocated']=h_overview[hardware]['total']-h_overview[hardware]['unallocated']   
  return h_overview    
  
@trinity.get('/trinity/v<version:float>/overview/clusters')
def cluster_overview(version=1):
  req=TrinityAPI(request)
  if not req.is_admin:
    ret={'error':req.not_admin}
    return ret
  hc_overview=req.detailed_overview()
  c_overview={}
  for cluster in hc_overview['cluster']:
    c_overview[cluster]={}
    c_overview[cluster]['hardware']={}
    for hardware in hc_overview['hardware']:
      amount=len(set(hc_overview['cluster'][cluster]).intersection(set(hc_overview['hardware'][hardware])))
      c_overview[cluster]['hardware'][hardware]=amount
  return c_overview   



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
  if not (req.is_admin or req.tenant==cluster):
    ret={'error':req.no_access}
    return ret
  hc_overview=req.detailed_overview()
  c_overview={'hardware':{}}
  for hardware in hc_overview['hardware']:
    amount=len(set(hc_overview['cluster'][cluster]).intersection(set(hc_overview['hardware'][hardware])))
    c_overview['hardware'][hardware]=amount
  return c_overview   
#  return req.cluster_nodes(cluster)    

@trinity.get('/trinity/v<version:float>/hardwares/<hardware>')
def show_hardware(hardware,version=1):
  req=TrinityAPI(request)
  if not req.is_admin:
    ret={'error':req.not_admin}
    return ret
  hc_overview=req.detailed_overview()
  c_nodes=set()
  for cluster in hc_overview['cluster']:
    c_nodes=c_nodes.union(set(hc_overview['cluster'][cluster]))
  h_overview={}
  h_overview={} 
  h_overview['total']=len(hc_overview['hardware'][hardware])
  h_overview['list_unallocated']=list(set(hc_overview['hardware'][hardware])-c_nodes)
  h_overview['unallocated']=len(h_overview['list_unallocated'])  
  h_overview['allocated']=h_overview['total']-h_overview['unallocated']   
  return h_overview    
#  return req.hardware_nodes(hardware)

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
    cluster_exists = True
    ret=update_cluster(req,cluster)
    slurm_needs_update=False
    if ret['statusOK']:
      if ret['change']:
        slurm_needs_update=True
  else:
    cluster_exists = False
    ret=create_cluster(req,cluster)
    if ret['statusOK']:
      # Create the cluster home directories    
      vc_cluster=req.vc + cluster
      cluster_home=os.path.join(vhome,vc_cluster) 
      if not os.path.isdir(cluster_home):
        os.makedirs(cluster_home) 
#      src_root=req.cluster_path
      src_root=req.template_dir
      vc_cluster=req.vc + cluster
#      dest_root=os.path.join(req.cluster_path,
#                             req.clusters_dir,
#                             cluster)
      dest_root=os.path.join(req.cluster_path,
#                             req.clusters_dir,
                             vc_cluster)
#      excludes=[req.clusters_dir]
      excludes=[]
      copy_with_excludes(src_root,dest_root,excludes)
      slurm_needs_update=True 
  
  cont_list=[]
  if slurm_needs_update:
    for node in ret['nodeList']:
      cont=node.replace(req.node_pref,req.cont_pref)
      cont_list.append(cont) 
    cont_string=','.join(cont_list)
    vc_cluster=req.vc + cluster
#    slurm=os.path.join(req.cluster_path,
#                       req.clusters_dir,
#                       cluster,
#                       req.slurm_node_file)
    slurm=os.path.join(req.cluster_path,
#                       req.clusters_dir,
                       vc_cluster,
                       req.slurm_node_file)
    part_string='PartitionName='+req.cont_part+' Nodes='+cont_string+' Default=Yes'
    changes={'NodeName':'NodeName='+cont_string,
             'PartitionName':part_string}
    replace_lines(slurm,changes)
#    conf_update(slurm,'NodeName',cont_string,sep='=')
#    conf_update(slurm,'PartitionName',req.cont_part+' Nodes='+cont_string+' Default=Yes',sep='=')

##---------------------------------------------------------------------
## In this part we update makehosts, makedns etc for the cluster
## We assume that the cluster name is a,b,c...l
##---------------------------------------------------------------------
  vc_cluster=req.vc + cluster

#should not hardcoded!!!
  vc_net='vc_'+cluster+'_net'
  login_cluster='login-'+cluster
# This will not work if cluster is not a single char!!!!!  
  second_octet=str(16+ord(cluster)-ord('a'))
 
  if not cluster_exists :
    # create vc-<cluster> entry in the hosts table
    # The verb is PUT because the nodes already exist
    verb='PUT' 
    path='/tables/hosts/rows/node='+vc_cluster
    payload={
      "ip" : "|\D+(\d+)$|172."+second_octet+".((($1-1)/255)).(($1-1)%255+1)|", 
      "hostnames" : "|\D+(\d+)$|c($1)|"
    }
    req.xcat(verb=verb,path=path,payload=payload)
    verb='PUT'
    # create login-<cluster> entry in the hosts table
    path='/tables/hosts/rows/node='+login_cluster
    payload={
      "ip" : "172."+second_octet+".255.254",
      "hostnames" : "login."+vc_cluster
    }
    req.xcat(verb=verb,path=path,payload=payload)
    # create the entry in the networks table
    verb='POST'
    path='/networks/'+vc_net
    payload={
      "domain" : vc_cluster,
      "gateway" : "<xcatmaster>",
      "mask" : "255.255.0.0",
      "mgtifname" : req.xcat_mgtifname,
      "net" : "172."+second_octet+".0.0"
    }
    req.xcat(verb=verb,path=path,payload=payload)
    # create a login node entry in the xCATdb
    verb='POST'
    path='/nodes/'+login_cluster
    payload={
      "groups" : "login"
    }
    req.xcat(verb=verb,path=path,payload=payload)
    # makehost and makedns for login node
    verb='POST'
    payload={}
    path='/nodes/'+login_cluster+'/host' 
    req.xcat(verb=verb,path=path,payload=payload)
    path='/nodes/'+login_cluster+'/dns' 
    req.xcat(verb=verb,path=path,payload=payload)
  # makehost and makedns for cluster
  verb='POST'
  payload={}
  path='/nodes/'+vc_cluster+'/host' 
  req.xcat(verb=verb,path=path,payload=payload)
  path='/nodes/'+vc_cluster+'/dns' 
  req.xcat(verb=verb,path=path,payload=payload)
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
  trinity.run(host=trinity_host, port=trinity_port, debug=trinity_debug, server=trinity_server)
