#!/usr/bin/python3

from uuid import uuid4
from datetime import datetime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, String, DateTime, Integer, Boolean
from flask import session
import models


time = "%Y-%m-%dT%H:%M:%S.%f"
Base = declarative_base()


class BaseModel:
    """
    BaseModel class definition
    """
    id = Column(String(60))
    staff_id = Column(Integer, primary_key=True, nullable=True)
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, default=datetime.now)
    first_name = Column(String(256), nullable=True)
    last_name = Column(String(256), nullable=True)
    is_active = Column(Boolean, default=True)
    email = Column(String(256), nullable=True)
    password = Column(String(256), nullable=True)
    name = Column(String(256), nullable=True)

    def __init__(self, *args, **kwargs):
        """Initializer for BaseModel class"""
        if kwargs:
            for key, value in kwargs.items():
                if key != "__class__":
                    setattr(self, key, value)
            if kwargs.get("created_at", None) and type(self.created_at) is str:
                self.created_at = datetime.strptime(kwargs["created_at"], time)
            else:
                self.created_at = datetime.now()
            if kwargs.get("updated_at", None) and type(self.updated_at) is str:
                self.updated_at = datetime.strptime(kwargs["updated_at"], time)
            else:
                self.updated_at = datetime.now()
            if kwargs.get("staff_id", None):
                self.staff_id = kwargs['staff_id']
            else:
                self.staff_id = None
            if kwargs.get("id", None) is None:
                self.id = str(uuid4())
            if kwargs.get("is_active", None) is None:
                self.is_active = True
        else:
            self.id = str(uuid4())
            self.staff_id = None
            self.created_at = datetime.now()
            self.updated_at = self.created_at
            self.is_active = True

    def set_name(self):
        """Set display name based on first and last name"""
        fullname = self.first_name + ' ' + self.last_name
        self.name = fullname

    def __str__(self):
        """String Representation of the BaseModel Object"""
        return "[{}] ({}) {}".format(self.__class__.__name__,
                                     self.id, self.__dict__)

    def save(self):
        """Updates the attribute 'updated_at' with the current datetime"""
        self.updated_at = datetime.now()
        models.storage.new(self)
        models.storage.save()

    def to_dict(self):
        """Method to convert BaseModel class to dict"""
        new_dict = self.__dict__.copy()
        if "created_at" in new_dict:
            new_dict["created_at"] = new_dict["created_at"].strftime(time)
        if "updated_at" in new_dict:
            new_dict["updated_at"] = new_dict["updated_at"].strftime(time)
        new_dict["__class__"] = self.__class__.__name__
        return (new_dict)
