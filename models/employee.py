#!/usr/bin/python3

"""
Base module for employee model

Class definition
  - Class Employee
"""

import random
from datetime import datetime
from uuid import uuid4

from flask_bcrypt import Bcrypt
from flask_login import UserMixin
from sqlalchemy import Boolean, Column, DateTime, Integer, String
from sqlalchemy.ext.declarative import declarative_base

import models
from models.permission import access_level, roles_description

time_format = "%Y-%m-%dT%H:%M:%S.%f"
Base = declarative_base()
bcrypt = Bcrypt()


class Employee(UserMixin):
    """Base class for all employees

    Object attributes for all employees:
      - Firstname
      - Lastname
      - Email
      - Default password
      - Staff ID and UUID4()
      - Date of object creation
      - Date of object update
      - Status of object: True for active and False for deactivated
      - Role and role description
      - Access level based on role
      - Annual leave counter

    Object methods:
      - Initialization
      - Deactivate account
      - Reactivate account
      - Update password
      - Reset password
      - Save object
      - Get roles description
      - Get manager object for current employee
      - String representation of object
      - Dictionary representation of object
    argument -- description
    Return: return_description
    """

    domain = 'localhost'
    # __tablename__ = 'employees'

    id = Column(String(60), default=lambda: str(uuid4()))
    staff_id = Column(Integer, primary_key=True, autoincrement=True)
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)
    first_name = Column(String(256), nullable=True)
    last_name = Column(String(256), nullable=True)
    status = Column(Boolean, default=True)
    email = Column(String(256), nullable=False)
    password = Column(String(256), nullable=False)
    name = Column(String(256), nullable=True)
    role = Column(String(16), nullable=False)
    desc = Column(String(128), nullable=False)
    access_level = Column(Integer, nullable=False)
    annual_leave = Column(Integer, default=10)

    def __init__(self, **kwargs):
        """Initializes object with kwargs
        and populate object db table column
        """
        for key, value in kwargs.items():
            if key in {'created_at', 'updated_at'} and isinstance(value, str):
                value = datetime.strptime(value, time_format)
            setattr(self, key, value)
        self.id = kwargs.get('id', str(uuid4()))
        self.created_at = kwargs.get('created_at', datetime.now())
        self.first_name = kwargs.get('first_name', None).strip().title()
        self.last_name = kwargs.get('last_name', None).strip().title()
        self.staff_id = kwargs.get('staff_id')
        self.status = kwargs.get('status', True)

        if self.__class__.__name__ != "Employee":
            role = kwargs.get('role', self.__class__.__name__)
        else:
            role = kwargs.get('role', 'SE')
        if role not in access_level:
            raise ValueError(f"Invalid role: {role}")
        if 'email' not in kwargs:
            if self.first_name and self.last_name:
                self.name = (f"{self.first_name.title()} "
                             f"{self.last_name.title()}")
                email = (f"{self.first_name.lower()}."
                         f"{self.last_name.lower()}@{self.domain}")
                while models.storage.get(email=email) is not None:
                    random_digit = str(random.randint(0, 9))
                    email = (f"{self.first_name.lower()}."
                             f"{self.last_name.lower()}"
                             f"{random_digit}@{self.domain}")
                self.email = email
        if not self.name:
            self.name = f"{self.first_name.title()} {self.last_name.title()}"
        self.role = role
        self.desc = roles_description[role]
        self.access_level = access_level[role]
        self.updated_at = kwargs.get('updated_at', datetime.now())
        self.password = bcrypt.generate_password_hash('default')

    def get_id(self):
        """Get staff_id for object.
        Override get_id in flask
        """
        try:
            return str(self.staff_id)
        except AttributeError:
            raise NotImplementedError("No `staff_id` attribute \
                                      - override `get_id`") from None

    def update_password(self, new_password):
        """Change the default password for user object after creation
        """
        self.password = bcrypt.generate_password_hash(new_password)
        self.save()

    def reset_password(self):
        """Reset password to default password for user object
        """
        self.password = bcrypt.generate_password_hash('default')
        self.save()

    def deactivate(self):
        """Deactivate an account
          - Deletes password to account
          - Sets status to False
        """
        self.password = None
        self.status = False
        self.save()

    def reactivate(self):
        """Reactivate an account
          - Sets password to default
          - Sets status to True
        """
        self.password = bcrypt.generate_password_hash('default')
        self.status = True
        self.save()

    def roles_descr(self):
        """Returns role description for object"""
        return roles_description[self.role]

    def get_manager(self):
        """Get the manager for the object
        Returns manager object
        """
        manager_id = self.reports_to
        if manager_id:
            manager = models.storage.get(manager_id)
            return manager
        else:
            return None

    def save(self):
        """Update user object after changes"""
        self.updated_at = datetime.now()
        models.storage.save()

    def to_dict(self):
        """Converts object to dictionary
          - Convert created_at and updated_at (datetime)
            to time format ("%Y-%m-%dT%H:%M:%S.%f")
          - Deletes _sa_instance_state and password hash from dict
        """
        dict_copy = self.__dict__.copy()
        dict_copy['created_at'] = dict_copy['created_at'].strftime(time_format)
        dict_copy['updated_at'] = dict_copy['updated_at'].strftime(time_format)
        dict_copy['__class__'] = self.__class__.__name__
        del dict_copy['_sa_instance_state']
        del dict_copy['password']
        return dict_copy

    def __str__(self):
        """String representation of object

        return (f"[{self.__class__.__name__}] "
                f"({self.staff_id}) {self.__dict__}")
        """
        return (f"[{self.__class__.__name__}] "
                f"({self.staff_id}) {self.to_dict()}")
