from django.conf.urls import patterns
from django.conf.urls import url

from . import views


urlpatterns = patterns('',
    url(r'^$', views.IndexView.as_view(), name='index'),
    url(r'^edit$', views.EditView.as_view(), name='edit'),
)
