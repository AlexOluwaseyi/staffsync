#!/usr/bin/python3

from models.base_model import Base
from models.employee import Employee
from models.manager import TM
from models.permission import AccessLevel, Permission, access_level
# from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, String, Integer
import models


class SE(Employee, Base):
    """Class definition for SEs
    """
    __tablename__ = 'advocates'
    __table_args__ = {'extend_existing': True}

    reports_to = Column(Integer, nullable=True)

    schedule = []

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        ...

    def set_manager(self, manager_id):
        """Set the manager for SE"""
        if self.role == 'TL':
            manager = models.storage.get(TM, designation='TL')
            if manager:
                self.reports_to = manager.staff_id
            else:
                self.reports_to = None  # Handle case where no manager is found
        elif self.role == 'NH':
            manager = models.storage.get(TM, designation='NH')
            if manager:
                self.reports_to = manager.staff_id
            else:
                self.reports_to = None
        else:
            manager = models.storage.get(TM, manager_id)
            if manager:
                self.reports_to = manager.staff_id
            else:
                self.reports_to = None

    def get_manager(self):
        """Get the manager for SE"""
        return self.reports_to

    def generate_schedule(self):
        """Generate a new schedule for SE"""
        import random
        sched_options = {
            "1": "TWTFS",
            "2": "TWTFS",
            "3": "WTFSS",
            "4": "TFSSM",
            "5": "FSSMT",
            "6": "SSMTW",
            "7": "MTWTF"
        }
        if len(self.schedule) == 3 and sched_options['7'] not in self.schedule:
            current_schedule = sched_options['7']
        elif (len(self.schedule) >= 3 and
              sched_options['7'] not in self.schedule[-4:]):
            current_schedule = sched_options['7']
        else:
            current_schedule = random.choice(list(sched_options.values()))
        self.schedule.append(current_schedule)
        return current_schedule


class T2(Employee):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        role = kwargs.get('role', 'T2')
        if role not in access_level:
            raise ValueError(f"Invalid role: {role}")
        self.role = access_level[role].value
        ...


# class TL(BaseRole):
#     def __init__(self, *args, **kwargs):
#         super().__init__(*args, **kwargs)
#         role = kwargs.get('role', 'TL')
#         if role not in access_level:
#             raise ValueError(f"Invalid role: {role}")
#         self.role = access_level[role].value
#         ...
