//
//  WSData_Private.h
//  PowerPlot
//
//  Created by Wolfram Schroers on 11.10.13.
//  Copyright 2013 Numerik & Analyse Schroers. All rights reserved.
//

#import "WSData.h"

/// Private implementation.
@interface WSData ()

@property NSMutableArray *ws_values; ///< Mutable container.
@property BOOL sorted;               ///< Read-writeable flag.

/** Add a single instance of WSDatum to KVO. */
- (void)WS_observeDatum:(WSDatum *)datum;

/** Remove a single instance of WSDatum from KVO. */
- (void)WS_removeObserveDatum:(WSDatum *)datum;

/** Register all instances of WSDatum in the values array to KVO. */
- (void)WS_observeAllValues;

/** Deregister all instances of WSDatum in the values array from
    KVO.
 */
- (void)WS_removeObserveAllValues;

@end

