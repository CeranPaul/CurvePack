# LoopArticle

Loop class is a bucket for collecting PenCurves that define a region on a plane. It is a single path without branches. It does not have internal voids or cutouts.

## Overview

As curves are added, an attempt is made to find what curves already in the Loop share a common end point. Function 'isClosed' reports whether or not all curves share either end point with another curve. An attempt can then be made to align the curves so that there is a continuous direction as you sequentially traverse the curves. Some curves may get reversed in that alignment process.

## Loop Sources

SVG files could be translated to Loops - e.g. alphabetic characters, though this hasn't been included yet.

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
