#!/usr/bin/python3

import unittest
from models.advocate import SE
from models.permission import AccessLevel


class TestAdvocate(unittest.TestCase):
    """Test Case for Advocates"""
    def setUp(self) -> None:
        """Set up objects for test"""
        self.adv = SE(staff_id=1220, role='SE')

    def test_instance(self):
        """Test object instances"""
        self.assertTrue(isinstance(self.adv, SE))

    def test_has_id(self):
        """"test base model init"""
        self.assertTrue(hasattr(self.adv, 'id'))

    def test_has_created_at(self):
        """"test base model init"""
        self.assertTrue(hasattr(self.adv, 'created_at'))

    def test_has_updated_at(self):
        """"test base model init"""
        self.assertTrue(hasattr(self.adv, 'updated_at'))

    def test_has_staff_id(self):
        """"test base model init"""
        self.assertTrue(hasattr(self.adv, 'updated_at'))

    def test_has_role(self):
        """"test base model init"""
        self.assertTrue(hasattr(self.adv, 'role'))

    def test_role(self):
        self.assertEqual(self.adv.role, AccessLevel.SE)


class TestMultipleAdvocates(unittest.TestCase):
    """Test different advocates"""
    def setUp(self):
        from time import sleep
        self.adv1 = SE(staff_id=1220, role='SE')
        sleep(3)
        self.adv2 = SE(staff_id=4219, role='SE')

    def test_instance(self):
        """Test object instances"""
        self.assertTrue(isinstance(self.adv1, SE))
        self.assertTrue(isinstance(self.adv2, SE))

    def test_not_same_id(self):
        """Test uuid4"""
        self.assertNotEqual(self.adv1.id, self.adv2.id)

    def test_not_same_created_at(self):
        """Test creted_at"""
        self.assertNotEqual(self.adv1.created_at, self.adv2.created_at)

    def test_not_same_updated_at(self):
        """Test creted_at"""
        self.assertNotEqual(self.adv1.updated_at, self.adv2.updated_at)

    def test_no_role(self):
        """No roles defined"""
        adv1 = SE('SE')
        self.assertIsNone(adv1.staff_id)
        self.assertEqual(adv1.role, AccessLevel.SE)
