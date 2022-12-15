# General Discussion

Topics to set the context for this code.

### Approximation

Curves (and surfaces) are approximated when being displayed. "allowableCrown" is frequently the parameter used to define the smoothness of the approximation. A smaller value provides a smoother result, but takes more time and data. Its value will depend on the problem domain and the measurement system used.

### Accuracy

When comparing the coordinate values for two points, the desired level of accuracy must be defined. "Point3D.Epsilon" is a value set at compile time, and often used as a default parameter in function calls. "Vector3D.Epsilon" serves a similar role.

### Testing
Lots of unit tests are included, but probably don't handle the exhaustive set of cases.

### Errors
Many error classes have been written. The goal is to find bad referencing or other flaws during development.

### OrthoVol
To be able to scale a display, and look for overlapping curves, ``OrthoVol`` is a simple struct that represents a brick that is aligned with the global coordinate system. Each curve type has a method to build a volume that surrounds itself. The initializers have code to build a small depth for planar figures. Volumes can easily be summed.

