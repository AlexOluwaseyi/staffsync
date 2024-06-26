#!/usr/bin/python3

from models.employee import Employee
from models.permission import AccessLevel, Permission, access_level
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, String, DateTime, Integer


class BE(Employee):
    """Class definition for Business Enablement"""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

