/**
 *  @file
 *  NALineRectangleIntersection.h
 *  NuAS Amethyst Graphics System
 *
 *  This header defines functions for testing line/rectangle
 *  intersections.
 *
 *
 *  Created by Wolfram Schroers on 11/02/09.
 *  Copyright 2009-2013 Numerik & Analyse Schroers. All rights reserved.
 *
 */

#ifndef __NALINERECTANGLEINTERSECTION_H__
#define __NALINERECTANGLEINTERSECTION_H__

#include "NABase.h"

/** @brief Return the intersection of a line with a rectangle.

    This function returns the intersection points of a line and a
    rectangle. One point of the line has to lie inside the rectangle
    and the other one outside. If these conditions are not met,
    CGPoint(NAN, NAN) is returned. Otherwise, the coordinates of the
    intersection point are returned.

    @return Intersection point.
    @param start Line starting point.
    @param end Line end point.
    @param rectangle The CGRect describing the rectangle.
 */
CGPoint NALineInternalRectangleIntersection(const CGPoint start,
                                            const CGPoint end,
                                            const CGRect rectangle);

#endif /* __NALINERECTANGLEINTERSECTION_H__ */

