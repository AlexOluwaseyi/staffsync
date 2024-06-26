import unittest
# from models.base_model import BaseModel
from models.employee import Employee


class TestEmployeeModel(unittest.TestCase):
    """Base Model test cases"""

    @classmethod
    def setUpClass(self):
        self.base1 = Employee(staff_id=4219)

    def test_instance(self):
        """Test object instances"""
        self.assertTrue(isinstance(self.base1, Employee))

    def test_has_id(self):
        """"test base model init"""
        self.assertTrue(hasattr(self.base1, 'id'))

    def test_has_created_at(self):
        """"test base model init"""
        self.assertTrue(hasattr(self.base1, 'created_at'))

    def test_has_updated_at(self):
        """"test base model init"""
        self.assertTrue(hasattr(self.base1, 'updated_at'))

    def test_has_staff_id(self):
        """"test base model init"""
        self.assertTrue(hasattr(self.base1, 'updated_at'))

    def test_no_staff_id(self):
        """No staff_id"""
        base1 = Employee()
        self.assertIsNone(base1.staff_id)
