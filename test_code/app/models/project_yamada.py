from typing import List
from typing import Optional
from sqlalchemy import ForeignKey
from sqlalchemy import String
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.orm import Mapped
from sqlalchemy.orm import mapped_column
from sqlalchemy.orm import relationship

#ベースデータベースをインポート
from base import BaseDatabase, database

class Parent(Base):
    __tablename__ = 'parent'  # テーブル名の作成
    id = Column(Integer, primary_key=True)  # データログid設定：主キー制約
    age = Column(Float)
    name = Column(String)

    children = relationship('Child', backref='parent')  # Childテーブルとのリレーション設定

    def __init__(self, age, name):
        self.age = age
        self.name = name


class Child(Base):
    __tablename__ = 'child'  # テーブル名の作成
    id = Column(Integer, primary_key=True)  # データログid設定：主キー制約
    ch_age = Column(Float)
    code_school = Column(String, ForeignKey('school.code_school'))
    id_Parent = Column(Integer, ForeignKey('parent.id'))  # 外部キー設定

    # parents = relationship('Parent', backref='child') #backrefのため記載不要※back_populatesの場合は要記載
    # schools = relationship('School', backref='child') #backrefのため記載不要※back_populatesの場合は要記載

    def __init__(self, ch_age, code_school, id_Parent):
        self.ch_age = ch_age
        self.code_school = code_school
        self.id_Parent = id_Parent


class School(Base):
    __tablename__ = 'school'
    code_school = Column(String, primary_key=True)
    type = Column(String)

    childen = relationship('Child', backref='school')  # Parentクラスとの関連付け

    def __init__(self, code_school, type):
        self.code_school = code_school
        self.type = type


def init_DB():
    Base.metadata.create_all(bind=engine)  # DB作成/初期化


init_DB()
