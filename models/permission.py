#!/usr/bin/python3

from enum import IntEnum


class AccessLevel(IntEnum):
    SUPER_ADMIN = 0
    ADMIN = 1
    GM = 2
    TM = 3
    OM = 3
    BE = 3
    SUPERVISOR = 4
    SME = 5
    TL = 6
    T2 = 7
    SE = 8
    NH = 9
    VISITORS = 10


# Create a dictionary to map roles to access levels
access_level = {
    "SUPER_ADMIN": AccessLevel.SUPER_ADMIN,
    "ADMIN": AccessLevel.ADMIN,
    "GM": AccessLevel.GM,
    "TM": AccessLevel.TM,
    "OM": AccessLevel.OM,
    "BE": AccessLevel.BE,
    "SUPERVISOR": AccessLevel.SUPERVISOR,
    "SME": AccessLevel.SME,
    "TL": AccessLevel.TL,
    "T2": AccessLevel.T2,
    "SE": AccessLevel.SE,
    "NH": AccessLevel.NH,
    "VISITORS": AccessLevel.VISITORS
}


class Permission:
    """
    VIEW_REPORTS = AccessLevel.EMPLOYEE
    EDIT_REPORTS = AccessLevel.MANAGER
    DELETE_REPORTS = AccessLevel.ADMIN
    CONFIGURE_SYSTEM = AccessLevel.SUPER_ADMIN
    """
    pass
