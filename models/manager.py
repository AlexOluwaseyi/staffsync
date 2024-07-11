#!/usr/bin/python3

"""
Modules, class and function definitions for Managers
Includes classes for TM, DM, OM, GM
"""

import json

from sqlalchemy import Column, Integer, String

import models
from models.employee import Base, Employee
from models.permission import access_level


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
        role = kwargs.get('role', 'TM')
        if role not in access_level:
            raise ValueError(f"Invalid role: {role}")
        self.role = access_level[role].value

    def get_advocates(self):
        """Get all support engineers that
        report to based on manager staff_id
        """
        from models.advocate import SE
        advocates_dict = {}
        employees = models.storage.all()
        if employees:
            for advocate in employees.values():
                if advocate.reports_to == self.staff_id:
                    advocates_dict[advocate.staff_id] = advocate
        else: 
            return None
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
        role = kwargs.get('role', 'OM')
        if role not in access_level:
            raise ValueError(f"Invalid role: {role}")
        self.role = access_level[role].value


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
        role = kwargs.get('role', 'GM')
        if role not in access_level:
            raise ValueError(f"Invalid role: {role}")
        self.role = access_level[role].value


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
        role = kwargs.get('role', 'DM')
        if role not in access_level:
            raise ValueError(f"Invalid role: {role}")
        self.role = access_level[role].value
