#!/usr/bin/python3

"""
Modules, class and function definitions for Engineers
Includes classes for BE
Other classes to be included: HR, FIN, FD
"""

from sqlalchemy import Column, DateTime, Integer, String
from sqlalchemy.ext.declarative import declarative_base

from models.employee import Base, Employee
from models.permission import AccessLevel, Permission, access_level


class BE(Employee, Base):
    """Class definition for Business Enablement"""
    __tablename__ = "biz_enable"
    __table_args__ = {'extend_existing': True}
    reports_to = Column(Integer, nullable=True)
    in_charge_of = Column(String(1024), nullable=True)
    designation = Column(String(16), nullable=True)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
