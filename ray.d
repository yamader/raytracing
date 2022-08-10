import vec3;

@safe:

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
