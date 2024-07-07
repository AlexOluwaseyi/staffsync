#!/usr/bin/python3

from models.employee import Employee, Base
from models.permission import AccessLevel, Permission, access_level
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, String, DateTime, Integer


class BE(Employee, Base):
    """Class definition for Business Enablement"""
    __tablename__ = "biz_enable"
    __table_args__ = {'extend_existing': True}
    reports_to = Column(Integer, nullable=True)
    in_charge_of = Column(String(1024), nullable=True)
    designation = Column(String(16), nullable=True)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
