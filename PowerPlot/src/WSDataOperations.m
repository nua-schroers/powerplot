//
//  WSDataOperations.m
//  PowerPlot
//
//  Created by Wolfram Schroers on 06.08.11.
//  Copyright 2011-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import "WSDataOperations.h"
#import "WSData+Private.h"
#import "WSDatum.h"

@implementation WSData (WSDataOperations)

+ (WSData *)data:(id)data
             map:(mapBlock_t)mapBlock {
    // Verify the type of the argument.
    NSParameterAssert([data isKindOfClass:[WSData class]] ||
                      [data isKindOfClass:[NSArray class]]);

    WSData *result = [WSData data];
    if ([data isKindOfClass:[WSData class]]) {
        // Perform simple one-argument map.
        for (WSDatum *datum in data) {
            [result addDatum:mapBlock(datum)];
        }
    } else if ([data isKindOfClass:[NSArray class]]) {
        // Perform multi-argument map.
        NSUInteger len = [(NSArray *)data[0] count];
        NSUInteger numargs = [(NSArray *)data count];
#if DEBUG == 1
        for (WSData *oneSet in data) {
            NSParameterAssert(len == [oneSet count]);
        }
#endif

        NSMutableArray *par = [NSMutableArray arrayWithCapacity:len];
        [par insertObjects:[WSData arrayOfZerosWithLen:len]
                 atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, len)]];
        for (NSUInteger i=0; i<len; i++) {
            for (NSUInteger j=0; j<numargs; j++) {
                par[j] = [(WSData *)data[j]
                                           datumAtIndex:i];
            }
            [result addDatum:mapBlock(par)];
        }
    }

    return result;
}

- (void)map:(mapBlock_t)mapBlock {
    WSDatum *tmp = nil;

    for (NSUInteger i=0; i<[self count]; i++) {
        tmp = mapBlock([self datumAtIndex:i]);
        [self replaceDatumAtIndex:i
                        withDatum:tmp];
    }
}

- (WSDatum *)reduce:(reduceDatum_t)reduceBlock
              start:(WSDatum *)initial
{
    __block WSDatum *result = [initial copy];

    for (WSDatum *datum in self) {
        result = reduceBlock(result, datum);
    }

    return result;
}

- (WSDatum *)reduceAverage {
    WSDatum *result = [self reduceSum];
    NAFloat len = (NAFloat)[self count];

    [result setValue:([result value] / len)];
    [result setValueX:([result valueX] / len)];

    return result;
}

- (WSDatum *)reduceSum {
    WSDatum *result = [WSDatum datum];
    double sumX = 0.0,
           sumY = 0.0;

    for (WSDatum *datum in self) {
        sumX += (double)[datum valueX];
        sumY += (double)[datum value];
    }
    [result setValueX:(NAFloat)sumX];
    [result setValueY:(NAFloat)sumY];

    return result;
}

- (WSData *)sortedDataUsingComparator:(sortBlock_t)comparator {
    WSData *result = [self copy];
    [result.ws_values sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return comparator((WSDatum *)obj1, (WSDatum *)obj2);
    }];

    return result;
}

- (WSData *)filteredDataUsingFilter:(filterBlock_t)filter {
    WSData *result = [WSData data];

    for (WSDatum *datum in self) {
        if (filter(datum)) {
            [result addDatum:datum];
        }
    }
    
    return result;
}

- (NAFloat *)floatsFromDataX {
    NAFloat *result = NULL;
    
    result = (NAFloat *)malloc([self count] * sizeof(NAFloat));
    for (NSUInteger i=0; i<[self count]; i++) {
        result[i] = [[self datumAtIndex:i] valueX];
    }
    
    return result;
}

- (NAFloat *)floatsFromDataY {
    NAFloat *result = NULL;
    
    result = (NAFloat *)malloc([self count] * sizeof(NAFloat));
    for (NSUInteger i=0; i<[self count]; i++) {
        result[i] = [[self datumAtIndex:i] value];
    }
    
    return result;
}

- (NSInteger)datumClosestToLocation:(CGPoint)location
{
    NSInteger result = -1;
    NAFloat bestDistance = INFINITY;
    NAFloat thisDistance;
    
    for (NSUInteger i=0; i<[self count]; i++) {
        thisDistance = sqrtf(powf(location.x-[[self datumAtIndex:i] valueX], 2) +
                             powf(location.y-[[self datumAtIndex:i] valueY], 2));
        if (thisDistance < bestDistance) {
            result = i;
            bestDistance = thisDistance;
        }
    }
    
    return result;
}

- (NSInteger)datumClosestToLocation:(CGPoint)location
                    maximumDistance:(NAFloat)distance {
    NSInteger result = -1;
    NAFloat bestDistance = INFINITY;
    NAFloat thisDistance;
    
    for (NSUInteger i=0; i<[self count]; i++) {
        thisDistance = sqrtf(powf(location.x-[[self datumAtIndex:i] valueX], 2) +
                             powf(location.y-[[self datumAtIndex:i] valueY], 2));
        if ((thisDistance < bestDistance) && (thisDistance < distance)) {
            result = i;
            bestDistance = thisDistance;
        }
    }
    
    return result;
}

- (NSInteger)datumClosestToValueX:(NAFloat)valueX
{
    NSInteger result = -1;
    NAFloat bestDistance = INFINITY;
    NAFloat thisDistance;
    
    for (NSUInteger i=0; i<[self count]; i++) {
        thisDistance = fabs(valueX - [[self datumAtIndex:i] valueX]);
        if (thisDistance < bestDistance) {
            result = i;
            bestDistance = thisDistance;
        }
    }
    
    return result;    
}

- (NSInteger)datumClosestToValueX:(NAFloat)valueX
                  maximumDistance:(NAFloat)distance {
    NSInteger result = -1;
    NAFloat bestDistance = INFINITY;
    NAFloat thisDistance;
    
    for (NSUInteger i=0; i<[self count]; i++) {
        thisDistance = fabs(valueX - [[self datumAtIndex:i] valueX]);
        if ((thisDistance < bestDistance) && (thisDistance < distance)) {
            result = i;
            bestDistance = thisDistance;
        }
    }
    
    return result;    
}

- (NSInteger)datumClosestToValueY:(NAFloat)valueY {
    NSInteger result = -1;
    NAFloat bestDistance = INFINITY;
    NAFloat thisDistance;
    
    for (NSUInteger i=0; i<[self count]; i++) {
        thisDistance = fabs(valueY - [[self datumAtIndex:i] valueY]);
        if (thisDistance < bestDistance) {
            result = i;
            bestDistance = thisDistance;
        }
    }
    
    return result;
}

- (NSInteger)datumClosestToValueY:(NAFloat)valueY
                  maximumDistance:(NAFloat)distance {
    NSInteger result = -1;
    NAFloat bestDistance = INFINITY;
    NAFloat thisDistance;
    
    for (NSUInteger i=0; i<[self count]; i++) {
        thisDistance = fabs(valueY - [[self datumAtIndex:i] valueY]);
        if ((thisDistance < bestDistance) && (thisDistance < distance)) {
            result = i;
            bestDistance = thisDistance;
        }
    }
    
    return result;    
}

@end
