//
//  WSPlotCustomView.m
//  PowerPlot_lib
//
//  Created by Dr. Wolfram Schroers on 4/6/14.
//  Copyright (c) 2010-2014 Numerik & Analyse Schroers. All rights reserved.
//

#import "WSPlotCustomView.h"
#import "WSData.h"
#import "WSDatum.h"

@implementation WSPlotCustomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Setup reasonable default values.
        _dataSource = nil;
        _customPositioning = kCustomPositioningCenter;
        _offsetX = 0.f;
        _offsetY = 0.f;
    }
    return self;
}

// Return YES if a subclass can plot (or otherwise handle) data.
// Otherwise, WSPlot returns NO.
- (BOOL)hasData {
    return YES;
}

#pragma mark - Plot handling

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    NSUInteger index = 0;
    if (([self.dataDelegate.dataD count] > 0) &&
        [self dataSource]) {
        // Remove the old views.
        NSArray *oldViews = self.subviews;
        for (UIView *old in oldViews) {
            [old removeFromSuperview];
        }

        // Place the new views as supplied by the data source.
        for (WSDatum *pointD in self.dataDelegate.dataD) {
            UIView *theView = [self.dataSource plotCustomView:self
                                          viewForDatumAtIndex:index];
            index++;
            if (theView) {
                switch (self.customPositioning) {
                    case kCustomPositioningCenter:
                    {
                        NAFloat coordX = [self.coordDelegate boundsWithDataXD:pointD.valueX];
                        NAFloat coordY = [self.coordDelegate boundsWithDataYD:pointD.valueY];
                        coordX += self.offsetX;
                        coordY += self.offsetY;
                        theView.center = CGPointMake(coordX, coordY);
                    }
                        break;

                    case kCustomPositioningLeftXTopY:
                    {
                        NAFloat coordX = [self.coordDelegate boundsWithDataXD:pointD.valueX];
                        NAFloat coordY = [self.coordDelegate boundsWithDataYD:pointD.valueY];
                        coordX += self.offsetX;
                        coordY += self.offsetY;
                        theView.frame = CGRectMake(coordX,
                                                   coordY,
                                                   theView.frame.size.width,
                                                   theView.frame.size.height);
                    }
                        break;
                        
                    default:
                        break;
                }
                [self addSubview:theView];
            }
        }
    }
}

@end

