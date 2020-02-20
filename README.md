# Sensorized-Objects

# ReadMe Contents
- Folder Contents
- Introduction
- Object Assembly
- Fabrication
- How to Place Polhemus Sensors and Retro-Reflective Markers in Objects

# Folder Contents
In this repository you can find:
* CAD and STL files of the rigid and soft manipulation objects. 
* Code examples for processing data.
* In-hand manipulation example data with the T42 and NDX-A* robot hands. 


# Introduction
The human hand is Nature's most versatile and dexterous end-effector and it has been a source of inspiration for roboticists for over 50 years. Recently, significant industrial and research effort has been put into the development of dexterous robot hands and grippers. Such end-effectors offer robust grasping and dexterous, in-hand manipulation capabilities that increase the efficiency, precision, and adaptability of the overall robotic platform. This work focuses on the development of modular, sensorized objects that can facilitate benchmarking of the dexterity and performance of hands and grippers. The proposed objects aim to offer; a minimal, sufficiently diverse solution, efficient pose tracking, and accessibility. The object manufacturing instructions, 3D models, and assembly information are made publicly available through the creation of a corresponding repository.

<p align="center">
  <img src = https://user-images.githubusercontent.com/54158341/74490231-b8743400-4f2c-11ea-9af3-04e84ff102dd.jpg>
</p>

# Object Assembly
![explodedView3](https://user-images.githubusercontent.com/54158341/73730014-f4740000-479a-11ea-8336-e72841e834bf.jpg)
Each object of the sensorized object set consists of 5 to 13 parts:
* a plastic screw (which holds the object together)
* two object halves (these halves can be objects of any size and surface stiffness)
* two removable urethane marker mounts
* eight removable object weights (optional components)

# Fabrication 

## 3D printing
STL files are included in the CAD folder.
### Plastic Threads
If the plastic screw does not screw into the object, a **M8 tap and die** can be used to fix any tolerancing errors introdruced by the 3D printing proccess.

[comment]: <> (add image of plastic screw and object being tapped)
[![tapping5sec](https://user-images.githubusercontent.com/54158341/74497252-09425780-4f42-11ea-8b20-e1494cdfd888.PNG)](https://www.youtube.com/watch?v=iwGn_2lOhc0&feature=youtu.be "tapping5sec")

**NOTE:** The plastic screws should not be overtightened or they will break (using SLA or SLS printing proccesses can increase the strength of the screw).

## Molding
### Urethane/ Silicone Mixing
**Note:** Before molding the mold should be sprayed with mold release and **ensure not to spray objects** as this may prevent the objects soft skin from sticking correctly to the soft object halves. 
1. Read the unrethane/ silicone instructions to determine **mix ratio** and **work time**
    - Work time will determine how quickly you will need to degas and inject the material into the mold.
2. Pour appropriate resin and hardener portions instructed by the suppliers mix ratio.
3. Mix togeather thoroughly.
5. Place mixture into vacuum chamber to degas. 
6. Pour or inject urethane/ silicone mixture into mold. 
### Markers
Instructional videos for molding the markers can be found below. When molding the markers using a softer urethane or silicon (e.g **Smooth On Vytaflex 30**) will make insertion and removal of the markers into and out of the object halves significantly easier.
#### Optical Markers/ Polhemus Markers
[![flatMaker](https://user-images.githubusercontent.com/54158341/74596792-f2724100-50b8-11ea-9a1f-15151a7673b6.JPG)](https://www.youtube.com/watch?v=eXIwOtoV1qc "flatMaker")
#### AR Markers
[![ARMaker](https://user-images.githubusercontent.com/54158341/74596832-762c2d80-50b9-11ea-9c4e-b6d14c671c77.JPG)](https://www.youtube.com/watch?v=xcrOEh82KFU "ARMaker")

### Soft Objects 
Before molding the objects a narrow nozzle syringe needs to be prepared in order for the chosen urethane or silicone to reach the small narrow spaces in the mold without air bubbles.

Materials needed to prepare long nozzle syringe: 
* Syringe
* Heat shrink
* Pliers 
* Super glue

The materials can be seen depicted below with an accompanying video demonstrating how to fabricate one.

<p align="center">
  <img src = https://user-images.githubusercontent.com/54158341/74497968-faf53b00-4f43-11ea-8a1f-8a414c7fc11c.jpg>
</p>

[![syringe5sec](https://user-images.githubusercontent.com/54158341/74500838-131d8800-4f4d-11ea-88c0-5d738e4734c0.PNG)](https://www.youtube.com/watch?v=B0mpWGTTy3A&feature=youtu.be "syringe5sec")

#### Mold Assembly and Preparation
Assembly of the molds can be seen be low with exploded views of the mold and assembly videos. 

Cube and radially split cylinder molds will require aluminum tape to the mold seams to prevent potential leaking. 

Components required for molds: 
* For object halves with internal threads
    - 1 x M8 screw of 20mm length
* For object halves without threads
    - 1x M8 screw of 35mm length
    - 1 x M8 nut

##### Cube Mold

<p align="center">
  <img src = https://user-images.githubusercontent.com/54158341/74600176-86acca00-50f2-11ea-9bcd-5ea6770d5870.png>
</p>

[![CubeMoldPreparations](https://user-images.githubusercontent.com/54158341/74598260-73d6cd00-50d3-11ea-8feb-13c2671f4871.JPG)](https://www.youtube.com/watch?v=x2nqksHXXIw "CubeMoldPreparations")

**Note:** The walls of the mold should be parallel to the soft object core as shown in the image below to prevent misalignment. 
<p align="center">
  <img src = https://user-images.githubusercontent.com/54158341/74522674-85f42680-4f80-11ea-8254-0f5da4df5827.png>
</p>

##### Cylinder Mold
* Radially Split Cylinder

<p align="center">
  <img src = https://user-images.githubusercontent.com/54158341/74600182-a0e6a800-50f2-11ea-8e28-6c30978823e5.png>
</p>

[![CylinderMoldPreparations](https://user-images.githubusercontent.com/54158341/74598322-784fb580-50d4-11ea-8708-6aac99996106.JPG)](https://www.youtube.com/watch?v=_m07TIoGHqI "CylinderMoldPreparations")

* Axially Split Cylinder

<p align="center">
  <img src = https://user-images.githubusercontent.com/54158341/74600192-be1b7680-50f2-11ea-9674-264c548cab7b.png>
</p>

##### Sphere Mold

<p align="center">
  <img src = https://user-images.githubusercontent.com/54158341/74600212-e3a88000-50f2-11ea-862f-1f3216331779.png>
</p>

#### Molding Process
[![moldingObject](https://user-images.githubusercontent.com/54158341/74596973-b096ca00-50bb-11ea-8e53-58e37fe110bc.JPG)](https://www.youtube.com/watch?v=eo5qOiTZaQk "moldingObject")

## Demolding

### Markers
#### Optical Markers/ Polhemus Markers

[![OpticalMarkers](https://user-images.githubusercontent.com/54158341/74598466-2197ab00-50d7-11ea-92f8-622f696855fd.JPG)](https://www.youtube.com/watch?v=Dwkm1ft7N5k "OpticalMarkers")

For Polhemus markers only the first 2 steps of the video need to be followed. The last step is only relevant if you require optical markers.

#### AR Markers

[![ARMarkers](https://user-images.githubusercontent.com/54158341/74598448-b0f08e80-50d6-11ea-8326-aa87f0e9417f.JPG)](https://www.youtube.com/watch?v=l4PmQHS5-48 "ARMarkers")

### Soft Objects 
The demolding proccess of cubes and radially split cylinders are the same. Similarly, can be said for the spheres and axially split cylinders. 

[![CylinderDemold](https://user-images.githubusercontent.com/54158341/74598400-c1543980-50d5-11ea-9090-9836fae38bf8.JPG)](https://www.youtube.com/watch?v=J1zPYWYStN0&feature=youtu.be "CylinderDemold")

[![ShpereDemold](https://user-images.githubusercontent.com/54158341/74598378-63bfed00-50d5-11ea-9eae-525b6c3dfa07.JPG)](https://www.youtube.com/watch?v=wvo3y9mB7Rw&feature=youtu.be "ShpereDemold")

# How to Place Polhemus Sensors in Objects
1. Insert micro sensor through the hole of the Polhemus urethane marker. 
2. Insert the micro sensor into the 2mm hole at the base of the screw. 
    **Note:** If the sensor can't fit into hole a 2mm drill bit will need to be used to correct the dimensions of the hole. 
3. Place blu tack around the cable at the base of the screw. This will prevent the sensor from falling out, but will still allow it to be pulled out if a sigincant tug force on the cable is experienced. 
4. once, the screw and the sensor are in place, the Polhemus urethane marker can then be inserted into the corresponding object half.

[![Polhemus](https://user-images.githubusercontent.com/54158341/74620839-6555e780-519f-11ea-8c88-1d8fd543367e.PNG)](https://www.youtube.com/watch?v=4mxdQY6hf8g&feature=youtu.be "Polhemus")
