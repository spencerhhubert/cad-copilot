# CAD Copilot 🔧🦙
fine-tuning LLaMA to generate SCAD to make STLs

then we make CAD Engineering Copilot

## the idea
[OpenSCAD](https://openscad.org/) is like a programming language for 3D shapes. You can define primititive shapes, move them around, extrude, take the difference or union between them, and apply algorithms to define more complex shapes than would normally be possible in traditional CAD programs. Then, you can output them as STLs and use them as you could any other 3D file in the engineering process. Perhaps 3D print it.

[LLaMA](https://github.com/facebookresearch/llama) is a large language model recently "open-sourced" (kinda) by Meta. It's like GPT-3 but 10x more efficient. Even the smallest model can generate coherent, usable code if you prompt it *just* right, but it needs some fine-tuning work. If you ask it to write SCAD code, it'll make a valiant but doesn't yet produce usable work. The problem is that it clearly doesn't know that much SCAD. It refuses to use anything but the most basic primitives. It needs more data and it needs fine-tuning for this purpose.

Example from vanilla LLaMA 13B, with 8bit weights:
```
prompt: "The OpenSCAD code for the model of a cube is:"
continuation:
Shape shape;
Appearance appearance;
materials::Material material(Color("FF0080"), Color("E56B27"));
//The top face must have more triangles than any other, since it's visible in three
//spatial directions. All six edges are shared by two faces.
for (int i=0; i<6; ++i) {
std::string name = "face_top"; // All names for this cube must be unique to avoid errors
if ((!name.empty()) && !shape.faceNames().contains(name)) {
appearance.setDiffuseTexture(texture);
//This function generates the vertices in counterclockwise order around the centroid point.
generateCubeVertexOrder(FVector(1., 1., 1.),
...(a bunch of other junk)
```

It knows a few things, like the OpenSCAD is a programming language for shapes and that cubes have six sides and there are vertices to a shape, but yeah this is not good yet.

However, what's amazing and already a momentous breakthrough about these LLMs, is that they in practice *can* produce cohernet SCAD code, and so 3D shapes. If you ask ChapGPT to write you the code for a car, it can apply its knowledge of the geometry of that thing and apply it to its limited knowledge of SCAD code. I think we can leverage this to make something practically useful.

Example from ChatGPT:
```
prompt: "Write the OpenSCAD code for a car"
output:
// Car body
difference() {
    union() {
        // Main body
        cube([100, 50, 30]);

        // Roof
        translate([0, 0, 30]) cube([100, 50, 20]);

        // Windows
        translate([10, 10, 30]) cube([80, 30, 1]);
        translate([10, 19, 30]) cube([80, 1, 9]);
        translate([10, 40, 30]) cube([80, 1, 9]);
    }

    // Cut out wheels
    union() {
        translate([20, -10, -5]) cylinder(h=10, r=15, center=true);
        translate([80, -10, -5]) cylinder(h=10, r=15, center=true);
    }
}

// Car doors
difference() {
    translate([0, 0, 10]) cube([20, 40, 20]);
    translate([80, 0, 10]) cube([20, 40, 20]);
}

// Car lights
union() {
    translate([5, 20, 30]) sphere(7);
    translate([95, 20, 30]) sphere(7);
}
```
I think we can outperform this.

Checkout some [example data](https://github.com/spencerhhubert/cad-copilot/blob/main/assets/example_data.md) for what we're aiming for.

The plan is to train this on two RTX 3090's, totalling 48gb of VRAM and over 70 tflops of compute. We could always use more but I think this might just do.

## todo
Contact me if you're interested in taking a task on, we'll get in a call and form a concrete plan. These are just rough notes to get an idea of what the task looks like
- **Not yet assigned, multi-person job**: build dataset
  - we'll need to acquire a lot of data through scraping as many websites and APIs as we can find. we need to assemble at least 1-10k prompt/OpenSCAD pairs; what is the desired output (OpenSCAD code) corresponding to some input (english prompt)
  - this will require data scraping (basically making mouse click bots), using APIs, and writing scripts all for the purpose of downloading data off websites
  - [example data](https://github.com/spencerhhubert/cad-copilot/blob/main/assets/example_data.md)
  - examples of where to look:
    - [GitHub](https://github.com/search?q=language%3AOpenSCAD&type=Repositories&ref=advsearch&l=OpenSCAD&l=)
    - [Thingiverse](https://www.thingiverse.com/search?q=scad&page=1&type=things&sort=relevant) 
      - they have an [API](https://www.thingiverse.com/developers/getting-started) that one would need to get access to. this is a matter of filling out their form, then they'll give an authentication key
      - if you look at an example of thing like [this](https://www.thingiverse.com/thing:40410), we could want to download the `.scad` files from the "Thing Files" and the summary and description. these will all be accessible through the API
        - it's possible we'll need to prune this data, it's not all going to be perfect, but that's okay. I have some ideas how we can mass cleanse once we have lots of data
    - [Cults3D](https://cults3d.com/en/search?q=scad)
    - [The OpenSCAD website](https://openscad.org/gallery.html) has a small gallery
- **Not yet assigned**: pytorch dataset class for the above datase
  - this will take in the files we sourced above and make them usable to our PyTorch model
  - the dataset above does not need to exist before writing this, just need to assume the format it's going to be in
  - this is a standard API that will allows us to load in batches of `(inputs,expected_outputs)` and train en masse
  - [tutorial to get started](https://pytorch.org/tutorials/beginner/data_loading_tutorial.html)
- **Spencer**: environment setup
    - convert llama weights to int8
      - if you have an RTX 3090 or above, it's possible to run the LLaMA 13b parameter model with 8 bit ints. It's actually even possible to run it with neglible loss in quality with only [4 bit weights](https://rentry.org/llama-tard-v2#bonus-4-4bit-llama-basic-setup)! We'll save this for later, the stability seems low.
      - it's also [possible](https://github.com/ggerganov/llama.cpp) to run it on an M1 Mac with 32gb of memory
    - get fine-tuning llama with int8's working
- write and experiment with fine-tuning layer architectures
- training code
  - this will need to wait until the above work is done
- **Not yet assigned**: helper functions to generate and visualize actual STLs
  - need a python function, and whatever relevant helper functions, to input a giant string of OpenSCAD code and output an STL/.obj file.
    - will probably want to call [OpenSCAD command line tool](https://files.openscad.org/documentation/manual/Using_OpenSCAD_in_a_command_line_environment.html) for this
    - look into the format of an STL. they are basically a big list of vertices and faces, each of which references three vertices
- web interface?
  - I'm not going to focus on this for now, but if someone feels inclined, this can be your task
  - architecture:
    - front end takes in textual prompts for shapes. "Make me a 3mm long, 1mm wide helix"
    - backend phones this prompt home
    - processes it through the pytorch model that we have yet to fine-tune, which generates some OpenSCAD
    - generate an STL, there's an [OpenSCAD command line tool](https://files.openscad.org/documentation/manual/Using_OpenSCAD_in_a_command_line_environment.html) for this
    - send the STL back to the client and display it with some 3D graphics Javascript library
    - Key: remember what the previous prompts were such that the user can say "make it taller" and we can send home the previous prompts plus this new stipulation such that the user can hone in the shape they want

## where to start
- See the [Where to Start](https://github.com/spencerhhubert/cad-copilot/blob/main/assets/where_to_start.md) document
