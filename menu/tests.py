
# Create your tests here.
from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from .models import Menu
from datetime import datetime

class MenuTestCase(TestCase):
    def setUp(self):
        self.menu_item = Menu.objects.create(
            name="Margherita Pizza",
            price=9.99
        )
    
    def test_menu_item_creation(self):
        """Test model instance creation"""
        item = Menu.objects.get(id=self.menu_item.id)
        self.assertEqual(item.name, "Margherita Pizza")
        self.assertEqual(item.price, 9.99)
        self.assertIsInstance(item.created, datetime)
        self.assertIsInstance(item.updated, datetime)
    
    def test_menu_list_endpoint(self):
        """Test GET /api/menu/ endpoint"""
        client = APIClient()
        
        # Use namespaced URL name
        response = client.get(reverse('core_api:menu-list'))
        
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 1)
        
        response_data = response.data[0]
        self.assertEqual(response_data['name'], "Margherita Pizza")
        self.assertEqual(float(response_data['price']), 9.99)
        self.assertIn('created', response_data)
        self.assertIn('updated', response_data)
    
    def test_menu_detail_endpoint(self):
        """Test GET /api/menu/<id>/ endpoint"""
        client = APIClient()
        response = client.get(reverse('core_api:menu-detail', args=[self.menu_item.id]))
        
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['name'], "Margherita Pizza")
        self.assertEqual(float(response.data['price']), 9.99)
