tableextension 81183 "Item jnl Lines Ext" extends "Item Journal Line"
{
    //T12149-NS
    fields
    {
        field(81180; "Cons. Return Ref. No."; Code[20])
        {
            Caption = 'Cons. Return Ref. No.';
            DataClassification = ToBeClassified;
        }
        field(81185; "Receipt No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Description = 'C0011-1001330';
            Editable = false;
        }
        field(81186; "Receipt Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            Description = 'C0011-1001330';
            Editable = false;
        }
    }
    procedure ChechOnlyNegativeConsum_gFnc(ItemJournalLine_iRec: Record "Item Journal Line")
    var
        ItemJouranlLine_lRec: Record "Item Journal Line";
        Text50000_lCtx: label 'must be lessthen zero.';
        ItemJournalTemplate_lRec: Record "Item Journal Template";
    begin
        //I-A012_A-1000467-01-NS
        ItemJouranlLine_lRec.Reset;
        ItemJournalTemplate_lRec.Reset;
        if ItemJournalTemplate_lRec.Get(ItemJournalLine_iRec."Journal Template Name") then begin
            if ItemJournalTemplate_lRec."Source Code" = 'CONSUMPJNL' then begin
                ItemJouranlLine_lRec.SetRange("Journal Template Name", ItemJournalLine_iRec."Journal Template Name");
                ItemJouranlLine_lRec.SetRange("Journal Batch Name", ItemJournalLine_iRec."Journal Batch Name");
                ItemJouranlLine_lRec.SetRange("Location Code", ItemJournalLine_iRec."Location Code");
                ItemJouranlLine_lRec.SetRange("Entry Type", ItemJournalLine_iRec."entry type"::Consumption);
                if ItemJouranlLine_lRec.FindSet(false, false) then begin
                    repeat
                        if ItemJouranlLine_lRec.Quantity > 0 then
                            ItemJouranlLine_lRec.FieldError(Quantity, Text50000_lCtx);
                    until ItemJouranlLine_lRec.Next = 0;
                end;
            end;
        end;
        //I-A012_A-1000467-01-NE
    end;
    //T12149-NE
}
