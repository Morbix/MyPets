//
//  PNLineChart.m
//  PNChartDemo
//
//  Created by kevin on 11/7/13.
//  Copyright (c) 2013年 kevinzhow. All rights reserved.
//

#import "PNLineChart.h"
#import "PNColor.h"
#import "PNChartLabel.h"
#import "PNLineChartData.h"
#import "PNLineChartDataItem.h"


//------------------------------------------------------------------------------------------------
// private interface declaration
//------------------------------------------------------------------------------------------------
@interface PNLineChart ()

@property (nonatomic,strong) NSMutableArray *chartLineArray; // Array[CAShapeLayer]

@property (strong, nonatomic) NSMutableArray *chartPath; //Array of line path, one for each line.

- (void)setDefaultValues;

@end


//------------------------------------------------------------------------------------------------
// public interface implementation
//------------------------------------------------------------------------------------------------
@implementation PNLineChart

#pragma mark initialization

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setDefaultValues];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultValues];
    }
    return self;
}

#pragma mark instance methods

-(void)setYLabels:(NSArray *)yLabels
{

    float level = _yValueMax / 6.0;
	
    NSInteger index = 0;
	NSInteger num = [yLabels count] + 1;
	while (num > 0) {
		CGFloat levelHeight = _chartCavanHeight /6.0;
		PNChartLabel * label = [[PNChartLabel alloc] initWithFrame:CGRectMake(0.0,_chartCavanHeight - index * levelHeight + (levelHeight - yLabelHeight) , 30.0, yLabelHeight)];
		[label setTextAlignment:NSTextAlignmentRight];
		label.text = [NSString stringWithFormat:@"%.2f",level * index];
        [label setFont:[UIFont systemFontOfSize:8]];
		[self addSubview:label];
        
        PNChartLabel * label2 = [[PNChartLabel alloc] initWithFrame:CGRectMake(34.0,_chartCavanHeight - index * levelHeight + (levelHeight - yLabelHeight - 2) , self.frame.size.width-46.0, yLabelHeight)];
		[label2 setTextAlignment:NSTextAlignmentCenter];
        [label2 setLineBreakMode:NSLineBreakByCharWrapping];
		//label2.text = [NSString stringWithFormat:@"------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"];
        label2.text = [NSString stringWithFormat:@"____________________________________________________________________________________________________________________________________________________________________________________________________________________________"];
        [label2 setFont:[UIFont systemFontOfSize:8]];
		[self addSubview:label2];
        [self sendSubviewToBack:label2];
        
        index +=1 ;
		num -= 1;
	}
    
    
    
    PNChartLabel * label1 = [[PNChartLabel alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 40.0 , 30.0, 20.0)];
    [label1 setTextAlignment:NSTextAlignmentRight];
    label1.text = NSLS(@"Dia");
    [label1 setFont:[UIFont systemFontOfSize:8]];
    [self addSubview:label1];
    
    PNChartLabel * label2 = [[PNChartLabel alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 28.0 , 30.0, 20.0)];
    [label2 setTextAlignment:NSTextAlignmentRight];
    label2.text = NSLS(@"Mês");
    [label2 setFont:[UIFont systemFontOfSize:8]];
    [self addSubview:label2];
    
    PNChartLabel * label3 = [[PNChartLabel alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 16.0 , 30.0, 20.0)];
    [label3 setTextAlignment:NSTextAlignmentRight];
    label3.text = NSLS(@"Ano");
    [label3 setFont:[UIFont systemFontOfSize:8]];
    [self addSubview:label3];

}

-(void)setXLabels1:(NSArray *)xLabels1 andXLabels2:(NSArray *)xLabels2 andXLabels3:(NSArray *)xLabels3
{
    _xLabels1 = xLabels1;
    _xLabels2 = xLabels2;
    _xLabels3 = xLabels3;
    
    if(_showLabel){
        _xLabelWidth = (self.frame.size.width - chartMargin - 30.0)/[xLabels1 count];
        
        for(int index = 0; index < xLabels1.count; index++)
        {
            NSString* labelText = xLabels1[index];
            PNChartLabel * label = [[PNChartLabel alloc] initWithFrame:CGRectMake(index * _xLabelWidth + 30.0, self.frame.size.height - 40.0, _xLabelWidth, 20.0)];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setFont:[UIFont systemFontOfSize:8]];
            label.text = labelText;
            [self addSubview:label];
            
            NSString* labelText2 = xLabels2[index];
            PNChartLabel * label2 = [[PNChartLabel alloc] initWithFrame:CGRectMake(index * _xLabelWidth + 30.0, self.frame.size.height - 28.0, _xLabelWidth, 20.0)];
            [label2 setTextAlignment:NSTextAlignmentCenter];
            [label2 setFont:[UIFont systemFontOfSize:8]];
            label2.text = labelText2;
            [self addSubview:label2];
            
            NSString* labelText3 = xLabels3[index];
            PNChartLabel * label3 = [[PNChartLabel alloc] initWithFrame:CGRectMake(index * _xLabelWidth + 30.0, self.frame.size.height - 16.0, _xLabelWidth, 20.0)];
            [label3 setTextAlignment:NSTextAlignmentCenter];
            [label3 setFont:[UIFont systemFontOfSize:8]];
            label3.text = labelText3;
            [self addSubview:label3];
        }
        
    }else{
        _xLabelWidth = (self.frame.size.width)/[xLabels1 count];
    }
    
}

-(void)setXLabels:(NSArray *)xLabels
{
    _xLabels1 = xLabels;
    
    if(_showLabel){
        _xLabelWidth = (self.frame.size.width - chartMargin - 30.0)/[xLabels count];
        
        for(int index = 0; index < xLabels.count; index++)
        {
            NSString* labelText = xLabels[index];
            PNChartLabel * label = [[PNChartLabel alloc] initWithFrame:CGRectMake(index * _xLabelWidth + 30.0, self.frame.size.height - 30.0, _xLabelWidth, 20.0)];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setBackgroundColor:[UIColor clearColor]];
            label.text = labelText;
            [self addSubview:label];
        }
        
    }else{
        _xLabelWidth = (self.frame.size.width)/[xLabels count];
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchPoint:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchPoint:touches withEvent:event];
}

-(void)touchPoint:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Get the point user touched
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    for (UIBezierPath *path in _chartPath) {
        CGPathRef originalPath = path.CGPath;
        CGPathRef strokedPath = CGPathCreateCopyByStrokingPath(originalPath, NULL, 3.0, kCGLineCapRound, kCGLineJoinRound, 3.0);
        BOOL pathContainsPoint = CGPathContainsPoint(strokedPath, NULL, touchPoint, NO);
        if (pathContainsPoint)
        {
            [_delegate userClickedOnLinePoint:touchPoint lineIndex:[_chartPath indexOfObject:path]];
            for (NSArray *linePointsArray in _pathPoints) {
                for (NSValue *val in linePointsArray) {
                    CGPoint p = [val CGPointValue];
                    if (p.x + 3.0 > touchPoint.x && p.x - 3.0 < touchPoint.x && p.y + 3.0 > touchPoint.y && p.y - 3.0 < touchPoint.y ) {
                        //Call the delegate and pass the point and index of the point
                        [_delegate userClickedOnLineKeyPoint:touchPoint lineIndex:[_pathPoints indexOfObject:linePointsArray] andPointIndex:[linePointsArray indexOfObject:val]];
                    }
                }
            }
            
        }
    }
    
}

-(void)strokeChart
{
    _chartPath = [[NSMutableArray alloc] init];
    //Draw each line
    for (NSUInteger lineIndex = 0; lineIndex < self.chartData.count; lineIndex++) {
        PNLineChartData *chartData = self.chartData[lineIndex];
        CAShapeLayer *chartLine = (CAShapeLayer *) self.chartLineArray[lineIndex];

        UIGraphicsBeginImageContext(self.frame.size);
        UIBezierPath * progressline = [UIBezierPath bezierPath];
        [_chartPath addObject:progressline];
        
        PNLineChartDataItem *firstDataItem = chartData.getData(0);
        CGFloat firstValue = firstDataItem.y;

        CGFloat xPosition = 36;//MAX(_xLabelWidth, 36);

        if(!_showLabel){
            _chartCavanHeight = self.frame.size.height  - _xLabelHeight*2;
            xPosition = 0;
        }

        CGFloat grade = (float)firstValue / _yValueMax;
        NSMutableArray * linePointsArray = [[NSMutableArray alloc] init];
        [progressline moveToPoint:CGPointMake( xPosition, _chartCavanHeight - grade * _chartCavanHeight + _xLabelHeight-2)];
        [linePointsArray addObject:[NSValue valueWithCGPoint:CGPointMake( xPosition, _chartCavanHeight - grade * _chartCavanHeight + _xLabelHeight-2)]];
        [progressline setLineWidth:1.0];
        [progressline setLineCapStyle:kCGLineCapRound];
        [progressline setLineJoinStyle:kCGLineJoinRound];

        
        NSInteger index = 0;
        for (NSUInteger i = 0; i < chartData.itemCount; i++) {

            PNLineChartDataItem *dataItem = chartData.getData(i);
            float value = dataItem.y;

            CGFloat innerGrade = value / _yValueMax;
            if (index != 0) {
                CGPoint point = CGPointMake(index * _xLabelWidth + 30.0 + _xLabelWidth / 2.0, _chartCavanHeight - (innerGrade * _chartCavanHeight) + _xLabelHeight-2);
                [linePointsArray addObject:[NSValue valueWithCGPoint:point]];
                [progressline addLineToPoint:point];
                [progressline moveToPoint:point];
            }
            index += 1;
        }
        [_pathPoints addObject:[linePointsArray copy]];
        
        chartLine.strokeColor = [PNGreen CGColor];
        [chartLine setLineWidth:2.0];

        [progressline stroke];

        chartLine.path = progressline.CGPath;

        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = 1.0;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        [chartLine addAnimation:pathAnimation forKey:@"strokeEndAnimation"];

        chartLine.strokeEnd = 1.0;

        UIGraphicsEndImageContext();
    }
}

- (void)setChartData:(NSArray *)data {
    if (data != _chartData) {

        NSMutableArray *yLabelsArray = [NSMutableArray arrayWithCapacity:data.count];
        CGFloat yMax = 0.0f;

        // remove all shape layers before adding new ones
        for (CALayer *layer in self.chartLineArray) {
            [layer removeFromSuperlayer];
        }
        self.chartLineArray = [NSMutableArray arrayWithCapacity:data.count];

        for (PNLineChartData *chartData in data) {

            // create as many chart line layers as there are data-lines
            CAShapeLayer *chartLine = [CAShapeLayer layer];
            chartLine.lineCap   = kCALineCapRound;
            chartLine.lineJoin  = kCALineJoinBevel;
            chartLine.fillColor = [[UIColor whiteColor] CGColor];
            chartLine.lineWidth = 3.0;
            chartLine.strokeEnd = 0.0;
            [self.layer addSublayer:chartLine];
            [self.chartLineArray addObject:chartLine];

            for (NSUInteger i = 0; i < chartData.itemCount; i++) {
                PNLineChartDataItem *dataItem = chartData.getData(i);
                CGFloat yValue = dataItem.y;
                [yLabelsArray addObject:[NSString stringWithFormat:@"%2f", yValue]];
                yMax = fmaxf(yMax, dataItem.y);
            }
        }

        // Min value for Y label
        if (yMax < 5) {
            yMax = 5.0f;
        }
        _yValueMax = yMax;

        _chartData = data;

        if (_showLabel) {
            [self setYLabels:yLabelsArray];
        }

        [self setNeedsDisplay];
    }
}

#pragma mark private methods

- (void)setDefaultValues {
    // Initialization code
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds   = YES;
    self.chartLineArray  = [NSMutableArray new];
    _showLabel           = YES;
    _pathPoints = [[NSMutableArray alloc] init];
    self.userInteractionEnabled = YES;
    _xLabelHeight = 20.0;
    _chartCavanHeight = self.frame.size.height - chartMargin * 2 - _xLabelHeight*2 ;
}

@end
