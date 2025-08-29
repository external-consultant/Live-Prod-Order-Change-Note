Page 81185 "Posted Prod Order Change Line"
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

    AutoSplitKey = true;
    Caption = 'Posted Prod. Order Change Note Line';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Prod. Order Change Note Line";
Description ='T12149';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Prod. Order Component Line No."; Rec."Prod. Order Component Line No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExp_gTxt;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExp_gTxt;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExp_gTxt;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExp_gTxt;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExp_gTxt;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExp_gTxt;
                }
                field("Quantity Per"; Rec."Quantity Per")
                {
                    ApplicationArea = All;
                    Editable = FieldEditableAddAction_gBln;
                    StyleExpr = StyleExp_gTxt;
                }
                field("New Quantity Per"; Rec."New Quantity Per")
                {
                    ApplicationArea = All;
                    Editable = FieldEditableModifyAction_gBln;
                    StyleExpr = StyleExp_gTxt;
                }
                field("Expected Quantity"; Rec."Expected Quantity")
                {
                    ApplicationArea = All;
                    Editable = FieldEditableAddAction_gBln;
                    StyleExpr = StyleExp_gTxt;
                }
                field("New Expected Quantity"; Rec."New Expected Quantity")
                {
                    ApplicationArea = All;
                    Editable = FieldEditableModifyAction_gBln;
                    StyleExpr = StyleExp_gTxt;
                }
                field("Act. Consumption (Qty)"; Rec."Act. Consumption (Qty)")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExp_gTxt;
                }
                field("Reserved Qty. (Base)"; Rec."Reserved Qty. (Base)")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExp_gTxt;
                }
                field("Force Close By"; Rec."Force Close By")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExp_gTxt;
                }
                field(Recovery; Rec.Recovery)
                {
                    ApplicationArea = All;
                }
                field("Recovery Quantity"; Rec."Recovery Quantity")
                {
                    ApplicationArea = All;
                }
                field("FG Recovery"; Rec."FG Recovery")
                {
                    ApplicationArea = All;
                }
                field("FG Recovery Quantity"; Rec."FG Recovery Quantity")
                {
                    ApplicationArea = All;
                }
                field("Final Qty. Per"; Rec."Final Qty. Per")
                {
                    ApplicationArea = All;
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = All;
                    Editable = FieldEditableAddAction_gBln;
                    StyleExpr = StyleExp_gTxt;
                }
                field("Action"; Rec.Action)
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExp_gTxt;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Co&mments")
            {
                ApplicationArea = All;
                Caption = 'Co&mments';
                Image = ViewComments;
                RunObject = Page "Prod. Order Comp. Change Cmt.";
                RunPageLink = Status = field("Prod. Order Status"),
                              "Prod. Order No." = field("Prod. Order No."),
                              "Prod. Order Line No." = field("Prod. Order Line No."),
                              "Prod. Order Component Line No." = field("Prod. Order Component Line No."),
                              "Prod. Order Change Note No." = field("Document No.");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec.Action = Rec.Action::Modify then begin
            FieldEditableModifyAction_gBln := true;
            StyleExp_gTxt := 'Attention';
        end else
            if Rec.Action = Rec.Action::Add then begin
                FieldEditableAddAction_gBln := true;
                FieldEditableModifyAction_gBln := false;
                StyleExp_gTxt := 'Favorable';
            end else begin
                FieldEditableAddAction_gBln := false;
                FieldEditableModifyAction_gBln := false;
                if Rec.Action = Rec.Action::Delete then
                    StyleExp_gTxt := 'Unfavorable';
            end;
    end;

    trigger OnOpenPage()
    begin
        FieldEditableAddAction_gBln := false;
        FieldEditableModifyAction_gBln := false;
        Rec.SetCurrentkey(Action);
        Rec.Ascending(false);
    end;

    var
        [InDataSet]
        FieldEditableModifyAction_gBln: Boolean;
        [InDataSet]
        FieldEditableAddAction_gBln: Boolean;
        StyleExp_gTxt: Text;
}

