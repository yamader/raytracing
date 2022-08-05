import std;

void main() {
  enum width = 256;
  enum height = 256;

  auto fout = File("image.ppm", "w");

  fout.write("P3\n", width, " ", height, "\n255\n");

  foreach_reverse(j; 0 .. height) {
    write("scanlines remaining: ", j, " ...");
    foreach(i; 0 .. width) {
      auto r = i / real(width - 1),
           g = j / real(height - 1),
           b = real(.25);

      auto ir = cast(int)(255.999 * r),
           ig = cast(int)(255.999 * g),
           ib = cast(int)(255.999 * b);

      fout.writeln(ir, " ", ig, " ", ib);
    }
    writeln("ok");
  }
}
