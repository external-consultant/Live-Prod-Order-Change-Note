Table 81182 "Prod. Order Comp. change Cmt"
{
    Caption = 'Prod. Order Comp. change note Comment';
    DrillDownPageID = "Prod. Order BOM Cmt List";
    LookupPageID = "Prod. Order BOM Cmt List";
    Description = 'T12149';

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
            NotBlank = true;
#pragma warning disable
            TableRelation = "Production Order"."No." where(Status = field(Status));
#pragma warning disable
        }
        field(3; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
            NotBlank = true;
            TableRelation = "Prod. Order Line"."Line No." where(Status = field(Status),
                                                                 "Prod. Order No." = field("Prod. Order No."));
        }
        field(4; "Prod. Order Component Line No."; Integer)
        {
            Caption = 'Prod. Order BOM Line No.';
            NotBlank = true;
            TableRelation = "Prod. Order Component"."Line No." where(Status = field(Status),
                                                                      "Prod. Order No." = field("Prod. Order No."),
                                                                      "Prod. Order Line No." = field("Prod. Order Line No."));
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(6; "Prod. Order Change Note No."; Code[20])
        {
        }
        field(11; Date; Date)
        {
            Caption = 'Date';
        }
        field(12; Comment; Text[80])
        {
            Caption = 'Comment';
        }
        field(13; "Code"; Code[10])
        {
            Caption = 'Code';
        }
    }

    keys
    {
        key(Key1; Status, "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Component Line No.", "Prod. Order Change Note No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if Status = Status::Finished then
            Error(Text000, Status, TableCaption);
    end;

    trigger OnInsert()
    begin
        if Status = Status::Finished then
            Error(Text000, Status, TableCaption);
    end;

    trigger OnModify()
    begin
        if Status = Status::Finished then
            Error(Text000, Status, TableCaption);
    end;

    var
        Text000: label 'A %1 %2 cannot be inserted, modified, or deleted.';


    procedure SetupNewLine()
    var
        ProdOrderBOMComment: Record "Prod. Order Comp. change Cmt";
    begin
        ProdOrderBOMComment.SetRange(Status, Status);
        ProdOrderBOMComment.SetRange("Prod. Order No.", "Prod. Order No.");
        ProdOrderBOMComment.SetRange("Prod. Order Line No.", "Prod. Order Line No.");
        ProdOrderBOMComment.SetRange("Prod. Order Component Line No.", "Prod. Order Component Line No.");
        ProdOrderBOMComment.SetRange(Date, WorkDate);
        if not ProdOrderBOMComment.FindFirst then
            Date := WorkDate;
    end;


    procedure Caption(): Text
    var
        ProdOrder: Record "Production Order";
        ProdOrderComp: Record "Prod. Order Component";
    begin
        if GetFilters = '' then
            exit('');

        if not ProdOrder.Get(Status, "Prod. Order No.") then
            exit('');

        if not ProdOrderComp.Get(Status, "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Component Line No.") then
            Clear(ProdOrderComp);

        exit(
          StrSubstNo('%1 %2 %3 %4 %5',
            Status, "Prod. Order No.", ProdOrder.Description, ProdOrderComp."Item No.", ProdOrderComp.Description));
    end;
}

