#!/usr/bin/python3
"""
Contains the class DBStorage
"""

from models.employee import Employee, Base
from models.advocate import SE
from models.manager import TM, OM, DM, GM
from sqlalchemy import create_engine
from sqlalchemy.orm import scoped_session, sessionmaker
import models
from sqlalchemy.exc import IntegrityError


class DBStorage:
    """
    Interacts with a particular database
    """
    __engine = None
    __session = None
    # _class = ['GM', 'TM', 'OM', 'DM', 'SE']
    _class = [SE]

    def __init__(self):
        """Initializes the DB storage class"""
        self.__engine = create_engine("sqlite:///staffsync.db")
        # Base.metadata.create_all(self.__engine)
        Session = sessionmaker(bind=self.__engine)
        self.__session = Session()

    def get_tables(self):
        from sqlalchemy import inspect
        inspector = inspect(self.__engine)
        print(inspector.get_table_names())

    @property
    def session(self):
        """Returns the current session"""
        return self.__session

    def all(self, cls=None):
        """Returns object dictionary of the data in database"""
        from models.employee import Employee
        all_dict = {}
        if cls is None:
            for class_type in self._class:
                objs = self.__session.query(class_type).all()
                if objs:
                    for obj in objs:
                        if obj and hasattr(obj, 'id'):
                            key = "{}.{}".format(obj.__class__.__name__,
                                                 obj.id)
                            all_dict[key] = obj
        else:
            objs = self.__session.query(cls).all()
            for obj in objs:
                if obj and hasattr(obj, 'id'):
                    key = "{}.{}".format(obj.__class__.__name__, obj.id)
                    all_dict[key] = obj
        return all_dict

    def new(self, obj):
        """Add the object to the current database session"""
        try:
            self.__session.add(obj)
        except IntegrityError as e:
            self.__session.rollback()
            print(f"IntegrityError: {e._message}")

    def save(self):
        """Commit all changes of the current database session"""
        try:
            self.__session.commit()
        except IntegrityError:
            self.__session.rollback()
            print(f"IntegrityError: User with staff id already exist. \
                  Unique constraint applied to staff_id.")

    def delete(self, obj=None):
        """Delete from the current database session obj if not None"""
        if obj is not None:
            self.__session.delete(obj)

    def reload(self):
        """Reloads data from the database"""
        Base.metadata.create_all(self.__engine)
        factory = sessionmaker(bind=self.__engine, expire_on_commit=False)
        Session = scoped_session(factory)
        self.__session = Session

    def close(self):
        """Call remove() method on the private session attribute"""
        self.__session.close()

    def get(self, staff_id=None, cls=None, **kwargs):
        """
        Returns the object based on the class name and matching
        criteria in kwargs, or None if not found. If staff_id
        is provided, it will be included in the filtering.
        """
        if cls is None:
            for class_type in self._class:
                query = self.__session.query(class_type)
                if staff_id is not None:
                    query = query.filter_by(staff_id=staff_id)
                for key, value in kwargs.items():
                    query = query.filter(getattr(class_type, key) == value)
                result = query.first()
                print(result)
                if result:
                    return result
            return None

        if cls is not None and cls not in self._class:
            return None

        # ... (rest of the code)

        if staff_id is not None and not kwargs:
            result = self.__session.query(cls)\
             .filter_by(staff_id=staff_id).first()
        elif kwargs:
            query = self.__session.query(cls)
            for key, value in kwargs.items():
                query = query.filter(getattr(cls, key) == value)
            result = query.all()  # Returns a list
        else:
            return None  # Return None if no filtering criteria provided

        return result

    def get_all_with_reports_to(self, cls, reports_to):
        """
        Returns all objects of class `cls` where staff_id
        is not None and reports_to is `reports_to`.
        """
        if cls not in self._class:
            return None

        query = self.__session.query(cls).filter(cls.staff_id.isnot(None),
                                                 cls.reports_to == reports_to)
        return query.all()
