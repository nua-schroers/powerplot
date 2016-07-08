/*
 *  NALineRectangleIntersection.c
 *  NuAS Amethyst Graphics System
 *
 *
 *  Created by Wolfram Schroers on 11.10.10.
 *  Copyright 2009-2013 Numerik & Analyse Schroers. All rights reserved.
 *
 */

#include "NABase.h"
#include "NALineRectangleIntersection.h"
#include "NALineIntersection.h"

CGPoint NALineInternalRectangleIntersection(const CGPoint start,
                                            const CGPoint end,
                                            const CGRect rectangle) {
    /* Are the conditions fulfilled? */
    CGPoint myStart = start;
    CGPoint myEnd = end;
    if (CGRectContainsPoint(rectangle, start)) {
        /* Always place the ending point in the rectangle. */
        CGPoint tmp = start;
        myStart = end;
        myEnd = tmp;
    }

    if (!((!CGRectContainsPoint(rectangle, myStart)) &&
          (CGRectContainsPoint(rectangle, myEnd)))) {
        return CGPOINT_INVALID;
    }
    
    /* At this point there is only one intersection. Find and return it. */
    CGPoint result = NALineIntersection(myStart,
                                        myEnd,
                                        rectangle.origin,
                                        CGPointMake(rectangle.origin.x,
                                                    rectangle.origin.y+rectangle.size.height));
    if (!isnan(result.x)) {
        return result;
    }
    
    result = NALineIntersection(myStart,
                                myEnd,
                                CGPointMake(rectangle.origin.x,
                                            rectangle.origin.y+rectangle.size.height),
                                CGPointMake(rectangle.origin.x+rectangle.size.width,
                                            rectangle.origin.y+rectangle.size.height));
    if (!isnan(result.x)) {
        return result;
    }

    result = NALineIntersection(myStart,
                                myEnd,
                                CGPointMake(rectangle.origin.x+rectangle.size.width,
                                            rectangle.origin.y+rectangle.size.height),
                                CGPointMake(rectangle.origin.x+rectangle.size.width,
                                            rectangle.origin.y));
    if (!isnan(result.x)) {
        return result;
    }
    
    result = NALineIntersection(myStart,
                                myEnd,
                                CGPointMake(rectangle.origin.x+rectangle.size.width,
                                            rectangle.origin.y),
                                rectangle.origin);

    return result;
}
