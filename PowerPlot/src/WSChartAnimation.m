//
//  WSChartAnimation.m
//  PowerPlot
//
//  Created by Wolfram Schroers on 11/7/11.
//  Copyright (c) 2011-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import "WSChartAnimation.h"
#import "WSChartAnimationKeys.h"
#import "WSPlotController.h"
#import "WSData.h"
#import "WSDataOperations.h"
#import "WSDatum.h"
#import "WSCoordinate.h"

/// Internal helpers for animation.
@interface WSChart (WSChartAnimationHelper)

/** Return the ease in/out helper function, maps @p [0,1] -> @p [0,1].
 
    With PowerPlot v1.4 the default is now the @p smoothstep function
    (see, e.g. http://en.wikipedia.org/wiki/Smoothstep ). Since
    PowerPlot v2.0 this is the only option available.
 */
+ (NAFloat)WS_easeInOutHelper:(NAFloat)x;

@end

@implementation WSChart (WSChartAnimation)

- (void)dataAnimateWithDuration:(NSTimeInterval)duration
                          delay:(NSTimeInterval)delay
                        options:(WSChartAnimationOptions)options
                     animations:(void (^)(void))animations
                        context:(id)context
                         update:(void (^)(NAFloat, id))update
                     completion:(void (^)(BOOL))completion {
    
    // Verify that we have an animations block.
    NSAssert(animations != nil, @"Animations block must not be nil!");
    NSAssert(self.animationTimer == nil, @"Multiple animations initialized!");
    
    // Set up the information for the animation.
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:12];
    if (update != nil) {
        void (^updateHandlerCopy)(NAFloat, id) = [update copy];
        [userInfo setValue:context forKey:WSUI_CONTEXT_KEY];
        userInfo[WSUI_CONTEXT_CUSTOM] = updateHandlerCopy;
    }
    if (completion != nil) {
        void (^completionHandlerCopy)(BOOL) = [completion copy];
        userInfo[WSUI_COMPLETION] = completionHandlerCopy;
    }
    [userInfo setValue:@(options)
                forKey:WSUI_OPTIONS];
    userInfo[WSUI_ITERATION] = @0;
    userInfo[WSUI_DURATION] = @(duration);
    
    // Store the old and the new animatable properties.
    NSMutableArray *oldData = [NSMutableArray arrayWithCapacity:[self count]];
    NSMutableArray *oldCoordX = [NSMutableArray arrayWithCapacity:[self count]];
    NSMutableArray *oldCoordY = [NSMutableArray arrayWithCapacity:[self count]];
    NSMutableArray *newData = [NSMutableArray arrayWithCapacity:[self count]];
    NSMutableArray *newCoordX = [NSMutableArray arrayWithCapacity:[self count]];
    NSMutableArray *newCoordY = [NSMutableArray arrayWithCapacity:[self count]];
    for (NSUInteger i=0; i<[self count]; i++) {
        WSPlotController *currentCtrl = [self plotAtIndex:i];
        WSCoordinate *coordX = [currentCtrl coordX];
        WSCoordinate *coordY = [currentCtrl coordY];
        [oldData addObject:[[currentCtrl dataD] copy]];
        [oldCoordX addObject:@[@([coordX coordRangeD].rMin),
                              @([coordX coordRangeD].rMax),
                              @([coordX coordOrigin])]];
        [oldCoordY addObject:@[@([coordY coordRangeD].rMin),
                              @([coordY coordRangeD].rMax),
                              @([coordY coordOrigin])]];
    }
    animations();
    for (NSUInteger i=0; i<[self count]; i++) {
        WSPlotController *currentCtrl = [self plotAtIndex:i];
        WSCoordinate *coordX = [currentCtrl coordX];
        WSCoordinate *coordY = [currentCtrl coordY];
        [newData addObject:[[currentCtrl dataD] copy]];
        NSAssert([((NSArray *)[newData lastObject]) count] == [((NSArray *)oldData[i]) count],
                 @"Length of data object changed during animation!");
        [newCoordX addObject:@[@([coordX coordRangeD].rMin),
                              @([coordX coordRangeD].rMax),
                              @([coordX coordOrigin])]];
        [newCoordY addObject:@[@([coordY coordRangeD].rMin),
                              @([coordY coordRangeD].rMax),
                              @([coordY coordOrigin])]];
    }
    [userInfo setValue:oldData forKey:WSUI_OLDDATA];
    [userInfo setValue:oldCoordX forKey:WSUI_OLDCOORDINATEX];
    [userInfo setValue:oldCoordY forKey:WSUI_OLDCOORDINATEY];
    [userInfo setValue:newData forKey:WSUI_NEWDATA];
    [userInfo setValue:newCoordX forKey:WSUI_NEWCOORDINATEX];
    [userInfo setValue:newCoordY forKey:WSUI_NEWCOORDINATEY];
    
    // Restore the former settings.
    for (NSUInteger i=0; i<[self count]; i++) {
        WSPlotController *currentCtrl = [self plotAtIndex:i];
        [currentCtrl setDataD:oldData[i]];
        NSArray *oldCX = oldCoordX[i];
        NSArray *oldCY = oldCoordY[i];
        [[currentCtrl coordX] setCoordRangeD:NARangeMake([oldCX[0] floatValue],
                                                         [oldCX[1] floatValue])];
        [[currentCtrl coordX] setCoordOrigin:[oldCX[2] floatValue]];
        [[currentCtrl coordY] setCoordRangeD:NARangeMake([oldCY[0] floatValue],
                                                         [oldCY[1] floatValue])];
        [[currentCtrl coordY] setCoordOrigin:[oldCY[2] floatValue]];
    }
    
    // Set up the animation timer.
    [self setAnimationTimer:[NSTimer scheduledTimerWithTimeInterval:delay
                                                             target:self
                                                           selector:@selector(dataBeginAnimation:)
                                                           userInfo:userInfo
                                                            repeats:NO]];
}

- (void)dataAnimateWithDuration:(NSTimeInterval)duration
                          delay:(NSTimeInterval)delay
                        options:(WSChartAnimationOptions)options
                     animations:(void (^)(void))animations
                     completion:(void (^)(BOOL))completion {
    [self dataAnimateWithDuration:duration
                            delay:delay
                          options:options
                       animations:animations
                          context:nil
                           update:NULL
                       completion:completion];
}

- (void)dataAnimateWithDuration:(NSTimeInterval)duration
                     animations:(void (^)(void))animations
                     completion:(void (^)(BOOL))completion {
    [self dataAnimateWithDuration:duration
                            delay:0.
                          options:kWSChartAnimationOptionCurveEaseInOut
                       animations:animations
                       completion:completion];
}

- (void)dataAnimateWithDuration:(NSTimeInterval)duration
                     animations:(void (^)(void))animations {
    [self dataAnimateWithDuration:duration
                       animations:animations
                       completion:NULL];
}

- (void)dataBeginAnimation:(NSTimer *)aTimer {
    NSTimeInterval interval = 1./kWSChartAnimationFPS;
    [self setAnimationTimer:[NSTimer scheduledTimerWithTimeInterval:interval
                                                             target:self
                                                           selector:@selector(dataUpdateAnimation:)
                                                           userInfo:aTimer.userInfo
                                                            repeats:YES]];
}

- (void)dataUpdateAnimation:(NSTimer *)aTimer {
    BOOL final = NO;
    
    // Get options and parameters from dictionary userInfo.
    NSMutableDictionary *userInfo = (NSMutableDictionary *)aTimer.userInfo;
    NSInteger iteration = [(NSNumber *)userInfo[WSUI_ITERATION]
                           intValue];
    NAFloat duration = [(NSNumber *)userInfo[WSUI_DURATION]
                        floatValue];
    WSChartAnimationOptions options = [(NSNumber *)userInfo[WSUI_OPTIONS]
                                       intValue];
    NAFloat progress = [WSChart progressionAtIteration:(NAFloat)iteration
                                              duration:duration
                                               options:options];
    void (^updateHandlerCopy)(NAFloat, id);
    updateHandlerCopy = userInfo[WSUI_CONTEXT_CUSTOM];
    
    // Update iteration, check current progress, end animation if necessary.
    iteration++;
    ((NSMutableDictionary *)aTimer.userInfo)[WSUI_ITERATION] = @(iteration);
    if (iteration >= floor(duration*kWSChartAnimationFPS)) {
        final = YES;
        progress = 1.;
    }
    
    // Perform chart update.
    NSArray *oldSet = userInfo[WSUI_OLDDATA];
    NSArray *newSet = userInfo[WSUI_NEWDATA];
    for (NSUInteger i=0; i<[oldSet count]; i++) {
        WSData *cData = [WSData data:@[oldSet[i],
                                      newSet[i]]
                                 map:^WSDatum *(const id args) {
                                     WSDatum *oldDatum = args[0];
                                     WSDatum *newDatum = args[1];
                                     WSDatum *currentDatum = [WSDatum datum];
                                     NAFloat valX = ([oldDatum valueX] + progress * ([newDatum valueX] - [oldDatum valueX]));
                                     NAFloat valY = ([oldDatum valueY] + progress * ([newDatum valueY] - [oldDatum valueY]));
                                     
                                     [currentDatum setValue:valY];
                                     [currentDatum setValueX:valX];
                                     if ([newDatum hasErrorX]) {
                                         NAFloat errorMinX = ([oldDatum errorMinX] + progress * ([newDatum errorMinX] - [oldDatum errorMinX]));
                                         NAFloat errorMaxX = ([oldDatum errorMaxX] + progress * ([newDatum errorMaxX] - [oldDatum errorMaxX]));
                                         [currentDatum setErrorMinX:errorMinX];
                                         [currentDatum setErrorMaxX:errorMaxX];
                                     }
                                     if ([newDatum hasErrorY]) {
                                         NAFloat errorMinY = ([oldDatum errorMinY] + progress * ([newDatum errorMinY] - [oldDatum errorMinY]));
                                         NAFloat errorMaxY = ([oldDatum errorMaxY] + progress * ([newDatum errorMaxY] - [oldDatum errorMaxY]));
                                         [currentDatum setErrorMinY:errorMinY];
                                         [currentDatum setErrorMaxY:errorMaxY];
                                     }
                                     if ([newDatum hasErrorX] && [newDatum hasErrorY]) {
                                         NAFloat errorCorr = ([oldDatum errorCorr] + progress * ([newDatum errorCorr] - [oldDatum errorCorr]));
                                         [currentDatum setErrorCorr:errorCorr];
                                     }
                                     
                                     if ([newDatum annotation]) {
                                         [currentDatum setAnnotation:[newDatum annotation]];
                                     }
                                     return currentDatum;
                                 }];
        
        NSArray *oldCoordX = userInfo[WSUI_OLDCOORDINATEX][i];
        NSArray *newCoordX = userInfo[WSUI_NEWCOORDINATEX][i];
        NSArray *oldCoordY = userInfo[WSUI_OLDCOORDINATEY][i];
        NSArray *newCoordY = userInfo[WSUI_NEWCOORDINATEY][i];
        
        NAFloat oldXrMin = [(NSNumber *)oldCoordX[0] floatValue];
        NAFloat oldXrMax = [(NSNumber *)oldCoordX[1] floatValue];
        NAFloat oldXOrig = [(NSNumber *)oldCoordX[2] floatValue];
        NAFloat newXrMin = [(NSNumber *)newCoordX[0] floatValue];
        NAFloat newXrMax = [(NSNumber *)newCoordX[1] floatValue];
        NAFloat newXOrig = [(NSNumber *)newCoordX[2] floatValue];
        
        NAFloat cCoordXrMin = oldXrMin + progress * (newXrMin - oldXrMin);
        NAFloat cCoordXrMax = oldXrMax + progress * (newXrMax - oldXrMax);
        NAFloat cCoordXOrig = oldXOrig + progress * (newXOrig - oldXOrig);
        
        NAFloat oldYrMin = [(NSNumber *)oldCoordY[0] floatValue];
        NAFloat oldYrMax = [(NSNumber *)oldCoordY[1] floatValue];
        NAFloat oldYOrig = [(NSNumber *)oldCoordY[2] floatValue];
        NAFloat newYrMin = [(NSNumber *)newCoordY[0] floatValue];
        NAFloat newYrMax = [(NSNumber *)newCoordY[1] floatValue];
        NAFloat newYOrig = [(NSNumber *)newCoordY[2] floatValue];
        
        NAFloat cCoordYrMin = oldYrMin + progress * (newYrMin - oldYrMin);
        NAFloat cCoordYrMax = oldYrMax + progress * (newYrMax - oldYrMax);
        NAFloat cCoordYOrig = oldYOrig + progress * (newYOrig - oldYOrig);
        
        WSPlotController *cCtrl = [self plotAtIndex:i];
        [cCtrl setDataD:cData];
        [[cCtrl coordX] setCoordRangeD:NARangeMake(cCoordXrMin, cCoordXrMax)];
        [[cCtrl coordX] setCoordOrigin:cCoordXOrig];
        [[cCtrl coordY] setCoordRangeD:NARangeMake(cCoordYrMin, cCoordYrMax)];
        [[cCtrl coordY] setCoordOrigin:cCoordYOrig];
    }
    
    // Call the custom update handler (if present).
    if (updateHandlerCopy != nil) {
        id context = [userInfo valueForKey:WSUI_CONTEXT_KEY];
        updateHandlerCopy(progress, context);
    }
    
    if (final) {
        [self setAnimationTimer:nil];
        [aTimer invalidate];

        // Call the completion handler and release memory.
        void (^completionHandlerCopy)(BOOL);
        completionHandlerCopy = userInfo[WSUI_COMPLETION];
        if (completionHandlerCopy != nil) {
            completionHandlerCopy(YES);
        }
    }
    
    // We are done. Flag display update and exit.
    [self setNeedsDisplay];
}

+ (NAFloat)progressionAtIteration:(NAFloat)iteration
                         duration:(NSTimeInterval)duration
                          options:(WSChartAnimationOptions)options {
    NAFloat progress = iteration/(duration * kWSChartAnimationFPS);
    
    switch (options) {
        case kWSChartAnimationOptionCurveNone:
            return 1.;
            break;
            
        case kWSChartAnimationOptionCurveEaseInOut:
            return [WSChart WS_easeInOutHelper:progress];
            break;
            
        case kWSChartAnimationOptionCurveEaseIn:
            return 2.*[WSChart WS_easeInOutHelper:(0.5*progress)];
            break;
            
        case kWSChartAnimationOptionCurveEaseOut:
            return 2.*([WSChart WS_easeInOutHelper:(0.5*progress+0.5)]-0.5);
            break;
            
        case kWSChartAnimationOptionCurveLinear:
            return progress;
            break;
            
        default:
            break;
    }
}

+ (NAFloat)WS_easeInOutHelper:(NAFloat)x {
    // Return the standard @p smoothstep polynomial function.
    return x*x*(3.0f - 2.0f*x);
}

@end
