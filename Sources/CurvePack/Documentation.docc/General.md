# Meet CurvePack

Topics to set the context for this code.

### Description
This code builds and analyzes 3D curves. The genesis of the code was to create profiles that can be extruded, swept, or revolved for 3D printing. A secondary goal was to create section views of structural beams for analysis and comparison. An attempt has been made to organize the code so that it can be adopted to myriad other purposes.

``LineSeg``, ``Arc``, ``Cubic``, and ``Quadratic`` are the workhorse structs, with ``Point3D``, ``Vector3D``, ``Line``, and ``Plane`` vital for their construction.

### Accuracy
When comparing the coordinate values for two points, the desired level of accuracy must be defined. ``Point3D.Epsilon`` has a default value set at compile time, and often used as a default parameter in function calls. ``Vector3D.Epsilon`` serves a similar role.

### Approximation
Curves (and surfaces) are approximated when being displayed. "allowableCrown" is frequently the parameter used to define the smoothness of the approximation. A smaller value provides a smoother result, but takes more time and data. Its value will depend on the problem domain and the measurement system used.

### Scaling
To be able to scale the geometry display, ``OrthoVol`` is a simple struct that represents a brick that is aligned with the global coordinate system. Each curve type that implements ``PenCurve`` has a method to specify the volume that surrounds itself. The initializers have code to build a small depth for planar figures. Volumes can easily be summed. OrthoVol can also be used to look for overlapping curves. 

