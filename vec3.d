import std;

@safe:

alias Point3 = Vec3;
alias Color = Vec3;

struct Vec3 {
  real[3] e;

  this(const real[] init) { e = init; }
  this(const real e0,
       const real e1,
       const real e2) {
    e = [e0, e1, e2];
  }

  auto x() const => e[0];
  auto y() const => e[1];
  auto z() const => e[2];
  auto ref _x() => e[0];
  auto ref _y() => e[1];
  auto ref _z() => e[2];

  real lenSquared() const => x*x + y*y + z*z;
  real len() const => lenSquared.sqrt;
  Vec3 unit() const => this / len;
  real dot(const Vec3 v) const => x*v.x + y*v.y + z*v.z;
  Vec3 cross(const Vec3 v) const => Vec3(y*v.z - z*v.y,
                                         z*v.x - x*v.z,
                                         x*v.y - y*v.x);

  Vec3 opUnary(string op)() const => Vec3(e[].map!(op ~ `a`).array);
  Vec3 opBinary(string op, T)(const T rhs) const {
    typeof(e) v = mixin(`e[]`~op~`rhs`);
    return Vec3(v);
  }
  Vec3 opBinaryRight(string op, T)(const T lhs) const {
    typeof(e) v = mixin(`lhs`~op~`e[]`);
    return Vec3(v);
  }
  Vec3 opOpAssign(string op, T)(const T rhs) {
    e = mixin(`e[]`~op~`rhs`);
    return this;
  }
  Vec3 opBinary(string op)(const Vec3 rhs) const
      if(op == "+" || op == "-") {
    typeof(e) v = mixin(`e[]`~op~`rhs.e[]`);
    return Vec3(v);
  }
  Vec3 opAssign(const Vec3 rhs) {
    e = rhs.e;
    return this;
  }
  Vec3 opOpAssign(string op)(const Vec3 rhs) {
    e = mixin(`e[]`~op~`rhs.e[]`);
    return this;
  }

  string toString() const => e[].map!(to!string).join(" ");
}
