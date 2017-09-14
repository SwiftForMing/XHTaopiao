//
//  EditAddressCell.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/12.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "EditAddressCell.h"

@implementation EditAddressCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setAddressModel:(RecoverAddressListInfo *)addressModel{
    
    _nameLabel.text = addressModel.user_name;
    _telLabel.text = addressModel.user_tel;
    _addressLabel.text = [NSString stringWithFormat:@"%@%@",addressModel.address,addressModel.detail_address];
}

@end
