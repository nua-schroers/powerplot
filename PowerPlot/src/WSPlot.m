//
//  WSPlot.m
//  PowerPlot
//
//  Created by Wolfram Schroers on 23.09.10.
//  Copyright 2010-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import "WSPlot.h"
#import "WSData.h"
#import "WSCoordinateDelegate.h"
#import "WSDataDelegate.h"

@implementation WSPlot

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.allowReordering = YES;
    }
    return self;
}

#pragma mark -

- (BOOL)hasData {
    // Return YES if a subclass can plot (or otherwise handle) data.
    return NO;
}

#pragma mark - Plotting information on screen

- (void)plotSample:(CGPoint)aPoint {
    // Override this method if a subclass plots something to provide a
    // sample. (E.g. something that is inserted in legends etc.)
}

- (void)setAllDisplaysOff {
    // Override this method if a plots presents something on the canvas.
    // Reset the chart to use only no-display parameters in all customizable values.
}  

- (void)chartSetNeedsDisplay {
    [[self superview] setNeedsDisplay];
}

/*
 // Only override drawRect: if you perform custom drawing.  An empty
 // implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
