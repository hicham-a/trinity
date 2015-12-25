# Create the admin user 
multisite_users.update(
{'admin': {'alias': u'admin',
              'locked': False,
              'roles': ['admin']}
})

