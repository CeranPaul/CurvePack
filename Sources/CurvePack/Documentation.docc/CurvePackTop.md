# ``CurvePack``

Curves in three dimensions.

## Overview

``LineSeg``, ``Arc``, ``Quadratic``, and ``Cubic`` can be drawn. 

![Different drawable curves in the package.](variety.png)

``Point3D``, ``Vector3D``, ``Line``, and ``Plane`` are construction tools.

The code makes no assumptions about the length units used. It is up to the adopter to be consistent.

The usual measure of an angle is radians.

## Topics

### Drawable objects
These each conform to the ``PenCurve`` protocol.
- ``LineSeg``
- ``Arc``
- ``Quadratic``
- ``Cubic``

### Construction
- ``Point3D``
- ``Vector3D``
- ``Line``
- ``Plane``

### Other
- ``CoordinateSystem``
- ``Transform``
- ``OrthoVol``
- ``Involute``
- ``Helix``

