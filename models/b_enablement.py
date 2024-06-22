#!/usr/bin/python3

from models.base_model import Base, BaseModel
from models.permission import AccessLevel, Permission, access_level
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, String, DateTime, Integer


class BE(BaseModel):
    """Class definition for SEs
    """
    # __tablename__ = 'advocates'

    role = Column(Integer, nullable=False)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        role = kwargs.get('role', 'BE')
        if role not in access_level:
            raise ValueError(f"Invalid role: {role}")
        self.role = access_level[role].value
        ...
