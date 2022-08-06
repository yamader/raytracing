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

class Ray {
private:
  Point3 _orig;
  Vec3 _dir;

public:
  this(const Point3 origin, const Vec3 direction) {
    _orig = origin;
    _dir = direction;
  }

  Point3 orig() const => _orig;
  Vec3 dir() const => _dir;

  Point3 at(real t) const => _orig + t*_dir;
}

void writeColor(ref File f, Color c) {
  f.writeln(
    cast(int)(255.999 * c.x), " ",
    cast(int)(255.999 * c.y), " ",
    cast(int)(255.999 * c.z));
}

real hitShape(const Ray r, const Point3 center, real rad) {
  // (-b - sqrt(b*b - 4*a*c)) / (2*a)
  // ==
  // (-b/2 - sqrt((b/2)*(b/2) - a*c)) / a
  Vec3 oc = r.orig - center;
  auto a = r.dir.lenSquared;
  auto b_half = oc.dot(r.dir);
  auto c = oc.lenSquared - rad*rad;
  auto discriminant = b_half*b_half - a*c; // 英: 判別式
  if(discriminant < 0)
    return -1;
  else
    return (-b_half - discriminant.sqrt) / a;
}

Color rayColor(const Ray r) {
  auto t = r.hitShape(Point3(0, 0, -1), 0.5);
  if(t > 0.) {
    Vec3 N = (r.at(t) - Vec3(0, 0, -1)).unit;
    return 0.5*Color(N.x+1, N.y+1, N.z+1);
  }
  t = 0.5*(r.dir.unit.y+1.);
  return (1-t)*Color(1, 1, 1) + t*Color(0.5, 0.7, 1);
}

void main() {
  enum aspect_ratio = 16 / 9.;
  enum width = 400;
  enum height = cast(int)(width / aspect_ratio);

  auto fout = File("image.ppm", "w");
  fout.write("P3\n", width, " ", height, "\n255\n");

  auto vph = 2.;
  auto vpw = aspect_ratio * vph;
  auto focal = 1.;

  auto orig = Point3(0, 0, 0);
  auto horiz = Vec3(vpw, 0, 0);
  auto vert = Vec3(0, vph, 0);
  auto lowerLeftCorner = orig
    - horiz / 2 // x
    - vert / 2  // y
    - Vec3(0, 0, focal); // focal

  foreach_reverse(j; 0 .. height) {
    write(j, "...");
    foreach(i; 0 .. width) {
      auto u = i / (width-1.);
      auto v = j / (height-1.);
      auto r = new Ray(orig, lowerLeftCorner + u*horiz + v*vert - orig);
      auto c = r.rayColor;
      fout.writeColor(c);
    }
  }
  writeln("ok");
}
