//
//  WSColorScheme.h
//  PowerPlot
//
//  Created by Wolfram Schroers on 02.11.10.
//  Copyright 2010-2013 Numerik & Analyse Schroers. All rights reserved.
//

@import UIKit;
#import "WSPlotFactoryDefaults.h"

/// This class defines and returns appropriate colors based on a given
/// color scheme constant as defined in @p WSPlotFactoryDefaults.h.
@interface WSColorScheme : NSObject <NSCoding, NSCopying>

@property (nonatomic) LPColorScheme colors; ///< Current color scheme constant.

/** @return A color scheme (factory method).
 
    @param cs The color scheme constant.
    @return An instance of a color scheme. */
+ (instancetype)colorScheme:(LPColorScheme)cs;

/** Initialize a color scheme.
 
    @param cs The color scheme constant.
    @return An initialized color scheme. */
- (instancetype)initWithScheme:(LPColorScheme)cs;

/** Initialize a color scheme with default white color. */
- (instancetype)init;

/** @return Foreground color for the current color scheme. */
- (UIColor *)foreground;

/** @return Background color for the current color scheme. */
- (UIColor *)background;

/** @return Receded color for the current color scheme. */
- (UIColor *)receded;

/** @return Highlight color for the current color scheme. */
- (UIColor *)highlight;

/** @return Spotlight color for the current color scheme. */
- (UIColor *)spotlight;

/** @return Shadow color for the current color scheme. */
- (UIColor *)shadow;

/** @return Array of alternative highlight colors. */
- (NSArray<UIColor *> *)highlightArray;

/** @return primary alert color. */
- (UIColor *)alert;

/** @return Secondary alert color. */
- (UIColor *)alertSecondary;

@end
