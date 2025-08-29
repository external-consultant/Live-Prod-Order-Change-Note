pageextension 81190 "RW Released Prod Order Ext" extends "RW-Released Production Order"
{
    layout
    {
        addlast(General)
        {
            field("No. of Batches"; Rec."No. of Batches")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the No. of Batches field.', Comment = '%';
            }
        }
    }
}
