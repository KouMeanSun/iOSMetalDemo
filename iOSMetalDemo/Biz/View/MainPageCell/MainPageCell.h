//
//  MainPageCell.h
//  VideoEditorDemo
//
//  Created by 高明阳 on 2021/3/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^MainPageCellCallBack)(NSIndexPath *indexPath);

@interface MainPageCell : UITableViewCell

@property (nonatomic,strong,readonly,class)NSString *ID;

@property (nonatomic,copy)MainPageCellCallBack block;

-(void)setCellData:(NSString *)title indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
