Page 81183 "Posted Prod. Order Change List"
{
    // -----------------------------------------------------------------------------------------------------------------------------
    // Intech Systems Pvt. Ltd.
    // -----------------------------------------------------------------------------------------------------------------------------
    // ID                          Date            Author
    // -----------------------------------------------------------------------------------------------------------------------------
    // I-A012_B-1000321-01         30/05/15        Chintan Panchal
    //                             Production Component Change Note Development
    //                             Created New Page
    // -----------------------------------------------------------------------------------------------------------------------------

    ApplicationArea = All;
    CardPageID = "Posted Prod. Order Change Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Prod. Order Change Note Header";
    SourceTableView = sorting("No.")
                      order(ascending)
                      where("Change Status" = filter(Posted));
    UsageCategory = History;
    Description ='T12149';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Prod. Order Status"; Rec."Prod. Order Status")
                {
                    ApplicationArea = All;
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    ApplicationArea = All;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;
                }
                field("Source Item Description"; Rec."Source Item Description")
                {
                    ApplicationArea = All;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = All;
                }
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = All;
                }
                field("Posted On"; Rec."Posted On")
                {
                    ApplicationArea = All;
                }
                field("Submitted By"; Rec."Submitted By")
                {
                    ApplicationArea = All;
                }
                field("Posted By"; Rec."Posted By")
                {
                    ApplicationArea = All;
                }
                field("Ref. Prod. Order Change Note"; Rec."Ref. Prod. Order Change Note")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                }
                field("Prod. Order Line No."; Rec."Prod. Order Line No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Finished Quantity"; Rec."Finished Quantity")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

