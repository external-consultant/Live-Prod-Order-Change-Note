Table 81181 "Prod. Order Change Note Line"
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
        field(1; "Document No."; Code[20])
        {
            Editable = false;
            TableRelation = "Prod. Order Change Note Header"."No.";
        }
        field(2; "Line No."; Integer)
        {
            Editable = false;
        }
        field(3; "Item No."; Code[20])
        {
            TableRelation = Item;

            trigger OnValidate()
            var
                Item_lRec: Record Item;
                ProdChangeNoteLine_lRec: Record "Prod. Order Change Note Line";
            begin
                TestStatusOpen_gFnc;

                if CurrFieldNo <> 0 then begin
                    if "Prod. Order Component Line No." <> 0 then
                        Error('You cannot change the Item in line which link with component lines');

                    if ("Item No." <> '') and ("Item No." <> xRec."Item No.") then begin
                        Item_lRec.Get("Item No.");
                        "Item Description" := Item_lRec.Description;
                        "Prod. Order Status" := ProdOrderChangeNoteHdr_gRec."Prod. Order Status";
                        "Prod. Order No." := ProdOrderChangeNoteHdr_gRec."Prod. Order No.";
                        "Prod. Order Line No." := ProdOrderChangeNoteHdr_gRec."Prod. Order Line No.";
                        "Location Code" := ProdOrderChangeNoteHdr_gRec."Location Code";
                        ProdChangeNoteLine_lRec.Reset;
                        ProdChangeNoteLine_lRec.SetRange("Document No.", "Document No.");
                        Validate("Unit of Measure Code", Item_lRec."Base Unit of Measure");
                        Action := Action::Add;
                    end else begin
                        "Item Description" := '';
                        "Prod. Order Status" := "prod. order status"::" ";
                        "Prod. Order No." := '';
                        "Prod. Order Line No." := 0;
                        "Unit of Measure Code" := '';
                        Action := Action::" ";
                    end;
                end else begin
                    TestField("Item No.");
                end;
            end;
        }
        field(4; "Item Description"; Text[100])
        {
            Editable = false;
        }
        field(5; "Quantity Per"; Decimal)
        {
            BlankZero = true;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                TestStatusOpen_gFnc;

                TestField("Item No.");
                TestField(Action, Action::Add);
                "New Quantity Per" := "Quantity Per";
                Validate("Calculation Formula");
            end;
        }
        field(6; "New Quantity Per"; Decimal)
        {
            BlankZero = true;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                Item_lRec: Record Item;
                CalQtyPer_lDec: Decimal;
                ProdOrderChangeNoteHeader_lRec: Record "Prod. Order Change Note Header";
            begin

                if (Action = Action::Add) and (Rec."FG Recovery" or Rec.Recovery) then begin
                    Rec."New Expected Quantity" := Rec."FG Recovery Quantity" + Rec."Recovery Quantity";
                end else begin
                    ProdOrderChangeNoteHeader_lRec.Reset();
                    ProdOrderChangeNoteHeader_lRec.GET(Rec."Document No.");
                    Rec."New Expected Quantity" := Round(Rec."New Quantity Per" * (ProdOrderChangeNoteHeader_lRec."Original Prod Order Qty"), 1, '>');
                end;

                //     TestStatusOpen_gFnc;

                //     TestField("Item No.");
                //     Validate("Calculation Formula");

                //     //Check Out of Tolerance >>
                //     "Out of Tolerance" := false;
                //     if Item_lRec.Get("Item No.") then begin
                //         if Item_lRec."Upper Tolerance Limit" > 0 then begin
                //             CalQtyPer_lDec := "Quantity Per" + ("Quantity Per" * Item_lRec."Upper Tolerance Limit" / 100);
                //             if "New Quantity Per" > CalQtyPer_lDec then
                //                 "Out of Tolerance" := true;
                //         end;

                //         if Item_lRec."Lower Tolerance Limit" > 0 then begin
                //             CalQtyPer_lDec := "Quantity Per" - ("Quantity Per" * Item_lRec."Lower Tolerance Limit" / 100);
                //             if "New Quantity Per" < CalQtyPer_lDec then
                //                 "Out of Tolerance" := true;
                //         end;
                //     end;
                //     //Check Out of Tolerance <<
            end;

        }
        field(7; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            Editable = false;
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));

            trigger OnValidate()
            begin
                Item_gRec.Get("Item No.");

                "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item_gRec, "Unit of Measure Code");
                "Quantity (Base)" := CalcBaseQty(Quantity);

                UpdateUnitCost;

                Validate("Expected Quantity", Quantity * ProdOrderNeeds);
            end;
        }
        field(8; "Expected Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Expected Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                Text50001_lCtx: label 'Expected Quantity cannot be less than Act. Consumption (Qty) + Requisition Qty.';
                Item: Record Item;
            begin
                if Item.Get("Item No.") then
                    if Item."Rounding Precision" > 0 then
                        "Expected Quantity" := ROUND("Expected Quantity", Item."Rounding Precision", '>')
                    else
                        "Expected Quantity" := ROUND("Expected Quantity", 0.00001, '>');

                if ("Prod. Order Status" in ["prod. order status"::Released]) and
                   (xRec."Item No." <> '') and
                   ("Line No." <> 0)
                then
                    CalcFields("Act. Consumption (Qty)");
                "Remaining Quantity" := "Expected Quantity" - "Act. Consumption (Qty)" / "Qty. per Unit of Measure";
                if ("Remaining Quantity" * "Expected Quantity") < 0 then
                    "Remaining Quantity" := 0;

                "Remaining Qty. (Base)" := ROUND("Remaining Quantity" * "Qty. per Unit of Measure", 0.00001);

                "Completely Picked" := "Qty. Picked" >= "Expected Quantity";

                //ReserveProdOrderComp.VerifyQuantity(Rec,xRec);

                "Cost Amount" := ROUND("Expected Quantity" * "Unit Cost");
                "Overhead Amount" :=
                  ROUND(
                    "Expected Quantity" *
                    (("Direct Unit Cost" * "Indirect Cost %" / 100) + "Overhead Rate"));
                "Direct Cost Amount" := ROUND("Expected Quantity" * "Direct Unit Cost");
            end;
        }
        field(10; "New Expected Quantity"; Decimal)
        {
            BlankZero = true;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                Item: Record Item;
                Text50001_lCtx: label 'Expected Quantity cannot be less than Act. Consumption (Qty) + Requisition Qty.';
            begin
                TestStatusOpen_gFnc;

                if Item.Get("Item No.") then
                    if Item."Rounding Precision" > 0 then
                        "New Expected Quantity" := ROUND("New Expected Quantity", Item."Rounding Precision", '>')
                    else
                        "New Expected Quantity" := ROUND("New Expected Quantity", 0.00001, '>');

                "Expected Qty. (Base)" := ROUND("Expected Quantity" * "Qty. per Unit of Measure", 0.00001);
                if ("Prod. Order Status" in ["prod. order status"::Released]) and
                   (xRec."Item No." <> '') and
                   ("Line No." <> 0)
                then
                    CalcFields("Act. Consumption (Qty)");
                "Remaining Quantity" := "Expected Quantity" - "Act. Consumption (Qty)" / "Qty. per Unit of Measure";
                if ("Remaining Quantity" * "Expected Quantity") < 0 then
                    "Remaining Quantity" := 0;

                "Remaining Qty. (Base)" := ROUND("Remaining Quantity" * "Qty. per Unit of Measure", 0.00001);
                "Completely Picked" := "Qty. Picked" >= "Expected Quantity";

                //ReserveProdOrderComp.VerifyQuantity(Rec,xRec);

                "Cost Amount" := ROUND("Expected Quantity" * "Unit Cost");
                "Overhead Amount" :=
                  ROUND(
                    "Expected Quantity" *
                    (("Direct Unit Cost" * "Indirect Cost %" / 100) + "Overhead Rate"));
                "Direct Cost Amount" := ROUND("Expected Quantity" * "Direct Unit Cost");

                "Final Qty. Per" := 0;
                if "Principal Input" then begin
                    ProdOrderChangeNoteHdr_gRec.Get("Document No.");
                    if ProdOrderChangeNoteHdr_gRec."Total Raw Material to Consume" <> 0 then begin
                        if "New Expected Quantity" <> 0 then
                            "Final Qty. Per" := "New Expected Quantity" / ProdOrderChangeNoteHdr_gRec."Total Raw Material to Consume"
                        else
                            "Final Qty. Per" := "Expected Quantity" / ProdOrderChangeNoteHdr_gRec."Total Raw Material to Consume"
                    end;
                end;
            end;
        }
        field(11; "Remaining Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Remaining Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(12; "Action"; Option)
        {
            Editable = false;
            OptionCaption = ' ,Add,Delete,Modify,Remove Action';
            OptionMembers = " ",Add,Delete,Modify,"Remove Action";
        }
        field(13; "Prod. Order Status"; Option)
        {
            Editable = false;
            OptionCaption = ' ,Planned,Firm Planned,Released';
            OptionMembers = " ",Planned,"Firm Planned",Released;
        }
        field(14; "Prod. Order No."; Code[20])
        {
            Editable = false;

            trigger OnValidate()
            var
                ProdOrderChangeNoteHdr_lRec: Record "Prod. Order Change Note Header";
                ProductionHeader_lRec: Record "Production Order";
            begin
            end;
        }
        field(15; "Prod. Order Line No."; Integer)
        {
            BlankNumbers = BlankZero;
            Editable = false;

            trigger OnValidate()
            var
                ProdOrderLine_lRec: Record "Prod. Order Line";
                ProdOrderChangeNoteHdr_lRec: Record "Prod. Order Change Note Header";
            begin
            end;
        }
        field(16; "Prod. Order Component Line No."; Integer)
        {
            Editable = false;
        }
        field(17; "Location Code"; Code[10])
        {
            TableRelation = Location where("Use As In-Transit" = const(false));
        }
        field(18; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';

            trigger OnLookup()
            var
                WMSManagement: Codeunit "WMS Management";
                BinCode: Code[20];
            begin
            end;

            trigger OnValidate()
            var
                WMSManagement: Codeunit "WMS Management";
            begin
            end;
        }
        field(19; "Calculation Formula"; Option)
        {
            Caption = 'Calculation Formula';
            Editable = false;
            OptionCaption = ' ,Length,Length * Width,Length * Width * Depth,Weight';
            OptionMembers = " ",Length,"Length * Width","Length * Width * Depth",Weight;

            trigger OnValidate()
            begin
                case "Calculation Formula" of
                    "calculation formula"::" ":
                        Quantity := "New Quantity Per";
                    "calculation formula"::Length:
                        Quantity := ROUND(Length * "New Quantity Per", 0.00001);
                    "calculation formula"::"Length * Width":
                        Quantity := ROUND(Length * Width * "New Quantity Per", 0.00001);
                    "calculation formula"::"Length * Width * Depth":
                        Quantity := ROUND(Length * Width * Depth * "New Quantity Per", 0.00001);
                    "calculation formula"::Weight:
                        Quantity := ROUND(Weight * "New Quantity Per", 0.00001);
                end;
                "Quantity (Base)" := Quantity * "Qty. per Unit of Measure";
                Validate("Expected Quantity", Quantity * ProdOrderNeeds);
                Validate("New Expected Quantity", Quantity * ProdOrderNeeds);
            end;
        }
        field(20; Quantity; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(21; Length; Decimal)
        {
            BlankZero = true;
            Caption = 'Length';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(22; Width; Decimal)
        {
            BlankZero = true;
            Caption = 'Width';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(23; Weight; Decimal)
        {
            BlankZero = true;
            Caption = 'Weight';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(24; Depth; Decimal)
        {
            BlankZero = true;
            Caption = 'Depth';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(25; "Quantity (Base)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(26; "Qty. per Unit of Measure"; Decimal)
        {
            BlankZero = true;
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 16;
            Editable = false;
        }
        field(27; "Routing Link Code"; Code[10])
        {
            Caption = 'Routing Link Code';
            Editable = false;
            TableRelation = "Routing Link";

            trigger OnValidate()
            var
                ProdOrderLine: Record "Prod. Order Line";
                ProdOrderRtngLine: Record "Prod. Order Routing Line";
            begin
            end;
        }
        field(28; "Scrap %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Scrap %';
            DecimalPlaces = 0 : 5;
            Editable = false;
            MaxValue = 100;
            MinValue = 0;
        }
        field(29; "Expected Qty. (Base)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Expected Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(30; "Act. Consumption (Qty)"; Decimal)
        {
            BlankZero = true;
            CalcFormula = - sum("Item Ledger Entry".Quantity where("Entry Type" = const(Consumption),
                                                                   "Order Type" = const(Production),
                                                                   "Order No." = field("Prod. Order No."),
                                                                   "Order Line No." = field("Prod. Order Line No."),
                                                                   "Prod. Order Comp. Line No." = field("Prod. Order Component Line No."),
                                                                   "Item No." = field("Item No.")));
            Caption = 'Act. Consumption (Qty)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(31; "Remaining Qty. (Base)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Remaining Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(32; "Completely Picked"; Boolean)
        {
            BlankZero = true;
            Caption = 'Completely Picked';
            Editable = false;
        }
        field(33; "Qty. Picked"; Decimal)
        {
            BlankZero = true;
            Caption = 'Qty. Picked';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(34; "Cost Amount"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Cost Amount';
            Editable = false;
        }
        field(35; "Unit Cost"; Decimal)
        {
            BlankZero = true;
            Caption = 'Unit Cost';
            DecimalPlaces = 2 : 5;
            Editable = false;
        }
        field(36; "Direct Cost Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Direct Cost Amount';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(37; "Overhead Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Overhead Amount';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(38; "Direct Unit Cost"; Decimal)
        {
            BlankZero = true;
            Caption = 'Direct Unit Cost';
            DecimalPlaces = 2 : 5;
            Editable = false;
        }
        field(39; "Indirect Cost %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Indirect Cost %';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(40; "Overhead Rate"; Decimal)
        {
            BlankZero = true;
            Caption = 'Overhead Rate';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(41; "Reserved Qty. (Base)"; Decimal)
        {
            BlankZero = true;
            CalcFormula = - sum("Reservation Entry"."Quantity (Base)" where("Source ID" = field("Prod. Order No."),
                                                                            "Source Ref. No." = field("Prod. Order Component Line No."),
                                                                            "Source Type" = const(5407),
                                                                            "Source Subtype" = field("Prod. Order Status"),
                                                                            "Source Batch Name" = const(''),
                                                                            "Source Prod. Order Line" = field("Prod. Order Line No."),
                                                                            "Reservation Status" = const(Reservation)));
            Caption = 'Reserved Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(42; "Reserved Quantity"; Decimal)
        {
            BlankZero = true;
            CalcFormula = - sum("Reservation Entry".Quantity where("Source ID" = field("Prod. Order No."),
                                                                   "Source Ref. No." = field("Prod. Order Component Line No."),
                                                                   "Source Type" = const(5407),
                                                                   "Source Subtype" = field("Prod. Order Status"),
                                                                   "Source Batch Name" = const(''),
                                                                   "Source Prod. Order Line" = field("Prod. Order Line No."),
                                                                   "Reservation Status" = const(Reservation)));
            Caption = 'Reserved Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(43; "Force Close By"; Code[50])
        {
            Editable = false;
        }
        field(44; Posted; Boolean)
        {
            CalcFormula = lookup("Prod. Order Change Note Header".Posted where("No." = field("Document No."),
                                                                                "Prod. Order Status" = field("Prod. Order Status"),
                                                                                "Prod. Order No." = field("Prod. Order No."),
                                                                                "Prod. Order Line No." = field("Prod. Order Line No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(50; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = ToBeClassified;
            Description = 'T10436';
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."),
                                                       Blocked = const(false));

            trigger OnValidate()
            var
                ItemVariant_lRec: Record "Item Variant";
            begin
                if Item_gRec."No." <> "Item No." then
                    Item_gRec.Get("Item No.");

                CalcFields("Reserved Qty. (Base)");
                TestField("Reserved Qty. (Base)", 0);
                TestField("Remaining Qty. (Base)", "Expected Qty. (Base)");

                // if Item_gRec."Variant Approval Required" then begin

                // end;

                if "Variant Code" <> '' then begin
                    ItemVariant_lRec.Get("Item No.", "Variant Code");
                    "Item Description" := ItemVariant_lRec.Description;
                end;
            end;
        }
        field(51; "Due Date"; Date)
        {
            Caption = 'Due Date';
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            var
                CheckDateConflict: Codeunit "Reservation-Check Date Confl.";
            begin
            end;
        }
        field(52; "Original Item No."; Code[20])
        {
            Caption = 'Original Item No.';
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = Item;
        }
        field(53; "Original Variant Code"; Code[10])
        {
            Caption = 'Original Variant Code';
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Item Variant".Code where("Item No." = field("Original Item No."));
        }
        field(100; "Principal Input"; Boolean)
        {
            Caption = 'Principal Input';
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                if "Principal Input" then begin
                    TestField(Recovery, false);
                    TestField("FG Recovery", false);
                end;
            end;
        }
        field(101; "Out of Tolerance"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(102; "Substitute Selected"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(103; "Item Variant Changed"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(110; Recovery; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'T10146';

            trigger OnValidate()
            begin
                TestField(Action, Action::Add);

                if "Force Close By" <> '' then
                    Error('You cannot Modify Prod. Order Component Line as it is force closed by %1 for Prod. Order No. %2, Prod. Order Line No. %3,Prod. Order Component Line No. %4',
                            "Force Close By", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Component Line No.");

                TestStatusOpen_gFnc;
                if Recovery then
                    TestField("FG Recovery", false);
            end;
        }
        field(111; "Recovery Quantity"; Decimal)
        {
            BlankZero = true;
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Description = 'T10146';
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField(Action, Action::Add);

                if "Force Close By" <> '' then
                    Error('You cannot Modify Prod. Order Component Line as it is force closed by %1 for Prod. Order No. %2, Prod. Order Line No. %3,Prod. Order Component Line No. %4',
                            "Force Close By", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Component Line No.");

                TestStatusOpen_gFnc;

                if "Recovery Quantity" <> 0 then
                    TestField(Recovery, true);

                UpdateHeaderRawMaetrQty_lFnc;
            end;
        }
        field(112; "FG Recovery"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'T10146';

            trigger OnValidate()
            begin
                TestField(Action, Action::Add);


                if "Force Close By" <> '' then
                    Error('You cannot Modify Prod. Order Component Line as it is force closed by %1 for Prod. Order No. %2, Prod. Order Line No. %3,Prod. Order Component Line No. %4',
                            "Force Close By", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Component Line No.");

                TestStatusOpen_gFnc;
                if "FG Recovery" then begin
                    TestField(Recovery, false);
                    TestField("Principal Input", false);
                end;


                Rec."Principal Input" := True;
            end;
        }
        field(113; "FG Recovery Quantity"; Decimal)
        {
            BlankZero = true;
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Description = 'T10146';
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField(Action, Action::Add);

                if "Force Close By" <> '' then
                    Error('You cannot Modify Prod. Order Component Line as it is force closed by %1 for Prod. Order No. %2, Prod. Order Line No. %3,Prod. Order Component Line No. %4',
                            "Force Close By", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Component Line No.");

                TestStatusOpen_gFnc;

                if "FG Recovery Quantity" <> 0 then
                    TestField("FG Recovery", true);

                UpdateHeaderRawMaetrQty_lFnc;
            end;
        }
        field(121; "Final Qty. Per"; Decimal)
        {
            BlankZero = true;
            DataClassification = ToBeClassified;
            DecimalPlaces = 2 : 5;
            Description = 'T10146';
            Editable = false;
        }
        field(122; "Processed"; Boolean)
        {
            Description = 'T10146';
            Editable = false;
        }
        field(123; "Make New Qty Per Zero"; Boolean)
        {
            Description = 'T10146';
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Component Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestStatusOpen_gFnc;
    end;

    trigger OnInsert()
    var
        ProdOrderChangeNoteLines_lRec: Record "Prod. Order Change Note Line";
        LineNo_lInt: Integer;
        Text5000_lCtx: label 'There is no Prod. order component lines. \First perform Action "Get Component Lines".';
    begin
        TestStatusOpen_gFnc;
    end;

    var
        ProdOrderChangeNoteHdr_gRec: Record "Prod. Order Change Note Header";
        UOMMgt: Codeunit "Unit of Measure Management";
        GLSetupRead: Boolean;
        GLSetup: Record "General Ledger Setup";
        Item_gRec: Record Item;


    procedure DeleteComponentLines_gFnc()
    var
        Text5000_lCtx: label 'This line manually created by user so you can not perform delete action. Use right click delete line option. Document No.: %1, Line No.: %2';
    begin
        CalcFields("Reserved Quantity");
        if "Reserved Quantity" <> 0 then
            Error('You cannot Delete Component Lines as reservation entries created for Prod. Order No. %1, Prod. Order Line No. %2,Prod. Order Component Line No. %3',
                    "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Component Line No.");

        CalcFields("Act. Consumption (Qty)");
        if "Act. Consumption (Qty)" > 0 then
            Error('You cannot Delete Component Lines as partial consumption has been done for Prod. Order No. %1, Prod. Order Line No. %2,Prod. Order Component Line No. %3',
                    "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Component Line No.");

        if "Force Close By" <> '' then
            Error('You cannot Delete Prod. Order Component Line as it is force closed by %1 for Prod. Order No. %2, Prod. Order Line No. %3,Prod. Order Component Line No. %4',
                    "Force Close By", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Component Line No.");

        TestStatusOpen_gFnc;

        if Action = Action::Add then
            Error(Text5000_lCtx, "Document No.", "Line No.");

        Action := Action::Delete;
        Modify;
    end;


    procedure ModifiyComponentLines_gFnc(Selection_iInt: Integer)
    var
        Text5000_lCtx: label 'This line manually created by user so you can not perform modify action. Document No.: %1, Line No.: %2';
    begin
        CalcFields("Reserved Quantity");
        // if "Reserved Quantity" <> 0 then
        //     Error('You cannot Modify Component Lines as reservation entries created for Prod. Order No. %1, Prod. Order Line No. %2,Prod. Order Component Line No. %3',
        //             "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Component Line No.");

        //CALCFIELDS("Act. Consumption (Qty)");
        //IF "Act. Consumption (Qty)" > 0 THEN
        //  ERROR('You cannot Modify Component Lines as partial consumption has been done for Prod. Order No. %1, Prod. Order Line No. %2,Prod. Order Component Line No. %3',
        //          "Prod. Order No.","Prod. Order Line No.","Prod. Order Component Line No.");

        if "Force Close By" <> '' then
            Error('You cannot Modify Prod. Order Component Line as it is force closed by %1 for Prod. Order No. %2, Prod. Order Line No. %3,Prod. Order Component Line No. %4',
                    "Force Close By", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Component Line No.");

        TestStatusOpen_gFnc;

        if Action = Action::Add then
            Error(Text5000_lCtx, "Document No.", "Line No.");
        if not "Make New Qty Per Zero" then
            Validate("New Quantity Per", "Quantity Per");
        //"New Expected Quantity" := "Expected Quantity";
        if (Selection_iInt = 1) then
            Action := Action::Modify;
        Modify;
    end;


    procedure RemoveAction_gFnc()
    var
        Text5000_lCtx: label 'This line manually created by user so you can not perform delete action. Document No.: %1, Line No.: %2';
    begin
        TestStatusOpen_gFnc;

        if Action = Action::Add then
            Error(Text5000_lCtx, "Document No.", "Line No.");

        "New Quantity Per" := 0;
        "New Expected Quantity" := 0;
        "Final Qty. Per" := 0;
        Action := Action::" ";
        Modify;
    end;


    procedure TestStatusOpen_gFnc()
    begin
        TestField("Document No.");
        Clear(ProdOrderChangeNoteHdr_gRec);
        ProdOrderChangeNoteHdr_gRec.Get("Document No.");
        ProdOrderChangeNoteHdr_gRec.TestField("Change Status", ProdOrderChangeNoteHdr_gRec."change status"::Open);
    end;


    procedure ProdOrderNeeds(): Decimal
    var
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderRtngLine: Record "Prod. Order Routing Line";
        ABC_lDec: Decimal;
        ProdOrderChangeNoteHeader_lRec: Record "Prod. Order Change Note Header";
        CalValue_lDec: Decimal;
    begin
        ProdOrderLine.Get("Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.");

        ProdOrderRtngLine.Reset;
        ProdOrderRtngLine.SetRange(Status, "Prod. Order Status");
        ProdOrderRtngLine.SetRange("Prod. Order No.", "Prod. Order No.");
        ProdOrderRtngLine.SetRange("Routing Reference No.", ProdOrderLine."Routing Reference No.");
        if "Routing Link Code" <> '' then
            ProdOrderRtngLine.SetRange("Routing Link Code", "Routing Link Code");
        if ProdOrderRtngLine.FindFirst then begin
            ABC_lDec := (ProdOrderLine.Quantity *
                (1 + ProdOrderLine."Scrap %" / 100) *
                    (1 + ProdOrderRtngLine."Scrap Factor % (Accumulated)") *
                        (1 + "Scrap %" / 100) +
                            ProdOrderRtngLine."Fixed Scrap Qty. (Accum.)");

            //T10146-NS
            ProdOrderChangeNoteHeader_lRec.Get("Document No.");
            if (ProdOrderChangeNoteHeader_lRec."Updated Production Quantity" <> 0) and (ProdOrderChangeNoteHeader_lRec."Updated Production Quantity" <> ProdOrderChangeNoteHeader_lRec.Quantity) then begin
                CalValue_lDec := ProdOrderChangeNoteHeader_lRec."Updated Production Quantity" *
                (1 + ProdOrderLine."Scrap %" / 100) *
                (1 + ProdOrderRtngLine."Scrap Factor % (Accumulated)") *
                (1 + "Scrap %" / 100) +
                ProdOrderRtngLine."Fixed Scrap Qty. (Accum.)";

                exit(CalValue_lDec);
            end;
            //T10146-NE

            exit(
              ProdOrderLine.Quantity *
              (1 + ProdOrderLine."Scrap %" / 100) *
              (1 + ProdOrderRtngLine."Scrap Factor % (Accumulated)") *
              (1 + "Scrap %" / 100) +
              ProdOrderRtngLine."Fixed Scrap Qty. (Accum.)");
        end;

        //T10146-NS
        ProdOrderChangeNoteHeader_lRec.Get("Document No.");
        if (ProdOrderChangeNoteHeader_lRec."Updated Production Quantity" <> 0) and (ProdOrderChangeNoteHeader_lRec."Updated Production Quantity" <> ProdOrderChangeNoteHeader_lRec.Quantity) then begin
            CalValue_lDec := ProdOrderChangeNoteHeader_lRec."Updated Production Quantity" * (1 + ProdOrderLine."Scrap %" / 100) * (1 + "Scrap %" / 100);

            exit(
            ProdOrderChangeNoteHeader_lRec."Updated Production Quantity" *
            (1 + ProdOrderLine."Scrap %" / 100) * (1 + "Scrap %" / 100));
        end;
        //T10146-NE

        exit(
          ProdOrderLine.Quantity *
          (1 + ProdOrderLine."Scrap %" / 100) * (1 + "Scrap %" / 100));
    end;

    local procedure CalcBaseQty(Qty: Decimal): Decimal
    begin
        TestField("Qty. per Unit of Measure");
        exit(ROUND(Qty * "Qty. per Unit of Measure", 0.00001));
    end;

    local procedure GetGLSetup()
    begin
        if not GLSetupRead then
            GLSetup.Get;
        GLSetupRead := true;
    end;

    local procedure UpdateUnitCost()
    begin
        "Unit Cost" := Item_gRec."Unit Cost";

        "Unit Cost" :=
          ROUND("Unit Cost" * "Qty. per Unit of Measure",
            GLSetup."Unit-Amount Rounding Precision");

        "Indirect Cost %" := ROUND(Item_gRec."Indirect Cost %", 0.00001);

        "Overhead Rate" :=
          ROUND(Item_gRec."Overhead Rate" * "Qty. per Unit of Measure",
            GLSetup."Unit-Amount Rounding Precision");

        "Direct Unit Cost" :=
          ROUND(
            ("Unit Cost" - "Overhead Rate") / (1 + "Indirect Cost %" / 100),
            GLSetup."Unit-Amount Rounding Precision");
    end;

    local procedure UpdateHeaderRawMaetrQty_lFnc()
    begin
        TestField("Document No.");
        Clear(ProdOrderChangeNoteHdr_gRec);
        // ProdOrderChangeNoteHdr_gRec.Get("Document No.");
        //ProdOrderChangeNoteHdr_gRec."Updated Production Quantity" := ProdOrderChangeNoteHdr_gRec."No. of Batches" * ProdOrderChangeNoteHdr_gRec."Batch Qty";
        // ProdOrderChangeNoteHdr_gRec."Total Raw Material to Consume" := ProdOrderChangeNoteHdr_gRec."Updated Production Quantity" - "Recovery Quantity" - "FG Recovery Quantity";
        // ProdOrderChangeNoteHdr_gRec.Modify;
    end;

    trigger OnModify()
    var
        PCNHEader_lReC: Record "Prod. Order Change Note Header";
    begin
        PCNHEader_lReC.Reset();
        PCNHEader_lReC.GET(Rec."Document No.");
        PCNHEader_lReC."Quantity Calculated" := false;
        PCNHEader_lReC.Modify();

        if "Variant Code" <> xRec."Variant Code" then
            "Item Variant Changed" := true;
    end;

    procedure UnProcessAllLines()
    var
        PCNLines_lRec: Record "Prod. Order Change Note Line";
    begin
        PCNLines_lRec.Reset();
        PCNLines_lRec.SetRange("Document No.", Rec."Document No.");
        PCNLines_lRec.SetFilter("Line No.", '<>%1', Rec."Line No.");
        if PCNLines_lRec.FindSet() then
            PCNLines_lRec.ModifyAll(Processed, false);
    end;
}

