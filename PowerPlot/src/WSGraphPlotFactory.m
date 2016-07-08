//
//  WSGraphPlotFactory.m
//  PowerPlot
//
//  Created by Wolfram Schroers on 20.10.10.
//  Copyright 2010-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import "WSGraphPlotFactory.h"
#import "WSColorScheme.h"
#import "WSConnection.h"
#import "WSData.h"
#import "WSDatum.h"
#import "WSGraph.h"
#import "WSGraphConnections.h"
#import "WSNodeProperties.h"
#import "WSPlot.h"
#import "WSPlotController.h"
#import "WSPlotGraph.h"

@implementation WSChart (WSGraphPlotFactory)

+ (instancetype)graphPlotWithFrame:(CGRect)frame
                             graph:(WSGraph *)data
                       colorScheme:(WSColorScheme *)colorScheme
{
    WSChart *chart = [[[self class] alloc] initWithFrame:frame];
    [chart configureWithGraph:data
                  colorScheme:colorScheme];
    return chart;
}

+ (instancetype)graphPlotWithFrame:(CGRect)frame
                             graph:(WSGraph *)data
                            colors:(LPColorScheme)colors
{
    WSChart *chart = [[[self class] alloc] initWithFrame:frame];
    WSColorScheme *colorScheme = [[WSColorScheme alloc] initWithScheme:colors];
    [chart configureWithGraph:data
                  colorScheme:colorScheme];
    return chart;
}

- (void)configureWithGraph:(WSGraph *)data
               colorScheme:(WSColorScheme *)cs
{
    // Remove all previous data.
    [self removeAllPlots];

    // Create the controller and the plot.
    WSPlotController *graphController = [[WSPlotController alloc] init];
    WSPlotGraph *graph = [[WSPlotGraph alloc] initWithFrame:[self bounds]];
    [graphController setView:graph];
    [graphController setDataD:data];
    [self addPlot:graphController];

    // Configure the plot.
    
    // Set colors for the graph.
    [graph setStyle:kCustomStyleUnified];
    [data colorAllConnections:[cs foreground]];
    [[graph propDefault] setOutlineColor:[cs spotlight]];
    [[graph propDefault] setNodeColor:[cs highlight]];
    [[graph propDefault] setShadowColor:[cs shadow]];
    [[graph propDefault] setLabelColor:[cs foreground]];
    
    // Configure the controller for alerting (optional).
    WSNodeProperties *defaults = [graph propDefault];
    [graphController setStandardProperties:defaults];
    [graphController setAlertedProperties:defaults];
    [((WSNodeProperties *)[graphController alertedProperties]) 
     setNodeColor:[cs alert]];
    [((WSNodeProperties *)[graphController alertedProperties])
     setOutlineColor:[cs alertSecondary]];

    // Set own background color.
    [self setBackgroundColor:[cs background]];

    // Automatic axis scaling.
    [self autoscaleAllAxisX];
    [self autoscaleAllAxisY];
}

@end
