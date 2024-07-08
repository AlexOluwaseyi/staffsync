#!/usr/bin/python3

"""
Module for definition of access level, permissions
(based on access level), roles and roles description
"""

from enum import IntEnum


class AccessLevel(IntEnum):
    """
    Access level enumeration definition
    """
    SUPER_ADMIN = 12
    MGMT = 11
    GM = 10
    OM = 9
    BE = 8
    TM = 7
    DM = 6
    SME = 5
    TL = 4
    T2 = 3
    SE = 2
    NH = 1
    VIS = 0


"""
String literal description for organizational roles
"""
roles_description = {
    'Super Admin': "Super Admin",
    'MGMT': "Admin.",
    "BE": "Business Enablement",
    "GM": "Global Manager",
    'TM': "Team Manager",
    'DM': "Duty Manager",
    'OM': "Operations Manager",
    'SME': "Subject Matter Experts",
    'TL': "Technical Lead",
    'T2': "Tier 2 Support Advocate",
    'SE': "Tenured Advocate",
    'NH': "New Hires",
    'VIS': "Visitors"
}


"""
Create a dictionary to map roles to access levels
"""
access_level = {
    "SUPER ADMIN": AccessLevel.SUPER_ADMIN,
    "MGMT": AccessLevel.MGMT,
    "GM": AccessLevel.GM,
    "TM": AccessLevel.TM,
    "OM": AccessLevel.OM,
    "DM": AccessLevel.DM,
    "BE": AccessLevel.BE,
    "TM": AccessLevel.TM,
    "SME": AccessLevel.SME,
    "TL": AccessLevel.TL,
    "T2": AccessLevel.T2,
    "SE": AccessLevel.SE,
    "NH": AccessLevel.NH,
    "VIS": AccessLevel.VIS
}


"""
Principle of least Privilege (POLP)
Not yet implemented
"""


class Permission:
    """
    VIEW_REPORTS = AccessLevel.EMPLOYEE
    EDIT_REPORTS = AccessLevel.MANAGER
    DELETE_REPORTS = AccessLevel.ADMIN
    CONFIGURE_SYSTEM = AccessLevel.SUPER_ADMIN
    """
    pass


"""
Available employee schedule options.
"""
sched_options = {
            "1": "TWTFS",
            "2": "TWTFS",
            "3": "WTFSS",
            "4": "TFSSM",
            "5": "FSSMT",
            "6": "SSMTW",
            "7": "MTWTF"
        }
