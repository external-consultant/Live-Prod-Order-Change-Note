Page 81189 "Con Jnl for Prod Change Note"
{
    // ------------------------------------------------------------------------------------------------------------------------
    // Intech Systems Pvt. Ltd.
    // ------------------------------------------------------------------------------------------------------------------------
    // ID                        Date            Author
    // ------------------------------------------------------------------------------------------------------------------------
    // I-I005-3001040-01         18/06/2010      Dipak
    //                           Subcontracting-> Added "Receipt No." and "Receipt Line No." Field on Page.
    // I-I005-3001040-01         30/06/2010      KSP
    //                           added code to test the Receipt No. and Line No. when Posting
    // I-A005_A-3000250-01       13/10/10        KSP
    //                           Added code to Validate Variant Code
    // I-A005_A-3000850-01       28/12/10        Pankaj
    //                           Added Code in OnAction trigger of 'Post' and 'Post and Print'  Menuitem to display
    //                           Document No.  generated after Posting.
    // I-I011-3001009-11-01      10/03/2011      RJT
    //                           Added code to make Description field Non-Editable
    // I-I011-3001004-08-01      24/03/11        RJT
    //                           Added fields
    //                           1) Available Stock Quantity
    //                           2) Total Qty. Req. in Prod. Order
    //                           3) Prod. Order Due Date
    //                           4) Difference Quantity
    //                           Added function "Shown Stock Qty. Only"to Remove the Consumption
    //                           Journal Lines having stock of items lesser than the required.
    // I-I011-3001004-09-01      24/03/11        RJT
    //                           Added function call for "Calc. Consumption Return"
    //                           for functionality "Material Return-Item/ProdOrder/IssueSlipWise"
    //                           Property changed of fields
    //                           1) Unit Amount - Visible - FALSE
    //                           2) Unit Cost - Visible - FALSE
    // I-I011-3001004-15-01      12/05/11        RJT
    //                           Added code to Print
    //                           Issue Slip that contains data Issue Slip No. wise, Production Order wise
    //                           Item Consumption Details after posting the Consumption
    // I-I011-3001009-16-01      16/11/11        RJT
    //                           Changed ProdOrderDescription VARIABLE length from 50 to 100
    // I-I011-3001004-18-01      21/11/11        RJT
    //                           Open JournalBatchList on Running Consumption / Output Journals
    // A012_A-1000147-01         31/01/12        Jignesh Dhandha
    //                           Added Code to Post Consumption Journal Based On User Rights wise
    //                           Added Field : "Requested Quantity"
    // A012_A-1000187-01         17/02/12        Jignesh Dhandha
    //                           Added field : "Issue Remarks"
    // I-A012_A-1000467-01       26/05/12        Nilesh Gajjar
    //                           Added code to check that consumption qty must be lessthan zero
    // ------------------------------------------------------------------------------------------------------------------------

    ApplicationArea = All;
    AutoSplitKey = true;
    Caption = 'Consumption Journal for Prod Order Change Note';
    DataCaptionFields = "Journal Batch Name";
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Item Journal Line";
    UsageCategory = Tasks;
    Description = 'T12149';
    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                ApplicationArea = All;
                Caption = 'Batch Name';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord;
                    ItemJnlMgt.LookupName(CurrentJnlBatchName, Rec);
                    CurrPage.Update(false);
                    ItemJnlMgt.CheckName(CurrentJnlBatchName, Rec);
                end;

                trigger OnValidate()
                begin
                    ItemJnlMgt.CheckName(CurrentJnlBatchName, Rec);
                    CurrentJnlBatchNameOnAfterVali;
                end;
            }
            repeater(Control1)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        ItemJnlMgt.GetConsump(Rec, ProdOrderDescription);
                    end;
                }
                field("Order Line No."; Rec."Order Line No.")
                {
                    ApplicationArea = All;
                }
                field("Prod. Order Comp. Line No."; Rec."Prod. Order Comp. Line No.")
                {
                    ApplicationArea = All;
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = DescnEditable_gBln;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,3';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(3, ShortcutDimCode[3]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,4';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(4, ShortcutDimCode[4]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,5';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(5, ShortcutDimCode[5]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,6';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(6, ShortcutDimCode[6]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,7';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(7, ShortcutDimCode[7]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,8';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(8, ShortcutDimCode[8]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Applies-to Entry"; Rec."Applies-to Entry")
                {
                    ApplicationArea = All;
                }
                field("Applies-from Entry"; Rec."Applies-from Entry")
                {
                    ApplicationArea = All;
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ApplicationArea = All;
                }
                field("Receipt Line No."; Rec."Receipt Line No.")
                {
                    ApplicationArea = All;
                }
            }
            group(Control73)
            {
                fixed(Control1902114901)
                {
                    group("Prod. Order Name")
                    {
                        Caption = 'Prod. Order Name';
                        field(ProdOrderDescription; ProdOrderDescription)
                        {
                            ApplicationArea = All;
                            Editable = false;
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                Visible = false;
                ApplicationArea = All;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    ApplicationArea = All;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions;
                        CurrPage.SaveRecord;
                    end;
                }
                action("Item &Tracking Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    ShortCutKey = 'Shift+Ctrl+I';

                    trigger OnAction()
                    begin
                        Rec.OpenItemTrackingLines(false);
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
                    RunPageView = sorting("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
                }
            }
            group("Pro&d. Order")
            {
                Caption = 'Pro&d. Order';
                Image = "Order";
                action(Card)
                {
                    ApplicationArea = All;
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Released Production Order";
                    RunPageLink = "No." = field("Order No.");
                    ShortCutKey = 'Shift+F7';
                }
                group("Ledger E&ntries")
                {
                    Caption = 'Ledger E&ntries';
                    Image = Entries;
                    action("Item Ledger E&ntries")
                    {
                        ApplicationArea = All;
                        Caption = 'Item Ledger E&ntries';
                        Image = ItemLedger;
                        RunObject = Page "Item Ledger Entries";
                        RunPageLink = "Order Type" = const(Production),
                                      "Order No." = field("Order No.");
                        ShortCutKey = 'Ctrl+F7';
                    }
                    action("Capacity Ledger Entries")
                    {
                        ApplicationArea = All;
                        Caption = 'Capacity Ledger Entries';
                        Image = CapacityLedger;
                        RunObject = Page "Capacity Ledger Entries";
                        RunPageLink = "Order Type" = const(Production),
                                      "Order No." = field("Order No.");
                    }
                }
            }
        }
        area(processing)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action("Test Report")
                {
                    ApplicationArea = All;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;

                    trigger OnAction()
                    begin
                        ReportPrint.PrintItemJnlLine(Rec);
                    end;
                }
                action("P&ost")
                {
                    ApplicationArea = All;
                    Caption = 'P&ost';
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        UserSetup_lRec: Record "User Setup";
                    begin
                        // //I-I005-3001040-01 NS
                        // ProdOrder_gRec.SetRange("No.", Rec."Order No.");
                        // if ProdOrder_gRec.Find('-') then
                        //     if ProdOrder_gRec.Status = ProdOrder_gRec.Status::Released then begin
                        //         ProdOrderLine_gRec.SetRange("Prod. Order No.", ProdOrder_gRec."No.");
                        //         ProdOrderLine_gRec.SetRange(Status, ProdOrder_gRec.Status);
                        //         ProdOrderLine_gRec.SetRange("Line No.", Rec."Order Line No.");
                        //         if ProdOrderLine_gRec.Find('-') then
                        //             if (ProdOrderLine_gRec."Subcontracting Order No." <> '') or (ProdOrderLine_gRec."Subcontractor Code" <> '') then begin
                        //                 Rec.TestField("Receipt No.");
                        //                 Rec.TestField("Receipt Line No.");
                        //             end;
                        //     end;
                        // //I-I005-3001040-01 NE

                        //A012_A-1000147-01-NS
                        UserSetup_lRec.Get(UserId);
                        if UserSetup_lRec."Allow Consumption Posting" then begin
                            ItemJnlLine_gRec.ChechOnlyNegativeConsum_gFnc(Rec);  //I-A012_A-1000467-01-N
                                                                                 //A012_A-1000147-01-NE
                            Codeunit.Run(Codeunit::"Item Jnl.-Post", Rec)
                            //A012_A-1000147-01-NS
                        end else
                            UserSetup_lRec.FieldError("Allow Consumption Posting", 'must be true');
                        //A012_A-1000147-01-NE

                        // //I-A005_A-3000850-01-ns
                        // DocumentNo_gCode := ProdSchedMgt_gCdu.ReturnDocumentNo_gFnc;
                        // Message(Text001_gCtx, DocumentNo_gCode);
                        // //I-A005_A-3000850-01-ne
                        // CurrentJnlBatchName := Rec.GetRangemax("Journal Batch Name");
                        // CurrPage.Update(false);
                        // //I-I011-3001004-15-01-NS
                        // if Confirm(Text53000_gCtx, false, DocumentNo_gCode) then begin
                        //     ItemLedgerEntry_gRec.SetRange(ItemLedgerEntry_gRec."Document No.", DocumentNo_gCode);
                        //     //Report.RunModal(Report::Report53010, true, true, ItemLedgerEntry_gRec);
                        // end;
                        //I-I011-3001004-15-01-NE
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = All;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';

                    trigger OnAction()
                    begin
                        // //I-I005-3001040-01 NS
                        // ProdOrder_gRec.SetRange("No.", Rec."Order No.");
                        // if ProdOrder_gRec.Find('-') then
                        //     if ProdOrder_gRec.Status = ProdOrder_gRec.Status::Released then begin
                        //         ProdOrderLine_gRec.SetRange("Prod. Order No.", ProdOrder_gRec."No.");
                        //         ProdOrderLine_gRec.SetRange(Status, ProdOrder_gRec.Status);
                        //         ProdOrderLine_gRec.SetRange("Line No.", Rec."Order Line No.");
                        //         if ProdOrderLine_gRec.Find('-') then
                        //             if (ProdOrderLine_gRec."Subcontracting Order No." <> '') or (ProdOrderLine_gRec."Subcontractor Code" <> '') then begin
                        //                 Rec.TestField("Receipt No.");
                        //                 Rec.TestField("Receipt Line No.");
                        //             end;
                        //     end;
                        // //I-I005-3001040-01 NE
                        ItemJnlLine_gRec.ChechOnlyNegativeConsum_gFnc(Rec);  //I-A012_A-1000467-01-N
                        Rec.PostingItemJnlFromProduction(true);
                        //I-A005_A-3000850-01-ns
                        // DocumentNo_gCode := ProdSchedMgt_gCdu.ReturnDocumentNo_gFnc;
                        // Message(Text001_gCtx, DocumentNo_gCode);
                        //I-A005_A-3000850-01-ne
                        CurrentJnlBatchName := Rec.GetRangemax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
            }
            action("&Print")
            {
                ApplicationArea = All;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction()
                var
                    ItemJnlLine: Record "Item Journal Line";
                begin
                    ItemJnlLine.Copy(Rec);
                    ItemJnlLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                    ItemJnlLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    Report.RunModal(Report::"Inventory Movement", true, true, ItemJnlLine);
                end;
            }
            // action("<Action1000000003>")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Material Issue/Cons. Return Slip';
            //     Promoted = true;
            //     PromotedCategory = "Report";

            //     trigger OnAction()
            //     var
            //         ItemJnlLine: Record "Item Journal Line";
            //     begin
            //         ItemJnlLine.Copy(Rec);
            //         ItemJnlLine.SetRange("Journal Template Name", Rec."Journal Template Name");
            //         ItemJnlLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
            //         Report.RunModal(Report::"Vendor Block 6 Month Invoice", true, true, ItemJnlLine);
            //     end;
            // }
            action("<Action1000000009>")
            {
                ApplicationArea = All;
                Caption = 'Posted Consumption Issue Slip';
                Promoted = true;
                PromotedCategory = "Report";

                trigger OnAction()
                begin
                    //Report.RunModal(Report::Report53010, true, true);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        ItemJnlMgt.GetConsump(Rec, ProdOrderDescription);
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
        //I-I011-3001009-11-01-NS
        if Rec."Item No." <> '' then
            DescnEditable_gBln := false
        else
            DescnEditable_gBln := true;
        //I-I011-3001009-11-01-NE
    end;

    trigger OnDeleteRecord(): Boolean
    var
        ReserveItemJnlLine: Codeunit "Item Jnl. Line-Reserve";
    begin
        Commit;
        if not ReserveItemJnlLine.DeleteLineConfirm(Rec) then
            exit(false);
        ReserveItemJnlLine.DeleteLine(Rec);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetUpNewLine(xRec);
        Rec.Validate("Entry Type", Rec."entry type"::Consumption);
        Clear(ShortcutDimCode);
    end;

    trigger OnOpenPage()
    var
        ManufacturingSetup_lRec: Record "Manufacturing Setup";
        JnlSelected: Boolean;
    begin
        if Rec.IsOpenedFromBatch then begin
            CurrentJnlBatchName := Rec."Journal Batch Name";
            ItemJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);
            exit;
        end;
        ItemJnlMgt.TemplateSelection(Page::"Consumption Journal", 4, false, Rec, JnlSelected);
        if not JnlSelected then
            Error('');
        ItemJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);

        if SetDocNo_gCod <> '' then
            Rec.SetFilter("Order No.", SetDocNo_gCod);
    end;

    var
        ItemJnlMgt: Codeunit ItemJnlManagement;
        ReportPrint: Codeunit "Test Report-Print";
        ProdOrderDescription: Text[100];
        CurrentJnlBatchName: Code[10];
        ShortcutDimCode: array[8] of Code[20];
        OpenedFromBatch: Boolean;
        ProdOrder_gRec: Record "Production Order";
        ProdOrderLine_gRec: Record "Prod. Order Line";
        Item_gRec: Record Item;
        ItemVariant_gRec: Record "Item Variant";
        DocumentNo_gCode: Code[20];
        Text001_gCtx: label 'Generated Document No. is %1';
        [InDataSet]
        DescnEditable_gBln: Boolean;
        Text53000_gCtx: label 'Do you want to print Issue Slip %1?';
        ItemLedgerEntry_gRec: Record "Item Ledger Entry";
        ItemJnlLine_gRec: Record "Item Journal Line";
        //ProdSchedMgt_gCdu: Codeunit "Show Doc No Single Inst";
        SetDocNo_gCod: Code[20];

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SaveRecord;
        ItemJnlMgt.SetName(CurrentJnlBatchName, Rec);
        CurrPage.Update(false);
    end;


    procedure Setfilter_gFnc(SetDocNo_iCod: Code[20])
    begin
        SetDocNo_gCod := SetDocNo_iCod;
    end;
}

