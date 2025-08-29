Page 81181 "Prod. Order Change Note Card"
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

    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Approval,Negative Consumption';
    RefreshOnActivate = true;
    SourceTable = "Prod. Order Change Note Header";
    Description = 'T12149';

    layout
    {
        area(content)
        {
            group(General)
            {
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
                    ValuesAllowed = " ", "Firm Planned", Released;
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    ApplicationArea = All;
                }
                field("Prod. Order Line No."; Rec."Prod. Order Line No.")
                {
                    ApplicationArea = All;
                }
                // field("Base Prod. BOM Change Note"; Rec."Base Prod. BOM Change Note")
                // {
                //     ApplicationArea = All;
                // }
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
                // field(Submitted; Rec.Submitted)
                // {
                //     ApplicationArea = All;
                // }
                // field("Submitted By"; Rec."Submitted By")
                // {
                //     ApplicationArea = All;
                // }
                // field("Submitted On"; Rec."Submitted On")
                // {
                //     ApplicationArea = All;
                // }
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
                }
                field("Batch Qty"; Rec."Batch Qty")
                {
                    ApplicationArea = All;
                }
                field("No. of Batches"; Rec."No. of Batches")
                {
                    ApplicationArea = All;
                }
                field("Updated Production Quantity"; Rec."Updated Production Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
                }
                field("Total Recovery Qty"; Rec."Total Recovery Qty")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Recovery Qty field.', Comment = '%';
                }
                field("Total Raw Material to Consume"; Rec."Total Raw Material to Consume")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = true;
                }
            }
            part("Prod. Order Change Note Lines"; "Prod Order Change Note Subform")
            {
                SubPageLink = "Document No." = field("No.");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Get Component Lines")
            {
                ApplicationArea = All;
                Image = GetLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.InsertProdOrderCompLines_gFnc(Rec, false);
                end;
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
            action(Post)
            {
                ApplicationArea = All;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField("Quantity Calculated", true);
                    Rec.PostDocument_gFnc();
                    CurrPage.Close;
                end;
            }
            action("Create Negative Consumption Entry")
            {
                ApplicationArea = All;
                Image = CreateLinesFromJob;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ProdOrderChangeNoteMgmt_lCdu: Codeunit "Prod. Order Change App. Mgmt";
                begin
                    ProdOrderChangeNoteMgmt_lCdu.CreateNegativeConsumptionEntry_gFnc(Rec);
                end;
            }
            action("Delete Negative Consumption Entry")
            {
                ApplicationArea = All;
                Image = DeleteExpiredComponents;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ProdOrderChangeNoteMgmt_lCdu: Codeunit "Prod. Order Change App. Mgmt";
                begin
                    ProdOrderChangeNoteMgmt_lCdu.DeleteNegativeConsumptionEntry_gFnc(Rec);
                end;
            }
            action("Show Negative Consumpt All Line")
            {
                ApplicationArea = All;
                Caption = 'Show Negative Consumption All Lines';
                Image = ShowSelected;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

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
                    ItemJnlLine_lRec.SetRange("Document No.", Rec."No.");

                    ItemJnlTemplate.Get(ManufacturingSetup_lRec."Item Templete - Con. Neg. Adj.");
                    ItemJnlBatch.Get(ManufacturingSetup_lRec."Item Templete - Con. Neg. Adj.", ManufacturingSetup_lRec."Item Batch - Con. Neg. Adj.");
                    ItemJnlBatch.TestField(Name);

                    BlankItemJnlLine.FilterGroup := 2;
                    BlankItemJnlLine.SetRange("Journal Template Name", ItemJnlTemplate.Name);
                    BlankItemJnlLine.FilterGroup := 0;

                    BlankItemJnlLine."Journal Template Name" := '';
                    BlankItemJnlLine."Journal Batch Name" := ItemJnlBatch.Name;
                    ConsumptionJul_lPge.Setfilter_gFnc(Rec."Prod. Order No.");
                    ConsumptionJul_lPge.SetRecord(ItemJnlLine_lRec);
                    ConsumptionJul_lPge.Editable(false);
                    ConsumptionJul_lPge.RunModal;
                end;
            }
            action("Send Approval Request")
            {
                ApplicationArea = All;
                Caption = 'Send Approval &Request';
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+1';

                trigger OnAction()
                var
                    ProdOrderChangeNoteAppMgt_lCdu: Codeunit "Prod. Order Change App. Mgmt";
                begin
                    Rec.TestField("Quantity Calculated", true);
                    ProdOrderChangeNoteAppMgt_lCdu.SendForApproval_gFnc(Rec);    //ProdOrderChangeNote-N
                end;
            }
            action("Cancel Approval Request")
            {
                ApplicationArea = All;
                Caption = '&Cancel Approval Request';
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+2';

                trigger OnAction()
                var
                    ProdOrderChangeNoteAppMgt_lCdu: Codeunit "Prod. Order Change App. Mgmt";
                begin
                    ProdOrderChangeNoteAppMgt_lCdu.CancelApprovalRequest_gFnc(Rec);    //ProdOrderChangeNote-N
                end;
            }
            action("Reopen Approval Entry")
            {
                ApplicationArea = All;
                Caption = 'Reopen Approval Entry';
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ProdOrderChangeNoteAppMgt_lCdu: Codeunit "Prod. Order Change App. Mgmt";
                begin
                    ProdOrderChangeNoteAppMgt_lCdu.ReOpenRequest_gFnc(Rec);    //ProdOrderChangeNote-N
                end;
            }
            action("Show Approval Entry")
            {
                ApplicationArea = All;
                Image = Approvals;
                Promoted = true;
                PromotedCategory = Category4;
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
            action("Calculate Components Qty")
            {
                ApplicationArea = All;
                Caption = 'Calculate Components Qty';
                Image = AdjustEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ProdOrderChangeNoteLine_lRec: Record "Prod. Order Change Note Line";
                    POCNLine_lRec: Record "Prod. Order Change Note Line";
                    RecoveryLine_lFnc: Record "Prod. Order Change Note Line";
                    CalNewQtyPer_lDec: Decimal;
                    TotalRecoveryQty_lDec: Decimal;
                    NewQTy_lDec: Decimal;
                    OringalExpQty_lDec: Decimal;
                    NewQtyAsPerOldQtyPer_lDec: Decimal;
                    Text001: Label 'Reduce FG Qty,Add FG Qty';
                    Selection: Integer;
                    SelectionString_lText: Text;
                    TotalPrincipleInputQty_lDec: Decimal;
                    ChangeinQtyPer_lBln: Boolean;
                    AddNewPrincipleInputItem_lBln: Boolean;
                begin

                    Rec.TestField("Batch Qty");
                    Rec.TestField("No. of Batches");
                    if Rec."Quantity Calculated" then
                        Error('You can not proform this action without making any changes in the lines.');
                    //----------------------------------------------------------------------------------------------Resetting the Values Begin
                    Rec."Updated Production Quantity" := Rec."Original Prod Order Qty";
                    Rec."Total Raw Material to Consume" := Rec."Original Prod Order Qty";
                    Rec."Total Recovery Qty" := 0;
                    Rec.Modify();
                    //----------------------------------------------------------------------------------------------Resetting the Values End

                    //----------------------------------------------------------------------------------------------Checking for  change in Quantity per Begin 
                    ChangeinQtyPer_lBln := false;
                    POCNLine_lRec.Reset();
                    POCNLine_lRec.SetRange("Document No.", Rec."No.");
                    POCNLine_lRec.SetRange(Action, POCNLine_lRec.Action::Modify);
                    if POCNLine_lRec.FindSet() then
                        repeat
                            if POCNLine_lRec."Quantity Per" <> POCNLine_lRec."New Quantity Per" then
                                ChangeinQtyPer_lBln := true;
                        until POCNLine_lRec.next = 0;
                    //----------------------------------------------------------------------------------------------Checking for  change in Quantity per End

                    //----------------------------------------------------------------------------------------------Checking for  New Component Line Begin
                    AddNewPrincipleInputItem_lBln := false;
                    POCNLine_lRec.Reset();
                    POCNLine_lRec.SetRange("Document No.", Rec."No.");
                    POCNLine_lRec.SetRange(Action, POCNLine_lRec.Action::Add);
                    POCNLine_lRec.SetRange("FG Recovery", false);
                    if POCNLine_lRec.FindFirst() then
                        AddNewPrincipleInputItem_lBln := true;
                    //----------------------------------------------------------------------------------------------Checking for  New Component Line End

                    //----------------------------------------------------------------------------------------------Selection for FG Recovery Item action Begin
                    POCNLine_lRec.Reset();
                    POCNLine_lRec.SetRange("Document No.", Rec."No.");
                    POCNLine_lRec.SetRange("FG Recovery", true);
                    if POCNLine_lRec.FindFirst() then begin
                        if (ChangeinQtyPer_lBln) OR (AddNewPrincipleInputItem_lBln) then
                            Selection := 2
                        else
                            Selection := StrMenu(Text001, 1, 'Kindly select the action.');
                    end else
                        Selection := 3;
                    //----------------------------------------------------------------------------------------------Selection for FG Recovery Item action End


                    case Selection of
                        1:
                            SelectionString_lText := 'Reduce FG Qty &';
                        2:
                            SelectionString_lText := 'Add FG Qty &';
                        3:
                            SelectionString_lText := '';
                    end;

                    if not Confirm('Do you want to %1 Updated Production Quantity', True, SelectionString_lText) then
                        exit;

                    //----------------------------------------------------------------------------------------------Calculating total Recovery Quantity Begin
                    TotalRecoveryQty_lDec := 0;
                    RecoveryLine_lFnc.Reset;
                    RecoveryLine_lFnc.SetRange("Document No.", Rec."No.");
                    if RecoveryLine_lFnc.FindSet then begin
                        repeat
                            if RecoveryLine_lFnc.Recovery then
                                RecoveryLine_lFnc.TestField("Recovery Quantity");

                            if RecoveryLine_lFnc."FG Recovery" then
                                RecoveryLine_lFnc.TestField("FG Recovery Quantity");

                            TotalRecoveryQty_lDec += RecoveryLine_lFnc."Recovery Quantity" + RecoveryLine_lFnc."FG Recovery Quantity";
                        until RecoveryLine_lFnc.Next = 0;
                    end;
                    //----------------------------------------------------------------------------------------------Calculating total Recovery Quantity End

                    //----------------------------------------------------------------------------------------------Porcessing FG Recovery Item Begin
                    ProdOrderChangeNoteLine_lRec.Reset;
                    ProdOrderChangeNoteLine_lRec.SetRange("Document No.", Rec."No.");
                    ProdOrderChangeNoteLine_lRec.SetRange("Principal Input", true);
                    ProdOrderChangeNoteLine_lRec.SetRange("FG Recovery", true);
                    ProdOrderChangeNoteLine_lRec.SetRange(Processed, false);
                    ProdOrderChangeNoteLine_lRec.SetRange(Action, ProdOrderChangeNoteLine_lRec.Action::Add);
                    if ProdOrderChangeNoteLine_lRec.FindSet then begin
                        repeat
                            CalNewQtyPer_lDec := 0;
                            CalNewQtyPer_lDec := ROUND(ProdOrderChangeNoteLine_lRec."FG Recovery Quantity" / Rec."Original Prod Order Qty", 0.00001, '<');

                            ProdOrderChangeNoteLine_lRec.Validate("New Quantity Per", CalNewQtyPer_lDec);//old
                            ProdOrderChangeNoteLine_lRec.Processed := true;
                            ProdOrderChangeNoteLine_lRec.Modify;
                        until ProdOrderChangeNoteLine_lRec.Next = 0;
                    end;
                    //----------------------------------------------------------------------------------------------Porcessing FG Recovery Item End

                    //----------------------------------------------------------------------------------------------Porcessing Add and modify Action for Principal Input Items Begin
                    ProdOrderChangeNoteLine_lRec.Reset;
                    ProdOrderChangeNoteLine_lRec.SetRange("Document No.", Rec."No.");
                    ProdOrderChangeNoteLine_lRec.SetRange("Principal Input", true);
                    ProdOrderChangeNoteLine_lRec.SetRange(Processed, false);
                    ProdOrderChangeNoteLine_lRec.setfilter(Action, '%1|%2', ProdOrderChangeNoteLine_lRec.Action::Add, ProdOrderChangeNoteLine_lRec.Action::Modify);
                    if ProdOrderChangeNoteLine_lRec.FindSet then begin
                        repeat
                            ProdOrderChangeNoteLine_lRec.Validate("New Expected Quantity", ProdOrderChangeNoteLine_lRec."New Quantity Per" * Rec."Original Prod Order Qty");//old
                            ProdOrderChangeNoteLine_lRec.Processed := true;
                            ProdOrderChangeNoteLine_lRec.Modify;
                        until ProdOrderChangeNoteLine_lRec.Next = 0;
                    end;
                    //----------------------------------------------------------------------------------------------Porcessing Add and modify Action for Principal Input Items End                    

                    //----------------------------------------------------------------------------------------------Preparing Line to Modfy Action and calculating total Principal Input Items Begin
                    ProdOrderChangeNoteLine_lRec.Reset;
                    ProdOrderChangeNoteLine_lRec.SetRange("Document No.", Rec."No.");
                    if ProdOrderChangeNoteLine_lRec.FindSet then begin
                        repeat
                            if (ProdOrderChangeNoteLine_lRec.Action = ProdOrderChangeNoteLine_lRec.Action::" ") and (ProdOrderChangeNoteLine_lRec."Prod. Order Component Line No." <> 0) then
                                ProdOrderChangeNoteLine_lRec.ModifiyComponentLines_gFnc(Selection);

                            if ProdOrderChangeNoteLine_lRec."Principal Input" then
                                TotalPrincipleInputQty_lDec += ProdOrderChangeNoteLine_lRec."New Quantity Per" * Rec."Original Prod Order Qty"; //Line 
                        until ProdOrderChangeNoteLine_lRec.Next = 0;
                    end;
                    //----------------------------------------------------------------------------------------------Preparing Line to Modfy Action and calculating total Principal Input Items End

                    if Selection = 1 then
                        TotalPrincipleInputQty_lDec := TotalPrincipleInputQty_lDec - TotalRecoveryQty_lDec;

                    //----------------------------------------------------------------------------------------------Processing Modfy Action for all remaining lines Begin
                    ProdOrderChangeNoteLine_lRec.Reset;
                    ProdOrderChangeNoteLine_lRec.SetRange("Document No.", Rec."No.");
                    ProdOrderChangeNoteLine_lRec.SetRange("Principal Input", true);
                    ProdOrderChangeNoteLine_lRec.SetRange("FG Recovery", false);
                    ProdOrderChangeNoteLine_lRec.SetRange(Processed, false);
                    ProdOrderChangeNoteLine_lRec.SetRange(Action, ProdOrderChangeNoteLine_lRec.Action::Modify);
                    if ProdOrderChangeNoteLine_lRec.FindSet then begin
                        repeat
                            ProdOrderChangeNoteLine_lRec."New Expected Quantity" := ROUND(ProdOrderChangeNoteLine_lRec."New Quantity Per" * TotalPrincipleInputQty_lDec, 0.00001, '>');
                            ProdOrderChangeNoteLine_lRec.Processed := true;
                            ProdOrderChangeNoteLine_lRec.Modify;
                        until ProdOrderChangeNoteLine_lRec.Next = 0;
                    end;
                    //----------------------------------------------------------------------------------------------Processing Modfy Action for all remaining lines End

                    //----------------------------------------------------------------------------------------------Updateing Header values Begin
                    case Selection of
                        1:
                            begin
                                Rec."Prod Qty Change Type" := Rec."Prod Qty Change Type"::Reduced;
                                Rec."Total Raw Material to Consume" := ROUND(TotalPrincipleInputQty_lDec, 0.000011, '<');
                            end;
                        2:
                            begin
                                Rec."Prod Qty Change Type" := Rec."Prod Qty Change Type"::Added;
                                Rec."Updated Production Quantity" := ROUND(TotalPrincipleInputQty_lDec, 0.00001, '<');
                                Rec."Total Raw Material to Consume" := ROUND(TotalPrincipleInputQty_lDec - TotalRecoveryQty_lDec, 0.00001, '<');
                            end;
                        3:
                            begin
                                Rec."Updated Production Quantity" := ROUND(TotalPrincipleInputQty_lDec, 0.00001, '<');
                                Rec."Total Raw Material to Consume" := ROUND(TotalPrincipleInputQty_lDec, 0.00001, '<');
                            end;
                    end;

                    Rec."Total Recovery Qty" := TotalRecoveryQty_lDec;
                    Rec."Quantity Calculated" := true;
                    Rec.Modify;
                    //----------------------------------------------------------------------------------------------Updateing Header values End

                    //----------------------------------------------------------------------------------------------Processing Non Principal Input lies for Modify Action Begin
                    ProdOrderChangeNoteLine_lRec.Reset;
                    ProdOrderChangeNoteLine_lRec.SetRange("Document No.", Rec."No.");
                    ProdOrderChangeNoteLine_lRec.SetRange("Principal Input", false);
                    ProdOrderChangeNoteLine_lRec.SetRange(Processed, false);
                    if ProdOrderChangeNoteLine_lRec.FindSet then begin
                        repeat
                            ProdOrderChangeNoteLine_lRec."New Expected Quantity" := ROUND(ProdOrderChangeNoteLine_lRec."New Quantity Per" * Rec."Updated Production Quantity", 0.00001, '>');
                            ProdOrderChangeNoteLine_lRec.Processed := true;
                            ProdOrderChangeNoteLine_lRec.Modify();
                        until ProdOrderChangeNoteLine_lRec.Next = 0;
                    End;
                    //----------------------------------------------------------------------------------------------Processing Non Principal Input lies for Modify Action End

                    Message('New Quantity Per updated successfully');
                end;
            }

            /*     action("Calculate Components Qty")
            {
                ApplicationArea = All;
                Caption = 'Calculate Components Qty';
                Image = AdjustEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ProdOrderChangeNoteLine_lRec: Record "Prod. Order Change Note Line";
                    POCNLine_lRec: Record "Prod. Order Change Note Line";
                    RecoveryLine_lFnc: Record "Prod. Order Change Note Line";
                    CalNewQtyPer_lDec: Decimal;
                    TotalRecoveryQty_lDec: Decimal;
                    NewQTy_lDec: Decimal;
                    OringalExpQty_lDec: Decimal;
                    NewQtyAsPerOldQtyPer_lDec: Decimal;
                    Text001: Label 'Reduce FG Qty,Add FG Qty';
                    Selection: Integer;
                    OriginalQty_lRecx: Decimal;
                    SelectionString_lText: Text;
                    SumNewExpectedQty_lDec: Decimal;
                    PrincipalInput_lBln: Boolean;
                    TotaNewQtyAsPerLineModify_lDec: Decimal;
                    OriginalProdOrderQty_lDec: Decimal;
                    CurrentPCNProdOrderQty_lDec: Decimal;
                    TotalPrincipleInputQty_lDec: Decimal;
                    ChangeinQtyPer_lBln: Boolean;
                    AddNewPrincipleInputItem_lBln: Boolean;
                begin
                    TotaNewQtyAsPerLineModify_lDec := 0;
                    Rec.TestField("Batch Qty");
                    Rec.TestField("No. of Batches");
                    if Rec."Quantity Calculated" then
                        Error('You can not proform this action without making any changes in the lines.');

                    Rec."Updated Production Quantity" := Rec."Original Prod Order Qty";
                    Rec."Total Raw Material to Consume" := Rec."Original Prod Order Qty";
                    Rec."Total Recovery Qty" := 0;
                    Rec.Modify();

                    ChangeinQtyPer_lBln := false;
                    POCNLine_lRec.Reset();
                    POCNLine_lRec.SetRange("Document No.", Rec."No.");
                    POCNLine_lRec.SetRange(Action, POCNLine_lRec.Action::Modify);
                    if POCNLine_lRec.FindSet() then
                        repeat
                            if POCNLine_lRec."Quantity Per" <> POCNLine_lRec."New Quantity Per" then
                                ChangeinQtyPer_lBln := true;
                        until POCNLine_lRec.next = 0;

                    AddNewPrincipleInputItem_lBln := false;
                    POCNLine_lRec.Reset();
                    POCNLine_lRec.SetRange("Document No.", Rec."No.");
                    POCNLine_lRec.SetRange(Action, POCNLine_lRec.Action::Add);
                    POCNLine_lRec.SetRange("FG Recovery", false);
                    if POCNLine_lRec.FindFirst() then
                        AddNewPrincipleInputItem_lBln := true;


                    POCNLine_lRec.Reset();
                    POCNLine_lRec.SetRange("Document No.", Rec."No.");
                    POCNLine_lRec.SetRange("FG Recovery", true);
                    if POCNLine_lRec.FindFirst() then begin
                        if (ChangeinQtyPer_lBln) OR (AddNewPrincipleInputItem_lBln) then
                            Selection := 2
                        else
                            Selection := StrMenu(Text001, 1, 'Kindly select the action.');
                    end else
                        Selection := 3;


                    case Selection of
                        1:
                            SelectionString_lText := 'Reduce FG Qty &';
                        2:
                            SelectionString_lText := 'Add FG Qty &';
                        3:
                            SelectionString_lText := '';
                    end;

                    if not Confirm('Do you want to %1 Updated Production Quantity', True, SelectionString_lText) then
                        exit;


                    TotalRecoveryQty_lDec := 0;
                    RecoveryLine_lFnc.Reset;
                    RecoveryLine_lFnc.SetRange("Document No.", Rec."No.");
                    if RecoveryLine_lFnc.FindSet then begin
                        repeat
                            if RecoveryLine_lFnc.Recovery then
                                RecoveryLine_lFnc.TestField("Recovery Quantity");

                            if RecoveryLine_lFnc."FG Recovery" then
                                RecoveryLine_lFnc.TestField("FG Recovery Quantity");

                            TotalRecoveryQty_lDec += RecoveryLine_lFnc."Recovery Quantity" + RecoveryLine_lFnc."FG Recovery Quantity";
                        until RecoveryLine_lFnc.Next = 0;
                    end;

                    OriginalProdOrderQty_lDec := Rec."Original Prod Order Qty";

                    ProdOrderChangeNoteLine_lRec.Reset;
                    ProdOrderChangeNoteLine_lRec.SetRange("Document No.", Rec."No.");
                    if ProdOrderChangeNoteLine_lRec.FindSet then begin
                        repeat
                            if (ProdOrderChangeNoteLine_lRec.Action = ProdOrderChangeNoteLine_lRec.Action::" ") and (ProdOrderChangeNoteLine_lRec."Prod. Order Component Line No." <> 0) then
                                ProdOrderChangeNoteLine_lRec.ModifiyComponentLines_gFnc(Selection);
                            // else
                            //     if (Selection = 1) and Not (ProdOrderChangeNoteLine_lRec."FG Recovery" OR ProdOrderChangeNoteLine_lRec.Recovery) then
                            //         ProdOrderChangeNoteLine_lRec.ModifiyComponentLines_gFnc(Selection);
                            if ProdOrderChangeNoteLine_lRec."Principal Input" then
                                TotalPrincipleInputQty_lDec += ProdOrderChangeNoteLine_lRec."New Expected Quantity"; //Line 
                        until ProdOrderChangeNoteLine_lRec.Next = 0;
                    end;

                    if Selection = 1 then
                        TotalPrincipleInputQty_lDec := TotalPrincipleInputQty_lDec - TotalRecoveryQty_lDec;

                    // Rec."Updated Production Quantity" := Rec."Total Raw Material to Consume";
                    // Rec."Total Recovery Qty" := TotalRecoveryQty_lDec;
                    // Rec."Quantity Calculated" := true;
                    // Rec.Modify;


                    ProdOrderChangeNoteLine_lRec.Reset;
                    ProdOrderChangeNoteLine_lRec.SetRange("Document No.", Rec."No.");
                    ProdOrderChangeNoteLine_lRec.SetRange("Principal Input", true);
                    ProdOrderChangeNoteLine_lRec.SetFilter(Action, '%1|%2', ProdOrderChangeNoteLine_lRec.Action::Add, ProdOrderChangeNoteLine_lRec.Action::Modify);
                    if ProdOrderChangeNoteLine_lRec.FindSet then begin
                        repeat
                            CalNewQtyPer_lDec := 0;

                            if ProdOrderChangeNoteLine_lRec.Recovery then begin
                                ProdOrderChangeNoteLine_lRec.TestField("Recovery Quantity");
                                CalNewQtyPer_lDec := ROUND(ProdOrderChangeNoteLine_lRec."Recovery Quantity" / Rec."Original Prod Order Qty", 0.00001, '<');
                                ProdOrderChangeNoteLine_lRec.Validate("New Quantity Per", CalNewQtyPer_lDec);//old
                            end else
                                if ProdOrderChangeNoteLine_lRec."FG Recovery" then begin
                                    ProdOrderChangeNoteLine_lRec.TestField("FG Recovery Quantity");
                                    CalNewQtyPer_lDec := ROUND(ProdOrderChangeNoteLine_lRec."FG Recovery Quantity" / Rec."Original Prod Order Qty", 0.00001, '<');
                                    ProdOrderChangeNoteLine_lRec.Validate("New Quantity Per", CalNewQtyPer_lDec);//old
                                end else begin
                                    If ProdOrderChangeNoteLine_lRec.Action in [ProdOrderChangeNoteLine_lRec.Action::Modify, ProdOrderChangeNoteLine_lRec.Action::Add] then begin
                                        ProdOrderChangeNoteLine_lRec."New Expected Quantity" := ProdOrderChangeNoteLine_lRec."New Quantity Per" * TotalPrincipleInputQty_lDec;
                                    end;
                                    // end else begin
                                    //     ProdOrderChangeNoteLine_lRec.Validate("New Quantity Per", CalNewQtyPer_lDec);//old
                                    //                                                                                  //ProdOrderChangeNoteLine_lRec.Validate("New Quantity Per", ProdOrderChangeNoteLine_lRec."Quantity Per");//
                                    //                                                                                  //ProdOrderChangeNoteLine_lRec."New Expected Quantity" := ProdOrderChangeNoteLine_lRec."Quantity Per" * Rec."Original Prod Order Qty";
                                    // end;
                                end;



                            // if ProdOrderChangeNoteLine_lRec."Quantity Per" = 0 then
                            //     ProdOrderChangeNoteLine_lRec."Quantity Per" := ProdOrderChangeNoteLine_lRec."New Quantity Per";

                            // // ProdOrderChangeNoteLine_lRec."Final Qty. Per" := 0;
                            // // if ProdOrderChangeNoteLine_lRec."Principal Input" then begin
                            // //     PrincipalInput_lBln := ProdOrderChangeNoteLine_lRec."Principal Input";
                            // //     if Rec."Total Raw Material to Consume" <> 0 then begin
                            // //         if ProdOrderChangeNoteLine_lRec."New Expected Quantity" <> 0 then
                            // //             ProdOrderChangeNoteLine_lRec."Final Qty. Per" := ProdOrderChangeNoteLine_lRec."New Expected Quantity" / Rec."Total Raw Material to Consume"
                            // //         else
                            // //             ProdOrderChangeNoteLine_lRec."Final Qty. Per" := ProdOrderChangeNoteLine_lRec."Expected Quantity" / Rec."Total Raw Material to Consume";
                            // //     end;
                            // end;
                            // if PrincipalInput_lBln then
                            //     ProdOrderChangeNoteLine_lRec."Principal Input" := PrincipalInput_lBln;
                            ProdOrderChangeNoteLine_lRec.Modify;

                        until ProdOrderChangeNoteLine_lRec.Next = 0;
                    end;

                    case Selection of
                        1:
                            begin
                                Rec."Prod Qty Change Type" := Rec."Prod Qty Change Type"::Reduced;
                                // Rec."Updated Production Quantity" := Rec."Updated Production Quantity" - TotalRecoveryQty_lDec;
                                Rec."Total Raw Material to Consume" := TotalPrincipleInputQty_lDec;
                            end;
                        2:
                            begin
                                Rec."Prod Qty Change Type" := Rec."Prod Qty Change Type"::Added;
                                Rec."Updated Production Quantity" := Rec."Updated Production Quantity" + TotalRecoveryQty_lDec;
                                Rec."Total Raw Material to Consume" := TotalPrincipleInputQty_lDec - TotalRecoveryQty_lDec;
                            end;
                        3:
                            begin
                                Rec."Updated Production Quantity" := TotalPrincipleInputQty_lDec;
                                Rec."Total Raw Material to Consume" := TotalPrincipleInputQty_lDec;
                            end;
                    end;

                    Rec."Total Recovery Qty" := TotalRecoveryQty_lDec;
                    Rec."Quantity Calculated" := true;
                    Rec.Modify;

                    Message('New Quantity Per updated successfully');
                end;
            }*/

            /*
            action("Update Recovery Details")
            {
                ApplicationArea = All;
                Image = AdjustEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ProdOrderChangeNoteLine_lRec: Record "Prod. Order Change Note Line";
                    RecoveryLine_lFnc: Record "Prod. Order Change Note Line";
                    CalNewQtyPer_lDec: Decimal;
                    TotalRecoveryQty_lDec: Decimal;
                    NewQTy_lDec: Decimal;
                    OringalExpQty_lDec: Decimal;
                    NewQtyAsPerOldQtyPer_lDec: Decimal;
                    Text001: Label 'Reduce FG Qty,Add FG Qty';
                    Selection: Integer;
                    OriginalQty_lRecx: Decimal;
                    SelectionString_lText: Text;
                begin
                    if Rec."Quantity Calculated" then
                        Error('You can not proform this action without making any changes in the lines.');

                    Selection := StrMenu(Text001, 1, 'Kindly select the action.');

                    case Selection of
                        1:
                            SelectionString_lText := 'Reduce FG Qty &';
                        2:
                            SelectionString_lText := 'Add FG Qty &';
                    end;
                    if not Confirm('Do you want to %1 Updated Production Quantity', True, SelectionString_lText) then
                        exit;

                    Rec.TestField("Batch Qty");
                    Rec.TestField("No. of Batches");
                    //IF Rec."Updated Production Quantity" <> Rec."Batch Qty" * Rec."No. of Batches"  then
                    //Rec."Updated Production Quantity" := Rec."Batch Qty" * Rec."No. of Batches";



                    OriginalQty_lRecx := Rec."Updated Production Quantity";

                    TotalRecoveryQty_lDec := 0;
                    RecoveryLine_lFnc.Reset;
                    RecoveryLine_lFnc.SetRange("Document No.", Rec."No.");
                    if RecoveryLine_lFnc.FindSet then begin
                        repeat
                            if RecoveryLine_lFnc.Recovery then
                                RecoveryLine_lFnc.TestField("Recovery Quantity");

                            if RecoveryLine_lFnc."FG Recovery" then
                                RecoveryLine_lFnc.TestField("FG Recovery Quantity");

                            TotalRecoveryQty_lDec += RecoveryLine_lFnc."Recovery Quantity" + RecoveryLine_lFnc."FG Recovery Quantity";
                        until RecoveryLine_lFnc.Next = 0;
                    end;

                    case Selection of
                        1:
                            Rec."Total Raw Material to Consume" := Rec."Updated Production Quantity" - TotalRecoveryQty_lDec;
                        2:
                            Rec."Total Raw Material to Consume" := Rec."Updated Production Quantity" + TotalRecoveryQty_lDec;
                    end;

                    // if Rec."Updated Production Quantity" = Rec."Total Raw Material to Consume" then
                    //     exit;

                    //TotalRecoveryQty_lDec := 0;
                    ProdOrderChangeNoteLine_lRec.Reset;
                    ProdOrderChangeNoteLine_lRec.SetRange("Document No.", Rec."No.");
                    if ProdOrderChangeNoteLine_lRec.FindSet then begin
                        repeat
                            if (ProdOrderChangeNoteLine_lRec.Action = ProdOrderChangeNoteLine_lRec.Action::" ") and (ProdOrderChangeNoteLine_lRec."Prod. Order Component Line No." <> 0) then begin
                                ProdOrderChangeNoteLine_lRec.ModifiyComponentLines_gFnc(Selection);
                            end;
                        // if ProdOrderChangeNoteLine_lRec.Recovery then
                        //     ProdOrderChangeNoteLine_lRec.TestField("Recovery Quantity");

                        // if ProdOrderChangeNoteLine_lRec."FG Recovery" then
                        //     ProdOrderChangeNoteLine_lRec.TestField("FG Recovery Quantity");

                        // TotalRecoveryQty_lDec += ProdOrderChangeNoteLine_lRec."Recovery Quantity" + ProdOrderChangeNoteLine_lRec."FG Recovery Quantity";
                        until ProdOrderChangeNoteLine_lRec.Next = 0;
                    end;

                    // IF TotalRecoveryQty_lDec = 0 THEN
                    //  ERROR('Please enter the recovery quantity in one or more lines');

                    case Selection of
                        1:
                            NewQTy_lDec := Rec."Total Raw Material to Consume";
                        2:
                            NewQTy_lDec := Rec."Updated Production Quantity";
                    end;


                    ProdOrderChangeNoteLine_lRec.Reset;
                    ProdOrderChangeNoteLine_lRec.SetRange("Document No.", Rec."No.");
                    ProdOrderChangeNoteLine_lRec.SetFilter(Action, '%1|%2', ProdOrderChangeNoteLine_lRec.Action::Add, ProdOrderChangeNoteLine_lRec.Action::Modify);
                    if ProdOrderChangeNoteLine_lRec.FindSet then begin
                        repeat
                            CalNewQtyPer_lDec := 0;
                            OringalExpQty_lDec := ROUND(ProdOrderChangeNoteLine_lRec."Quantity Per" * Rec.Quantity, 0.00001);

                            if ProdOrderChangeNoteLine_lRec.Recovery then begin
                                ProdOrderChangeNoteLine_lRec.TestField("Recovery Quantity");
                                CalNewQtyPer_lDec := ROUND(ProdOrderChangeNoteLine_lRec."Recovery Quantity" / OriginalQty_lRecx, 0.00001, '<');
                            end else
                                if ProdOrderChangeNoteLine_lRec."FG Recovery" then begin
                                    ProdOrderChangeNoteLine_lRec.TestField("FG Recovery Quantity");
                                    CalNewQtyPer_lDec := ROUND(ProdOrderChangeNoteLine_lRec."FG Recovery Quantity" / OriginalQty_lRecx, 0.00001, '<');
                                end else begin
                                    NewQtyAsPerOldQtyPer_lDec := ROUND(ProdOrderChangeNoteLine_lRec."Quantity Per" * NewQTy_lDec, 0.00001);
                                    CalNewQtyPer_lDec := ROUND(NewQtyAsPerOldQtyPer_lDec / NewQTy_lDec, 0.00001);
                                end;

                            //IF ProdOrderChangeNoteLine_lRec.Action = ProdOrderChangeNoteLine_lRec.Action::Modify THEN

                            ProdOrderChangeNoteLine_lRec.Validate("New Quantity Per", CalNewQtyPer_lDec);

                            if ProdOrderChangeNoteLine_lRec."Quantity Per" = 0 then
                                ProdOrderChangeNoteLine_lRec."Quantity Per" := ProdOrderChangeNoteLine_lRec."New Quantity Per";
                            //ELSE
                            //  ProdOrderChangeNoteLine_lRec.VALIDATE("Quantity Per",CalNewQtyPer_lDec);

                            ProdOrderChangeNoteLine_lRec.Recovery := ProdOrderChangeNoteLine_lRec.Recovery;
                            ProdOrderChangeNoteLine_lRec."FG Recovery Quantity" := ProdOrderChangeNoteLine_lRec."FG Recovery Quantity";

                            ProdOrderChangeNoteLine_lRec."Final Qty. Per" := 0;
                            if ProdOrderChangeNoteLine_lRec."Principal Input" then begin
                                if Rec."Total Raw Material to Consume" <> 0 then begin
                                    if ProdOrderChangeNoteLine_lRec."New Expected Quantity" <> 0 then
                                        ProdOrderChangeNoteLine_lRec."Final Qty. Per" := ProdOrderChangeNoteLine_lRec."New Expected Quantity" / Rec."Total Raw Material to Consume"
                                    else
                                        ProdOrderChangeNoteLine_lRec."Final Qty. Per" := ProdOrderChangeNoteLine_lRec."Expected Quantity" / Rec."Total Raw Material to Consume"
                                end;
                            end;

                            ProdOrderChangeNoteLine_lRec.Modify;
                        until ProdOrderChangeNoteLine_lRec.Next = 0;
                    end;

                    Rec."Updated Production Quantity" := Rec."Total Raw Material to Consume";
                    Rec."Quantity Calculated" := true;
                    Rec.Modify;

                    Message('New Quantity Per updated successfully');
                end;
            }
            
            */
            // action("Update Production Quantity")
            // {
            //     ApplicationArea = All;
            //     Image = AdjustEntries;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     PromotedIsBig = true;
            //     Visible = false;

            //     trigger OnAction()
            //     var
            //         ProdOrderChangeNoteLine_lRec: record "Prod. Order Change Note Line";
            //         TotalProdOrderQty_lDec: Decimal;
            //     begin
            //         TotalProdOrderQty_lDec := 0;

            //         ProdOrderChangeNoteLine_lRec.Reset();
            //         ProdOrderChangeNoteLine_lRec.SetRange("Document No.", Rec."No.");
            //         if ProdOrderChangeNoteLine_lRec.FindSet() then
            //             repeat
            //                 TotalProdOrderQty_lDec += ProdOrderChangeNoteLine_lRec."New Expected Quantity";
            //             until ProdOrderChangeNoteLine_lRec.Next() = 0;

            //         if Confirm('Do you want to updated the Production order Quantity as %1 ?', true, TotalProdOrderQty_lDec) then begin
            //             Rec."New Prod Order Qty" := TotalProdOrderQty_lDec;
            //             Rec.Modify();
            //         end;
            //     end;
            // }
        }
    }

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

    trigger OnOpenPage()
    var
        ManufacturingSetup_lRec: Record "Manufacturing Setup";
    begin
        ManufacturingSetup_lRec.Get;
        ManufacturingSetup_lRec.TestField("Enable Production Change Note");
    end;
}

