#import <Foundation/Foundation.h>


@interface PCPreferences : NSObject <NSOutlineViewDataSource> {
@private
    NSMutableArray *configurations;
    NSInteger selectedConfigurationIndex;
}

@property (retain) NSMutableArray *configurations;
@property (assign) NSInteger selectedConfigurationIndex;

- (NSString *)titleForConfigurationAtIndex:(NSUInteger)index;

@end
