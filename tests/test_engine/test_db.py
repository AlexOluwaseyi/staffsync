#!/usr/bin/python3
"""
Contains the TestDBStorageDocs and TestDBStorage classes
"""
import unittest
from unittest import mock
from models.base_model import Base
from models.advocate import SE
from models.manager import TM
from models.engine.db import DBStorage
import models
import random

staff_id = random.randint(1, 3000)


class TestDBStorage(unittest.TestCase):
    """
    Test the DBStorage class
    """
    def test_all_returns_dict(self):
        """Test that all returns a dictionary"""
        self.assertIs(type(models.storage.all()), dict)
        users = models.storage.all()
        print(all)
        # self.assertIs(type(models.storage.all(SE)), dict)

    def test_new_method(self):
        """Test that all returns a dictionary"""
        user = SE()
        user.email = "sale@wnourish.com"
        user.username = "sales"
        models.storage.new(user)
        self.assertIn(user, models.storage._DBStorage__session.new)

    def test_new_TM(self):
        """Test that all returns a dictionary"""
        user = TM()
        user.email = "sale@wnourish.com"
        user.username = "sales"
        models.storage.new(user)
        self.assertIn(user, models.storage._DBStorage__session.new)

    def test_save(self):
        """Test the save method"""
        usr = TM(staff_id=staff_id)
        usr.email = "sale@wnourish.com"
        usr.username = "sales"
        models.storage.new(usr)
        models.storage.save()
        user_id = usr.staff_id
        user = models.storage._DBStorage__session.query(TM)\
            .filter_by(staff_id=user_id).first()
        self.assertIsNotNone(user)

    def test_delete(self):
        """Test the delete method"""
        user = SE(staff_id=staff_id)
        user.email = "sale@wnourish.com"
        user.username = "sales"
        models.storage.new(user)
        models.storage.save()
        models.storage.delete(user)
        self.assertIn(user, models.storage._DBStorage__session.deleted)

    def test_delete(self):
        """Test the delete method"""
        user = TM(staff_id=staff_id)
        user.email = "sale@wnourish.com"
        user.username = "sales"
        models.storage.new(user)
        models.storage.save()
        models.storage.delete(user)
        self.assertIn(user, models.storage._DBStorage__session.deleted)

    def setUp(self):
        """Set up a temporary database and a test session"""
        self.storage = DBStorage()

    def tearDown(self):
        self.storage.close()
    #     """Tear down the test session and drop the database"""
        # self.storage.__session.close()
        # Base.metadata.drop_all(self.storage._DBStorage__engine)

    def test_get_se(self):
        """Test that get() retrieves the correct SE object"""
        new_se = SE(staff_id=staff_id)
        models.storage.new(new_se)
        models.storage.save()
        # print(f'staff_id - {staff_id}')
        get_se = self.storage.get(SE, staff_id)
        # print(get_se.desc)
        self.assertIsNotNone(get_se)
        self.assertEqual(get_se.staff_id, staff_id)
        self.assertEqual(get_se.first_name, None)

    def test_get_without_cls(self):
        """Test that get() retrieves the correct object without cls"""
        new_se = SE(staff_id=staff_id)
        models.storage.new(new_se)
        models.storage.save()
        # print(f'staff_id - {staff_id}')
        get_se = self.storage.get(staff_id)
        # print(get_se.desc)
        self.assertIsNotNone(get_se)
        self.assertEqual(get_se.staff_id, staff_id)
        self.assertEqual(get_se.first_name, None)

    def test_get_se_reports_to(self):
        from models.manager import TM
        """Test that get() retrieves the correct SE object"""
        # new_man = TM(staff_id=staff_id, designation='TL')
        # models.storage.new(new_man)
        # models.storage.save()
        get_se = self.storage.get(TM, access_level=4)
        # print(f'\n len of get_se - {len(get_se)}\n')
        for get_se_each in get_se:
            # print(get_se_each.to_dict())
            self.assertIsNotNone(get_se_each)
            # self.assertEqual(get_se_each.staff_id, staff_id)
            # self.assertEqual(get_se_each.first_name, None)

    def test_get_non_existent_se(self):
        """Test that get() returns None for a non-existent SE object"""
        se = self.storage.get(SE, 999)
        self.assertIsNone(se)

    def test_TM(self):
        """Test TM and tole"""
        from models.permission import access_level
        lily = TM(staff_id=1003, role='TM')
        self.assertIsNotNone(lily)
        self.assertEqual(lily.access_level, access_level[lily.role])
