# ドキュメントは説明がめちゃくちゃわかりにくくて理解不能

class User(TimeStampedModel):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, autoincrement=True)
    first_name = Column(String(80), nullable=False)
    last_name = Column(String(80), nullable=False)
    email = Column(String(320), nullable=False, unique=True)

    # (1)対になる、relation shipを設定　listではない、1:1と指定
    preference = Relationship("Preference", back_populates="user", uselist=False, passive_deletes=True)
    """passive_deletes=True は、SQLAlchemyがデフォルトで行う親子関係の同期処理を無効化するためのオプションです。
    通常、親エンティティが削除されると、SQLAlchemy は関連する子エンティティに対しても削除操作を行おうとします。
    しかし、passive_deletes=True を設定すると、SQLAlchemyは親エンティティが削除されたときに自動的に子エンティティに対して何も行わず、
    データベースの ondelete 設定に削除の処理を委ねます。"""

    # (2)対になる、relation shipを設定
    addresses = Relationship("Address", back_populates="user", passive_deletes=True)
    """uselist=Falseが(1)と違ってない"""

    # (3)対になる、relation shipを設定
    roles = Relationship("Role", secondary="user_roles", back_populates="users", passive_deletes=True)

    def __repr__(self):
        return f"{self.__class__.__name__}, name: {self.first_name} {self.last_name}"


# (1)one to one
# ユーザ(user)に一つの設定情報(preference)
class Preference(TimeStampedModel):
    __tablename__ = "preferences"

    id = Column(Integer, primary_key=True, autoincrement=True)
    language = Column(String(80), nullable=False)
    currency = Column(String(3), nullable=False)

    # one to one
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True, unique=True)
    """ondelete="CASCADE" は、データベースレベルで外部キー（Foreign Key）に対して設定するオプションです。
    このオプションが設定されると、親テーブルのレコードが削除されたときに、そのレコードに関連する子テーブルのレコードも自動的に削除されます。
    つまり、親テーブル（この場合は users テーブル）の id が削除されると、子テーブル（この場合は preferences テーブル）の関連する user_id を持つレコードも一緒に削除されます。"""
　　
    # 対になる、relation shipを設定 ※カラムではない
    user = Relationship("User", back_populates="preference")

# (2)one to many
# ユーザ(user)に複数の住所情報(addresses)

class Address(TimeStampedModel):
    __tablename__ = "addresses"

    id = Column(Integer, primary_key=True, autoincrement=True)
    road_name = Column(String(80), nullable=False)
    postcode = Column(String(80), nullable=False)
    city = Column(String(80), nullable=False)

    # one to many同じように親を消したらこれも消えるように
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)

    # 対になる、relation shipを設定 ※カラムではない
    user = Relationship("User", back_populates="addresses")

    def __repr__(self):
        return f"{self.__class__.__name__}, name: {self.city}"

# (2)many to many
# 複数ユーザ(user)に複数の権限情報(role)


class Role(Model):
    __tablename__ = "roles"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(80), nullable=False)
    slug = Column(String(80), nullable=False, unique=True)

    users = Relationship("User", secondary="user_roles", back_populates="roles", passive_deletes=True)

    def __repr__(self):
        return f"{self.__class__.__name__}, name: {self.name}"


class UserRole(TimeStampedModel):
    __tablename__ = "user_roles"

    # 片方が消えたらもう片方も消えるように
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    role_id = Column(Integer, ForeignKey("roles.id", ondelete="CASCADE"), primary_key=True)