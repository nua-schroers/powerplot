//
//  WSCoordinateDelegate.h
//  PowerPlot
//
//  Created by Wolfram Schroers on 23.09.10.
//  Copyright 2010 Numerik & Analyse Schroers. All rights reserved.
//

#import "NARange.h"
#import "WSCoordinate.h"

/// This protocol defines methods that deal with coordinate
/// transformations between data coordinates (used by all Data Model
/// objects and all View and Controller objects (and their respective
/// variables) whose names end with a capital @p D) and bounds
/// (screen) coordinates that are used for drawing to the current
/// view.
///
/// These methods must be implemented by a controller class that knows
/// about the views - and hence the bounds coordinates - and the
/// coordinate system used - and thus also the data coordinates.
@protocol WSCoordinateDelegate <NSObject>

@required

@property (nonatomic, readonly) CGRect viewBounds; ///< The bounds of the view.
@property (nonatomic) NARange rangeXD;             ///< The X-coordinate axis range.
@property (nonatomic) NARange rangeYD;             ///< The Y-coordinate axis range.

/** @return The X-coordinate inverted flag. */
- (BOOL)invertedX;

/** @return The Y-coordinate inverted flag. */
- (BOOL)invertedY;

/** @return X bound coordinate of a given data coordinate. */
- (NAFloat)boundsWithDataXD:(NAFloat)aDatumD;

/** @return Y bound coordinate of a given data coordinate. */
- (NAFloat)boundsWithDataYD:(NAFloat)aDatumD;

/** @return X-data coordinate of a given bounds coordinate. */
- (NAFloat)dataWithBoundsX:(NAFloat)aDatum;

/** @return Y-data coordinate of a given bounds coordinate. */
- (NAFloat)dataWithBoundsY:(NAFloat)aDatum;

/** Transform the sender from data to bounds coordinates. */
- (NAFloat)boundsWithDataD:(NAFloat)aDatumD
                 direction:(WSCoordinateDirection)direction;

/** Transform the sender from bounds to data coordinates. */
- (NAFloat)dataWithBounds:(NAFloat)aDatum
                direction:(WSCoordinateDirection)direction;

/** @return Size of the current view (bounds.size.[width|height]). */
- (NAFloat)boundsSizeForDirection:(WSCoordinateDirection)direction;

/** @return Offset of the current view (bounds.origin.[x|y]). */
- (NAFloat)boundsOffsetForDirection:(WSCoordinateDirection)direction;

@optional

/** Set the X- and Y-coordinate axis scale methods. */
- (void)setCoordinateScaleX:(WSCoordinateScale)scaleX
                     scaleY:(WSCoordinateScale)scaleY;

@end
