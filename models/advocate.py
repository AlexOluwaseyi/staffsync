#!/usr/bin/python3

from models.base_role import BaseRole
from models.permission import AccessLevel, Permission, access_level
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, String, DateTime, Integer


class SE(BaseRole):
    """Class definition for SEs
    """
    # __tablename__ = 'advocates'

    role = Column(Integer, nullable=False)

    schedule = []

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        role = kwargs.get('role', 'SE')
        if role not in access_level:
            raise ValueError(f"Invalid role: {role}")
        self.role = access_level[role].value
        ...

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
        elif len(self.schedule) >= 3 and sched_options['7'] not in self.schedule[-4:]:
            current_schedule = sched_options['7']
        else:
            current_schedule = random.choice(list(sched_options.values()))
        self.schedule.append(current_schedule)
        return current_schedule


if __name__ == "__main__":
    adv = SE()
    for i in range(12):
        adv.generate_schedule()
    print(adv.schedule)