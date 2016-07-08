/*
 *  NALineIntersection.c
 *  NuAS Amethyst Graphics System
 *
 *
 *  Created by Wolfram Schroers on 11/02/09.
 *  Copyright 2009-2013 Numerik & Analyse Schroers. All rights reserved.
 *
 */

#include "NALineIntersection.h"

CGPoint NALineIntersection(const CGPoint start1,
                           const CGPoint end1,
                           const CGPoint start2,
                           const CGPoint end2) {
    /* Setup the system of equations. */
    CGFloat a = end1.x - start1.x;
    CGFloat b = -end2.x + start2.x;
    CGFloat c = end1.y - start1.y;
    CGFloat d = -end2.y + start2.y;
    
    CGFloat det = a * d - b * c;
    
    /* Check if the system is singular. */
    if (IS_EPSILON(det)) {
        return CGPOINT_INVALID;
    }
    
    /* Otherwise, find the intersection point. */
    CGFloat aInv = d / det;
    CGFloat bInv = -b / det;
    CGFloat cInv = -c / det;
    CGFloat dInv = a / det;
    
    CGFloat x = aInv * (start2.x - start1.x) + bInv * (start2.y - start1.y);
    CGFloat y = cInv * (start2.x - start1.x) + dInv * (start2.y - start1.y);

    /* If the intersection point does not lie within the line segments,
       also return CGPOINT_INVALID. */
    if ((x < 0.0) || (x > 1.0) || (y < 0.0) || (y > 1.0)) {
        return CGPOINT_INVALID;
    }
    
    /* Otherwise return the result. */
    return CGPointMake(start1.x + x * (end1.x - start1.x),
                       start1.y + x * (end1.y - start1.y));
}
