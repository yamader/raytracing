import std;
import vec3;
import ray;

@safe:

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
