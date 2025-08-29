Page 81180 "Prod. Order Change Note List"
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
    CardPageID = "Prod. Order Change Note Card";
    Editable = false;
    PageType = List;
    SourceTable = "Prod. Order Change Note Header";
    SourceTableView = sorting("No.")
                      order(ascending)
                      where("Change Status" = filter(<> Posted));
    UsageCategory = Lists;
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
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field(Approve; Rec.Approve)
                {
                    ApplicationArea = All;
                }
                field("Change Status"; Rec."Change Status")
                {
                    ApplicationArea = All;
                }
                field("Submitted By"; Rec."Submitted By")
                {
                    ApplicationArea = All;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        ManufacturingSetup_lRec: Record "Manufacturing Setup";
    begin
        ManufacturingSetup_lRec.Get;
        ManufacturingSetup_lRec.TestField("Enable Production Change Note", true);
    end;
}

