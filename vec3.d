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

  Vec3 opUnary(string op)() const => Vec3(e[].map!(op ~ `a`).array);
  Vec3 opBinary(string op, T)(const T rhs) const {
    typeof(e) v = mixin(`e[]`~op~`rhs`);
    return Vec3(v);
  }
  Vec3 opBinaryRight(string op, T)(const T lhs) const {
    typeof(e) v = mixin(`lhs`~op~`e[]`);
    return Vec3(v);
  }
  ref Vec3 opOpAssign(string op, T)(const T rhs) {
    e = mixin(`e[]`~op~`rhs`);
    return this;
  }
  Vec3 opBinary(string op, T: Vec3)(auto ref T rhs) const
      if(op == "+" || op == "-") {
    typeof(e) v = mixin(`e[]`~op~`rhs.e[]`);
    return Vec3(v);
  }
  ref Vec3 opAssign(T: Vec3)(auto ref T rhs) {
    e = rhs.e;
    return this;
  }
  ref Vec3 opOpAssign(string op, T: Vec3)(auto ref T rhs) {
    e = mixin(`e[]`~op~`rhs.e[]`);
    return this;
  }

  string toString() const => e[].map!(to!string).join(" ");
}

real dot(T: Vec3)(auto ref T a, auto ref T b) => a.x*b.x + a.y*b.y + a.z*b.z;
Vec3 cross(T: Vec3)(auto ref T a, auto ref T b) => Vec3(a.y*b.z - a.z*b.y,
                                                        a.z*b.x - a.x*b.z,
                                                        a.x*b.y - a.y*b.x);
