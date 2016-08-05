/**
 *  @file
 *  NAArrow.h
 *  NuAS Amethyst Graphics System
 *
 *  This header defines functions and data types for supporting
 *  pre-defined dashing styles in 2D data-related chart curves.
 *
 *
 *  Created by Wolfram Schroers on 11/02/09.
 *  Copyright 2009-2013 Numerik & Analyse Schroers. All rights reserved.
 *
 */

#ifndef __NAARROW_H__
#define __NAARROW_H__

#include "NABase.h"

/** Styles an arrow can be plotted. */
typedef enum _NAArrowStyle {
    kArrowLineNone,
    kArrowLinePlain,
    kArrowLineArrow,
    kArrowLineFilledHead,
} NAArrowStyle;

/** Predefined fixed arrow drawing angle. */
extern const NAFloat kArrowAngle;

/** @brief Draw a straight line with an arrow at the end.

    @param aContext Drawing context.
    @param arrowStyle Style of drawing the arrow.
    @param start Screen coordinates starting point.
    @param end Screen coordinates end point.
    @param headLen Length of the arrow head.
    @param lineWidth Width of the line and the arrow.
 */
void NAContextAddLineArrow(const CGContextRef aContext,
                           const NAArrowStyle arrowStyle,
                           const CGPoint start,
                           const CGPoint end,
                           const NAFloat headLen,
                           const NAFloat lineWidth);

/** @brief Draw a straight line with an arrows at both ends.

    @param aContext Drawing context.
    @param arrowStyle Style of drawing the arrow.
    @param start Screen coordinates starting point.
    @param end Screen coordinates end point.
    @param headLen Length of the arrow head.
    @param lineWidth Width of the line and the arrow.
 */
void NAContextAddLineDoubleArrow(const CGContextRef aContext,
                                 const NAArrowStyle arrowStyle,
                                 const CGPoint start,
                                 const CGPoint end,
                                 const NAFloat headLen,
                                 const NAFloat lineWidth);

#endif /* __NAARROW_H__ */

