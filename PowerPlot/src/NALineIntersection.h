/**
 *  @file
 *  NALineIntersection.h
 *  NuAS Amethyst Graphics System
 *
 *  This header defines a function that finds an intersecting point of
 *  two lines (if it exists). If the two lines are identical (i.e.,
 *  they have infinitely many intersection points) or if they never
 *  intersect, @p CGPoint(NAN, NAN) is returned. Otherwise, the
 *  coordinates of the intersection point are returned.
 *
 *
 *  Created by Wolfram Schroers on 11/02/09.
 *  Copyright 2009-2013 Numerik & Analyse Schroers. All rights reserved.
 *
 */

#ifndef __NALINEINTERSECTION_H__
#define __NALINEINTERSECTION_H__

#include "NABase.h"

/** @brief Return the intersection of two lines.

    This function returns the intersection points of two straight
    lines.  If the two lines are identical (i.e., they have infinitely
    many intersection points) or if they never intersect, @p
    CGPoint(NAN, NAN) is returned. Otherwise, the coordinates of the
    intersection point are returned.

    @return Intersection point.
    @param start1 Starting point line 1.
    @param end1 End point line 1.
    @param start2 Starting point line 2.
    @param end2 End point line 2.
 */
CGPoint NALineIntersection(const CGPoint start1,
                           const CGPoint end1,
                           const CGPoint start2,
                           const CGPoint end2);

#endif /* __NALINEINTERSECTION_H__ */

