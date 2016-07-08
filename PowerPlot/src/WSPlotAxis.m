//
//  WSPlotAxis.m
//  PowerPlot
//
//  Created by Wolfram Schroers on 25.09.10.
//  Copyright 2010-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import "WSPlotAxis.h"
#import "WSData.h"
#import "WSDatum.h"
#import "WSTicks.h"
#import "WSAxisProperties.h"
#import "WSAuxiliary.h"
#import <math.h>

@interface WSPlotAxis ()

// Tick labels and the axis labels.
@property (nonatomic, strong) NSMutableArray *WS_tickUILabelsX;
@property (nonatomic, strong) NSMutableArray *WS_tickUILabelsY;
@property (nonatomic, strong) UILabel *WS_axisUILabelX;
@property (nonatomic, strong) UILabel *WS_axisUILabelY;

@end

@implementation WSPlotAxis

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Reset the axis to default values.
        _axisX = [[WSAxisProperties alloc] init];
        _axisY = [[WSAxisProperties alloc] init];
        [_axisX setAxisStyle:kAxisArrow];
        [_axisY setAxisStyle:kAxisArrow];
        _axisColor = [UIColor blackColor];
        _ticksX = [[WSTicks alloc] init];
        _ticksY = [[WSTicks alloc] init];
        _drawBoxed = NO;
        [_axisX setAxisOverhang:kAOverhangX];
        [_axisY setAxisOverhang:kAOverhangY];
        [_axisX setAxisPadding:kAPaddingX];
        [_axisY setAxisPadding:kAPaddingY];
        _axisArrowLength = kAArrowLength;
        _axisStrokeWidth = kAStrokeWidth;
        [_axisX setGridStyle:kGridNone];
        [_axisY setGridStyle:kGridNone];
        _gridStrokeWidth = kAStrokeWidth;
        _gridColor = [UIColor grayColor];
        _WS_tickUILabelsX = [[NSMutableArray alloc] initWithCapacity:10];
        _WS_tickUILabelsY = [[NSMutableArray alloc] initWithCapacity:10];
        _WS_axisUILabelX = [[UILabel alloc] initWithFrame:CGRectNull];
        _WS_axisUILabelY = [[UILabel alloc] initWithFrame:CGRectNull];
        [self addSubview:_WS_axisUILabelX];
        [self addSubview:_WS_axisUILabelY];
    }
    return self;
}

#pragma mark - Plot handling

- (BOOL)hasData {
    return NO;
}

- (void)setAllDisplaysOff {
    // Override this method if a plots presents something on the canvas.
    // Reset the plot to use only no-display parameters in all customizable values.
    [[self axisX] setAxisStyle:kAxisNone];
    [[self axisY] setAxisStyle:kAxisNone];
    [[self ticksX] setTicksStyle:kTicksNone];
    [[self ticksY] setTicksStyle:kTicksNone];
    [[self ticksX] setTicksDir:kTDirectionNone];
    [[self ticksY] setTicksDir:kTDirectionNone];
    [self setDrawBoxed:NO];
    [[self axisX] setGridStyle:kGridNone];
    [[self axisY] setGridStyle:kGridNone];
    [[self axisX] setAxisLabel:@""];
    [[self axisY] setAxisLabel:@""];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    NSUInteger i;
    NAFloat pos;
    NAFloat aLocX, aLocY;

    // Set the axis location.
    aLocX = [[self axisDelegate] axisBoundsX];
    aLocY = [[self axisDelegate] axisBoundsY];
    
    // First, plot the grid bars (if any). These are always below the
    // other objects and thus are drawn first.

    // First, do the X-grid.
    if ([[self axisX] gridStyle] != kGridNone) {
        CGContextBeginPath(myContext);
        [[self gridColor] set];
        CGContextSetLineWidth(myContext, [self gridStrokeWidth]);
        if ([[self axisX] gridStyle] == kGridPlain) {
            NAContextSetLineDash(myContext, kDashingSolid);
        } else if ([[self axisX] gridStyle] == kGridDotted) {
            NAContextSetLineDash(myContext, kDashingDotted);
        }
        for (i=0; i<[[self ticksX] count]; i++) {
            pos = [[self coordDelegate] boundsWithDataXD:[[self ticksX] tickAtIndex:i]];
            if ((pos > ([[self axisX] axisPadding] - [[self axisX] axisOverhang])) &&
                (pos < ([self bounds].size.width - [[self axisX] axisPadding]))) {
                // Place a grid bar at the current location.
                CGContextMoveToPoint(myContext,
                                     pos, 
                                     ([self bounds].size.height - 
                                      [[self axisY] axisPadding]));
                CGContextAddLineToPoint(myContext, 
                                        pos, 
                                        [[self axisY] axisPadding]);                
            }
        }
        CGContextDrawPath(myContext, kCGPathStroke);
    }
    
    // Then, draw the Y-grid.
    if ([[self axisY] gridStyle] != kGridNone) {
        CGContextBeginPath(myContext);
        [[self gridColor] set];
        CGContextSetLineWidth(myContext, [self gridStrokeWidth]);
        if ([[self axisY] gridStyle] == kGridPlain) {
            NAContextSetLineDash(myContext, kDashingSolid);
        } else if ([[self axisY] gridStyle] == kGridDotted) {
            NAContextSetLineDash(myContext, kDashingDotted);
        }
        for (i=0; i<[self.ticksY count]; i++) {
            pos = [[self coordDelegate] boundsWithDataYD:[[self ticksY] tickAtIndex:i]];
            if ((pos > [[self axisY] axisPadding]) &&
                (pos < ([self bounds].size.height - [[self axisY] axisPadding]))) {
                // Place a grid bar at the current location.
                CGContextMoveToPoint(myContext,
                                     ([self bounds].size.width -
                                      [[self axisX] axisPadding]),
                                     pos);
                CGContextAddLineToPoint(myContext, 
                                        [[self axisX] axisPadding],
                                        pos);
            }
        }
        CGContextDrawPath(myContext, kCGPathStroke);
    }

    // Plot the coordinate axis.

    // First, plot the X-axis.
    [[self axisColor] set];
    NAContextSetLineDash(myContext, kDashingSolid);
    NAArrowStyle aStyle = kArrowLineNone;
    NAFloat startX = [[self axisX] axisPadding] - [[self axisX] axisOverhang];
    NAFloat endX = [self bounds].size.width - [[self axisX] axisPadding];
    NAFloat startY = aLocY;
    NAFloat endY = startY;
    BOOL xPointsRight = YES;
    if ([[self coordDelegate] invertedX]) {
        NAFloat tmp = startX;
        startX = endX;
        endX = tmp;
        xPointsRight = !xPointsRight;
    }
    if (([[self axisX] axisStyle] == kAxisArrowInverse) ||
        ([[self axisX] axisStyle] == kAxisArrowFilledHeadInverse)) {
        NAFloat tmp = startX;
        startX = endX;
        endX = tmp;
        xPointsRight = !xPointsRight;
    }
    switch ([[self axisX] axisStyle]) {
        case kAxisArrowFilledHead:
        case kAxisArrowFilledHeadInverse:
            aStyle = kArrowLineFilledHead;
            break;

        case kAxisArrow:
        case kAxisArrowInverse:
            aStyle = kArrowLineArrow;
            break;

        case kAxisPlain:
            aStyle = kArrowLinePlain;
            break;

        case kAxisNone:
        default:
            aStyle = kArrowLineNone;
            break;
    }
    NAContextAddLineArrow(myContext,
                          aStyle,
                          CGPointMake(startX, startY),
                          CGPointMake(endX, endY),
                          [self axisArrowLength],
                          [self axisStrokeWidth]);
    
    // Then plot the Y-axis.
    startX = aLocX;
    endX = startX;
    startY = [[self axisY] axisPadding];
    endY = ([self bounds].size.height -
            [[self axisY] axisPadding] +
            [[self axisY] axisOverhang]);
    BOOL yPointsUp = YES;
    if ([[self coordDelegate] invertedY]) {
        NAFloat tmp = startY;
        startY = endY;
        endY = tmp;
        yPointsUp = !yPointsUp;
    }        
    if (([[self axisY] axisStyle] == kAxisArrowInverse) ||
        ([[self axisY] axisStyle] == kAxisArrowFilledHeadInverse)) {
        NAFloat tmp = startY;
        startY = endY;
        endY = tmp;
        yPointsUp = !yPointsUp;
    }
    switch ([[self axisY] axisStyle]) {
        case kAxisArrowFilledHead:
        case kAxisArrowFilledHeadInverse:
            aStyle = kArrowLineFilledHead;            
            break;

        case kAxisArrow:
        case kAxisArrowInverse:
            aStyle = kArrowLineArrow;            
            break;

        case kAxisPlain:
            aStyle = kArrowLinePlain;
            break;

        case kAxisNone:
        default:
            aStyle = kArrowLineNone;
            break;
    }
    NAContextAddLineArrow(myContext,
                          aStyle,
                          CGPointMake(startX, startY),
                          CGPointMake(endX, endY),
                          [self axisArrowLength],
                          [self axisStrokeWidth]);    

    // Now plot the box.
    if ([self drawBoxed]) {
        [[self axisColor] set];
        CGContextMoveToPoint(myContext,
                             [[self axisX] axisPadding],
                             [self bounds].size.height -
                             [[self axisY] axisPadding]);
        CGContextAddLineToPoint(myContext,
                                [self bounds].size.width -
                                [[self axisX] axisPadding],
                                [self bounds].size.height -
                                [[self axisY] axisPadding]);
        CGContextAddLineToPoint(myContext, 
                                [self bounds].size.width -
                                [[self axisX] axisPadding], 
                                [[self axisY] axisPadding]);
        CGContextAddLineToPoint(myContext, 
                                [[self axisX] axisPadding], 
                                [[self axisY] axisPadding]);
        CGContextAddLineToPoint(myContext, 
                                [[self axisX] axisPadding], 
                                [self bounds].size.height -
                                [[self axisY] axisPadding]);
    }
    
    // First, do the X-axis.
    CGContextSetLineWidth(myContext, [self axisStrokeWidth]);
        
    // Move along the X-axis until the end.
    startX = [[self axisX] axisPadding] - [[self axisX] axisOverhang];
    endX = [self bounds].size.width - [[self axisX] axisPadding];
    if (xPointsRight) {
        endX -= [self axisArrowLength];
    } else {
        startX += [self axisArrowLength];
    }
    if ([[self ticksX] count] > [_WS_tickUILabelsX count]) {
        for (i=0; i<([_WS_tickUILabelsX count] - [[self ticksX] count]); i++) {
            UILabel *aLabel = [[UILabel alloc] init];
            [_WS_tickUILabelsX addObject:aLabel];
            [self addSubview:aLabel];
        }
    }
    if ([[self ticksX] count] < [_WS_tickUILabelsX count]) {
        [_WS_tickUILabelsX
         removeObjectsAtIndexes:[NSIndexSet
                                 indexSetWithIndexesInRange:NSMakeRange([self.ticksX count],
                                                                        ([_WS_tickUILabelsX count]-[self.ticksX count]))]];
    }
    for (i=0; i<[[self ticksX] count]; i++) {
        pos = [[self coordDelegate] boundsWithDataXD:[[self ticksX] tickAtIndex:i]];
        if ((pos > startX) && (pos < endX)) {
            
            // Place a major tick mark at the current location.
            switch ([[self ticksX] ticksDir]) {
                case kTDirectionNone:
                    break;

                case kTDirectionInOut:
                    CGContextMoveToPoint(myContext,
                                         pos, 
                                         (aLocY + self.ticksX.majorTicksLen));
                    CGContextAddLineToPoint(myContext, 
                                            pos, 
                                            (aLocY - self.ticksX.majorTicksLen));
                    break;

                case kTDirectionIn:
                    CGContextMoveToPoint(myContext, 
                                         pos, 
                                         (aLocY));
                    CGContextAddLineToPoint(myContext,
                                            pos,
                                            (aLocY - self.ticksX.majorTicksLen));
                    break;

                case kTDirectionOut:
                    CGContextMoveToPoint(myContext, 
                                         pos, 
                                         (aLocY));
                    CGContextAddLineToPoint(myContext, 
                                            pos, 
                                            (aLocY + self.ticksX.majorTicksLen));
                    break;

                default:
                    break;
            }

            // Add a label to the tick mark.
            if ([[self ticksX] ticksStyle] != kTicksNone) {
                NAFloat angle = 0.25*M_PI;
                NSString *labelString = [self.ticksX labelAtIndex:i];
                UILabel *cLabel = _WS_tickUILabelsX[i];
                NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:labelString
                                                                                     attributes:@{NSFontAttributeName:self.axisX.labelFont}];
                CGRect rect = [attributedText boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                           context:nil];
                CGSize labelSize = rect.size;
                cLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                           UIViewAutoresizingFlexibleHeight);

                cLabel.textAlignment = NSTextAlignmentCenter;
                cLabel.font = self.axisX.labelFont;
                cLabel.textColor = self.axisX.labelColor;
                cLabel.backgroundColor = [UIColor clearColor];
                cLabel.text = labelString;
                CGRect newFrame = CGRectNull;
                newFrame.size = labelSize;
                cLabel.transform = CGAffineTransformIdentity;

                switch (self.ticksX.ticksStyle) {
                    case kTicksNone:
                        break;

                    case kTicksLabels:
                        newFrame.origin.x = pos - (labelSize.width / 2.0);
                        newFrame.origin.y = (aLocY +
                                             self.ticksX.majorTicksLen +
                                             self.ticksX.labelOffset);
                        cLabel.frame = newFrame;
                        break;

                    case kTicksLabelsInverse:
                        newFrame.origin.x = pos - (labelSize.width / 2.0);
                        newFrame.origin.y = (aLocY -
                                             labelSize.height -
                                             self.ticksX.majorTicksLen -
                                             self.ticksX.labelOffset);
                        [cLabel setFrame:newFrame];
                        break;

                    case kTicksLabelsSlanted:
                        newFrame.origin.x = pos;
                        newFrame.origin.y = (aLocY +
                                             self.ticksX.majorTicksLen +
                                             self.ticksX.labelOffset);
                        [cLabel setFrame:newFrame];
                        [cLabel setTransform:CGAffineTransformMakeRotation(angle)];
                        break;

                    case kTicksLabelsSlantedInverse:
                        newFrame.origin.x = pos;
                        newFrame.origin.y = (aLocY -
                                             newFrame.size.height -
                                             self.ticksX.majorTicksLen -
                                             self.ticksX.labelOffset);
                        [cLabel setFrame:newFrame];
                        [cLabel setTransform:CGAffineTransformMakeRotation(-angle)];                    
                        break;                    

                    default:
                        break;
                }
            }
        } else {
            UILabel *cLabel = _WS_tickUILabelsX[i];
            [cLabel setTransform:CGAffineTransformIdentity];
            [cLabel setFrame:CGRectNull];
        }
    }
    
    // Next, do the Y-axis.
    CGContextSetLineWidth(myContext, [self axisStrokeWidth]);
    
    // Move along the Y-axis until the end.
    startY = [[self axisY] axisPadding] - [[self axisY] axisOverhang];
    endY = [self bounds].size.height - [[self axisY] axisPadding];
    if (yPointsUp) {
        endY -= [self axisArrowLength];
    } else {
        startY += [self axisArrowLength];
    }
    if ([self.ticksY count] > [_WS_tickUILabelsY count]) {
        for (i=0; i<([_WS_tickUILabelsY count] - [self.ticksY count]); i++) {
            UILabel *aLabel = [[UILabel alloc] init];
            [_WS_tickUILabelsY addObject:aLabel];
            [self addSubview:aLabel];
        }
    }
    if ([self.ticksY count] < [_WS_tickUILabelsY count]) {
        [_WS_tickUILabelsY
         removeObjectsAtIndexes:[NSIndexSet
                                 indexSetWithIndexesInRange:NSMakeRange([self.ticksY count],
                                                                        ([_WS_tickUILabelsY count]-[self.ticksY count]))]];
    }
    for (i=0; i<[self.ticksY count]; i++) {
        pos = [[self coordDelegate] boundsWithDataYD:[[self ticksY] tickAtIndex:i]];
        if ((pos > startY) && (pos < endY)) {
        
            // Place a major tick mark at the current location.
            switch ([[self ticksY] ticksDir]) {
                case kTDirectionNone:
                    break;

                case kTDirectionInOut:
                    CGContextMoveToPoint(myContext,
                                         (aLocX +
                                          [[self ticksY] majorTicksLen]),
                                         pos);
                    CGContextAddLineToPoint(myContext, 
                                            (aLocX -
                                             [[self ticksY] majorTicksLen]),
                                            pos);
                    break;

                case kTDirectionIn:
                    CGContextMoveToPoint(myContext, 
                                         aLocX,
                                         pos);
                    CGContextAddLineToPoint(myContext,
                                            (aLocX +
                                             [[self ticksY] majorTicksLen]),
                                            pos);
                    break;

                case kTDirectionOut:
                    CGContextMoveToPoint(myContext, 
                                         aLocX,
                                         pos);
                    CGContextAddLineToPoint(myContext, 
                                            (aLocX -
                                             [[self ticksY] majorTicksLen]),
                                            pos);
                    break;

                default:
                    break;
            }

            // Add a label to the tick mark.
            if ([[self ticksY] ticksStyle] != kTicksNone) {
                NAFloat angle = 0.25*M_PI;
                NSString *labelString = [[self ticksY] labelAtIndex:i];
                UILabel *cLabel = _WS_tickUILabelsY[i];
                cLabel.textAlignment = NSTextAlignmentCenter;
                cLabel.font = self.axisY.labelFont;
                cLabel.textColor = self.axisY.labelColor;
                cLabel.backgroundColor = [UIColor clearColor];
                cLabel.text = labelString;
                cLabel.transform = CGAffineTransformIdentity;
                CGRect newFrame = CGRectNull;
                NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:labelString
                                                                                     attributes:@{NSFontAttributeName:cLabel.font}];
                CGRect rect = [attributedText boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                           context:nil];
                CGSize labelSize = rect.size;
                newFrame.size = labelSize;
                
                switch ([[self ticksY] ticksStyle]) {
                    case kTicksNone:
                        break;

                    case kTicksLabels:
                        newFrame.origin.x = (aLocX -
                                             labelSize.width -
                                             [[self ticksY] majorTicksLen] -
                                             [[self ticksY] labelOffset]);
                        newFrame.origin.y = pos - (labelSize.height / 2.0);
                        [cLabel setFrame:newFrame];
                        break;

                    case kTicksLabelsInverse:
                        newFrame.origin.x = (aLocX +
                                             [[self ticksY] majorTicksLen] +
                                             [[self ticksY] labelOffset]);
                        newFrame.origin.y = pos - (labelSize.height / 2.0);
                        [cLabel setFrame:newFrame];
                        break;

                    case kTicksLabelsSlanted:
                        newFrame.origin.x = (aLocX -
                                             labelSize.width -
                                             [[self ticksY] majorTicksLen] -
                                             [[self ticksY] labelOffset]);
                        newFrame.origin.y = pos - (labelSize.height / 2.0);
                        [cLabel setFrame:newFrame];
                        [cLabel setTransform:CGAffineTransformMakeRotation(angle)];
                        break;

                    case kTicksLabelsSlantedInverse:
                        newFrame.origin.x = (aLocX +
                                             [[self ticksY] majorTicksLen] +
                                             [[self ticksY] labelOffset]);
                        newFrame.origin.y = pos - (labelSize.height / 2.0);
                        [cLabel setFrame:newFrame];
                        [cLabel setTransform:CGAffineTransformMakeRotation(-angle)];                        

                    default:
                        break;
                }
            }                
        } else {
            UILabel *cLabel = _WS_tickUILabelsY[i];
            [cLabel setTransform:CGAffineTransformIdentity];
            [cLabel setFrame:CGRectNull];
        }
    }
    
    // Commit the path so far.
    CGContextDrawPath(myContext, kCGPathStroke);
    
    // Fill in minor tick marks between the major ones on the X-axis.
    CGContextBeginPath(myContext);
    CGContextSetLineWidth(myContext, [self axisStrokeWidth]/2.0);
    for (i=0; i<[[self ticksX] countMinor]; i++) {
        pos = [[self coordDelegate] boundsWithDataXD:[[self ticksX]
                                                     minorTickAtIndex:i]];
        if ((pos > startX) && (pos < endX)) {

            // Place a minor tick mark at the current location.
            switch ([[self ticksX] ticksDir]) {
                case kTDirectionNone:
                    break;

                case kTDirectionInOut:
                    CGContextMoveToPoint(myContext,
                                         pos,
                                         (aLocY +
                                          [[self ticksX] minorTicksLen]));                        
                    CGContextAddLineToPoint(myContext,
                                            pos,
                                            (aLocY -
                                             [[self ticksX] minorTicksLen]));                                                   
                    break;

                case kTDirectionIn:
                    CGContextMoveToPoint(myContext, 
                                         pos, 
                                         (aLocY));
                    CGContextAddLineToPoint(myContext,
                                            pos,
                                            (aLocY -
                                             [[self ticksX] minorTicksLen]));
                    break;

                case kTDirectionOut:
                    CGContextMoveToPoint(myContext, 
                                         pos, 
                                         (aLocY));                           
                    CGContextAddLineToPoint(myContext,
                                            pos,
                                            (aLocY +
                                             [[self ticksX] minorTicksLen]));
                    break;

                default:
                    break;
            }
        }
    }
    
    // Fill in minor tick marks between the major ones on the Y-axis.
    for (i=0; i<[[self ticksY] countMinor]; i++) {
        pos = [[self coordDelegate] boundsWithDataYD:[[self ticksY]
                                                     minorTickAtIndex:i]];
        if ((pos > startY) && (pos < endY)) {
            
            // Place a minor tick mark at the current location.
            switch ([[self ticksY] ticksDir]) {
                case kTDirectionNone:
                    break;

                case kTDirectionInOut:
                    CGContextMoveToPoint(myContext,
                                         (aLocX +
                                          [[self ticksY] minorTicksLen]),
                                         pos);
                    CGContextAddLineToPoint(myContext, 
                                            (aLocX -
                                             [[self ticksY] minorTicksLen]),
                                            pos);
                    break;

                case kTDirectionIn:
                    CGContextMoveToPoint(myContext, 
                                         aLocX,
                                         pos);
                    CGContextAddLineToPoint(myContext,
                                            (aLocX +
                                             [[self ticksY] minorTicksLen]),
                                            pos);
                    break;

                case kTDirectionOut:
                    CGContextMoveToPoint(myContext,
                                         aLocX,
                                         pos);
                    CGContextAddLineToPoint(myContext, 
                                            (aLocX -
                                             [[self ticksY] minorTicksLen]),
                                            pos);
                    break;

                default:
                    break;
            }
        }
    }

    // Commit the path so far.
    CGContextDrawPath(myContext, kCGPathStroke);

    // Finally, add the axis labels.
    
    // First, the X-axis label.
    if (self.axisX.labelStyle != kLabelNone) {
        
        // Configure the label, compute its size and position it as
        // requested.
        _WS_axisUILabelX.textAlignment = NSTextAlignmentCenter;
        _WS_axisUILabelX.font = [[self axisX] labelFont];
        _WS_axisUILabelX.textColor = [[self axisX] labelColor];
        _WS_axisUILabelX.backgroundColor = [UIColor clearColor];
        _WS_axisUILabelX.text = [[self axisX] axisLabel];
        CGRect newFrame = CGRectNull;
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self.axisX.axisLabel
                                                                             attributes:@{NSFontAttributeName:_WS_axisUILabelX.font}];
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        CGSize labelSize = rect.size;
        newFrame.size = labelSize;
        switch (self.axisX.labelStyle) {
            case kLabelNone:
                break;

            case kLabelCenter:
                newFrame.origin.x = 0.5*(self.bounds.size.width -
                                         newFrame.size.width);
                newFrame.origin.y = (aLocY +
                                     [[self axisX] labelOffset] +
                                     [[self axisY] axisOverhang]);
                break;

            case kLabelEnd:
                newFrame.origin.x = ([self bounds].size.width -
                                     [[self axisX] axisPadding] -
                                     labelSize.width);
                newFrame.origin.y = (aLocY +
                                     [[self axisX] labelOffset] +
                                     [[self axisY] axisOverhang]);
                break;

            case kLabelInside:
                newFrame.origin.x = ([self bounds].size.width -
                                     [[self axisX] axisPadding] -
                                     labelSize.width);
                newFrame.origin.y = (aLocY -
                                     [[self axisX] labelOffset] -
                                     [[self axisY] axisOverhang] -
                                     labelSize.height);
                break;

            default:
                break;
        }
        _WS_axisUILabelX.frame = newFrame;
    } else {
        _WS_axisUILabelX.transform = CGAffineTransformIdentity;
        _WS_axisUILabelX.frame = CGRectNull;
    }

    // Next, the Y-axis label.
    if ([[self axisY] labelStyle] != kLabelNone) {
        
        // Configure the label, compute its size and position it as
        // requested.
        _WS_axisUILabelY.textAlignment = NSTextAlignmentCenter;
        _WS_axisUILabelY.font = [[self axisY] labelFont];
        _WS_axisUILabelY.textColor = [[self axisY] labelColor];
        _WS_axisUILabelY.backgroundColor = [UIColor clearColor];
        _WS_axisUILabelY.text = [[self axisY] axisLabel];
        _WS_axisUILabelY.transform = CGAffineTransformIdentity;
        CGRect newFrame = CGRectNull;
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self.axisY.axisLabel
                                                                             attributes:@{NSFontAttributeName:_WS_axisUILabelY.font}];
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        CGSize labelSize = rect.size;
        newFrame.size = labelSize;

        switch ([[self axisY] labelStyle]) {
            case kLabelCenter:
                newFrame.origin.x = (aLocX -
                                     [[self ticksY] majorTicksLen] -
                                     [[self axisY] labelOffset] -
                                     [[self axisX] axisOverhang] -
                                     labelSize.height);
                newFrame.origin.y = 0.5*([self bounds].size.height -
                                         labelSize.width);
                newFrame.size.width = labelSize.height;
                newFrame.size.height = labelSize.width;
                [_WS_axisUILabelY setFrame:newFrame];
                [_WS_axisUILabelY setTransform:CGAffineTransformMakeRotation(1.5*M_PI)];
                break;

            case kLabelEnd:
                newFrame.origin.x = (aLocX -
                                     [[self axisY] labelOffset] -
                                     0.5*labelSize.width);
                newFrame.origin.y = ([[self axisY] axisPadding] -
                                     [[self axisY] axisOverhang] -
                                     labelSize.height);
                [_WS_axisUILabelY setFrame:newFrame];
                break;

            case kLabelInside:
                newFrame.origin.x = (aLocX +
                                     [[self axisY] labelOffset] +
                                     [[self axisX] axisOverhang]);
                newFrame.origin.y = ([[self axisY] axisPadding] -
                                     0.5*labelSize.height);
                [_WS_axisUILabelY setFrame:newFrame];
                break;

            default:
                break;
        }
    } else {
        _WS_axisUILabelY.transform = CGAffineTransformIdentity;
        _WS_axisUILabelY.frame = CGRectNull;
    }
}

#pragma mark - Ticks configuration

- (void)setTicksXDWithData:(WSData *)data {
    NSMutableArray *positions = [NSMutableArray arrayWithCapacity:[data count]];
    
    for (WSDatum *item in data) {
        NAFloat valX = item.valueX;
        NSParameterAssert(!isnan(valX));
        [positions addObject:@(valX)];
    }
    [[self ticksX] ticksWithNumbers:positions];    
}

- (void)setTicksXDAndLabelsWithData:(WSData *)data {
    NSMutableArray *positions = [NSMutableArray arrayWithCapacity:[data count]];
    NSMutableArray *labels = [NSMutableArray arrayWithCapacity:[data count]];
    
    for (WSDatum *item in data) {
        NAFloat valX = item.valueX;
        NSParameterAssert(!isnan(valX));
        [positions addObject:@(valX)];
        NSString *anno = item.annotation;
        if (!anno) {
            anno = @"";
        }
        [labels addObject:anno];
    }
    [[self ticksX] ticksWithNumbers:positions labels:labels];    
}

- (void)setTicksXDAndLabelsWithData:(WSData *)data
                        minDistance:(NAFloat)distance {
    
    WSData *tmp = [data sortedDataUsingValueX];
    WSData *result = [WSData data];
    [result addDatum:[tmp datumAtIndex:0]];
    
    NAFloat pos = [[self coordDelegate] boundsWithDataXD:[[result datumAtIndex:0]
                                                         valueX]];
    NAFloat newPos;
    
    for (WSDatum *datum in tmp) {
        newPos = [[self coordDelegate] boundsWithDataXD:[datum valueX]];
        if (newPos == pos) {
            continue;
        }
        if (fabs(newPos - pos) >= distance) {
            [result addDatum:datum];
        }
    }
    
    [self setTicksXDAndLabelsWithData:result];
}

- (void)autoTicksXD {
    [[self ticksX] autoTicksWithRange:[[self coordDelegate] rangeXD]
                               number:([self bounds].size.width/kDefaultTicksDistance)
                            skipFirst:YES];
}

- (void)autoTicksYD {
    [[self ticksY] autoTicksWithRange:[[self coordDelegate] rangeYD]
                               number:([self bounds].size.height/kDefaultTicksDistance)
                            skipFirst:YES];
}

- (void)autoNiceTicksXD {
    [[self ticksX] autoNiceTicksWithRange:[[self coordDelegate] rangeXD]
                                   number:([self bounds].size.width/kDefaultTicksDistance)];
}

- (void)autoNiceTicksYD {
    [[self ticksY] autoNiceTicksWithRange:[[self coordDelegate] rangeYD]
                                   number:([self bounds].size.width/kDefaultTicksDistance)];
}

- (void)setTickLabelsX {
    [[self ticksX] setTickLabels];
}

- (void)setTickLabelsY {
    [[self ticksY] setTickLabels];
}

- (void)setTickLabelsXWithStyle:(NSNumberFormatterStyle)style {
    [[self ticksX] setTickLabelsWithStyle:style];
}

- (void)setTickLabelsYWithStyle:(NSNumberFormatterStyle)style {
    [[self ticksY] setTickLabelsWithStyle:style];
}

- (void)setTickLabelsXWithFormatter:(NSNumberFormatter *)formatter {
    [[self ticksX] setTickLabelsWithFormatter:formatter];
}

- (void)setTickLabelsYWithFormatter:(NSNumberFormatter *)formatter {
    [[self ticksY] setTickLabelsWithFormatter:formatter];
}

#pragma mark -

- (void)dealloc {
    for (UILabel *aLabel in _WS_tickUILabelsX) {
        [aLabel removeFromSuperview];
    }
    for (UILabel *aLabel in _WS_tickUILabelsY) {
        [aLabel removeFromSuperview];
    }
    [_WS_axisUILabelX removeFromSuperview];
    [_WS_axisUILabelY removeFromSuperview];
}

@end
