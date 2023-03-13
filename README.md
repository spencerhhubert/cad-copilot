# alpaca 🔧🦙
Fine-tuning LLaMA to generate SCAD to make STLs

then we make CAD Engineering Copilot

## the idea
[OpenSCAD](https://openscad.org/) is like a programming language for 3D shapes. You can define primititive shapes, move them around, extrude, take the difference or union between them, and apply algorithms to define more complex shapes than would normally be possible in traditional CAD programs. Then, you can output them as STLs and use them as you could any other 3D file in the engineering process. Perhaps 3D print it.

[LLaMA](https://github.com/facebookresearch/llama) is a large language model recently "open-sourced" (kinda) by Meta. It's like GPT-3 but 10x more efficient. Even the smallest model can generate coherent, usable code. If you ask it to write SCAD code, it'll return some simple but usable work. The problem is that it clearly doesn't know that much SCAD. It refuses to use anything but the most basic operations. It needs more data.

The plan is to train this on two RTX 3090's, totalling 48gb of VRAM and over 70 tflops of compute. We could always use more but I think this might just do.

## todo
- big ones I encourage individuals or pairs take on:
    - Not yet assigned: data scraper for any OpenSCAD code online.
      - [Good place to start](https://openscad.org/gallery.html)
    - Not yet assigned: pytorch dataset class for this data
      - this is a standard API that will allows us to load in batches of `(inputs,expected_outputs)` and train en masse
- Spencer: environment setup
    - convert llama weights to int8
      - if you have an RTX 3090 or above, it's possible to run the LLaMA 13b parameter model with 8 bit ints. It's actually even possible to run it with neglible loss in quality with only [4 bit weights](https://rentry.org/llama-tard-v2#bonus-4-4bit-llama-basic-setup)! We'll save this for later, the stability seems low.
      - it's also [possible](https://github.com/ggerganov/llama.cpp) to run it on an M1 Mac with 32gb of memory
    - get fine-tuning llama with int8's working
- Not yet assigned: helper functions to generate and visualize actual STLs
  - need a python function, and whatever relevant helper functions, to input a giant string of OpenSCAD code and output an STL/.obj file.
    - will probably want to call [OpenSCAD command line tool](https://files.openscad.org/documentation/manual/Using_OpenSCAD_in_a_command_line_environment.html) for this
    - look into the format of an STL. they are basically a big list of vertices and faces, each of which references three vertices
- web interface?
  - I'm not going to focus on this for now, but if someone feels inclined, this can be your task
  - architecture:
    - front end takes in textual prompts for shapes. "Make me a 3mm helix"
    - backend phones this prompt home
    - processes it through the pytorch model that we have yet to fine-tune, which generates some OpenSCAD
    - generate an STL, there's an [OpenSCAD command line tool](https://files.openscad.org/documentation/manual/Using_OpenSCAD_in_a_command_line_environment.html) for this
    - send the STL back to the client and display it with some 3D graphics Javascript library
    - Key: remember what the previous prompts were such that the user can say "make it taller" and we can send home the previous prompts plus this new stipulation such that the user can hone in the shape they want

## where to start
- See the [Where to Start](https://github.com/spencerhhubert/alpaca/blob/main/assets/where_to_start.md) document
