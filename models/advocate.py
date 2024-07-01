#!/usr/bin/python3

# from models.base_model import Base
from models.employee import Employee, Base
from models.manager import TM
from models.permission import AccessLevel, Permission, access_level
# from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, String, Integer
import models
import calendar
import json


class SE(Employee, Base):
    """Class definition for SEs
    """
    __tablename__ = 'advocates'
    __table_args__ = {'extend_existing': True}

    reports_to = Column(Integer, nullable=True)
    schedules = Column(String(256))

    # schedule = {'January': None, 'February': None, 'March': None,
    #             'April': None, 'May': None, 'June': None, 'July': None,
    #             'August': None, 'September': None, 'October': None,
    #             'November': None, 'December': None}

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

    def generate_schedule(self, year, month):
        """Generate a new schedule for SE for a given year and month"""
        import random

        try:
            schedules_dict = json.loads(self.schedules)
        except (TypeError, json.JSONDecodeError):
            schedules_dict = {}

        if year not in schedules_dict:
            schedules_dict[year] = {calendar.month_name[i].upper():
                                    None for i in range(1, 13)}

        if schedules_dict[year].get(month.upper()) is not None:
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

        # Retrieve recent schedules
        # (convert None to empty string to avoid errors)
        recent_schedules = [v for v in schedules_dict[year].values()
                            if v is not None][-4:]

        if (len(recent_schedules) == 3 and
           sched_options['7'] not in recent_schedules):
            schedules_dict[year][month.upper()] = sched_options['7']
        elif (len(recent_schedules) >= 3 and
              sched_options['7'] not in recent_schedules):
            schedules_dict[year][month.upper()] = sched_options['7']
        else:
            schedules_dict[year][month.upper()] = \
             random.choice(list(sched_options.values()))

        # Update self.schedules with the new schedule
        self.schedules = json.dumps(schedules_dict)

        return schedules_dict[year][month.upper()]

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

        return schedules_dict[year_str][month_str]


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


if __name__ == '__main__':
    # from models.advocate import SE
    models.storage.reload()
    print('reload success')
    from models.manager import TM
    lily = TM(staff_id=1234)
    seyi = SE(staff_id=1235)
    print('models instantiation success')
    models.storage.reload()
    print('model reload success again')
    models.storage.new(lily)
    models.storage.new(seyi)
    print('new storage object success')
    models.storage.save()
    models.storage.reload()
