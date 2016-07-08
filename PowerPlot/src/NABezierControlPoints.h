/**
 *  @file
 *  NABezierControlPoints.h
 *  NuAS Amethyst Graphics System
 *
 *  This header defines the function for computing Bezier cubic spline
 *  control points. The points are computed based on the continuity
 *  condition for the first two derivatives.
 *
 *  Details and an example algorithm can be found at
 *  http://www.codeproject.com/KB/graphics/BezierSpline.aspx
 *
 *
 *  Created by Wolfram Schroers on 11/02/09.
 *  Copyright 2009-2013 Numerik & Analyse Schroers. All rights reserved.
 *
 */

#ifndef __NABEZIERCONTROLPOINTS_H__
#define __NABEZIERCONTROLPOINTS_H__

#include "NABase.h"

/** @brief Return control points for a Bezier cubic spline
    interpolation.

    This function computes and allocates two arrays of @p CGPoint
    structures which contain the control points @p P1 and @p P2 for
    drawing smooth (continuous up to the second-order derivative)
    interpolations using Quartz 2D cubic splines. The input data is an
    array of length @p num, the output consists of two arrays @p
    control1 and @p control2 of @p CGPoint which must be free'd by the
    caller.  The length of the array is given by the function's return
    value.  If the return value is smaller than @p 1, an error has
    occurred and the calculation has been aborted. In that case, the
    arrays MUST NOT be free'd by the caller.

    @return Number of control points (> 0 if computation successful).
    @param num Number of input data points.
    @param data Input data points as array.
    @param control1 The array of first control points.
    @param control2 The array of second control points.
 */
unsigned long NABezierControlPoints(const unsigned long num,
                                    const CGPoint data[],
                                    CGPoint **control1,
                                    CGPoint **control2);

/** @brief Solve a triangular system of equations.

    This function solves the tridiagonal system to get the x- and y-
    components of the control points for Bezier cubic spline
    interpolations. The input data is provided by the array @p b and
    the output as array @p cpr. @p tmp is a temporary array that acts
    as a buffer. All arrays have length @p n and must be allocated
    prior to the function call. On return, @p cpr will contain the
    desired solution vector.

    @param cpr The solution vector of the system (result).
    @param b The right-hand-side of the system.
    @param tmp A temporary array which will be modified on return.
    @param n The size of each of the previous vectors.
 */
void solve_eqsys(NAFloat cpr[],
                 const NAFloat b[],
                 NAFloat tmp[],
                 const unsigned n);

#endif /* __NABEZIERCONTROLPOINTS_H__ */
