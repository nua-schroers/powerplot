//
//  WSLinePlotFactory.m
//  PowerPlot
//
//  Created by Wolfram Schroers on 15.10.10.
//  Copyright 2010-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import "WSLinePlotFactory.h"
#import "WSColorScheme.h"
#import "WSData.h"
#import "WSDatum.h"
#import "WSPlot.h"
#import "WSPlotAxis.h"
#import "WSAxisProperties.h"
#import "WSPlotController.h"
#import "WSPlotData.h"
#import "WSTicks.h"
#import "WSDataPointProperties.h"

@implementation WSChart (WSLinePlotFactory)

+ (instancetype)linePlotWithFrame:(CGRect)frame
                             data:(WSData *)data
                            style:(LPStyle)style
                        axisStyle:(CSStyle)axis
                      colorScheme:(WSColorScheme *)colorScheme
                           labelX:(NSString *)labelX
                           labelY:(NSString *)labelY
{
    WSChart *chart = [[self alloc] initWithFrame:frame];
    [chart configureWithData:data
                       style:style
                   axisStyle:axis
                 colorScheme:colorScheme
                      labelX:labelX
                      labelY:labelY];
    return chart;
}

+ (instancetype)linePlotWithFrame:(CGRect)frame
                             data:(WSData *)data
                            style:(LPStyle)style
                        axisStyle:(CSStyle)axis
                           colors:(LPColorScheme)colors
                           labelX:(NSString *)labelX
                           labelY:(NSString *)labelY
{
    WSChart *chart = [[self alloc] initWithFrame:frame];
    WSColorScheme *colorScheme = [[WSColorScheme alloc] initWithScheme:colors];
    [chart configureWithData:data
                       style:style
                   axisStyle:axis
                 colorScheme:colorScheme
                      labelX:labelX
                      labelY:labelY];
    return chart;
}

- (void)configureWithData:(WSData *)data
                    style:(LPStyle)style
                axisStyle:(CSStyle)axis
              colorScheme:(WSColorScheme *)cs
                   labelX:(NSString *)labelX
                   labelY:(NSString *)labelY
{
    // Remove all previous data.
    [self removeAllPlots];

    // Create three controllers: One for the coordinate system, one
    // for a (possible) grid system and one for the plot.
    WSPlotController *myAxisController = [[WSPlotController alloc] init];
    WSPlotController *myGridController = [[WSPlotController alloc] init];
    WSPlotController *myPlotController = [[WSPlotController alloc] init];
    
    // Setup the plots for the controllers (the grid is configured,
    // but only added if needed).
    WSPlotAxis *myAxis = [[WSPlotAxis alloc] initWithFrame:[self bounds]];
    WSPlotAxis *myGrid = [[WSPlotAxis alloc] initWithFrame:[self bounds]];
    WSPlotData *myPlot = [[WSPlotData alloc] initWithFrame:[self bounds]];
    myAxisController.view = myAxis;
    myGridController.view = myGrid;
    myPlotController.view = myPlot;
    myPlotController.dataD = data;
    [myGrid setAllDisplaysOff];
    
    // Only one coordinate system is needed, sync the others from the
    // axis controller.
    myAxisController.coordX = myPlotController.coordX;
    myAxisController.coordY = myPlotController.coordY;
    myGridController.coordX = myPlotController.coordX;
    myGridController.coordY = myPlotController.coordY;
    
    // Set colors for the axis.
    [myAxis.axisX setLabelColor:[cs foreground]];
    [myAxis.axisY setLabelColor:[cs foreground]];
    [myAxis setAxisColor:[cs foreground]];
    [myGrid setGridColor:[cs receded]];
    
    // Set colors for the plot.
    [myPlot setStyle:kCustomStyleUnified];
    [[myPlot propDefault] setSymbolColor:[cs spotlight]];
    [[myPlot propDefault] setErrorBarColor:[cs foreground]];
    [myPlot setLineColor:[cs spotlight]];
    [myPlot setFillColor:[cs highlight]];
    
    // Set own background color.
    [self setBackgroundColor:[cs background]];

    // Configure the coordinate axis.
    [myAxis.ticksX setTicksStyle:kTicksNone];
    [myAxis.ticksY setTicksStyle:kTicksNone];
    [myAxis.ticksX setTicksDir:kTDirectionNone];
    [myAxis.ticksY setTicksDir:kTDirectionNone];
    [myAxis.ticksX setMinorTicksNum:2];
    [myAxis.ticksY setMinorTicksNum:2];
    [[myAxisController coordY] setInverted:YES];
    [myAxis setDrawBoxed:NO];
    [myAxis.axisX setGridStyle:kGridNone];
    [myAxis.axisY setGridStyle:kGridNone];
    [myAxis.axisX setLabelStyle:kLabelInside];
    [myAxis.axisY setLabelStyle:kLabelInside];
    [myAxis.axisX setAxisLabel:labelX];
    [myAxis.axisY setAxisLabel:labelY];    
    [myAxis.axisX setLabelFont:[UIFont systemFontOfSize:12.0]];
    [myAxis.axisY setLabelFont:[UIFont systemFontOfSize:12.0]];
    switch (axis) {
        case kCSNone:
            [myAxis.axisX setAxisStyle:kAxisNone];
            [myAxis.axisY setAxisStyle:kAxisNone];
            break;

        case kCSBoxed:
            [myAxis setDrawBoxed:YES];
            [myAxis.axisX setAxisOverhang:0.0];
            [myAxis.axisY setAxisOverhang:0.0];
            [myAxis.axisX setAxisPadding:0.0];
            [myAxis.axisY setAxisPadding:0.0];
            [myAxis.axisX setLabelStyle:kLabelInside];
            [myAxis.axisY setLabelStyle:kLabelInside];
        case kCSPlain:
            [myAxis.ticksX setTicksDir:kTDirectionIn];
            [myAxis.ticksY setTicksDir:kTDirectionIn];
            [myAxis.axisX setAxisStyle:kAxisPlain];
            [myAxis.axisY setAxisStyle:kAxisPlain];
            break;

        case kCSGrid:
            [[myGrid axisX] setGridStyle:kGridDotted];
            [[myGrid axisY] setGridStyle:kGridDotted];
            [myGrid setGridStrokeWidth:([myAxis gridStrokeWidth] / 3.0)];
            [myAxis.ticksX setTicksStyle:kTicksLabelsSlanted];
            [myAxis.ticksY setTicksStyle:kTicksLabelsSlanted];
            [myAxis.ticksX setTicksDir:kTDirectionInOut];
            [myAxis.ticksY setTicksDir:kTDirectionInOut];
            [myAxis.axisX setAxisStyle:kAxisArrowFilledHead];
            [myAxis.axisY setAxisStyle:kAxisArrowFilledHead];
            break;

        case kCSArrows:
            [myAxis.ticksX setTicksStyle:kTicksLabelsSlanted];
            [myAxis.ticksY setTicksStyle:kTicksLabels];
            [myAxis.ticksX setTicksDir:kTDirectionInOut];
            [myAxis.ticksY setTicksDir:kTDirectionInOut];
            [myAxis.axisX setAxisStyle:kAxisArrowFilledHead];
            [myAxis.axisY setAxisStyle:kAxisArrowFilledHead];
            break;

        default:
            break;
    }

    // Finally configure the plot.
    myPlot.propDefault.symbolSize = 15.0;
    myPlot.propDefault.symbolStyle = kSymbolNone;
    myPlot.propDefault.errorStyle = kErrorNone;
    myPlot.dashStyle = kDashingSolid;
    switch (style) {
        case kChartLineEmpty:
            [myPlot setLineStyle:kLineNone];
            break;

        case kChartLinePlain:
            [myPlot setLineStyle:kLineRegular];
            break;

        case kChartLineFilled:
            [myPlot setLineWidth:3.0];
            [myPlot setLineStyle:kLineFilledColor];
            break;

        case kChartLineGradient:
            [myPlot setFillGradientFromColor:[myPlot fillColor]
                                     toColor:[UIColor clearColor]];
            [myPlot setLineStyle:kLineFilledGradient];
            break;

        case kChartLineScientific:
            [[myPlot propDefault] setErrorStyle:kErrorXYCapped];
            [[myPlot propDefault] setSymbolStyle:kSymbolDisk];
            [myPlot setLineStyle:kLineRegular];
            break;

        default:
            break;
    }

    // Add the controllers to the chart.
    if (axis == kCSGrid) {
        [self addPlot:myGridController];
    }
    [self addPlot:myPlotController];
    [self addPlot:myAxisController];
    
    // Do the axis scaling & tick labelling of the finished graph.
    [self autoscaleAllAxisX];
    [self autoscaleAllAxisY];
    [self setAllAxisLocationXD:[self dataRangeXD].rMin];
    [self setAllAxisLocationYD:[self dataRangeYD].rMin];
    [myAxis autoTicksXD];
    [myAxis autoTicksYD];
    [myAxis setTickLabelsX];
    [myAxis setTickLabelsY];
    [myGrid autoTicksXD];
    [myGrid autoTicksYD];
    
    // Configure the controller for alerting (optional).
    WSDataPointProperties *defaults = [myPlot propDefault];
    [myPlotController setStandardProperties:defaults];
    [myPlotController setAlertedProperties:defaults];
    [((WSDataPointProperties *)[myPlotController alertedProperties]) 
     setSymbolColor:[cs alert]];
}

@end
