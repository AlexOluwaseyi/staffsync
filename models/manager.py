#!/usr/bin/python3

"""
Modules, class and function definitions for Managers
Includes classes for TM, DM, OM, GM
"""

import json

from sqlalchemy import Column, Integer, String

import models
from models.employee import Base, Employee


class TM(Employee, Base):
    """Class definition for Team Manager"""

    __tablename__ = "managers"
    __table_args__ = {'extend_existing': True}

    reports_to = Column(Integer, nullable=True)
    in_charge_of = Column(String(1024), nullable=True)
    designation = Column(String(16), nullable=True)

    def __init__(self, *args, **kwargs):
        """Initializes the object
        Inherits from Employee object"""
        super().__init__(*args, **kwargs)
        self.designation = kwargs.get('designation', None)
        self.set_advocates()

    def get_advocates(self):
        """Get all support engineers that
        report to based on manager staff_id
        """
        from models.advocate import SE
        advocates_staff_id = []
        advocates_dict = {}
        advocates = models.storage.get(SE, reports_to=self.staff_id)
        for advocate in advocates:
            advocates_staff_id.append(advocate.staff_id)
            advocates_dict[advocate.staff_id] = advocate.first_name \
                + ' ' + advocate.last_name
        return advocates_dict

    def set_advocates(self):
        """Get the employees that report to this manager,
        and save to database column as json"""
        advocates = self.get_advocates()
        try:
            self.in_charge_of = json.dumps(advocates.keys())
        except (TypeError, json.JSONDecodeError):
            self.in_charge_of = {}


class OM(Employee, Base):
    """Class definition for Operations Manager
    (Would be modified to inherit from TM class instead,
    to prevent repetition - DRY)
    """
    __tablename__ = "managers"
    __table_args__ = {'extend_existing': True}
    reports_to = Column(Integer, nullable=True)
    in_charge_of = Column(String(1024), nullable=True)
    designation = Column(String(16), nullable=True)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)


class GM(Employee, Base):
    """Class definition for Global Manager
    (Would be modified to inherit from TM class instead,
    to prevent repetition - DRY)
    """
    __tablename__ = "managers"
    __table_args__ = {'extend_existing': True}
    reports_to = Column(Integer, nullable=True)
    in_charge_of = Column(String(1024), nullable=True)
    designation = Column(String(16), nullable=True)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)


class DM(Employee, Base):
    """Class definition for Duty Manager
    (Would be modified to inherit from TM class instead,
    to prevent repetition - DRY)
    """
    __tablename__ = "managers"
    __table_args__ = {'extend_existing': True}
    reports_to = Column(Integer, nullable=True)
    in_charge_of = Column(String(1024), nullable=True)
    designation = Column(String(16), nullable=True)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
