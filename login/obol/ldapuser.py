from retrying import retry
import ldap
import os
import shutil
from textwrap import dedent

# FIXME: this should not always run on the localhost
conn = ldap.initialize('ldap://localhost')
conn.simple_bind_s('cn=Manager,dc=cluster', 'system')

def user_add(username, cn, sn, givenName, password, shell, groups):
    """Add a user to the LDAP"""
    uidNumber = increment_uid()

    # first add the group 
    dn = 'cn=%s,ou=Group,dc=cluster' % username
    add_record = [
     ('objectclass', ['top','posixGroup']),
     ('cn', [username] ),
     ('memberuid', [uidNumber] ),
     ('gidNumber', [uidNumber])
    ]
    conn.add_s(dn, add_record)

    # now add the user 
    dn = 'uid=%s,ou=People,dc=cluster' % username
    add_record = [
     ('objectclass', ['top','person', 'organizationalPerson', 'inetOrgPerson', 'posixAccount', 'shadowAccount']),
     ('uid', [username] ),
     ('cn', [cn] ),
     ('sn', [sn] ),
     ('givenName', [givenName] ),
     ('userPassword', [password] ), 
     ('loginShell', [shell] ),
     ('uidNumber', [uidNumber] ),
     ('gidNumber', [uidNumber] ),
     ('homeDirectory', ['/home/%s' % username] )
    ]
    conn.add_s(dn, add_record)

    if groups:
        for group in groups:
            group_addusers(group, [username])

    # Now setup the home directories and generate keys.
    if os.path.isdir("/home/%s/.ssh" % username):
        print '/home/%s/.ssh already exists, we will not create new keys' % username
    else:
        os.makedirs('/home/%s/.ssh' % username)
        os.chown('/home/%s' % username, int(uidNumber), int(uidNumber))
        os.chown('/home/%s/.ssh' % username, int(uidNumber), int(uidNumber))
        os.system('su - %s -c "ssh-keygen -f /home/%s/.ssh/id_dsa -q -t dsa -N \'\'"' % (username, username))
        with open('/home/%s/.ssh/config' % username, 'w') as file:
            print >>file, dedent(
                    """\
                       UserKnownHostsFile /dev/null
                       Host *
                          StrictHostKeyChecking no
                       LogLevel QUIET
                    """)
        os.chown('/home/%s/.ssh/config' % username, int(uidNumber), int(uidNumber))
        os.chmod('/home/%s/.ssh/config' % username, 600)


def user_delete(username):
    """Delete a user from the system"""
    # First delete the user
    try:
        dn = 'uid=%s,ou=People,dc=cluster' % username
        conn.delete_s(dn)
    except Exception, error:
        print error
    # Next delete the group
    try:
        dn = 'cn=%s,ou=Group,dc=cluster' % username
        conn.delete_s(dn)
    except Exception, error:
        print error
    # And delete the users home directory.
    try:
        shutil.rmtree('/home/%s' % username)
    except Exception, error:
        print error


def user_list():
    """List users defined in the system"""
    base_dn = 'ou=People,dc=cluster'
    filter = '(objectclass=person)'
    attrs = ['uid']
    for dn, attrs in conn.search_s( base_dn, ldap.SCOPE_SUBTREE, filter, attrs ):
        print attrs['uid'][0]


def user_reset(username, password):
    """Reset a users password"""
    dn = 'uid=%s,ou=People,dc=cluster' % username
    conn.passwd_s(dn, None, password)


def user_show(username):
    base_dn = 'ou=People,dc=cluster'
    filter = '(uid=%s)' % username
    for dn, attrs in conn.search_s( base_dn, ldap.SCOPE_SUBTREE, filter ):
        print attrs


def user_uidNumber(username):
    """Utility function to get the numeric id from a username"""
    base_dn = 'ou=People,dc=cluster'
    filter = '(uid=%s)' % username
    attrs = ['uidNumber']
    for dn, attrs in conn.search_s( base_dn, ldap.SCOPE_SUBTREE, filter, attrs ):
        return attrs['uidNumber'][0]


def group_list():
    """List groups defined in the system"""
    base_dn = 'ou=Group,dc=cluster'
    filter = '(objectclass=posixGroup)'
    for dn, attrs in conn.search_s( base_dn, ldap.SCOPE_SUBTREE, filter ):
        print attrs['gidNumber'][0], attrs['cn'][0]


def group_delete(groupname):
    """Delete a user from the system"""
    # First delete the user
    try:
        dn = 'cn=%s,ou=Group,dc=cluster' % groupname
        conn.delete_s(dn)
    except Exception, error:
        pass


def group_add(groupname):
    """Add a group to the LDAP"""
    gidNumber = increment_gid()

    # first add the group 
    dn = 'cn=%s,ou=Group,dc=cluster' % groupname
    add_record = [
     ('objectclass', ['top','posixGroup']),
     ('cn', [groupname] ),
     ('gidNumber', [gidNumber])
    ]
    conn.add_s(dn, add_record)


def group_addusers(groupname, username):
    """Add users to a group"""
    dn = 'cn=%s,ou=Group,dc=cluster' % groupname
    mod_attrs = []
    for name in username:
        uidNumber = user_uidNumber(name)
        print name, uidNumber
        mod_attrs.append((ldap.MOD_ADD, 'memberuid', uidNumber))
    conn.modify_s(dn, mod_attrs)
                     

def group_delusers(groupname, username):
    """Remove users from a group"""
    dn = 'cn=%s,ou=Group,dc=cluster' % groupname
    mod_attrs = []
    for name in username:
        uidNumber = user_uidNumber(name)
        print name, uidNumber
        mod_attrs.append((ldap.MOD_DELETE, 'memberuid', uidNumber))
    conn.modify_s(dn, mod_attrs)


def group_show(groupname):
    base_dn = 'ou=Group,dc=cluster'
    filter = '(cn=%s)' % groupname
    for dn, attrs in conn.search_s( base_dn, ldap.SCOPE_SUBTREE, filter ):
        print attrs


@retry(stop_max_delay=10000)
def increment_uid():
    """Generate a new userid"""
    dn = 'cn=uid,dc=cluster'
    filter = 'objectclass=*'
    attrs = ['uidNumber']

    result = conn.search_s( dn, ldap.SCOPE_SUBTREE, filter, attrs)
    uidNumber = result[0][1]['uidNumber'][0]

    mod_attrs = [(ldap.MOD_DELETE, 'uidNumber', uidNumber),
                 (ldap.MOD_ADD, 'uidNumber', str(int(uidNumber)+1))]

    conn.modify_s(dn, mod_attrs)
    return uidNumber

@retry(stop_max_delay=10000)
def increment_gid():
    """Generate a new groupid"""
    dn = 'cn=gid,dc=cluster'
    filter = 'objectclass=*'
    attrs = ['uidNumber']

    try:
        result = conn.search_s( dn, ldap.SCOPE_SUBTREE, filter, attrs)
        gidNumber = result[0][1]['uidNumber'][0]

        mod_attrs = [(ldap.MOD_DELETE, 'uidNumber', gidNumber),
                     (ldap.MOD_ADD, 'uidNumber', str(int(gidNumber)+1))]

        conn.modify_s(dn, mod_attrs)
    except Exception,e :
        print e
        raise
    return gidNumber

