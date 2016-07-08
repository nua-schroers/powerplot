//
//  WSChart.m
//  PowerPlot
//
//  Created by Wolfram Schroers on 23.09.10.
//  Copyright 2010-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import <PowerPlot/PowerPlot.h>

/** Offset of chart title from top of chart view frame (hard-coded). */
const NAFloat kChartTitleTopOffset = 10.0;

@interface WSChart ()

/** Private method to reset the view hierarchy after changes to plots. */
- (void)WS_viewHierarchyDidChange;

/** Private chart title label. */
@property (nonatomic, strong) UILabel *WS_titleLabel;

/** Initialize the title label. */
- (void)WS_initTitleLabel;

@end

@implementation WSChart

+ (NSString *)version
{
    return [NSString stringWithFormat:@"%3.1f", PowerPlotVersionNumber];
}

+ (NSString *)license
{
    return @"MIT";
}

- (instancetype)init {
    return [self initWithFrame:CGRectNull];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Custom initialization.
        self.customData = nil;
        [self resetChart];
        [self WS_initTitleLabel];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization.
        self.customData = nil;
        [self resetChart];
        [self WS_initTitleLabel];
    }
    return self;
}

- (void)awakeFromNib {
    [self resetChart];
}

- (void)resetChart {
    [self abortAnimation];

    // Initialize the chart with default values.
    self.chartTitleFont = [UIFont systemFontOfSize:24.0];
    self.chartTitleColor = [UIColor blackColor];
    self.backgroundColor = [UIColor whiteColor];
    self.plotSet = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)drawRect:(CGRect)rect {
    for (WSPlotController *ctrl in self.plotSet) {
        [ctrl.view setNeedsDisplay];
    }
}

- (void)layoutSubviews {
    for (WSPlotController *ctrl in self.plotSet) {
        ctrl.view.frame = self.bounds;
        [ctrl.view setNeedsDisplay];
    }
    self.chartTitle = self.chartTitle;
}

- (void)WS_initTitleLabel {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:self.frame];
    titleLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                   UIViewAutoresizingFlexibleRightMargin);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = self.chartTitleFont;
    titleLabel.textColor = self.chartTitleColor;
    titleLabel.backgroundColor = [UIColor clearColor];
    self.WS_titleLabel = titleLabel;
    [self addSubview:self.WS_titleLabel];
}

#pragma mark - Chart title handling

- (void)setChartTitle:(NSString *)newTitle {
    if (_chartTitle != newTitle) {
        _chartTitle = (newTitle ? newTitle : @"");
        [[self WS_titleLabel] setFrame:self.bounds];
        [[self WS_titleLabel] setText:_chartTitle];
        [[self WS_titleLabel] sizeToFit];
        [[self WS_titleLabel] setCenter:CGPointMake(self.center.x,
                                                    self.WS_titleLabel.frame.size.height + kChartTitleTopOffset)];
    }
}

#pragma mark - Plot array handling

- (void)addPlotsFromChart:(WSChart *)chart {
    for (WSPlotController *ctl in [chart plotSet]) {
        [self addPlot:ctl];
    }
    [self WS_viewHierarchyDidChange];
}

- (void)generateControllerWithData:(WSData *)dataD
                         plotClass:(Class<NSObject>)aClass
                             frame:(CGRect)frame {
    NSParameterAssert([(id)aClass isSubclassOfClass:[WSPlot class]]);

    WSPlotController *aController = [[WSPlotController alloc] init];
    id aPlot = [[((id)aClass) alloc] initWithFrame:frame];
    aController.view = aPlot;
    aController.dataD = dataD;
    if ([self count] > 0) {
        WSPlotController *firstPlot = self[0];
        aController.coordX = firstPlot.coordX;
        aController.coordY = firstPlot.coordY;
        aController.axisLocationX = firstPlot.axisLocationX;
        aController.axisLocationY = firstPlot.axisLocationY;
        firstPlot.axisLocationX.coordDelegate = firstPlot;
        firstPlot.axisLocationY.coordDelegate = firstPlot;
    }
    [self addPlot:aController];
}

- (void)addPlot:(WSPlotController *)aPlot {
    [[aPlot view] setFrame:self.bounds];
    [self.plotSet addObject:aPlot];
    [self WS_viewHierarchyDidChange];
}

- (void)insertPlot:(WSPlotController *)aPlot
           atIndex:(NSUInteger)idx {
    [[aPlot view] setFrame:self.bounds];
    [self.plotSet insertObject:aPlot atIndex:idx];
    [self WS_viewHierarchyDidChange];
}

- (void)replacePlotAtIndex:(NSUInteger)idx
                  withPlot:(WSPlotController *)aPlot {
    [[aPlot view] setFrame:self.bounds];
    self.plotSet[idx] = aPlot;
    [self WS_viewHierarchyDidChange];
}

- (void)bringPlotToFront:(WSPlotController *)aPlot
{
    NSUInteger index = [self.plotSet indexOfObject:aPlot];
    if (index != NSNotFound) {
        [self.plotSet removeObject:aPlot];
        [self addPlot:aPlot];
    }
}

- (void)sendPlotToBack:(WSPlotController *)aPlot
{
    NSUInteger index = [self.plotSet indexOfObject:aPlot];
    if (index != NSNotFound) {
        [self.plotSet removeObject:aPlot];
        [self insertPlot:aPlot
                 atIndex:0];
    }
}

- (NSUInteger)indexOfPlot:(WSPlotController *)aPlot
{
    return [self.plotSet indexOfObject:aPlot];
}

- (void)removeAllPlots {
    for (WSPlotController *plotCtrl in self.plotSet) {
        NSParameterAssert([plotCtrl.view isKindOfClass:[UIView class]]);
        [plotCtrl.view removeFromSuperview];
    }
    [self.plotSet removeAllObjects];
    [self WS_viewHierarchyDidChange];
}

- (void)removePlotAtIndex:(NSUInteger)idx {
    [self.plotSet removeObjectAtIndex:idx];
    [self WS_viewHierarchyDidChange];
}

- (void)exchangePlotAtIndex:(NSUInteger)idx1
            withPlotAtIndex:(NSUInteger)idx2 {
    [self.plotSet exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
    [self WS_viewHierarchyDidChange];
}

- (WSPlotController *)plotAtIndex:(NSUInteger)idx {
    return self.plotSet[idx];
}

- (WSPlotController *)lastPlot {
    return [self.plotSet lastObject];
}

- (WSPlotController *)firstPlot {
    return [self.plotSet firstObject];
}

- (NSUInteger)count {
    return [self.plotSet count];
}

- (id)firstPlotOfClass:(Class)aClass {
    for (WSPlotController *aPlot in self.plotSet) {
        if ([[aPlot view] isKindOfClass:aClass]) {
            return [aPlot view];
        }
    }
    return nil;
}

- (WSPlotAxis *)firstPlotAxis {
    return [self firstPlotOfClass:[WSPlotAxis class]];
}

#pragma mark - Coordinate system handling

- (BOOL)isAxisConsistentX {
    NARange aRangeD, tmpRangeD;

    // Only need to work if there is data there.
    if ([self count] > 0) {
        aRangeD = NARANGE_INVALID;
        SEL getRangeXD = @selector(rangeXD);
        for (WSPlotController *item in self.plotSet) {
            if ([item respondsToSelector:getRangeXD]) {
                aRangeD = [item rangeXD];
                if ((!isnan(aRangeD.rMin)) && !(isnan(aRangeD.rMax)))
                    break;
            }
        }
        // Is there any useful data in the first plot that responds?
        if (isnan(aRangeD.rMin) || isnan(aRangeD.rMax))
            return NO;
        
        // Check all ranges.
        for (WSPlotController *item in self.plotSet) {
            if ([item respondsToSelector:getRangeXD]) {
                tmpRangeD = [item rangeXD];
                if ((tmpRangeD.rMin != aRangeD.rMin) ||
                    (tmpRangeD.rMax != aRangeD.rMax))
                    return NO;
            }
        }
    }
    return YES;
}

/** Return if all plots have identical Y-axis scales. */
- (BOOL)isAxisConsistentY {
    NARange aRangeD, tmpRangeD;
    
    // Only need to work if there is data there.
    if ([self count] > 0) {
        aRangeD = NARANGE_INVALID;
        SEL getRangeYD = @selector(rangeYD);
        for (WSPlotController *item in self.plotSet) {
            if ([item respondsToSelector:getRangeYD]) {
                aRangeD = [item rangeYD];
                if ((!isnan(aRangeD.rMin)) && (!isnan(aRangeD.rMax)))
                    break;
            }
        }
        // Is there useful data in the first plot that responds?
        if (isnan(aRangeD.rMin) || isnan(aRangeD.rMax))
            return NO;
        
        // Check all ranges.
        for (WSPlotController *item in self.plotSet) {
            if ([item respondsToSelector:getRangeYD]) {
                tmpRangeD = [item rangeYD];
                if ((tmpRangeD.rMin != aRangeD.rMin) ||
                    (tmpRangeD.rMax != aRangeD.rMax))
                    return NO;
            }
        }
    }
    return YES;
}

- (void)scaleAllAxisXD:(NARange)aRangeD {
    NSParameterAssert(NARangeLen(aRangeD) > 0.0);
    // Set the coordinate axis scale in all plots.
    for (WSPlotController *item in self.plotSet) {
        [item setRangeXD:aRangeD];
    }    
}

- (void)scaleAllAxisYD:(NARange)aRangeD {
    NSParameterAssert(NARangeLen(aRangeD) > 0.0);
    // Set the coordinate axis scale in all plots.
    for (WSPlotController *item in self.plotSet) {
        [item setRangeYD:aRangeD];
    }
}

- (void)autoscaleAllAxisX {
    NARange aRangeD = NARangeStretchGoldenRatio([self dataRangeXD]);
    if (!NARange_isValid(aRangeD)) {
        aRangeD = NARangeMake(0., 1.);
    } else if (NARange_hasZeroLen(aRangeD)) {
        aRangeD = NARangeMake(aRangeD.rMin - 1., aRangeD.rMax + 1.);
    }
    [self scaleAllAxisXD:aRangeD];
}

- (void)autoscaleAllAxisY {
    NARange aRangeD = NARangeStretchGoldenRatio([self dataRangeYD]);
    if (!NARange_isValid(aRangeD)) {
        aRangeD = NARangeMake(0., 1.);
    } else if (NARange_hasZeroLen(aRangeD)) {
        aRangeD = NARangeMake(aRangeD.rMin - 1., aRangeD.rMax + 1.);
    }
    [self scaleAllAxisYD:aRangeD];
}

- (void)setAllAxisLocationX:(NAFloat)aLocation {
    for (WSPlotController *ctrl in self.plotSet) {
        [[ctrl axisLocationX] setBounds:aLocation];
    }
}

- (void)setAllAxisLocationY:(NAFloat)aLocation {
    for (WSPlotController *ctrl in self.plotSet) {
        [[ctrl axisLocationY] setBounds:aLocation];
    }
}

- (void)setAllAxisLocationXD:(NAFloat)aLocationD {
    for (WSPlotController *ctrl in self.plotSet) {
        [[ctrl axisLocationX] setDataD:aLocationD];
    }
}

- (void)setAllAxisLocationYD:(NAFloat)aLocationD {
    for (WSPlotController *ctrl in self.plotSet) {
        [[ctrl axisLocationY] setDataD:aLocationD];
    }
}

- (void)setAllAxisLocationToOriginXD {
    [self setAllAxisLocationXD:0.];
}

- (void)setAllAxisLocationToOriginYD {
    [self setAllAxisLocationYD:0.];
}

- (void)setAllAxisLocationXRelative:(CGFloat)aLocation {
    for (WSPlotController *ctrl in self.plotSet) {
        [[ctrl axisLocationX] setRelative:aLocation];
    }
}

- (void)setAllAxisLocationYRelative:(CGFloat)aLocation {
    for (WSPlotController *ctrl in self.plotSet) {
        [[ctrl axisLocationY] setRelative:aLocation];
    }
}

- (void)setAllAxisPreserveOnChangeX:(WSAxisLocationPreservationStyle)aStyle {
    for (WSPlotController *ctrl in self.plotSet) {
        [[ctrl axisLocationX] setPreserveOnChange:aStyle];
    }
}

- (void)setAllAxisPreserveOnChangeY:(WSAxisLocationPreservationStyle)aStyle {
    for (WSPlotController *ctrl in self.plotSet) {
        [[ctrl axisLocationY] setPreserveOnChange:aStyle];
    }
}

#pragma mark - Data handling

- (NARange)dataRangeD:(SEL)dataExtract {
    NARange aRangeD, tmpRangeD;
    
    // This only works with at least one plot.
    aRangeD = NARANGE_INVALID;
    if ([self count] > 0) {
        
        // Start with any given range (if possible).
        for (WSPlotController *item in self.plotSet) {
            if ([item respondsToSelector:dataExtract]) {
                NSInvocation *inv = [NSInvocation
                                     invocationWithMethodSignature:[item
                                                                    methodSignatureForSelector:dataExtract]];
                [inv setTarget:item];
                [inv setSelector:dataExtract];
                [inv invoke];
                [inv getReturnValue:&aRangeD];
                if ((!isnan(aRangeD.rMin)) && (!isnan(aRangeD.rMax)))
                    break;
            }
        }
        if (isnan(aRangeD.rMin) || isnan(aRangeD.rMax)) {
            return NARANGE_INVALID;
        }
        
        // Then find the maximum range possible.
        for (WSPlotController *item in self.plotSet) {
            if ([item respondsToSelector:dataExtract]) {
                NSInvocation *inv = [NSInvocation
                                     invocationWithMethodSignature:[item
                                                                    methodSignatureForSelector:dataExtract]];
                [inv setTarget:item];
                [inv setSelector:dataExtract];
                [inv invoke];
                [inv getReturnValue:&tmpRangeD];
                aRangeD = NARangeMax(aRangeD, tmpRangeD);
            }
        }
    }

    return aRangeD;
}

- (NARange)dataRangeXD {
    return [self dataRangeD:@selector(dataRangeXD)];
}
- (NARange)dataRangeYD {
    return [self dataRangeD:@selector(dataRangeYD)];
}

- (WSPlotController *)objectAtIndexedSubscript:(NSUInteger)idx
{
    return [self plotAtIndex:idx];
}

- (void)setObject:(WSPlotController *)obj
atIndexedSubscript:(NSUInteger)idx
{
    obj.view.frame = self.bounds;
    self.plotSet[idx] = obj;
    [self WS_viewHierarchyDidChange];
}

@synthesize animationTimer = _animationTimer;

- (void)abortAnimation {
    if (self.animationTimer != nil) {
        // Recover the active handlers (if present).
        NSMutableDictionary *userInfo = self.animationTimer.userInfo;
        void (^completionHandlerCopy)(BOOL);
        completionHandlerCopy = userInfo[WSUI_COMPLETION];

        // Call completion handler and clean everything up.
        [self.animationTimer invalidate];
        self.animationTimer = nil;

        if (completionHandlerCopy != nil) {
            completionHandlerCopy(NO);
        }
    }
}

#pragma mark -

- (void)WS_viewHierarchyDidChange {
    self.chartTitle = self.chartTitle;

    for (UIView *item in self.subviews) {
        if ([item isKindOfClass:[WSPlot class]]) {
            [(WSPlot *)item removeFromSuperview];
        }
    }
    for (WSPlotController *item in self.plotSet) {
        [self addSubview:item.view];
    }
}

- (NSString *)description {
    NSMutableString *prtCont = [NSMutableString
                                stringWithFormat:@"WSChart with %lu plots: [",
                                (unsigned long)[self count]];
    for (WSPlotController *item in self.plotSet) {
        [prtCont appendString:[item description]];
        [prtCont appendString:@","];
    }
    [prtCont appendString:@"nil]."];
    
    return [NSString stringWithString:prtCont];
}

- (void)dealloc {
    [self abortAnimation];
    [self removeAllPlots];

    [_WS_titleLabel removeFromSuperview];
}

@end
