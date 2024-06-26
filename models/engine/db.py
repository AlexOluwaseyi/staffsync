#!/usr/bin/python3
"""
Contains the class DBStorage
"""

# from models.base_model import Base, BaseModel
from models.employee import Employee, Base
from models.advocate import SE
from models.manager import TM, OM, DM, GM
from sqlalchemy import create_engine
from sqlalchemy.orm import scoped_session, sessionmaker
import models


class DBStorage:
    """
    Interacts with the a particular database
    """
    __engine = None
    __session = None
    _class = [GM, TM, OM, DM, SE]

    # _class = [SUPER_ADMIN, ADMIN, GM, TM,
    #           OM, BE, SUPERVISOR, SME,
    #           TL, T2, SE, NH, VISITORS]

    def __init__(self):
        """Initializes the DB storage class"""
        self.__engine = create_engine("sqlite:///staffsync.db")

        Session = sessionmaker(bind=self.__engine)
        self.__session = Session()

    @property
    def session(self):
        """Returns the current session"""
        return self.__session

    def all(self, cls=None):
        """Returns object dictionary of the data in database"""
        all_dict = {}
        if cls is None or cls is SE:
            objs = self.__session.query(cls).all()
            for obj in objs:
                if obj and hasattr(obj, 'id'):
                    key = "{}.{}".format(obj.__class__.__name__, obj.id)
                    all_dict[key] = obj
        return (all_dict)

    def new(self, obj):
        """Add the object to the current database session"""
        self.__session.add(obj)

    def save(self):
        """Commit all changes of the current database session"""
        self.__session.commit()

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

    def get(self, cls, staff_id):
        """
        Returns the object based on the class name and staff ID, or
        None if not found
        """
        if cls not in self._class:
            return None
        all_cls = models.storage.all(cls)
        for value in all_cls.values():
            if (value.staff_id == staff_id):
                return value
        return None

    def get_manager(self, in_charge_of):
        """
        Returns the manager based on the 'in_charge_of' field
        """
        result = self.__session.query(self._class)\
            .filter_by(in_charge_of=in_charge_of).first()
        return result

    def get_advocates(self, reports_to):
        """
        Returns the manager based on the 'in_charge_of' field
        """
        results = self.__session.query(self._class)\
            .filter_by(reports_to=reports_to)
        return results


# Example usage
if __name__ == "__main__":
    models.storage = DBStorage()
    models.storage.reload()
    from models.employee import Employee

    try:
        emp = Employee(staff_id=3124, role="GM", first_name="John", last_name="Doe", in_charge_of=[1, 2, 3])
        emp.set_name()
        models.storage.new(emp)
        models.storage.save()
        print(f'Role: {emp.role}, Description: {emp.desc}, Access Level: {emp.access_level}, Name: {emp.name}, In Charge Of: {emp.in_charge_of_list}')
    except ValueError as e:
        print(e)

    try:
        adv = Employee(staff_id=3124, first_name="Jane", last_name="Smith", in_charge_of=[4, 5])
        adv.set_manager(1)
        adv.set_name()
        models.storage.new(adv)
        models.storage.save()
        print(f'Role: {adv.role}, Description: {adv.desc}, Access Level: {adv.access_level}, Reports To: {adv.reports_to}, Name: {adv.name}, In Charge Of: {adv.in_charge_of_list}')
    except ValueError as e:
        print(e)