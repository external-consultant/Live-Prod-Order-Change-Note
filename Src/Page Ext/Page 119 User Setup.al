pageextension 81187 "User Setup Ext" extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {
            //T12149-NS            
            field("Allow Prod Ord. Change Post"; Rec."Allow Prod Ord. Change Post")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Allow Prod Ord. Change Post field.', Comment = '%';
            }
            field("Allow Prod Ord. Change Approve"; Rec."Allow Prod Ord. Change Approve")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Allow Prod Ord. Change Approve field.', Comment = '%';
            }
            field("Allow to Mod Prod Order Comp"; Rec."Allow to Mod Prod Order Comp")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Allow to Modify Production Order Component field.', Comment = '%';
            }
            //T12149-NE
        }
    }
}
