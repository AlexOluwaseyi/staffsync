#!/usr/bin/python3
from models.employee import Employee
from models.advocate import Base, SE
from sqlalchemy import Column, String, Integer
import models



class TM(Employee, Base):
    """Class definition for Team Manager"""
    __tablename__ = "managers"
    __table_args__ = {'extend_existing': True}
    reports_to = Column(Integer, nullable=True)
    in_charge_of = Column(String(1024), nullable=True)
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def get_advocates(self):
        """Get the support engineers that report to this manager"""
        advocates_staff_id = []
        advocates_dict = {}
        advocates = models.storage.get_advocates(self.staff_id)
        for advocate in advocates:
            advocates_staff_id.append(advocate.staff_id)
            advocates_dict[advocate.staff_id] = advocate.first_name + ' ' + advocate.last_name
        return advocates_dict

    def set_advocates(self):
        """Get the support engineers that report to this manager"""
        advocates = self.get_advocates()
        self.in_charge_of = list(advocates.keys())


class OM(Employee):
    """Class definition for Operations Manager"""
    __tablename__ = "managers"
    __table_args__ = {'extend_existing': True}

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)


class GM(Employee):
    """Class definition for Global Manager"""
    __tablename__ = "managers"
    __table_args__ = {'extend_existing': True}
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)


class DM(Employee):
    """Class definition for Duty Manager"""
    __tablename__ = "managers"
    __table_args__ = {'extend_existing': True}
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
