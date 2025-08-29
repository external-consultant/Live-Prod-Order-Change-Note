Table 81183 "Prod. Order Component Archive"
{
    // -----------------------------------------------------------------------------------------------------------------------------
    // Intech Systems Pvt. Ltd.
    // -----------------------------------------------------------------------------------------------------------------------------
    // ID                        Date            Author
    // -----------------------------------------------------------------------------------------------------------------------------
    // I-C0059-1005713-01        10/10/11        KSP
    //                           Added field "Description 2" and flow it
    // I-C0059-1400410-01        08/08/14        Chintan Panchal
    //                           C0059-NAV ENHANCEMENTS upgrade to NAV 2013 R2
    // I-C0007-1260510-01        31/12/12    Jignesh Dhandha
    //                           Added New Field For Report No. 33029050 - "Mat. Requisition Consolidated"
    //                           New Fields : 60315 - Inventory
    //                                        63303 - "Description 3" Reference to Component - C0039 and Task No. - C0039-1006179-01
    //                                        65053 - "Description 2" Reference to Component - C0059 and Task No. - I-C0059-1005713-01
    // I-C0007-1400411-01    11/08/14     Chintan Panchal
    //                       C0007-STANDARD DOCUMENTS AND REPORTS Upgrade to NAV 2013 R2
    // I-C0059-1005723-01    07/10/11    KSP
    //                       Change "Qty. per Unit of Measure" -> DecimalPlaces Property(0:16)
    // I-C0044-1006180-01    08/10/11    KSP
    //                       Object Released
    // I-C0044-1400421-01    18/08/14    Chintan Panchal
    //                       C0044-Multiple UOM Conversion RENUMBER upgrade to NAV2013 R2
    // I-C0011-1001330-02  24/07/12     RaviShah
    //                     Subcontracting -> Added Following Field in Table:
    //                     33029432 - Available in Bulk at SubconLoc
    // I-C0011-1400409-01  07/08/14     Chintan Panchal
    //                     C0011 - SUBCONTRACTING PLUS Upgrade to NAV 2013 R2
    // -----------------------------------------------------------------------------------------------------------------------------

    Caption = 'Prod. Order Component';
    DataCaptionFields = Status, "Prod. Order No.";
    DrillDownPageID = "Prod. Order Comp. Line List";
    LookupPageID = "Prod. Order Comp. Line List";

    fields
    {
        field(1; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Simulated,Planned,Firm Planned,Released,Finished';
            OptionMembers = Simulated,Planned,"Firm Planned",Released,Finished;
        }
        field(2; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. Order No.';
#pragma warning disable
            TableRelation = "Production Order"."No." where(Status = field(Status));
#pragma warning disable
        }
        field(3; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
            TableRelation = "Prod. Order Line"."Line No." where(Status = field(Status),
                                                                 "Prod. Order No." = field("Prod. Order No."));
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(11; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item where(Type = const(Inventory));
        }
        field(12; Description; Text[100])//08082024
        {
            Caption = 'Description';
        }
        field(13; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
        }
        field(14; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(15; Position; Code[10])
        {
            Caption = 'Position';
        }
        field(16; "Position 2"; Code[10])
        {
            Caption = 'Position 2';
        }
        field(17; "Position 3"; Code[10])
        {
            Caption = 'Position 3';
        }
        field(18; "Lead-Time Offset"; DateFormula)
        {
            Caption = 'Lead-Time Offset';
        }
        field(19; "Routing Link Code"; Code[10])
        {
            Caption = 'Routing Link Code';
            TableRelation = "Routing Link";

            trigger OnValidate()
            var
                ProdOrderLine: Record "Prod. Order Line";
                ProdOrderRtngLine: Record "Prod. Order Routing Line";
            begin
            end;
        }
        field(20; "Scrap %"; Decimal)
        {
            Caption = 'Scrap %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(21; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));

            trigger OnValidate()
            var
                ItemVariant: Record "Item Variant";
            begin
            end;
        }
        field(25; "Expected Quantity"; Decimal)
        {
            Caption = 'Expected Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(26; "Remaining Quantity"; Decimal)
        {
            Caption = 'Remaining Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(27; "Act. Consumption (Qty)"; Decimal)
        {
            AccessByPermission = TableData "Production Order" = R;
            CalcFormula = - sum("Item Ledger Entry".Quantity where("Entry Type" = const(Consumption),
                                                                   "Order Type" = const(Production),
                                                                   "Order No." = field("Prod. Order No."),
                                                                   "Order Line No." = field("Prod. Order Line No."),
                                                                   "Prod. Order Comp. Line No." = field("Line No.")));
            Caption = 'Act. Consumption (Qty)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(28; "Flushing Method"; Option)
        {
            Caption = 'Flushing Method';
            OptionCaption = 'Manual,Forward,Backward,Pick + Forward,Pick + Backward';
            OptionMembers = Manual,Forward,Backward,"Pick + Forward","Pick + Backward";
        }
        field(30; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location where("Use As In-Transit" = const(false));
        }
        field(31; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(32; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(33; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code where("Location Code" = field("Location Code"));

            trigger OnLookup()
            var
                WMSManagement: Codeunit "WMS Management";
                BinCode: Code[20];
            begin
            end;

            trigger OnValidate()
            var
                WMSManagement: Codeunit "WMS Management";
                WhseIntegrationMgt: Codeunit "Whse. Integration Management";
            begin
            end;
        }
        field(35; "Supplied-by Line No."; Integer)
        {
            Caption = 'Supplied-by Line No.';
            TableRelation = "Prod. Order Line"."Line No." where(Status = field(Status),
                                                                 "Prod. Order No." = field("Prod. Order No."),
                                                                 "Line No." = field("Supplied-by Line No."));
        }
        field(36; "Planning Level Code"; Integer)
        {
            Caption = 'Planning Level Code';
            Editable = false;
        }
        field(37; "Item Low-Level Code"; Integer)
        {
            Caption = 'Item Low-Level Code';
        }
        field(40; Length; Decimal)
        {
            Caption = 'Length';
            DecimalPlaces = 0 : 5;
        }
        field(41; Width; Decimal)
        {
            Caption = 'Width';
            DecimalPlaces = 0 : 5;
        }
        field(42; Weight; Decimal)
        {
            Caption = 'Weight';
            DecimalPlaces = 0 : 5;
        }
        field(43; Depth; Decimal)
        {
            Caption = 'Depth';
            DecimalPlaces = 0 : 5;
        }
        field(44; "Calculation Formula"; Option)
        {
            Caption = 'Calculation Formula';
            OptionCaption = ' ,Length,Length * Width,Length * Width * Depth,Weight';
            OptionMembers = " ",Length,"Length * Width","Length * Width * Depth",Weight;
        }
        field(45; "Quantity per"; Decimal)
        {
            Caption = 'Quantity per';
            DecimalPlaces = 0 : 5;
        }
        field(50; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DecimalPlaces = 2 : 5;
        }
        field(51; "Cost Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Cost Amount';
            Editable = false;
        }
        field(52; "Due Date"; Date)
        {
            Caption = 'Due Date';

            trigger OnValidate()
            var
                CheckDateConflict: Codeunit "Reservation-Check Date Confl.";
            begin
            end;
        }
        field(53; "Due Time"; Time)
        {
            Caption = 'Due Time';
        }
        field(60; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 16;
            Description = 'C0059-1005723-01';
            Editable = false;
        }
        field(61; "Remaining Qty. (Base)"; Decimal)
        {
            Caption = 'Remaining Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(62; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(63; "Reserved Qty. (Base)"; Decimal)
        {
            CalcFormula = - sum("Reservation Entry"."Quantity (Base)" where("Source ID" = field("Prod. Order No."),
                                                                            "Source Ref. No." = field("Line No."),
                                                                            "Source Type" = const(5407),
                                                                            "Source Subtype" = field(Status),
                                                                            "Source Batch Name" = const(''),
                                                                            "Source Prod. Order Line" = field("Prod. Order Line No."),
                                                                            "Reservation Status" = const(Reservation)));
            Caption = 'Reserved Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = true;
            FieldClass = FlowField;
        }
        field(71; "Reserved Quantity"; Decimal)
        {
            CalcFormula = - sum("Reservation Entry".Quantity where("Source ID" = field("Prod. Order No."),
                                                                   "Source Ref. No." = field("Line No."),
                                                                   "Source Type" = const(5407),
                                                                   "Source Subtype" = field(Status),
                                                                   "Source Batch Name" = const(''),
                                                                   "Source Prod. Order Line" = field("Prod. Order Line No."),
                                                                   "Reservation Status" = const(Reservation)));
            Caption = 'Reserved Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(73; "Expected Qty. (Base)"; Decimal)
        {
            Caption = 'Expected Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(76; "Due Date-Time"; DateTime)
        {
            Caption = 'Due Date-Time';
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(5702; "Substitution Available"; Boolean)
        {
            CalcFormula = exist("Item Substitution" where(Type = const(Item),
                                                           "Substitute Type" = const(Item),
                                                           "No." = field("Item No."),
                                                           "Variant Code" = field("Variant Code")));
            Caption = 'Substitution Available';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5703; "Original Item No."; Code[20])
        {
            Caption = 'Original Item No.';
            Editable = false;
            TableRelation = Item;
        }
        field(5704; "Original Variant Code"; Code[10])
        {
            Caption = 'Original Variant Code';
            Editable = false;
            TableRelation = "Item Variant".Code where("Item No." = field("Original Item No."));
        }
        field(5750; "Pick Qty."; Decimal)
        {
            CalcFormula = sum("Warehouse Activity Line"."Qty. Outstanding" where("Activity Type" = filter(<> "Put-away"),
                                                                                  "Source Type" = const(5407),
                                                                                  "Source Subtype" = field(Status),
                                                                                  "Source No." = field("Prod. Order No."),
                                                                                  "Source Line No." = field("Prod. Order Line No."),
                                                                                  "Source Subline No." = field("Line No."),
                                                                                  "Unit of Measure Code" = field("Unit of Measure Code"),
                                                                                  "Action Type" = filter(" " | Place),
                                                                                  "Original Breakbulk" = const(false),
                                                                                  "Breakbulk No." = const(0)));
            Caption = 'Pick Qty.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(7300; "Qty. Picked"; Decimal)
        {
            Caption = 'Qty. Picked';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(7301; "Qty. Picked (Base)"; Decimal)
        {
            Caption = 'Qty. Picked (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(7302; "Completely Picked"; Boolean)
        {
            Caption = 'Completely Picked';
            Editable = false;
        }
        field(7303; "Pick Qty. (Base)"; Decimal)
        {
            CalcFormula = sum("Warehouse Activity Line"."Qty. Outstanding (Base)" where("Activity Type" = filter(<> "Put-away"),
                                                                                         "Source Type" = const(5407),
                                                                                         "Source Subtype" = field(Status),
                                                                                         "Source No." = field("Prod. Order No."),
                                                                                         "Source Line No." = field("Prod. Order Line No."),
                                                                                         "Source Subline No." = field("Line No."),
                                                                                         "Action Type" = filter(" " | Place),
                                                                                         "Original Breakbulk" = const(false),
                                                                                         "Breakbulk No." = const(0)));
            Caption = 'Pick Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(16360; "Qty. To Consume"; Decimal)
        {
            Caption = 'Qty. To Consume';
        }
        field(50001; "Change Note Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50139; "Principal Input"; Boolean)
        {
            Caption = 'Principal Input';
            DataClassification = ToBeClassified;
            Description = 'ProdOrderChangeNote';
            Editable = false;
        }
        field(60315; Inventory; Decimal)
        {
            CalcFormula = sum("Item Ledger Entry".Quantity where("Item No." = field("Item No."),
                                                                  "Location Code" = field("Location Code"),
                                                                  "Variant Code" = field("Variant Code")));
            Description = 'I-C0007-1260510-01,SubConChngV2 - Fix Flowfield Formula';
            Editable = false;
            FieldClass = FlowField;
        }
        field(63303; "Description 3"; Text[50])
        {
            Description = 'C0039-1006179-01,I-C0007-1260510-01';
        }
        field(33029278; "Sales Order No."; Code[20])
        {
            Description = 'OrderTrack';
            Editable = false;
            TableRelation = "Sales Header"."No." where("Document Type" = const(Order));
        }
        field(33029279; "Sales Order Line No."; Integer)
        {
            BlankZero = true;
            Description = 'OrderTrack';
            Editable = false;
        }
        field(33029432; "Available in Bulk at SubconLoc"; Boolean)
        {
            Caption = 'Available in Bulk at Subcon Location';
            Description = 'I-C0011-1001330-01';
        }
        field(33029433; "Qty Send at SubCon Location"; Decimal)
        {
            CalcFormula = sum("Item Ledger Entry"."Remaining Quantity" where("Entry Type" = filter(Transfer),
                                                                              "Order No." = field("Prod. Order No."),
                                                                              "Order Line No." = field("Prod. Order Line No."),
                                                                              "Item No." = field("Item No.")));
            Caption = 'Qty Send at SubCon Location';
            DecimalPlaces = 0 : 2;
            Description = 'SubConChngV2';
            Editable = false;
            FieldClass = FlowField;
        }
        field(33029813; "Description 2"; Text[50])
        {
            Description = 'I-C0059-1005713-01';
        }
        field(33030014; "Created By"; Code[30])
        {
            Description = 'LogDetail';
            Editable = false;
            TableRelation = "User Setup";
        }
        field(33030015; "Created DateTime"; DateTime)
        {
            Description = 'LogDetail';
            Editable = false;
        }
        field(33030016; "Modified By"; Code[30])
        {
            Description = 'LogDetail';
            Editable = false;
            TableRelation = "User Setup";
        }
        field(33030017; "Modified DateTime"; DateTime)
        {
            Description = 'LogDetail';
            Editable = false;
        }
        field(99000754; "Direct Unit Cost"; Decimal)
        {
            Caption = 'Direct Unit Cost';
            DecimalPlaces = 2 : 5;
        }
        field(99000755; "Indirect Cost %"; Decimal)
        {
            Caption = 'Indirect Cost %';
            DecimalPlaces = 0 : 5;
        }
        field(99000756; "Overhead Rate"; Decimal)
        {
            Caption = 'Overhead Rate';
            DecimalPlaces = 0 : 5;
        }
        field(99000757; "Direct Cost Amount"; Decimal)
        {
            Caption = 'Direct Cost Amount';
            DecimalPlaces = 2 : 2;
        }
        field(99000758; "Overhead Amount"; Decimal)
        {
            Caption = 'Overhead Amount';
            DecimalPlaces = 2 : 2;
        }
    }

    keys
    {
        key(Key1; Status, "Prod. Order No.", "Prod. Order Line No.", "Line No.", "Change Note Document No.")
        {
            Clustered = true;
        }
        key(Key2; "Prod. Order No.", "Prod. Order Line No.", "Line No.", Status)
        {
        }
        key(Key3; Status, "Prod. Order No.", "Prod. Order Line No.", "Due Date")
        {
            SumIndexFields = "Expected Quantity", "Cost Amount";
        }
        key(Key4; Status, "Prod. Order No.", "Prod. Order Line No.", "Item No.", "Line No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key5; Status, "Item No.", "Variant Code", "Location Code", "Due Date")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Expected Quantity", "Remaining Qty. (Base)", "Cost Amount", "Overhead Amount";
        }
        key(Key6; "Item No.", "Variant Code", "Location Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Due Date")
        {
            Enabled = false;
            SumIndexFields = "Expected Quantity", "Remaining Qty. (Base)", "Cost Amount", "Overhead Amount";
        }
        key(Key7; Status, "Prod. Order No.", "Routing Link Code", "Flushing Method")
        {
        }
        key(Key8; Status, "Prod. Order No.", "Location Code")
        {
        }
        key(Key9; "Item No.", "Variant Code", "Location Code", Status, "Due Date")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Expected Qty. (Base)", "Remaining Qty. (Base)", "Cost Amount", "Overhead Amount", "Qty. Picked (Base)";
        }
        key(Key10; Status, "Prod. Order No.", "Prod. Order Line No.", "Item Low-Level Code")
        {
            MaintainSQLIndex = false;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderBOMComment: Record "Prod. Order Comp. Cmt Line";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        NewQuantity: Decimal;
    begin
    end;
}

