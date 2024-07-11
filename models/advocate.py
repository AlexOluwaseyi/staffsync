#!/usr/bin/python3

"""
Modules, class and function definitions for Engineers
Includes classes for SE, T2, TL, NH
"""

import calendar
import json

from sqlalchemy import Column, Integer, String

import models
from models.employee import Base, Employee
from models.manager import TM
from models.permission import access_level


class SE(Employee, Base):
    """Class definition for SEs
    """
    __tablename__ = 'advocates'
    __table_args__ = {'extend_existing': True}

    reports_to = Column(Integer, nullable=True)
    schedules = Column(String(256))

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
        manager_id = self.reports_to
        manager = models.storage.get(manager_id)
        return manager

    def override_schedule(self, year, month, schedule):
        """Override the scheule for a given year and month"""
        from datetime import datetime
        try:
            schedules_dict = json.loads(self.schedules)
        except (TypeError, json.JSONDecodeError):
            schedules_dict = {}

        year_str = str(year)
        if year_str not in schedules_dict:
            schedules_dict[year_str] = {calendar.month_name[i].upper():
                                        None for i in range(1, 13)}
        schedules_dict[year_str][month.upper()] = schedule
        self.schedules = json.dumps(schedules_dict)
        self.updated_at = datetime.now()

    def generate_schedule(self, year, month):
        """Generate a new schedule for SE for a given year and month"""
        import random

        try:
            schedules_dict = json.loads(self.schedules)
        except (TypeError, json.JSONDecodeError):
            schedules_dict = {}

        year_str = str(year)
        if year_str not in schedules_dict:
            schedules_dict[year_str] = {calendar.month_name[i].upper():
                                        None for i in range(1, 13)}

        if schedules_dict[year_str].get(month.upper()) is not None:
            return f'Schedule for {month} {year} already exists'

        sched_options = {
            "1": "TWTFS",
            "2": "TWTFS",
            "3": "WTFSS",
            "4": "TFSSM",
            "5": "FSSMT",
            "6": "SSMTW",
            "7": "MTWTF"
        }

        """
        Retrieve recent schedules
        (convert None to empty string to avoid errors)
        """
        recent_schedules = [v for v in schedules_dict[year_str].values()
                            if v is not None][-4:]

        if (len(recent_schedules) == 3 and
           sched_options['7'] not in recent_schedules):
            schedules_dict[year_str][month.upper()] = sched_options['7']
        elif (len(recent_schedules) >= 3 and
              sched_options['7'] not in recent_schedules):
            schedules_dict[year_str][month.upper()] = sched_options['7']
        else:
            schedules_dict[year_str][month.upper()] = \
             random.choice(list(sched_options.values()))

        """
        Update self.schedules with the new schedule
        """
        self.schedules = json.dumps(schedules_dict)
        try:
            models.storage.session.add(self)
            models.storage.session.commit()
        except Exception as e:
            models.storage.session.rollback()
            raise e

        return schedules_dict[year_str][month.upper()]

    def get_schedule(self, year, month):
        """Retrieve schedule for SE for a given year and month"""
        try:
            schedules_dict = json.loads(self.schedules)
        except (TypeError, json.JSONDecodeError):
            return 'Schedules data is invalid.'

        year_str = str(year)
        month_str = month.upper()

        if year_str not in schedules_dict:
            return f'Schedule for year {year} not available.'

        if month_str not in schedules_dict[year_str]:
            return f'Schedule for {month} not available.'

        if schedules_dict[year_str][month_str] is None:
            return f'Schedule for {month} {year} not available yet.'
        return f'Schedule for {month} {year} is\
                {schedules_dict[year_str][month_str]}'


class NH(Employee, Base):
    """Class definition for New Hires
    """
    __tablename__ = "advocates"
    __table_args__ = {'extend_existing': True}
    def __init__(self, *args, **kwargs):
        """Initialization for NH
        Inherits from SE and but defines roles, access_level
        """
        super().__init__(*args, **kwargs)
        role = kwargs.get('role', 'NH')
        if role not in access_level:
            raise ValueError(f"Invalid role: {role}")
        self.role = access_level[role].value
        ...


class T2(Employee, Base):
    """Class definition for Tier 2 Engineers
    """
    __tablename__ = "advocates"
    __table_args__ = {'extend_existing': True}

    def __init__(self, *args, **kwargs):
        """Initialization for NH
        Inherits from SE and but defines roles, access_level
        """
        super().__init__(*args, **kwargs)
        role = kwargs.get('role', 'T2')
        if role not in access_level:
            raise ValueError(f"Invalid role: {role}")
        self.role = access_level[role].value
        ...


class TL(Employee, Base):
    """Class definition for Technical Leads
    """
    __tablename__ = "advocates"
    __table_args__ = {'extend_existing': True}


    def __init__(self, *args, **kwargs):
        """Initialization for NH
        Inherits from SE and but defines roles, access_level
        """
        super().__init__(*args, **kwargs)
        role = kwargs.get('role', 'TL')
        if role not in access_level:
            raise ValueError(f"Invalid role: {role}")
        self.role = access_level[role].value
        ...
