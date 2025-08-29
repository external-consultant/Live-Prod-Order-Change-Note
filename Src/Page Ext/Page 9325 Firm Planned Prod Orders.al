PageExtension 81180 Firm_Planned_Prod_Orders_50241 extends "Firm Planned Prod. Orders"
{
    actions
    {
        addafter("Prod. Order - Detail Calc.")
        {
            //T12149-NS
            action("Total No. of PCN Posted View")
            {
                Caption = 'Total No. of PCN Posted';
                Image = List;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ProdOrderChangeNoteHeader_lRec: Record "Prod. Order Change Note Header";
                begin
                    ProdOrderChangeNoteHeader_lRec.Reset;
                    ProdOrderChangeNoteHeader_lRec.SetRange("Prod. Order No.", Rec."No.");
                    Page.RunModal(Page::"Posted Prod. Order Change List", ProdOrderChangeNoteHeader_lRec);
                end;
            }

            //T12149-NE
        }
    }
    var
        UserSetup_gRec: Record "User Setup"; //T12149-NS
}

