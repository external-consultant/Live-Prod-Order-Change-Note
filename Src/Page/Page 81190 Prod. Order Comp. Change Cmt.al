Page 81190 "Prod. Order Comp. Change Cmt."
{
    AutoSplitKey = true;
    Caption = 'Comment List';
    DataCaptionExpression = Rec.Caption;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Prod. Order Comp. change Cmt";
    Description = 'T12149';
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Date; Rec.Date)
                {
                    ApplicationArea = All;
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = All;
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetupNewLine;
    end;
}

