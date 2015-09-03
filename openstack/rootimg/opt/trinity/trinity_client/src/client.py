#!/usr/bin/env python
import os
from ConfigParser import SafeConfigParser
import json
import requests

#conf_file=os.path.join(os.path.dirname(os.path.abspath(__file__)),'trinity_client.conf')
conf_file='/etc/trinity/trinity_client.conf'
class Client(object):

  def __init__(self,username=None,password=None,tenant=None,token=None):
    # This will be in a conf file finder routine
    self.conf_file= conf_file
    self.config(self.conf_file)
    self.trinity_prefix=self.trinity_protocol+'://'+self.trinity_host+':'+self.trinity_port \
                         +'/'+self.trinity_collection+'/v'+self.trinity_version    
    self.username=username
    self.password=password
    self.tenant=tenant
    self.token=token
    if token:
      self.headers = {
       "Content-Type": "application/json", 
       "Accept":"application/json", 
       "X-Tenant": self.tenant,
       "X-Auth-Token":self.token
      }
      self.payload = {}
    else:
      self.headers = {
       "Content-Type": "application/json", 
       "Accept":"application/json", 
       "X-Tenant": self.tenant
      }
      self.payload = { 
                  "username": self.username,
                  "password": self.password
                }
      self.token=self.login()
      self.headers.update({"X-Auth-Token":self.token})
      self.payload={}
 
  def config(self,file):
    config=SafeConfigParser()
    config.read(file)
    for section in config.sections():
      for option in config.options(section):
        value=config.get(section,option)
        setattr(self,option,value)

############################################################################################################

  def login(self):
    r = requests.post(self.trinity_prefix+'/login', data=json.dumps(self.payload), headers=self.headers)
    return r.json()["token"] 

  def version(self):
    if os.path.isfile('/trinity/version'):
      fop=open('/trinity/version','r')
      lines=fop.readlines()
      fop.close()
      branch=lines[0].strip().split()[1]
      id=lines[1].strip().split()[0]
      id_branch = id + ' ('+branch+')'
      return id_branch
    else:
      r = requests.get(self.trinity_prefix+'/version', data=json.dumps(self.payload), headers=self.headers)
      return r.json()["versionID (releaseBranch)"]
 
  def hardwares_list(self):
    r = requests.get(self.trinity_prefix+'/hardwares', data=json.dumps(self.payload), headers=self.headers)
    return r.json()["hardwares"]
  
  def clusters_list(self):
    r = requests.get(self.trinity_prefix+'/clusters', data=json.dumps(self.payload), headers=self.headers)
    return r.json()["clusters"]

  def hardwares_detail(self):
    hardwares=self.hardwares_list()
    data=[]
    r = requests.get(self.trinity_prefix+'/overview/hardwares', data=json.dumps(self.payload), headers=self.headers).json()
    for hardware in  r: 
#      r = requests.get(self.trinity_prefix+'/hardwares/'+hardware, data=json.dumps(self.payload), headers=self.headers)
      datum={}
      res=r[hardware]
      datum['total']=res['total']
      datum['used']=res['allocated']
      datum['hardware']=hardware
      data.append(datum)
    return data

  def clusters_detail(self):
    clusters=self.clusters_list()
    data=[]
    r = requests.get(self.trinity_prefix+'/overview/clusters', data=json.dumps(self.payload), headers=self.headers).json()
    for cluster in r: 
      hardwares=r[cluster]['hardware']
      datum={'cluster':cluster}
      for hardware in hardwares: 
        datum[hardware]=r[cluster]['hardware'][hardware]
      data.append(datum)
    return data

  def cluster_hardware(self,cluster):
    r = requests.get(self.trinity_prefix+'/clusters/'+cluster, data=json.dumps(self.payload), headers=self.headers)
    data=[]
    res=r.json()
    for key,value in res['hardware'].items():
      datum={}
      datum['type']=key
      datum['amount']=value
      data.append(datum) 
    return data

  def cluster_config(self,cluster):
#  Dummy
    data=[{'param': 'Operating System', 'value': 'Centos-7.0'},
          {'param': 'Scheduler', 'value': 'SLURM-14.11'}]
#          {'param': 'Monitoring','value':'Ganglia-3.6.2'}]
    return data


  def cluster_modify(self,cluster,specs):
    self.payload.update({'specs':specs})
    r = requests.put(self.trinity_prefix+'/clusters/'+cluster, data=json.dumps(self.payload), headers=self.headers)
    return r.json() 

  def monitoring_info(self):
    r =requests.get(self.trinity_prefix+'/monitoring', data=json.dumps(self.payload), headers=self.headers)
    return r.json()

  def get_metrics(self):
#  Dummy
    return
############################################################################

def main():
# Get credentials from env consts
  username=os.environ.get("OS_USERNAME")
  password=os.environ.get("OS_PASSWORD")
  tenant=os.environ.get("OS_TENANT_NAME")
  
if __name__ == "__main__":
  c=Client(username='admin',password='system',tenant='admin')
  print c.hardwares_list()
#  print c.token
#  print c.clusters_detail() 
#  print c.cluster_modify(cluster='bio',specs={'gpu':1}) 
     
