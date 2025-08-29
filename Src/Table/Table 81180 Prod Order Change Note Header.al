Table 81180 "Prod. Order Change Note Header"
{
    // -----------------------------------------------------------------------------------------------------------------------------
    // Intech Systems Pvt. Ltd.
    // -----------------------------------------------------------------------------------------------------------------------------
    // ID                          Date            Author
    // -----------------------------------------------------------------------------------------------------------------------------
    // I-A012_B-1000321-01         30/05/15        Chintan Panchal
    //                             Production Component Change Note Development
    //                             Created New Table
    // -----------------------------------------------------------------------------------------------------------------------------
    Description = 'T12149';

    fields
    {
        field(1; "No."; Code[20])
        {

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    ManufacturingSetup_gRec.Get;
                    NoSeriesMgmt_gCdu.TestManual(ManufacturingSetup_gRec."Prod. Order Change No. Series");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Prod. Order Status"; Option)
        {
            OptionCaption = ' ,Planned,Firm Planned,Released';
            OptionMembers = " ",Planned,"Firm Planned",Released;

            trigger OnValidate()
            begin
                TestField("Change Status", "change status"::Open);
            end;
        }
        field(3; "Prod. Order No."; Code[20])
        {
            TableRelation = if ("Prod. Order Status" = filter(Planned)) "Production Order"."No." where(Status = filter(Planned))
            else
            if ("Prod. Order Status" = filter("Firm Planned")) "Production Order"."No." where(Status = filter("Firm Planned"))
            else
            if ("Prod. Order Status" = filter(Released)) "Production Order"."No." where(Status = filter(Released));

            trigger OnValidate()
            var
                ProdOrderChangeNoteHdr_lRec: Record "Prod. Order Change Note Header";
                ProductionHeader_lRec: Record "Production Order";
            begin
                TestField("Change Status", "change status"::Open);

                if ProdOrderChangeLineExit_gFnc then
                    Error(Text5001_gCtx, "No.");

                if "Prod. Order No." <> xRec."Prod. Order No." then begin
                    if ProductionHeader_lRec.Get("Prod. Order Status", "Prod. Order No.") then begin
                        "Source Type" := ProductionHeader_lRec."Source Type".AsInteger();
                        "Source No." := ProductionHeader_lRec."Source No.";
                        "Source Item Description" := ProductionHeader_lRec.Description;
                        "Location Code" := ProductionHeader_lRec."Location Code";
                        "Batch Qty" := ProductionHeader_lRec."Batch Quantity";
                        "No. of Batches" := ProductionHeader_lRec."No. of Batches";
                        "Updated Production Quantity" := ProductionHeader_lRec.Quantity;   //"Batch Qty" * "No. of Batches";
                        "Original Prod Order Qty" := ProductionHeader_lRec.Quantity;   //"Batch Qty" * "No. of Batches";
                        "Total Raw Material to Consume" := "Updated Production Quantity";
                    end else begin
                        "Source Type" := "source type"::" ";
                        "Source No." := '';
                        "Source Item Description" := '';
                        "Location Code" := '';
                        "Updated Production Quantity" := 0;
                        "Batch Qty" := 0;
                        "No. of Batches" := 0;
                    end;
                end;
            end;
        }
        field(4; "Source Type"; Option)
        {
            Editable = false;
            OptionCaption = 'Item,Family,Sales Header';
            OptionMembers = " ",Item,Family,"Sales Header";

            trigger OnValidate()
            begin
                TestField("Change Status", "change status"::Open);
            end;
        }
        field(5; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Editable = false;

            trigger OnValidate()
            var
                Item: Record Item;
                Family: Record Family;
                SalesHeader: Record "Sales Header";
            begin
            end;
        }
        field(6; "Source Item Description"; Text[100])
        {
            Editable = false;
        }
        field(7; "Location Code"; Code[20])
        {
            Editable = false;
        }
        field(8; "Created By"; Code[50])
        {
            Editable = false;
        }
        field(9; "Created On"; Date)
        {
            Editable = false;
        }
        field(10; Submitted; Boolean)
        {
            Editable = false;
        }
        field(11; "Submitted On"; Date)
        {
            Editable = false;
        }
        field(12; "Prod. Order Line No."; Integer)
        {
            BlankNumbers = BlankZero;
#pragma warning disable
            TableRelation = "Prod. Order Line"."Line No." where(Status = field("Prod. Order Status"),
#pragma warning disable
                                                                 "Prod. Order No." = field("Prod. Order No."));

            trigger OnValidate()
            var
                ProdOrderLine_lRec: Record "Prod. Order Line";
                ProdOrderChangeNoteHdr_lRec: Record "Prod. Order Change Note Header";
            begin
                TestField("Change Status", "change status"::Open);

                if ProdOrderChangeLineExit_gFnc then
                    Error(Text5001_gCtx, "No.");

                if "Prod. Order Line No." <> xRec."Prod. Order Line No." then begin
                    ProdOrderChangeNoteHdr_lRec.Reset;
                    ProdOrderChangeNoteHdr_lRec.SetRange("Prod. Order Status", "Prod. Order Status");
                    ProdOrderChangeNoteHdr_lRec.SetRange("Prod. Order No.", "Prod. Order No.");
                    ProdOrderChangeNoteHdr_lRec.SetRange("Prod. Order Line No.", "Prod. Order Line No.");
                    ProdOrderChangeNoteHdr_lRec.SetFilter("Change Status", '<>%1', ProdOrderChangeNoteHdr_lRec."change status"::Posted);
                    if ProdOrderChangeNoteHdr_lRec.FindFirst then
                        Error(Text5000_gCtx, ProdOrderChangeNoteHdr_lRec."Prod. Order No.", "No.");

                    if ProdOrderLine_lRec.Get("Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.") then begin
                        ProdOrderLine_lRec.CalcFields(ProdOrderLine_lRec."Reserved Quantity");
                        //IF ProdOrderLine_lRec."Reserved Quantity" <> 0 THEN
                        //  ERROR('You cannot select Prod. Order line as reservation entries created for Prod. Order No. %1, Prod. Order Line No. %2',
                        //            "Prod. Order No.","Prod. Order Line No.");

                        "Item No." := ProdOrderLine_lRec."Item No.";
                        Description := ProdOrderLine_lRec.Description;
                        Quantity := ProdOrderLine_lRec.Quantity;
                        "Finished Quantity" := ProdOrderLine_lRec."Finished Quantity";
                    end else begin
                        "Item No." := '';
                        Description := '';
                        Quantity := 0;
                        "Finished Quantity" := 0;
                    end;
                end;
            end;
        }
        field(13; "Item No."; Code[20])
        {
            Editable = false;
        }
        field(14; Description; Text[100])
        {
            Editable = false;
        }
        field(15; Quantity; Decimal)
        {
            Editable = false;
        }
        field(16; "Finished Quantity"; Decimal)
        {
            Editable = false;
        }
        field(17; Approve; Boolean)
        {
            Editable = false;
        }
        field(18; "Approved By"; Code[50])
        {
            Editable = false;
        }
        field(19; "Approved On"; Date)
        {
            Editable = false;
        }
        field(20; Posted; Boolean)
        {
            Editable = false;
        }
        field(21; "Posted On"; Date)
        {
            Editable = false;
        }
        field(22; "Change Status"; Option)
        {
            Editable = false;
            OptionCaption = 'Open,Pending for Approval,Approved,Posted';
            OptionMembers = Open,Submitted,Approved,Posted;
        }
        field(23; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(24; "Submitted By"; Code[50])
        {
            Editable = false;
        }
        field(25; "Posted By"; Code[50])
        {
            Editable = false;
        }
        field(27; "Ref. Prod. Order Change Note"; Code[20])
        {
            Editable = false;
        }
        field(28; "Base Prod. BOM Change Note"; Boolean)
        {

            trigger OnValidate()
            var
                ProdOrderChangeNote_lRec: Record "Prod. Order Change Note Header";
            begin
                TestField("Prod. Order Status", "prod. order status"::"Firm Planned");
                TestField("Prod. Order No.");
                TestField("Prod. Order Line No.");

                if "Base Prod. BOM Change Note" then begin
                    ProdOrderChangeNote_lRec.Reset;
                    ProdOrderChangeNote_lRec.SetRange("No.", '<>%1', "No.");
                    ProdOrderChangeNote_lRec.SetRange("Prod. Order Status", "Prod. Order Status");
                    ProdOrderChangeNote_lRec.SetRange("Prod. Order No.", "Prod. Order No.");
                    ProdOrderChangeNote_lRec.SetRange("Prod. Order Line No.", "Prod. Order Line No.");
                    ProdOrderChangeNote_lRec.SetRange("Base Prod. BOM Change Note", true);
                    if ProdOrderChangeNote_lRec.FindFirst then
                        Error('You can not mark as Base Prod. BOM change note as this Prod. order already mark with Base Prod. BOM change note in Prd. Order Change Note No. %1',
                                  ProdOrderChangeNote_lRec."No.");
                end;
            end;
        }
        field(29; "Change category"; Option)
        {
            OptionCaption = ' ,From Customer Side,From Our Side';
            OptionMembers = " ","From Customer Side","From Our Side";
        }
        field(50; "Updated Production Quantity"; Decimal)
        {
            BlankZero = true;
            DataClassification = ToBeClassified;
            Description = 'T10146';
            Editable = false;
            MinValue = 0;
        }
        field(51; "Total Raw Material to Consume"; Decimal)
        {
            BlankZero = true;
            DataClassification = ToBeClassified;
            Description = 'T10146';
            Editable = false;
            MinValue = 0;
        }
        field(53; "Batch Qty"; Decimal)
        {
            BlankZero = true;
            DataClassification = ToBeClassified;
            Description = 'T02065,T10146';
            Editable = false;
        }
        field(54; "No. of Batches"; Integer)
        {
            BlankZero = true;
            DataClassification = ToBeClassified;
            Description = 'T02065,T10146';
            Editable = false;
        }
        field(55; "Total Recovery Qty"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 2 : 5;
            Description = 'T12149';
            Editable = false;
        }

        field(56; "Quantity Calculated"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'T12149';
            Editable = false;
        }
        field(57; "Prod Qty Change Type"; Option)
        {
            OptionMembers = " ",Added,Reduced;
            OptionCaption = ' ,Added,Reduced';
            Editable = false;
        }
        field(58; "Original Prod Order Qty"; Decimal)
        {
            Editable = false;
            Description = 'T12149';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ProdOrderChangeNoteLines_lRec: Record "Prod. Order Change Note Line";
    begin
        TestField("Change Status", "change status"::Open);

        ProdOrderChangeNoteLines_lRec.Reset;
        ProdOrderChangeNoteLines_lRec.SetRange("Document No.", "No.");
        if ProdOrderChangeNoteLines_lRec.FindSet then
            ProdOrderChangeNoteLines_lRec.DeleteAll;
    end;

    trigger OnInsert()
    begin
        ManufacturingSetup_gRec.Get;
        if "No." = '' then begin
            ManufacturingSetup_gRec.TestField("Prod. Order Change No. Series");
            NoSeriesMgmt_gCdu.InitSeries(ManufacturingSetup_gRec."Prod. Order Change No. Series",
                                          xRec."No. Series", Today, "No.", "No. Series");
        end;

        "Created By" := UserId;
        "Created On" := Today;
    end;

    trigger OnModify()
    begin
        TestField("Change Status", "change status"::Open);
    end;

    var
        Text5000_gCtx: label 'You can not select %1 Production Order because there is already unposted document %1 for this Production order.';
        PrdoOrderChangeNoteHeader_gRec: Record "Prod. Order Change Note Header";
        ManufacturingSetup_gRec: Record "Manufacturing Setup";
        NoSeriesMgmt_gCdu: Codeunit NoSeriesManagement;
        Text5001_gCtx: label 'Prod. Order change Note Line Exits for Document : %1';
        Text50010_gCtx: label 'Updating Data...\';
        Text50011_gCtx: label 'Creation Change Note Count #1##########\';
        WindowDialog_gDlg: Dialog;
        CurrentRecord_gInt: Integer;
        CreationCount_gInt: Integer;
        LineNo_gInt: Integer;


    procedure AssitEdit_gFnc(OldProdOrderChangeNoteHdr_iRec: Record "Prod. Order Change Note Header"): Boolean
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        PrdoOrderChangeNoteHeader_gRec := Rec;
        ManufacturingSetup_gRec.Get;
        ManufacturingSetup_gRec.TestField("Prod. Order Change No. Series");
        if NoSeriesMgmt_gCdu.SelectSeries(ManufacturingSetup_gRec."Prod. Order Change No. Series",
                                          OldProdOrderChangeNoteHdr_iRec."No. Series", PrdoOrderChangeNoteHeader_gRec."No. Series") then begin
            NoSeriesMgmt_gCdu.SetSeries(PrdoOrderChangeNoteHeader_gRec."No.");
            Rec := PrdoOrderChangeNoteHeader_gRec;
            exit(true);
        end;
    end;


    procedure InsertProdOrderCompLines_gFnc(ProdOrderChangeNoteHdr_iRec: Record "Prod. Order Change Note Header"; CallFromMultipleProdOrder_iBln: Boolean)
    var
        ProdOrderCompLines_lRec: Record "Prod. Order Component";
        ProdOrderChangeNoteLines_lRec: Record "Prod. Order Change Note Line";
        LineNo_lInt: Integer;
        Text5000_lCtx: label 'Are you sure to insert Prod. Order component lines?';
        ProdOrderChangeNoteLine1_lRec: Record "Prod. Order Change Note Line";
        Text5001_lCtx: label 'Prod. Order component line already exists. \Do you want delete all Prod. order component lines and insert again?';
        ProdOrderComponentArchive_lRec: Record "Prod. Order Component Archive";
        TotalRecoveryQty_lDec: Decimal;
        RecoveryLine_lFnc: Record "Prod. Order Change Note Line";
    begin
        ProdOrderChangeNoteHdr_iRec.TestField("Change Status", ProdOrderChangeNoteHdr_iRec."change status"::Open);


        if ProdOrderChangeNoteHdr_iRec.ProdOrderChangeLineExit_gFnc then begin
            if not Confirm(Text5001_lCtx) then
                exit
            else begin
                ProdOrderChangeNoteLine1_lRec.Reset;
                ProdOrderChangeNoteLine1_lRec.SetRange("Document No.", ProdOrderChangeNoteHdr_iRec."No.");
                ProdOrderChangeNoteLine1_lRec.DeleteAll;
            end;
        end else begin
            if not CallFromMultipleProdOrder_iBln then begin
                if not Confirm(Text5000_lCtx) then
                    exit;
            end;
        end;

        ProdOrderChangeNoteHdr_iRec.TestField("Prod. Order Status");
        ProdOrderChangeNoteHdr_iRec.TestField("Prod. Order No.");
        ProdOrderChangeNoteHdr_iRec.TestField("Prod. Order Line No.");
        ProdOrderChangeNoteHdr_iRec.TestField("Source No.");

        LineNo_lInt := 10000;
        ProdOrderCompLines_lRec.Reset;
        ProdOrderCompLines_lRec.SetRange(Status, ProdOrderChangeNoteHdr_iRec."Prod. Order Status");
        ProdOrderCompLines_lRec.SetRange("Prod. Order No.", ProdOrderChangeNoteHdr_iRec."Prod. Order No.");
        ProdOrderCompLines_lRec.SetRange("Prod. Order Line No.", ProdOrderChangeNoteHdr_iRec."Prod. Order Line No.");
        if ProdOrderCompLines_lRec.FindSet then begin
            repeat
                ProdOrderChangeNoteLines_lRec.Init;
                ProdOrderChangeNoteLines_lRec."Document No." := ProdOrderChangeNoteHdr_iRec."No.";
                ProdOrderChangeNoteLines_lRec."Line No." := LineNo_lInt;
                ProdOrderChangeNoteLines_lRec."Prod. Order Status" := ProdOrderChangeNoteHdr_iRec."Prod. Order Status";
                ProdOrderChangeNoteLines_lRec."Prod. Order No." := ProdOrderChangeNoteHdr_iRec."Prod. Order No.";
                ProdOrderChangeNoteLines_lRec."Prod. Order Line No." := ProdOrderChangeNoteHdr_iRec."Prod. Order Line No.";
                ProdOrderChangeNoteLines_lRec."Prod. Order Component Line No." := ProdOrderCompLines_lRec."Line No.";
                ProdOrderChangeNoteLines_lRec."Item No." := ProdOrderCompLines_lRec."Item No.";
                ProdOrderChangeNoteLines_lRec."Item Description" := ProdOrderCompLines_lRec.Description;
                ProdOrderChangeNoteLines_lRec."Quantity Per" := ProdOrderCompLines_lRec."Quantity per";
                ProdOrderChangeNoteLines_lRec."Unit of Measure Code" := ProdOrderCompLines_lRec."Unit of Measure Code";
                ProdOrderChangeNoteLines_lRec."Expected Quantity" := ProdOrderCompLines_lRec."Expected Quantity";
                ProdOrderChangeNoteLines_lRec."Remaining Quantity" := ProdOrderCompLines_lRec."Remaining Quantity";
                ProdOrderChangeNoteLines_lRec."Location Code" := ProdOrderChangeNoteHdr_iRec."Location Code";
                ProdOrderChangeNoteLines_lRec."Calculation Formula" := ProdOrderCompLines_lRec."Calculation Formula".AsInteger();
                ProdOrderChangeNoteLines_lRec.Quantity := ProdOrderCompLines_lRec.Quantity;
                ProdOrderChangeNoteLines_lRec.Length := ProdOrderCompLines_lRec.Length;
                ProdOrderChangeNoteLines_lRec.Width := ProdOrderCompLines_lRec.Width;
                ProdOrderChangeNoteLines_lRec.Weight := ProdOrderCompLines_lRec.Weight;
                ProdOrderChangeNoteLines_lRec.Depth := ProdOrderCompLines_lRec.Depth;
                ProdOrderChangeNoteLines_lRec."Quantity (Base)" := ProdOrderCompLines_lRec."Quantity (Base)";
                ProdOrderChangeNoteLines_lRec."Qty. per Unit of Measure" := ProdOrderCompLines_lRec."Qty. per Unit of Measure";
                ProdOrderChangeNoteLines_lRec."Routing Link Code" := ProdOrderCompLines_lRec."Routing Link Code";
                ProdOrderChangeNoteLines_lRec."Scrap %" := ProdOrderCompLines_lRec."Scrap %";
                ProdOrderChangeNoteLines_lRec."Expected Qty. (Base)" := ProdOrderCompLines_lRec."Expected Qty. (Base)";
                ProdOrderChangeNoteLines_lRec."Remaining Qty. (Base)" := ProdOrderCompLines_lRec."Remaining Qty. (Base)";
                ProdOrderChangeNoteLines_lRec."Completely Picked" := ProdOrderCompLines_lRec."Completely Picked";
                ProdOrderChangeNoteLines_lRec."Qty. Picked" := ProdOrderCompLines_lRec."Qty. Picked";
                ProdOrderChangeNoteLines_lRec."Cost Amount" := ProdOrderCompLines_lRec."Cost Amount";
                ProdOrderChangeNoteLines_lRec."Unit Cost" := ProdOrderCompLines_lRec."Unit Cost";
                ProdOrderChangeNoteLines_lRec."Direct Cost Amount" := ProdOrderCompLines_lRec."Direct Cost Amount";
                ProdOrderChangeNoteLines_lRec."Overhead Amount" := ProdOrderCompLines_lRec."Overhead Amount";
                ProdOrderChangeNoteLines_lRec."Direct Unit Cost" := ProdOrderCompLines_lRec."Direct Unit Cost";
                ProdOrderChangeNoteLines_lRec."Indirect Cost %" := ProdOrderCompLines_lRec."Indirect Cost %";
                ProdOrderChangeNoteLines_lRec."Overhead Rate" := ProdOrderCompLines_lRec."Overhead Rate";
                ProdOrderChangeNoteLines_lRec."Principal Input" := ProdOrderCompLines_lRec."Principal Input";
                ProdOrderChangeNoteLines_lRec."Variant Code" := ProdOrderCompLines_lRec."Variant Code";
                ProdOrderChangeNoteLines_lRec."Due Date" := ProdOrderCompLines_lRec."Due Date";
                ProdOrderChangeNoteLines_lRec."Original Item No." := ProdOrderCompLines_lRec."Original Item No.";
                ProdOrderChangeNoteLines_lRec."Original Variant Code" := ProdOrderCompLines_lRec."Original Variant Code";
                ProdOrderChangeNoteLines_lRec."FG Recovery" := ProdOrderCompLines_lRec."FG Recovery";
                ProdOrderChangeNoteLines_lRec.Recovery := ProdOrderCompLines_lRec.Recovery;
                if ProdOrderCompLines_lRec.Recovery then
                    ProdOrderChangeNoteLines_lRec."Recovery Quantity" := ProdOrderCompLines_lRec."Expected Quantity";

                if ProdOrderCompLines_lRec."FG Recovery" then
                    ProdOrderChangeNoteLines_lRec."FG Recovery Quantity" := ProdOrderCompLines_lRec."Expected Quantity";
                //ProdOrderChangeNoteLines_lRec."Force Close By" := ProdOrderCompLines_lRec."Force Close By";

                ProdOrderChangeNoteLines_lRec.Insert;

                //Insert Prod. Component Archive Lines
                ProdOrderComponentArchive_lRec.Init;
                ProdOrderComponentArchive_lRec.TransferFields(ProdOrderCompLines_lRec);
                ProdOrderComponentArchive_lRec.Status := ProdOrderCompLines_lRec.Status;
                ProdOrderComponentArchive_lRec."Prod. Order No." := ProdOrderCompLines_lRec."Prod. Order No.";
                ProdOrderComponentArchive_lRec."Prod. Order Line No." := ProdOrderCompLines_lRec."Prod. Order Line No.";
                ProdOrderComponentArchive_lRec."Line No." := ProdOrderCompLines_lRec."Line No.";
                ProdOrderComponentArchive_lRec."Change Note Document No." := ProdOrderChangeNoteLines_lRec."Document No.";
                ProdOrderComponentArchive_lRec.Insert(true);

                LineNo_lInt := LineNo_lInt + 10000;
            until ProdOrderCompLines_lRec.Next = 0;
        end;

        ProdOrderChangeNoteHdr_iRec.TestField("Batch Qty");
        ProdOrderChangeNoteHdr_iRec.TestField("No. of Batches");
        //ProdOrderChangeNoteHdr_iRec."Updated Production Quantity" := ProdOrderChangeNoteHdr_iRec."Batch Qty" * ProdOrderChangeNoteHdr_iRec."No. of Batches";

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
        //ProdOrderChangeNoteHdr_iRec."Total Raw Material to Consume" := ProdOrderChangeNoteHdr_iRec."Updated Production Quantity" - TotalRecoveryQty_lDec;
        // ProdOrderChangeNoteHdr_iRec.Modify;

        RecoveryLine_lFnc.Reset;
        RecoveryLine_lFnc.SetRange("Document No.", Rec."No.");
        RecoveryLine_lFnc.SetRange("Principal Input", true);
        if RecoveryLine_lFnc.FindSet then begin
            repeat
                RecoveryLine_lFnc."Final Qty. Per" := 0;
                if ProdOrderChangeNoteHdr_iRec."Total Raw Material to Consume" <> 0 then begin
                    if RecoveryLine_lFnc."New Expected Quantity" <> 0 then
                        RecoveryLine_lFnc."Final Qty. Per" := RecoveryLine_lFnc."New Expected Quantity" / ProdOrderChangeNoteHdr_iRec."Total Raw Material to Consume"
                    else
                        RecoveryLine_lFnc."Final Qty. Per" := RecoveryLine_lFnc."Expected Quantity" / ProdOrderChangeNoteHdr_iRec."Total Raw Material to Consume";

                    RecoveryLine_lFnc.Modify;
                end;
            until RecoveryLine_lFnc.Next = 0;
        end;
    end;


    procedure ReOpenDocument_gFnc()
    begin
        if ("Change Status" = "change status"::Open) or ("Change Status" = "change status"::Posted) then
            exit;

        if not Confirm('Do you want to Reopen prod. order change note %1', true, "No.") then
            exit;

        "Change Status" := "change status"::Open;
        Submitted := false;
        "Submitted By" := '';
        "Submitted On" := 0D;
        Approve := false;
        "Approved By" := '';
        "Approved On" := 0D;

        Modify;
    end;


    procedure SubmitDocument_gFnc()
    var
        ProdOrderChangeNoteLines_lRec: Record "Prod. Order Change Note Line";
        Text5000_lCtx: label 'There is no component lines for submit document %1';
    begin
        TestField("Base Prod. BOM Change Note", false);

        if not ProdOrderChangeLineExit_gFnc then
            Error(Text5000_lCtx, "No.");

        TestField("Change Status", "change status"::Open);

        if not Confirm('Do you want to submit prod. order change note %1', true, "No.") then
            exit;

        Submitted := true;
        "Submitted By" := UserId;
        "Submitted On" := Today;
        "Change Status" := "change status"::Submitted;
        Modify;
    end;


    procedure ApproveDocument_gFnc()
    var
        ProdOrderChangeNoteLines_lRec: Record "Prod. Order Change Note Line";
        Text5000_lCtx: label 'There is no component lines for Approve document %1';
        UserSetup_lRec: Record "User Setup";
    begin
        UserSetup_lRec.Get(UserId);
        UserSetup_lRec.TestField("Allow Prod Ord. Change Approve");

        if not ProdOrderChangeLineExit_gFnc then
            Error(Text5000_lCtx, "No.");

        TestField("Change Status", "change status"::Submitted);

        if not Confirm('Do you want to Approve prod. order change note %1', true, "No.") then
            exit;

        Approve := true;
        "Approved By" := UserId;
        "Approved On" := Today;
        "Change Status" := "change status"::Approved;
        Modify;
    end;


    procedure PostDocument_gFnc()
    var
        Text5000_lCtx: label 'There is no component lines for post document No. : %1';
        ProdOrderChangeNoteLines_lRec: Record "Prod. Order Change Note Line";
        POCNLines_lRec: Record "Prod. Order Change Note Line";
        ProdOrderCompLines_lRec: Record "Prod. Order Component";
        LineNo_lInt: Integer;
        InsertProdOrderCompLines_lRec: Record "Prod. Order Component";
        DeleteProdOrderCompLines_lRec: Record "Prod. Order Component";
        ModifyProdOrderCompLines_lRec: Record "Prod. Order Component";
        UserSetup_lRec: Record "User Setup";
        ProdOrderChangeNoteLinesForNegConsumption_lRec: Record "Prod. Order Change Note Line";
        Text5001_lCtx: label 'You cannot Post Prod. order component change note %1 as Prod Order change note Component line %2 has more Act. consumption qty. %3 compared to new expexted qty. %4. Please post negative consumption first.';
        ProdOrderComponentLineComment_lRec: Record "Prod. Order Comp. Cmt Line";
        ProdOrderComponentChangeNoteLineComment_lRec: Record "Prod. Order Comp. change Cmt";
        ProdOrderComponentLineCommentExsit_lRec: Record "Prod. Order Comp. Cmt Line";
        ProdOrderComponentLineCommentExsitDelete_lRec: Record "Prod. Order Comp. Cmt Line";
        InsertProdOrderComponentLineComment_lRec: Record "Prod. Order Comp. Cmt Line";
        NewLineNo_lInt: Integer;
        ProductionOrder_lRec: Record "Production Order";
        ProdOrderLine_lRec: Record "Prod. Order Line";
    begin
        UserSetup_lRec.Get(UserId);
        UserSetup_lRec.TestField("Allow Prod Ord. Change Post");

        TestField("Change Status", "change status"::Approved);

        ProdOrderChangeNoteLinesForNegConsumption_lRec.Reset;
        ProdOrderChangeNoteLinesForNegConsumption_lRec.SetRange("Document No.", "No.");
        ProdOrderChangeNoteLinesForNegConsumption_lRec.SetRange(Action, ProdOrderChangeNoteLinesForNegConsumption_lRec.Action::Modify);
        if ProdOrderChangeNoteLinesForNegConsumption_lRec.FindSet then begin
            repeat
                ProdOrderChangeNoteLinesForNegConsumption_lRec.CalcFields("Act. Consumption (Qty)");
                if ProdOrderChangeNoteLinesForNegConsumption_lRec."Act. Consumption (Qty)" > ProdOrderChangeNoteLinesForNegConsumption_lRec."New Expected Quantity" then
                    Error(Text5001_lCtx, ProdOrderChangeNoteLinesForNegConsumption_lRec."Document No.", ProdOrderChangeNoteLinesForNegConsumption_lRec."Line No.",
                            ProdOrderChangeNoteLinesForNegConsumption_lRec."Act. Consumption (Qty)", ProdOrderChangeNoteLinesForNegConsumption_lRec."New Expected Quantity");
            until ProdOrderChangeNoteLinesForNegConsumption_lRec.Next = 0;
        end;

        if not Confirm('Do you want to post prod. order change note %1', true, "No.") then
            exit;

        //T10146-NS
        if (Quantity <> "Updated Production Quantity") and ("Updated Production Quantity" > 0) then begin
            if "Prod. Order Line No." = 10000 then begin
                ProductionOrder_lRec.Get("Prod. Order Status", "Prod. Order No.");
                ProductionOrder_lRec.Validate(Quantity, "Updated Production Quantity");
                ProductionOrder_lRec.Modify;
            end;

            ProdOrderLine_lRec.Get("Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.");
            ProdOrderLine_lRec.Validate(Quantity, "Updated Production Quantity");
            ProdOrderLine_lRec.Validate("Ending Time");
            ProdOrderLine_lRec.Modify;
        end;
        //T10146-NS


        ProdOrderChangeNoteLines_lRec.Reset;
        ProdOrderChangeNoteLines_lRec.SetRange("Document No.", "No.");
        ProdOrderChangeNoteLines_lRec.SetRange(Action, ProdOrderChangeNoteLines_lRec.Action::" ");
        if ProdOrderChangeNoteLines_lRec.FindSet then begin
            if Rec."Prod Qty Change Type" = Rec."Prod Qty Change Type"::Added then begin
                repeat
                    if ModifyProdOrderCompLines_lRec.Get(ProdOrderChangeNoteLines_lRec."Prod. Order Status",
                                                                      ProdOrderChangeNoteLines_lRec."Prod. Order No.",
                                                                      ProdOrderChangeNoteLines_lRec."Prod. Order Line No.",
                                                                      ProdOrderChangeNoteLines_lRec."Prod. Order Component Line No.") then begin
                        ModifyProdOrderCompLines_lRec.Validate("Expected Quantity", ProdOrderChangeNoteLines_lRec."New Expected Quantity");
                        ModifyProdOrderCompLines_lRec.Modify(true);
                    end;
                until ProdOrderChangeNoteLines_lRec.Next = 0;
            end else begin
                POCNLines_lRec.Reset();
                POCNLines_lRec.SetRange("Document No.", Rec."No.");
                POCNLines_lRec.SetFilter(Action, '<>%1', POCNLines_lRec.Action::" ");
                if not POCNLines_lRec.FindFirst() then
                    Error(Text5000_lCtx, "No.")
            end;
        end;

        LineNo_gInt := 10000;
        ProdOrderChangeNoteLines_lRec.SetRange(Action);
        ProdOrderChangeNoteLines_lRec.SetRange(Action, ProdOrderChangeNoteLines_lRec.Action::Add);
        if ProdOrderChangeNoteLines_lRec.FindSet then begin
            repeat
                ProdOrderCompLines_lRec.Reset;
                ProdOrderCompLines_lRec.SetRange(Status, "Prod. Order Status");
                ProdOrderCompLines_lRec.SetRange("Prod. Order No.", "Prod. Order No.");
                ProdOrderCompLines_lRec.SetRange("Prod. Order Line No.", "Prod. Order Line No.");
                if ProdOrderCompLines_lRec.FindLast then
                    NewLineNo_lInt := ProdOrderCompLines_lRec."Line No." + 10000
                else
                    NewLineNo_lInt := 10000;

                InsertProdOrderCompLines_lRec.Init;
                InsertProdOrderCompLines_lRec.Validate(Status, ProdOrderChangeNoteLines_lRec."Prod. Order Status");
                InsertProdOrderCompLines_lRec.Validate("Prod. Order No.", ProdOrderChangeNoteLines_lRec."Prod. Order No.");
                InsertProdOrderCompLines_lRec.Validate("Prod. Order Line No.", ProdOrderChangeNoteLines_lRec."Prod. Order Line No.");
                InsertProdOrderCompLines_lRec."Line No." := NewLineNo_lInt;
                InsertProdOrderCompLines_lRec.Validate("Item No.", ProdOrderChangeNoteLines_lRec."Item No.");
                if ProdOrderChangeNoteLines_lRec."Variant Code" <> '' then
                    InsertProdOrderCompLines_lRec.Validate("Variant Code", ProdOrderChangeNoteLines_lRec."Variant Code");

                //InsertProdOrderCompLines_lRec.VALIDATE(Description,ProdOrderChangeNoteLines_lRec."Item Description");
                InsertProdOrderCompLines_lRec.Validate("Quantity per", ProdOrderChangeNoteLines_lRec."New Quantity Per");
                //InsertProdOrderCompLines_lRec.VALIDATE("Unit of Measure Code",ProdOrderChangeNoteLines_lRec."Unit of Measure Code");                
                InsertProdOrderCompLines_lRec.Validate("Expected Quantity", ProdOrderChangeNoteLines_lRec."New Expected Quantity");
                //InsertProdOrderCompLines_lRec.Validate("Expected Quantity", ProdOrderChangeNoteLines_lRec."New Expected Quantity");
                //InsertProdOrderCompLines_lRec.VALIDATE("Remaining Quantity",ProdOrderChangeNoteLines_lRec."Remaining Quantity");
                InsertProdOrderCompLines_lRec.Validate("Location Code", ProdOrderChangeNoteLines_lRec."Location Code");
                InsertProdOrderCompLines_lRec.Validate("Principal Input", ProdOrderChangeNoteLines_lRec."Principal Input");
                InsertProdOrderCompLines_lRec.Recovery := ProdOrderChangeNoteLines_lRec.Recovery;
                InsertProdOrderCompLines_lRec."FG Recovery" := ProdOrderChangeNoteLines_lRec."FG Recovery";
                InsertProdOrderCompLines_lRec.Insert(true);

                ProdOrderComponentChangeNoteLineComment_lRec.Reset;
                ProdOrderComponentChangeNoteLineComment_lRec.SetRange(Status, ProdOrderChangeNoteLines_lRec."Prod. Order Status");
                ProdOrderComponentChangeNoteLineComment_lRec.SetRange("Prod. Order No.", ProdOrderChangeNoteLines_lRec."Prod. Order No.");
                ProdOrderComponentChangeNoteLineComment_lRec.SetRange("Prod. Order Line No.", ProdOrderChangeNoteLines_lRec."Prod. Order Line No.");
                ProdOrderComponentChangeNoteLineComment_lRec.SetRange("Prod. Order Component Line No.", ProdOrderChangeNoteLines_lRec."Prod. Order Component Line No.");
                ProdOrderComponentChangeNoteLineComment_lRec.SetRange("Prod. Order Change Note No.", ProdOrderChangeNoteLines_lRec."Document No.");
                if ProdOrderComponentChangeNoteLineComment_lRec.FindSet then begin
                    repeat
                        InsertProdOrderComponentLineComment_lRec.Init;
                        InsertProdOrderComponentLineComment_lRec.Status := ProdOrderComponentChangeNoteLineComment_lRec.Status;
                        InsertProdOrderComponentLineComment_lRec."Prod. Order No." := ProdOrderComponentChangeNoteLineComment_lRec."Prod. Order No.";
                        InsertProdOrderComponentLineComment_lRec."Prod. Order Line No." := ProdOrderComponentChangeNoteLineComment_lRec."Prod. Order Line No.";
                        InsertProdOrderComponentLineComment_lRec."Prod. Order BOM Line No." := ProdOrderComponentChangeNoteLineComment_lRec."Prod. Order Component Line No.";
                        InsertProdOrderComponentLineComment_lRec."Line No." := LineNo_gInt;
                        InsertProdOrderComponentLineComment_lRec.Comment := ProdOrderComponentChangeNoteLineComment_lRec.Comment;
                        InsertProdOrderComponentLineComment_lRec.Date := ProdOrderComponentChangeNoteLineComment_lRec.Date;
                        InsertProdOrderComponentLineComment_lRec.Code := ProdOrderComponentChangeNoteLineComment_lRec.Code;
                        InsertProdOrderComponentLineComment_lRec.Insert;
                        LineNo_gInt := LineNo_gInt + 10000;
                    until ProdOrderComponentChangeNoteLineComment_lRec.Next = 0;
                end;
            until ProdOrderChangeNoteLines_lRec.Next = 0;
        end;

        ProdOrderChangeNoteLines_lRec.SetRange(Action);
        ProdOrderChangeNoteLines_lRec.SetRange(Action, ProdOrderChangeNoteLines_lRec.Action::Modify);
        if ProdOrderChangeNoteLines_lRec.FindSet then begin
            repeat


                if ModifyProdOrderCompLines_lRec.Get(ProdOrderChangeNoteLines_lRec."Prod. Order Status",
                                                  ProdOrderChangeNoteLines_lRec."Prod. Order No.",
                                                  ProdOrderChangeNoteLines_lRec."Prod. Order Line No.",
                                                  ProdOrderChangeNoteLines_lRec."Prod. Order Component Line No.") then begin

                    if (ProdOrderChangeNoteLines_lRec."Item No." <> ModifyProdOrderCompLines_lRec."Item No.") then
                        ModifyProdOrderCompLines_lRec.Validate("Item No.", ProdOrderChangeNoteLines_lRec."Item No.");

                    if (ProdOrderChangeNoteLines_lRec."Variant Code" <> ModifyProdOrderCompLines_lRec."Variant Code") then
                        ModifyProdOrderCompLines_lRec.Validate("Variant Code", ProdOrderChangeNoteLines_lRec."Variant Code");

                    IF ProdOrderChangeNoteLines_lRec."Make New Qty Per Zero" then
                        ModifyProdOrderCompLines_lRec.Validate("Quantity per", 0)
                    ELSE
                        ModifyProdOrderCompLines_lRec.Validate("Quantity per", ProdOrderChangeNoteLines_lRec."New Quantity Per");
                    ModifyProdOrderCompLines_lRec.Validate("Expected Quantity", ProdOrderChangeNoteLines_lRec."New Expected Quantity");

                    if ProdOrderChangeNoteLines_lRec."Principal Input" then
                        ModifyProdOrderCompLines_lRec."Principal Input" := ProdOrderChangeNoteLines_lRec."Principal Input";

                    ModifyProdOrderCompLines_lRec.Recovery := ProdOrderChangeNoteLines_lRec.Recovery;
                    ModifyProdOrderCompLines_lRec."FG Recovery" := ProdOrderChangeNoteLines_lRec."FG Recovery";
                    ModifyProdOrderCompLines_lRec.Modify(true);

                    ProdOrderComponentLineCommentExsit_lRec.Reset;
                    ProdOrderComponentLineCommentExsit_lRec.SetRange(Status, ModifyProdOrderCompLines_lRec.Status);
                    ProdOrderComponentLineCommentExsit_lRec.SetRange("Prod. Order No.", ModifyProdOrderCompLines_lRec."Prod. Order No.");
                    ProdOrderComponentLineCommentExsit_lRec.SetRange("Prod. Order Line No.", ModifyProdOrderCompLines_lRec."Prod. Order Line No.");
                    ProdOrderComponentLineCommentExsit_lRec.SetRange("Prod. Order BOM Line No.", ModifyProdOrderCompLines_lRec."Line No.");
                    if ProdOrderComponentLineCommentExsit_lRec.FindLast then
                        LineNo_gInt := ProdOrderComponentLineCommentExsit_lRec."Line No." + 10000
                    else
                        LineNo_gInt := 10000;

                    ProdOrderComponentChangeNoteLineComment_lRec.Reset;
                    ProdOrderComponentChangeNoteLineComment_lRec.SetRange(Status, ProdOrderChangeNoteLines_lRec."Prod. Order Status");
                    ProdOrderComponentChangeNoteLineComment_lRec.SetRange("Prod. Order No.", ProdOrderChangeNoteLines_lRec."Prod. Order No.");
                    ProdOrderComponentChangeNoteLineComment_lRec.SetRange("Prod. Order Line No.", ProdOrderChangeNoteLines_lRec."Prod. Order Line No.");
                    ProdOrderComponentChangeNoteLineComment_lRec.SetRange("Prod. Order Component Line No.", ProdOrderChangeNoteLines_lRec."Prod. Order Component Line No.");
                    ProdOrderComponentChangeNoteLineComment_lRec.SetRange("Prod. Order Change Note No.", ProdOrderChangeNoteLines_lRec."Document No.");
                    if ProdOrderComponentChangeNoteLineComment_lRec.FindSet then begin
                        repeat
                            InsertProdOrderComponentLineComment_lRec.Init;
                            InsertProdOrderComponentLineComment_lRec.Status := ProdOrderComponentChangeNoteLineComment_lRec.Status;
                            InsertProdOrderComponentLineComment_lRec."Prod. Order No." := ProdOrderComponentChangeNoteLineComment_lRec."Prod. Order No.";
                            InsertProdOrderComponentLineComment_lRec."Prod. Order Line No." := ProdOrderComponentChangeNoteLineComment_lRec."Prod. Order Line No.";
                            InsertProdOrderComponentLineComment_lRec."Prod. Order BOM Line No." := ProdOrderComponentChangeNoteLineComment_lRec."Prod. Order Component Line No.";
                            InsertProdOrderComponentLineComment_lRec."Line No." := LineNo_gInt;
                            InsertProdOrderComponentLineComment_lRec.Comment := ProdOrderComponentChangeNoteLineComment_lRec.Comment;
                            InsertProdOrderComponentLineComment_lRec.Date := ProdOrderComponentChangeNoteLineComment_lRec.Date;
                            InsertProdOrderComponentLineComment_lRec.Code := ProdOrderComponentChangeNoteLineComment_lRec.Code;
                            InsertProdOrderComponentLineComment_lRec.Insert;
                            LineNo_gInt := LineNo_gInt + 10000;
                        until ProdOrderComponentChangeNoteLineComment_lRec.Next = 0;
                    end;

                end;
            until ProdOrderChangeNoteLines_lRec.Next = 0;
        end;

        ProdOrderChangeNoteLines_lRec.SetRange(Action);
        ProdOrderChangeNoteLines_lRec.SetRange(Action, ProdOrderChangeNoteLines_lRec.Action::Delete);
        if ProdOrderChangeNoteLines_lRec.FindSet then begin
            repeat
                if DeleteProdOrderCompLines_lRec.Get(ProdOrderChangeNoteLines_lRec."Prod. Order Status",
                                                  ProdOrderChangeNoteLines_lRec."Prod. Order No.",
                                                  ProdOrderChangeNoteLines_lRec."Prod. Order Line No.",
                                                  ProdOrderChangeNoteLines_lRec."Prod. Order Component Line No.") then
                    DeleteProdOrderCompLines_lRec.Delete(true);

                ProdOrderComponentLineCommentExsitDelete_lRec.Reset;
                ProdOrderComponentLineCommentExsitDelete_lRec.SetRange(Status, DeleteProdOrderCompLines_lRec.Status);
                ProdOrderComponentLineCommentExsitDelete_lRec.SetRange("Prod. Order No.", DeleteProdOrderCompLines_lRec."Prod. Order No.");
                ProdOrderComponentLineCommentExsitDelete_lRec.SetRange("Prod. Order Line No.", DeleteProdOrderCompLines_lRec."Prod. Order Line No.");
                ProdOrderComponentLineCommentExsitDelete_lRec.SetRange("Prod. Order BOM Line No.", DeleteProdOrderCompLines_lRec."Line No.");
                ProdOrderComponentLineCommentExsitDelete_lRec.DeleteAll(true);

            until ProdOrderChangeNoteLines_lRec.Next = 0;
        end;

        "Change Status" := "change status"::Posted;
        Posted := true;
        "Posted By" := UserId;
        "Posted On" := Today;
        Modify;

        //T12712-NS
        ProductionOrder_lRec.Get("Prod. Order Status", "Prod. Order No.");
        ProductionOrder_lRec."Latest PCN No." := "No.";
        ProductionOrder_lRec."Total No. of PCN Posted" += 1;
        ProductionOrder_lRec.Modify;
        //T12712-NE

    end;


    procedure ProdOrderChangeLineExit_gFnc(): Boolean
    var
        ProdOrderChangeNoteLines_lRec: Record "Prod. Order Change Note Line";
    begin
        ProdOrderChangeNoteLines_lRec.Reset;
        ProdOrderChangeNoteLines_lRec.SetRange("Document No.", "No.");
        exit(ProdOrderChangeNoteLines_lRec.FindFirst);
    end;


    procedure "----------CreateWorkOrderWiseProdOrder----------"()
    begin
    end;


    procedure CreateWorkOrderWiseProdOrder_gFnc(ProdOrderChangeNoteHdr_iRec: Record "Prod. Order Change Note Header")
    var
        ProdOrder_lRec: Record "Production Order";
        InsertProdOrderChangeNoteHdr_lRec: Record "Prod. Order Change Note Header";
        InsertProdOrderChangeNoteLine_lRec: Record "Prod. Order Change Note Line";
        NoSeriesMgt_lCdu: Codeunit NoSeriesManagement;
        ProdOrderLine_lRec: Record "Prod. Order Line";
    begin
        ProdOrderChangeNoteHdr_iRec.TestField("Change Status", ProdOrderChangeNoteHdr_iRec."change status"::Approved);
        ProdOrderChangeNoteHdr_iRec.TestField("No.");

        WindowDialog_gDlg.Open(Text50010_gCtx + Text50011_gCtx);

        ManufacturingSetup_gRec.Get;
        ManufacturingSetup_gRec.TestField("Prod. Order Change No. Series");

        ProdOrder_lRec.Reset;
        ProdOrder_lRec.SetFilter("No.", '<>%1', ProdOrderChangeNoteHdr_iRec."Prod. Order No.");
        //ProdOrder_lRec.SETRANGE("WO No.","Work Order No.");
        ProdOrder_lRec.SetFilter(Status, '<>%1&<>%2', ProdOrder_lRec.Status::Simulated, ProdOrder_lRec.Status::Planned);
        if ProdOrder_lRec.FindSet then begin
            repeat
                ProdOrderLine_lRec.Reset;
                ProdOrderLine_lRec.SetRange(Status, ProdOrder_lRec.Status);
                ProdOrderLine_lRec.SetRange("Prod. Order No.", ProdOrder_lRec."No.");
                ProdOrderLine_lRec.SetRange("Item No.", ProdOrderChangeNoteHdr_iRec."Item No.");
                if ProdOrderLine_lRec.FindFirst then begin
                    CurrentRecord_gInt := CurrentRecord_gInt + 1;
                    WindowDialog_gDlg.Update(1, CurrentRecord_gInt);

                    InsertProdOrderChangeNoteHdr_lRec.Init;
                    InsertProdOrderChangeNoteHdr_lRec."No." := NoSeriesMgt_lCdu.GetNextNo(ManufacturingSetup_gRec."Prod. Order Change No. Series", 0D, true);
                    InsertProdOrderChangeNoteHdr_lRec."No. Series" := ManufacturingSetup_gRec."Prod. Order Change No. Series";
                    InsertProdOrderChangeNoteHdr_lRec.Validate("Prod. Order Status", ProdOrder_lRec.Status);
                    InsertProdOrderChangeNoteHdr_lRec.Validate("Prod. Order No.", ProdOrder_lRec."No.");
                    InsertProdOrderChangeNoteHdr_lRec.Validate("Prod. Order Line No.", ProdOrderLine_lRec."Line No.");
                    InsertProdOrderChangeNoteHdr_lRec."Ref. Prod. Order Change Note" := ProdOrderChangeNoteHdr_iRec."No.";
                    InsertProdOrderChangeNoteHdr_lRec.Insert;

                    ProdOrderChangeNoteHdr_iRec.InsertProdOrderCompLines_gFnc(InsertProdOrderChangeNoteHdr_lRec, true);

                    CreationCount_gInt := CreationCount_gInt + 1;
                end;
            until ProdOrder_lRec.Next = 0;
        end;
        WindowDialog_gDlg.Close;
        Message('%1 - New Production Order Component Change Note created successfully', CreationCount_gInt);
    end;


    procedure UpdateProdOrderChangeNoteLine_gFnc(MainProdOrderChangeNoteHdr_iRec: Record "Prod. Order Change Note Header")
    var
        MainProdOrderChangeNoteLine_lRec: Record "Prod. Order Change Note Line";
        ProdOrderChangeNoteHdr_lRec: Record "Prod. Order Change Note Header";
        ProdOrderChangeNoteLine_lRec: Record "Prod. Order Change Note Line";
        LastLineNo_gInt: Integer;
        InsertProdOrderChangeNoteLine_lRec: Record "Prod. Order Change Note Line";
    begin
        MainProdOrderChangeNoteLine_lRec.Reset;
        MainProdOrderChangeNoteLine_lRec.SetRange("Document No.", MainProdOrderChangeNoteHdr_iRec."No.");
        MainProdOrderChangeNoteLine_lRec.SetRange("Prod. Order Status", MainProdOrderChangeNoteHdr_iRec."Prod. Order Status");
        MainProdOrderChangeNoteLine_lRec.SetRange("Prod. Order No.", MainProdOrderChangeNoteHdr_iRec."Prod. Order No.");
        MainProdOrderChangeNoteLine_lRec.SetRange("Prod. Order Line No.", MainProdOrderChangeNoteHdr_iRec."Prod. Order Line No.");
        MainProdOrderChangeNoteLine_lRec.SetFilter(Action, '<>%1', MainProdOrderChangeNoteLine_lRec.Action::" ");
        if MainProdOrderChangeNoteLine_lRec.FindSet then begin
            repeat
                if ProdOrderChangeNoteLine_lRec.Action = ProdOrderChangeNoteLine_lRec.Action::Modify then begin
                    ProdOrderChangeNoteHdr_lRec.Reset;
                    ProdOrderChangeNoteHdr_lRec.SetRange("Ref. Prod. Order Change Note", MainProdOrderChangeNoteHdr_iRec."No.");
                    ProdOrderChangeNoteHdr_lRec.SetRange("Source No.", MainProdOrderChangeNoteHdr_iRec."Source No.");
                    if ProdOrderChangeNoteHdr_lRec.FindSet then begin
                        repeat
                            ProdOrderChangeNoteLine_lRec.SetRange("Document No.", ProdOrderChangeNoteHdr_lRec."No.");
                            ProdOrderChangeNoteLine_lRec.SetRange("Prod. Order Status", ProdOrderChangeNoteHdr_lRec."Prod. Order Status");
                            ProdOrderChangeNoteLine_lRec.SetRange("Prod. Order No.", ProdOrderChangeNoteHdr_lRec."Prod. Order No.");
                            ProdOrderChangeNoteLine_lRec.SetRange("Prod. Order Line No.", MainProdOrderChangeNoteLine_lRec."Prod. Order Line No.");
                            ProdOrderChangeNoteLine_lRec.SetRange("Item No.", MainProdOrderChangeNoteLine_lRec."Item No.");
                            if ProdOrderChangeNoteLine_lRec.FindSet then begin
                                repeat
                                    ProdOrderChangeNoteLine_lRec.Validate("New Quantity Per", MainProdOrderChangeNoteLine_lRec."New Quantity Per");
                                    ProdOrderChangeNoteLine_lRec.Validate(Action, MainProdOrderChangeNoteLine_lRec.Action);
                                    ProdOrderChangeNoteLine_lRec.Modify;
                                until ProdOrderChangeNoteLine_lRec.Next = 0;
                            end;
                        until ProdOrderChangeNoteHdr_lRec.Next = 0;
                    end;
                end else
                    if ProdOrderChangeNoteLine_lRec.Action = ProdOrderChangeNoteLine_lRec.Action::Add then begin
                        ProdOrderChangeNoteHdr_lRec.Reset;
                        ProdOrderChangeNoteHdr_lRec.SetRange("Ref. Prod. Order Change Note", MainProdOrderChangeNoteHdr_iRec."No.");
                        ProdOrderChangeNoteHdr_lRec.SetRange("Source No.", MainProdOrderChangeNoteHdr_iRec."Source No.");
                        if ProdOrderChangeNoteHdr_lRec.FindSet then begin
                            repeat
                                ProdOrderChangeNoteLine_lRec.SetRange("Document No.", ProdOrderChangeNoteHdr_lRec."No.");
                                ProdOrderChangeNoteLine_lRec.SetRange("Prod. Order Status", ProdOrderChangeNoteHdr_lRec."Prod. Order Status");
                                ProdOrderChangeNoteLine_lRec.SetRange("Prod. Order No.", ProdOrderChangeNoteHdr_lRec."Prod. Order No.");
                                ProdOrderChangeNoteLine_lRec.SetRange("Prod. Order Line No.", MainProdOrderChangeNoteLine_lRec."Prod. Order Line No.");
                                if ProdOrderChangeNoteLine_lRec.FindLast then
                                    LastLineNo_gInt := ProdOrderChangeNoteLine_lRec."Line No." + 10000
                                else
                                    LastLineNo_gInt := 10000;

                                InsertProdOrderChangeNoteLine_lRec.Init;
                                InsertProdOrderChangeNoteLine_lRec.TransferFields(MainProdOrderChangeNoteLine_lRec);
                                InsertProdOrderChangeNoteLine_lRec."Line No." := LastLineNo_gInt;
                                InsertProdOrderChangeNoteLine_lRec."Location Code" := ProdOrderChangeNoteHdr_lRec."Location Code";
                                //InsertProdOrderChangeNoteLine_lRec."Prod. Order Component Line No." := LastLineNo_gInt;
                                InsertProdOrderChangeNoteLine_lRec.Insert(true);
                            until ProdOrderChangeNoteHdr_lRec.Next = 0;
                        end;
                    end;
            until MainProdOrderChangeNoteLine_lRec.Next = 0;
        end;
    end;
}

