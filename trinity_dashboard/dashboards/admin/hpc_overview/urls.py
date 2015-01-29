from django.conf.urls import patterns
from django.conf.urls import url

from . import views


urlpatterns = patterns('',
    url(r'^$', views.IndexView.as_view(), name='index'),
    url(r'^create$', views.CreateClusterView.as_view(), name='create'),
    url(r'^(?P<cluster>[^/]+)/update/$',
        views.UpdateClusterView.as_view(), name='update'),

)
