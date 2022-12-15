# Parametric Curves

``Cubic`` and ``Quadratic`` are naturally parametric curves, but ``LineSeg`` and ``Arc`` can be treated that way as well.

## Overview

Parameter values for curves commonly go from a value of 0.0 at one end to 1.0 at the other end. That parameter is named 't' most often, though other letters are sometimes used. See the functions "pointAt" and "tangentAt", which are required by the ``PenCurve`` protocol.

### General Discussion

LineSeg and Arc don't require to be looked at as parametric curves, but when using a basketful of curves, it is convenient to have a common way of dealing with them.

Curves can be trimmed by setting limits to the allowable range of the parameter.

![Quadratic and Cubic trimmed to a pair of lines.](trimmed.png)

Quadratic and Cubic have polynomials to define the coordinate in each axis. Show equations.

Different ways to build a Cubic.

Using the derivative to find the slope.

This approach is also used for defining surfaces. See class Bicubic.

