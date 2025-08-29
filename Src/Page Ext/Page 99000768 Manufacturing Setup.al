PageExtension 81183 Manufacturing_Setup_50250 extends "Manufacturing Setup"
{
    layout
    {



        addafter(Planning)
        {
            //T12149-NS
            group("Prod. Order Change Note")
            {
                Caption = 'Prod. Order Change Note';
                field("Enable Production Change Note"; Rec."Enable Production Change Note")
                {
                    ApplicationArea = All;
                }
                field("Allow PO Qty Change in PCN"; Rec."Allow PO Qty Change in PCN")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow PO Qty Change in PCN field.', Comment = '%';
                }
                field("Prod. Order Change No. Series"; Rec."Prod. Order Change No. Series")
                {
                    ApplicationArea = All;
                }
                field("Item Templete - Con. Neg. Adj."; Rec."Item Templete - Con. Neg. Adj.")
                {
                    ApplicationArea = All;
                }
                field("Item Batch - Con. Neg. Adj."; Rec."Item Batch - Con. Neg. Adj.")
                {
                    ApplicationArea = All;
                }
                field("Check Qty. per Sum equals 1"; Rec."Check Qty. per Sum equals 1")
                {
                    ApplicationArea = All;
                }
                field("Match Tot Qty. with Princple"; Rec."Match Tot Qty. with Princple")
                {
                    ApplicationArea = All;
                }
            }
            //T12149-NE
        }
    }
}

