Page 81184 "Posted Prod. Order Change Card"
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

    Caption = 'Posted Prod. Order Change Note Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Prod. Order Change Note Header";
    Description = 'T12149';
    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = Editable_gBln;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssitEdit_gFnc(xRec) then
                            CurrPage.Update;
                    end;
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
                field("Base Prod. BOM Change Note"; Rec."Base Prod. BOM Change Note")
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
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = All;
                }
                field(Submitted; Rec.Submitted)
                {
                    ApplicationArea = All;
                }
                field("Submitted By"; Rec."Submitted By")
                {
                    ApplicationArea = All;
                }
                field("Submitted On"; Rec."Submitted On")
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
                field(Description; Rec.Description)
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
                field(Approve; Rec.Approve)
                {
                    ApplicationArea = All;
                }
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = All;
                }
                field("Approved On"; Rec."Approved On")
                {
                    ApplicationArea = All;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = All;
                }
                field("Posted By"; Rec."Posted By")
                {
                    ApplicationArea = All;
                }
                field("Posted On"; Rec."Posted On")
                {
                    ApplicationArea = All;
                }
                field("Change Status"; Rec."Change Status")
                {
                    ApplicationArea = All;
                }
                field("Change category"; Rec."Change category")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Updated Production Quantity"; Rec."Updated Production Quantity")
                {
                    ApplicationArea = All;
                }
            }
            part("Prod. Order Change Note Lines"; "Posted Prod Order Change Line")
            {
                Editable = false;
                SubPageLink = "Document No." = field("No.");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Show Approval Entry")
            {
                ApplicationArea = All;
                Image = Approvals;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "Doc. Prod. Order Change App.";
                RunPageLink = "Approval Source" = filter("Production Change Note"),
                              "Prod. Order Status" = field("Prod. Order Status"),
                              "Prod. Order No." = field("Prod. Order No."),
                              "Prod. Order Line No." = field("Prod. Order Line No."),
                              "Prod. Order Change Note No." = field("No.");
                RunPageView = sorting("Approval Source", "Entry No.")
                              where("Approval Source" = filter("Production Change Note"));
            }
            action("Prod. Order Component Archive")
            {
                ApplicationArea = All;
                Caption = 'Prod. Order Component Archive';
                Image = Archive;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Prod. Order Components Archive";
                RunPageLink = "Change Note Document No." = field("No.");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec.Posted then
            Editable_gBln := false
        else
            Editable_gBln := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        ProdOrder_lRec: Record "Production Order";
    begin
        if Rec.GetFilter("Prod. Order No.") <> '' then begin
            Rec."Prod. Order No." := Rec.GetFilter("Prod. Order No.");
            ProdOrder_lRec.SetRange("No.", Rec."Prod. Order No.");
            if ProdOrder_lRec.FindFirst then
#pragma warning disable
                Rec."Prod. Order Status" := ProdOrder_lRec.Status;
#pragma warning disable

            Evaluate(Rec."Prod. Order Line No.", Rec.GetFilter("Prod. Order Line No."));
        end;
    end;

    var
        Editable_gBln: Boolean;
}

