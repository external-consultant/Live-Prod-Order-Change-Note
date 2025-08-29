Page 81188 "Prod. Order Comp version diff"
{
    Caption = 'Prod. Order change note version difference';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Prod. Order Change Note Line";
    SourceTableView = sorting("Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Component Line No.")
                      where(Posted = filter(true),
                            Action = filter(Modify | Add));
    Description = 'T12149';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Prod. Order Status"; Rec."Prod. Order Status")
                {
                    ApplicationArea = All;
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    ApplicationArea = All;
                }
                field("Prod. Order Line No."; Rec."Prod. Order Line No.")
                {
                    ApplicationArea = All;
                }
                field("Prod. Order Component Line No."; Rec."Prod. Order Component Line No.")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                }
                field("Quantity Per"; Rec."Quantity Per")
                {
                    ApplicationArea = All;
                }
                field("New Quantity Per"; Rec."New Quantity Per")
                {
                    ApplicationArea = All;
                }
                field("Expected Quantity"; Rec."Expected Quantity")
                {
                    ApplicationArea = All;
                }
                field("New Expected Quantity"; Rec."New Expected Quantity")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Action"; Rec.Action)
                {
                    ApplicationArea = All;
                }
                field("ProdOrderChangeNoteHdr_gRec.""Change category"""; ProdOrderChangeNoteHdr_gRec."Change category")
                {
                    ApplicationArea = All;
                    Caption = 'Change Category';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Clear(ProdOrderChangeNoteHdr_gRec);
        ProdOrderChangeNoteHdr_gRec.Get(Rec."Document No.");
    end;

    trigger OnOpenPage()
    var
        ManufacturingSetup_lRec: Record "Manufacturing Setup";
    begin
        ManufacturingSetup_lRec.Get;
        ManufacturingSetup_lRec.TestField("Enable Production Change Note");
    end;

    var
        ProdOrderChangeNoteHdr_gRec: Record "Prod. Order Change Note Header";
}

