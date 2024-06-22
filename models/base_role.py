#!/usr/bin/python3

from models.base_model import BaseModel
from models.permission import access_level
from sqlalchemy import Column, Integer

class BaseRole(BaseModel):
    """Base class for different roles"""
    role = Column(Integer, nullable=False)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        role = kwargs.get('role', self.__class__.__name__)
        if role not in access_level:
            raise ValueError(f"Invalid role: {role}")
        self.role = access_level[role].value
