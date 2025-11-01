"""
URL mapping for user API
"""
from django.urls import path

from user import views

# used for reverse URL mapping
app_name = 'user'

urlpatterns = [
    path('create/', views.CreateUserView.as_view(), name='create')
]
