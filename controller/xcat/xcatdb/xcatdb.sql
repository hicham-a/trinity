-- MySQL dump 10.14  Distrib 5.5.41-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: xcatdb
-- ------------------------------------------------------
-- Server version	5.5.41-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `xcatdb`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `xcatdb` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `xcatdb`;

--
-- Table structure for table `auditlog`
--

DROP TABLE IF EXISTS `auditlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auditlog` (
  `recid` int(11) NOT NULL AUTO_INCREMENT,
  `audittime` text,
  `userid` text,
  `clientname` text,
  `clienttype` text,
  `command` text,
  `noderange` text,
  `args` text,
  `status` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`recid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditlog`
--

LOCK TABLES `auditlog` WRITE;
/*!40000 ALTER TABLE `auditlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `auditlog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bootparams`
--

DROP TABLE IF EXISTS `bootparams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bootparams` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `kernel` text,
  `initrd` text,
  `kcmdline` text,
  `addkcmdline` text,
  `dhcpstatements` text,
  `adddhcpstatements` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bootparams`
--

LOCK TABLES `bootparams` WRITE;
/*!40000 ALTER TABLE `bootparams` DISABLE KEYS */;
INSERT INTO `bootparams` VALUES ('compute',NULL,NULL,NULL,'selinux=0',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `bootparams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `boottarget`
--

DROP TABLE IF EXISTS `boottarget`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `boottarget` (
  `bprofile` varchar(128) NOT NULL DEFAULT '',
  `kernel` text,
  `initrd` text,
  `kcmdline` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`bprofile`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `boottarget`
--

LOCK TABLES `boottarget` WRITE;
/*!40000 ALTER TABLE `boottarget` DISABLE KEYS */;
/*!40000 ALTER TABLE `boottarget` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cfgmgt`
--

DROP TABLE IF EXISTS `cfgmgt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cfgmgt` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `cfgmgr` text,
  `cfgserver` text,
  `roles` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cfgmgt`
--

LOCK TABLES `cfgmgt` WRITE;
/*!40000 ALTER TABLE `cfgmgt` DISABLE KEYS */;
/*!40000 ALTER TABLE `cfgmgt` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chain`
--

DROP TABLE IF EXISTS `chain`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chain` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `currstate` text,
  `currchain` text,
  `chain` text,
  `ondiscover` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chain`
--

LOCK TABLES `chain` WRITE;
/*!40000 ALTER TABLE `chain` DISABLE KEYS */;
INSERT INTO `chain` VALUES ('compute',NULL,NULL,'runcmd=bmcsetup,runimage=http://controller/install/runimages/mkfs.tgz,standby',NULL,NULL,NULL);
/*!40000 ALTER TABLE `chain` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deps`
--

DROP TABLE IF EXISTS `deps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deps` (
  `node` varchar(128) NOT NULL,
  `nodedep` text,
  `msdelay` text,
  `cmd` varchar(128) NOT NULL,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`,`cmd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deps`
--

LOCK TABLES `deps` WRITE;
/*!40000 ALTER TABLE `deps` DISABLE KEYS */;
/*!40000 ALTER TABLE `deps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `discoverydata`
--

DROP TABLE IF EXISTS `discoverydata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `discoverydata` (
  `uuid` varchar(128) NOT NULL DEFAULT '',
  `node` text,
  `method` text,
  `discoverytime` text,
  `arch` text,
  `cpucount` text,
  `cputype` text,
  `memory` text,
  `mtm` text,
  `serial` text,
  `nicdriver` text,
  `nicipv4` text,
  `nichwaddr` text,
  `nicpci` text,
  `nicloc` text,
  `niconboard` text,
  `nicfirm` text,
  `switchname` text,
  `switchaddr` text,
  `switchdesc` text,
  `switchport` text,
  `otherdata` varchar(2048) DEFAULT NULL,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `discoverydata`
--

LOCK TABLES `discoverydata` WRITE;
/*!40000 ALTER TABLE `discoverydata` DISABLE KEYS */;
/*!40000 ALTER TABLE `discoverydata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `domain`
--

DROP TABLE IF EXISTS `domain`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `domain` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `ou` text,
  `authdomain` text,
  `adminuser` text,
  `adminpassword` text,
  `type` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `domain`
--

LOCK TABLES `domain` WRITE;
/*!40000 ALTER TABLE `domain` DISABLE KEYS */;
/*!40000 ALTER TABLE `domain` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eventlog`
--

DROP TABLE IF EXISTS `eventlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `eventlog` (
  `recid` int(11) NOT NULL AUTO_INCREMENT,
  `eventtime` text,
  `eventtype` text,
  `monitor` text,
  `monnode` text,
  `node` text,
  `application` text,
  `component` text,
  `id` text,
  `severity` text,
  `message` text,
  `rawdata` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`recid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eventlog`
--

LOCK TABLES `eventlog` WRITE;
/*!40000 ALTER TABLE `eventlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `eventlog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `firmware`
--

DROP TABLE IF EXISTS `firmware`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `firmware` (
  `node` varchar(128) NOT NULL,
  `cfgfile` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `firmware`
--

LOCK TABLES `firmware` WRITE;
/*!40000 ALTER TABLE `firmware` DISABLE KEYS */;
/*!40000 ALTER TABLE `firmware` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hosts`
--

DROP TABLE IF EXISTS `hosts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hosts` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `ip` text,
  `hostnames` text,
  `otherinterfaces` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hosts`
--

LOCK TABLES `hosts` WRITE;
/*!40000 ALTER TABLE `hosts` DISABLE KEYS */;
INSERT INTO `hosts` VALUES ('compute','|\\D+(\\d+)$|10.141.((($1-1)/255)).(($1-1)%255+1)|','|\\D+(\\d+)$|node($1)|','|\\D+(\\d+)$|node($1)-bmc:10.148.((($1-1)/255)).(($1-1)%255+1),node($1)-ib:10.149.((($1-1)/255)).(($1-1)%255+1)|',NULL,NULL),('controller','10.141.255.254','controller',NULL,NULL,NULL),('login-a','172.16.255.254','login.vc-a',NULL,NULL,NULL),('switch','192.168.192.168','switch',NULL,NULL,NULL),('vc-a','|\\D+(\\d+)$|172.16.((($1-1)/255)).(($1-1)%255+1)|','|\\D+(\\d+)$|c($1)|',NULL,NULL,NULL);
/*!40000 ALTER TABLE `hosts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hwinv`
--

DROP TABLE IF EXISTS `hwinv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hwinv` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `cputype` text,
  `cpucount` text,
  `memory` text,
  `disksize` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hwinv`
--

LOCK TABLES `hwinv` WRITE;
/*!40000 ALTER TABLE `hwinv` DISABLE KEYS */;
/*!40000 ALTER TABLE `hwinv` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hypervisor`
--

DROP TABLE IF EXISTS `hypervisor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hypervisor` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `type` text,
  `mgr` text,
  `interface` text,
  `netmap` text,
  `defaultnet` text,
  `cluster` text,
  `datacenter` text,
  `preferdirect` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hypervisor`
--

LOCK TABLES `hypervisor` WRITE;
/*!40000 ALTER TABLE `hypervisor` DISABLE KEYS */;
/*!40000 ALTER TABLE `hypervisor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ipmi`
--

DROP TABLE IF EXISTS `ipmi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ipmi` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `bmc` text,
  `bmcport` text,
  `taggedvlan` text,
  `bmcid` text,
  `username` text,
  `password` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ipmi`
--

LOCK TABLES `ipmi` WRITE;
/*!40000 ALTER TABLE `ipmi` DISABLE KEYS */;
INSERT INTO `ipmi` VALUES ('compute','/\\z/-bmc/','0',NULL,NULL,'root','system',NULL,NULL);
/*!40000 ALTER TABLE `ipmi` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `iscsi`
--

DROP TABLE IF EXISTS `iscsi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iscsi` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `server` text,
  `target` text,
  `lun` text,
  `iname` text,
  `file` text,
  `userid` text,
  `passwd` text,
  `kernel` text,
  `kcmdline` text,
  `initrd` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `iscsi`
--

LOCK TABLES `iscsi` WRITE;
/*!40000 ALTER TABLE `iscsi` DISABLE KEYS */;
/*!40000 ALTER TABLE `iscsi` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kit`
--

DROP TABLE IF EXISTS `kit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kit` (
  `kitname` varchar(128) NOT NULL DEFAULT '',
  `basename` text,
  `description` text,
  `version` text,
  `release` text,
  `ostype` text,
  `isinternal` text,
  `kitdeployparams` text,
  `kitdir` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`kitname`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kit`
--

LOCK TABLES `kit` WRITE;
/*!40000 ALTER TABLE `kit` DISABLE KEYS */;
/*!40000 ALTER TABLE `kit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kitcomponent`
--

DROP TABLE IF EXISTS `kitcomponent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kitcomponent` (
  `kitcompname` varchar(128) NOT NULL DEFAULT '',
  `description` text,
  `kitname` text,
  `kitreponame` text,
  `basename` text,
  `version` text,
  `release` text,
  `serverroles` text,
  `kitpkgdeps` text,
  `prerequisite` text,
  `driverpacks` text,
  `kitcompdeps` text,
  `postbootscripts` text,
  `genimage_postinstall` text,
  `exlist` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`kitcompname`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kitcomponent`
--

LOCK TABLES `kitcomponent` WRITE;
/*!40000 ALTER TABLE `kitcomponent` DISABLE KEYS */;
/*!40000 ALTER TABLE `kitcomponent` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kitrepo`
--

DROP TABLE IF EXISTS `kitrepo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kitrepo` (
  `kitreponame` varchar(128) NOT NULL DEFAULT '',
  `kitname` text,
  `osbasename` text,
  `osmajorversion` text,
  `osminorversion` text,
  `osarch` text,
  `compat_osbasenames` text,
  `kitrepodir` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`kitreponame`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kitrepo`
--

LOCK TABLES `kitrepo` WRITE;
/*!40000 ALTER TABLE `kitrepo` DISABLE KEYS */;
/*!40000 ALTER TABLE `kitrepo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kvm_masterdata`
--

DROP TABLE IF EXISTS `kvm_masterdata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kvm_masterdata` (
  `name` varchar(128) NOT NULL DEFAULT '',
  `xml` varchar(16000) DEFAULT NULL,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kvm_masterdata`
--

LOCK TABLES `kvm_masterdata` WRITE;
/*!40000 ALTER TABLE `kvm_masterdata` DISABLE KEYS */;
/*!40000 ALTER TABLE `kvm_masterdata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kvm_nodedata`
--

DROP TABLE IF EXISTS `kvm_nodedata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kvm_nodedata` (
  `node` varchar(128) NOT NULL,
  `xml` varchar(16000) DEFAULT NULL,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kvm_nodedata`
--

LOCK TABLES `kvm_nodedata` WRITE;
/*!40000 ALTER TABLE `kvm_nodedata` DISABLE KEYS */;
/*!40000 ALTER TABLE `kvm_nodedata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `linuximage`
--

DROP TABLE IF EXISTS `linuximage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `linuximage` (
  `imagename` varchar(128) NOT NULL DEFAULT '',
  `template` text,
  `boottarget` text,
  `addkcmdline` text,
  `pkglist` text,
  `pkgdir` text,
  `otherpkglist` text,
  `otherpkgdir` text,
  `exlist` text,
  `postinstall` text,
  `rootimgdir` text,
  `kerneldir` text,
  `nodebootif` text,
  `otherifce` text,
  `netdrivers` text,
  `kernelver` text,
  `krpmver` text,
  `permission` text,
  `dump` text,
  `crashkernelsize` text,
  `partitionfile` text,
  `driverupdatesrc` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`imagename`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `linuximage`
--

LOCK TABLES `linuximage` WRITE;
/*!40000 ALTER TABLE `linuximage` DISABLE KEYS */;
INSERT INTO `linuximage` VALUES ('centos7-x86_64-install-controller',NULL,NULL,NULL,'/install/custom/install/centos/controller.pkglist','/install/centos7/x86_64','/install/custom/install/centos/controller.otherpkgs','/install/post/otherpkgs/centos7/x86_64','/install/custom/install/centos/controller.exlist','/install/custom/install/centos/controller.postinstall',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'755',NULL,NULL,NULL,NULL,NULL,NULL),('centos7-x86_64-install-master',NULL,NULL,NULL,'/install/custom/install/centos/master.pkglist','/install/centos7/x86_64','/install/custom/install/centos/master.otherpkgs','/install/post/otherpkgs/centos7/x86_64','/install/custom/install/centos/master.exlist','/install/custom/install/centos/master.postinstall',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'755',NULL,NULL,NULL,NULL,NULL,NULL),('centos7-x86_64-install-openstack',NULL,NULL,NULL,'/install/custom/install/centos/openstack.pkglist','/install/centos7/x86_64','/install/custom/install/centos/openstack.otherpkgs','/install/post/otherpkgs/centos7/x86_64','/install/custom/install/centos/openstack.exlist','/install/custom/install/centos/openstack.postinstall',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'755',NULL,NULL,NULL,NULL,NULL,NULL),('centos7-x86_64-netboot-compute',NULL,NULL,NULL,'/install/custom/netboot/centos/compute.centos7.pkglist','/install/centos7/x86_64',NULL,'/install/post/otherpkgs/centos7/x86_64','/install/custom/netboot/centos/compute.centos7.exlist','/install/custom/netboot/centos/compute.centos7.postinstall','/install/netboot/centos7/x86_64/compute',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('centos7-x86_64-netboot-trinity',NULL,NULL,NULL,'/install/custom/netboot/centos/trinity.centos7.pkglist','/install/centos7/x86_64','/install/custom/netboot/centos/trinity.centos7.otherpkgs','/install/post/otherpkgs/centos7/x86_64','/install/custom/netboot/centos/trinity.centos7.exlist','/install/custom/netboot/centos/trinity.centos7.postinstall','/install/netboot/centos7/x86_64/trinity',NULL,NULL,NULL,NULL,NULL,NULL,'755',NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `linuximage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `litefile`
--

DROP TABLE IF EXISTS `litefile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `litefile` (
  `image` varchar(128) NOT NULL,
  `file` varchar(128) NOT NULL,
  `options` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`image`,`file`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `litefile`
--

LOCK TABLES `litefile` WRITE;
/*!40000 ALTER TABLE `litefile` DISABLE KEYS */;
/*!40000 ALTER TABLE `litefile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `litetree`
--

DROP TABLE IF EXISTS `litetree`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `litetree` (
  `priority` varchar(128) NOT NULL,
  `image` text,
  `directory` text NOT NULL,
  `mntopts` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `litetree`
--

LOCK TABLES `litetree` WRITE;
/*!40000 ALTER TABLE `litetree` DISABLE KEYS */;
/*!40000 ALTER TABLE `litetree` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mac`
--

DROP TABLE IF EXISTS `mac`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mac` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `interface` text,
  `mac` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mac`
--

LOCK TABLES `mac` WRITE;
/*!40000 ALTER TABLE `mac` DISABLE KEYS */;
/*!40000 ALTER TABLE `mac` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mic`
--

DROP TABLE IF EXISTS `mic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mic` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `host` text,
  `id` text,
  `nodetype` text,
  `bridge` text,
  `onboot` text,
  `vlog` text,
  `powermgt` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mic`
--

LOCK TABLES `mic` WRITE;
/*!40000 ALTER TABLE `mic` DISABLE KEYS */;
/*!40000 ALTER TABLE `mic` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `monitoring`
--

DROP TABLE IF EXISTS `monitoring`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `monitoring` (
  `name` varchar(128) NOT NULL,
  `nodestatmon` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `monitoring`
--

LOCK TABLES `monitoring` WRITE;
/*!40000 ALTER TABLE `monitoring` DISABLE KEYS */;
/*!40000 ALTER TABLE `monitoring` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `monsetting`
--

DROP TABLE IF EXISTS `monsetting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `monsetting` (
  `name` varchar(128) NOT NULL,
  `key` varchar(128) NOT NULL,
  `value` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`name`,`key`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `monsetting`
--

LOCK TABLES `monsetting` WRITE;
/*!40000 ALTER TABLE `monsetting` DISABLE KEYS */;
/*!40000 ALTER TABLE `monsetting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mp`
--

DROP TABLE IF EXISTS `mp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mp` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `mpa` text,
  `id` text,
  `nodetype` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mp`
--

LOCK TABLES `mp` WRITE;
/*!40000 ALTER TABLE `mp` DISABLE KEYS */;
/*!40000 ALTER TABLE `mp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mpa`
--

DROP TABLE IF EXISTS `mpa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mpa` (
  `mpa` varchar(128) NOT NULL DEFAULT '',
  `username` varchar(128) NOT NULL DEFAULT '',
  `password` text,
  `displayname` text,
  `slots` text,
  `urlpath` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`mpa`,`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mpa`
--

LOCK TABLES `mpa` WRITE;
/*!40000 ALTER TABLE `mpa` DISABLE KEYS */;
/*!40000 ALTER TABLE `mpa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `networks`
--

DROP TABLE IF EXISTS `networks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `networks` (
  `netname` text,
  `net` varchar(128) NOT NULL DEFAULT '',
  `mask` varchar(128) NOT NULL DEFAULT '',
  `mgtifname` text,
  `gateway` text,
  `dhcpserver` text,
  `tftpserver` text,
  `nameservers` text,
  `ntpservers` text,
  `logservers` text,
  `dynamicrange` text,
  `staticrange` text,
  `staticrangeincrement` text,
  `nodehostname` text,
  `ddnsdomain` text,
  `vlanid` text,
  `domain` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`net`,`mask`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `networks`
--

LOCK TABLES `networks` WRITE;
/*!40000 ALTER TABLE `networks` DISABLE KEYS */;
INSERT INTO `networks` VALUES ('internal_net','10.141.0.0','255.255.0.0','em2','10.141.255.254','10.141.255.254','10.141.255.254','10.141.255.254',NULL,NULL,'10.141.230.1-10.141.239.254',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('bmc_net','10.148.0.0','255.255.0.0','em2','10.148.255.1',NULL,NULL,'10.141.255.254',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('vc_a_net','172.16.0.0','255.255.0.0','em2','<xcatmaster>',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'vc-a',NULL,NULL),('switch_net','192.168.192.0','255.255.255.0','em3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `networks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nics`
--

DROP TABLE IF EXISTS `nics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nics` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `nicips` text,
  `nichostnamesuffixes` text,
  `nichostnameprefixes` text,
  `nictypes` text,
  `niccustomscripts` text,
  `nicnetworks` text,
  `nicaliases` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nics`
--

LOCK TABLES `nics` WRITE;
/*!40000 ALTER TABLE `nics` DISABLE KEYS */;
/*!40000 ALTER TABLE `nics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nimimage`
--

DROP TABLE IF EXISTS `nimimage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nimimage` (
  `imagename` varchar(128) NOT NULL DEFAULT '',
  `nimtype` text,
  `lpp_source` text,
  `spot` text,
  `root` text,
  `dump` text,
  `paging` text,
  `resolv_conf` text,
  `tmp` text,
  `home` text,
  `shared_home` text,
  `res_group` text,
  `nimmethod` text,
  `script` text,
  `bosinst_data` text,
  `installp_bundle` text,
  `mksysb` text,
  `fb_script` text,
  `shared_root` text,
  `otherpkgs` text,
  `image_data` text,
  `configdump` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`imagename`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nimimage`
--

LOCK TABLES `nimimage` WRITE;
/*!40000 ALTER TABLE `nimimage` DISABLE KEYS */;
/*!40000 ALTER TABLE `nimimage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nodegroup`
--

DROP TABLE IF EXISTS `nodegroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nodegroup` (
  `groupname` varchar(128) NOT NULL DEFAULT '',
  `grouptype` text,
  `members` text,
  `membergroups` text,
  `wherevals` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`groupname`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nodegroup`
--

LOCK TABLES `nodegroup` WRITE;
/*!40000 ALTER TABLE `nodegroup` DISABLE KEYS */;
/*!40000 ALTER TABLE `nodegroup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nodehm`
--

DROP TABLE IF EXISTS `nodehm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nodehm` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `power` text,
  `mgt` text,
  `cons` text,
  `termserver` text,
  `termport` text,
  `conserver` text,
  `serialport` text,
  `serialspeed` text,
  `serialflow` text,
  `getmac` text,
  `cmdmapping` text,
  `consoleondemand` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nodehm`
--

LOCK TABLES `nodehm` WRITE;
/*!40000 ALTER TABLE `nodehm` DISABLE KEYS */;
INSERT INTO `nodehm` VALUES ('compute','ipmi','ipmi',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `nodehm` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nodelist`
--

DROP TABLE IF EXISTS `nodelist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nodelist` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `groups` text,
  `status` text,
  `statustime` text,
  `appstatus` text,
  `appstatustime` text,
  `primarysn` text,
  `hidden` text,
  `updatestatus` text,
  `updatestatustime` text,
  `zonename` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nodelist`
--

LOCK TABLES `nodelist` WRITE;
/*!40000 ALTER TABLE `nodelist` DISABLE KEYS */;
INSERT INTO `nodelist` VALUES ('controller','xcat',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('login-a','login',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('switch','xcat',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `nodelist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nodepos`
--

DROP TABLE IF EXISTS `nodepos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nodepos` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `rack` text,
  `u` text,
  `chassis` text,
  `slot` text,
  `room` text,
  `height` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nodepos`
--

LOCK TABLES `nodepos` WRITE;
/*!40000 ALTER TABLE `nodepos` DISABLE KEYS */;
/*!40000 ALTER TABLE `nodepos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `noderes`
--

DROP TABLE IF EXISTS `noderes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `noderes` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `servicenode` text,
  `netboot` text,
  `tftpserver` text,
  `tftpdir` text,
  `nfsserver` text,
  `monserver` text,
  `nfsdir` text,
  `installnic` text,
  `primarynic` text,
  `discoverynics` text,
  `cmdinterface` text,
  `xcatmaster` text,
  `current_osimage` text,
  `next_osimage` text,
  `nimserver` text,
  `routenames` text,
  `nameservers` text,
  `proxydhcp` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `noderes`
--

LOCK TABLES `noderes` WRITE;
/*!40000 ALTER TABLE `noderes` DISABLE KEYS */;
INSERT INTO `noderes` VALUES ('compute',NULL,'xnba',NULL,NULL,NULL,NULL,NULL,NULL,'mac',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `noderes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nodetype`
--

DROP TABLE IF EXISTS `nodetype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nodetype` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `os` text,
  `arch` text,
  `profile` text,
  `provmethod` text,
  `supportedarchs` text,
  `nodetype` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nodetype`
--

LOCK TABLES `nodetype` WRITE;
/*!40000 ALTER TABLE `nodetype` DISABLE KEYS */;
/*!40000 ALTER TABLE `nodetype` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification`
--

DROP TABLE IF EXISTS `notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notification` (
  `filename` varchar(128) NOT NULL,
  `tables` text NOT NULL,
  `tableops` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`filename`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification`
--

LOCK TABLES `notification` WRITE;
/*!40000 ALTER TABLE `notification` DISABLE KEYS */;
INSERT INTO `notification` VALUES ('montbhandler.pm','monsetting','a,u,d',NULL,NULL);
/*!40000 ALTER TABLE `notification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `osdistro`
--

DROP TABLE IF EXISTS `osdistro`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `osdistro` (
  `osdistroname` varchar(128) NOT NULL DEFAULT '',
  `basename` text,
  `majorversion` text,
  `minorversion` text,
  `arch` text,
  `type` text,
  `dirpaths` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`osdistroname`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `osdistro`
--

LOCK TABLES `osdistro` WRITE;
/*!40000 ALTER TABLE `osdistro` DISABLE KEYS */;
/*!40000 ALTER TABLE `osdistro` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `osdistroupdate`
--

DROP TABLE IF EXISTS `osdistroupdate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `osdistroupdate` (
  `osupdatename` varchar(128) NOT NULL DEFAULT '',
  `osdistroname` text,
  `dirpath` text,
  `downloadtime` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`osupdatename`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `osdistroupdate`
--

LOCK TABLES `osdistroupdate` WRITE;
/*!40000 ALTER TABLE `osdistroupdate` DISABLE KEYS */;
/*!40000 ALTER TABLE `osdistroupdate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `osimage`
--

DROP TABLE IF EXISTS `osimage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `osimage` (
  `imagename` varchar(128) NOT NULL DEFAULT '',
  `groups` text,
  `profile` text,
  `imagetype` text,
  `description` text,
  `provmethod` text,
  `rootfstype` text,
  `osdistroname` text,
  `osupdatename` varchar(1024) DEFAULT NULL,
  `cfmdir` text,
  `osname` text,
  `osvers` text,
  `osarch` text,
  `synclists` text,
  `postscripts` text,
  `postbootscripts` text,
  `serverrole` text,
  `isdeletable` text,
  `kitcomponents` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`imagename`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `osimage`
--

LOCK TABLES `osimage` WRITE;
/*!40000 ALTER TABLE `osimage` DISABLE KEYS */;
INSERT INTO `osimage` VALUES ('centos7-x86_64-install-controller',NULL,'controller','linux',NULL,'install',NULL,'centos7-x86_64',NULL,NULL,'Linux','centos7','x86_64',NULL,NULL,'cv_install_slapd,cv_install_controller',NULL,NULL,NULL,NULL,NULL),('centos7-x86_64-install-master',NULL,'master','linux',NULL,'install',NULL,'centos7-x86_64',NULL,NULL,'Linux','centos7','x86_64',NULL,NULL,'cv_install_master,cv_install_synology',NULL,NULL,NULL,NULL,NULL),('centos7-x86_64-install-openstack',NULL,'openstack','linux',NULL,'install',NULL,'centos7-x86_64',NULL,NULL,'Linux','centos7','x86_64',NULL,NULL,'cv_install_slapd,cv_install_openstack',NULL,NULL,NULL,NULL,NULL),('centos7-x86_64-netboot-compute',NULL,'compute','linux',NULL,'netboot',NULL,'centos7-x86_64',NULL,NULL,'Linux','centos7','x86_64',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('centos7-x86_64-netboot-trinity',NULL,'trinity','linux',NULL,'netboot',NULL,'centos7-x86_64',NULL,NULL,'Linux','centos7','x86_64',NULL,NULL,'cv_configure_prinic,cv_set_scheduler,cv_configure_storage',NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `osimage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `passwd`
--

DROP TABLE IF EXISTS `passwd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `passwd` (
  `key` varchar(128) NOT NULL DEFAULT '',
  `username` varchar(128) NOT NULL DEFAULT '',
  `password` text,
  `cryptmethod` text,
  `authdomain` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`key`,`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `passwd`
--

LOCK TABLES `passwd` WRITE;
/*!40000 ALTER TABLE `passwd` DISABLE KEYS */;
INSERT INTO `passwd` VALUES ('omapi','xcat_key','V0ZCM1N4bTF2T2hSdndITnZXeXhYeW5VRWJ0dGxGek4=',NULL,NULL,NULL,NULL),('system','root','system',NULL,NULL,NULL,NULL),('xcat','trinity','trinity',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `passwd` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `performance`
--

DROP TABLE IF EXISTS `performance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `performance` (
  `timestamp` varchar(128) NOT NULL DEFAULT '',
  `node` varchar(128) NOT NULL DEFAULT '',
  `attrname` varchar(128) NOT NULL DEFAULT '',
  `attrvalue` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`timestamp`,`node`,`attrname`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `performance`
--

LOCK TABLES `performance` WRITE;
/*!40000 ALTER TABLE `performance` DISABLE KEYS */;
/*!40000 ALTER TABLE `performance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `policy`
--

DROP TABLE IF EXISTS `policy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policy` (
  `priority` varchar(128) NOT NULL DEFAULT '',
  `name` text,
  `host` text,
  `commands` text,
  `noderange` text,
  `parameters` text,
  `time` text,
  `rule` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `policy`
--

LOCK TABLES `policy` WRITE;
/*!40000 ALTER TABLE `policy` DISABLE KEYS */;
INSERT INTO `policy` VALUES ('1','root',NULL,NULL,NULL,NULL,NULL,'allow',NULL,NULL),('1.2','controller.cluster',NULL,NULL,NULL,NULL,NULL,'trusted',NULL,NULL),('2',NULL,NULL,'getbmcconfig',NULL,NULL,NULL,'allow',NULL,NULL),('2.1',NULL,NULL,'remoteimmsetup',NULL,NULL,NULL,'allow',NULL,NULL),('2.3',NULL,NULL,'lsxcatd',NULL,NULL,NULL,'allow',NULL,NULL),('3',NULL,NULL,'nextdestiny',NULL,NULL,NULL,'allow',NULL,NULL),('4',NULL,NULL,'getdestiny',NULL,NULL,NULL,'allow',NULL,NULL),('4.4',NULL,NULL,'getpostscript',NULL,NULL,NULL,'allow',NULL,NULL),('4.5',NULL,NULL,'getcredentials',NULL,NULL,NULL,'allow',NULL,NULL),('4.6',NULL,NULL,'syncfiles',NULL,NULL,NULL,'allow',NULL,NULL),('4.7',NULL,NULL,'litefile',NULL,NULL,NULL,'allow',NULL,NULL),('4.8',NULL,NULL,'litetree',NULL,NULL,NULL,'allow',NULL,NULL),('6','trinity',NULL,NULL,NULL,NULL,NULL,'allow',NULL,NULL);
/*!40000 ALTER TABLE `policy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `postscripts`
--

DROP TABLE IF EXISTS `postscripts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `postscripts` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `postscripts` text,
  `postbootscripts` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `postscripts`
--

LOCK TABLES `postscripts` WRITE;
/*!40000 ALTER TABLE `postscripts` DISABLE KEYS */;
INSERT INTO `postscripts` VALUES ('service','servicenode',NULL,NULL,NULL),('xcatdefaults','syslog,remoteshell,syncfiles','cv_wait_for_it,otherpkgs',NULL,NULL);
/*!40000 ALTER TABLE `postscripts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ppc`
--

DROP TABLE IF EXISTS `ppc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ppc` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `hcp` text,
  `id` text,
  `pprofile` text,
  `parent` text,
  `nodetype` text,
  `supernode` text,
  `sfp` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ppc`
--

LOCK TABLES `ppc` WRITE;
/*!40000 ALTER TABLE `ppc` DISABLE KEYS */;
/*!40000 ALTER TABLE `ppc` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ppcdirect`
--

DROP TABLE IF EXISTS `ppcdirect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ppcdirect` (
  `hcp` varchar(128) NOT NULL DEFAULT '',
  `username` varchar(128) NOT NULL DEFAULT '',
  `password` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`hcp`,`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ppcdirect`
--

LOCK TABLES `ppcdirect` WRITE;
/*!40000 ALTER TABLE `ppcdirect` DISABLE KEYS */;
/*!40000 ALTER TABLE `ppcdirect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ppchcp`
--

DROP TABLE IF EXISTS `ppchcp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ppchcp` (
  `hcp` varchar(128) NOT NULL DEFAULT '',
  `username` text,
  `password` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`hcp`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ppchcp`
--

LOCK TABLES `ppchcp` WRITE;
/*!40000 ALTER TABLE `ppchcp` DISABLE KEYS */;
/*!40000 ALTER TABLE `ppchcp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prescripts`
--

DROP TABLE IF EXISTS `prescripts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prescripts` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `begin` text,
  `end` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prescripts`
--

LOCK TABLES `prescripts` WRITE;
/*!40000 ALTER TABLE `prescripts` DISABLE KEYS */;
/*!40000 ALTER TABLE `prescripts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prodkey`
--

DROP TABLE IF EXISTS `prodkey`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prodkey` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `product` varchar(128) NOT NULL DEFAULT '',
  `key` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`,`product`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prodkey`
--

LOCK TABLES `prodkey` WRITE;
/*!40000 ALTER TABLE `prodkey` DISABLE KEYS */;
/*!40000 ALTER TABLE `prodkey` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rack`
--

DROP TABLE IF EXISTS `rack`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rack` (
  `rackname` varchar(128) NOT NULL DEFAULT '',
  `displayname` text,
  `num` text,
  `height` text,
  `room` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`rackname`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rack`
--

LOCK TABLES `rack` WRITE;
/*!40000 ALTER TABLE `rack` DISABLE KEYS */;
/*!40000 ALTER TABLE `rack` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `routes`
--

DROP TABLE IF EXISTS `routes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `routes` (
  `routename` varchar(128) NOT NULL DEFAULT '',
  `net` text,
  `mask` text,
  `gateway` text,
  `ifname` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`routename`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `routes`
--

LOCK TABLES `routes` WRITE;
/*!40000 ALTER TABLE `routes` DISABLE KEYS */;
/*!40000 ALTER TABLE `routes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `servicenode`
--

DROP TABLE IF EXISTS `servicenode`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `servicenode` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `nameserver` text,
  `dhcpserver` text,
  `tftpserver` text,
  `nfsserver` text,
  `conserver` text,
  `monserver` text,
  `ldapserver` text,
  `ntpserver` text,
  `ftpserver` text,
  `nimserver` text,
  `ipforward` text,
  `dhcpinterfaces` text,
  `proxydhcp` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `servicenode`
--

LOCK TABLES `servicenode` WRITE;
/*!40000 ALTER TABLE `servicenode` DISABLE KEYS */;
/*!40000 ALTER TABLE `servicenode` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site`
--

DROP TABLE IF EXISTS `site`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site` (
  `key` varchar(128) NOT NULL DEFAULT '',
  `value` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site`
--

LOCK TABLES `site` WRITE;
/*!40000 ALTER TABLE `site` DISABLE KEYS */;
INSERT INTO `site` VALUES ('dhcpinterfaces','em2',NULL,NULL),('domain','cluster',NULL,NULL),('forwarders','8.8.8.8,8.8.4.4',NULL,NULL),('installdir','/install',NULL,NULL),('master','10.141.255.254',NULL,NULL),('nameservers','<xcatmaster>',NULL,NULL),('tftpdir','/tftpboot',NULL,NULL),('timezone','Europe/Amsterdam',NULL,NULL),('xcatconfdir','/etc/xcat',NULL,NULL),('xcatdport','3001',NULL,NULL),('xcatiport','3002',NULL,NULL);
/*!40000 ALTER TABLE `site` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `statelite`
--

DROP TABLE IF EXISTS `statelite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `statelite` (
  `node` varchar(128) NOT NULL,
  `image` text,
  `statemnt` text NOT NULL,
  `mntopts` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `statelite`
--

LOCK TABLES `statelite` WRITE;
/*!40000 ALTER TABLE `statelite` DISABLE KEYS */;
/*!40000 ALTER TABLE `statelite` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `storage`
--

DROP TABLE IF EXISTS `storage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `storage` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `osvolume` text,
  `size` text,
  `state` text,
  `storagepool` text,
  `hypervisor` text,
  `fcprange` text,
  `volumetag` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `storage`
--

LOCK TABLES `storage` WRITE;
/*!40000 ALTER TABLE `storage` DISABLE KEYS */;
/*!40000 ALTER TABLE `storage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `switch`
--

DROP TABLE IF EXISTS `switch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `switch` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `switch` varchar(128) NOT NULL DEFAULT '',
  `port` varchar(128) NOT NULL DEFAULT '',
  `vlan` text,
  `interface` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`,`switch`,`port`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `switch`
--

LOCK TABLES `switch` WRITE;
/*!40000 ALTER TABLE `switch` DISABLE KEYS */;
INSERT INTO `switch` VALUES ('node001','switch','ifc12 (Slot: 1 Port: 12)',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `switch` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `switches`
--

DROP TABLE IF EXISTS `switches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `switches` (
  `switch` varchar(128) NOT NULL DEFAULT '',
  `snmpversion` text,
  `username` text,
  `password` text,
  `privacy` text,
  `auth` text,
  `linkports` text,
  `sshusername` text,
  `sshpassword` text,
  `protocol` text,
  `switchtype` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`switch`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `switches`
--

LOCK TABLES `switches` WRITE;
/*!40000 ALTER TABLE `switches` DISABLE KEYS */;
INSERT INTO `switches` VALUES ('switch','2c',NULL,'public',NULL,NULL,NULL,NULL,NULL,'telnet',NULL,NULL,NULL);
/*!40000 ALTER TABLE `switches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `token`
--

DROP TABLE IF EXISTS `token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `token` (
  `tokenid` varchar(128) NOT NULL DEFAULT '',
  `username` text,
  `expire` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`tokenid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `token`
--

LOCK TABLES `token` WRITE;
/*!40000 ALTER TABLE `token` DISABLE KEYS */;
/*!40000 ALTER TABLE `token` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `virtsd`
--

DROP TABLE IF EXISTS `virtsd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `virtsd` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `sdtype` text,
  `stype` text,
  `location` text,
  `host` text,
  `cluster` text,
  `datacenter` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `virtsd`
--

LOCK TABLES `virtsd` WRITE;
/*!40000 ALTER TABLE `virtsd` DISABLE KEYS */;
/*!40000 ALTER TABLE `virtsd` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vm`
--

DROP TABLE IF EXISTS `vm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vm` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `mgr` text,
  `host` text,
  `migrationdest` text,
  `storage` text,
  `storagemodel` text,
  `storagecache` text,
  `storageformat` text,
  `cfgstore` text,
  `memory` text,
  `cpus` text,
  `nics` text,
  `nicmodel` text,
  `bootorder` text,
  `clockoffset` text,
  `virtflags` text,
  `master` text,
  `vncport` text,
  `textconsole` text,
  `powerstate` text,
  `beacon` text,
  `datacenter` text,
  `cluster` text,
  `guestostype` text,
  `othersettings` text,
  `physlots` text,
  `vidmodel` text,
  `vidproto` text,
  `vidpassword` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vm`
--

LOCK TABLES `vm` WRITE;
/*!40000 ALTER TABLE `vm` DISABLE KEYS */;
/*!40000 ALTER TABLE `vm` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vmmaster`
--

DROP TABLE IF EXISTS `vmmaster`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vmmaster` (
  `name` varchar(128) NOT NULL DEFAULT '',
  `os` text,
  `arch` text,
  `profile` text,
  `storage` text,
  `storagemodel` text,
  `nics` text,
  `vintage` text,
  `originator` text,
  `virttype` text,
  `specializeparameters` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vmmaster`
--

LOCK TABLES `vmmaster` WRITE;
/*!40000 ALTER TABLE `vmmaster` DISABLE KEYS */;
/*!40000 ALTER TABLE `vmmaster` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vpd`
--

DROP TABLE IF EXISTS `vpd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vpd` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `serial` text,
  `mtm` text,
  `side` text,
  `asset` text,
  `uuid` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vpd`
--

LOCK TABLES `vpd` WRITE;
/*!40000 ALTER TABLE `vpd` DISABLE KEYS */;
/*!40000 ALTER TABLE `vpd` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `websrv`
--

DROP TABLE IF EXISTS `websrv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `websrv` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `port` text,
  `username` text,
  `password` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `websrv`
--

LOCK TABLES `websrv` WRITE;
/*!40000 ALTER TABLE `websrv` DISABLE KEYS */;
/*!40000 ALTER TABLE `websrv` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `winimage`
--

DROP TABLE IF EXISTS `winimage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `winimage` (
  `imagename` varchar(128) NOT NULL DEFAULT '',
  `template` text,
  `installto` text,
  `partitionfile` text,
  `winpepath` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`imagename`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `winimage`
--

LOCK TABLES `winimage` WRITE;
/*!40000 ALTER TABLE `winimage` DISABLE KEYS */;
/*!40000 ALTER TABLE `winimage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `zone`
--

DROP TABLE IF EXISTS `zone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `zone` (
  `zonename` varchar(128) NOT NULL DEFAULT '',
  `sshkeydir` text,
  `sshbetweennodes` text,
  `defaultzone` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`zonename`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `zone`
--

LOCK TABLES `zone` WRITE;
/*!40000 ALTER TABLE `zone` DISABLE KEYS */;
/*!40000 ALTER TABLE `zone` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `zvm`
--

DROP TABLE IF EXISTS `zvm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `zvm` (
  `node` varchar(128) NOT NULL DEFAULT '',
  `hcp` text,
  `userid` text,
  `nodetype` text,
  `parent` text,
  `comments` text,
  `disable` text,
  PRIMARY KEY (`node`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `zvm`
--

LOCK TABLES `zvm` WRITE;
/*!40000 ALTER TABLE `zvm` DISABLE KEYS */;
/*!40000 ALTER TABLE `zvm` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-08-06 20:01:15
