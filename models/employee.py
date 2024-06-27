#!/usr/bin/python3

from uuid import uuid4
from datetime import datetime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, String, DateTime, Integer, Boolean
import models
from models.permission import access_level, roles_description

time_format = "%Y-%m-%dT%H:%M:%S.%f"
Base = declarative_base()


class Employee:
    domain = 'tek-experts.com'
    # __tablename__ = 'employees'

    id = Column(String(60), primary_key=True, default=lambda: str(uuid4()))
    staff_id = Column(Integer, nullable=True, unique=True)
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)
    first_name = Column(String(256), nullable=True)
    last_name = Column(String(256), nullable=True)
    is_active = Column(Boolean, default=True)
    email = Column(String(256), nullable=True)
    password = Column(String(256), nullable=True)
    name = Column(String(256), nullable=True)
    role = Column(String(16), nullable=False)
    desc = Column(String(128), nullable=False)
    access_level = Column(Integer, nullable=False)

    def __init__(self, **kwargs):
        for key, value in kwargs.items():
            if key in {'created_at', 'updated_at'} and isinstance(value, str):
                value = datetime.strptime(value, time_format)
            setattr(self, key, value)
        self.id = kwargs.get('id', str(uuid4()))
        self.created_at = kwargs.get('created_at', datetime.now())
        self.first_name = kwargs.get('first_name', None)
        self.last_name = kwargs.get('last_name', None)
        self.staff_id = kwargs.get('staff_id')
        self.is_active = kwargs.get('is_active', True)

        if self.__class__.__name__ != "Employee":
            role = kwargs.get('role', self.__class__.__name__)
        else:
            role = kwargs.get('role', 'SE')
        if role not in access_level:
            raise ValueError(f"Invalid role: {role}")
        if self.first_name is not None and self.last_name is not None:
            self.name = " ".join([self.first_name, self.last_name])
            email_id = '.'.join([self.first_name.lower(),
                                 self.last_name.lower()])
            self.email = f"{email_id}@{self.domain}"
        self.role = role
        self.desc = roles_description[role]
        self.access_level = access_level[role]
        self.updated_at = kwargs.get('updated_at', datetime.now())

    def set_name(self):
        if self.first_name is not None and self.last_name is not None:
            self.name = " ".join([self.first_name, self.last_name])
            self.updated_at = datetime.now()

    def __str__(self):
        return f"[{self.__class__.__name__}] ({self.id}) {self.__dict__}"

    def save(self):
        self.updated_at = datetime.now()
        models.storage.new(self)
        models.storage.save()

    def to_dict(self):
        # for '_sa_instance'
        dict_copy = self.__dict__.copy()
        dict_copy['created_at'] = dict_copy['created_at'].strftime(time_format)
        dict_copy['updated_at'] = dict_copy['updated_at'].strftime(time_format)
        dict_copy['__class__'] = self.__class__.__name__
        del dict_copy['_sa_instance_state']
        return dict_copy

    def roles_descr(self):
        return roles_description[self.role]
