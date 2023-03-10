# alpaca
Fine-tuning LLaMA to generate SCAD to make STLs

then we make CAD Engineering Copilot

## the idea
[OpenSCAD](https://openscad.org/) is like a programming language for 3D shapes. You can define primititive shapes, move them around, extrude, take the difference or union between them, and apply algorithms to define more complex shapes than would normally be possible in traditional CAD programs. Then, you can output them as STLs and use them as you could any other 3D file in the engineering process. Perhaps 3D print it.

[LLaMA](https://github.com/facebookresearch/llama) is a large language model recently "open-sourced" (kinda) by Meta. It's like GPT-3 but 10x more efficient. Even the smallest model can generate coherent, usable code. If you ask it to write SCAD code, it'll return some simple but usable work. The problem is that it clearly doesn't know that much SCAD. It refuses to use anything but the most basic operations. It needs more data.

## todo
- data scraper for any OpenSCAD code online.
  - [Good place to start](https://openscad.org/gallery.html)
- pytorch dataset class for this data
- convert llama weights to 8int
- get llama fine-tuning working
- helper functions to generate and visualize actual STLs
