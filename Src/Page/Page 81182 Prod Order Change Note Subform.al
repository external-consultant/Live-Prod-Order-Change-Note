Page 81182 "Prod Order Change Note Subform"
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
    PageType = ListPart;
    SourceTable = "Prod. Order Change Note Line";
    SourceTableView = sorting("Document No.", "Line No.")
                      order(ascending);
    Description = 'T12149';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Prod. Order Component Line No."; Rec."Prod. Order Component Line No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExp_gTxt;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExp_gTxt;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExp_gTxt;

                    trigger OnValidate()
                    var
                        ItemVariant_lRec: Record "Item Variant";
                    begin
                        ItemVariant_lRec.Reset();
                        ItemVariant_lRec.SetRange("Item No.", Rec."Item No.");
                        ItemVariant_lRec.SetFilter(Code, '<>%1', '');
                        if ItemVariant_lRec.FindFirst() then
                            ShowMandatory_gBln := true
                        else
                            ShowMandatory_gBln := false;
                        CurrPage.Update;
                    end;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExp_gTxt;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Editable = FieldEditableModifyAction_gBln or FieldEditableAddAction_gBln;
                    ShowMandatory = ShowMandatory_gBln;
                }
                field("Principal Input"; Rec."Principal Input")
                {
                    ApplicationArea = All;
                    Editable = PrintEditable_gBln;
                    StyleExpr = StyleExp_gTxt;
                }
                field("Substitute Selected"; Rec."Substitute Selected")
                {
                    ApplicationArea = All;
                }
                field("Item Variant Changed"; Rec."Item Variant Changed")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExp_gTxt;
                }
                field("Reserved Quantity"; Rec."Reserved Quantity")
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
                field("Make New Qty Per Zero"; Rec."Make New Qty Per Zero")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Make New Qty Per Zero field.', Comment = '%';
                    Editable = FieldEditableModifyAction_gBln;
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
                    Editable = false;
                    StyleExpr = StyleExp_gTxt;
                }
                field("New Expected Quantity"; Rec."New Expected Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExp_gTxt;
                }
                field(TotalBatchQty_gDec; TotalBatchQty_gDec)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Total Qty/ Batch';
                    Editable = false;
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExp_gTxt;
                }
                field("FG Recovery"; Rec."FG Recovery")
                {
                    ApplicationArea = All;
                    Editable = FieldEditableAddAction_gBln;
                }
                field("FG Recovery Quantity"; Rec."FG Recovery Quantity")
                {
                    ApplicationArea = All;
                    Editable = Rec."FG Recovery";
                }
                field("Act. Consumption (Qty)"; Rec."Act. Consumption (Qty)")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExp_gTxt;
                }
                field(QtyForNegativeConsumption_gDec; QtyForNegativeConsumption_gDec)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Qty. for Negative Consumption';
                    Editable = false;
                    StyleExpr = StyleExp_gTxt;
                }
                field("Action"; Rec.Action)
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExp_gTxt;
                }
                field(UnReservedQty_gDec; UnReservedQty_gDec)
                {
                    ApplicationArea = All;
                    Caption = 'Unreserved Quantity';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Delete Component Lines")
            {
                ApplicationArea = All;
                Image = Delete;
                Visible = false;

                trigger OnAction()
                begin
                    Rec.DeleteComponentLines_gFnc();
                end;
            }
            action("Modifiy Component Lines")
            {
                ApplicationArea = All;
                Image = EditList;

                trigger OnAction()
                begin
                    Rec.ModifiyComponentLines_gFnc(1);
                end;
            }
            action("Remove Action")
            {
                ApplicationArea = All;
                Image = RemoveContacts;

                trigger OnAction()
                begin
                    Rec.RemoveAction_gFnc();
                end;
            }
            action("Show Negative Consumption Line")
            {
                ApplicationArea = All;
                Image = ShowSelected;

                trigger OnAction()
                var
                    ConsumptionJul_lPge: Page "Con Jnl for Prod Change Note";
                    ItemJnlLine_lRec: Record "Item Journal Line";
                    ManufacturingSetup_lRec: Record "Manufacturing Setup";
                    ItemJnlTemplate: Record "Item Journal Template";
                    BlankItemJnlLine: Record "Item Journal Line";
                    ItemJnlBatch: Record "Item Journal Batch";
                begin
                    ManufacturingSetup_lRec.Get;
                    ManufacturingSetup_lRec.TestField("Item Templete - Con. Neg. Adj.");
                    ManufacturingSetup_lRec.TestField("Item Batch - Con. Neg. Adj.");
                    ItemJnlLine_lRec.Reset;
                    ItemJnlLine_lRec.SetRange("Journal Template Name", ManufacturingSetup_lRec."Item Templete - Con. Neg. Adj.");
                    ItemJnlLine_lRec.SetRange("Journal Batch Name", ManufacturingSetup_lRec."Item Batch - Con. Neg. Adj.");
                    ItemJnlLine_lRec.SetRange("Entry Type", ItemJnlLine_lRec."entry type"::Consumption);
                    ItemJnlLine_lRec.SetRange("Document No.", Rec."Document No.");
                    ItemJnlLine_lRec.SetRange("Order No.", Rec."Prod. Order No.");
                    ItemJnlLine_lRec.SetRange("Order Line No.", Rec."Prod. Order Line No.");
                    ItemJnlLine_lRec.SetRange("Prod. Order Comp. Line No.", Rec."Prod. Order Component Line No.");
                    //ItemJnlLine_lRec.FINDFIRST;
                    /*
                    ConsumptionJul_lPge.SetFilter_gFnc(ManufacturingSetup_lRec."Item Templete - Con. Neg. Adj.",ManufacturingSetup_lRec."Item Batch - Con. Neg. Adj.");
                    ConsumptionJul_lPge.SETTABLEVIEW(ItemJnlLine_lRec);
                    ConsumptionJul_lPge.EDITABLE(FALSE);
                    ConsumptionJul_lPge.RUNMODAL;
                    */

                    ItemJnlTemplate.Get(ManufacturingSetup_lRec."Item Templete - Con. Neg. Adj.");
                    ItemJnlBatch.Get(ManufacturingSetup_lRec."Item Templete - Con. Neg. Adj.", ManufacturingSetup_lRec."Item Batch - Con. Neg. Adj.");
                    ItemJnlBatch.TestField(Name);

                    BlankItemJnlLine.FilterGroup := 2;
                    BlankItemJnlLine.SetRange("Journal Template Name", ItemJnlTemplate.Name);
                    BlankItemJnlLine.FilterGroup := 0;

                    BlankItemJnlLine."Journal Template Name" := '';
                    BlankItemJnlLine."Journal Batch Name" := ItemJnlBatch.Name;
                    //ConsumptionJul_lPge.SETTABLEVIEW(ItemJnlLine_lRec);
                    ConsumptionJul_lPge.Setfilter_gFnc(Rec."Prod. Order No.");
                    ConsumptionJul_lPge.SetRecord(ItemJnlLine_lRec);
                    ConsumptionJul_lPge.Editable(false);
                    ConsumptionJul_lPge.RunModal;

                end;
            }
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
            action("&Select Item Substitution")
            {
                AccessByPermission = TableData "Item Substitution" = R;
                ApplicationArea = All;
                Caption = '&Select Item Substitution';
                Image = SelectItemSubstitution;

                trigger OnAction()
                var
                    ItemSubstitutionMgt: Codeunit "Item Subst.";
                begin
                    Rec.TestField(Action, Rec.Action::Modify);
                    CurrPage.SaveRecord;

                    ItemSubstitutionMgt_gCdu.GetCompSubstChangeNote_gFnc(Rec);

                    CurrPage.Update(true);
                end;
            }
            action("Bin Contents")
            {
                ApplicationArea = All;
                Caption = 'Bin Contents';
                Image = BinContent;
                RunObject = Page "Bin Contents List";
                RunPageLink = "Location Code" = field("Location Code"),
                              "Item No." = field("Item No."),
                              "Variant Code" = field("Variant Code");
                RunPageView = sorting("Location Code", "Bin Code", "Item No.", "Variant Code");

                trigger OnAction()
                begin
                    //T10255-N 20-10-2018
                end;
            }
            group("Item Availability by")
            {
                Caption = 'Item Availability by';
                Image = ItemAvailability;
                action("Event")
                {
                    ApplicationArea = All;
                    Caption = 'Event';
                    Image = "Event";

                    trigger OnAction()
                    begin
                        ItemAvailFormsMgt_gCdu.ShowItemAvailFromChangeNoteSubform_gFnc(Rec, ItemAvailFormsMgt.ByEvent);
                    end;
                }
                action(Period)
                {
                    ApplicationArea = All;
                    Caption = 'Period';
                    Image = Period;

                    trigger OnAction()
                    begin
                        ItemAvailFormsMgt_gCdu.ShowItemAvailFromChangeNoteSubform_gFnc(Rec, ItemAvailFormsMgt.ByPeriod);
                    end;
                }
                action(Variant)
                {
                    ApplicationArea = All;
                    Caption = 'Variant';
                    Image = ItemVariant;

                    trigger OnAction()
                    begin
                        ItemAvailFormsMgt_gCdu.ShowItemAvailFromChangeNoteSubform_gFnc(Rec, ItemAvailFormsMgt.ByVariant);
                    end;
                }
                action(Location)
                {
                    AccessByPermission = TableData Location = R;
                    ApplicationArea = All;
                    Caption = 'Location';
                    Image = Warehouse;

                    trigger OnAction()
                    begin
                        ItemAvailFormsMgt_gCdu.ShowItemAvailFromChangeNoteSubform_gFnc(Rec, ItemAvailFormsMgt.ByLocation);
                    end;
                }
                action("BOM Level")
                {
                    ApplicationArea = All;
                    Caption = 'BOM Level';
                    Image = BOMLevel;

                    trigger OnAction()
                    begin
                        ItemAvailFormsMgt_gCdu.ShowItemAvailFromChangeNoteSubform_gFnc(Rec, ItemAvailFormsMgt.ByBOM);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if Rec.Action = Rec.Action::Modify then begin
            FieldEditableModifyAction_gBln := true;
        end else
            if Rec.Action = Rec.Action::Add then begin
                FieldEditableAddAction_gBln := true;
                FieldEditableModifyAction_gBln := true;
                PrintEditable_gBln := true;
            end else begin
                FieldEditableAddAction_gBln := false;
                FieldEditableModifyAction_gBln := false;
            end;

        QtyForNegativeConsumption_gDec := 0;
        Rec.CalcFields("Act. Consumption (Qty)");
        QtyForNegativeConsumption_gDec := Rec."Act. Consumption (Qty)" - Rec."New Expected Quantity";

        if QtyForNegativeConsumption_gDec <= 0 then
            QtyForNegativeConsumption_gDec := 0;
    end;

    trigger OnAfterGetRecord()
    var
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
        ProdOrderChangeNoteHdr_lRec: Record "Prod. Order Change Note Header";
    begin
        StyleExp_gTxt := 'None';
        PrintEditable_gBln := false;
        if Rec.Action = Rec.Action::Modify then begin
            FieldEditableModifyAction_gBln := true;
            StyleExp_gTxt := 'Attention';
        end else
            if Rec.Action = Rec.Action::Add then begin
                FieldEditableAddAction_gBln := true;
                FieldEditableModifyAction_gBln := false;
                PrintEditable_gBln := true;
                StyleExp_gTxt := 'Favorable';
            end else begin
                FieldEditableAddAction_gBln := false;
                FieldEditableModifyAction_gBln := false;
                if Rec.Action = Rec.Action::Delete then
                    StyleExp_gTxt := 'Unfavorable';
            end;

        QtyForNegativeConsumption_gDec := 0;
        Rec.CalcFields("Act. Consumption (Qty)");
        QtyForNegativeConsumption_gDec := Rec."Act. Consumption (Qty)" - Rec."New Expected Quantity";

        if QtyForNegativeConsumption_gDec <= 0 then
            QtyForNegativeConsumption_gDec := 0;

        //ProdOrderChangeNote-NS
        UnReservedQty_gDec := 0;
        ItemLedgerEntry_lRec.Reset;
        ItemLedgerEntry_lRec.SetRange("Item No.", Rec."Item No.");
        ItemLedgerEntry_lRec.SetRange("Variant Code", Rec."Variant Code");
        ItemLedgerEntry_lRec.SetRange("Location Code", Rec."Location Code");
        ItemLedgerEntry_lRec.SetFilter("Remaining Quantity", '>%1', 0);
        if ItemLedgerEntry_lRec.FindSet then begin
            repeat
                ItemLedgerEntry_lRec.CalcFields("Reserved Quantity");
                UnReservedQty_gDec += ItemLedgerEntry_lRec."Remaining Quantity" - ItemLedgerEntry_lRec."Reserved Quantity";
            until ItemLedgerEntry_lRec.Next = 0;
        end;
        //ProdOrderChangeNote-NE

        TotalBatchQty_gDec := 0;
        ProdOrderChangeNoteHdr_lRec.Get(Rec."Document No.");
        //TotalBatchQty_gDec := Rec."New Quantity Per" * ProdOrderChangeNoteHdr_lRec."Batch Qty";
        if ProdOrderChangeNoteHdr_lRec."No. of Batches" > 0 then
            TotalBatchQty_gDec := Rec."New Expected Quantity" / ProdOrderChangeNoteHdr_lRec."No. of Batches"
        else
            TotalBatchQty_gDec := Rec."New Expected Quantity";

    end;

    trigger OnDeleteRecord(): Boolean
    begin
        //Rec.TestField("Prod. Order Component Line No.", 0);
    end;

    trigger OnOpenPage()
    begin
        FieldEditableAddAction_gBln := false;
        FieldEditableModifyAction_gBln := false;
        PrintEditable_gBln := false;
        QtyForNegativeConsumption_gDec := 0;
        //SETCURRENTKEY(Action);
        //ASCENDING(FALSE);
    end;

    trigger OnModifyRecord(): Boolean
    var
        ProdOrderChangeNoteHeader_lRec: Record "Prod. Order Change Note Header";
    begin
        ProdOrderChangeNoteHeader_lRec.Reset();
        ProdOrderChangeNoteHeader_lRec.GET(Rec."Document No.");
        ProdOrderChangeNoteHeader_lRec."Quantity Calculated" := false;
        ProdOrderChangeNoteHeader_lRec.Modify();
    end;

    var
        [InDataSet]
        FieldEditableModifyAction_gBln: Boolean;
        [InDataSet]
        FieldEditableAddAction_gBln: Boolean;
        QtyForNegativeConsumption_gDec: Decimal;
        StyleExp_gTxt: Text;
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        [InDataSet]
        PrintEditable_gBln: Boolean;
        UnReservedQty_gDec: Decimal;
        TotalBatchQty_gDec: Decimal;
        ItemSubstitutionMgt_gCdu: Codeunit Subscribe_Codeunit_5701;
        ItemAvailFormsMgt_gCdu: Codeunit Subscribe_Codeunit_353;
        ShowMandatory_gBln: Boolean;
}

