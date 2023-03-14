prompt: "make me a skateboard bearing"

output:
```
rotate_extrude($fn=50){
  difference() {
    translate([10, 0, 0]){
      square([10, 9], center=true);
    }

    translate([15, 0, 0]){
      circle(r=5);
    }
  }
  difference() {
    translate([20, 0, 0]){
      square([10, 9], center=true);
    }

    translate([15, 0, 0]){
      circle(r=5);
    }
  }
}
for (i = [1 : abs(1) : 10]) {
  rotate([0, 0, (i * 36)]){
    translate([15, 0, 0]){
      {
        $fn=50;    //set sides to 50
        sphere(r=4.5);
      }
    }
  }
}
```

rendered output (this is not in the dataset, this is just showing what the above creates):
![example skateboard bearing openscad render](https://raw.githubusercontent.com/spencerhhubert/cad-copilot/main/assets/example_skateboard_bearing.jpg)

[source](https://github.com/mathcodeprint/openscad-fiddlybits/blob/master/simplebearing.scad)
