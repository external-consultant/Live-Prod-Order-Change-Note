TableExtension 81182 Production_Order_33028983 extends "Production Order"
{
    fields
    {
        //T12149-NS
        field(50513; "Latest PCN No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Description = 'T12149';
            Editable = false;
        }
        field(50514; "Total No. of PCN Posted"; Integer)
        {
            BlankZero = true;
            DataClassification = ToBeClassified;
            Description = 'T12149';
            Editable = false;

            trigger OnLookup()
            var
                ProdOrderChangeNoteHeader_lRec: Record "Prod. Order Change Note Header";
            begin
                //T12712-NS
                ProdOrderChangeNoteHeader_lRec.Reset;
                ProdOrderChangeNoteHeader_lRec.SetRange("Prod. Order No.", "No.");
                Page.RunModal(50284, ProdOrderChangeNoteHeader_lRec);
                //T12712-NE
            end;
        }
        field(81180; "No. of Batches"; Integer)
        {
            DataClassification = ToBeClassified;
            Description = 'T12149';
        }
        //T12149-Ne
    }
}

