# ArcArticle

Full or partial circle.

## Overview

A planar figure of constant radius. Has a local coordinate system. Conforms to protocol PenCurve.

## Topics

### Construction Methods

Center point, axis, start point, and sweep. Use this method for a half or full circle.
Center point, axis, start point, end point, and a Bool to indicate whether to use the smaller or larger posible arc.
Concentric arc by specifying the reference Arc, and an offset to the radius. The same sweep will be used for the new Arc.

"approximate" is a function that breaks curves into line segments for plotting.

Several methods are provided for creating fillet curves:

Fillet between two lines;

90 degree fillet at a designated point on a curve;

Short (partial) fillet;

Fillet between a line and a large Arc.

Each Arc has a local coordinate system. Transforms are generated to calculate points back and forth between the local and global coordinate systems.

An Arc can define a Plane.

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
