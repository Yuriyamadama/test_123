import datetime

from sqlalchemy import Column, DateTime, Integer, String, UniqueConstraint, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

import settings

#initial setting
class Database(object):
    def __init__(self) -> None:
        #初期でcreate engineを作成
        self.engine = create_engine(f"sqlite:///{settings.DB_NAME}")
        #関数を定義
        self.connect_db()
        #二つのattributeをinitで追加

    #connect_dbはここで定義。　
    def connect_db(self) -> sessionmaker:
        #なければ作る
        Base.metadata.create_all(self.engine)
        #make session
        session = sessionmaker(self.engine)
        #ここでエンジンを呼び出して、セッションを作成
        return session()

#baseはライブラリから
Base = declarative_base()
#時間をかけて理解することを恐れない。
#gpt→それぞれをきじょうとネットで調べる

#定義したDatabaseをここで定義
database = Database()

#データの作成
#呼び出し専門なので、アブストラクトとする
#baseを継承
class BaseDatabase(Base):
    __abstract__ = True
    #primary keyとして
    id = Column(Integer, primary_key=True, nullable=False)
    #現在時間を書き込む
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    ##onupdateで、updateされた時間を確認
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)