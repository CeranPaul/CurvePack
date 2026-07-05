# Orthogonal volume and extent

A box with sides that are aligned to the coordinate planes.

## Brick aligned with the coordinate system

Useful for determining display scale, and filtering entities for intersections. They can be summed. This isn't necessarily the minimum volume that encloses an entity or group of entities.

Defined without using a curve by supplying acceptable ranges in each of the X, Y, and Z axes, or by specifying two points in opposite corners.

### Extent

The minimum orthogonal volume that contains an entity. Classes and structs that adhere to the PenCurve protocol each have a function for generating their extent. Line segments, for example have a small proportional thickness applied (if needed) to define a volume.

### Tests

See "OrthoVolTests"

